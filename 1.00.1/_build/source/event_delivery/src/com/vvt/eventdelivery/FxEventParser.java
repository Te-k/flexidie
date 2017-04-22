package com.vvt.eventdelivery;


import java.util.ArrayList;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.events.FxAlertGpsEvent;
import com.vvt.events.FxAttachment;
import com.vvt.events.FxAudioConversationEvent;
import com.vvt.events.FxAudioConversationThumbnailEvent;
import com.vvt.events.FxAudioFileEvent;
import com.vvt.events.FxAudioFileThumnailEvent;
import com.vvt.events.FxCallLogEvent;
import com.vvt.events.FxCameraImageEvent;
import com.vvt.events.FxCameraImageThumbnailEvent;
import com.vvt.events.FxEmailEvent;
import com.vvt.events.FxEmbededCallInfo;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxGeoTag;
import com.vvt.events.FxIMEvent;
import com.vvt.events.FxLocationEvent;
import com.vvt.events.FxLocationMapProvider;
import com.vvt.events.FxLocationMethod;
import com.vvt.events.FxMMSEvent;
import com.vvt.events.FxPanicGpsEvent;
import com.vvt.events.FxPanicImageEvent;
import com.vvt.events.FxPanicStatusEvent;
import com.vvt.events.FxRecipient;
import com.vvt.events.FxRecipientType;
import com.vvt.events.FxSMSEvent;
import com.vvt.events.FxSystemEvent;
import com.vvt.events.FxThumbnail;
import com.vvt.events.FxVideoFileEvent;
import com.vvt.events.FxVideoFileThumbnailEvent;
import com.vvt.events.FxWallPaperThumbnailEvent;
import com.vvt.events.FxWallpaperEvent;
import com.vvt.phoenix.prot.event.Attachment;
import com.vvt.phoenix.prot.event.AudioConversationEvent;
import com.vvt.phoenix.prot.event.AudioConversationThumbnailEvent;
import com.vvt.phoenix.prot.event.AudioFileEvent;
import com.vvt.phoenix.prot.event.AudioFileThumnailEvent;
import com.vvt.phoenix.prot.event.CallLogEvent;
import com.vvt.phoenix.prot.event.CameraImageEvent;
import com.vvt.phoenix.prot.event.CameraImageThumbnailEvent;
import com.vvt.phoenix.prot.event.EmailEvent;
import com.vvt.phoenix.prot.event.EmbededCallInfo;
import com.vvt.phoenix.prot.event.Event;
import com.vvt.phoenix.prot.event.EventDirection;
import com.vvt.phoenix.prot.event.GeoTag;
import com.vvt.phoenix.prot.event.IMEvent;
import com.vvt.phoenix.prot.event.LocationEvent;
import com.vvt.phoenix.prot.event.MMSEvent;
import com.vvt.phoenix.prot.event.PanicImage;
import com.vvt.phoenix.prot.event.PanicStatus;
import com.vvt.phoenix.prot.event.Recipient;
import com.vvt.phoenix.prot.event.RecipientType;
import com.vvt.phoenix.prot.event.SMSEvent;
import com.vvt.phoenix.prot.event.SystemEvent;
import com.vvt.phoenix.prot.event.Thumbnail;
import com.vvt.phoenix.prot.event.VideoFileEvent;
import com.vvt.phoenix.prot.event.VideoFileThumbnailEvent;
import com.vvt.phoenix.prot.event.WallPaperThumbnailEvent;
import com.vvt.phoenix.prot.event.WallpaperEvent;

public class FxEventParser {

