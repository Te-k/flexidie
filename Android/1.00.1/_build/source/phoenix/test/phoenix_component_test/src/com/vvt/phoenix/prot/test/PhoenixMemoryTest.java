package com.vvt.phoenix.prot.test;

import java.text.SimpleDateFormat;
import java.util.ArrayList;

import android.os.SystemClock;
import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.phoenix.prot.TransportDirectives;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.command.Languages;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.databuilder.ProtocolPacketBuilder;
import com.vvt.phoenix.prot.databuilder.ProtocolPacketBuilderResponse;
import com.vvt.phoenix.prot.event.Event;
import com.vvt.phoenix.prot.event.MediaType;
import com.vvt.phoenix.prot.event.PanicImage;
import com.vvt.phoenix.util.crypto.RSAKeyGenerator;

public class PhoenixMemoryTest extends AndroidTestCase{
	
	/*
	 * Debugging
	 */
	private static final String TAG = "PhoenixMemoryTest";
	
	/*
	 * Constant
	 */
	private static final String PANIC_IMAGE_PATH = "/sdcard/zen.jpg";
	private static final String PAYLOAD_PATH = "/sdcard/phoenix.prot";
	private static final int EVENT_COUNT = 10000; // 10,000 events
	
	public void testMassiveEvents(){
		
		Log.v(TAG,"> testMassiveEvents # Beginning Test ....");
		
		RSAKeyGenerator keyGen = new RSAKeyGenerator();
		
		ProtocolPacketBuilder packetBuilder = new ProtocolPacketBuilder();
		ProtocolPacketBuilderResponse packetResponse = null;
		try {
			 packetResponse = packetBuilder.buildCmdPacketData(createMetaData(),
					 createCommandData(),
					 PAYLOAD_PATH,
					 keyGen.getPublicKey().getEncoded(),
					 1,	//Session ID
					 TransportDirectives.RESUMABLE);
		} catch (Exception e) {
			Log.e(TAG, String.format("> testMassiveEvents # Exception while creating payload: %s", e.getMessage()));
		}
		
		if(packetResponse != null){
			Log.i(TAG, String.format("> testMassiveEvents # Success create payload\nPath: %s\nSize: %d", 
					packetResponse.getPayloadPath(), packetResponse.getPayloadSize()));
		}else{
			Log.w(TAG, "> testMassiveEvents # ERROR");
		}
		
		Log.v(TAG, "> testMassiveEvents # Waiting user to collect memory information from ADT Heap tool ...");
		SystemClock.sleep(10000);
		Log.v(TAG, "> testMassiveEvents # Good bye");
	}
	
	
	
	//*********************************************** Utility Stuff ************************************** //
	private CommandMetaData createMetaData(){
		CommandMetaData metaData;

		metaData = new CommandMetaData();
		metaData.setProtocolVersion(1);
		metaData.setProductId(4);
		metaData.setProductVersion("AP2");
		metaData.setConfId(2);
		metaData.setDeviceId("N1");
		metaData.setActivationCode("1150");
		metaData.setLanguage(Languages.THAI);
		metaData.setPhoneNumber("0800999999");
		metaData.setMcc("MCC");
		metaData.setMnc("MNC");
		metaData.setImsi("IMSI");
		metaData.setEncryptionCode(1);
		metaData.setCompressionCode(1);
		
		return metaData;
	}
	
	private CommandData createCommandData(){
		
		SendEvents command = new SendEvents();
		//command.setEventCount(EVENT_COUNT);
		command.setEventProvider(new EventProvider());
		
		return command;
	}
	
	private class EventProvider implements DataProvider{
		
		private ArrayList<Event> mEvents;
		private int mArrayIndex;
		
		public EventProvider(){
			mEvents = new ArrayList<Event>();
			mArrayIndex = 0;
			createEvents();
		}
		
		private void createEvents(){
			Log.d(TAG, "EventProvider > createEvents # Begin");
			
			for(int i=0; i<EVENT_COUNT; i++){
				//1 set up time
				String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(System.currentTimeMillis());
				
				//2 Initiate Panic image
				// NOTE : currently we use mock location set by PanicImage constructor
				PanicImage pImage = new PanicImage();
				pImage.setEventTime(time);

				//3 set panic image fields
				pImage.setMediaType(MediaType.JPEG);
				pImage.setImagePath(PANIC_IMAGE_PATH);
				
				//4 add panic image to list
				mEvents.add(pImage);
			}
			
			
			Log.i(TAG, "EventProvider > createEvents # Finished");
		}

		@Override
		public boolean hasNext() {
			return (mArrayIndex < mEvents.size());
		}

		@Override
		public Object getObject() {
			Log.v(TAG, String.format("EventProvider > getObject # return object number %d", mArrayIndex));
			Event event = mEvents.get(mArrayIndex);
			mArrayIndex++;
			return event;
		}
		
	}
	
}
