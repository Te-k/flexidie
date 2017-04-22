package com.vvt.phoenix.prot.databuilder;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.security.interfaces.RSAPublicKey;

import javax.crypto.SecretKey;

import android.os.ConditionVariable;
import android.os.Looper;

import com.vvt.crypto.RSACipher;
import com.vvt.crypto.RSAKeyGenerator;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.CommandMetaDataWrapper;
import com.vvt.phoenix.prot.parser.ProtocolParser;
import com.vvt.phoenix.util.ByteUtil;
import com.vvt.phoenix.util.DataBuffer;
import com.vvt.phoenix.util.IOStreamUtil;
import com.vvt.phoenix.util.crc.CRC32Checksum;
import com.vvt.phoenix.util.crypto.AESCipher;
import com.vvt.phoenix.util.crypto.AESKeyGenerator;

/**
 * @author tanakharn
 * @version 1.0
 * @created 16-Aug-2010 10:50:20 AM
 * Refactoring: January 2012
 */
public class ProtocolPacketBuilder implements com.vvt.crc.CRC32Listener {
	
	// Debugging
	private static final String TAG = "ProtocolPacketBuilder";
	
	// Members
	private ConditionVariable mLock;
	

	/**
	 * 
	 * @param cmdCode
	 * @param dataProvider
	 * @param listener
	 */
	public ProtocolPacketBuilderResponse buildCmdPacketData(CommandMetaData metaData, CommandData commandData, String payloadPath,
			byte[] publicKey, long ssid, int transportDirective) throws Exception{
		
		FxLog.d(TAG, "> buildCmdPacketData");
		ProtocolPacketBuilderResponse response = new ProtocolPacketBuilderResponse();
		mLock = new ConditionVariable();
		//mSsid = ssid;
		
		//2 build payload
		FxLog.v(TAG, "> buildCmdPacketData # Build payload");
		PayloadBuilderResponse payloadResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(metaData, commandData, payloadPath, transportDirective);
		
		//3 initiate meta data wrapper
		CommandMetaDataWrapper metaWrapper = new CommandMetaDataWrapper();
		metaWrapper.setCommandMetaData(metaData);
		metaWrapper.setTransportDirective(transportDirective);
		
		//4 calculate and set payload size
		FxLog.v(TAG, "> buildCmdPacketData # Calculate payload size");
		int payloadSize = calculatePayloadSize(payloadResponse);
		metaWrapper.setPayloadSize(payloadSize);

		//5 calculate and set payload crc32
		if(payloadResponse.getPayloadType() == PayloadType.BUFFER){
			FxLog.v(TAG, "> buildCmdPacketData # Calculate payload CRC value using synchronous method");
			metaWrapper.setPayloadCrc32(com.vvt.crc.CRC32Checksum.calculate(payloadResponse.getData()));
		}else{
			FxLog.v(TAG, String.format("> buildCmdPacketData # Calculate payload CRC value using asynchronous method - Thread ID %d", 
					Thread.currentThread().getId()));
			final String responsePayloadPath = payloadResponse.getPayloadPath();
			Thread crcCallerThread = new Thread(){
				@Override
				public void run(){
					Looper.prepare();
					FxLog.v(TAG, String.format("> buildCmdPacketData > run # Calculate payload CRC value using asynchronous method - Thread ID %d", 
							Thread.currentThread().getId()));
					com.vvt.crc.CRC32Checksum crc = new com.vvt.crc.CRC32Checksum();
					crc.calculate(responsePayloadPath, ProtocolPacketBuilder.this);
					Looper.loop();
				}
			};
			crcCallerThread.setPriority(Thread.MIN_PRIORITY);
			crcCallerThread.start();
			mLock.block();
			mLock.close();
			if( !mCalculatePayloadCrcSuccess ){	// exception while calculate Payload Crc32
				throw mPayloadException;
			}
			metaWrapper.setPayloadCrc32(mPayloadCrc);
		}
		
		//6 parsing CommandMetaDataWrapper
		FxLog.v(TAG, "> buildCmdPacketData # Parsing meta data");
		byte[] protMetaData = ProtocolParser.parseCommandMetadata(metaWrapper);

		//7 encrypt parsedMetaData
		FxLog.v(TAG, "> buildCmdPacketData # Encrypt meta data");
		byte[] encryptedProtMetaData = com.vvt.crypto.AESCipher.encrypt(payloadResponse.getAesKey(), protMetaData);
		
		//8 calculate encryptedParsedMetaData crc32
		FxLog.v(TAG, "> buildCmdPacketData # Calculate meta data CRC value");
		long metaDataCrcValue = com.vvt.crc.CRC32Checksum.calculate(encryptedProtMetaData);

		//9 calculate meta data length
		int metaDataLen = encryptedProtMetaData.length;
		
		//10 encrypt AES Key with RSA Public Key
		FxLog.v(TAG, "> buildCmdPacketData # Encrypt secret key using public key");
		RSAPublicKey pk = RSAKeyGenerator.generatePublicKeyFromRaw(publicKey);
		byte[] encryptedAesKey = RSACipher.encrypt(pk, payloadResponse.getAesKey().getEncoded());

		//11 parse meta data with header
		FxLog.v(TAG, "> buildCmdPacketData # Parsing ready meta data with meta data header");
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//Encryption Type
		stream.write((byte) 1);
		//Session ID
		stream.write(ByteUtil.toBytes((int) ssid), 0, 4);
		//Encrypted AES Key with length
		stream.write(ByteUtil.toBytes((short) encryptedAesKey.length), 0, 2);
		stream.write(encryptedAesKey, 0, encryptedAesKey.length);
		//Request Length
		stream.write(ByteUtil.toBytes((short) metaDataLen), 0, 2);
		//MetaData CRC32
		stream.write(ByteUtil.toBytes((int) metaDataCrcValue), 0, 4);
		//Encrypted MetaData
		stream.write(encryptedProtMetaData, 0, encryptedProtMetaData.length);
		
		//12 set up response
		response.setAesKey(payloadResponse.getAesKey());
		response.setMetaDataWithHeader(stream.toByteArray());
		IOStreamUtil.safelyCloseStream(stream);
		response.setPayloadCrc32(mPayloadCrc);
		response.setPayloadSize(payloadSize);
		response.setPayloadType(payloadResponse.getPayloadType());
		response.setPayloadData(payloadResponse.getData());
		response.setPayloadPath(payloadResponse.getPayloadPath());

		FxLog.i(TAG, "> buildCmdPacketData # OK");
		
		return response;
	}
	