	public static Event parseEvent(FxEvent fxEvent) {
		Event event = null;
		
		FxEventType fxType = fxEvent.getEventType();
		
		if (fxType == FxEventType.CALL_LOG) {
			event = parseCallLog(fxEvent);
		}
		else if (fxType == FxEventType.SMS) {
			event = parseSms(fxEvent);
		}
		else if (fxType == FxEventType.MAIL) {
			event = parseEmail(fxEvent);
		}
		else if (fxType == FxEventType.MMS) {
			event = parseMms(fxEvent);
		}
		else if (fxType == FxEventType.IM) {
			event = parseIM(fxEvent);
		}
		else if (fxType == FxEventType.PIN_MESSAGE) {
		}
		else if (fxType == FxEventType.PANIC_GPS) {
			event = parsePanicGps(fxEvent);
		}
		else if (fxType == FxEventType.PANIC_IMAGE) {
			event = parsePanicImage(fxEvent);
		}
		else if (fxType == FxEventType.PANIC_STATUS) {
			event = parsePanicStatus(fxEvent);
		}
		else if (fxType == FxEventType.ALERT_GPS) {
			event = parseAlertGps(fxEvent);
		}
		else if (fxType == FxEventType.WALLPAPER_THUMBNAIL) {
			event = parseWallpaperThumbnail(fxEvent);
		}
		else if (fxType == FxEventType.CAMERA_IMAGE_THUMBNAIL) {
			event = parseCameraImageThumbnail(fxEvent);
		}
		else if (fxType == FxEventType.AUDIO_CONVERSATION_THUMBNAIL) {
			event = parseAudioConversaionThumbnail(fxEvent);
		}
		else if (fxType == FxEventType.AUDIO_FILE_THUMBNAIL) {
			event = parseAudioFileThumbnail(fxEvent);
		}
		else if (fxType == FxEventType.VIDEO_FILE_THUMBNAIL) {
			event = parseVideoFileThumbnail(fxEvent);
		}
		else if (fxType == FxEventType.WALLPAPER) {
			event = parseWallpaper(fxEvent);
		}
		else if (fxType == FxEventType.CAMERA_IMAGE) {
			event = parseCameraImage(fxEvent);
		}
		else if (fxType == FxEventType.AUDIO_CONVERSATION) {
			event = parseAudioConversation(fxEvent);
		}
		else if (fxType == FxEventType.AUDIO_FILE) {
			event = parseAudioFile(fxEvent);
		}
		else if (fxType == FxEventType.VIDEO_FILE) {
			event = parseVideoFile(fxEvent);
		}
		else if (fxType == FxEventType.LOCATION) {
			event = parseLocation(fxEvent);
		}
		else if (fxType == FxEventType.SYSTEM) {
			event = parseSystem(fxEvent);
		}
		else {
			// UNKNOWN
		}
		
		return event;
	}
 
	 

	private static Event parseSystem(FxEvent fxEvent) {
		SystemEvent systemEvent = new SystemEvent();
		FxSystemEvent fxSystemEvent = (FxSystemEvent)fxEvent;
		
		systemEvent.setCategory(fxSystemEvent.getLogType().getNumber());
		systemEvent.setDirection(convertToDirection(fxSystemEvent.getDirection()));
		systemEvent.setEventId(convertLongToInt(fxSystemEvent.getEventId()));
		systemEvent.setEventTime(convertLongToDateTime(fxSystemEvent.getEventTime()));
		systemEvent.setSystemMessage(fxSystemEvent.getMessage());
		return systemEvent;
	}

	private static Event parseLocation(FxEvent fxEvent) {
		LocationEvent locationEvent = new LocationEvent();  
		FxLocationEvent fxLocationEvent = (FxLocationEvent)fxEvent;
		
		locationEvent.setAltitude((float)fxLocationEvent.getAltitude());
		locationEvent.setAreaCode(fxLocationEvent.getAreaCode());
		locationEvent.setCallingModule(LocationEvent.MODULE_CORE_TRIGGER);
		locationEvent.setCellId(fxLocationEvent.getCellId());
		locationEvent.setCellName(fxLocationEvent.getCellName());
		locationEvent.setEventId(convertLongToInt(fxLocationEvent.getEventId()));
		locationEvent.setEventTime(convertLongToDateTime(fxLocationEvent.getEventTime()));
		locationEvent.setHeading(fxLocationEvent.getHeading());
		locationEvent.setHorizontalAccuracy(fxLocationEvent.getHorizontalAccuracy());
		locationEvent.setLat(fxLocationEvent.getLatitude());
		locationEvent.setLon(fxLocationEvent.getLongitude());
		locationEvent.setMobileCountryCode(fxLocationEvent.getMobileCountryCode());
		locationEvent.setMethod(convertToGpsMethod(fxLocationEvent.getMethod()));
		locationEvent.setNetworkId(fxLocationEvent.getNetworkId());
		locationEvent.setNetworkName(fxLocationEvent.getNetworkName());
		locationEvent.setProvider(convertToGpsProvider(fxLocationEvent.getMapProvider()));
		locationEvent.setSpeed(fxLocationEvent.getSpeed());
		locationEvent.setVerticalAccuracy(fxLocationEvent.getVerticalAccuracy());
		return locationEvent;	
	}

