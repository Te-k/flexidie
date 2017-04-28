package com.vvt.phoenix.prot.databuilder.test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.security.InvalidKeyException;
import java.security.interfaces.RSAPrivateKey;
import java.util.Arrays;

import javax.crypto.SecretKey;

import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.crc.CRC32Checksum;
import com.vvt.crypto.AESCipher;
import com.vvt.crypto.AESKeyGenerator;
import com.vvt.crypto.RSACipher;
import com.vvt.crypto.RSAKeyGenerator;
import com.vvt.phoenix.prot.TransportDirectives;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.databuilder.ProtocolPacketBuilder;
import com.vvt.phoenix.prot.databuilder.ProtocolPacketBuilderResponse;
import com.vvt.phoenix.prot.event.PanicStatus;
import com.vvt.phoenix.prot.test.PhoenixTestUtil;
import com.vvt.phoenix.util.ByteUtil;

public class ProtocolPacketBuilderTest extends AndroidTestCase{
	
	private static final String TAG = "ProtocolPacketBuilderTest";
	
	private static final String PAYLOAD_PATH = "/sdcard/payload.out";
	private static final long SSID = 91;
	private static final int CONFIG_ID = 104;
	private static final String ACTIVATION_CODE = "01329";
	
	private static final boolean TEST_BUILD_COMMAND_PACKET_DATA = false;
	private static final boolean TEST_HANDLE_BUILD_COMMAND_PACKET_DATA_CALCULATE_CRC_ERROR = false;
	private static final boolean TEST_BUILD_RESUME_PACKET_DATA = true;
	
	public void testCases(){
		if(TEST_BUILD_COMMAND_PACKET_DATA){
			_testBuildCommandPacketData();
		}
		if(TEST_HANDLE_BUILD_COMMAND_PACKET_DATA_CALCULATE_CRC_ERROR){
			_testHandleBuildCommandPacketDataCalculateCrcError();
		}
		if(TEST_BUILD_RESUME_PACKET_DATA){
			_testBuildResumePacketData();
		}
	}

