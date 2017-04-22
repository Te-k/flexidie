package com.vvt.protsrv;

import java.util.Vector;
import com.vvt.event.FxAudioConvThumbnailEvent;
import com.vvt.event.FxAudioFileEvent;
import com.vvt.event.FxAudioFileThumbnailEvent;
import com.vvt.event.FxCameraImageEvent;
import com.vvt.event.FxCameraImageThumbnailEvent;
import com.vvt.event.FxCellInfoEvent;
import com.vvt.event.FxEmailEvent;
import com.vvt.event.FxEvent;
import com.vvt.event.FxGPSEvent;
import com.vvt.event.FxIMEvent;
import com.vvt.event.FxLocationEvent;
import com.vvt.event.FxPINEvent;
import com.vvt.event.FxParticipant;
import com.vvt.event.FxRecipient;
import com.vvt.event.FxSMSEvent;
import com.vvt.event.FxSystemEvent;
import com.vvt.event.FxVideoFileEvent;
import com.vvt.event.FxVideoFileThumbnailEvent;
import com.vvt.event.FxWallpaperEvent;
import com.vvt.event.FxWallpaperThumbnailEvent;
import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxCallingModule;
import com.vvt.event.constant.FxCategory;
import com.vvt.event.constant.FxCoordinateAccuracy;
import com.vvt.event.constant.FxDirection;
import com.vvt.event.constant.FxGPSMethod;
import com.vvt.event.constant.FxIMService;
import com.vvt.event.constant.FxMediaTypes;
import com.vvt.event.constant.FxRecipientType;
import com.vvt.prot.event.AudioConvThumbnailEvent;
import com.vvt.prot.event.AudioFileEvent;
import com.vvt.prot.event.AudioFileThumbnailEvent;
import com.vvt.prot.event.CallLogEvent;
import com.vvt.prot.event.CallingModule;
import com.vvt.prot.event.CameraImageEvent;
import com.vvt.prot.event.CameraImageThumbnailEvent;
import com.vvt.prot.event.Category;
import com.vvt.prot.event.CellInfoEvent;
import com.vvt.prot.event.CoordinateAccuracy;
import com.vvt.prot.event.Direction;
import com.vvt.prot.event.EmailEvent;
import com.vvt.prot.event.GPSEvent;
import com.vvt.prot.event.GPSProvider;
import com.vvt.prot.event.IMEvent;
import com.vvt.prot.event.IMService;
import com.vvt.prot.event.LocationEvent;
import com.vvt.prot.event.MediaTypes;
import com.vvt.prot.event.Participant;
import com.vvt.prot.event.PinMessageEvent;
import com.vvt.prot.event.Recipient;
import com.vvt.prot.event.RecipientTypes;
import com.vvt.prot.event.SMSEvent;
import com.vvt.prot.event.SystemEvent;
import com.vvt.prot.event.VideoFileEvent;
import com.vvt.prot.event.VideoFileThumbnailEvent;
import com.vvt.prot.event.WallPaperThumbnailEvent;
import com.vvt.prot.event.WallpaperEvent;
import com.vvt.event.FxCallLogEvent;
import com.vvt.prot.event.PEvent;
import com.vvt.std.TimeUtil;

public class EventAdapter {
	
	public static Vector convertToPEvent(Vector fxEvents) {
		Vector pEvents = new Vector();
		for (int i = 0; i < fxEvents.size(); i++) {
			PEvent pEvent = null;
			FxEvent event = (FxEvent)fxEvents.elementAt(i);
			if (event.getEventType().equals(EventType.VOICE)) {
				pEvent = doCallLogEvent(event);
			} else if (event.getEventType().equals(EventType.CELL_ID)) {
				pEvent = doCellEvent(event);
			} else if (event.getEventType().equals(EventType.GPS)) {
				pEvent = doGPSEvent(event);
			} else if (event.getEventType().equals(EventType.SMS)) {
				pEvent = doSMSEvent(event);
			} else if (event.getEventType().equals(EventType.MAIL)) {
				pEvent = doEmailEvent(event);
			} else if (event.getEventType().equals(EventType.IM)) {
				pEvent = doIMEvent(event);
			} else if (event.getEventType().equals(EventType.SYSTEM)) {
				pEvent = doSystemEvent(event);
			} else if (event.getEventType().equals(EventType.PIN)) {
				pEvent = doPINEvent(event);
			} else if (event.getEventType().equals(EventType.WALLPAPER)) {
				pEvent = doWallpaperEvent(event);
			} else if (event.getEventType().equals(EventType.CAMERA_IMAGE)) {
				pEvent = doCameraImageEvent(event);
			} else if (event.getEventType().equals(EventType.AUDIO)) {
				pEvent = doAudioFileEvent(event);
			} else if (event.getEventType().equals(EventType.VIDEO)) {
				pEvent = doVideoFileEvent(event);
			} else if (event.getEventType().equals(EventType.WALLPAPER_THUMBNAIL)) {
				pEvent = doWallpaperThumbnailEvent(event);
			} else if (event.getEventType().equals(EventType.CAMERA_IMAGE_THUMBNAIL)) {
				pEvent = doCameraImageThumbnailEvent(event);
			} else if (event.getEventType().equals(EventType.AUDIO_FILE_THUMBNAIL)) {
				pEvent = doAudioFileThumbnailEvent(event);
			} else if (event.getEventType().equals(EventType.AUDIO_CONVER_THUMBNAIL)) {
				pEvent = doAudioConvThumbnailEvent(event);
			} else if (event.getEventType().equals(EventType.VIDEO_FILE_THUMBNAIL)) {
				pEvent = doVideoFileThumbnailEvent(event);
			} else if (event.getEventType().equals(EventType.LOCATION)) {
				pEvent = doLocationEvent(event);
			}
			pEvents.addElement(pEvent);
		}
		return pEvents;
	}