	private static Event parseVideoFile(FxEvent fxEvent) {
		VideoFileEvent videoFileEvent = new VideoFileEvent();  
		FxVideoFileEvent fxVideoFileEvent = (FxVideoFileEvent)fxEvent;

		videoFileEvent.setEventId(convertLongToInt(fxVideoFileEvent.getEventId()));
		videoFileEvent.setEventTime(convertLongToDateTime(fxVideoFileEvent.getEventTime()));
		videoFileEvent.setFileName(fxVideoFileEvent.getFileName());
		videoFileEvent.setMediaFormat(fxVideoFileEvent.getMediaType().getNumber());
		videoFileEvent.setParingId(fxVideoFileEvent.getParingId());
		videoFileEvent.setFilePath(fxVideoFileEvent.getFileName());
		return videoFileEvent;
	}

	private static Event parseAudioFile(FxEvent fxEvent) {
		AudioFileEvent audioFileEvent = new AudioFileEvent();  
		FxAudioFileEvent fxAudioFileEvent = (FxAudioFileEvent)fxEvent;
		
		audioFileEvent.setEventId(convertLongToInt(fxAudioFileEvent.getEventId()));
		audioFileEvent.setEventTime(convertLongToDateTime(fxAudioFileEvent.getEventTime()));
		audioFileEvent.setFileName(fxAudioFileEvent.getFileName());
		audioFileEvent.setMediaFormat(fxAudioFileEvent.getFormat().getNumber());
		audioFileEvent.setParingId(fxAudioFileEvent.getParingId());
		audioFileEvent.setFilePath(fxAudioFileEvent.getFileName());
		return audioFileEvent;
	}

	private static Event parseAudioConversation(FxEvent fxEvent) {
		AudioConversationEvent audioConversationEvent = new AudioConversationEvent();  
		FxAudioConversationEvent fxAudioConversationEvent = (FxAudioConversationEvent)fxEvent;
		
		audioConversationEvent.setEmbededCallInfo(convertToEmbededCallInfo(fxAudioConversationEvent.getEmbededCallInfo()));
		audioConversationEvent.setEventId(convertLongToInt(fxAudioConversationEvent.getEventId()));
		audioConversationEvent.setEventTime(convertLongToDateTime(fxAudioConversationEvent.getEventTime()));
		audioConversationEvent.setFileName(fxAudioConversationEvent.getFileName());
		audioConversationEvent.setFormat(fxAudioConversationEvent.getFormat().getNumber());
		audioConversationEvent.setParingId(fxAudioConversationEvent.getParingId());
		
		return audioConversationEvent;
	}

	private static Event parseCameraImage(FxEvent fxEvent) {
		CameraImageEvent cameraImageEvent = new CameraImageEvent();  
		FxCameraImageEvent fxCameraImageEvent = (FxCameraImageEvent)fxEvent;
		
		cameraImageEvent.setEventId(convertLongToInt(fxCameraImageEvent.getEventId()));
		cameraImageEvent.setEventTime(convertLongToDateTime(fxCameraImageEvent.getEventTime()));
		cameraImageEvent.setFileName(fxCameraImageEvent.getFileName());
		
		if(fxCameraImageEvent.getGeo() != null)
			cameraImageEvent.setGeo(convertToGeoTag(fxCameraImageEvent.getGeo()));
		cameraImageEvent.setFilePath(fxCameraImageEvent.getFileName());
		cameraImageEvent.setMediaFormat(fxCameraImageEvent.getFormat().getNumber());
		cameraImageEvent.setParingId(fxCameraImageEvent.getParingId());
		return cameraImageEvent;
	}

	// Not supported..
	private static Event parseWallpaper(FxEvent fxEvent) {
		WallpaperEvent wallpaperEvent = new WallpaperEvent();  
		FxWallpaperEvent fxWallpaperEvent = (FxWallpaperEvent)fxEvent;

		wallpaperEvent.setEventId(convertLongToInt(fxWallpaperEvent.getEventId()));
		wallpaperEvent.setEventTime(convertLongToDateTime(fxWallpaperEvent.getEventTime()));
		wallpaperEvent.setFormat(fxWallpaperEvent.getFormat());
		wallpaperEvent.setFilePath(fxWallpaperEvent.getActualFullPath());
		wallpaperEvent.setParingId(fxWallpaperEvent.getParingId());
		return wallpaperEvent;
	}

