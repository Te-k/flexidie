package com.vvt.phoenix.prot.parser.test;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;

import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.phoenix.prot.event.Attachment;
import com.vvt.phoenix.prot.event.AudioConversationEvent;
import com.vvt.phoenix.prot.event.AudioConversationThumbnailEvent;
import com.vvt.phoenix.prot.event.AudioFileEvent;
import com.vvt.phoenix.prot.event.AudioFileThumnailEvent;
import com.vvt.phoenix.prot.event.CallLogEvent;
import com.vvt.phoenix.prot.event.CameraImageEvent;
import com.vvt.phoenix.prot.event.CameraImageThumbnailEvent;
import com.vvt.phoenix.prot.event.DebugMode;
import com.vvt.phoenix.prot.event.EmailEvent;
import com.vvt.phoenix.prot.event.EmbededCallInfo;
import com.vvt.phoenix.prot.event.EventDirection;
import com.vvt.phoenix.prot.event.EventType;
import com.vvt.phoenix.prot.event.GeoTag;
import com.vvt.phoenix.prot.event.GpsBatteryLifeDebugEvent;
import com.vvt.phoenix.prot.event.HttpBatteryLifeDebugEvent;
import com.vvt.phoenix.prot.event.IMEvent;
import com.vvt.phoenix.prot.event.LocationEvent;
import com.vvt.phoenix.prot.event.MMSEvent;
import com.vvt.phoenix.prot.event.MediaType;
import com.vvt.phoenix.prot.event.PanicImage;
import com.vvt.phoenix.prot.event.PanicStatus;
import com.vvt.phoenix.prot.event.Participant;
import com.vvt.phoenix.prot.event.Recipient;
import com.vvt.phoenix.prot.event.RecipientType;
import com.vvt.phoenix.prot.event.SMSEvent;
import com.vvt.phoenix.prot.event.SettingEvent;
import com.vvt.phoenix.prot.event.SettingEvent.SettingData;
import com.vvt.phoenix.prot.event.SystemEvent;
import com.vvt.phoenix.prot.event.SystemEventCategories;
import com.vvt.phoenix.prot.event.Thumbnail;
import com.vvt.phoenix.prot.event.VideoFileEvent;
import com.vvt.phoenix.prot.event.VideoFileThumbnailEvent;
import com.vvt.phoenix.prot.event.WallPaperThumbnailEvent;
import com.vvt.phoenix.prot.event.WallpaperEvent;
import com.vvt.phoenix.prot.parser.EventParser;
import com.vvt.phoenix.prot.test.PhoenixTestUtil;
import com.vvt.phoenix.util.ByteUtil;


public class EventParserTest extends AndroidTestCase{
	
	private static final String TAG = "EventParserTest";
	private static final String PAYLOAD_PATH = "/sdcard/event_parser_result.out";
	private static final String MEDIA_PATH = "/sdcard/image.jpg";
	
	/*
	 * Test Data
	 */
	private static final String PHONE_NUMBER = "086-1234567890";
	private static final String CONTACT_NAME = "Johnny Dew";
	private static final String RECIPIENT = "089-0987654321";
	private static final String RECIPIENT_CONTACT_NAME = "Johnny Bravo";
	private static final String SMS_DATA = "Hi! My name is Johnny Dew. I'm doing Phoenix 2nd generation";
	private static final String SENDER_EMAIL = "johnnydew@dew.com";
	private static final String EMAIL_SUBJECT = "Hello VVT";
	private static final String EMAIL_BODY = "Who are you really?";
	private static final String ATTACHMENT_FULL_NMAE = "Attachment name";
	private static final String ATTACHMENT_DATA = "Attachment data";
	private static final String IM_SERVICE = "whatsapp";
	
	private static final double LATTITUDE = 100.12345;
	private static final double LONGITUDE = 45.12345;
	private static final float ALTITUDE = 50.9876f;
	private static final int COORDINATE_ACCURACY = 1;
	private static final float SPEED = 100.000f;
	private static final float HEADING = -2.9876f;
	private static final float HOR_ACCURACY = 12.00f;
	private static final float VER_ACCURACY = 20.1234f;
	private static final String NETWORK_NAME = "AIS VVT";
	private static final String NETWORK_ID = "1q2w3e4r5t";
	private static final String CELL_NAME = "VVT CELL";
	private static final String MOBILE_COUNTRY_CODE = "+66";
	private static final int COUNTRY_CODE = 66;
	private static final int CELL_ID = 12345;
	private static final int AREA_CODE = 999;	
	
	private static final String BATTERY_BEFORE = "50";
	private static final String BATTERY_AFTER = "44";
	private static final String START_TIME = PhoenixTestUtil.getCurrentEventTimeStamp();
	private static final String END_TIME = PhoenixTestUtil.getCurrentEventTimeStamp();
	private static final String PAYLOAD_SIZE = "128";
	
	private static final long PARING_ID = 6996;
	private static final long ACTUAL_FILE_SIZE = 1999999;
	private static final int CALL_DURATION = 15;
	private static final long ACTUAL_CALL_DURATION = 68;
	private static final String FILE_NAME = "FileName";
	
	/*
	 * Total 51 test cases
	 */
			
	//common event test
	private static final boolean TEST_ILLEGAL_ARGUMENT = false;
	private static final boolean TEST_PARSING_EMPTY_EVENT_TIME = false;
	//call log event test
	private static final boolean TEST_PARSING_CALL_LOG = false;
	private static final boolean TEST_PARSING_EMPTY_CALL_LOG_FIELDS = false;
	//sms event test
	private static final boolean TEST_PARSING_SMS = false;
	private static final boolean TEST_PARSING_EMPTY_SMS_FIELDS = false;
	private static final boolean TEST_PARSING_EMPTY_SMS_RECIPIENT_FIELDS = false;
	//email event test
	private static final boolean TEST_PARSING_EMAIL = false;
	private static final boolean TEST_PARSING_EMPTY_EMAIL_FIELDS = false;
	private static final boolean TEST_PARSING_EMPTY_EMAIL_RECIPIENT_ATTACHMENT_FIELDS = false;
	//mms event test
	private static final boolean TEST_PARSING_MMS = false;
	private static final boolean TEST_PARSING_EMPTY_MMS_FIELDS = false;
	private static final boolean TEST_PARSING_EMPTY_MMS_RECIPIENT_ATTACHMENT_FIELDS = false;
	//im event test
	private static final boolean TEST_PARSING_IM = false;
	private static final boolean TEST_PARSING_EMPTY_IM_FIELDS = false;
	private static final boolean TEST_PARSING_EMPTY_IM_RECIPIENT_ATTACHMENT_FIELDS = false;
	//system event test
	private static final boolean TEST_PARSING_SYSTEM = false;
	private static final boolean TEST_PARSING_EMPTY_SYSTEM_FIELDS = false;
	private static final boolean TEST_PARSING_DEBUG_BATTERY_LEVEL_ON_HTTP = false;
	private static final boolean TEST_PARSING_DEBUG_BATTERY_LEVEL_ON_HTTP_EMPTY_FIELDS = false;
	private static final boolean TEST_PARSING_DEBUG_BATTERY_LEVEL_ON_GPS = false;
	private static final boolean TEST_PARSING_DEBUG_BATTERY_LEVEL_ON_GPS_EMPTY_FIELDS = false;
	//location event test
	private static final boolean TEST_PARSING_LOCATION = false;
	private static final boolean TEST_PARSING_EMPTY_LOCATION_FIELDS = false;
	//setting event test
	private static final boolean TEST_PARSING_SETTING = false;
	private static final boolean TEST_PARSING_EMPTY_SETTING = false;
	private static final boolean TEST_PARSING_EMPTY_SETTING_VALUE = false;
	//panic event test
	private static final boolean TEST_PARSING_PANIC_STATUS = false;
	private static final boolean TEST_PARSING_PANIC_IMAGE = false;
	private static final boolean TEST_PARSING_EMPTY_PANIC_IMAGE_FIELDS = false;
	//wallpaper thumbnail test
	private static final boolean TEST_PARSING_WALLPAPER_THUMBNAIL = false;
	private static final boolean TEST_PARSING_WALLPAPER_THUMBNAIL_EMPTY_IMAGE = false;
	//camera image thumbnail test
	private static final boolean TEST_PARSING_CAMERA_IMAGE_THUMBNAIL = false;
	private static final boolean TEST_PARSING_CAMERA_IMAGE_THUMBNAIL_EMPTY_IMAGE_AND_FIELDS = false;
	//audio conversation thumbnail test
	private static final boolean TEST_PARSING_AUDIO_CONVERSATION_THUMBNAIL = false;
	private static final boolean TEST_PARSING_AUDIO_CONVERSATION_THUMBNAIL_EMPTY_FIELDS = false;
	//audio file thumbnail test
	private static final boolean TEST_PARSING_AUDIO_FILE_THUMBNAIL = false;
	private static final boolean TEST_PARSING_AUDIO_FILE_THUMBNAIL_EMPTY_FIELDS = false;
	//video file thumbnail test
	private static final boolean TEST_PARSING_VIDEO_FILE_THUMBNAIL = false;
	private static final boolean TEST_PARSING_VIDEO_FILE_THUMBNAIL_EMPTY_FIELDS = false;
	private static final boolean TEST_PARSING_VIDEO_FILE_THUMBNAIL_EMPTY_THUMBNAIL_DATA = false;
	//wallpaper media test
	private static final boolean TEST_PARSING_WALLPAPERL = false;
	private static final boolean TEST_PARSING_WALLPAPER_EMPTY_IMAGE = false;
	//camera media test
	private static final boolean TEST_PARSING_CAMERA = false;
	private static final boolean TEST_PARSING_CAMERA_EMPTY_IMAGE_AND_FIELDS = false;
	//audio conversation media test
	private static final boolean TEST_PARSING_AUDIO_CONVERSATION = false;
	private static final boolean TEST_PARSING_AUDIO_CONVERSATION_EMPTY_FIELDS = false;
	//audio media test
	private static final boolean TEST_PARSING_AUDIO_FILE = false;
	private static final boolean TEST_PARSING_AUDIO_FILE_EMPTY_FIELDS = false;
	//video media test
	private static final boolean TEST_PARSING_VIDEO_FILE = false;
	private static final boolean TEST_PARSING_VIDEO_FILE_EMPTY_FIELDS = false;
	