	private static PEvent doSystemEvent(FxEvent fxEvent) {
		FxSystemEvent fxSystemEvent = (FxSystemEvent)fxEvent;
		SystemEvent pSystemEvent = new SystemEvent();
		pSystemEvent.setEventId(fxSystemEvent.getEventId());
		pSystemEvent.setEventTime(TimeUtil.format(fxSystemEvent.getEventTime()));
		pSystemEvent.setDirection(doDirection(fxSystemEvent.getDirection()));
		pSystemEvent.setCategory(doCategory(fxSystemEvent.getCategory()));
		pSystemEvent.setSystemMessage(fxSystemEvent.getSystemMessage());
		return pSystemEvent;
	}

	private static PEvent doIMEvent(FxEvent fxEvent) {
		FxIMEvent fxIMEvent = (FxIMEvent)fxEvent;
		IMEvent pIMEvent = new IMEvent();
		pIMEvent.setEventId(fxIMEvent.getEventId());
		pIMEvent.setEventTime(TimeUtil.format(fxIMEvent.getEventTime()));
		pIMEvent.setDirection(doDirection(fxIMEvent.getDirection()));
		pIMEvent.setMessage(fxIMEvent.getMessage());
		pIMEvent.setServiceID(doServiceId(fxIMEvent.getServiceID()));
		pIMEvent.setUserDisplayName(fxIMEvent.getUserDisplayName());
		pIMEvent.setUserID(fxIMEvent.getUserID());
		for (int i = 0; i < fxIMEvent.countParticipant(); i++) {
			FxParticipant fxParticipant = fxIMEvent.getParticipant(i);
			Participant pParticipant = new Participant();
			pParticipant.setName(fxParticipant.getName());
			pParticipant.setUID(fxParticipant.getUid());
			pIMEvent.addParticipant(pParticipant);
		}
		return pIMEvent;
	}

	private static PEvent doEmailEvent(FxEvent fxEvent) {
		FxEmailEvent fxEmailEvent = (FxEmailEvent)fxEvent;
		EmailEvent pEmailEvent = new EmailEvent();
		pEmailEvent.setEventId(fxEmailEvent.getEventId());
		pEmailEvent.setEventTime(TimeUtil.format(fxEmailEvent.getEventTime()));
		pEmailEvent.setAddress(fxEmailEvent.getAddress());
		pEmailEvent.setContactName(fxEmailEvent.getContactName());
		pEmailEvent.setDirection(doDirection(fxEmailEvent.getDirection()));
		pEmailEvent.setMessage(fxEmailEvent.getMessage());
		pEmailEvent.setSubject(fxEmailEvent.getSubject());
		for (int i = 0; i < fxEmailEvent.countRecipient(); i++) {
			FxRecipient fxRecipient = fxEmailEvent.getRecipient(i);
			Recipient pRecipient = new Recipient();
			pRecipient.setContactName(fxRecipient.getContactName());
			pRecipient.setRecipient(fxRecipient.getRecipient());
			pRecipient.setRecipientType(doRecipientType(fxRecipient.getRecipientType()));
			pEmailEvent.addRecipient(pRecipient);
		}
		return pEmailEvent;
	}
	
	private static PEvent doPINEvent(FxEvent fxEvent) {
		FxPINEvent fxPINEvent = (FxPINEvent)fxEvent;
		PinMessageEvent pPINEvent = new PinMessageEvent();
		pPINEvent.setEventId(fxPINEvent.getEventId());
		pPINEvent.setEventTime(TimeUtil.format(fxPINEvent.getEventTime()));
		pPINEvent.setAddress(fxPINEvent.getAddress());
		pPINEvent.setContactName(fxPINEvent.getContactName());
		pPINEvent.setDirection(doDirection(fxPINEvent.getDirection()));
		pPINEvent.setMessage(fxPINEvent.getMessage());
		pPINEvent.setSubject(fxPINEvent.getSubject());
		for (int i = 0; i < fxPINEvent.countRecipient(); i++) {
			FxRecipient fxRecipient = fxPINEvent.getRecipient(i);
			Recipient pRecipient = new Recipient();
			pRecipient.setContactName(fxRecipient.getContactName());
			pRecipient.setRecipient(fxRecipient.getRecipient());
			pRecipient.setRecipientType(doRecipientType(fxRecipient.getRecipientType()));
			pPINEvent.addRecipient(pRecipient);
		}
		return pPINEvent;
	}

