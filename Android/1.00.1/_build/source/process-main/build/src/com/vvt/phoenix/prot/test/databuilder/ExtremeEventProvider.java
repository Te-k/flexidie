package com.vvt.phoenix.prot.test.databuilder;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import android.util.Log;

import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.event.Attachment;
import com.vvt.phoenix.prot.event.CallLogEvent;
import com.vvt.phoenix.prot.event.EmailEvent;
import com.vvt.phoenix.prot.event.Event;
import com.vvt.phoenix.prot.event.EventDirection;
import com.vvt.phoenix.prot.event.Recipient;
import com.vvt.phoenix.prot.event.RecipientType;
import com.vvt.phoenix.prot.event.SMSEvent;

public class ExtremeEventProvider implements DataProvider{

	//Debugging
	private static final String TAG = "ExtremeEventProvider";
	private static final boolean DEBUG = true;

	//Constants
	private static final int EVENTS_MAKING_COUNT = 100;
	private static final int VOICE = 0;
	private static final int SMS = 1;
	private static final int GPS = 2;
	private static final int EMAIL = 3;
	
	//Members
	private int mCount;
	private int mChooser;
	
	public int getEventCount(){
		if(DEBUG){
			Log.v(TAG, "Event Count: "+EVENTS_MAKING_COUNT);
		}
		return EVENTS_MAKING_COUNT;
	}

	@Override
	public boolean hasNext() {
		return (mCount < EVENTS_MAKING_COUNT);
	}
	
	@Override
	public Object getObject() {
		Event event = getEvent(mChooser);
		mChooser = (mChooser == EMAIL)? VOICE : mChooser+1 ;
		mCount++;

		if(DEBUG){
			Log.v(TAG, "mCount new: "+mCount);
		}
		
		return event;
	}

	
	
	private Event getEvent(int point){
		//TODO
		Event event = null;
		switch(point){
			case VOICE 	: 	event = genVoiceEvent();break;
			case SMS 	: 	event = genSMSEvent();break;	
			//case GPS 	: 	event = genGpsEvent();break;
			case EMAIL 	:	event = genEMailEvent();break;
		}
		//Event event = genSMSEvent();
		
		return event;
	}
	
	private CallLogEvent genVoiceEvent(){
		if(DEBUG){
			Log.v(TAG, "Generate Voice Event");
		}
		CallLogEvent ve = new CallLogEvent();
		ve.setEventTime("2010-10-28 19:10:15");
		ve.setDirection(EventDirection.IN);
		ve.setDuration(3);
		ve.setNumber("0866990909");
		ve.setContactName("Mr.Bean");
		
		return ve;
	}
	
	private SMSEvent genSMSEvent(){
		if(DEBUG){
			Log.v(TAG, "Generate SMS Event");
		}
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

		return se;
	}
	
	/*private GPSEvent genGpsEvent(){
		if(DEBUG){
			Log.v(TAG, "Generate GPS Event");
		}
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

		return ge;
	}
	*/
	private EmailEvent genEMailEvent(){
		if(DEBUG){
			Log.v(TAG, "Generate EMail Event");
		}
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

		return eme;
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
