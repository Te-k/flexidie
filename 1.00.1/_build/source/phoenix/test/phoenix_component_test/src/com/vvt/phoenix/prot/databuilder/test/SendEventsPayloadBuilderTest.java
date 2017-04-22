package com.vvt.phoenix.prot.databuilder.test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.security.InvalidKeyException;
import java.util.Arrays;

import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.phoenix.prot.TransportDirectives;
import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.databuilder.PayloadBuilderResponse;
import com.vvt.phoenix.prot.databuilder.PayloadType;
import com.vvt.phoenix.prot.databuilder.SendEventsPayloadBuilder;
import com.vvt.phoenix.prot.event.EventType;
import com.vvt.phoenix.prot.event.MediaType;
import com.vvt.phoenix.prot.event.PanicImage;
import com.vvt.phoenix.prot.test.PhoenixTestUtil;
import com.vvt.phoenix.util.ByteUtil;

public class SendEventsPayloadBuilderTest extends AndroidTestCase{
	
	private static final String TAG = "SendEventsPayloadBuilderTest";
	
	//constants
	private static final String PAYLOAD_PATH = "/sdcard/payload.out";
	private static final String MEDIA_PATH = "/sdcard/image.jpg";
	private static final double LATTITUDE = 100.12345;
	private static final double LONGITUDE = 45.12345;
	private static final float ALTITUDE = 50.9876f;
	private static final int COORDINATE_ACCURACY = 1;
	private static final String NETWORK_NAME = "AIS VVT";
	private static final String NETWORK_ID = "1q2w3e4r5t";
	private static final String CELL_NAME = "VVT CELL";
	private static final int COUNTRY_CODE = 66;
	private static final int CELL_ID = 12345;
	private static final int AREA_CODE = 999;	
	
	//common test
	private static final boolean TEST_BUILD_SEND_EVENT_PAYLOAD = true;
	private static final boolean TEST_HANDLE_NULL_ARGUMENTS = false;
	private static final boolean TEST_HANDLE_BUILD_SEND_EVENT_PAYLOAD_EXCEPTION = false;
	private static final boolean TEST_BUILD_SEND_EVENT_PAYLOAD_ON_MEMORY = true;
	//memory compression test
	private static final boolean TEST_COMPRESS_PAYLOAD_ON_MEMORY = true;
	private static final boolean TEST_HANDLE_COMPRESS_PAYLOAD_ON_MEMORY_ERROR = false;
	//memory encryption test
	private static final boolean TEST_ENCRYPT_PAYLOAD_ON_MEMORY = true;
	private static final boolean TEST_HANDLE_ENCRYPT_PAYLOAD_ON_MEMORY_ERROR = false;
	//memory compression and encryption test
	private static final boolean TEST_COMPRESS_AND_ENCRYPT_PAYLOAD_ON_MEMORY = true;
	private static final boolean TEST_HANDLE_COMPRESS_AND_ENCRYPT_PAYLOAD_ON_MEMORY_ERROR = false;
	//file compression test
	private static final boolean TEST_COMPRESS_PAYLOAD = true;
	private static final boolean TEST_HANDLE_COMPRESS_PAYLOAD_ERROR = false;
	//file encryption test
	private static final boolean TEST_ENCRYPT_PAYLOAD = true;
	private static final boolean TEST_HANDLE_ENCRYPT_PAYLOAD_ERROR = false;
	//file compression and encryption test
	private static final boolean TEST_COMPRESS_AND_ENCRYPT_PAYLOAD = true;
	private static final boolean TEST_HANDLE_COMPRESS_AND_ENCRYPT_PAYLOAD_ERROR = false;	
	