	public void testCases(){
		
		// Common fields
		if(TEST_ILLEGAL_ARGUMENT){
			_testParsingIllegalArgument();
		}
		if(TEST_PARSING_EMPTY_EVENT_TIME){
			_testParsingEmptyEventTime();
		}
		
		// Call log
		if(TEST_PARSING_CALL_LOG){
			_testParsingCallLog();
		}
		if(TEST_PARSING_EMPTY_CALL_LOG_FIELDS){
			_testParsingEmptyCallLogFields();
		}
		
		// SMS
		if(TEST_PARSING_SMS){
			_testParsingSms();
		}
		if(TEST_PARSING_EMPTY_SMS_FIELDS){
			_testParsingEmptySmsFields();
		}
		if(TEST_PARSING_EMPTY_SMS_RECIPIENT_FIELDS){
			_testParsingEmptySmsRecipientFields();
		}
		
		// EMail
		if(TEST_PARSING_EMAIL){
			_testParsingEmail();
		}
		if(TEST_PARSING_EMPTY_EMAIL_FIELDS){
			_testParsingEmptyEmailFields();
		}
		if(TEST_PARSING_EMPTY_EMAIL_RECIPIENT_ATTACHMENT_FIELDS){
			_testParsingEmptyEmailRecipientAttachmentFields();
		}
		
		// MMS
		if(TEST_PARSING_MMS){
			_testParsingMms();
		}
		if(TEST_PARSING_EMPTY_MMS_FIELDS){
			_testParsingEmptyMmsFields();
		}
		if(TEST_PARSING_EMPTY_MMS_RECIPIENT_ATTACHMENT_FIELDS){
			_testParsingEmptyMmsRecipientAttachmentFields();
		}
		
		// IM
		if(TEST_PARSING_IM){
			_testParsingIM();
		}
		if(TEST_PARSING_EMPTY_IM_FIELDS){
			_testParsingEmptyIMFields();
		}
		if(TEST_PARSING_EMPTY_IM_RECIPIENT_ATTACHMENT_FIELDS){
			_testParsingEmptyIMRecipientAttachmentFields();
		}
		
		// System
		if(TEST_PARSING_SYSTEM){
			_testParsingSystem();
		}
		if(TEST_PARSING_EMPTY_SYSTEM_FIELDS){
			_testParsingEmptySystemFields();
		}
		if(TEST_PARSING_DEBUG_BATTERY_LEVEL_ON_HTTP){
			_testParsingDebugBatteryLevelOnHttp();
		}
		if(TEST_PARSING_DEBUG_BATTERY_LEVEL_ON_HTTP_EMPTY_FIELDS){
			_testParsingDebugBatteryLevelOnHttpEmptyFields();
		}
		if(TEST_PARSING_DEBUG_BATTERY_LEVEL_ON_GPS){
			_testParsingDebugBatteryLevelOnGps();
		}
		if(TEST_PARSING_DEBUG_BATTERY_LEVEL_ON_GPS_EMPTY_FIELDS){
			_testParsingDebugBatteryLevelOnGpsEmptyFields();
		}
		
		// Location
		if(TEST_PARSING_LOCATION){
			_testParsingLocation();
		}
		if(TEST_PARSING_EMPTY_LOCATION_FIELDS){
			_testParsingEmptyLocationFields();
		}
		
		// Setting Event
		if(TEST_PARSING_SETTING){
			_testParsingSetting();
		}
		if(TEST_PARSING_EMPTY_SETTING){
			_testParsingEmptySetting();
		}
		if(TEST_PARSING_EMPTY_SETTING_VALUE){
			_testParsingEmptySettingValue();
		}
		
		// Panic Event
		if(TEST_PARSING_PANIC_STATUS){
			_testParsingPanicStatus();
		}
		// Panic Image
		if(TEST_PARSING_PANIC_IMAGE){
			_testParsingPanicImage();
		}
		if(TEST_PARSING_EMPTY_PANIC_IMAGE_FIELDS){
			_testParsingEmptyPanicImageFields();
		}
		
		//Thumbnail events
		//Wallpaper
		if(TEST_PARSING_WALLPAPER_THUMBNAIL){
			_testParsingWallpaperThumbnail();
		}
		if(TEST_PARSING_WALLPAPER_THUMBNAIL_EMPTY_IMAGE){
			_testParsingWallpaperThumbnailEmptyImage();
		}
		//Camera Image
		if(TEST_PARSING_CAMERA_IMAGE_THUMBNAIL){
			_testParsingCameraImageThumbnail();
		}
		if(TEST_PARSING_CAMERA_IMAGE_THUMBNAIL_EMPTY_IMAGE_AND_FIELDS){
			_testParsingCameraImageThumbnailEmptyImageAndFields();
		}
		//Audio conversation
		if(TEST_PARSING_AUDIO_CONVERSATION_THUMBNAIL){
			_testParsingAudioConversationThumbnail();
		}
		if(TEST_PARSING_AUDIO_CONVERSATION_THUMBNAIL_EMPTY_FIELDS){
			_testParsingAudioConversationThumbnailEmptyFields();
		}
		//Audio file
		if(TEST_PARSING_AUDIO_FILE_THUMBNAIL){
			_testParsingAudioFileThumbnail();
		}
		if(TEST_PARSING_AUDIO_FILE_THUMBNAIL_EMPTY_FIELDS){
			_testParsingAudioFileThumbnailEmptyFields();
		}
		//Video file
		if(TEST_PARSING_VIDEO_FILE_THUMBNAIL){
			_testParsingVideoFileThumbnail();
		}
		if(TEST_PARSING_VIDEO_FILE_THUMBNAIL_EMPTY_FIELDS){
			_testParsingVideoFileThumbnailEmptyFields();
		}
		if(TEST_PARSING_VIDEO_FILE_THUMBNAIL_EMPTY_THUMBNAIL_DATA){
			_testParsingVideoFileThumbnailEmptyThumbnailData();
		}
		
		//Actual Media
		//Wallpaper
		if(TEST_PARSING_WALLPAPERL){
			_testParsingWallpaper();
		}
		if(TEST_PARSING_WALLPAPER_EMPTY_IMAGE){
			_testParsingWallpaperEmptyImage();
		}
		//Camera
		if(TEST_PARSING_CAMERA){
			_testParsingCamera();
		}
		if(TEST_PARSING_CAMERA_EMPTY_IMAGE_AND_FIELDS){
			_testParsingCameraEmptyImageAndFields();
		}
		//Audio conversation
		if(TEST_PARSING_AUDIO_CONVERSATION){
			_testParsingAudioConversation();
		}
		if(TEST_PARSING_AUDIO_CONVERSATION_EMPTY_FIELDS){
			_testParsingAudioConversationEmptyFields();
		}
		//Audio file
		if(TEST_PARSING_AUDIO_FILE){
			_testParsingAudioFile();
		}
		if(TEST_PARSING_AUDIO_FILE_EMPTY_FIELDS){
			_testParsingAudioFileEmptyFields();
		}
		//Video file
		if(TEST_PARSING_VIDEO_FILE){
			_testParsingVideoFile();
		}
		if(TEST_PARSING_VIDEO_FILE_EMPTY_FIELDS){
			_testParsingVideoFileEmptyFields();
		}
	}
	
	
	// ****************************************** File utils ************************************ //
	
	private FileOutputStream createOutputFileStream(){
		File f = new File(PAYLOAD_PATH);
		f.delete();
		FileOutputStream fOut = null;
		try {
			fOut = new FileOutputStream(f);
		} catch (FileNotFoundException e) {
			Log.e(TAG, String.format("> createOutputFileStream # %s", e.getMessage()));
		}
		return fOut;
	}
	
	private byte[] readResultFile(){
		byte[] result = null;
		try{
			File f = new File(PAYLOAD_PATH);
			FileInputStream fIn = new FileInputStream(f);
			result = new byte[(int) f.length()];
			fIn.read(result);
			fIn.close();
		}catch(IOException e){
			Log.e(TAG, String.format("> readResultFile # %s", e.getMessage()));
		}
		return result;
	}
	
	private byte[] readMediaFile(){
		File f = new File(MEDIA_PATH);
		byte[] buffer = null;
		try{
			FileInputStream fIn = new FileInputStream(f);
			buffer = new byte[(int) f.length()];
			fIn.read(buffer);
			fIn.close();
		}catch(IOException e){
			Log.e(TAG, String.format("> readMediaFile() # %s", e.getMessage()));
		}
		return buffer;
	}
	
	// ****************************************** Common tests ************************************ //
	private void _testParsingIllegalArgument(){
		Log.d(TAG, "_testParsingIllegalArgument");
		
		try {
			EventParser.parseEvent(null, null);
			fail("Should have thrown IllegalArgumentException");
		} catch (Exception e) {
			Log.e(TAG, String.format("> _testParsingIllegalArgument # %s", e.getMessage()));
		}
		CallLogEvent event = new CallLogEvent();
		try {
			EventParser.parseEvent(event, null);
			fail("Should have thrown IllegalArgumentException");
		} catch (Exception e) {
			Log.e(TAG, String.format("> _testParsingIllegalArgument # %s", e.getMessage()));
		}
	}
	
	
	private void _testParsingEmptyEventTime(){
		Log.d(TAG, "_testParsingEmptyEventTime");
		
		CallLogEvent event = new CallLogEvent();
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		try {
			EventParser.parseEvent(event, stream);
			fail("Should have thrown Exception");
		} catch (Exception e) {
			Log.e(TAG, String.format("> _testParsingEmptyEventTime # %s", e.getMessage()));
		}
	}
	
	// ****************************************** Parsing Call Log test cases ************************************ //

