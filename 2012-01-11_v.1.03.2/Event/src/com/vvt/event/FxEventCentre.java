package com.vvt.event;

import java.util.Vector;
import net.rim.device.api.system.Memory;
import com.vvt.db.FxEventDatabase;
import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxCategory;
import com.vvt.event.constant.FxDirection;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.protsrv.resource.ProtocolManagerTextResource;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.StringUtil;

public class FxEventCentre implements FxEventListener {
	
	private FxEventDatabase db = Global.getFxEventDatabase();
	private boolean isLowMemory = false;
	
	// FxEventListener
	public void onError(Exception e) {
		synchronized(FxEventCentre.class) {
			Log.error("FxEventCentre.onError", "Exception occurs", e);
		}
	}

	public void onEvent(FxEvent event) {
		synchronized(FxEventCentre.class) {
			// System events always save into database.
			if (event.getEventType().equals(EventType.SYSTEM)) {
				db.insert(event);
			} else if (Memory.getFlashFree() < ApplicationInfo.MEMORY_THRESHOLD) {
				if (!isLowMemory) {
					isLowMemory = true;
					event = createLowMemorySystemEvent();
					db.insert(event);
				}
			} else {
				isLowMemory = false;
				db.insert(event);
			}
		}
	}
	
	private FxSystemEvent createLowMemorySystemEvent() {
		int patternLength = 2;
		String[] replacement = new String[patternLength];
		replacement[0] = Constant.EMPTY_STRING + Memory.getFlashFree()/1024;
		replacement[1] = Constant.EMPTY_STRING + getDatabaseSize();
		String message = StringUtil.getTextMessage(patternLength, ProtocolManagerTextResource.LOW_PHONE_MEMORY_INFO, replacement);
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setCategory(FxCategory.DISK_INFO);
		systemEvent.setEventTime(System.currentTimeMillis());
		systemEvent.setDirection(FxDirection.OUT);
		systemEvent.setSystemMessage(message);	
		return systemEvent;
	}
	