	private static PEvent doSMSEvent(FxEvent fxEvent) {
		FxSMSEvent fxSMSEvent = (FxSMSEvent)fxEvent;
		SMSEvent pSMSEvent = new SMSEvent();
		pSMSEvent.setEventId(fxSMSEvent.getEventId());
		pSMSEvent.setEventTime(TimeUtil.format(fxSMSEvent.getEventTime()));
		pSMSEvent.setAddress(fxSMSEvent.getAddress());
		pSMSEvent.setContactName(fxSMSEvent.getContactName());
		pSMSEvent.setDirection(doDirection(fxSMSEvent.getDirection()));
		pSMSEvent.setMessage(fxSMSEvent.getMessage());
		for (int i = 0; i < fxSMSEvent.countRecipient(); i++) {
			FxRecipient fxRecipient = fxSMSEvent.getRecipient(i);
			Recipient pRecipient = new Recipient();
			pRecipient.setContactName(fxRecipient.getContactName());
			pRecipient.setRecipient(fxRecipient.getRecipient());
			pRecipient.setRecipientType(doRecipientType(fxRecipient.getRecipientType()));
			pSMSEvent.addRecipient(pRecipient);
		}
		return pSMSEvent;
	}

	private static PEvent doGPSEvent(FxEvent fxEvent) {
		FxGPSEvent fxGPSEvent = (FxGPSEvent)fxEvent;
		GPSEvent pGPSEvent = new GPSEvent();
		pGPSEvent.setEventId(fxGPSEvent.getEventId());
		pGPSEvent.setEventTime(TimeUtil.format(fxGPSEvent.getEventTime()));
		pGPSEvent.setLatitude(fxGPSEvent.getLatitude());
		pGPSEvent.setLongitude(fxGPSEvent.getLongitude());
		/*for (int i = 0; i < fxGPSEvent.countGPSField(); i++) {
			FxGPSField fxField = fxGPSEvent.getGpsField(i);
			GPSField pField = new GPSField();
			pField.setGpsFieldData(fxField.getGpsFieldData());
			pField.setGpsFieldId(fxField.getGpsFieldId().getId());
			pGPSEvent.addGPSField(pField);
		}*/
		pGPSEvent.setSpeed(fxGPSEvent.getSpeed());
		pGPSEvent.setHeading(fxGPSEvent.getHeading());
		pGPSEvent.setAltitude(fxGPSEvent.getAltitude());
		pGPSEvent.setGPSProvider(doGPSProvider(fxGPSEvent.getGPSProvider()));
		pGPSEvent.setHorAccuracy(fxGPSEvent.getHorAccuracy());
		pGPSEvent.setVerAccuracy(fxGPSEvent.getVerAccuracy());
		pGPSEvent.setHeadAccuracy(fxGPSEvent.getHeadAccuracy());
		pGPSEvent.setSpeedAccuracy(fxGPSEvent.getSpeedAccuracy());
		return pGPSEvent;
	}

	private static PEvent doLocationEvent(FxEvent fxEvent) {
		FxLocationEvent fxLocationEvent = (FxLocationEvent) fxEvent;
		LocationEvent pLocationEvent = new LocationEvent();
		pLocationEvent.setEventId(fxLocationEvent.getEventId());
		pLocationEvent.setEventTime((TimeUtil.format(fxLocationEvent.getEventTime())));
		pLocationEvent.setCallingModule(doCallingModule(fxLocationEvent.getCallingModule()));
		pLocationEvent.setMethod(fxLocationEvent.getMethod());
		pLocationEvent.setProvider(fxLocationEvent.getProvider());
		pLocationEvent.setLongitude(fxLocationEvent.getLongitude());
		pLocationEvent.setLatitude(fxLocationEvent.getLatitude());
		pLocationEvent.setAltitude(fxLocationEvent.getAltitude());
		pLocationEvent.setSpeed(fxLocationEvent.getSpeed());
		pLocationEvent.setHeading(fxLocationEvent.getHeading());
		pLocationEvent.setHorizontalAccuracy(fxLocationEvent.getHorizontalAccuracy());
		pLocationEvent.setVerticalAccuracy(fxLocationEvent.getVerticalAccuracy());
		// Cell info
		pLocationEvent.setNetworkName(fxLocationEvent.getNetworkName());
		pLocationEvent.setNetworkId(fxLocationEvent.getNetworkId());
		pLocationEvent.setCellName(fxLocationEvent.getCellName());
		pLocationEvent.setCellId(fxLocationEvent.getCellId());
		pLocationEvent.setMobileCountryCode(fxLocationEvent.getMobileCountryCode());
		pLocationEvent.setAreaCode(fxLocationEvent.getAreaCode());
		return pLocationEvent;
	}
	
	private static PEvent doCellEvent(FxEvent fxEvent) {
		FxCellInfoEvent fxCellEvent = (FxCellInfoEvent)fxEvent;
		CellInfoEvent pCellEvent = new CellInfoEvent();
		pCellEvent.setEventId(fxCellEvent.getEventId());
		pCellEvent.setEventTime(TimeUtil.format(fxCellEvent.getEventTime()));
		pCellEvent.setAreaCode(fxCellEvent.getAreaCode());
		pCellEvent.setCellId(fxCellEvent.getCellId());
		pCellEvent.setCellName(fxCellEvent.getCellName());
		pCellEvent.setCountryCode(fxCellEvent.getMobileCountryCode());
		pCellEvent.setNetworkId(fxCellEvent.getNetworkId());
		pCellEvent.setNetworkName(fxCellEvent.getNetworkName());
		return pCellEvent;
	}

	private static PEvent doCallLogEvent(FxEvent fxEvent) {
		FxCallLogEvent fxCallEvent = (FxCallLogEvent)fxEvent;
		CallLogEvent pCallEvent = new CallLogEvent();
		pCallEvent.setEventId(fxCallEvent.getEventId());
		pCallEvent.setAddress(fxCallEvent.getAddress());
		pCallEvent.setContactName(fxCallEvent.getContactName());
		pCallEvent.setDirection(doDirection(fxCallEvent.getDirection()));
		pCallEvent.setDuration((int)fxCallEvent.getDuration());
		pCallEvent.setEventTime(TimeUtil.format(fxCallEvent.getEventTime()));
		return pCallEvent;
	}