	public void testCases(){
		//common test
		if(TEST_BUILD_SEND_EVENT_PAYLOAD){
			_testBuildSendEventPayload();
		}
		if(TEST_HANDLE_NULL_ARGUMENTS){
			_testHandleNullArguments();
		}
		if(TEST_HANDLE_BUILD_SEND_EVENT_PAYLOAD_EXCEPTION){
			_testHandleBuildSendEventPayloadException();
		}
		if(TEST_BUILD_SEND_EVENT_PAYLOAD_ON_MEMORY){
			_testBuildSendEventPayloadOnMemory();
		}
		//memory compression test
		if(TEST_COMPRESS_PAYLOAD_ON_MEMORY){
			_testCompressPayloadOnMemory();
		}
		if(TEST_HANDLE_COMPRESS_PAYLOAD_ON_MEMORY_ERROR){
			_testHandleCompressPayloadOnMemoryError();
		}
		//memory encryption test
		if(TEST_ENCRYPT_PAYLOAD_ON_MEMORY){
			_testEncryptPayloadOnMemory();
		}
		if(TEST_HANDLE_ENCRYPT_PAYLOAD_ON_MEMORY_ERROR){
			_testHandleEncryptPayloadOnMemoryError();
		}
		//memory compression and encryption test
		if(TEST_COMPRESS_AND_ENCRYPT_PAYLOAD_ON_MEMORY){
			_testCompressAndEncryptPayloadOnMemory();
		}
		if(TEST_HANDLE_COMPRESS_AND_ENCRYPT_PAYLOAD_ON_MEMORY_ERROR){
			_testHandleCompressAndEncryptPayloadOnMemoryError();
		}
		//file compression test
		if(TEST_COMPRESS_PAYLOAD){
			_testCompressPayload();
		}
		if(TEST_HANDLE_COMPRESS_PAYLOAD_ERROR){
			_testHandleCompressPayloadError();
		}
		//file encryption test
		if(TEST_ENCRYPT_PAYLOAD){
			_testEncryptPayload();
		}
		if(TEST_HANDLE_ENCRYPT_PAYLOAD_ERROR){
			_testHandleEncryptPayloadError();
		}
		//file compression and encryption test
		if(TEST_COMPRESS_AND_ENCRYPT_PAYLOAD){
			_testCompressAndEncryptPayload();
		}
		if(TEST_HANDLE_COMPRESS_AND_ENCRYPT_PAYLOAD_ERROR){
			_testHandleCompressAndEncryptPayloadError();
		}
	}
		
	// ****************************************** Test Cases ************************************ //

