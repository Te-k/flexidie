package com.vvt.phoenix.prot.test.databuilder;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;

import android.util.Log;

import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.event.CallLogEvent;
import com.vvt.phoenix.prot.event.Event;
import com.vvt.phoenix.prot.event.EventDirection;
import com.vvt.phoenix.prot.event.Recipient;
import com.vvt.phoenix.prot.event.RecipientType;
import com.vvt.phoenix.prot.event.SMSEvent;

public class EventProvider implements DataProvider{
	
	//Debugging
	private static final String TAG = "EventProvider";
	private static final boolean DEBUG = true;

	//Members
	private ArrayList<Event> mEventList;
	private int mCount;
	
	//Constants
	private static final int EVENTS_MAKING_ROUND_COUNT = 1;
	
	@Override
	public Object getObject() {
		/*mCount++;
		return mEventList.get(mCount);*/
		Event event = mEventList.get(mCount);
		mCount++;
		return event;
	}

	@Override
	public boolean hasNext() {
		return (mCount < mEventList.size());
	}

	/**
	 * Constructor
	 */
	public EventProvider(){
		
		addMoreAndMoreEvents();
		
		/*
		
		HttpBatteryLifeDebugEvent hbd = new HttpBatteryLifeDebugEvent();
		hbd.setEventTime("2010-10-28 19:19:19");
		hbd.setBatteryBefore("95%");
		hbd.setBatteryAfter("95%");
		hbd.setStartTime("2010-10-28 20:20:21");
		hbd.setEndTime("2010-10-28 20:21:21");
		hbd.setPayloadSize("55");
		mEventList.add(hbd);
		
		GpsBatteryLifeDebugEvent gbd = new GpsBatteryLifeDebugEvent();
		gbd.setEventTime("2010-10-28 20:20:20");
		gbd.setBatteryBefore("50%");
		gbd.setBatteryAfter("47%");
		gbd.setStartTime("2010-10-28 20:05:21");
		gbd.setEndTime("2010-10-28 20:10:21");
		mEventList.add(gbd);
		*/
		
	}
	
	private void addMoreAndMoreEvents(){
		mEventList = new ArrayList<Event>();
		
		for(int i=0; i<EVENTS_MAKING_ROUND_COUNT; i++){
			CallLogEvent ve = new CallLogEvent();
			ve.setEventTime("2010-10-28 19:10:15");
			ve.setDirection(EventDirection.IN);
			ve.setDuration(3);
			ve.setNumber("0866990909");
			ve.setContactName("Mr.Bean");
			mEventList.add(ve);
			
			SMSEvent se = new SMSEvent();
			//se.setEventId(2);
			se.setEventTime("2010-10-28 19:15:09");
			se.setDirection(EventDirection.OUT);
			se.setSenderNumber("081-1112233");
			se.setContactName("Mr.Android");
			Recipient r = new Recipient();
			r.setRecipientType(RecipientType.TO);
			r.setRecipient("Mr.PDU");
			r.setContactName("BB-Boy");
			se.addRecipient(r);		
			se.setSMSData("Hi Dude");
			//se.setSMSData(readLineFromFile());
			mEventList.add(se);
			
			/*
			GPSEvent ge = new GPSEvent();
			ge.setEventTime("2010-10-28 19:20:21");
			ge.setLongitude(100.2f);
			ge.setLatitude(13.5f);
			ge.setSpeed(100f);
			ge.setHeading(2);
			ge.setAltitude(1);
			ge.setProvider(GPSProvider.INTERGRATED_GPS);
			ge.setHorizontalAccuracy(3);
			ge.setVerticalAccuracy(4);
			ge.setHeadingAccuracy(2.1f);
			ge.setSpeedAccuracy(5);	
			mEventList.add(ge);
			
			EmailEvent eme = new EmailEvent();
			eme.setEventTime("2010-10-28 19:20:21");
			eme.setDirection(EventDirection.OUT);
			eme.setSenderEMail("andrew@vvt.info");
			eme.setSenderContactName("Andrew");
			Recipient r1 = new Recipient();
			r1.setRecipientType(RecipientType.TO);
			r1.setRecipient("droiddev@gg.com");
			r1.setContactName("Droid Dev");
			eme.addRecipient(r1);
			Recipient r2 = new Recipient();
			r2.setRecipientType(RecipientType.CC);
			r2.setRecipient("htc@htc.com");
			r2.setContactName("HTC Support");
			eme.addRecipient(r2);
			eme.setSubject("Hi Android Guys");
			Attachment att = new Attachment();
			att.setAttachemntFullName("Droid Attachment");
			att.setAttachmentData("onCreate is coming".getBytes());
			eme.addAttachment(att);
			eme.setEMailBody("This EMail will be destroy in 5 seconds...");
			mEventList.add(eme);*/
		}
		
		
	}
	
	public int getEventCount(){
		return mEventList.size();
	}
	
	private String readLineFromFile(){
		File f = new File("/sdcard/prot/thaiword.txt");
		
		int fLen = (int) f.length();
		byte[] buf = new byte[fLen];
		try{
			FileInputStream fIn = new FileInputStream(f);
			fIn.read(buf);
			fIn.close();
		}catch(IOException e){
			return "null";
		}
		
		String res = new String(buf);
		
		if(DEBUG){
			Log.v(TAG, "buf len: "+buf.length);
			Log.v(TAG, "res: "+res);
			Log.v(TAG, "res len: "+res.length());
		}
		
		/*FileReader fIn = null;
		try {
			fIn = new FileReader(f);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return "FileNotFound";
		}
		BufferedReader reader = new BufferedReader(fIn);
		String res = null;
		try {
			res = reader.readLine();
		} catch (IOException e) {
			return "demo";
		}*/
				
		return res.trim();
	}
}