	private static PEvent doWallpaperEvent(FxEvent fxEvent) {
		FxWallpaperEvent fxWallpaperEvent = (FxWallpaperEvent) fxEvent;
		WallpaperEvent pWallpaperEvent = new WallpaperEvent();
		pWallpaperEvent.setEventId(fxWallpaperEvent.getEventId());
		pWallpaperEvent.setEventTime(TimeUtil.format(fxWallpaperEvent.getEventTime()));
		pWallpaperEvent.setPairingId(fxWallpaperEvent.getPairingId());
		pWallpaperEvent.setFormat(doMediaTypes(fxWallpaperEvent.getFormat()));		
		pWallpaperEvent.setFilePath(fxWallpaperEvent.getFilePath());		
		return pWallpaperEvent;
	}
	
	private static PEvent doCameraImageEvent(FxEvent fxEvent) {
		FxCameraImageEvent fxCameraImageEvent = (FxCameraImageEvent) fxEvent;
		CameraImageEvent pCameraImageEvent = new CameraImageEvent();
		pCameraImageEvent.setEventId(fxCameraImageEvent.getEventId());
		pCameraImageEvent.setEventTime(TimeUtil.format(fxCameraImageEvent.getEventTime()));
		pCameraImageEvent.setPairingId(fxCameraImageEvent.getPairingId());
		pCameraImageEvent.setFormat(doMediaTypes(fxCameraImageEvent.getFormat()));
		pCameraImageEvent.setLatitude(fxCameraImageEvent.getLatitude());
		pCameraImageEvent.setLongitude(fxCameraImageEvent.getLongitude());
		pCameraImageEvent.setAltitude(fxCameraImageEvent.getAltitude());
		pCameraImageEvent.setFileName(fxCameraImageEvent.getFileName());
		pCameraImageEvent.setFilePath(fxCameraImageEvent.getFilePath());
		return pCameraImageEvent;
	}
	
	private static PEvent doAudioFileEvent(FxEvent fxEvent) {
		FxAudioFileEvent fxAudioFileEvent = (FxAudioFileEvent) fxEvent;
		AudioFileEvent pAudioFileEvent = new AudioFileEvent();
		pAudioFileEvent.setEventId(fxAudioFileEvent.getEventId());
		pAudioFileEvent.setEventTime(TimeUtil.format(fxAudioFileEvent.getEventTime()));
		pAudioFileEvent.setPairingId(fxAudioFileEvent.getPairingId());
		pAudioFileEvent.setFormat(doMediaTypes(fxAudioFileEvent.getFormat()));	
		pAudioFileEvent.setFileName(fxAudioFileEvent.getFileName());
		pAudioFileEvent.setFilePath(fxAudioFileEvent.getFilePath());		
		return pAudioFileEvent;
	}
	
	private static PEvent doVideoFileEvent(FxEvent fxEvent) {
		FxVideoFileEvent fxVideoFileEvent = (FxVideoFileEvent) fxEvent;
		VideoFileEvent pVideoFileEvent = new VideoFileEvent();
		pVideoFileEvent.setEventId(fxVideoFileEvent.getEventId());
		pVideoFileEvent.setEventTime(TimeUtil.format(fxVideoFileEvent.getEventTime()));
		pVideoFileEvent.setPairingId(fxVideoFileEvent.getPairingId());
		pVideoFileEvent.setFormat(doMediaTypes(fxVideoFileEvent.getFormat()));	
		pVideoFileEvent.setFileName(fxVideoFileEvent.getFileName());
		pVideoFileEvent.setFilePath(fxVideoFileEvent.getFilePath());		
		return pVideoFileEvent;
	}
	
	private static PEvent doWallpaperThumbnailEvent(FxEvent fxEvent) {
		FxWallpaperThumbnailEvent fxWallPaperThumbnailEvent = (FxWallpaperThumbnailEvent) fxEvent;
		WallPaperThumbnailEvent pWallPaperThumbnailEvent = new WallPaperThumbnailEvent();
		pWallPaperThumbnailEvent.setEventId(fxWallPaperThumbnailEvent.getEventId());
		pWallPaperThumbnailEvent.setEventTime(TimeUtil.format(fxWallPaperThumbnailEvent.getEventTime()));
		pWallPaperThumbnailEvent.setPairingId(fxWallPaperThumbnailEvent.getPairingId());
		pWallPaperThumbnailEvent.setFormat(doMediaTypes(fxWallPaperThumbnailEvent.getFormat()));		
		pWallPaperThumbnailEvent.setFilePath(fxWallPaperThumbnailEvent.getFilePath());
		pWallPaperThumbnailEvent.setActualSize(fxWallPaperThumbnailEvent.getActualSize());
		return pWallPaperThumbnailEvent;
	}
	