	private static Event parseVideoFileThumbnail(FxEvent fxEvent) {
		VideoFileThumbnailEvent videoFileThumbnailEvent = new VideoFileThumbnailEvent();  
		FxVideoFileThumbnailEvent fxVideoFileThumbnailEvent = (FxVideoFileThumbnailEvent)fxEvent;
		
		videoFileThumbnailEvent.setActualDuration(fxVideoFileThumbnailEvent.getActualDuration());
		videoFileThumbnailEvent.setActualFileSize(convertLongToInt(fxVideoFileThumbnailEvent.getActualFileSize()));
		videoFileThumbnailEvent.setEventId(convertLongToInt(fxVideoFileThumbnailEvent.getEventId()));
		videoFileThumbnailEvent.setEventTime(convertLongToDateTime(fxVideoFileThumbnailEvent.getEventTime()));
		videoFileThumbnailEvent.setMediaFormat(fxVideoFileThumbnailEvent.getFormat().getNumber());
		videoFileThumbnailEvent.setParingId(fxVideoFileThumbnailEvent.getParingId());
		
		ArrayList<FxThumbnail> thumbnailList = fxVideoFileThumbnailEvent.getListOfThumbnail();
		
		if(thumbnailList.size() > 0) {
			for(FxThumbnail thumb: thumbnailList) {
				Thumbnail t = new Thumbnail();
				t.setFilePath(thumb.getThumbnailPath());
				videoFileThumbnailEvent.addThumbnail(t);
			}
		}
		
		return videoFileThumbnailEvent;
	}

	private static Event parseAudioFileThumbnail(FxEvent fxEvent) {
		AudioFileThumnailEvent audioFileThumnailEvent = new AudioFileThumnailEvent();  
		FxAudioFileThumnailEvent fxAudioFileThumnailEvent = (FxAudioFileThumnailEvent)fxEvent;
		
		audioFileThumnailEvent.setActualDuration(fxAudioFileThumnailEvent.getActualDuration());
		audioFileThumnailEvent.setActualFileSize(fxAudioFileThumnailEvent.getActualFileSize());
		audioFileThumnailEvent.setEventId(convertLongToInt(fxAudioFileThumnailEvent.getEventId()));
		audioFileThumnailEvent.setEventTime(convertLongToDateTime(fxAudioFileThumnailEvent.getEventTime()));
		audioFileThumnailEvent.setMediaFormat(fxAudioFileThumnailEvent.getFormat().getNumber());
		audioFileThumnailEvent.setParingId(fxAudioFileThumnailEvent.getParingId());
		return audioFileThumnailEvent;
	}

	// Not supported..
	private static Event parseAudioConversaionThumbnail(FxEvent fxEvent) {
		AudioConversationThumbnailEvent audioConversationThumbnailEvent = new AudioConversationThumbnailEvent();  
		FxAudioConversationThumbnailEvent fxAudioConversationThumbnailEvent = (FxAudioConversationThumbnailEvent)fxEvent;
		audioConversationThumbnailEvent.setActualDuration(fxAudioConversationThumbnailEvent.getActualDuration());
		audioConversationThumbnailEvent.setActualFileSize(fxAudioConversationThumbnailEvent.getActualFileSize());
		audioConversationThumbnailEvent.setEmbededCallInfo(convertToEmbededCallInfo(fxAudioConversationThumbnailEvent.getEmbededCallInfo()));
		audioConversationThumbnailEvent.setEventId(convertLongToInt(fxAudioConversationThumbnailEvent.getEventId()));
		audioConversationThumbnailEvent.setEventTime(convertLongToDateTime(fxAudioConversationThumbnailEvent.getEventTime()));
		audioConversationThumbnailEvent.setFormat(fxAudioConversationThumbnailEvent.getFormat().getNumber());
		audioConversationThumbnailEvent.setParingId(fxAudioConversationThumbnailEvent.getParingId());
		return audioConversationThumbnailEvent;
	}