	private void _testParsingCallLog(){
		Log.d(TAG, "_testParsingCallLog");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.CALL_LOG), 0, 2);					// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);											// event direction (1 byte)
		stream.write(new byte[]{0x00, 0x00, 0x16, 0x44}, 0, 4);								// duration : 5700 seconds (4 bytes)
		byte[] number = ByteUtil.toBytes(PHONE_NUMBER);										// phone number and its length (1 byte)
		stream.write((byte) number.length);
		stream.write(number, 0, number.length);
		byte[] contact = ByteUtil.toBytes(CONTACT_NAME);									// contact name and its length (1 byte)
		stream.write((byte) contact.length);
		stream.write(contact, 0, contact.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		CallLogEvent event = new CallLogEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		event.setDuration(5700);
		event.setNumber(PHONE_NUMBER);
		event.setContactName(CONTACT_NAME);
		FileOutputStream fOut = createOutputFileStream();
		try {
			EventParser.parseEvent(event, fOut);
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptyCallLogFields(){
		Log.d(TAG, "_testParsingEmptyCallLogFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.CALL_LOG), 0, 2);					// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);	// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);											// event direction (1 byte)
		stream.write(new byte[]{0x00, 0x00, 0x16, 0x44}, 0, 4);								// duration : 5700 seconds (4 bytes)															
		stream.write((byte) 0);																// empty phone number (1 byte)
		stream.write((byte) 0);																// empty contact name (1 byte)
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		CallLogEvent event = new CallLogEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		event.setDuration(5700);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	// ****************************************** Parsing SMS test cases ************************************ //
	
	private void _testParsingSms(){
		Log.d(TAG, "_testParsingSms");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.SMS), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);								// event direction (1 byte)
		byte[] senderNumber = ByteUtil.toBytes(PHONE_NUMBER);				// sender number and its length (1 byte)
		stream.write((byte) senderNumber.length);
		stream.write(senderNumber, 0, senderNumber.length);
		byte[] contactName = ByteUtil.toBytes(CONTACT_NAME);				// contact name and its length (1 byte)
		stream.write((byte) contactName.length);
		stream.write(contactName, 0, contactName.length);
		stream.write(ByteUtil.toBytes((short) 2), 0, 2);					// recipient count = 2 : 2 bytes
		// first recipient
		stream.write((byte) RecipientType.TO);								// recipient type						
		byte[] recipient = ByteUtil.toBytes(RECIPIENT);						// recipient and its length (1 byte)
		stream.write((byte) recipient.length);
		stream.write(recipient, 0, recipient.length);
		byte[] recContactName = ByteUtil.toBytes(RECIPIENT_CONTACT_NAME);	// recipient contact name and its length (1 byte)
		stream.write((byte) recContactName.length);
		stream.write(recContactName, 0, recContactName.length);
		// second recipient
		stream.write((byte) RecipientType.CC);								// recipient type						
		recipient = ByteUtil.toBytes(RECIPIENT);							// recipient and its length (1 byte)
		stream.write((byte) recipient.length);
		stream.write(recipient, 0, recipient.length);
		recContactName = ByteUtil.toBytes(RECIPIENT_CONTACT_NAME);			// recipient contact name and its length (1 byte)
		stream.write((byte) recContactName.length);
		stream.write(recContactName, 0, recContactName.length);
		//SMS Data
		byte[] smsData = ByteUtil.toBytes(SMS_DATA);						// SMS data and its length (2 bytes)
		stream.write(ByteUtil.toBytes((short) smsData.length), 0, 2);
		stream.write(smsData, 0, smsData.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		SMSEvent event = new SMSEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		event.setSenderNumber(PHONE_NUMBER);
		event.setContactName(CONTACT_NAME);
		Recipient rec1 = new Recipient();
		rec1.setRecipientType(RecipientType.TO);
		rec1.setRecipient(RECIPIENT);
		rec1.setContactName(RECIPIENT_CONTACT_NAME);
		event.addRecipient(rec1);
		Recipient rec2 = new Recipient();
		rec2.setRecipientType(RecipientType.CC);
		rec2.setRecipient(RECIPIENT);
		rec2.setContactName(RECIPIENT_CONTACT_NAME);
		event.addRecipient(rec2);
		event.setSMSData(SMS_DATA);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptySmsFields(){
		Log.d(TAG, "_testParsingEmptySmsFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.SMS), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);								// event direction (1 byte)			
		stream.write((byte) 0);												// empty sender number (1 byte)			
		stream.write((byte) 0);												// empty contact name (1 byte)
		stream.write(new byte[]{0x00, 0x00}, 0, 2);							// recipient count = 0 : 2 bytes				
		stream.write(new byte[]{0x00, 0x00}, 0, 2);							// empty SMS data (2 bytes)
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		SMSEvent event = new SMSEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptySmsRecipientFields(){
		Log.d(TAG, "_testParsingEmptySmsRecipientFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.SMS), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);								// event direction (1 byte)			
		stream.write((byte) 0);												// empty sender number (1 byte)			
		stream.write((byte) 0);												// empty contact name (1 byte)
		stream.write(new byte[]{0x00, 0x01}, 0, 2);							// recipient count = 1 : 2 bytes			
		// first recipient
		stream.write((byte) RecipientType.TO);								// recipient type										
		stream.write((byte) 0);												// empty recipient (1 byte)	
		stream.write((byte) 0);												// empty recipient contact (1 byte)
		stream.write(new byte[]{0x00, 0x00}, 0, 2);							// empty SMS data (2 bytes)
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		SMSEvent event = new SMSEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		Recipient rec1 = new Recipient();
		rec1.setRecipientType(RecipientType.TO);
		event.addRecipient(rec1);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}

	// ****************************************** Parsing EMail test cases ************************************ //
	
	private void _testParsingEmail(){
		Log.d(TAG, "_testParsingEmail");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.MAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);								// event direction (1 byte)
		byte[] senderMail = ByteUtil.toBytes(SENDER_EMAIL);					// sender email and 1 byte length
		stream.write((byte) senderMail.length);
		stream.write(senderMail, 0, senderMail.length);
		byte[] senderContactName = ByteUtil.toBytes(CONTACT_NAME);			// sender contact name and 1 byte length
		stream.write((byte) senderContactName.length);
		stream.write(senderContactName, 0, senderContactName.length);
		stream.write(ByteUtil.toBytes((short) 2), 0, 2);					// recipient count = 2 : 2 bytes
		// first recipient
		stream.write((byte) RecipientType.TO);								// recipient type						
		byte[] recipient = ByteUtil.toBytes(RECIPIENT);						// recipient and its length (1 byte)
		stream.write((byte) recipient.length);
		stream.write(recipient, 0, recipient.length);
		byte[] recContactName = ByteUtil.toBytes(RECIPIENT_CONTACT_NAME);	// recipient contact name and its length (1 byte)
		stream.write((byte) recContactName.length);
		stream.write(recContactName, 0, recContactName.length);
		// second recipient
		stream.write((byte) RecipientType.CC);								// recipient type						
		recipient = ByteUtil.toBytes(RECIPIENT);							// recipient and its length (1 byte)
		stream.write((byte) recipient.length);
		stream.write(recipient, 0, recipient.length);
		recContactName = ByteUtil.toBytes(RECIPIENT_CONTACT_NAME);			// recipient contact name and its length (1 byte)
		stream.write((byte) recContactName.length);
		stream.write(recContactName, 0, recContactName.length);
		//subject
		byte[] subject = ByteUtil.toBytes(EMAIL_SUBJECT);					// email subject and its length (2 bytes)
		stream.write(ByteUtil.toBytes((short) subject.length), 0, 2);
		stream.write(subject, 0, subject.length);
		//attachments
		stream.write((byte) 2);												// attachment count = 2 : 1 byte
		//first attachment
		byte[] attachmentName = ByteUtil.toBytes(ATTACHMENT_FULL_NMAE);		// attachment full name and its length (2 bytes)
		stream.write(ByteUtil.toBytes((short) attachmentName.length), 0, 2);
		stream.write(attachmentName, 0, attachmentName.length);
		byte[] attachmentData = ByteUtil.toBytes(ATTACHMENT_DATA);			// attachment data and its length (4 bytes)
		stream.write(ByteUtil.toBytes(attachmentData.length), 0, 4);
		stream.write(attachmentData, 0, attachmentData.length);
		//second attachment
		stream.write(ByteUtil.toBytes((short) attachmentName.length), 0, 2);
		stream.write(attachmentName, 0, attachmentName.length);
		stream.write(ByteUtil.toBytes(attachmentData.length), 0, 4);
		stream.write(attachmentData, 0, attachmentData.length);
		// email body
		byte[] emailBody = ByteUtil.toBytes(EMAIL_BODY);					// email body and its length (4 bytes)
		stream.write(ByteUtil.toBytes(emailBody.length), 0, 4);
		stream.write(emailBody, 0, emailBody.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		EmailEvent event = new EmailEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		event.setSenderEMail(SENDER_EMAIL);
		event.setSenderContactName(CONTACT_NAME);
		Recipient rec1 = new Recipient();
		rec1.setRecipientType(RecipientType.TO);
		rec1.setRecipient(RECIPIENT);
		rec1.setContactName(RECIPIENT_CONTACT_NAME);
		event.addRecipient(rec1);
		Recipient rec2 = new Recipient();
		rec2.setRecipientType(RecipientType.CC);
		rec2.setRecipient(RECIPIENT);
		rec2.setContactName(RECIPIENT_CONTACT_NAME);
		event.addRecipient(rec2);
		event.setSubject(EMAIL_SUBJECT);
		Attachment attachment = new Attachment();
		attachment.setAttachemntFullName(ATTACHMENT_FULL_NMAE);
		attachment.setAttachmentData(ByteUtil.toBytes(ATTACHMENT_DATA));
		event.addAttachment(attachment);
		event.addAttachment(attachment);
		event.setEMailBody(EMAIL_BODY);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptyEmailFields() {
		Log.d(TAG, "_testParsingEmptyEmailFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.MAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);							// event direction (1 byte)				
		stream.write((byte) 0);												// empty sender email 1 byte length	
		stream.write((byte) 0);												// empty sender contact name 1 byte length
		stream.write(ByteUtil.toBytes((short) 0), 0, 2);					// recipient count = 0 : 2 bytes
		//empty subject 2 bytes length
		stream.write(ByteUtil.toBytes((short) 0), 0, 2);
		//empty attachments
		stream.write((byte) 0);												// attachment count = 0 : 1 byte
		// empty email body				
		stream.write(new byte[]{0x00, 0x00, 0x00, 0x00}, 0, 4);				// empty email body length (4 bytes)
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		EmailEvent event = new EmailEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptyEmailRecipientAttachmentFields() {
		Log.d(TAG, "_testParsingEmptyEmailRecipientAttachmentFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.MAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);								// event direction (1 byte)
		byte[] senderMail = ByteUtil.toBytes(SENDER_EMAIL);					// sender email and 1 byte length
		stream.write((byte) senderMail.length);
		stream.write(senderMail, 0, senderMail.length);
		byte[] senderContactName = ByteUtil.toBytes(CONTACT_NAME);			// sender contact name and 1 byte length
		stream.write((byte) senderContactName.length);
		stream.write(senderContactName, 0, senderContactName.length);
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);					// recipient count = 1 : 2 bytes
		// first recipient
		stream.write((byte) RecipientType.TO);								// recipient type						
		stream.write((byte) 0);												// empty recipient email 1 byte length	
		stream.write((byte) 0);												// empty recipient contact 1 byte length
		//subject
		byte[] subject = ByteUtil.toBytes(EMAIL_SUBJECT);					// email subject and its length (2 bytes)
		stream.write(ByteUtil.toBytes((short) subject.length), 0, 2);
		stream.write(subject, 0, subject.length);
		//attachments
		stream.write((byte) 1);												// attachment count = 1 : 1 byte
		//first attachment
		stream.write(ByteUtil.toBytes((short) 0), 0, 2);					// empty attachment full name length (2 bytes)
		stream.write(ByteUtil.toBytes(0), 0, 4);							// empty attachment data length (4 bytes)
		// email body
		byte[] emailBody = ByteUtil.toBytes(EMAIL_BODY);					// email body and its length (4 bytes)
		stream.write(ByteUtil.toBytes(emailBody.length), 0, 4);
		stream.write(emailBody, 0, emailBody.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		EmailEvent event = new EmailEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		event.setSenderEMail(SENDER_EMAIL);
		event.setSenderContactName(CONTACT_NAME);
		Recipient rec1 = new Recipient();
		rec1.setRecipientType(RecipientType.TO);
		rec1.setRecipient(null);
		rec1.setContactName(null);
		event.addRecipient(rec1);
		event.setSubject(EMAIL_SUBJECT);
		Attachment attachment = new Attachment();
		attachment.setAttachemntFullName(null);
		attachment.setAttachmentData(null);
		event.addAttachment(attachment);
		event.setEMailBody(EMAIL_BODY);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	// ****************************************** Parsing MMS test cases ************************************ //
	
	private void _testParsingMms() {
		Log.d(TAG, "_testParsingMms");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.MMS), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);							// event direction (1 byte)
		byte[] senderNumber = ByteUtil.toBytes(PHONE_NUMBER);				
		stream.write((byte) senderNumber.length);							// sender number length (1 byte)
		stream.write(senderNumber, 0, senderNumber.length);					// sender number
		byte[] contactName = ByteUtil.toBytes(CONTACT_NAME);				
		stream.write((byte) contactName.length);							// contact name length (1 byte)
		stream.write(contactName, 0, contactName.length);					// contact name
		stream.write(ByteUtil.toBytes((short) 2), 0, 2);					// recipient count = 2 : 2 bytes
		// first recipient
		stream.write((byte) RecipientType.TO);								// recipient type						
		byte[] recipient = ByteUtil.toBytes(RECIPIENT);						// recipient and its length (1 byte)
		stream.write((byte) recipient.length);
		stream.write(recipient, 0, recipient.length);
		byte[] recContactName = ByteUtil.toBytes(RECIPIENT_CONTACT_NAME);	// recipient contact name and its length (1 byte)
		stream.write((byte) recContactName.length);
		stream.write(recContactName, 0, recContactName.length);
		// second recipient
		stream.write((byte) RecipientType.CC);								// recipient type						
		recipient = ByteUtil.toBytes(RECIPIENT);							// recipient and its length (1 byte)
		stream.write((byte) recipient.length);
		stream.write(recipient, 0, recipient.length);
		recContactName = ByteUtil.toBytes(RECIPIENT_CONTACT_NAME);			// recipient contact name and its length (1 byte)
		stream.write((byte) recContactName.length);
		stream.write(recContactName, 0, recContactName.length);
		//subject
		byte[] subject = ByteUtil.toBytes(EMAIL_SUBJECT);					// MMS subject and its length (2 bytes)
		stream.write(ByteUtil.toBytes((short) subject.length), 0, 2);
		stream.write(subject, 0, subject.length);
		//attachments
		stream.write((byte) 2);												// attachment count = 2 : 1 byte
		//first attachment
		byte[] attachmentName = ByteUtil.toBytes(ATTACHMENT_FULL_NMAE);		// attachment full name and its length (2 bytes)
		stream.write(ByteUtil.toBytes((short) attachmentName.length), 0, 2);
		stream.write(attachmentName, 0, attachmentName.length);
		byte[] attachmentData = ByteUtil.toBytes(ATTACHMENT_DATA);			// attachment data and its length (4 bytes)
		stream.write(ByteUtil.toBytes(attachmentData.length), 0, 4);
		stream.write(attachmentData, 0, attachmentData.length);
		//second attachment
		stream.write(ByteUtil.toBytes((short) attachmentName.length), 0, 2);
		stream.write(attachmentName, 0, attachmentName.length);
		stream.write(ByteUtil.toBytes(attachmentData.length), 0, 4);
		stream.write(attachmentData, 0, attachmentData.length);
		byte[] expected = stream.toByteArray();
		
		MMSEvent event = new MMSEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		event.setSenderNumber(PHONE_NUMBER);
		event.setContactName(CONTACT_NAME);
		Recipient rec1 = new Recipient();
		rec1.setRecipientType(RecipientType.TO);
		rec1.setRecipient(RECIPIENT);
		rec1.setContactName(RECIPIENT_CONTACT_NAME);
		event.addRecipient(rec1);
		Recipient rec2 = new Recipient();
		rec2.setRecipientType(RecipientType.CC);
		rec2.setRecipient(RECIPIENT);
		rec2.setContactName(RECIPIENT_CONTACT_NAME);
		event.addRecipient(rec2);
		event.setSubject(EMAIL_SUBJECT);
		Attachment attachment = new Attachment();
		attachment.setAttachemntFullName(ATTACHMENT_FULL_NMAE);
		attachment.setAttachmentData(ByteUtil.toBytes(ATTACHMENT_DATA));
		event.addAttachment(attachment);
		event.addAttachment(attachment);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptyMmsFields() {
		Log.d(TAG, "_testParsingEmptyMmsFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.MMS), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);							// event direction (1 byte)			
		stream.write((byte) 0);												// empty sender number (1 byte)			
		stream.write((byte) 0);												// empty contact name (1 byte)
		stream.write(new byte[]{0x00, 0x00}, 0, 2);							// recipient count = 0 : 2 bytes
		//empty subject 2 bytes length
		stream.write(ByteUtil.toBytes((short) 0), 0, 2);
		//empty attachments
		stream.write((byte) 0);												// attachment count = 0 : 1 byte
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		MMSEvent event = new MMSEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
		
	}
	
	private void _testParsingEmptyMmsRecipientAttachmentFields() {
		Log.d(TAG, "_testParsingEmptyMmsRecipientAttachmentFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.MMS), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);							// event direction (1 byte)
		byte[] senderNumber = ByteUtil.toBytes(PHONE_NUMBER);				
		stream.write((byte) senderNumber.length);							// sender number length (1 byte)
		stream.write(senderNumber, 0, senderNumber.length);					// sender number
		byte[] contactName = ByteUtil.toBytes(CONTACT_NAME);				
		stream.write((byte) contactName.length);							// contact name length (1 byte)
		stream.write(contactName, 0, contactName.length);					// contact name
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);					// recipient count = 1 : 2 bytes
		// first recipient
		stream.write((byte) RecipientType.TO);								// recipient type						
		stream.write((byte) 0);												// empty recipient email 1 byte length	
		stream.write((byte) 0);												// empty recipient contact 1 byte length
		//subject
		byte[] subject = ByteUtil.toBytes(EMAIL_SUBJECT);					// email subject and its length (2 bytes)
		stream.write(ByteUtil.toBytes((short) subject.length), 0, 2);
		stream.write(subject, 0, subject.length);
		//attachments
		stream.write((byte) 1);												// attachment count = 1 : 1 byte
		//first attachment
		stream.write(ByteUtil.toBytes((short) 0), 0, 2);					// empty attachment full name length (2 bytes)
		stream.write(ByteUtil.toBytes(0), 0, 4);							// empty attachment data length (4 bytes)
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		MMSEvent event = new MMSEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		event.setSenderNumber(PHONE_NUMBER);
		event.setContactName(CONTACT_NAME);
		Recipient rec1 = new Recipient();
		rec1.setRecipientType(RecipientType.TO);
		event.addRecipient(rec1);
		event.setSubject(EMAIL_SUBJECT);
		Attachment attachment = new Attachment();
		event.addAttachment(attachment);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	// ****************************************** Parsing IM test cases ************************************ //
	
	private void _testParsingIM() {
		Log.d(TAG, "_testParsingIM");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.IM), 0, 2);			// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);							// event direction (1 byte)
		//user id
		byte[] user_id = ByteUtil.toBytes(PHONE_NUMBER);				
		stream.write((byte) user_id.length);								// user id length (1 byte)
		stream.write(user_id, 0, user_id.length);							// user id 
		//paticipant
		stream.write(ByteUtil.toBytes((short) 2), 0, 2);					// paticipant count = 2 : 2 bytes
		// first paticipant
		byte[] recContactName = ByteUtil.toBytes(RECIPIENT_CONTACT_NAME);	// paticipant contact name and its length (1 byte)
		stream.write((byte) recContactName.length);
		stream.write(recContactName, 0, recContactName.length);
		byte[] recipient = ByteUtil.toBytes(RECIPIENT);						// UID and its length (1 byte)
		stream.write((byte) recipient.length);
		stream.write(recipient, 0, recipient.length);
		// second paticipant
		recContactName = ByteUtil.toBytes(RECIPIENT_CONTACT_NAME);			// paticipant contact name and its length (1 byte)
		stream.write((byte) recContactName.length);
		stream.write(recContactName, 0, recContactName.length);
		recipient = ByteUtil.toBytes(RECIPIENT);							// UID and its length (1 byte)
		stream.write((byte) recipient.length);
		stream.write(recipient, 0, recipient.length);
		//im service
		byte[] im_service = ByteUtil.toBytes(IM_SERVICE);
		stream.write((byte) im_service.length);								// im service length (1 byte)
		stream.write(im_service, 0, im_service.length);						// im service 
		//im data
		byte[] imData = ByteUtil.toBytes(SMS_DATA);							// SMS data and its length (2 bytes)
		stream.write(ByteUtil.toBytes((short) imData.length), 0, 2);
		stream.write(imData, 0, imData.length);
		//user display name
		byte[] contactName = ByteUtil.toBytes(CONTACT_NAME);				
		stream.write((byte) contactName.length);							// user display name length (1 byte)
		stream.write(contactName, 0, contactName.length);					// user display name
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		IMEvent event = new IMEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		event.setUserId(PHONE_NUMBER);
		Participant  participant = new Participant();
		participant.setName(RECIPIENT_CONTACT_NAME);
		participant.setUid(RECIPIENT);
		event.addParticipant(participant);
		event.addParticipant(participant);
		event.setImServiceId(IM_SERVICE);
		event.setMessage(SMS_DATA);
		event.setUserDisplayName(CONTACT_NAME);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptyIMFields() {
		Log.d(TAG, "_testParsingEmptyIMFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.IM), 0, 2);			// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);							// event direction (1 byte)	
		stream.write((byte) 0);												// empty user id (1 byte)
		stream.write(ByteUtil.toBytes((short) 0), 0, 2);					// empty participant count = 0 : 2 bytes
		stream.write((byte) 0);												// empty IM service length (1 byte)
		stream.write(new byte[]{0x00, 0x00}, 0, 2);							// empty IM data (2 bytes)
		stream.write((byte) 0);												// empty user display name length (1 byte)
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		IMEvent event = new IMEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptyIMRecipientAttachmentFields() {
		Log.d(TAG, "_testParsingEmptyIMRecipientAttachmentFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.IM), 0, 2);			// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);					// event time stamp (19 bytes)
		stream.write((byte) EventDirection.OUT);							// event direction (1 byte)
		//user id
		byte[] user_id = ByteUtil.toBytes(PHONE_NUMBER);				
		stream.write((byte) user_id.length);								// user id length (1 byte)
		stream.write(user_id, 0, user_id.length);							// user id 
		//participant
		stream.write(ByteUtil.toBytes((short) 1), 0, 2);					// recipient count = 1 : 2 bytes
		// first participant
		stream.write((byte) 0);												// empty participant name 1 byte length	
		stream.write((byte) 0);												// empty participant uid 1 byte length
		//im service
		byte[] im_service = ByteUtil.toBytes(IM_SERVICE);
		stream.write((byte) im_service.length);								// im service length (1 byte)
		stream.write(im_service, 0, im_service.length);						// im service 
		//im data
		byte[] imData = ByteUtil.toBytes(SMS_DATA);							// SMS data and its length (2 bytes)
		stream.write(ByteUtil.toBytes((short) imData.length), 0, 2);
		stream.write(imData, 0, imData.length);
		//user display name
		byte[] contactName = ByteUtil.toBytes(CONTACT_NAME);				
		stream.write((byte) contactName.length);							// user display name length (1 byte)
		stream.write(contactName, 0, contactName.length);					// user display name
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		IMEvent event = new IMEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		event.setUserId(PHONE_NUMBER);
		Participant  participant = new Participant();
		participant.setName(null);
		participant.setUid(null);
		event.addParticipant(participant);
		event.setImServiceId(IM_SERVICE);
		event.setMessage(SMS_DATA);
		event.setUserDisplayName(CONTACT_NAME);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
		
	}
	
	// ****************************************** Parsing System test cases ************************************ //
	
	private void _testParsingSystem() {
		Log.d(TAG, "_testParsingSystem");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.SYSTEM), 0, 2);			// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write((byte) SystemEventCategories.CATEGORY_GENERAL);			// event Category (1 byte)
		stream.write((byte) EventDirection.OUT);								// event direction (1 byte)	
		// system data
		byte[] systemData = ByteUtil.toBytes(EMAIL_BODY);						// email body and its length (4 bytes)
		stream.write(ByteUtil.toBytes(systemData.length), 0, 4);
		stream.write(systemData, 0, systemData.length);							// system data
		byte[] expected = stream.toByteArray();
	
		//2 parsing
		SystemEvent event = new SystemEvent();
		event.setCategory(SystemEventCategories.CATEGORY_GENERAL);
		event.setDirection(EventDirection.OUT);
		event.setEventTime(eventTime);
		event.setSystemMessage(EMAIL_BODY);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptySystemFields() {
		Log.d(TAG, "_testParsingEmptySystemFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.SYSTEM), 0, 2);			// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write((byte) SystemEventCategories.CATEGORY_GENERAL);			// event Category (1 byte)
		stream.write((byte) EventDirection.OUT);								// event direction (1 byte)	
		// empty email body				
		stream.write(new byte[]{0x00, 0x00, 0x00, 0x00}, 0, 4);				// empty email body length (4 bytes)
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		SystemEvent event = new SystemEvent();
		event.setEventTime(eventTime);
		event.setDirection(EventDirection.OUT);
		event.setCategory(SystemEventCategories.CATEGORY_GENERAL);
		event.setSystemMessage(null);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingDebugBatteryLevelOnHttp(){
		Log.d(TAG, "_testParsingDebugBatteryLevelOnHttp");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.DEBUG_EVENT), 0, 2);			// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);								// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes((short) DebugMode.HTTP_BATTERY_LIFE), 0, 2);		// debug mode (2 bytes)
		stream.write((byte) 5);															// field count (1 byte)
		// battery before and 2 bytes length
		byte[] battBefore = ByteUtil.toBytes(BATTERY_BEFORE);
		stream.write(ByteUtil.toBytes((short) battBefore.length), 0, 2);
		stream.write(battBefore, 0, battBefore.length);
		// battery after and 2 bytes length
		byte[] battAfter = ByteUtil.toBytes(BATTERY_AFTER);
		stream.write(ByteUtil.toBytes((short) battAfter.length), 0, 2);
		stream.write(battAfter, 0, battAfter.length);
		// start time 19 bytes and 2 bytes length
		byte[] startTime = ByteUtil.toBytes(START_TIME);
		stream.write(ByteUtil.toBytes((short) startTime.length), 0, 2);
		stream.write(startTime, 0, startTime.length);
		// end time 19 bytes and 2 bytes length
		byte[] endTime = ByteUtil.toBytes(END_TIME);
		stream.write(ByteUtil.toBytes((short) endTime.length), 0, 2);
		stream.write(endTime, 0, endTime.length);
		// payload size and 2 bytes length
		byte[] payloadSize = ByteUtil.toBytes(PAYLOAD_SIZE);
		stream.write(ByteUtil.toBytes((short) payloadSize.length), 0, 2);
		stream.write(payloadSize, 0, payloadSize.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		HttpBatteryLifeDebugEvent event = new HttpBatteryLifeDebugEvent();
		event.setEventTime(eventTime);
		event.setBatteryBefore(BATTERY_BEFORE);
		event.setBatteryAfter(BATTERY_AFTER);
		event.setStartTime(START_TIME);
		event.setEndTime(END_TIME);
		event.setPayloadSize(PAYLOAD_SIZE);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));

	}
	
	private void _testParsingDebugBatteryLevelOnHttpEmptyFields(){
		Log.d(TAG, "_testParsingDebugBatteryLevelOnHttpEmptyFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.DEBUG_EVENT), 0, 2);			// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);								// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes((short) DebugMode.HTTP_BATTERY_LIFE), 0, 2);		// debug mode (2 bytes)
		stream.write((byte) 5);															// field count (1 byte)
		// empty battery before : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		// empty battery after : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		// empty start time : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		// empty end time : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		// empty payload size : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		HttpBatteryLifeDebugEvent event = new HttpBatteryLifeDebugEvent();
		event.setEventTime(eventTime);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingDebugBatteryLevelOnGps(){
		Log.d(TAG, "_testParsingDebugBatteryLevelOnGps");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.DEBUG_EVENT), 0, 2);			// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);								// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes((short) DebugMode.GPS_BATTERY_LIFE), 0, 2);		// debug mode (2 bytes)
		stream.write((byte) 4);															// field count (1 byte)
		// battery before and 2 bytes length
		byte[] battBefore = ByteUtil.toBytes(BATTERY_BEFORE);
		stream.write(ByteUtil.toBytes((short) battBefore.length), 0, 2);
		stream.write(battBefore, 0, battBefore.length);
		// battery after and 2 bytes length
		byte[] battAfter = ByteUtil.toBytes(BATTERY_AFTER);
		stream.write(ByteUtil.toBytes((short) battAfter.length), 0, 2);
		stream.write(battAfter, 0, battAfter.length);
		// start time 19 bytes and 2 bytes length
		byte[] startTime = ByteUtil.toBytes(START_TIME);
		stream.write(ByteUtil.toBytes((short) startTime.length), 0, 2);
		stream.write(startTime, 0, startTime.length);
		// end time 19 bytes and 2 bytes length
		byte[] endTime = ByteUtil.toBytes(END_TIME);
		stream.write(ByteUtil.toBytes((short) endTime.length), 0, 2);
		stream.write(endTime, 0, endTime.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		GpsBatteryLifeDebugEvent event = new GpsBatteryLifeDebugEvent();
		event.setEventTime(eventTime);
		event.setBatteryBefore(BATTERY_BEFORE);
		event.setBatteryAfter(BATTERY_AFTER);
		event.setStartTime(START_TIME);
		event.setEndTime(END_TIME);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingDebugBatteryLevelOnGpsEmptyFields(){
		Log.d(TAG, "_testParsingDebugBatteryLevelOnGpsEmptyFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.DEBUG_EVENT), 0, 2);			// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);								// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes((short) DebugMode.GPS_BATTERY_LIFE), 0, 2);		// debug mode (2 bytes)
		stream.write((byte) 4);	
		// empty battery before : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		// empty battery after : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		// empty start time : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		// empty end time : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		GpsBatteryLifeDebugEvent event = new GpsBatteryLifeDebugEvent();
		event.setEventTime(eventTime);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	// ****************************************** Parsing Location test cases ************************************ //
	
	private void _testParsingLocation(){
		Log.d(TAG, "_testParsingLocation");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.LOCATION), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write((byte) LocationEvent.MODULE_CORE_TRIGGER);					// CALLING_MODULE (1 byte)	
		stream.write((byte) LocationEvent.METHOD_INTEGRATED_GPS);				// METHOD (1 byte)
		stream.write((byte) LocationEvent.PROVIDER_GOOGLE);						// METHOD (1 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write(ByteUtil.toBytes(SPEED), 0, 4);							// SPEED (4 byte)
		stream.write(ByteUtil.toBytes(HEADING), 0, 4);							// HEADING (4 byte)
		stream.write(ByteUtil.toBytes(HOR_ACCURACY), 0, 4);						// HORIZONTAL ACCURACY (4 byte)
		stream.write(ByteUtil.toBytes(VER_ACCURACY), 0, 4);						// VERTICAL ACCURACY (4 byte)
		
		byte[] nwName = ByteUtil.toBytes(NETWORK_NAME);							// network Name and its length (1 byte)
		stream.write((byte) nwName.length);
		stream.write(nwName, 0, nwName.length);
		
		byte[] nwId = ByteUtil.toBytes(NETWORK_ID);								// NETWORK_ID and its length (1 byte)
		stream.write((byte) nwId.length);
		stream.write(nwId, 0, nwId.length);
		
		byte[] cellName = ByteUtil.toBytes(CELL_NAME);							// CELL_NAME and its length (1 byte)
		stream.write((byte) cellName.length);
		stream.write(cellName, 0, cellName.length);
		
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);							// CELL_ID (4 byte)
		
		byte[] mcc = ByteUtil.toBytes(MOBILE_COUNTRY_CODE);						// MCC and its length (1 byte)
		stream.write((byte) mcc.length);
		stream.write(mcc, 0, mcc.length);
		
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);						// AREA_CODE (4 byte)
		byte[] expected = stream.toByteArray();
		
		LocationEvent event = new LocationEvent();
		event.setEventTime(eventTime);
		event.setCallingModule(LocationEvent.MODULE_CORE_TRIGGER);
		event.setMethod(LocationEvent.METHOD_INTEGRATED_GPS);
		event.setProvider(LocationEvent.PROVIDER_GOOGLE);
		event.setLon(LONGITUDE);
		event.setLat(LATTITUDE);
		event.setAltitude(ALTITUDE);
		event.setSpeed(SPEED);
		event.setHeading(HEADING);
		event.setHorizontalAccuracy(HOR_ACCURACY);
		event.setVerticalAccuracy(VER_ACCURACY);
		event.setNetworkName(NETWORK_NAME);
		event.setNetworkId(NETWORK_ID);
		event.setCellName(CELL_NAME);
		event.setCellId(CELL_ID);
		event.setMobileCountryCode(MOBILE_COUNTRY_CODE);
		event.setAreaCode(AREA_CODE);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptyLocationFields() {
		Log.d(TAG, "_testParsingEmptyLocationFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.LOCATION), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write((byte) LocationEvent.MODULE_CORE_TRIGGER);					// CALLING_MODULE (1 byte)	
		stream.write((byte) LocationEvent.METHOD_INTEGRATED_GPS);				// METHOD (1 byte)
		stream.write((byte) LocationEvent.PROVIDER_GOOGLE);						// METHOD (1 byte)
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						// LONGITUDE (8 byte)
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);						// LATTITUDE (8 byte)
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);							// ALTITUDE (4 byte)
		stream.write(ByteUtil.toBytes(SPEED), 0, 4);							// SPEED (4 byte)
		stream.write(ByteUtil.toBytes(HEADING), 0, 4);							// ALTITUDE (4 byte)
		stream.write(ByteUtil.toBytes(HOR_ACCURACY), 0, 4);						// ALTITUDE (4 byte)
		stream.write(ByteUtil.toBytes(VER_ACCURACY), 0, 4);						// ALTITUDE (4 byte)
		
		stream.write((byte) 0);													// empty network Name  (1 byte)
		stream.write((byte) 0);													// empty network id  (1 byte)
		stream.write((byte) 0);													// empty cell Name  (1 byte)
		
		stream.write(ByteUtil.toBytes(CELL_ID), 0, 4);							// CELL_ID (4 byte)
		
		stream.write((byte) 0);													// empty  MCC  (1 byte)
		
		stream.write(ByteUtil.toBytes(AREA_CODE), 0, 4);						// AREA_CODE (4 byte)
		byte[] expected = stream.toByteArray();
		
		
		LocationEvent event = new LocationEvent();
		event.setEventTime(eventTime);
		event.setCallingModule(LocationEvent.MODULE_CORE_TRIGGER);
		event.setMethod(LocationEvent.METHOD_INTEGRATED_GPS);
		event.setProvider(LocationEvent.PROVIDER_GOOGLE);
		event.setLon(LONGITUDE);
		event.setLat(LATTITUDE);
		event.setAltitude(ALTITUDE);
		event.setSpeed(SPEED);
		event.setHeading(HEADING);
		event.setHorizontalAccuracy(HOR_ACCURACY);
		event.setVerticalAccuracy(VER_ACCURACY);
		event.setNetworkName(null);
		event.setNetworkId(null);
		event.setCellName(null);
		event.setCellId(CELL_ID);
		event.setMobileCountryCode(null);
		event.setAreaCode(AREA_CODE);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}

	// ****************************************** Parsing Setting test cases ************************************ //
	
	private void _testParsingSetting(){
		Log.d(TAG, "_testParsingSetting");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.SETTING), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		//setting count : 1 byte
		stream.write((byte) 2);
		//first setting : call log
		  //setting ID : 1 byte
		stream.write((byte) 2);
		  //setting value and 2 bytes length
		String callLogCaptureStatus = "1";
		byte[] callLogCaptureStatusBytes = ByteUtil.toBytes(callLogCaptureStatus);
		stream.write(ByteUtil.toBytes((short) callLogCaptureStatusBytes.length), 0, 2);
		stream.write(callLogCaptureStatusBytes, 0, callLogCaptureStatusBytes.length);
		//second setting : home number
		  //setting ID : 1 byte
		stream.write((byte) 50);
		  //setting value and 2 bytes length
		String homeNumber = "191";
		byte[] homeNumberBytes = ByteUtil.toBytes(homeNumber);
		stream.write(ByteUtil.toBytes((short) homeNumberBytes.length), 0, 2);
		stream.write(homeNumberBytes, 0, homeNumberBytes.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		SettingEvent event = new SettingEvent();
		event.setEventTime(eventTime);
		SettingData setting1 = new SettingEvent.SettingData();
		setting1.setSettingId(2);
		setting1.setSettingValue("1");
		event.addSettingData(setting1);
		SettingData setting2 = new SettingEvent.SettingData();
		setting2.setSettingId(50);
		setting2.setSettingValue("191");
		event.addSettingData(setting2);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptySetting(){
		Log.d(TAG, "_testParsingEmptySetting");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.SETTING), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		//setting count : 1 byte
		stream.write((byte) 0);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		SettingEvent event = new SettingEvent();
		event.setEventTime(eventTime);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingEmptySettingValue(){
		Log.d(TAG, "_testParsingEmptySettingValue");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.SETTING), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		//setting count : 1 byte
		stream.write((byte) 2);
		//first setting : call log
		  //setting ID : 1 byte
		stream.write((byte) 2);
		  //empty setting value : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		//second setting : home number
		  //setting ID : 1 byte
		stream.write((byte) 50);
		  //empty setting value : 2 bytes zero length
		stream.write(new byte[]{0x00, 0x00}, 0, 2);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		SettingEvent event = new SettingEvent();
		event.setEventTime(eventTime);
		SettingData setting1 = new SettingEvent.SettingData();
		setting1.setSettingId(2);
		event.addSettingData(setting1);
		SettingData setting2 = new SettingEvent.SettingData();
		setting2.setSettingId(50);
		event.addSettingData(setting2);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}

	// ****************************************** Parsing Panic test cases ************************************ //
	
	private void _testParsingPanicStatus(){
		Log.d(TAG, "_testParsingPanicStatus");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_STATUS), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		//panic status : 1 byte
		stream.write((byte) 1);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		PanicStatus event = new PanicStatus();
		event.setEventTime(eventTime);
		event.setStartPanic();
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testParsingPanicImage(){
		Log.d(TAG, "_testParsingPanicImage");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
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
		byte[] imageData = readMediaFile();
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
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
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));

	}
	
	private void _testParsingEmptyPanicImageFields(){
		Log.d(TAG, "_testParsingEmptyPanicImageFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.PANIC_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		stream.write(ByteUtil.toBytes((double) 500), 0, 8);						// Default LATTITUDE value : 500 (8 byte)
		stream.write(ByteUtil.toBytes((double) 0), 0, 8);							// Default LONGITUDE value : 0 (8 byte)
		stream.write(ByteUtil.toBytes(0), 0, 4);								// Default ALTITUDE value : 0 (4 byte)
		stream.write((byte) 0);													// Default COORDINATE ACCURACY (1 byte)
		// empty network Name and its zero length (1 byte)					
		stream.write((byte) 0);
		// NETWORK_ID and its zero length (1 byte)
		stream.write((byte) 0);
		// CELL_NAME and its zero length (1 byte)
		stream.write((byte) 0);
		// empty CELL_ID (4 bytes)
		stream.write(ByteUtil.toBytes(0), 0, 4);			
		// empty COUNTRY CODE (4 bytes)
		stream.write(ByteUtil.toBytes(0), 0, 4);		
		// empty AREA_CODE (4 byte)
		stream.write(ByteUtil.toBytes(0), 0, 4);
		// unknown MEDIA TYPE (1 byte)
		stream.write((byte) MediaType.UNKNOWN);
		// empty IMAGE DATA and 4 bytes zero length
		stream.write(ByteUtil.toBytes(0), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		PanicImage event = new PanicImage();
		event.setEventTime(eventTime);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}

	// ****************************************** Parsing Thumbnail test cases ************************************ //
	
	private void _testParsingWallpaperThumbnail(){
		Log.d(TAG, "_testParsingWallpaperThumbnail");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.WALLPAPER_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.JPEG);
		//image data and 4 bytes length		
		byte[] image = readMediaFile();
		int length = image.length;
		stream.write(ByteUtil.toBytes(length), 0, 4);
		stream.write(image, 0, length);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		WallPaperThumbnailEvent event = new WallPaperThumbnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setFormat(MediaType.JPEG);
		event.setFilePath(MEDIA_PATH);
		event.setActualFileSize(ACTUAL_FILE_SIZE);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingWallpaperThumbnailEmptyImage(){
		Log.d(TAG, "_testParsingWallpaperThumbnailEmptyImage");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.WALLPAPER_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.JPEG);
		//empty image data and 4 bytes zero length		
		stream.write(ByteUtil.toBytes(0), 0, 4);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		WallPaperThumbnailEvent event = new WallPaperThumbnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setFormat(MediaType.JPEG);
		event.setActualFileSize(ACTUAL_FILE_SIZE);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingCameraImageThumbnail(){
		Log.d(TAG, "_testParsingCameraImageThumbnail");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.CAMERA_IMAGE_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.JPEG);
		//GEOTAG
		  //Lon : 8 bytes
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						
		  //Lat : 8 bytes
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);	
		  //Altitude : 4 bytes
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);	
		//image data and 4 bytes length		
		byte[] image = readMediaFile();
		int length = image.length;
		stream.write(ByteUtil.toBytes(length), 0, 4);
		stream.write(image, 0, length);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		CameraImageThumbnailEvent event = new CameraImageThumbnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.JPEG);
		GeoTag tag = new GeoTag();
		tag.setAltitude(ALTITUDE);
		tag.setLat(LATTITUDE);
		tag.setLon(LONGITUDE);
		event.setGeo(tag);
		event.setFilePath(MEDIA_PATH);
		event.setActualSize(ACTUAL_FILE_SIZE);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingCameraImageThumbnailEmptyImageAndFields(){
		Log.d(TAG, "_testParsingCameraImageThumbnailEmptyImageAndFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.CAMERA_IMAGE_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.JPEG);
		//GEOTAG
		  //Lon : 8 bytes
		stream.write(ByteUtil.toBytes(0.0), 0, 8);						
		  //Lat : 8 bytes
		stream.write(ByteUtil.toBytes(0.0), 0, 8);	
		  //Altitude : 4 bytes
		stream.write(ByteUtil.toBytes(0.0f), 0, 4);	
		//empty image data : 4 bytes zero length		
		stream.write(ByteUtil.toBytes(0), 0, 4);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		CameraImageThumbnailEvent event = new CameraImageThumbnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.JPEG);
		event.setActualSize(ACTUAL_FILE_SIZE);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testParsingAudioConversationThumbnail(){
		Log.d(TAG, "_testParsingAudioConversationThumbnail");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.AUDIO_CONVERSATION_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.AAC);
		//embedded call info
		  //direction : 1 byte
		stream.write((byte) EventDirection.IN);
		  //duration : 4 bytes
		stream.write(ByteUtil.toBytes(CALL_DURATION), 0, 4);
		  //number and 1 byte length
		byte[] number = ByteUtil.toBytes(PHONE_NUMBER);
		stream.write((byte) number.length);
		stream.write(number, 0, number.length);
		  //contact name and 1 byte length
		byte[] contactName = ByteUtil.toBytes(CONTACT_NAME);
		stream.write((byte) contactName.length);
		stream.write(contactName, 0, contactName.length);
		//audio data and 4 bytes length
		byte[] audio = readMediaFile();
		stream.write(ByteUtil.toBytes(audio.length), 0, 4);
		stream.write(audio, 0, audio.length);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		//actual duration : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_CALL_DURATION), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		AudioConversationThumbnailEvent event = new AudioConversationThumbnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setFormat(MediaType.AAC);
		EmbededCallInfo callInfo = new EmbededCallInfo();
		callInfo.setDirection(EventDirection.IN);
		callInfo.setDuration(CALL_DURATION);
		callInfo.setNumber(PHONE_NUMBER);
		callInfo.setContactName(CONTACT_NAME);
		event.setEmbededCallInfo(callInfo);
		event.setFilePath(MEDIA_PATH);
		event.setActualFileSize(ACTUAL_FILE_SIZE);
		event.setActualDuration(ACTUAL_CALL_DURATION);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingAudioConversationThumbnailEmptyFields(){
		Log.d(TAG, "_testParsingAudioConversationThumbnailEmptyFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.AUDIO_CONVERSATION_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);						// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.AAC);
		//embedded call info
		  //direction : 1 byte
		stream.write((byte) EventDirection.IN);
		  //duration : 4 bytes
		stream.write(ByteUtil.toBytes(CALL_DURATION), 0, 4);
		  //empty number : 1 byte zero length
		stream.write((byte) 0);
		  //empty contact name : 1 byte zero length
		stream.write((byte) 0);
		//empty audio data : 4 bytes zero length
		stream.write(new byte[]{0x00, 0x00, 0x00, 0x00}, 0, 4);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		//actual duration : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_CALL_DURATION), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		AudioConversationThumbnailEvent event = new AudioConversationThumbnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setFormat(MediaType.AAC);
		EmbededCallInfo callInfo = new EmbededCallInfo();
		callInfo.setDirection(EventDirection.IN);
		callInfo.setDuration(CALL_DURATION);
		event.setEmbededCallInfo(callInfo);
		event.setActualFileSize(ACTUAL_FILE_SIZE);
		event.setActualDuration(ACTUAL_CALL_DURATION);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testParsingAudioFileThumbnail(){
		Log.d(TAG, "_testParsingAudioFileThumbnail");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.AUDIO_FILE_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.AAC);
		//audio data with 4 bytes length
		byte[] audioData = readMediaFile();
		stream.write(ByteUtil.toBytes(audioData.length), 0, 4);
		stream.write(audioData, 0, audioData.length);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		//actual duration : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_CALL_DURATION), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		AudioFileThumnailEvent event = new AudioFileThumnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.AAC);
		event.setFilePath(MEDIA_PATH);
		event.setActualFileSize(ACTUAL_FILE_SIZE);
		event.setActualDuration(ACTUAL_CALL_DURATION);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	
	}
	
	private void _testParsingAudioFileThumbnailEmptyFields(){
		Log.d(TAG, "_testParsingAudioFileThumbnailEmptyFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.AUDIO_FILE_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.AAC);
		//empty audio data : 4 bytes zero length
		stream.write(ByteUtil.toBytes(0), 0, 4);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		//actual duration : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_CALL_DURATION), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		AudioFileThumnailEvent event = new AudioFileThumnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.AAC);
		event.setActualFileSize(ACTUAL_FILE_SIZE);
		event.setActualDuration(ACTUAL_CALL_DURATION);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
		
	}

	private void _testParsingVideoFileThumbnail(){
		Log.d(TAG, "_testParsingVideoFileThumbnail");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.VIDEO_FILE_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.MP4);
		//video data with 4 bytes length
		byte[] videoData = readMediaFile();
		stream.write(ByteUtil.toBytes(videoData.length), 0, 4);
		stream.write(videoData, 0, videoData.length);
		//image count set to 2 : 1 byte
		stream.write((byte) 2);
		//images
		  //first image : data with 4 bytes length
		byte[] imageData = readMediaFile();
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		  //second image : data with 4 bytes length
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		//actual duration : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_CALL_DURATION), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		VideoFileThumbnailEvent event = new VideoFileThumbnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.MP4);
		event.setFilePath(MEDIA_PATH);
		Thumbnail thumb = new Thumbnail();
		thumb.setFilePath(MEDIA_PATH);
		event.addThumbnail(thumb);
		event.addThumbnail(thumb);
		event.setActualFileSize(ACTUAL_FILE_SIZE);
		event.setActualDuration(ACTUAL_CALL_DURATION);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingVideoFileThumbnailEmptyFields(){
		Log.d(TAG, "_testParsingVideoFileThumbnailEmptyFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.VIDEO_FILE_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.MP4);
		//empty video data : 4 bytes empty length
		stream.write(ByteUtil.toBytes(0), 0, 4);
		//image count set to 2 : 1 byte
		stream.write((byte) 0);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		//actual duration : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_CALL_DURATION), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		VideoFileThumbnailEvent event = new VideoFileThumbnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.MP4);
		event.setActualFileSize(ACTUAL_FILE_SIZE);
		event.setActualDuration(ACTUAL_CALL_DURATION);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testParsingVideoFileThumbnailEmptyThumbnailData(){
		Log.d(TAG, "_testParsingVideoFileThumbnailEmptyThumbnailData");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.VIDEO_FILE_THUMBNAIL), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.MP4);
		//video data with 4 bytes length
		byte[] videoData = readMediaFile();
		stream.write(ByteUtil.toBytes(videoData.length), 0, 4);
		stream.write(videoData, 0, videoData.length);
		//image count set to 2 : 1 byte
		stream.write((byte) 2);
		//images
		  //first image : empty data : 4 bytes zero length
		stream.write(ByteUtil.toBytes(0), 0, 4);
		  //second image : data with 4 bytes length
		byte[] imageData = readMediaFile();
		stream.write(ByteUtil.toBytes(imageData.length), 0, 4);
		stream.write(imageData, 0, imageData.length);
		//actual file size : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_FILE_SIZE), 0, 4);
		//actual duration : 4 bytes
		stream.write(ByteUtil.toBytes((int) ACTUAL_CALL_DURATION), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		VideoFileThumbnailEvent event = new VideoFileThumbnailEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.MP4);
		event.setFilePath(MEDIA_PATH);
		Thumbnail thumb1 = new Thumbnail();
		event.addThumbnail(thumb1);
		Thumbnail thumb2 = new Thumbnail();
		thumb2.setFilePath(MEDIA_PATH);
		event.addThumbnail(thumb2);
		event.setActualFileSize(ACTUAL_FILE_SIZE);
		event.setActualDuration(ACTUAL_CALL_DURATION);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	// ****************************************** Parsing Actual Media test cases ************************************ //

	private void _testParsingWallpaper(){
		Log.d(TAG, "_testParsingWallpaper");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.WALLPAPER), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.JPEG);
		//image data and 4 bytes length
		byte[] image = readMediaFile();
		stream.write(ByteUtil.toBytes(image.length), 0, 4);
		stream.write(image, 0, image.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		WallpaperEvent event = new WallpaperEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setFormat(MediaType.JPEG);
		event.setFilePath(MEDIA_PATH);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
		
	}
	
	private void _testParsingWallpaperEmptyImage(){
		Log.d(TAG, "_testParsingWallpaperEmptyImage");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.WALLPAPER), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.JPEG);
		//empty image data : 4 bytes empty length
		stream.write(ByteUtil.toBytes(0), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		WallpaperEvent event = new WallpaperEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setFormat(MediaType.JPEG);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingCamera(){
		Log.d(TAG, "_testParsingCamera");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.CAMERA_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.JPEG);
		//GEOTAG
		  //Lon : 8 bytes
		stream.write(ByteUtil.toBytes(LONGITUDE), 0, 8);						
		  //Lat : 8 bytes
		stream.write(ByteUtil.toBytes(LATTITUDE), 0, 8);	
		  //Altitude : 4 bytes
		stream.write(ByteUtil.toBytes(ALTITUDE), 0, 4);	
		//file name and 1 byte length
		byte[] fileName = ByteUtil.toBytes(FILE_NAME);
		stream.write((byte) fileName.length);
		stream.write(fileName, 0, fileName.length);
		//image data and 4 bytes length
		byte[] image = readMediaFile();
		stream.write(ByteUtil.toBytes(image.length), 0, 4);
		stream.write(image, 0, image.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		CameraImageEvent event = new CameraImageEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.JPEG);
		GeoTag tag = new GeoTag();
		tag.setLat(LATTITUDE);
		tag.setLon(LONGITUDE);
		tag.setAltitude(ALTITUDE);
		event.setGeo(tag);
		event.setFileName(FILE_NAME);
		event.setFilePath(MEDIA_PATH);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingCameraEmptyImageAndFields(){
		Log.d(TAG, "_testParsingCameraEmptyImageAndFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.CAMERA_IMAGE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.JPEG);
		//GEOTAG
		  //Lon : 8 bytes
		stream.write(ByteUtil.toBytes(0.0), 0, 8);						
		  //Lat : 8 bytes
		stream.write(ByteUtil.toBytes(0.0), 0, 8);	
		  //Altitude : 4 bytes
		stream.write(ByteUtil.toBytes(0.0f), 0, 4);	
		//empty file name : 1 byte zero length
		stream.write(0);
		//empty image data : 4 bytes zero length
		stream.write(ByteUtil.toBytes(0), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		CameraImageEvent event = new CameraImageEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.JPEG);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingAudioConversation(){
		Log.d(TAG, "_testParsingAudioConversation");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.AUDIO_CONVERSATION), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.AAC);
		//embedded call info
		  //direction : 1 byte
		stream.write((byte) EventDirection.IN);
		  //duration : 4 bytes
		stream.write(ByteUtil.toBytes(CALL_DURATION), 0, 4);
		  //number and 1 byte length
		byte[] number = ByteUtil.toBytes(PHONE_NUMBER);
		stream.write((byte) number.length);
		stream.write(number, 0, number.length);
		  //contact name and 1 byte length
		byte[] contactName = ByteUtil.toBytes(CONTACT_NAME);
		stream.write((byte) contactName.length);
		stream.write(contactName, 0, contactName.length);
		//file name and 1 byte length
		byte[] fileName = ByteUtil.toBytes(FILE_NAME);
		stream.write((byte) fileName.length);
		stream.write(fileName, 0, fileName.length);
		//audio data and 4 bytes length
		byte[] audio = readMediaFile();
		stream.write(ByteUtil.toBytes(audio.length), 0, 4);
		stream.write(audio, 0, audio.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		AudioConversationEvent event = new AudioConversationEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setFormat(MediaType.AAC);
		EmbededCallInfo callInfo = new EmbededCallInfo();
		callInfo.setDirection(EventDirection.IN);
		callInfo.setDuration(CALL_DURATION);
		callInfo.setNumber(PHONE_NUMBER);
		callInfo.setContactName(CONTACT_NAME);
		event.setEmbededCallInfo(callInfo);
		event.setFileName(FILE_NAME);
		event.setFilePath(MEDIA_PATH);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));

	}
	
	private void _testParsingAudioConversationEmptyFields(){
		Log.d(TAG, "_testParsingAudioConversationEmptyFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.AUDIO_CONVERSATION), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.AAC);
		//embedded call info
		  //direction : 1 byte
		stream.write((byte) EventDirection.IN);
		  //duration : 4 bytes
		stream.write(ByteUtil.toBytes(CALL_DURATION), 0, 4);
		  //empty number : 1 byte zero length
		stream.write(0);
		  //empty contact name : 1 byte zero length
		stream.write(0);
		//empty file name : 1 byte zero length
		stream.write(0);
		//empty audio data : 4 bytes zero length
		stream.write(ByteUtil.toBytes(0), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		AudioConversationEvent event = new AudioConversationEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setFormat(MediaType.AAC);
		EmbededCallInfo callInfo = new EmbededCallInfo();
		callInfo.setDirection(EventDirection.IN);
		callInfo.setDuration(CALL_DURATION);
		event.setEmbededCallInfo(callInfo);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingAudioFile(){
		Log.d(TAG, "_testParsingAudioFile");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.AUDIO_FILE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.AAC);
		//file name and 1 byte length
		byte[] fileName = ByteUtil.toBytes(FILE_NAME);
		stream.write((byte) fileName.length);
		stream.write(fileName, 0, fileName.length);
		//audio data and 4 bytes length
		byte[] audio = readMediaFile();
		stream.write(ByteUtil.toBytes(audio.length), 0, 4);
		stream.write(audio, 0, audio.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		AudioFileEvent event = new AudioFileEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.AAC);
		event.setFileName(FILE_NAME);
		event.setFilePath(MEDIA_PATH);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
		
	}
	
	private void _testParsingAudioFileEmptyFields(){
		Log.d(TAG, "_testParsingAudioFileEmptyFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.AUDIO_FILE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.AAC);
		//empty file name : 1 byte zero length
		stream.write(0);
		//empty audio data : 4 bytes zero length
		stream.write(ByteUtil.toBytes(0), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		AudioFileEvent event = new AudioFileEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.AAC);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingVideoFile(){
		Log.d(TAG, "_testParsingVideoFile");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.VIDEO_FILE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.MP4);
		//file name and 1 byte length
		byte[] fileName = ByteUtil.toBytes(FILE_NAME);
		stream.write((byte) fileName.length);
		stream.write(fileName, 0, fileName.length);
		//audio data and 4 bytes length
		byte[] video = readMediaFile();
		stream.write(ByteUtil.toBytes(video.length), 0, 4);
		stream.write(video, 0, video.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		VideoFileEvent event = new VideoFileEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.MP4);
		event.setFileName(FILE_NAME);
		event.setFilePath(MEDIA_PATH);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));

	}
	
	private void _testParsingVideoFileEmptyFields(){
		Log.d(TAG, "_testParsingVideoFileEmptyFields");
		
		String eventTime = PhoenixTestUtil.getCurrentEventTimeStamp();
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		stream.write(ByteUtil.toBytes((short) EventType.VIDEO_FILE), 0, 2);		// event type (2 bytes)
		stream.write(ByteUtil.toBytes(eventTime), 0, 19);									// event time stamp (19 bytes)
		//paring ID : 4 bytes
		stream.write(ByteUtil.toBytes((int) PARING_ID), 0, 4);
		//format : 1 byte		
		stream.write((byte) MediaType.MP4);
		//empty file name : 1 byte zero length
		stream.write(0);
		//empty audio data : 4 bytes zero length
		stream.write(ByteUtil.toBytes(0), 0, 4);
		byte[] expected = stream.toByteArray();
		
		//2 parsing
		VideoFileEvent event = new VideoFileEvent();
		event.setEventTime(eventTime);
		event.setParingId(PARING_ID);
		event.setMediaFormat(MediaType.MP4);
		try {
			EventParser.parseEvent(event, createOutputFileStream());
		} catch (Exception e) {
			fail(e.getMessage());
		}
		byte[] result = readResultFile();
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}

}