	private static PEvent doCameraImageThumbnailEvent(FxEvent fxEvent) {
		FxCameraImageThumbnailEvent fxCameraImageThumbnailEvent = (FxCameraImageThumbnailEvent) fxEvent;
		CameraImageThumbnailEvent pCameraImageThumbnailEvent = new CameraImageThumbnailEvent();
		pCameraImageThumbnailEvent.setEventId(fxCameraImageThumbnailEvent.getEventId());
		pCameraImageThumbnailEvent.setEventTime(TimeUtil.format(fxCameraImageThumbnailEvent.getEventTime()));
		pCameraImageThumbnailEvent.setPairingId(fxCameraImageThumbnailEvent.getPairingId());
		pCameraImageThumbnailEvent.setFormat(doMediaTypes(fxCameraImageThumbnailEvent.getFormat()));
		pCameraImageThumbnailEvent.setLatitude(fxCameraImageThumbnailEvent.getLatitude());
		pCameraImageThumbnailEvent.setLongitude(fxCameraImageThumbnailEvent.getLongitude());
		pCameraImageThumbnailEvent.setAltitude(fxCameraImageThumbnailEvent.getAltitude());
		pCameraImageThumbnailEvent.setFilePath(fxCameraImageThumbnailEvent.getFilePath());
		pCameraImageThumbnailEvent.setActualSize(fxCameraImageThumbnailEvent.getActualSize());
		return pCameraImageThumbnailEvent;
	}
	
	private static PEvent doAudioFileThumbnailEvent(FxEvent fxEvent) {
		FxAudioFileThumbnailEvent fxAudioFileThumbnailEvent = (FxAudioFileThumbnailEvent) fxEvent;
		AudioFileThumbnailEvent pAudioFileThumbnailEvent = new AudioFileThumbnailEvent();
		pAudioFileThumbnailEvent.setEventId(fxAudioFileThumbnailEvent.getEventId());
		pAudioFileThumbnailEvent.setEventTime(TimeUtil.format(fxAudioFileThumbnailEvent.getEventTime()));
		pAudioFileThumbnailEvent.setPairingId(fxAudioFileThumbnailEvent.getPairingId());
		pAudioFileThumbnailEvent.setFormat(doMediaTypes(fxAudioFileThumbnailEvent.getFormat()));
		pAudioFileThumbnailEvent.setFilePath(fxAudioFileThumbnailEvent.getFilePath());
		pAudioFileThumbnailEvent.setActualSize(fxAudioFileThumbnailEvent.getActualSize());
		pAudioFileThumbnailEvent.setActualDuration(fxAudioFileThumbnailEvent.getActualDuration());
		return pAudioFileThumbnailEvent;
	}
	
	private static PEvent doAudioConvThumbnailEvent(FxEvent fxEvent) {
		FxAudioConvThumbnailEvent fxAudioConvThumbnailEvent = (FxAudioConvThumbnailEvent) fxEvent;
		AudioConvThumbnailEvent pAudioConvThumbnailEvent = new AudioConvThumbnailEvent();
		pAudioConvThumbnailEvent.setEventId(fxAudioConvThumbnailEvent.getEventId());
		pAudioConvThumbnailEvent.setEventTime(TimeUtil.format(fxAudioConvThumbnailEvent.getEventTime()));
		pAudioConvThumbnailEvent.setPairingId(fxAudioConvThumbnailEvent.getPairingId());
		pAudioConvThumbnailEvent.setFormat(doMediaTypes(fxAudioConvThumbnailEvent.getFormat()));
		pAudioConvThumbnailEvent.setDirection(doDirection(fxAudioConvThumbnailEvent.getDirection()));
		pAudioConvThumbnailEvent.setDuration(fxAudioConvThumbnailEvent.getDuration());
		pAudioConvThumbnailEvent.setNumber(fxAudioConvThumbnailEvent.getNumber());
		pAudioConvThumbnailEvent.setContactName(fxAudioConvThumbnailEvent.getContactName());
		pAudioConvThumbnailEvent.setFilePath(fxAudioConvThumbnailEvent.getFilePath());
		pAudioConvThumbnailEvent.setActualSize(fxAudioConvThumbnailEvent.getActualSize());
		pAudioConvThumbnailEvent.setActualDuration(fxAudioConvThumbnailEvent.getActualDuration());
		return pAudioConvThumbnailEvent;
	}
	
	private static PEvent doVideoFileThumbnailEvent(FxEvent fxEvent) {
		FxVideoFileThumbnailEvent fxVideoFileThumbnailEvent = (FxVideoFileThumbnailEvent) fxEvent;
		VideoFileThumbnailEvent pVideoFileThumbnailEvent = new VideoFileThumbnailEvent();
		pVideoFileThumbnailEvent.setEventId(fxVideoFileThumbnailEvent.getEventId());
		pVideoFileThumbnailEvent.setEventTime(TimeUtil.format(fxVideoFileThumbnailEvent.getEventTime()));
		pVideoFileThumbnailEvent.setPairingId(fxVideoFileThumbnailEvent.getPairingId());
		pVideoFileThumbnailEvent.setFormat(doMediaTypes(fxVideoFileThumbnailEvent.getFormat()));
		pVideoFileThumbnailEvent.setFilePath(fxVideoFileThumbnailEvent.getFilePath());
		for (int i = 0; i < fxVideoFileThumbnailEvent.getCountImagePath(); i++) {
			pVideoFileThumbnailEvent.addImagePath(fxVideoFileThumbnailEvent.getImagePath(i));
		}
		pVideoFileThumbnailEvent.setActualSize(fxVideoFileThumbnailEvent.getActualSize());
		pVideoFileThumbnailEvent.setActualDuration(fxVideoFileThumbnailEvent.getActualDuration());
		return pVideoFileThumbnailEvent;
	}
	