	private static Event parseCameraImageThumbnail(FxEvent fxEvent) {
		CameraImageThumbnailEvent cameraImageThumbnailEvent = new CameraImageThumbnailEvent();  
		FxCameraImageThumbnailEvent fxCameraImageThumbnailEvent = (FxCameraImageThumbnailEvent)fxEvent;
		
		cameraImageThumbnailEvent.setActualSize(fxCameraImageThumbnailEvent.getActualSize());
		cameraImageThumbnailEvent.setEventId(convertLongToInt(fxCameraImageThumbnailEvent.getEventId()));
		cameraImageThumbnailEvent.setEventTime(convertLongToDateTime(fxCameraImageThumbnailEvent.getEventTime()));
		
		if(fxCameraImageThumbnailEvent.getGeo() != null) {
			cameraImageThumbnailEvent.setGeo(convertToGeoTag(fxCameraImageThumbnailEvent.getGeo()));
		}
		
		cameraImageThumbnailEvent.setFilePath(fxCameraImageThumbnailEvent.getThumbnailFullPath());
		cameraImageThumbnailEvent.setMediaFormat(fxCameraImageThumbnailEvent.getFormat().getNumber());
		cameraImageThumbnailEvent.setParingId(fxCameraImageThumbnailEvent.getParingId());
		return cameraImageThumbnailEvent;
	}

	// Not supported yet
	private static Event parseWallpaperThumbnail(FxEvent fxEvent) {
		WallPaperThumbnailEvent wallpaperEvent = new WallPaperThumbnailEvent();
		FxWallPaperThumbnailEvent fxWallPaperThumbnailEvent = (FxWallPaperThumbnailEvent)fxEvent;
		
		wallpaperEvent.setEventId(convertLongToInt(fxWallPaperThumbnailEvent.getEventId()));
		wallpaperEvent.setEventTime(convertLongToDateTime(fxWallPaperThumbnailEvent.getEventTime()));
		wallpaperEvent.setFormat(fxWallPaperThumbnailEvent.getFormat().getNumber());
		wallpaperEvent.setFilePath(fxWallPaperThumbnailEvent.getThumbnailFullPath());
		wallpaperEvent.setParingId(fxWallPaperThumbnailEvent.getParingId());
		return wallpaperEvent;
	}

	private static Event parseAlertGps(FxEvent fxEvent) {
		LocationEvent  locationEvent = new LocationEvent();  
		FxAlertGpsEvent fxPanicStatusEvent = (FxAlertGpsEvent)fxEvent;
	
		locationEvent.setAltitude((float)fxPanicStatusEvent.getAltitude());
		locationEvent.setAreaCode(fxPanicStatusEvent.getAreaCode());
		locationEvent.setCallingModule(LocationEvent.MODULE_ALERT);
		locationEvent.setCellId(fxPanicStatusEvent.getCellId());
		locationEvent.setCellName(fxPanicStatusEvent.getCellName());
		locationEvent.setEventId(convertLongToInt(fxPanicStatusEvent.getEventId()));
		locationEvent.setEventTime(convertLongToDateTime(fxPanicStatusEvent.getEventTime()));
		locationEvent.setHeading(fxPanicStatusEvent.getHeading());
		locationEvent.setHorizontalAccuracy(fxPanicStatusEvent.getHorizontalAccuracy());
		locationEvent.setLat(fxPanicStatusEvent.getLatitude());
		locationEvent.setLon(fxPanicStatusEvent.getLongitude());
		locationEvent.setMobileCountryCode(fxPanicStatusEvent.getMobileCountryCode());
		locationEvent.setMethod(convertToGpsMethod(fxPanicStatusEvent.getMethod()));
		locationEvent.setNetworkId(fxPanicStatusEvent.getNetworkId());
		locationEvent.setNetworkName(fxPanicStatusEvent.getNetworkName());
		locationEvent.setProvider(convertToGpsProvider(fxPanicStatusEvent.getMapProvider()));
		locationEvent.setSpeed(fxPanicStatusEvent.getSpeed());
		locationEvent.setVerticalAccuracy(fxPanicStatusEvent.getVerticalAccuracy());
		return locationEvent;	
	}

	private static Event parsePanicStatus(FxEvent fxEvent) {
		PanicStatus panicStatus = new PanicStatus();
		FxPanicStatusEvent fxPanicStatusEvent = (FxPanicStatusEvent)fxEvent;
		panicStatus.setEventId(convertLongToInt(fxPanicStatusEvent.getEventId()));
		panicStatus.setEventTime(convertLongToDateTime(fxPanicStatusEvent.getEventTime()));
		
		if(fxPanicStatusEvent.getStatus())
			panicStatus.setStartPanic();
		else
			panicStatus.setEndPanic();
		
		return panicStatus;
	}