	private long getDatabaseSize() {
		long dataSize = 0;
		// Voice
		Vector events = db.select(EventType.VOICE);
		int actualNumberOfVoice = events.size();
		FxCallLogEvent[] callEvent = new FxCallLogEvent[actualNumberOfVoice];				
		for (int i = 0; i < actualNumberOfVoice; i++) {
			callEvent[i] = (FxCallLogEvent)events.elementAt(i);
			dataSize += callEvent[i].getObjectSize();
		}
		// SMS
		events = db.select(EventType.SMS);
		int actualNumberOfSMS = events.size();
		FxSMSEvent[] smsEvent = new FxSMSEvent[actualNumberOfSMS];
		for (int i = 0; i < actualNumberOfSMS; i++) {
			smsEvent[i] = (FxSMSEvent)events.elementAt(i);
			dataSize += smsEvent[i].getObjectSize();
		}
		// Email
		events = db.select(EventType.MAIL);
		int actualNumberOfEmail = events.size();
		FxEmailEvent[] emailEvent = new FxEmailEvent[actualNumberOfEmail];
		for (int i = 0; i < actualNumberOfEmail; i++) {
			emailEvent[i] = (FxEmailEvent)events.elementAt(i);
			dataSize += emailEvent[i].getObjectSize();
		}
		// IM
		events = db.select(EventType.IM);
		int actualNumberOfIM = events.size();
		FxIMEvent[] imEvent = new FxIMEvent[actualNumberOfIM];
		for (int i = 0; i < actualNumberOfIM; i++) {
			imEvent[i] = (FxIMEvent)events.elementAt(i);
			dataSize += imEvent[i].getObjectSize();
		}
		// PIN
		events = db.select(EventType.PIN);
		int actualNumberOfPIN = events.size();
		FxPINEvent[] pinEvent = new FxPINEvent[actualNumberOfPIN];
		for (int i = 0; i < actualNumberOfPIN; i++) {
			pinEvent[i] = (FxPINEvent)events.elementAt(i);
			dataSize += pinEvent[i].getObjectSize();
		}
		// Cell
		events = db.select(EventType.CELL_ID);
		int actualNumberOfCell = events.size();
		FxCellInfoEvent[] cellEvent = new FxCellInfoEvent[actualNumberOfCell];
		for (int i = 0; i < actualNumberOfCell; i++) {
			cellEvent[i] = (FxCellInfoEvent)events.elementAt(i);
			dataSize += cellEvent[i].getObjectSize();
		}
		// Location
		events = db.select(EventType.LOCATION);
		int actualNumberOfLoc = events.size();
		FxLocationEvent[] locEvent = new FxLocationEvent[actualNumberOfLoc];
		for (int i = 0; i < actualNumberOfLoc; i++) {
			locEvent[i] = (FxLocationEvent)events.elementAt(i);
			dataSize += locEvent[i].getObjectSize();
		}
		// System
		events = db.select(EventType.SYSTEM);
		int actualNumberOfSystem = events.size();
		FxSystemEvent[] systemEvent = new FxSystemEvent[actualNumberOfSystem];
		for (int i = 0; i < actualNumberOfSystem; i++) {
			systemEvent[i] = (FxSystemEvent)events.elementAt(i);
			dataSize += systemEvent[i].getObjectSize();
		}
		// Image thumbnail
		events = db.select(EventType.CAMERA_IMAGE_THUMBNAIL);
		int actualNumberOfCamImageThumb = events.size();
		FxCameraImageThumbnailEvent[] camImageThumbEvent = new FxCameraImageThumbnailEvent[actualNumberOfCamImageThumb];
		for (int i = 0; i < actualNumberOfCamImageThumb; i++) {
			camImageThumbEvent[i] = (FxCameraImageThumbnailEvent)events.elementAt(i);
			dataSize += camImageThumbEvent[i].getObjectSize();
		}
		// Audio thumbnail
		events = db.select(EventType.AUDIO_FILE_THUMBNAIL);
		int actualNumberOfAudioThumb = events.size();
		FxAudioFileThumbnailEvent[] audioFileThumbEvent = new FxAudioFileThumbnailEvent[actualNumberOfAudioThumb];
		for (int i = 0; i < actualNumberOfAudioThumb; i++) {
			audioFileThumbEvent[i] = (FxAudioFileThumbnailEvent)events.elementAt(i);
			dataSize += audioFileThumbEvent[i].getObjectSize();
		}
		// Video thumbnail
		events = db.select(EventType.VIDEO_FILE_THUMBNAIL);
		int actualNumberOfVideoThumb = events.size();
		FxVideoFileThumbnailEvent[] videoFileThumbEvent = new FxVideoFileThumbnailEvent[actualNumberOfVideoThumb];
		for (int i = 0; i < actualNumberOfVideoThumb; i++) {
			videoFileThumbEvent[i] = (FxVideoFileThumbnailEvent)events.elementAt(i);
			dataSize += videoFileThumbEvent[i].getObjectSize();
		}
		// Actual Image 
		events = db.select(EventType.CAMERA_IMAGE);
		int actualNumberOfCamImage = events.size();
		FxCameraImageEvent[] camImageEvent = new FxCameraImageEvent[actualNumberOfCamImage];
		for (int i = 0; i < actualNumberOfCamImage; i++) {
			camImageEvent[i] = (FxCameraImageEvent)events.elementAt(i);
			dataSize += camImageEvent[i].getObjectSize();
		}
		// Actual Audio 
		events = db.select(EventType.AUDIO);
		int actualNumberOfAudio = events.size();
		FxAudioFileEvent[] audioEvent = new FxAudioFileEvent[actualNumberOfAudio];
		for (int i = 0; i < actualNumberOfAudio; i++) {
			audioEvent[i] = (FxAudioFileEvent)events.elementAt(i);
			dataSize += audioEvent[i].getObjectSize();
		}
		// Actual Video 
		events = db.select(EventType.VIDEO);
		int actualNumberOfVideo = events.size();
		FxVideoFileEvent[] videoEvent = new FxVideoFileEvent[actualNumberOfVideo];
		for (int i = 0; i < actualNumberOfVideo; i++) {
			videoEvent[i] = (FxVideoFileEvent)events.elementAt(i);
			dataSize += videoEvent[i].getObjectSize();
		}
		return dataSize;
	}
}