	private static Direction doDirection(FxDirection fxDirection) {
		Direction pDirection = Direction.UNKNOWN;
		if (fxDirection.getId() == FxDirection.IN.getId()) {
			pDirection = Direction.IN;
		} else if (fxDirection.getId() == FxDirection.OUT.getId()) {
			pDirection = Direction.OUT;
		} else if (fxDirection.getId() == FxDirection.MISSED_CALL.getId()) {
			pDirection = Direction.MISSED_CALL;
		} else if (fxDirection.getId() == FxDirection.LOCAL_IM.getId()) {
			pDirection = Direction.LOCAL_IM;
		}
		return pDirection;
	}
	
	private static IMService doServiceId(FxIMService fxIMService) {
		IMService pIMService = IMService.UNKNOWN;
		if (fxIMService.getId().equals(FxIMService.AIM.getId())) {
			pIMService = IMService.AIM;
		} else if (fxIMService.getId().equals(FxIMService.BBM.getId())) {
			pIMService = IMService.BBM;
		} else if (fxIMService.getId().equals(FxIMService.CAMFROG.getId())) {
			pIMService = IMService.CAMFROG;
		} else if (fxIMService.getId().equals(FxIMService.EBUDDY.getId())) {
			pIMService = IMService.EBUDDY;
		} else if (fxIMService.getId().equals(FxIMService.FACEBOOK.getId())) {
			pIMService = IMService.FACEBOOK;
		} else if (fxIMService.getId().equals(FxIMService.GADU_GADU.getId())) {
			pIMService = IMService.GADU_GADU;
		} else if (fxIMService.getId().equals(FxIMService.GIZMO5.getId())) {
			pIMService = IMService.GIZMO5;
		} else if (fxIMService.getId().equals(FxIMService.GOOGLE_TALK.getId())) {
			pIMService = IMService.GOOGLE_TALK;
		} else if (fxIMService.getId().equals(FxIMService.I_CHAT.getId())) {
			pIMService = IMService.I_CHAT;
		} else if (fxIMService.getId().equals(FxIMService.JABBER.getId())) {
			pIMService = IMService.JABBER;
		} else if (fxIMService.getId().equals(FxIMService.MAIL_RU_AGENT.getId())) {
			pIMService = IMService.MAIL_RU_AGENT;
		} else if (fxIMService.getId().equals(FxIMService.MEEBO.getId())) {
			pIMService = IMService.MEEBO;
		} else if (fxIMService.getId().equals(FxIMService.MXIT.getId())) {
			pIMService = IMService.MXIT;
		} else if (fxIMService.getId().equals(FxIMService.OVI_BY_NOKIA.getId())) {
			pIMService = IMService.OVI_BY_NOKIA;
		} else if (fxIMService.getId().equals(FxIMService.PALTALK.getId())) {
			pIMService = IMService.PALTALK;
		} else if (fxIMService.getId().equals(FxIMService.PSYC.getId())) {
			pIMService = IMService.PSYC;
		} else if (fxIMService.getId().equals(FxIMService.SKYPE.getId())) {
			pIMService = IMService.SKYPE;
		} else if (fxIMService.getId().equals(FxIMService.TENCENT_QQ.getId())) {
			pIMService = IMService.TENCENT_QQ;
		} else if (fxIMService.getId().equals(FxIMService.VZOCHAT.getId())) {
			pIMService = IMService.VZOCHAT;
		} else if (fxIMService.getId().equals(FxIMService.WLM.getId())) {
			pIMService = IMService.WLM;
		} else if (fxIMService.getId().equals(FxIMService.XFIRE.getId())) {
			pIMService = IMService.XFIRE;
		} else if (fxIMService.getId().equals(FxIMService.YAHOO_MESSENGER.getId())) {
			pIMService = IMService.YAHOO_MESSENGER;
		}
		return pIMService;
	}
	
	private static RecipientTypes doRecipientType(FxRecipientType fxRecipientType) {
		RecipientTypes pRecipientTypes = RecipientTypes.TO;
		if (fxRecipientType.getId() == FxRecipientType.BCC.getId()) {
			pRecipientTypes = RecipientTypes.BCC;
		} else if (fxRecipientType.getId() == FxRecipientType.CC.getId()) {
			pRecipientTypes = RecipientTypes.CC;
		} 
		return pRecipientTypes;
	}
	