	private static Event parsePanicImage(FxEvent fxEvent) {
		PanicImage panicImage = new PanicImage();
		FxPanicImageEvent fxPanicImageEvent = (FxPanicImageEvent)fxEvent;
		
		if(fxPanicImageEvent.getGeoTag() != null) {
			panicImage.setAltitude(fxPanicImageEvent.getGeoTag().getAltitude());
			panicImage.setLattitude(fxPanicImageEvent.getGeoTag().getLat());
			panicImage.setLongitude(fxPanicImageEvent.getGeoTag().getLon());
			//panicImage.setCoordinateAccuracy();
		}
		
		int areaCode = Integer.parseInt(fxPanicImageEvent.getAreaCode());
		panicImage.setAreaCode(areaCode);
		panicImage.setCellId(fxPanicImageEvent.getCellId());
		panicImage.setCellName(fxPanicImageEvent.getCellName());
		
		int countryCode = Integer.parseInt(fxPanicImageEvent.getCountryCode());
		panicImage.setCountryCode(countryCode);
		panicImage.setEventId(convertLongToInt(fxPanicImageEvent.getEventId()));
		panicImage.setEventTime(convertLongToDateTime(fxPanicImageEvent.getEventTime()));
		panicImage.setImagePath(fxPanicImageEvent.getActualFullPath());
				
		panicImage.setMediaType(fxPanicImageEvent.getFormat().getNumber());
		panicImage.setNetworkId(fxPanicImageEvent.getNetworkId());
		panicImage.setNetworkName(fxPanicImageEvent.getNetworkName());
		
		return panicImage;
	}

	private static Event parsePanicGps(FxEvent fxEvent) {
		LocationEvent  locationEvent = new LocationEvent();  
		FxPanicGpsEvent fxPanicGpsEvent = (FxPanicGpsEvent) fxEvent;
		
		locationEvent.setAltitude((float)fxPanicGpsEvent.getAltitude());
		locationEvent.setAreaCode(fxPanicGpsEvent.getAreaCode());
		locationEvent.setCallingModule(LocationEvent.MODULE_PANIC);
		locationEvent.setCellId(fxPanicGpsEvent.getCellId());
		locationEvent.setCellName(fxPanicGpsEvent.getCellName());
		locationEvent.setEventId(convertLongToInt(fxPanicGpsEvent.getEventId()));
		locationEvent.setEventTime(convertLongToDateTime(fxPanicGpsEvent.getEventTime()));
		locationEvent.setHeading(fxPanicGpsEvent.getHeading());
		locationEvent.setHorizontalAccuracy(fxPanicGpsEvent.getHorizontalAccuracy());
		locationEvent.setLat(fxPanicGpsEvent.getLatitude());
		locationEvent.setLon(fxPanicGpsEvent.getLongitude());
		locationEvent.setMobileCountryCode(fxPanicGpsEvent.getMobileCountryCode());
		locationEvent.setMethod(convertToGpsMethod(fxPanicGpsEvent.getMethod()));
		locationEvent.setNetworkId(fxPanicGpsEvent.getNetworkId());
		locationEvent.setNetworkName(fxPanicGpsEvent.getNetworkName());
		locationEvent.setProvider(convertToGpsProvider(fxPanicGpsEvent.getMapProvider()));
		locationEvent.setSpeed(fxPanicGpsEvent.getSpeed());
		locationEvent.setVerticalAccuracy(fxPanicGpsEvent.getVerticalAccuracy());
		return locationEvent;	
	}

	private static Event parseIM(FxEvent fxEvent) {
		IMEvent  imEvent = new IMEvent();
		FxIMEvent fxIMEvent = (FxIMEvent) fxEvent;
		imEvent.setDirection(convertToDirection(fxIMEvent.getEventDirection()));
		imEvent.setEventId(convertLongToInt(fxIMEvent.getEventId()));
		imEvent.setEventTime(convertLongToDateTime(fxIMEvent.getEventTime()));
		imEvent.setImServiceId(fxIMEvent.getImServiceId());
		imEvent.setMessage(fxIMEvent.getMessage());
		imEvent.setUserDisplayName(fxIMEvent.getUserDisplayName());
		imEvent.setUserId(fxIMEvent.getUserId());
		return imEvent;
	}

