package com.vvt.phoenix.prot.test.databuilder;

import java.io.FileOutputStream;
import java.security.interfaces.RSAPrivateKey;

import android.util.Log;

import com.vvt.phoenix.prot.TransportDirectives;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.Languages;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.databuilder.ProtocolPacketBuilder;
import com.vvt.phoenix.prot.databuilder.ProtocolPacketBuilderResponse;
import com.vvt.phoenix.util.DataBuffer;
import com.vvt.phoenix.util.crypto.AESCipher;
import com.vvt.phoenix.util.crypto.RSACipher;
import com.vvt.phoenix.util.crypto.RSAKeyGenerator;

/**
 * @author tanakharn
 * This class act like CommandExecutor
 */
public class ProtocolPacketBuilderTest {
	//Debugging
	private static final String TAG = "ProtocolPacketBuilderTest";
	
	//Members
	private RSAKeyGenerator mKeyGen;
	private CommandMetaData mMetaData;
	private CommandData mCommandData;
	private byte[] mPublicKey;
	private long mSsid;
	private int mTransportDirective = TransportDirectives.RESUMABLE;
	//private int mTransportDirective = TransportDirectives.NON_RESUMABLE;
	
	private static final String PAYLOAD_PATH = "/sdcard/prot/payload.prot";
	private static final String DECOMPRESS_PATH = "/sdcard/prot/payload_decompress.prot";
	private static final String DECRYPT_PATH = "/sdcard/prot/payload_decrypt.prot";
	
	private static final String DEBUG_FILE_PATH = "/sdcard/prot/protData.prot";
	
	private ProtocolPacketBuilderResponse mResponse;
	
	private void createMetaData(){

		mMetaData = new CommandMetaData();
		mMetaData.setProtocolVersion(1);
		mMetaData.setProductId(4);
		mMetaData.setProductVersion("FXS2.0");
		mMetaData.setConfId(2);
		mMetaData.setDeviceId("N1");
		mMetaData.setActivationCode("1150");
		mMetaData.setLanguage(Languages.THAI);
		mMetaData.setPhoneNumber("0800999999");
		mMetaData.setMcc("MCC");
		mMetaData.setMnc("MNC");
		mMetaData.setImsi("IMSI");
		//mMetaData.setTransportDirective(TransportDirectives.RESUMABLE);
		//mMetaData.setTransportDirective(TransportDirectives.NON_RESUMABLE);
		mMetaData.setEncryptionCode(1);
		mMetaData.setCompressionCode(1);
	}
	
	
	public void testProtocolPacketBuilder(){
		//1 create MetaData
		createMetaData();
		
		//2 prepare command data
		SendActivate commandData = new SendActivate();
		commandData.setDeviceInfo("I'm Super Phone");
		commandData.setDeviceModel("Nexus One");
		
		//3 prepare public key
		mKeyGen = new RSAKeyGenerator();
		mPublicKey = mKeyGen.getPublicKey().getEncoded();
		
		//4 prepare SSID
		mSsid = 1;
		
		
		
		//3 build Protocol Packet
		try {
			ProtocolPacketBuilder builder = new ProtocolPacketBuilder();
			mResponse = builder.buildCmdPacketData(mMetaData, commandData, PAYLOAD_PATH, mPublicKey, mSsid, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 display response details
		showResponseDetails();
		
		//5 write extracted data to file
		try {
			writeReadableDataToFile();
		} catch (Exception e) {
			Log.e(TAG, "Exception while writing response to Debug File: "+e.getMessage());
		}
	}
	
	private void showResponseDetails(){
		Log.v(TAG, "MetaData with Header: "+mResponse.getMetaDataWithHeader());
		Log.v(TAG, "Payload Path: "+mResponse.getPayloadPath());
		Log.v(TAG, "AES Key: "+mResponse.getAesKey());
		Log.v(TAG, "Payload Type: "+mResponse.getPayloadType());
		Log.v(TAG, "Payload Data: "+mResponse.getPayloadData());
		Log.v(TAG, "Payload Size: "+mResponse.getPayloadSize());
		Log.v(TAG, "Payload CRC: "+mResponse.getPayloadCrc32());
	
	}
	
	private void writeReadableDataToFile() throws Exception{
		//1 prepare output file
		FileOutputStream fOut = new FileOutputStream(DEBUG_FILE_PATH);
		DataBuffer outBuf = new DataBuffer();
		
		//2 buffer meta data
		DataBuffer metaBuffer = new DataBuffer(mResponse.getMetaDataWithHeader());
		
		//3 write meta data header to file
		// encryption type
		outBuf.writeByte(metaBuffer.readByte());
		// SSID
		outBuf.writeInt(metaBuffer.readInt());
		// AES KEY (Encrypted)
		int keyLen = metaBuffer.readShort();
		Log.v(TAG, "keyLen: "+keyLen);
		outBuf.writeShort((short) keyLen);
		outBuf.writeBytes(metaBuffer.readBytes(keyLen));
		// request length
		int reqLen = metaBuffer.readShort();
		outBuf.writeShort((short) reqLen);
		// crc32
		int crc = metaBuffer.readInt();
		outBuf.writeInt(crc);
		
		//4 decrypt meta data and write to file
		byte[] encryptedMetaData = metaBuffer.readBytes(reqLen);
		Log.v(TAG, "encryptedMetaData Len: "+encryptedMetaData.length);
		//TODO Debug
		//fOut.write(encryptedMetaData);
		byte[] metaData = null;
		try{
			metaData = AESCipher.decryptSynchronous(mResponse.getAesKey(), encryptedMetaData);
		}catch(Exception e){
			Log.e(TAG, "Exception while decrypt meta data: "+e.getMessage());
		}
		outBuf.writeBytes(metaData);
		//outBuf.writeBytes(encryptedMetaData);	//for test correction of REQUEST_LENGTH
		
		fOut.write(outBuf.toArray());
		fOut.close();
	}
	
	
}