	private void _testBuildSendEventPayload(){
		Log.d(TAG, "_testBuildSendEventPayload");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//comand code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(0);
		metaData.setEncryptionCode(0);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, PAYLOAD_PATH, TransportDirectives.RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = PhoenixTestUtil.readFile(PAYLOAD_PATH);
		
		//3 compare
		assertEquals(PayloadType.FILE, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testHandleNullArguments(){
		Log.d(TAG, "_testHandleNullArguments");
		
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		
		// null metadata
		try {
			builder.buildPayload(null, null, null, TransportDirectives.RESUMABLE);
			fail("Should have thrown IllgalArgumentException");
		} catch (Exception e) {
			Log.e(TAG, String.format("> _testHandleNullArguments # %s", e.getMessage()));
		}
		
		// null command data
		try {
			builder.buildPayload(new CommandMetaData(), null, null, TransportDirectives.RESUMABLE);
			fail("Should have thrown IllgalArgumentException");
		} catch (Exception e) {
			Log.e(TAG, String.format("> _testHandleNullArguments # %s", e.getMessage()));
		}
		
		// null payload path
		try {
			builder.buildPayload(new CommandMetaData(), new SendEvents(), null, TransportDirectives.RESUMABLE);
			fail("Should have thrown IllgalArgumentException");
		} catch (Exception e) {
			Log.e(TAG, String.format("> _testHandleNullArguments # %s", e.getMessage()));
		}
	}
	
	/**
	 * To test this case
	 * You have to add Dummy Exception
	 * inside SendEventsPayloadBuilder
	 */
	private void _testHandleBuildSendEventPayloadException(){
		Log.d(TAG, "_testHandleBuildSendEventPayloadException");
		
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		try {
			builder.buildPayload(new CommandMetaData(), new SendEvents(), PAYLOAD_PATH, TransportDirectives.RESUMABLE);
			fail("Should have thrown Exception");
		} catch (Exception e) {
			Log.e(TAG, String.format("> _testHandleBuildSendEventPayloadException # %s", e.getMessage()));
		}
	}

	private void _testBuildSendEventPayloadOnMemory(){
		Log.d(TAG, "_testBuildSendEventPayloadOnMemory");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(0);
		metaData.setEncryptionCode(0);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, null, TransportDirectives.NON_RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = response.getData();
		
		//3 compare
		assertEquals(PayloadType.BUFFER, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testCompressPayloadOnMemory(){
		Log.d(TAG, "_testCompressPayloadOnMemory");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(1);
		metaData.setEncryptionCode(0);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, null, TransportDirectives.NON_RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] compressedResult = response.getData();
		
		//3 decompress
		byte[] result = PhoenixTestUtil.decompress(new ByteArrayInputStream(compressedResult));
		
		//4 compare
		assertEquals(1, metaData.getCompressionCode());
		assertEquals(PayloadType.BUFFER, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	/**
	 * To test this case you have to add Dummy Exception inside SendEventsPayloadBuilder
	 * at synchronous compression step.
	 */
	private void _testHandleCompressPayloadOnMemoryError(){
		Log.d(TAG, "_testHandleCompressPayloadOnMemoryError");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(1);
		metaData.setEncryptionCode(0);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, null, TransportDirectives.NON_RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = response.getData();
		
		//3 compare
		assertEquals(0, metaData.getCompressionCode());
		assertEquals(PayloadType.BUFFER, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testEncryptPayloadOnMemory(){
		Log.d(TAG, "_testEncryptPayloadOnMemory");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(0);
		metaData.setEncryptionCode(1);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, null, TransportDirectives.NON_RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] encryptedResult = response.getData();
		
		//3 decompress
		byte[] result = null;
		try {
			result = PhoenixTestUtil.decrypt(response.getAesKey(), encryptedResult);
		} catch (InvalidKeyException e) {
			fail(e.getMessage());
		}
		
		//4 compare
		assertEquals(1, metaData.getEncryptionCode());
		assertEquals(PayloadType.BUFFER, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}

	/**
	 * To test this case you have to add Dummy Exception inside SendEventsPayloadBuilder
	 * at synchronous encryption step.
	 */
	private void _testHandleEncryptPayloadOnMemoryError(){
		Log.d(TAG, "_testHandleEncryptPayloadOnMemoryError");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(0);
		metaData.setEncryptionCode(1);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, null, TransportDirectives.NON_RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = response.getData();
		
		//3 compare
		assertEquals(0, metaData.getEncryptionCode());
		assertEquals(PayloadType.BUFFER, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testCompressAndEncryptPayloadOnMemory(){
		Log.d(TAG, "_testCompressAndEncryptPayloadOnMemory");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(1);
		metaData.setEncryptionCode(1);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, null, TransportDirectives.NON_RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] encryptedResult = response.getData();
		
		//3 decrypt
		byte[] decrypted = null;
		try {
			decrypted = PhoenixTestUtil.decrypt(response.getAesKey(), encryptedResult);
		} catch (InvalidKeyException e) {
			fail(e.getMessage());
		}
		
		//4 decompress
		byte[] result = PhoenixTestUtil.decompress(new ByteArrayInputStream(decrypted));
		
		
		//5 compare
		assertEquals(1, metaData.getEncryptionCode());
		assertEquals(1, metaData.getCompressionCode());
		assertEquals(PayloadType.BUFFER, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	/**
	 * To test this case you have to add Dummy Exception inside SendEventsPayloadBuilder
	 * at synchronous encryption and compression step.
	 */
	private void _testHandleCompressAndEncryptPayloadOnMemoryError(){
		Log.d(TAG, "_testHandleCompressAndEncryptPayloadOnMemoryError");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(1);
		metaData.setEncryptionCode(1);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, null, TransportDirectives.NON_RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = response.getData();
		
		//3 compare
		assertEquals(0, metaData.getEncryptionCode());
		assertEquals(0, metaData.getCompressionCode());
		assertEquals(PayloadType.BUFFER, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testCompressPayload(){
		Log.d(TAG, "_testCompressPayload");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//comand code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(1);
		metaData.setEncryptionCode(0);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, PAYLOAD_PATH, TransportDirectives.RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] compressed = PhoenixTestUtil.readFile(PAYLOAD_PATH);
		
		//3 decompress
		byte[] result = PhoenixTestUtil.decompress(new ByteArrayInputStream(compressed));
		
		//3 compare
		assertEquals(1, metaData.getCompressionCode());
		assertEquals(PayloadType.FILE, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}

	/**
	 * To test this case you have to add Dummy Exception inside SendEventsPayloadBuilder
	 * at onCompressSuccess() step.
	 */
	private void _testHandleCompressPayloadError(){
		Log.d(TAG, "_testHandleCompressPayloadError");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//comand code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(1);
		metaData.setEncryptionCode(0);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, PAYLOAD_PATH, TransportDirectives.RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = PhoenixTestUtil.readFile(PAYLOAD_PATH);
		//3 compare
		assertEquals(0, metaData.getCompressionCode());
		assertEquals(PayloadType.FILE, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testEncryptPayload(){
		Log.d(TAG, "_testEncryptPayload");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(0);
		metaData.setEncryptionCode(1);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, PAYLOAD_PATH, TransportDirectives.RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] encryptedResult = PhoenixTestUtil.readFile(PAYLOAD_PATH);
		
		//3 decrypt
		byte[] result = null;
		try {
			result = PhoenixTestUtil.decrypt(response.getAesKey(), encryptedResult);
		} catch (InvalidKeyException e) {
			fail(e.getMessage());
		}
		
		//4 compare
		assertEquals(1, metaData.getEncryptionCode());
		assertEquals(PayloadType.FILE, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}

	/**
	 * To test this case you have to add Dummy Exception inside SendEventsPayloadBuilder
	 * at onAESEncryptSuccess() step.
	 */
	private void _testHandleEncryptPayloadError(){
		Log.d(TAG, "_testHandleEncryptPayloadError");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(0);
		metaData.setEncryptionCode(1);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, PAYLOAD_PATH, TransportDirectives.RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = PhoenixTestUtil.readFile(PAYLOAD_PATH);

		//4 compare
		assertEquals(0, metaData.getEncryptionCode());
		assertEquals(PayloadType.FILE, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testCompressAndEncryptPayload(){
		Log.d(TAG, "_testCompressAndEncryptPayload");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(1);
		metaData.setEncryptionCode(1);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, PAYLOAD_PATH, TransportDirectives.RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] encryptedResult = PhoenixTestUtil.readFile(PAYLOAD_PATH);
		
		//3 decrypt
		byte[] compressed = null;
		try {
			compressed = PhoenixTestUtil.decrypt(response.getAesKey(), encryptedResult);
		} catch (InvalidKeyException e) {
			fail(e.getMessage());
		}
		
		//4 decompress
		byte[] result = PhoenixTestUtil.decompress(new ByteArrayInputStream(compressed));
		
		//5 compare
		assertEquals(1, metaData.getEncryptionCode());
		assertEquals(1, metaData.getCompressionCode());
		assertEquals(PayloadType.FILE, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	/**
	 * To test this case you have to add Dummy Exception inside SendEventsPayloadBuilder
	 * at onCompressSuccess and onAESEncryptSuccess step.
	 */
	private void _testHandleCompressAndEncryptPayloadError(){
		Log.d(TAG, "_testHandleCompressAndEncryptPayloadError");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//command code : 2 bytes
		stream.write(ByteUtil.toBytes((short) CommandCode.SEND_EVENT), 0, 2);
		//event count : 2 bytes
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);
		//first event (Panic Image)
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write((byte) COORDINATE_ACCURACY);								// COORDINATE ACCURACY (1 byte)
		// network Name and its length (1 byte)
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		// NETWORK_ID and its length (1 byte)
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		// CELL_NAME and its length (1 byte)
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		// CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);			
		// COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(COUNTRY_CODE), 0, 4);		
		// AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);
		// MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.JPEG);
		// IMAGE DATA and 4 bytes length
		byte[] imageData = PhoenixTestUtil.readFile(MEDIA_PATH);
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 building payload
		CommandMetaData metaData = new CommandMetaData();
		metaData.setCompressionCode(1);
		metaData.setEncryptionCode(1);
		EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(eventTime);
    	event.setLattitude(LATTITUDE);
    	event.setLongitude(LONGITUDE);
    	event.setAltitude(ALTITUDE);
    	event.setCoordinateAccuracy(COORDINATE_ACCURACY);
    	event.setNetworkName(NETWORK_NAME);
    	event.setNetworkId(NETWORK_ID);
    	event.setCellName(CELL_NAME);
    	event.setCellId(CELL_ID);
    	event.setCountryCode(COUNTRY_CODE);
    	event.setAreaCode(AREA_CODE);
    	event.setMediaType(MediaType.JPEG);
    	event.setImagePath(MEDIA_PATH);
    	provider.addEvent(event);
    	SendEvents commandData = new SendEvents();
    	commandData.setEventProvider(provider);
		SendEventsPayloadBuilder builder = new SendEventsPayloadBuilder();
		PayloadBuilderResponse response = null;
		try {
			response = builder.buildPayload(metaData, commandData, PAYLOAD_PATH, TransportDirectives.RESUMABLE);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = PhoenixTestUtil.readFile(PAYLOAD_PATH);
		
		
		//3 compare
		assertEquals(0, metaData.getEncryptionCode());
		assertEquals(0, metaData.getCompressionCode());
		assertEquals(PayloadType.FILE, response.getPayloadType());
		assertEquals(true, Arrays.equals(expected, result));
	}
}