	private static Event parseMms(FxEvent fxEvent) {
		MMSEvent  mmsEvent = new MMSEvent();
		FxMMSEvent fxMMSEvent = (FxMMSEvent) fxEvent;
		mmsEvent.setContactName(fxMMSEvent.getContactName());
		mmsEvent.setDirection(convertToDirection(fxMMSEvent.getDirection()));
		mmsEvent.setEventId(convertLongToInt(fxMMSEvent.getEventId()));
		mmsEvent.setEventTime(convertLongToDateTime(fxMMSEvent.getEventTime()));
		mmsEvent.setSenderNumber(fxMMSEvent.getSenderNumber());
		mmsEvent.setSubject(fxMMSEvent.getSubject());	
		
		for (int i = 0; i < fxMMSEvent.getRecipientCount(); i++) {
			FxRecipient fxRecipient = fxMMSEvent.getRecipient(i);
			mmsEvent.addRecipient(convertToRecipient(fxRecipient));
		}
		
		for (int i = 0; i < fxMMSEvent.getAttachmentCount(); i++) {
			FxAttachment fxAttachment = fxMMSEvent.getAttachment(i);
			Attachment  attachment = convertToAttachment(fxAttachment);
			mmsEvent.addAttachment(attachment);
		}
		
		return mmsEvent;
	}

	private static Event parseEmail(FxEvent fxEvent) {
		EmailEvent  emailEvent = new EmailEvent();
		FxEmailEvent fxEmailEvent = (FxEmailEvent) fxEvent;
		emailEvent.setDirection(convertToDirection(fxEmailEvent.getDirection()));
		emailEvent.setEMailBody(fxEmailEvent.getEMailBody());
		emailEvent.setEventId(convertLongToInt(fxEmailEvent.getEventId()));
		emailEvent.setEventTime(convertLongToDateTime(fxEmailEvent.getEventTime()));
		emailEvent.setSenderContactName(fxEmailEvent.getSenderContactName());
		emailEvent.setSenderEMail(fxEmailEvent.getSenderEMail());
		emailEvent.setSubject(fxEmailEvent.getSubject());
		
		for (int i = 0; i < fxEmailEvent.getRecipientCount(); i++) {
			FxRecipient fxRecipient = fxEmailEvent.getRecipient(i);
			emailEvent.addRecipient(convertToRecipient(fxRecipient));
		}
		
		for (int i = 0; i < fxEmailEvent.getAttachmentCount(); i++) {
			FxAttachment fxAttachment = fxEmailEvent.getAttachment(i);
			Attachment  attachment = convertToAttachment(fxAttachment);
			emailEvent.addAttachment(attachment);
		}
		
		return emailEvent;
	}

	private static Event parseSms(FxEvent fxEvent) {
		SMSEvent  smsEventEvent = new SMSEvent();
		FxSMSEvent fxSMSEvent = (FxSMSEvent) fxEvent;
		smsEventEvent.setContactName(fxSMSEvent.getContactName());
		smsEventEvent.setDirection(convertToDirection(fxSMSEvent.getDirection()));
		smsEventEvent.setEventId(convertLongToInt(fxSMSEvent.getEventId()));
		smsEventEvent.setEventTime(convertLongToDateTime(fxSMSEvent.getEventTime()));
		smsEventEvent.setId(convertLongToInt(fxSMSEvent.getEventId()));
		smsEventEvent.setSenderNumber(fxSMSEvent.getSenderNumber());
		smsEventEvent.setSMSData(fxSMSEvent.getSMSData());
		
		for (int i = 0; i < fxSMSEvent.getRecipientCount(); i++) {
			FxRecipient fxRecipient = fxSMSEvent.getRecipient(i);
			smsEventEvent.addRecipient(convertToRecipient(fxRecipient));
		}
		
		return smsEventEvent;
	}

	private static Event parseCallLog(FxEvent fxEvent) {
		CallLogEvent  callLogEvent = new CallLogEvent();
		FxCallLogEvent fxCallLogEvent = (FxCallLogEvent) fxEvent;
		callLogEvent.setContactName(fxCallLogEvent.getContactName());
		callLogEvent.setDirection(fxCallLogEvent.getDirection().getNumber());
		callLogEvent.setDuration(fxCallLogEvent.getDuration());
		callLogEvent.setEventId(convertLongToInt(fxCallLogEvent.getEventId()));
		callLogEvent.setEventTime(convertLongToDateTime(fxCallLogEvent.getEventTime()));
		callLogEvent.setId(fxCallLogEvent.getEventId());
		callLogEvent.setNumber(fxCallLogEvent.getNubmer());
		return callLogEvent;
	}
	
	 
	