	private void _testBuildCommandPacketData(){
		Log.d(TAG, "_testBuildCommandPacketData");
		
		//1 building protocol packet
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		CommandMetaData metaData = PhoenixTestUtil.createMetaData(CONFIG_ID, ACTIVATION_CODE, getContext());
		EventProvider provider = new EventProvider();
    	PanicStatus event = new PanicStatus();
    	event.setEventTime(eventTime);
    	event.setStartPanic();
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
    	RSAKeyGenerator rsaKeys = new RSAKeyGenerator();
    	ProtocolPacketBuilder builder = new ProtocolPacketBuilder();
    	ProtocolPacketBuilderResponse response = null;
    	try {
    		response =  builder.buildCmdPacketData(metaData, commandData, PAYLOAD_PATH, rsaKeys.getPublicKey().getEncoded(), 
    				SSID, TransportDirectives.RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		
		/*
		 * 2 prepare expected and compare (We can't prepare expected result at the first step since we need AES key that returned from building step)
		 * Separate expected into 5 parts
		 * 1: Meta data header - encryption type, session ID, encrypted key length
		 * 2: AES key
		 * 3: Request length
		 * 4: Meta data CRC value
		 * 5: Meta data
		 */
    	byte[] metaWithHeader = response.getMetaDataWithHeader();
    	ByteArrayInputStream resultStream = new ByteArrayInputStream(metaWithHeader);
    	
    	//first part : encryption type, session ID, encrypted key length
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//Encryption Type : 1 byte
		stream.write((byte) 1);
		//Session ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) SSID), 0, 4);
		//encrypted AES key length (64 bytes) : 2 bytes
		stream.write(ByteUtil.toBytes((short) 64), 0, 2);
		byte[] result = new byte[7];
		resultStream.read(result, 0, result.length);		
		//compare first part
		assertEquals(true, Arrays.equals(stream.toByteArray(), result));
		
		//second part : AES key
		//decrypt AES key
		byte[] encryptedKey = new byte[64];
		resultStream.read(encryptedKey, 0, 64);
		try {
			result = RSACipher.decrypt((RSAPrivateKey) rsaKeys.getPrivateKey(), encryptedKey);
		} catch (InvalidKeyException e) {
			fail(e.getMessage());
		}
		assertEquals(true, Arrays.equals(response.getAesKey().getEncoded(), result));
		
		//third part : Request length
		  //grab request length
		result = new byte[2];
		resultStream.read(result, 0, 2);
		int requestLen = ByteUtil.toShort(result);
		  //calculate CRC from remaining byte data
		int calculatelen = metaWithHeader.length - 77; // 77 = 13 (header) + 64 (AES key length)
		assertEquals(calculatelen, requestLen);
		
		//fourth part : Meta data CRC value
		  //grab CRC value
		result = new byte[8];
		resultStream.read(result, 4, 4);
		long storedCrc = ByteUtil.toLong(result);
		  //calculate CRC value
		result = new byte[requestLen];
		resultStream.read(result, 0, requestLen);
		long calculateCrc = CRC32Checksum.calculate(result);
		assertEquals(calculateCrc, storedCrc);		
		
		// fifth part : validate meta data fields
		  //decrypt meta data
		try {
			result = AESCipher.decrypt(response.getAesKey(), result);
		} catch (InvalidKeyException e) {
			fail(e.getMessage());
		}
		resultStream = new ByteArrayInputStream(result);
		  //protocol version
		byte[] buffer = new byte[2];
		resultStream.read(buffer, 0, 2);
		assertEquals(metaData.getProtocolVersion(), ByteUtil.toShort(buffer));
		  //product ID
		buffer = new byte[2];
		resultStream.read(buffer, 0, 2);
		assertEquals(metaData.getProductId(), ByteUtil.toShort(buffer));
		  //product version
		int length = resultStream.read();
		buffer = new byte[length];
		resultStream.read(buffer, 0, length);
		assertEquals(true, metaData.getProductVersion().equals(new String(buffer)));
		  //configuration ID
		buffer = new byte[2];
		resultStream.read(buffer, 0, 2);
		assertEquals(metaData.getConfId(), ByteUtil.toShort(buffer));
		  //device ID
		length = resultStream.read();
		buffer = new byte[length];
		resultStream.read(buffer, 0, length);
		assertEquals(true, metaData.getDeviceId().equals(new String(buffer)));
		  //activation code
		length = resultStream.read();
		buffer = new byte[length];
		resultStream.read(buffer, 0, length);
		assertEquals(true, metaData.getActivationCode().equals(new String(buffer)));
		  //language
		assertEquals(metaData.getLanguage(), resultStream.read());
		  //phone number
		length = resultStream.read();
		buffer = new byte[length];
		resultStream.read(buffer, 0, length);
		assertEquals(true, metaData.getPhoneNumber().equals(new String(buffer)));
		  //MCC
		length = resultStream.read();
		buffer = new byte[length];
		resultStream.read(buffer, 0, length);
		assertEquals(true, metaData.getMcc().equals(new String(buffer)));
		  //MNC
		length = resultStream.read();
		buffer = new byte[length];
		resultStream.read(buffer, 0, length);
		assertEquals(true, metaData.getMnc().equals(new String(buffer)));
		  //IMSI
		length = resultStream.read();
		buffer = new byte[length];
		resultStream.read(buffer, 0, length);
		assertEquals(true, metaData.getImsi().equals(new String(buffer)));
		  //host URL
		length = resultStream.read();
		buffer = new byte[length];
		resultStream.read(buffer, 0, length);
		assertEquals(true, metaData.getHostUrl().equals(new String(buffer)));
		  //transport directive
		assertEquals(TransportDirectives.RESUMABLE, resultStream.read());
		  //encryption code
		assertEquals(metaData.getEncryptionCode(), resultStream.read());
		  //compression code
		assertEquals(metaData.getCompressionCode(), resultStream.read());
		  //payload size
		buffer = new byte[4];
		resultStream.read(buffer, 0, 4);
		assertEquals(response.getPayloadSize(), ByteUtil.toInt(buffer));
		  //payload  CRC value
		buffer = new byte[8];
		resultStream.read(buffer, 4, 4);
		long storedPayloadCrc = ByteUtil.toLong(buffer);
		assertEquals(response.getPayloadCrc32(), storedPayloadCrc);
	}
	
	/**
	 * To test this case
	 * you will have to call onCalculateCRC32Error() from onCalculateCRC32Success() 
	 */
	private void _testHandleBuildCommandPacketDataCalculateCrcError(){
		Log.d(TAG, "_testHandleBuildCOmmandPacketDataCalculateCrcError");
		
		//1 building protocol packet
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		CommandMetaData metaData = PhoenixTestUtil.createMetaData(CONFIG_ID, ACTIVATION_CODE, getContext());
		EventProvider provider = new EventProvider();
    	PanicStatus event = new PanicStatus();
    	event.setEventTime(eventTime);
    	event.setStartPanic();
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
    	RSAKeyGenerator rsaKeys = new RSAKeyGenerator();
    	ProtocolPacketBuilder builder = new ProtocolPacketBuilder();
    	try {
    		builder.buildCmdPacketData(metaData, commandData, PAYLOAD_PATH, rsaKeys.getPublicKey().getEncoded(), 
    				SSID, TransportDirectives.RESUMABLE);
    		fail("Should have thrown Exception");
		} catch (Exception e) {
			Log.e(TAG, String.format("> _testHandleBuildCOmmandPacketDataCalculateCrcError # %s", e.getMessage()));
		}
	}

	private void _testBuildResumePacketData(){
		//TODO
		Log.d(TAG, "> _testBuildResumePacketData");
		
		CommandMetaData metaData = PhoenixTestUtil.createMetaData(CONFIG_ID, ACTIVATION_CODE, getContext());
		RSAKeyGenerator rsaKeyGen = new RSAKeyGenerator();
		SecretKey aesKey = AESKeyGenerator.generate();
		int payloadSize = 1024;
		long payloadCrc = 6996;
				

		//2 parsing resume packet
		ProtocolPacketBuilder builder = new ProtocolPacketBuilder();
    	ProtocolPacketBuilderResponse response = null;
    	try {
    		response = builder.buildResumePacketData(metaData, PAYLOAD_PATH, rsaKeyGen.getPublicKey().getEncoded(), aesKey.getEncoded(), 
    				SSID, TransportDirectives.RSEND, payloadSize, payloadCrc);
		} catch (Exception e) {
			fail(e.getMessage());
		}
    	
    	/*
    	 * 2 compare with expected result
    	 * We cannot prepare expected result before parsing data
    	 * since we don't know CRC value
    	 */
		 ByteArrayInputStream resultStream = new ByteArrayInputStream(response.getMetaDataWithHeader());
		 ByteArrayOutputStream expectedStream = new ByteArrayOutputStream();
		 byte[] buffer;
		 int length;
		 //2.1 check encryption type and SSID
		 expectedStream.write(1);	//encryption type : 1 byte
		 expectedStream.write(ByteUtil.toBytes((int) SSID), 0, 4);	//SSID : 4 bytes
		 buffer = new byte[5];
		 resultStream.read(buffer, 0, 5);
		 assertEquals(true, Arrays.equals(expectedStream.toByteArray(), buffer));
		 //2.2 check AES key
		 /*expectedStream.reset();
		 buffer = aesKey.getEncoded();
		 expectedStream.write(buffer, 0, buffer.length);
		 buffer = new byte[2];
		 length = resultStream.read(buffer, 0, 2);*/
		 

	}

}