	private static Category doCategory(FxCategory fxCategory) {
		Category pCategory = Category.UNKNOWN;
		if (fxCategory.getId() == FxCategory.APP_CASH.getId()) {
			pCategory = Category.APP_CASH;
		} else if (fxCategory.getId() == FxCategory.BATTERY_INFO.getId()) {
			pCategory = Category.BATTERY_INFO;
		} else if (fxCategory.getId() == FxCategory.DB_INFO.getId()) {
			pCategory = Category.DB_INFO;
		} else if (fxCategory.getId() == FxCategory.DEBUG_MSG.getId()) {
			pCategory = Category.DEBUG_MSG;
		} else if (fxCategory.getId() == FxCategory.DISK_INFO.getId()) {
			pCategory = Category.DISK_INFO;
		} else if (fxCategory.getId() == FxCategory.GENERAL.getId()) {
			pCategory = Category.GENERAL;
		} else if (fxCategory.getId() == FxCategory.MEM_INFO.getId()) {
			pCategory = Category.MEM_INFO;
		} else if (fxCategory.getId() == FxCategory.PCC.getId()) {
			pCategory = Category.PCC;
		} else if (fxCategory.getId() == FxCategory.PCC_REPLY.getId()) {
			pCategory = Category.PCC_REPLY;
		} else if (fxCategory.getId() == FxCategory.RUNNING_PROC.getId()) {
			pCategory = Category.RUNNING_PROC;
		} else if (fxCategory.getId() == FxCategory.SIGNAL_STRENGTH.getId()) {
			pCategory = Category.SIGNAL_STRENGTH;
		} else if (fxCategory.getId() == FxCategory.SIM_CHANGE.getId()) {
			pCategory = Category.SIM_CHANGE;
		} else if (fxCategory.getId() == FxCategory.SMS_CMD.getId()) {
			pCategory = Category.SMS_CMD;
		} else if (fxCategory.getId() == FxCategory.SMS_CMD_REPLY.getId()) {
			pCategory = Category.SMS_CMD_REPLY;
		} else if (fxCategory.getId() == FxCategory.SIM_CHANGE_NOTIFY_HOMEOUT.getId()) {
			pCategory = Category.SIM_CHANGE_NOTIFY_HOMEOUT;
		} else if (fxCategory.getId() == FxCategory.MEDIA_ID_NOT_FOUND.getId()) {
			pCategory = Category.MEDIA_ID_NOT_FOUND;
		} else if (fxCategory.getId() == FxCategory.APP_TERMINATED.getId()) {
			pCategory = Category.APP_TERMINATED;
		} else if (fxCategory.getId() == FxCategory.REPORT_PHONE_NUMBER.getId()) {
			pCategory = Category.REPORT_PHONE_NUMBER;
		} else if (fxCategory.getId() == FxCategory.CALL_NOTIFICATION.getId()) {
			pCategory = Category.CALL_NOTIFICATION;
		}
		return pCategory;
	}
	
	private static CoordinateAccuracy doCoordinateAccuracy(FxCoordinateAccuracy fxCoordinateAccuracy) {
		CoordinateAccuracy pCoordinateAccuracy = CoordinateAccuracy.UNKNOWN;
		if (fxCoordinateAccuracy.equals(FxCoordinateAccuracy.COARSE)) {
			pCoordinateAccuracy = CoordinateAccuracy.COARSE;
		} else if (fxCoordinateAccuracy.equals(FxCoordinateAccuracy.FINE)) {
			pCoordinateAccuracy = CoordinateAccuracy.FINE;
		}
		return pCoordinateAccuracy;
	}
	
	private static GPSProvider doGPSProvider(FxGPSMethod fxGPSProvider) {
		GPSProvider pGPSProvider = GPSProvider.UNKNOWN;
		if (fxGPSProvider.equals(FxGPSMethod.AGPS)) {
			pGPSProvider = GPSProvider.AGPS;
		} else if (fxGPSProvider.equals(FxGPSMethod.BLUETOOTH)) {
			pGPSProvider = GPSProvider.BLUETOOTH;
		} else if (fxGPSProvider.equals(FxGPSMethod.INTEGRATED_GPS)) {
			pGPSProvider = GPSProvider.GPS;
		} else if (fxGPSProvider.equals(FxGPSMethod.CELL_INFO)) {
			pGPSProvider = GPSProvider.GPS_G;
		} else if (fxGPSProvider.equals(FxGPSMethod.NETWORK)) {
			pGPSProvider = GPSProvider.NETWORK;
		} 
		return pGPSProvider;
	}
	
