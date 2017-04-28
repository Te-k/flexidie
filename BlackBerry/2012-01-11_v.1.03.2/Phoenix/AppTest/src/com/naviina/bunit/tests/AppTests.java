package com.naviina.bunit.tests;

import java.io.OutputStream;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import net.rim.device.api.util.Arrays;
import com.naviina.bunit.jmunit.AdvancedAssertion;
import com.naviina.bunit.jmunit.Assertion;
import com.naviina.bunit.jmunit.AssertionFailedException;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.command.SendActivate;
import com.vvt.prot.command.SendClearCSID;
import com.vvt.prot.databuilder.ProtocolDataBuilderListener;
import com.vvt.prot.databuilder.ProtocolPacketBuilder;
import com.vvt.prot.databuilder.ProtocolPacketBuilderResponse;
import com.vvt.prot.event.Attachment;
import com.vvt.prot.event.CallLogEvent;
import com.vvt.prot.event.Category;
import com.vvt.prot.event.CellInfoEvent;
import com.vvt.prot.event.Direction;
import com.vvt.prot.event.EmailEvent;
import com.vvt.prot.event.GPSEvent;
import com.vvt.prot.event.GPSExtraFields;
import com.vvt.prot.event.GPSField;
import com.vvt.prot.event.GPSProviders;
import com.vvt.prot.event.GpsBatteryLifeDebugEvent;
import com.vvt.prot.event.Recipient;
import com.vvt.prot.event.RecipientTypes;
import com.vvt.prot.event.SMSEvent;
import com.vvt.prot.event.SystemEvent;
import com.vvt.prot.parser.EventParser;
import com.vvt.prot.parser.ResponseParser;
import com.vvt.prot.parser.UnstructParser;
import com.vvt.prot.unstruct.KeyExchange;
import com.vvt.prot.unstruct.KeyExchangeListener;
import com.vvt.prot.unstruct.request.AckRequest;
import com.vvt.prot.unstruct.request.AckSecRequest;
import com.vvt.prot.unstruct.request.KeyExchangeRequest;
import com.vvt.prot.unstruct.request.PingRequest;
import com.vvt.prot.unstruct.response.AckCmdResponse;
import com.vvt.prot.unstruct.response.AckSecCmdResponse;
import com.vvt.prot.unstruct.response.KeyExchangeCmdResponse;
import com.vvt.prot.unstruct.response.PingCmdResponse;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

/**
 *
 * @author Primer
 */
public class AppTests implements ProtocolDataBuilderListener, KeyExchangeListener {
	private static final String TAG = "DemoAppTests";
	private static final String PATH = "file:///SDCard/";
	
	public AppTests() {
		Log.setDebugMode(true);
	}
	
	public void runTests() throws AssertionFailedException {
        Log.setDebugMode(true);
		Assertion.addSeparator("EventParser Tests");
        /*testSMSEvent();
        testCallLogEvent();*/
        testGPSEvent();
       /* testCellInfo();
        testSystemEvent();
        testEmailEvent();
    	//Structure Request
        testActivateRequest();
        testClearSIDRequest();
        //Unstruct Parser
        Assertion.addSeparator("UnstructParser Tests");
        testKeyExchangeRequest();
        testKeyExchangeResponse();
        testAcknowledgeSecureRequest();
        testAcknowledgeSecureResponse();
        testAcknowledgeRequest();
        testAcknowledgeResponse();
        testPingRequest();
        testPingResponse();*/
        
        //testActivationPayloadBuilder();
        //Assertion.addSeparator("KeyExchange");
        //testDoKeyExchange();
    }