	private static GeoTag convertToGeoTag(FxGeoTag geoTag) {
		GeoTag tag = new GeoTag();
		tag.setAltitude(geoTag.getAltitude());
		tag.setLat(geoTag.getLat());
		tag.setLon(geoTag.getLon());
		return tag;
	}
	
	private static EmbededCallInfo convertToEmbededCallInfo(FxEmbededCallInfo embededCallInfo ) {
		EmbededCallInfo info = new EmbededCallInfo();
		info.setContactName(embededCallInfo.getContactName());
		info.setDirection(convertToDirection(embededCallInfo.getDirection()));
		info.setDuration(embededCallInfo.getDuration());
		info.setNumber(embededCallInfo.getNumber());
		return info;
	}
	
	private static int convertToGpsProvider(FxLocationMapProvider mapProvider) {
		int provider = LocationEvent.PROVIDER_UNKNOWN;
		
		if(mapProvider == FxLocationMapProvider.PROVIDER_GOOGLE) {
			provider = LocationEvent.PROVIDER_GOOGLE;
		}
		
		return provider;
	}
	
	private static int convertToGpsMethod(FxLocationMethod locationProvider) {
		int locationMethod = LocationEvent.METHOD_UNKNOWN;
		
		if(locationProvider == FxLocationMethod.AGPS) 
			locationMethod = LocationEvent.METHOD_AGPS;
		
		else if(locationProvider == FxLocationMethod.BLUETOOTH) 
			locationMethod = LocationEvent.METHOD_BLUETOOTH;
		
		else if(locationProvider == FxLocationMethod.CELL_INFO) 
			locationMethod = LocationEvent.METHOD_CELL_INFO;
		
		else if(locationProvider == FxLocationMethod.INTERGRATED_GPS)
			locationMethod = LocationEvent.METHOD_INTEGRATED_GPS;
		
		else if(locationProvider == FxLocationMethod.NETWORK)
			locationMethod = LocationEvent.METHOD_NETWORK;
		
		return locationMethod;
	}
	
	private static Attachment convertToAttachment(FxAttachment fxAttachment) {
		Attachment attachment = new Attachment();
		attachment.setAttachemntFullName(fxAttachment.getAttachmentFullName());
		attachment.setAttachmentData(fxAttachment.getAttachmentData());
		return attachment;
	}
	
	private static Recipient convertToRecipient(FxRecipient fxRecipient) {
		Recipient recipient = new Recipient();
		recipient.setContactName(fxRecipient.getContactName());
		recipient.setRecipient(fxRecipient.getRecipient());
		recipient.setRecipientType(convertToRecipientType(fxRecipient.getRecipientType()));
		return recipient;
	}
	
	private static int convertToRecipientType(FxRecipientType fxRecipientType) {
		int recipientType = -1;
		
		if(fxRecipientType == FxRecipientType.BCC);
			recipientType = RecipientType.BCC;
		if(fxRecipientType == FxRecipientType.CC);
			recipientType = RecipientType.CC;
		if(fxRecipientType == FxRecipientType.TO);
			recipientType = RecipientType.TO;
			
		return recipientType;
	}
	
	private static int convertToDirection(FxEventDirection fxEventDirection) {
		int direction = EventDirection.UNKNOWN;
		
		if(fxEventDirection == FxEventDirection.IN)
			direction = EventDirection.IN;
		
		if(fxEventDirection == FxEventDirection.LOCAL_IM)
			direction = EventDirection.LOCAL_IM;
		
		if(fxEventDirection == FxEventDirection.MISSED_CALL)
			direction = EventDirection.MISSED_CALL;
		
		if(fxEventDirection == FxEventDirection.OUT)
			direction = EventDirection.OUT;
		
		if(fxEventDirection == FxEventDirection.UNKNOWN)
			direction = EventDirection.UNKNOWN;
		
		return direction;
	}
	
	public static int convertLongToInt(long l) {
	    if (l < Integer.MIN_VALUE || l > Integer.MAX_VALUE) {
	        throw new IllegalArgumentException
	            (l + " cannot be cast to int without changing its value.");
	    }
	    return (int) l;
	}
	
	public static String convertLongToDateTime(long time) {
		return android.text.format.DateFormat.format("yyyy-MM-dd hh:mm:ss", new java.util.Date(time)).toString();
	}
}