	public ProtocolPacketBuilderResponse buildResumePacketData(CommandMetaData metaData, String payloadPath,
			byte[] publicKey, byte[] aesKey, long ssid, int transportDirective, int payloadSize, long payloadCrc) throws Exception{
		
		FxLog.d(TAG, "> buildResumePacketData");
		
		ProtocolPacketBuilderResponse response = new ProtocolPacketBuilderResponse();
		//mSsid = ssid;
		
		//1 initiate meta data wrapper
		CommandMetaDataWrapper metaWrapper = new CommandMetaDataWrapper();
		metaWrapper.setCommandMetaData(metaData);
		metaWrapper.setTransportDirective(transportDirective);
		
		//2 set payload size
		metaWrapper.setPayloadSize(payloadSize);
		
		//3 set payload crc32
		metaWrapper.setPayloadCrc32(payloadCrc);

		//4 parsing CommandMetaDataWrapper
		byte[] parsedMetaData = ProtocolParser.parseCommandMetadata(metaWrapper);
		
		//5 encrypt parsedMetaData
		SecretKey secretKey = AESKeyGenerator.generateKeyFromRaw(aesKey);
		//TODO change to new AESCipher
		byte[] encryptedParsedMetaData = AESCipher.encryptSynchronous(secretKey, parsedMetaData);
		
		//6 calculate encryptedParsedMetaData crc32
		long metaDataCrcValue = CRC32Checksum.calculateSynchronous(encryptedParsedMetaData);

		//7 calculate meta data length
		//TODO what is the bound of REQUEST_LENGTH ?
		int metaDataLen = encryptedParsedMetaData.length;

		//8 encrypt AES Key with RSA Public Key
		RSAPublicKey pk = RSAKeyGenerator.generatePublicKeyFromRaw(publicKey);	//in real scenario this PK will come from KeyExchange
		byte[] encryptedAesKey = RSACipher.encrypt(pk, aesKey);

		//9 parse meta data with header
		DataBuffer buffer = new DataBuffer();
		//Encryption Type
		buffer.writeByte((byte) 1);
		//Session ID
		buffer.writeInt((int) ssid);
		//Encrypted AES Key with length
		buffer.writeShort((short) encryptedAesKey.length);
		buffer.writeBytes(encryptedAesKey);
		//Request Length
		buffer.writeShort((short) metaDataLen);
		//MetaData CRC32
		buffer.writeInt((int) metaDataCrcValue);
		//Encrypted MetaData
		buffer.writeBytes(encryptedParsedMetaData);
		
		//10 set up response
		response.setAesKey(secretKey);
		response.setMetaDataWithHeader(buffer.toArray());
		response.setPayloadCrc32(payloadCrc);
		response.setPayloadSize(payloadSize);
		response.setPayloadType(PayloadType.FILE);
		response.setPayloadPath(payloadPath);

		return response;
	}
	
	private int calculatePayloadSize(PayloadBuilderResponse response){
		if(response.getPayloadType() == PayloadType.BUFFER){
			return response.getData().length;
		}else{
			File f = new File(response.getPayloadPath());
			return (int) f.length();
		}
	}
	
	// variables for handles Payload CRC calculation operation
	private long mPayloadCrc;
	private boolean mCalculatePayloadCrcSuccess;
	private Exception mPayloadException;
	
	@Override
	public void onCalculateCRC32Error(Exception err) {
		FxLog.w(TAG, String.format("> onCalculateCRC32Error # %s - Thread ID: %d", err.getMessage(), Thread.currentThread().getId()));
		mCalculatePayloadCrcSuccess = false;
		mPayloadException = err;
		mLock.open();
	}

	@Override
	public void onCalculateCRC32Success(long result) {
		FxLog.d(TAG, String.format("> onCalculateCRC32Success(long) # Result: %d - Thread ID: %d", result, Thread.currentThread().getId()));
		// for test handle calculate CRC error
		/*if(true){
			onCalculateCRC32Error(new Exception("Dummy Exception while do asynchronous CRC calculation."));
			return;
		}*/
		mCalculatePayloadCrcSuccess = true;
		mPayloadCrc = result;
		mLock.open();
	}
	
}