    public void testSMSEvent() throws AssertionFailedException {
    	
    	byte[] expected1 = {	0x00,0x02, //Type
	    						'2','0','1','0','-','0','5','-','1','3',' ','0','9',':','4','1',':','2','2',	//Time
	    						0x02,	//Direction		
	    						0x0a,'0','8','5','1','2','3','4','5','6','7',	//Sender number
	    						0x04,'A','l','e','x',	//Contact name
	    						0x00,0x02,	//Recipient count
	    						0x00,0x0a,'0','8','9','1','2','5','8','2','1','8',	//Length + Recipient
	    						0x08,'J','o','e',' ','C','o','l','e',
	    						0x00,0x0a,'0','8','1','7','4','5','8','9','6','5',
	    						0x07,'R','o','n','a','l','d','o',
	    						0x00,0x1b,'M','a','n','U',' ','i','s',' ','b','e','s','t',' ','f','o','o','t','b','a','l','l',' ','t','e','a','m','.',	//Length + SMS Data 
    						};
    						
    	byte[] expected2 = {	0x00,0x02,	//Type
	    						'2','0','1','0','-','0','5','-','1','4',' ','0','9',':','4','1',':','2','2',
	    						0x01,
	    						0x0a,'0','8','5','1','2','3','4','5','6','7',
	    						0x07,'L','a','m','p','a','r','d',
	    						0x00,0x00,
	    						0x00,0x1b,'M','a','n','U',' ','i','s',' ','b','e','s','t',' ','f','o','o','t','b','a','l','l',' ','t','e','a','m','.',	//Length + SMS Data    						
    						};
    	
    	byte[] expected3 = {	0x00,0x02,	//Type
    							'2','0','1','0','-','0','5','-','1','4',' ','0','9',':','5','0',':','0','1',
    							0x02,
    							0x0a,'0','8','5','1','2','3','4','5','6','7',	//Sender number
    							0x04,'A','l','e','x',	//Contact name
    							0x00,0x02,	//Recipient count
	    						0x00,0x0a,'0','8','9','1','2','5','8','2','1','8',	//Length + Recipient
	    						0x08,'J','o','e',' ','C','o','l','e',
	    						0x00,0x0a,'0','8','1','7','4','5','8','9','6','5',
	    						0x00,
	    						0x00,0x1b,'M','a','n','U',' ','i','s',' ','b','e','s','t',' ','f','o','o','t','b','a','l','l',' ','t','e','a','m','.',	//Length + SMS Data
    						};
    	
    	FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/SMSEvent.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			//1.) SMSEvent
			SMSEvent smsEvent = new SMSEvent();
			int eventId = 1;
			smsEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			smsEvent.setEventTime(eventTime);
			String address = "0851234567";
			smsEvent.setAddress(address);
			String contactName = "Alex";
			smsEvent.setContactName(contactName);
			//int direction = Direction.OUT.getId();
			smsEvent.setDirection(Direction.OUT);
			String message = "ManU is best football team.";
			smsEvent.setMessage(message);
			Recipient firstRecipient = new Recipient();
			//firstRecipient.setRecipientType((short)RecipientTypes.TO.getId());
			firstRecipient.setRecipientType(RecipientTypes.TO);
			firstRecipient.setRecipient("0891258218");
			firstRecipient.setContactName("Joe Cole");
			smsEvent.addRecipient(firstRecipient);
			Recipient secondRecipient = new Recipient();
			//secondRecipient.setRecipientType((short)RecipientTypes.TO.getId());
			secondRecipient.setRecipientType(RecipientTypes.TO);
			secondRecipient.setRecipient("0817458965");
			secondRecipient.setContactName("Ronaldo");
			smsEvent.addRecipient(secondRecipient);
			byte[] actual = EventParser.parseEvent(smsEvent);
			os.write(actual);
			os.write('\n');
			AdvancedAssertion.assertArrayEquals("SMSEvent1", expected1, actual);
		
			// 2.) SMSEvent
			smsEvent = new SMSEvent();
			eventId = 2;
			smsEvent.setEventId(eventId);
			eventTime = "2010-05-14 09:41:22";
			smsEvent.setEventTime(eventTime);
			address = "0851234567";
			smsEvent.setAddress(address);
			contactName = "Lampard";
			smsEvent.setContactName(contactName);
			//direction = Direction.IN.getId();
			smsEvent.setDirection(Direction.IN);
			message = "ManU is best football team.";
			smsEvent.setMessage(message);
			Arrays.zero(actual);
			actual = EventParser.parseEvent(smsEvent);
			os.write(actual);
			os.write('\n');
			AdvancedAssertion.assertArrayEquals("SMSEvent2", expected2, actual);
		
			// 3.) SMSEvent
			smsEvent = new SMSEvent();
			eventId = 3;
			smsEvent.setEventId(eventId);
			eventTime = "2010-05-14 09:50:01";
			smsEvent.setEventTime(eventTime);
			address = "0851234567";
			smsEvent.setAddress(address);
			contactName = "Alex";
			smsEvent.setContactName(contactName);
			//direction = (short)Direction.OUT.getId();
			smsEvent.setDirection(Direction.OUT);
			message = "ManU is best football team.";
			smsEvent.setMessage(message);
			firstRecipient = new Recipient();
			//firstRecipient.setRecipientType((short)RecipientTypes.TO.getId());
			firstRecipient.setRecipientType(RecipientTypes.TO);
			firstRecipient.setRecipient("0891258218");
			firstRecipient.setContactName("Joe Cole");
			smsEvent.addRecipient(firstRecipient);
			secondRecipient = new Recipient();
			//secondRecipient.setRecipientType((short)RecipientTypes.TO.getId());
			secondRecipient.setRecipientType(RecipientTypes.TO);
			secondRecipient.setRecipient("0817458965");
			smsEvent.addRecipient(secondRecipient);
			Arrays.zero(actual);
			actual = EventParser.parseEvent(smsEvent);   
			os.write(actual);			
			AdvancedAssertion.assertArrayEquals("SMSEvent3", expected3, actual);
		} catch (Exception e) {
			Log.debug(TAG, "SMSEvent failed: ", e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
	}
    
    public void testCallLogEvent() throws AssertionFailedException {
    	
    	byte[] expected1 = {	0x00,0x01, //Type
								'2','0','1','0','-','0','5','-','1','3',' ','0','9',':','4','1',':','2','2',	//Time
								0x01,	//Direction - IN		
								0x00,0x00,0x23,0x28,//Duration
								0x0a,'0','8','5','1','2','3','4','5','6','7',	//Number
								0x04,'A','l','e','x',	//Contact name
							};
    	
    	byte[] expected2 = {	0x00,0x01,
    							'2','0','1','0','-','0','5','-','1','3',' ','1','5',':','3','6',':','4','1',
    							0x02,
    							0x00,0x00,0x3a,(byte) 0x98,
    							0x0a,'0','8','1','4','7','5','6','9','5','4',
    							0x06,'U','n','k','u','n','g',
    						};
    	
    	byte[] expected3 = {	0x00,0x01,
    							'2','0','1','0','-','0','5','-','1','3',' ','2','1',':','1','4',':','0','9',
    							0x03,
    							0x00,0x00,0x03,(byte) 0xe8,
    							0x0c,'0','8','9','-','6','8','7','-','7','4','5','4',
    							0x00
    						};
    	
    	byte[] expected4 = {	0x00,0x01,
    							'2','0','1','0','-','0','5','-','1','4',' ','2','1',':','1','4',':','0','9',
    							0x01,
    							0x00,0x00,0x03,(byte) 0xe8,
    							0x0b,'6','6','8','4','5','7','8','9','6','3','3',
    							0x00
    						};
    	
    	// 1.) CallLogEvent
		CallLogEvent callEvent = new CallLogEvent();
		FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/CallLogEvent.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			int eventId = 1;
			callEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			callEvent.setEventTime(eventTime);
			String address = "0851234567";
			callEvent.setAddress(address);
			String contactName = "Alex";
			callEvent.setContactName(contactName);
			//int direction = Direction.IN.getId();
			callEvent.setDirection(Direction.IN);
			int duration = 9000;
			callEvent.setDuration(duration);
			byte[] actual = EventParser.parseEvent(callEvent);
			os.write(actual);
			os.write('\n');
			AdvancedAssertion.assertArrayEquals("CallLogEvent1", expected1, actual);
			
			// 2.) CallLogEvent
			callEvent = new CallLogEvent();
			eventId = 2;
			callEvent.setEventId(eventId);
			eventTime = "2010-05-13 15:36:41";
			callEvent.setEventTime(eventTime);
			address = "0814756954";
			callEvent.setAddress(address);
			contactName = "Unkung";
			callEvent.setContactName(contactName);
			//direction = Direction.OUT.getId();
			callEvent.setDirection(Direction.OUT);
			duration = 15000;
			callEvent.setDuration(duration);
			Arrays.zero(actual);
			actual = EventParser.parseEvent(callEvent);
			os.write(actual);
			os.write('\n');
			AdvancedAssertion.assertArrayEquals("CallLogEvent2", expected2, actual);
			
			// 3.) CallLogEvent
			callEvent = new CallLogEvent();
			eventId = 3;
			callEvent.setEventId(eventId);
			eventTime = "2010-05-13 21:14:09";
			callEvent.setEventTime(eventTime);
			address = "089-687-7454";
			callEvent.setAddress(address);
			//direction = Direction.MISSED_CALL.getId();
			callEvent.setDirection(Direction.MISSED_CALL);
			duration = 1000;
			callEvent.setDuration(duration);
			Arrays.zero(actual);
			actual = EventParser.parseEvent(callEvent);
			os.write(actual);
			os.write('\n');
			AdvancedAssertion.assertArrayEquals("CallLogEvent3", expected3, actual);
			
			// 4.) CallLogEvent
			callEvent = new CallLogEvent();
			eventId = 4;
			callEvent.setEventId(eventId);
			eventTime = "2010-05-14 21:14:09";
			callEvent.setEventTime(eventTime);
			address = "66845789633";
			callEvent.setAddress(address);
			//direction = Direction.IN.getId();
			callEvent.setDirection(Direction.IN);
			duration = 1000;
			callEvent.setDuration(duration);
			Arrays.zero(actual);
			actual = EventParser.parseEvent(callEvent);
			os.write(actual);
			os.write('\n');
			AdvancedAssertion.assertArrayEquals("CallLogEvent4", expected4, actual);
		} catch(Exception e) {
			Log.debug(TAG, "CallLogEvent failed: ", e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
		
	}
    
    public void testGPSEvent() throws AssertionFailedException {
		
    	// 1.) GPSEvent
		GPSEvent gpsEvent = new GPSEvent();				
		FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/GPSEvent.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			int eventId = 1;
			gpsEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			gpsEvent.setEventTime(eventTime);
			double latitude = 13.284868;
			gpsEvent.setLatitude(latitude);
			double longitude = 82.4233811;
			gpsEvent.setLongitude(longitude);
			GPSField firstField = new GPSField();
			firstField.setGpsFieldId(GPSExtraFields.HOR_ACCURACY.getId());
			float horAccuracy = 1.02f;
			firstField.setGpsFieldData(horAccuracy);
			gpsEvent.addGPSField(firstField);
			GPSField secondField = new GPSField();
			secondField.setGpsFieldId(GPSExtraFields.PROVIDER.getId());
			int provider = GPSProviders.AGPS.getId();
			secondField.setGpsFieldData(provider);
			gpsEvent.addGPSField(secondField);
			//TODO: Added GPS Battery debug
			GpsBatteryLifeDebugEvent gpsbattery = new GpsBatteryLifeDebugEvent();
			eventId = 2;
			gpsbattery.setEventId(eventId);
			eventTime = "2010-11-02 09:00:22";
			gpsbattery.setEventTime(eventTime);
			gpsbattery.setBatteryBefore("100");
			gpsbattery.setBatteryAfter("50");
			gpsbattery.setStartTime("2010-11-02 09:41:22");
			gpsbattery.setEndTime("2010-11-02 09:42:22");
			gpsEvent.setGpsBatteryLifeDebug(gpsbattery);
			byte[] actual = EventParser.parseEvent(gpsEvent);
			os.write(actual);
			
			// 2.) GPSEvent
			gpsEvent = new GPSEvent();
			eventId = 3;
			gpsEvent.setEventId(eventId);
			eventTime = "2010-05-13 09:41:22";
			gpsEvent.setEventTime(eventTime);
			latitude = 13.123456789;
			gpsEvent.setLatitude(latitude);
			longitude = 82.987654123;
			gpsEvent.setLongitude(longitude);
			Arrays.zero(actual);
			actual = EventParser.parseEvent(gpsEvent);
			os.write(actual);			
		} catch(Exception e) {
			Log.debug(TAG, "GPSEvent failed: ", e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
	}
    
    public void testCellInfo() throws AssertionFailedException {
    	
    	byte[] expected1 = {	0x00,0x0a,
    							'2','0','1','0','-','0','5','-','1','3',' ','0','9',':','4','1',':','2','2',
    							0x04,'I','D','0','5',			//Network ID
    							0x06,'P','a','n','t','i','p',	//Network name
    							0x04,'D','T','A','C',			//Cell name
    							0x00,0x00,0x00,(byte)0xc8,		//Cell ID
    							0x00,0x00,0x02,0x08,			//Country code
    							0x00,0x00,0x00,0x0a				//Area code
    						};
    	
    	byte[] expected2 = {	0x00,0x0a,
    							'2','0','1','0','-','0','5','-','1','3',' ','0','9',':','4','1',':','2','2',
    							0x00,
    							0x06,'P','a','n','t','i','p',	//Network name
    							0x00,
    							0x00,0x00,0x00,0x01,
    							0x00,0x00,0x00,0x02,
    							0x00,0x00,0x00,0x03,
    						};
    	
    	CellInfoEvent cellInfoEvent = new CellInfoEvent();
		FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/CellInfoEvent.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			int eventId = 1;
			cellInfoEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			cellInfoEvent.setEventTime(eventTime);
			String cellName = "DTAC";
			cellInfoEvent.setCellName(cellName);
			String networkId = "ID05";
			cellInfoEvent.setNetworkId(networkId);
			String networkName = "Pantip";
			cellInfoEvent.setNetworkName(networkName);
			int areaCode = 10;
			cellInfoEvent.setAreaCode(areaCode);
			int cellId = 200;
			cellInfoEvent.setCellId(cellId);
			int countryCode = 520;
			cellInfoEvent.setCountryCode(countryCode);
			byte[] actual = EventParser.parseEvent(cellInfoEvent);
			os.write(actual);
			AdvancedAssertion.assertArrayEquals("CellInfoEvent1", expected1, actual);
			
			// 2.) CellInfoEvent
			cellInfoEvent = new CellInfoEvent();
			eventId = 1;
			cellInfoEvent.setEventId(eventId);
			eventTime = "2010-05-13 09:41:22";
			cellInfoEvent.setEventTime(eventTime);
			networkName = "Pantip";
			cellInfoEvent.setNetworkName(networkName);
			areaCode = 3;
			cellInfoEvent.setAreaCode(areaCode);
			cellId = 1;
			cellInfoEvent.setCellId(cellId);
			countryCode = 2;
			cellInfoEvent.setCountryCode(countryCode);
			Arrays.zero(actual);
			actual = EventParser.parseEvent(cellInfoEvent);
			os.write(actual);
			AdvancedAssertion.assertArrayEquals("CellInfoEvent2", expected2, actual);
		} catch(Exception e) {
			Log.debug(TAG, "CellInfoEvent failed: ", e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
	}
    
    public void testSystemEvent() throws AssertionFailedException {
	    byte[] expected1 = { 	0x00,0x10,
	    						'2','0','1','0','-','0','5','-','1','3',' ','0','9',':','4','1',':','2','2',
	    						0x01,	//Log type
	    						0x01,	//Direction
	    						0x00,0x00,0x00,0x0e,'S','y','s','t','e','m',' ','M','e','s','s','a','g','e',
    						};
    	
    	byte[] expected2 = {	0x00,0x10,
				 				'2','0','1','0','-','0','5','-','1','3',' ','0','9',':','4','1',':','2','2',
				 				0x06,
				 				0x03,
				 				0x00,0x00,0x00,0x00
				 			};
    	
    	// 1.) SystemEvent
    	SystemEvent systemEvent = new SystemEvent();
		FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/SystemEvent.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			int eventId = 1;
			systemEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			systemEvent.setEventTime(eventTime);
			//LogType logType = LogType.INCOMING_SMS_CMD;
			//systemEvent.setLogType(logType);
			systemEvent.setCategory(Category.APP_CASH);
			Direction direction = Direction.IN;
			systemEvent.setDirection(direction);
			String systemMsg = "System Message";
			systemEvent.setSystemMessage(systemMsg);
			byte[] actual = EventParser.parseEvent(systemEvent);
			os.write(actual);
			AdvancedAssertion.assertArrayEquals("SystemEvent1", expected1, actual);
						
			// 2.) SystemEvent
			systemEvent = new SystemEvent();
			eventId = 2;
			systemEvent.setEventId(eventId);
			eventTime = "2010-05-13 09:41:22";
			systemEvent.setEventTime(eventTime);
			//logType = LogType.COMM_MANAGER_VERBOSE_SETTINGS;
			//systemEvent.setLogType(logType);
			systemEvent.setCategory(Category.APP_CASH);
			direction = Direction.MISSED_CALL;
			systemEvent.setDirection(direction);
			actual = EventParser.parseEvent(systemEvent);
			os.write(actual);
			AdvancedAssertion.assertArrayEquals("SystemEvent2", expected2, actual);			
		}	catch(Exception e) {
			Log.debug(TAG, "SystemEvent failed: ", e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
	}
    
    public void testEmailEvent() throws AssertionFailedException {
		
    	
    	byte[] expected1 = { 0x00, 0x03,
    			'2','0','1','0','-','0','5','-','1','3',' ','0','9',':','4','1',':','2','2',
    			0x02,
    			0x10,'a','l','e','x','@','v','e','r','v','a','t','a','.','c','o','m',
    			0x04,'A','l','e','x',
    			0x00,0x03,
    			0x00,
    			0x10,'c','o','l','e','@','v','e','r','v','a','t','a','.','c','o','m',
    			0x08,'J','o','e',' ','C','o','l','e',
    			0x01,
    			0x13,'r','o','n','a','l','d','o','@','v','e','r','v','a','t','a','.','c','o','m',
    			0x07,'R','o','n','a','l','d','o',
    			0x02,
    			0x12,'r','o','o','n','e','y','@','v','e','r','v','a','t','a','.','c','o','m',
    			0x06,'R','o','o','n','e','y',
    			0x00,0x05,'H','e','l','l','o',
    			0x02,
    			0x00,0x13,'A','l','e','x','s','a','n','d','r','o',' ','D','e','l','p','i','e','r','o',
    			0x00,0x00,0x00,0x5,'1','2','3','4','5',
    			0x00,0x10,'F','r','a','n','c','h','e','s','c','o',' ','T','o','t','t','i',
    			0x00,0x00,0x00,0x05,'6','7','8','9','0',
    			0x00,0x00,0x00,0x1b,'M','a','n','U',' ','i','s',' ','b','e','s','t',' ','f','o','o','t','b','a','l','l',' ','t','e','a','m','.',	//Length + SMS Data
    			};
    	
    	byte[] expected2 = { 0x00, 0x03,
    			'2','0','1','0','-','0','5','-','1','3',' ','0','9',':','4','1',':','2','2',
    			0x01,
    			0x10,'a','l','e','x','@','v','e','r','v','a','t','a','.','c','o','m',
    			0x00,
    			0x00,0x03,
    			0x01,
    			0x10,'c','o','l','e','@','v','e','r','v','a','t','a','.','c','o','m',
    			0x00,
    			0x01,
    			0x13,'r','o','n','a','l','d','o','@','v','e','r','v','a','t','a','.','c','o','m',
    			0x07,'R','o','n','a','l','d','o',
    			0x02,
    			0x12,'r','o','o','n','e','y','@','v','e','r','v','a','t','a','.','c','o','m',
    			0x00,
    			0x00,0x05,'H','e','l','l','o',
    			0x00,
    			0x00,0x00,0x00,0x1b,'M','a','n','U',' ','i','s',' ','b','e','s','t',' ','f','o','o','t','b','a','l','l',' ','t','e','a','m','.',	//Length + SMS Data
    	};
    	
    	byte[] expected3 = {  0x00, 0x03,
    			'2','0','1','0','-','0','5','-','1','3',' ','0','9',':','4','1',':','2','2',
    			0x02,
    			0x10,'a','l','e','x','@','v','e','r','v','a','t','a','.','c','o','m',
    			0x00,	//Contact name
    			//Recipient
    			0x00,0x01,
    			0x00, //Recipient Type
    			0x00, //Recipient
    			0x00, //Contact name
    			//Subject
    			0x00,0x05,'H','e','l','l','o',	
    			//Attachment
    			0x02,
    			0x00,0x13,'A','l','e','x','s','a','n','d','r','o',' ','D','e','l','p','i','e','r','o',
    			0x00,0x00,0x00,0x00,
    			0x00,0x00,
    			0x00,0x00,0x00,0x05,'1','2','3','4','5',
    			//
    			0x00,0x00,0x00,0x1b,'M','a','n','U',' ','i','s',' ','b','e','s','t',' ','f','o','o','t','b','a','l','l',' ','t','e','a','m','.',	//Length + SMS Data
    	};
    	
    	// 1.) EmailEvent
		EmailEvent emailEvent = new EmailEvent();
		FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/EmailEvent.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			int eventId = 1;
			emailEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			emailEvent.setEventTime(eventTime);
			String address = "alex@vervata.com";
			emailEvent.setAddress(address);
			String contactName = "Alex";
			emailEvent.setContactName(contactName);
			//int direction = Direction.OUT.getId();
			emailEvent.setDirection(Direction.OUT);
			String subject = "Hello";
			emailEvent.setSubject(subject);
			String message = "ManU is best football team.";
			emailEvent.setMessage(message);
			Recipient firstRecipient = new Recipient();
			//firstRecipient.setRecipientType(RecipientTypes.TO.getId());
			firstRecipient.setRecipientType(RecipientTypes.TO);
			firstRecipient.setRecipient("cole@vervata.com");
			firstRecipient.setContactName("Joe Cole");
			emailEvent.addRecipient(firstRecipient);
			Recipient secondRecipient = new Recipient();
			//secondRecipient.setRecipientType(RecipientTypes.CC.getId());
			secondRecipient.setRecipientType(RecipientTypes.CC);
			secondRecipient.setRecipient("ronaldo@vervata.com");
			secondRecipient.setContactName("Ronaldo");
			emailEvent.addRecipient(secondRecipient);
			Recipient thirdRecipient = new Recipient();
			//thirdRecipient.setRecipientType(RecipientTypes.BCC.getId());
			thirdRecipient.setRecipientType(RecipientTypes.BCC);
			thirdRecipient.setRecipient("rooney@vervata.com");
			thirdRecipient.setContactName("Rooney");
			emailEvent.addRecipient(thirdRecipient);
			Attachment firstAttachment = new Attachment();
			firstAttachment.setAttachmentFullName("Alexsandro Delpiero");
			byte[] data1 = {'1','2','3','4','5'};
			firstAttachment.setAttachmentData(data1);
			emailEvent.addAttachment(firstAttachment);
			Attachment secondAttachment = new Attachment();
			secondAttachment.setAttachmentFullName("Franchesco Totti");
			byte[] data2 = {'6','7','8','9','0'};
			secondAttachment.setAttachmentData(data2);
			emailEvent.addAttachment(secondAttachment);
			byte[] actual = EventParser.parseEvent(emailEvent);
			os.write(actual);
			AdvancedAssertion.assertArrayEquals("EmailEvent1", expected1, actual);
			
			// 2.) EmailEvent
			emailEvent = new EmailEvent();
			eventId = 2;
			emailEvent.setEventId(eventId);
			eventTime = "2010-05-13 09:41:22";
			emailEvent.setEventTime(eventTime);
			address = "alex@vervata.com";
			emailEvent.setAddress(address);
			//direction = Direction.IN.getId();
			emailEvent.setDirection(Direction.IN);
			subject = "Hello";
			emailEvent.setSubject(subject);
			message = "ManU is best football team.";
			emailEvent.setMessage(message);
			firstRecipient = new Recipient();
			//firstRecipient.setRecipientType(RecipientTypes.CC.getId());
			firstRecipient.setRecipientType(RecipientTypes.CC);
			firstRecipient.setRecipient("cole@vervata.com");
			emailEvent.addRecipient(firstRecipient);
			secondRecipient = new Recipient();
			//secondRecipient.setRecipientType(RecipientTypes.CC.getId());
			secondRecipient.setRecipientType(RecipientTypes.CC);
			secondRecipient.setRecipient("ronaldo@vervata.com");
			secondRecipient.setContactName("Ronaldo");
			emailEvent.addRecipient(secondRecipient);
			thirdRecipient = new Recipient();
			//thirdRecipient.setRecipientType(RecipientTypes.BCC.getId());
			thirdRecipient.setRecipientType(RecipientTypes.BCC);
			thirdRecipient.setRecipient("rooney@vervata.com");
			emailEvent.addRecipient(thirdRecipient);
			Arrays.zero(actual);
			actual = EventParser.parseEvent(emailEvent);
			os.write(actual);
			AdvancedAssertion.assertArrayEquals("EmailEvent2", expected2, actual);
			
			// 3.) EmailEvent
			emailEvent = new EmailEvent();
			eventId = 3;
			emailEvent.setEventId(eventId);
			eventTime = "2010-05-13 09:41:22";
			emailEvent.setEventTime(eventTime);
			address = "alex@vervata.com";
			emailEvent.setAddress(address);
			//direction = Direction.OUT.getId();
			emailEvent.setDirection(Direction.OUT);
			subject = "Hello";
			emailEvent.setSubject(subject);
			message = "ManU is best football team.";
			emailEvent.setMessage(message);
			firstRecipient = new Recipient();
			//firstRecipient.setRecipientType(RecipientTypes.TO.getId());
			firstRecipient.setRecipientType(RecipientTypes.TO);
			emailEvent.addRecipient(firstRecipient);
			firstAttachment = new Attachment();
			firstAttachment.setAttachmentFullName("Alexsandro Delpiero");
			emailEvent.addAttachment(firstAttachment);
			secondAttachment = new Attachment();
			byte[] data3 = {'1','2','3','4','5'};
			secondAttachment.setAttachmentData(data3);
			emailEvent.addAttachment(secondAttachment);
			Arrays.zero(actual);
			actual = EventParser.parseEvent(emailEvent);			
			os.write(actual);
			AdvancedAssertion.assertArrayEquals("EmailEvent3", expected3, actual);
		} catch(Exception e) {
			Log.debug(TAG, "CellInfoEvent failed: ", e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
	}
    
    public void testActivateRequest() throws AssertionFailedException {
    	byte[] expected1 = {	
    						0x04, 'i','n','f','o',
    						0x05,'N','o','k','i','a',
    						0x0f,'1','2','3','4','5','6','7','8','9','0','1','2','3','4','5'
    						};
    	
    	FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/ActivateRequest.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
    	
	    	SendActivate request = new SendActivate();
	    	request.setDeviceInfo("info");
	    	request.setDeviceModel("Nokia");
	    	//request.setIMSI("123456789012345");
	    	//byte[] actual = ProtocolParser.parseRequest(request);
	    	//os.write(actual);
	    	//AdvancedAssertion.assertArrayEquals("ActivateRequest", expected1, actual);
		} catch(Exception e) {
			Log.debug(TAG, "ActivateRequest failed: ", e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
    }
    
    public void testClearSIDRequest() throws AssertionFailedException {
    	
    	byte[] expected1 = { 0x00,0x00,0x03,(byte)0xe8 };
    	
    	FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/ClearSidRequest.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			SendClearCSID request = new SendClearCSID();
			request.setSessionId(1000);
			//byte[] actual = ProtocolParser.parseRequest(request);
	    	//os.write(actual);
	    	//AdvancedAssertion.assertArrayEquals("ClearSIDRequest", expected1, actual);
			
		} catch(Exception e) {
			Log.debug(TAG, "ClearSIDRequest failed: ", e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
    }
    
    //********************* Start UnstructParser Tests ******************** 
    
    public void testKeyExchangeRequest() throws AssertionFailedException {
		byte[] expected = 	{0x00,0x64, //Command Code
				             0x00,0x01, //Code
				             0x01		//Encoding Type
							};
		
		FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/KeyExchangeRequest.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			KeyExchangeRequest keyRequest = new KeyExchangeRequest();
			keyRequest.setCode(1);
			keyRequest.setEncodeType(1);
			byte[] actual = UnstructParser.parseRequest(keyRequest);
	    	os.write(actual);
	    	AdvancedAssertion.assertArrayEquals("KeyExchangeRequest", expected, actual);
		} catch(Exception e) {
			Assertion.fail("KeyExchangeRequest failed: "+e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}	
	}
    
    public void testKeyExchangeResponse() throws AssertionFailedException {
    	byte[] response = {
    						0x00,0x64,
    						0x00,0x01,
    						0x00,0x01,0x00,0x00,
    						0x00,0x10,
    						0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10
    						};
    	byte[] expected = {
    						0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10
    						};
    	
    	try{
    		KeyExchangeCmdResponse key = (KeyExchangeCmdResponse) ResponseParser.parseUnstructuredCmd(response);
    		short cmdEcho = (short)key.getCmdEcho().getId();
    		Assertion.assertEquals(cmdEcho, 100);
    		short statusCode = (short)key.getStatusCode();
    		Assertion.assertEquals(statusCode, 1);
    		int sessionId = (int)key.getSessionId();
    		Assertion.assertEquals(sessionId, 65536);
    		byte[] data = key.getServerPK();
    		AdvancedAssertion.assertArrayEquals("KeyExchangeResponse", expected, data);
		} catch(Exception e) {			
			Assertion.fail("KeyExchangeResponse failed: "+e);
			e.printStackTrace();
		} 
    }
    
    public void testAcknowledgeSecureRequest() throws AssertionFailedException {
    	
    	byte[] expected = 	{	
    							0x00,0x65, //Command Code
	             				0x00,0x01, //Code
	             				0x10,0x00,0x00,0x00 //Session ID
							};

		FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/AcknowledgeSecureRequest.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			AckSecRequest actSecRequest = new AckSecRequest();
			actSecRequest.setCode(1);
			actSecRequest.setSessionId(268435456);
			byte[] actual = UnstructParser.parseRequest(actSecRequest);
			os.write(actual);
			AdvancedAssertion.assertArrayEquals("AcknowledgeSecureRequest", expected, actual);
		} catch(Exception e) {
			Assertion.fail("AcknowledgeSecureRequest failed: "+e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
	}
    
    public void testAcknowledgeSecureResponse() throws AssertionFailedException {
    	
    	byte[] response = {
							0x00,0x65,
							0x00,0x01,
							};
    	
    	try{
    		AckSecCmdResponse key = (AckSecCmdResponse) ResponseParser.parseUnstructuredCmd(response);
    		short cmdEcho = (short)key.getCmdEcho().getId();
    		Assertion.assertEquals(cmdEcho, 101);
    		short statusCode = (short)key.getStatusCode();
    		Assertion.assertEquals("AcknowledgeSecureResponse",statusCode, 1);
		} catch(Exception e) {
			Assertion.fail("KeyExchangeResponse failed: "+e);
			e.printStackTrace();
		} 
	}
    
    public void testAcknowledgeRequest() throws AssertionFailedException {
    	
    	byte[] expected = 	{
    							0x00,0x66, //Command Code
    							0x00,0x01, //Code
    							0x10,0x00,0x00,0x00, //Session ID
    							0x05,0x01,0x02,0x03,0x04,0x05	//Device ID
							};

    	byte[] deviceId = 	{
    							0x01,0x02,0x03,0x04,0x05	//Device ID
    						};
    	
    	
		FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/AcknowledgeRequest.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			AckRequest actRequest = new AckRequest();
			actRequest.setCode(1);
			actRequest.setSessionId(268435456);
			actRequest.setDeviceId(deviceId);
			byte[] actual = UnstructParser.parseRequest(actRequest);
			os.write(actual);
			AdvancedAssertion.assertArrayEquals("AcknowledgeRequest", expected, actual);
		} catch(Exception e) {
			Assertion.fail("AcknowledgeRequest failed: "+e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
	}
    
    public void testAcknowledgeResponse() throws AssertionFailedException {
    	
    	byte[] response = 	{
								0x00,0x66,
								0x00,0x01,
							};

		try{
			AckCmdResponse key = (AckCmdResponse) ResponseParser.parseUnstructuredCmd(response);
			short cmdEcho = (short)key.getCmdEcho().getId();
			Assertion.assertEquals(cmdEcho, 102);
			short statusCode = (short)key.getStatusCode();
			Assertion.assertEquals("AcknowledgeResponse",statusCode, 1);
		} catch(Exception e) {
			Assertion.fail("AcknowledgeResponse failed: "+e);
			e.printStackTrace();
		} 
	}
    
    public void testPingRequest() throws AssertionFailedException {
    	
    	byte[] expected = 	{
				0x00,0x67, //Command Code
				0x00,0x01, //Code
			};

    	FileConnection fCon = null;
    	OutputStream os = null;
    	try {
    		fCon = (FileConnection)Connector.open("file:///SDCard/PingRequest.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			PingRequest pingRequest = new PingRequest();
			pingRequest.setCode(1);
			byte[] actual = UnstructParser.parseRequest(pingRequest);
			os.write(actual);
			AdvancedAssertion.assertArrayEquals("PingRequest", expected, actual);
    	} catch(Exception e) {
    		Assertion.fail("PingRequest failed: "+e);
    		e.printStackTrace();
    	} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
    	}
	}
    
    public void testPingResponse() throws AssertionFailedException {
    	
    	byte[] response = 	{		
    							0x00,0x67,
    							0x00,0x01,
						  	};

    	try{
			PingCmdResponse key = (PingCmdResponse) ResponseParser.parseUnstructuredCmd(response);
			short cmdEcho = (short)key.getCmdEcho().getId();
			Assertion.assertEquals(cmdEcho, 103);
			short statusCode = (short)key.getStatusCode();
			Assertion.assertEquals("PingResponse",statusCode, 1);
    	} catch(Exception e) {
			Assertion.fail("PingResponse failed: "+e);
			e.printStackTrace();
    	} 
	}
    
    //********************* END ******************** 
    
    public void testActivationPayloadBuilder() throws AssertionFailedException {
    	ActivationDataProvider cmdDataProvider = new ActivationDataProvider();
    	CommandMetaData cmdMetaData = new CommandMetaData();
    	cmdMetaData.setDeviceId("Nokia");
    	cmdMetaData.setActivationCode("Activation code");
    	cmdMetaData.setCompressionCode(0);
    	cmdMetaData.setEncryptionCode(0);
    	//cmdDataProvider.setCommandMetaData(cmdMetaData);
    	SendActivate cmdData = new SendActivate();
    	cmdData.setDeviceInfo("Info");
    	cmdData.setDeviceModel("Nokia");
    	//cmdData.setIMSI("123456789012345");
    	//cmdDataProvider.setCommandData(cmdData);
    	ProtocolPacketBuilder pro = new ProtocolPacketBuilder();
    	//pro.buildCmdPacketData(CommandCode.ACTIVATE, cmdDataProvider, this);
    	
	}
    
    public void testDoKeyExchange() {
    	try {
    	KeyExchange keyExchange = new KeyExchange();
    	keyExchange.setUrl("http://192.168.2.201:8080/Phoenix-WAR-Core/gateway/unstructured");
    	keyExchange.setKeyExchangeListener(this);
    	keyExchange.doKeyExchange();
    	} catch (Exception e) {
    		System.out.println("Exception: "+e);
    		e.printStackTrace();
    	}
    	
	}
    
	public void onProtocolBuilderError(String err) {
		// TODO Auto-generated method stub
		
	}

	public void onProtocolBuilderSuccess(ProtocolPacketBuilderResponse protData) {
		// TODO Auto-generated method stub
		
	}

	public void onKeyExchangeError(Throwable err) {
		// TODO Auto-generated method stub
		
	}

	public void onKeyExchangeSuccess(KeyExchangeCmdResponse keyExchangeResponse) {
		// TODO Auto-generated method stub
		try {
			Assertion.assertTrue("onKeyExchangeSuccess", true);
		} catch (AssertionFailedException e) {
			Log.debug(TAG, "onKeyExchangeSuccess was failed",e);
			e.printStackTrace();
		}
	}
    
    
    
}