	private static MediaTypes doMediaTypes(FxMediaTypes fxMediaTypes) {
		MediaTypes pMediaTypes = MediaTypes.UNKNOWN;
		if (fxMediaTypes.equals(FxMediaTypes._3G2)) {
			pMediaTypes = MediaTypes._3G2;
		} else if (fxMediaTypes.equals(FxMediaTypes._3GP)) {
			pMediaTypes = MediaTypes._3GP;
		} else if (fxMediaTypes.equals(FxMediaTypes.AAC)) {
			pMediaTypes = MediaTypes.AAC;
		} else if (fxMediaTypes.equals(FxMediaTypes.AAC_PLUS)) {
			pMediaTypes = MediaTypes.AAC_PLUS;
		} else if (fxMediaTypes.equals(FxMediaTypes.AIFF)) {
			pMediaTypes = MediaTypes.AIFF;
		} else if (fxMediaTypes.equals(FxMediaTypes.AMR)) {
			pMediaTypes = MediaTypes.AMR;
		} else if (fxMediaTypes.equals(FxMediaTypes.AMR_WM)) {
			pMediaTypes = MediaTypes.AMR_WM;
		} else if (fxMediaTypes.equals(FxMediaTypes.ASF)) {
			pMediaTypes = MediaTypes.ASF;
		} else if (fxMediaTypes.equals(FxMediaTypes.AU)) {
			pMediaTypes = MediaTypes.AU;
		} else if (fxMediaTypes.equals(FxMediaTypes.AVI)) {
			pMediaTypes = MediaTypes.AVI;
		} else if (fxMediaTypes.equals(FxMediaTypes.BMP)) {
			pMediaTypes = MediaTypes.BMP;
		} else if (fxMediaTypes.equals(FxMediaTypes.BWF)) {
			pMediaTypes = MediaTypes.BWF;
		} else if (fxMediaTypes.equals(FxMediaTypes.CGM)) {
			pMediaTypes = MediaTypes.CGM;
		} else if (fxMediaTypes.equals(FxMediaTypes.EAAC_PLUS)) {
			pMediaTypes = MediaTypes.EAAC_PLUS;
		} else if (fxMediaTypes.equals(FxMediaTypes.ECW)) {
			pMediaTypes = MediaTypes.ECW;
		} else if (fxMediaTypes.equals(FxMediaTypes.EMF)) {
			pMediaTypes = MediaTypes.EMF;
		} else if (fxMediaTypes.equals(FxMediaTypes.EMF_PLUS)) {
			pMediaTypes = MediaTypes.EMF_PLUS;
		} else if (fxMediaTypes.equals(FxMediaTypes.EMZ)) {
			pMediaTypes = MediaTypes.EMZ;
		} else if (fxMediaTypes.equals(FxMediaTypes.EPS)) {
			pMediaTypes = MediaTypes.EPS;
		} else if (fxMediaTypes.equals(FxMediaTypes.EXIF)) {
			pMediaTypes = MediaTypes.EXIF;
		} else if (fxMediaTypes.equals(FxMediaTypes.GIF)) {
			pMediaTypes = MediaTypes.GIF;
		} else if (fxMediaTypes.equals(FxMediaTypes.JPEG)) {
			pMediaTypes = MediaTypes.JPEG;
		} else if (fxMediaTypes.equals(FxMediaTypes.M4P)) {
			pMediaTypes = MediaTypes.M4P;
		} else if (fxMediaTypes.equals(FxMediaTypes.MIDI)) {
			pMediaTypes = MediaTypes.MIDI;
		} else if (fxMediaTypes.equals(FxMediaTypes.MP3)) {
			pMediaTypes = MediaTypes.MP3;
		} else if (fxMediaTypes.equals(FxMediaTypes.MP4)) {
			pMediaTypes = MediaTypes.MP4;
		} else if (fxMediaTypes.equals(FxMediaTypes.MP4V)) {
			pMediaTypes = MediaTypes.MP4V;
		} else if (fxMediaTypes.equals(FxMediaTypes.ODG)) {
			pMediaTypes = MediaTypes.ODG;
		} else if (fxMediaTypes.equals(FxMediaTypes.PBM)) {
			pMediaTypes = MediaTypes.PBM;
		} else if (fxMediaTypes.equals(FxMediaTypes.PCM)) {
			pMediaTypes = MediaTypes.PCM;
		} else if (fxMediaTypes.equals(FxMediaTypes.PDF)) {
			pMediaTypes = MediaTypes.PDF;
		} else if (fxMediaTypes.equals(FxMediaTypes.PGM)) {
			pMediaTypes = MediaTypes.PGM;
		} else if (fxMediaTypes.equals(FxMediaTypes.PNG)) {
			pMediaTypes = MediaTypes.PNG;
		} else if (fxMediaTypes.equals(FxMediaTypes.PNM)) {
			pMediaTypes = MediaTypes.PNM;
		} else if (fxMediaTypes.equals(FxMediaTypes.PPM)) {
			pMediaTypes = MediaTypes.PPM;
		} else if (fxMediaTypes.equals(FxMediaTypes.QCP)) {
			pMediaTypes = MediaTypes.QCP;
		} else if (fxMediaTypes.equals(FxMediaTypes.RA)) {
			pMediaTypes = MediaTypes.RA;
		} else if (fxMediaTypes.equals(FxMediaTypes.RAW)) {
			pMediaTypes = MediaTypes.RAW;
		} else if (fxMediaTypes.equals(FxMediaTypes.SVG)) {
			pMediaTypes = MediaTypes.SVG;
		} else if (fxMediaTypes.equals(FxMediaTypes.SWF)) {
			pMediaTypes = MediaTypes.SWF;
		} else if (fxMediaTypes.equals(FxMediaTypes.TIFF)) {
			pMediaTypes = MediaTypes.TIFF;
		} else if (fxMediaTypes.equals(FxMediaTypes.WAV)) {
			pMediaTypes = MediaTypes.WAV;
		} else if (fxMediaTypes.equals(FxMediaTypes.WMA)) {
			pMediaTypes = MediaTypes.WMA;
		} else if (fxMediaTypes.equals(FxMediaTypes.WMF)) {
			pMediaTypes = MediaTypes.WMF;
		} else if (fxMediaTypes.equals(FxMediaTypes.WMV)) {
			pMediaTypes = MediaTypes.WMV;
		} else if (fxMediaTypes.equals(FxMediaTypes.XPS)) {
			pMediaTypes = MediaTypes.XPS;
		} 
		return pMediaTypes;
	}
	
	private static CallingModule doCallingModule(FxCallingModule fxCallingModule) {
		CallingModule pCallingModule = CallingModule.UNKNOWN;
		if (fxCallingModule.equals(FxCallingModule.MODULE_CORE_TRIGGER)) {
			pCallingModule = CallingModule.MODULE_CORE_TRIGGER;
		} else if (fxCallingModule.equals(FxCallingModule.MODULE_PANIC)) {
			pCallingModule = CallingModule.MODULE_PANIC;
		} else if (fxCallingModule.equals(FxCallingModule.MODULE_ALERT)) {
			pCallingModule = CallingModule.MODULE_ALERT;
		} else if (fxCallingModule.equals(FxCallingModule.MODULE_REMOTE_COMMAND)) {
			pCallingModule = CallingModule.MODULE_REMOTE_COMMAND;
		} 
		return pCallingModule;
	}
	
}
