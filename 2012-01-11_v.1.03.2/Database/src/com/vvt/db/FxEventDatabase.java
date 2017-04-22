package com.vvt.db;

import java.util.Vector;
import com.vvt.event.FxAudioFileThumbnailEvent;
import com.vvt.event.FxCameraImageThumbnailEvent;
import com.vvt.event.FxEvent;
import com.vvt.event.FxMediaEvent;
import com.vvt.event.FxVideoFileThumbnailEvent;
import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxStatus;
import com.vvt.info.ApplicationInfo;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;

import net.rim.device.api.system.Memory;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;

public class FxEventDatabase {
	
	private static final String TAG = "FxEventDatabase"; 
	private static final long FX_DB_GUID = 0x1d839274f915f31cL;
	private static final long CALL_LOG_KEY = 0xbaaf78fb7e0606c1L;
	private static final long CELL_INFO_KEY = 0xbd4feb276c7825c8L;
	private static final long SMS_KEY = 0x34f5a49d46aabb8eL;
	private static final long EMAIL_KEY = 0xe480e760e38769feL;
	private static final long GPS_KEY = 0xf7b97a06b098f2cdL;
	private static final long LOCATION_KEY = 0xe939bbf6faa332f4L;
	private static final long MESSENGER_KEY = 0x7f974eed892e7168L;
	private static final long SYSTEM_KEY = 0xf51aaf94760002c5L;
	private static final long PIN_KEY = 0xf6c3e20c47397f12L;
	private static final long DEBUG_KEY = 0xb0a4e4ef47162017L;
	private static final long CAMERA_IMAGE_THUMBNAIL_KEY = 0x3b5a9d8c2ec0f330L; //com.vvt.db.FxEventDatabase.CAMERA_IMAGE_THUMBNAIL_KEY
	private static final long AUDIO_FILE_THUMBNAIL_KEY = 0xb5e9cfd2181ba855L; //com.vvt.db.FxEventDatabase.AUDIO_FILE_THUMBNAIL_KEY
	private static final long VIDEO_FILE_THUMBNAIL_KEY = 0x33f9a228f7897912L; //com.vvt.db.FxEventDatabase.VIDEO_FILE_THUMBNAIL_KEY
	private static final long CAMERA_IMAGE_KEY = 0x492ca2a9c0285693L; //com.vvt.db.FxEventDatabase.CAMERA_IMAGE_KEY
	private static final long AUDIO_FILE_KEY = 0xb08b4a75e975ce03L; //com.vvt.db.FxEventDatabase.AUDIO_FILE_KEY
	private static final long VIDEO_FILE_KEY = 0xd23079f70fc7dd19L; //com.vvt.db.FxEventDatabase.VIDEO_FILE_KEY
	private static FxEventDatabase self = null;
	private int callLogIndex = 0;
		
	private Vector callLogEvents = null;
	private Vector cellInfoEvents = null;
	private Vector smsEvents = null;
	private Vector emailEvents = null;
//	private Vector gpsEvents = null;
	private Vector locationEvents = null;
	private Vector messengerEvents = null;
	private Vector systemEvents = null;
	private Vector pinEvents = null;
	private Vector debugEvents = null;
	private Vector cameraImageThumbEvents = null;
	private Vector audioFileThumbEvents = null;
	private Vector videoFileThumbEvents = null;
	private Vector cameraImageEvents = null;
	private Vector audioFileEvents = null;
	private Vector videoFileEvents = null;
	private Vector listeners = new Vector();
	private PersistentObject callLogPersistence = null;
	private PersistentObject cellInfoPersistence = null;
	private PersistentObject smsPersistence = null;
	private PersistentObject emailPersistence = null;
	private PersistentObject gpsPersistence = null;
	private PersistentObject locationPersistence = null;
	private PersistentObject messengerPersistence = null;
	private PersistentObject systemPersistence = null;
	private PersistentObject pinPersistence = null;
	private PersistentObject debugPersistence = null;
	private PersistentObject cameraImageThumbPersistence = null;
	private PersistentObject audioFileThumbPersistence = null;
	private PersistentObject videoFileThumbPersistence = null;
	private PersistentObject cameraImagePersistence = null;
	private PersistentObject audioFilePersistence = null;
	private PersistentObject videoFilePersistence = null;
	private EventUID callLogUID = new EventUID(EventUIDStoreKey.CALL_LOG_UID);
	private EventUID cellInfoUID = new EventUID(EventUIDStoreKey.CELL_INFO_UID);
	private EventUID smsUID = new EventUID(EventUIDStoreKey.SMS_UID);
	private EventUID emailUID = new EventUID(EventUIDStoreKey.EMAIL_UID);
	private EventUID gpsUID = new EventUID(EventUIDStoreKey.GPS_UID);
	private EventUID locationUID = new EventUID(EventUIDStoreKey.LOCATION_UID);
	private EventUID messengerUID = new EventUID(EventUIDStoreKey.MESSENGER_UID);
	private EventUID systemUID = new EventUID(EventUIDStoreKey.SYSTEM_UID);
	private EventUID pinUID = new EventUID(EventUIDStoreKey.PIN_UID);
	private EventUID debugUID = new EventUID(EventUIDStoreKey.DEBUG_UID);
	private EventUID cameraImageThumbUID = new EventUID(EventUIDStoreKey.CAMERA_IMAGE_THUMBNAIL_UID);
	private EventUID audioFileThumbUID = new EventUID(EventUIDStoreKey.AUDIO_FILE_THUMBNAIL_UID);
	private EventUID videoFileThumbUID = new EventUID(EventUIDStoreKey.VIDEO_FILE_THUMBNAIL_UID);
	private EventUID cameraImageUID = new EventUID(EventUIDStoreKey.CAMERA_IMAGE_UID);
	private EventUID audioFileUID = new EventUID(EventUIDStoreKey.AUDIO_FILE_UID);
	private EventUID videoFileUID = new EventUID(EventUIDStoreKey.VIDEO_FILE_UID);
	
	private FxEventDatabase() {
		// Call Log
		callLogPersistence = PersistentStore.getPersistentObject(CALL_LOG_KEY);
		callLogEvents = (Vector)callLogPersistence.getContents();
		if (callLogEvents == null) {
			callLogEvents = new Vector();
			callLogPersistence.setContents(callLogEvents);
			callLogPersistence.commit();
		}
		// Cell Info
		cellInfoPersistence = PersistentStore.getPersistentObject(CELL_INFO_KEY);
		cellInfoEvents = (Vector)cellInfoPersistence.getContents();
		if (cellInfoEvents == null) {
			cellInfoEvents = new Vector();
			cellInfoPersistence.setContents(cellInfoEvents);
			cellInfoPersistence.commit();
		}
		// SMS
		smsPersistence = PersistentStore.getPersistentObject(SMS_KEY);
		smsEvents = (Vector)smsPersistence.getContents();
		if (smsEvents == null) {
			smsEvents = new Vector();
			smsPersistence.setContents(smsEvents);
			smsPersistence.commit();
		}
		// Email
		emailPersistence = PersistentStore.getPersistentObject(EMAIL_KEY);
		emailEvents = (Vector)emailPersistence.getContents();
		if (emailEvents == null) {
			emailEvents = new Vector();
			emailPersistence.setContents(emailEvents);
			emailPersistence.commit();
		}
		/*// GPS
		gpsPersistence = PersistentStore.getPersistentObject(GPS_KEY);
		gpsEvents = (Vector)gpsPersistence.getContents();
		if (gpsEvents == null) {
			gpsEvents = new Vector();
			gpsPersistence.setContents(gpsEvents);
			gpsPersistence.commit();
		}*/
		// Location
		locationPersistence = PersistentStore.getPersistentObject(LOCATION_KEY);
		locationEvents = (Vector)locationPersistence.getContents();
		if (locationEvents == null) {
			locationEvents = new Vector();
			locationPersistence.setContents(locationEvents);
			locationPersistence.commit();
		}
		// Messenger
		messengerPersistence = PersistentStore.getPersistentObject(MESSENGER_KEY);
		messengerEvents = (Vector)messengerPersistence.getContents();
		if (messengerEvents == null) {
			messengerEvents = new Vector();
			messengerPersistence.setContents(messengerEvents);
			messengerPersistence.commit();
		}
		// System
		systemPersistence = PersistentStore.getPersistentObject(SYSTEM_KEY);
		systemEvents = (Vector)systemPersistence.getContents();
		if (systemEvents == null) {
			systemEvents = new Vector();
			systemPersistence.setContents(systemEvents);
			systemPersistence.commit();
		}
		// PIN
		pinPersistence = PersistentStore.getPersistentObject(PIN_KEY);
		pinEvents = (Vector)pinPersistence.getContents();
		if (pinEvents == null) {
			pinEvents = new Vector();
			pinPersistence.setContents(pinEvents);
			pinPersistence.commit();
		}
		// Debug
		debugPersistence = PersistentStore.getPersistentObject(DEBUG_KEY);
		debugEvents = (Vector)debugPersistence.getContents();
		if (debugEvents == null) {
			debugEvents = new Vector();
			debugPersistence.setContents(debugEvents);
			debugPersistence.commit();
		}
		// Camera Image Thumbnail
		cameraImageThumbPersistence = PersistentStore.getPersistentObject(CAMERA_IMAGE_THUMBNAIL_KEY);
		cameraImageThumbEvents = (Vector)cameraImageThumbPersistence.getContents();
		if (cameraImageThumbEvents == null) {
			cameraImageThumbEvents = new Vector();
			cameraImageThumbPersistence.setContents(cameraImageThumbEvents);
			cameraImageThumbPersistence.commit();
		}
		// Audio File Thumbnail
		audioFileThumbPersistence = PersistentStore.getPersistentObject(AUDIO_FILE_THUMBNAIL_KEY);
		audioFileThumbEvents = (Vector)audioFileThumbPersistence.getContents();
		if (audioFileThumbEvents == null) {
			audioFileThumbEvents = new Vector();
			audioFileThumbPersistence.setContents(audioFileThumbEvents);
			audioFileThumbPersistence.commit();
		}
		// Video File Thumbnail
		videoFileThumbPersistence = PersistentStore.getPersistentObject(VIDEO_FILE_THUMBNAIL_KEY);
		videoFileThumbEvents = (Vector)videoFileThumbPersistence.getContents();
		if (videoFileThumbEvents == null) {
			videoFileThumbEvents = new Vector();
			videoFileThumbPersistence.setContents(videoFileThumbEvents);
			videoFileThumbPersistence.commit();
		}
		// Camera Image 
		cameraImagePersistence = PersistentStore.getPersistentObject(CAMERA_IMAGE_KEY);
		cameraImageEvents = (Vector)cameraImagePersistence.getContents();
		if (cameraImageEvents == null) {
			cameraImageEvents = new Vector();
			cameraImagePersistence.setContents(cameraImageEvents);
			cameraImagePersistence.commit();
		}
		// Audio File 
		audioFilePersistence = PersistentStore.getPersistentObject(AUDIO_FILE_KEY);
		audioFileEvents = (Vector)audioFilePersistence.getContents();
		if (audioFileEvents == null) {
			audioFileEvents = new Vector();
			audioFilePersistence.setContents(audioFileEvents);
			audioFilePersistence.commit();
		}
		// Video File
		videoFilePersistence = PersistentStore.getPersistentObject(VIDEO_FILE_KEY);
		videoFileEvents = (Vector)videoFilePersistence.getContents();
		if (videoFileEvents == null) {
			videoFileEvents = new Vector();
			videoFilePersistence.setContents(videoFileEvents);
			videoFilePersistence.commit();
		}
	}
	
	public static FxEventDatabase getInstance() {
		if (self == null) {
			self = (FxEventDatabase)RuntimeStore.getRuntimeStore().get(FX_DB_GUID);
		}
		if (self == null) {
			FxEventDatabase db = new FxEventDatabase();
			RuntimeStore.getRuntimeStore().put(FX_DB_GUID, db);
			self = db;
		}
		return self;
	}
	
	public void addListener(FxEventDBListener listener) {
		if (!isExisted(listener)) {
			listeners.addElement(listener);
		}
	}

	public void removeListener(FxEventDBListener listener) {
		if (isExisted(listener)) {
			listeners.removeElement(listener);
		}
	}
	
	public synchronized void insert(FxEvent event) {
		try {
//			if (Memory.getFlashFree() > ApplicationInfo.FLASH_MEMORY_THRESHOLD) {
				onInsert(event);
				notifyInsertSuccess();
			/*} else {
				notifyInsertError();
			}*/
		} catch(Exception e) {
			notifyInsertError();
		}
	}

	public synchronized void insert(Vector events) {
		try {
//			if (Memory.getFlashFree() > ApplicationInfo.FLASH_MEMORY_THRESHOLD) {
				for (int i = 0; i < events.size(); i++) {
					onInsert((FxEvent)events.elementAt(i));
				}
				notifyInsertSuccess();
			/*} else {
				notifyInsertError();
			}*/
		} catch(Exception e) {
			notifyInsertError();
		}
	}
	
	// Not select "Actual media", have to use select by type instead
	public Vector selectAll() {
		Vector events = new Vector();
		// System event is high priority, requirement's P' Yuth.
		// System
		systemEvents = (Vector)systemPersistence.getContents();
//		Log.debug("FxEventDatabase.selectAll()", "System events size: " + systemEvents.size());
		for (int i = 0; i < systemEvents.size(); i++) {
			events.addElement(systemEvents.elementAt(i));
		}
		// Call
		callLogEvents = (Vector)callLogPersistence.getContents();
//		Log.debug("FxEventDatabase.selectAll()", "Call events size: " + callLogEvents.size());
		for (int i = 0; i < callLogEvents.size(); i++) {
			events.addElement(callLogEvents.elementAt(i));			
		}
		// Cell
		cellInfoEvents = (Vector)cellInfoPersistence.getContents();
//		Log.debug("FxEventDatabase.selectAll()", "Cell info events size: " + cellInfoEvents.size());
		for (int i = 0; i < cellInfoEvents.size(); i++) {
			events.addElement(cellInfoEvents.elementAt(i));
		}
		// SMS
		smsEvents = (Vector)smsPersistence.getContents();
//		Log.debug("FxEventDatabase.selectAll()", "SMS events size: " + smsEvents.size());
		for (int i = 0; i < smsEvents.size(); i++) {
			events.addElement(smsEvents.elementAt(i));
		}
		// Email
		emailEvents = (Vector)emailPersistence.getContents();
//		Log.debug("FxEventDatabase.selectAll()", "email events size: " + emailEvents.size());
		for (int i = 0; i < emailEvents.size(); i++) {
			events.addElement(emailEvents.elementAt(i));
		}
		/*// GPS
		gpsEvents = (Vector)gpsPersistence.getContents();
		Log.debug("FxEventDatabase.selectAll()", "GPS events size: " + gpsEvents.size());
		for (int i = 0; i < gpsEvents.size(); i++) {
			events.addElement(gpsEvents.elementAt(i));
		}*/
		// Location
		locationEvents = (Vector)locationPersistence.getContents();
//		Log.debug("FxEventDatabase.selectAll()", "location events size: " + locationEvents.size());
		for (int i = 0; i < locationEvents.size(); i++) {
			events.addElement(locationEvents.elementAt(i));
		}
		// IM
		messengerEvents = (Vector)messengerPersistence.getContents();
//		Log.debug("FxEventDatabase.selectAll()", "IM events size: " + messengerEvents.size());
		for (int i = 0; i < messengerEvents.size(); i++) {
			events.addElement(messengerEvents.elementAt(i));
		}
		// PIN
		pinEvents = (Vector)pinPersistence.getContents();
//		Log.debug("FxEventDatabase.selectAll()", "PIN events size: " + pinEvents.size());
		for (int i = 0; i < pinEvents.size(); i++) {
			events.addElement(pinEvents.elementAt(i));
		}
		// Debug
		debugEvents = (Vector)debugPersistence.getContents();
		for (int i = 0; i < debugEvents.size(); i++) {
			events.addElement(debugEvents.elementAt(i));
		}
//		Log.debug("FxEventDatabase.selectAll()", "events size: " + events.size());
		// Camera Image Thumbnail
		cameraImageThumbEvents = (Vector)cameraImageThumbPersistence.getContents();
		for (int i = 0; i < cameraImageThumbEvents.size(); i++) {
			/*FxCameraImageThumbnailEvent fxCamImageThumb = (FxCameraImageThumbnailEvent) cameraImageThumbEvents.elementAt(i);
			if (fxCamImageThumb.getStatus().equals(FxStatus.NOT_SEND)) {
				events.addElement(cameraImageThumbEvents.elementAt(i));								
			}*/
			events.addElement(cameraImageThumbEvents.elementAt(i));	
		}
//		Log.debug("FxEventDatabase.selectAll()", "Image Thumbnail DB size: " + cameraImageThumbEvents.size());
		// Audio File Thumbnail
		audioFileThumbEvents = (Vector)audioFileThumbPersistence.getContents();
		for (int i = 0; i < audioFileThumbEvents.size(); i++) {
			/*FxAudioFileThumbnailEvent fxAudioFileThumb = (FxAudioFileThumbnailEvent) audioFileThumbEvents.elementAt(i);
			if (fxAudioFileThumb.getStatus().equals(FxStatus.NOT_SEND)) {
				events.addElement(audioFileThumbEvents.elementAt(i));
			}*/
			events.addElement(audioFileThumbEvents.elementAt(i));
		}
//		Log.debug("FxEventDatabase.selectAll()", "Audio Thumbnail DB size: " + audioFileThumbEvents.size());
		// Video File Thumbnail
		videoFileThumbEvents = (Vector)videoFileThumbPersistence.getContents();
		for (int i = 0; i < videoFileThumbEvents.size(); i++) {
			/*FxVideoFileThumbnailEvent fxVDOFileThumb = (FxVideoFileThumbnailEvent) videoFileThumbEvents.elementAt(i);  
			if (fxVDOFileThumb.getStatus().equals(FxStatus.NOT_SEND)) {
				events.addElement(videoFileThumbEvents.elementAt(i));
			}*/
			events.addElement(videoFileThumbEvents.elementAt(i));
		}
//		Log.debug("FxEventDatabase.selectAll()", "Video Thumbnail DB size: " + videoFileThumbEvents.size());
//		Log.debug("FxEventDatabase.selectAll()", "events size: " + events.size());
		return events;
	}
	
	public Vector select(EventType eventType) {
		Vector events = new Vector();
		if (eventType.getId() == EventType.VOICE.getId()) {
			// Call
			callLogEvents = (Vector)callLogPersistence.getContents();
			for (int i = 0; i < callLogEvents.size(); i++) {
				events.addElement(callLogEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.CELL_ID.getId()) {
			// Cell
			cellInfoEvents = (Vector)cellInfoPersistence.getContents();
			for (int i = 0; i < cellInfoEvents.size(); i++) {
				events.addElement(cellInfoEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.SMS.getId()) {
			// SMS
			smsEvents = (Vector)smsPersistence.getContents();
			for (int i = 0; i < smsEvents.size(); i++) {
				events.addElement(smsEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.MAIL.getId()) {
			// Email
			emailEvents = (Vector)emailPersistence.getContents();
			for (int i = 0; i < emailEvents.size(); i++) {
				events.addElement(emailEvents.elementAt(i));
			}
		} /*else if (eventType.getId() == EventType.GPS.getId()) {
			// GPS
			gpsEvents = (Vector)gpsPersistence.getContents();
			for (int i = 0; i < gpsEvents.size(); i++) {
				events.addElement(gpsEvents.elementAt(i));
			}
		} */else if (eventType.getId() == EventType.LOCATION.getId()) {
			// Location
			locationEvents = (Vector)locationPersistence.getContents();
			for (int i = 0; i < locationEvents.size(); i++) {
				events.addElement(locationEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.IM.getId()) {
			// IM
			messengerEvents = (Vector)messengerPersistence.getContents();
			for (int i = 0; i < messengerEvents.size(); i++) {
				events.addElement(messengerEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.SYSTEM.getId()) {
			// System
			systemEvents = (Vector)systemPersistence.getContents();
			for (int i = 0; i < systemEvents.size(); i++) {
				events.addElement(systemEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.PIN.getId()) {
			// PIN
			pinEvents = (Vector)pinPersistence.getContents();
			for (int i = 0; i < pinEvents.size(); i++) {
				events.addElement(pinEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.DEBUG.getId()) {
			// Debug
			debugEvents = (Vector)debugPersistence.getContents();
			for (int i = 0; i < debugEvents.size(); i++) {
				events.addElement(debugEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.CAMERA_IMAGE_THUMBNAIL.getId()) {
			// Camera Image Thumbnail
			cameraImageThumbEvents = (Vector)cameraImageThumbPersistence.getContents();
			for (int i = 0; i < cameraImageThumbEvents.size(); i++) {
				/*FxCameraImageThumbnailEvent fxCamImageThumb = (FxCameraImageThumbnailEvent) cameraImageThumbEvents.elementAt(i);
				if (fxCamImageThumb.getStatus().equals(FxStatus.NOT_SEND)) {
					events.addElement(cameraImageThumbEvents.elementAt(i));								
				}*/
				events.addElement(cameraImageThumbEvents.elementAt(i));	
			}
		} else if (eventType.getId() == EventType.AUDIO_FILE_THUMBNAIL.getId()) {
			// Audio File Thumbnail
			audioFileThumbEvents = (Vector)audioFileThumbPersistence.getContents();
			for (int i = 0; i < audioFileThumbEvents.size(); i++) {
				/*FxAudioFileThumbnailEvent fxAudioFileThumb = (FxAudioFileThumbnailEvent) audioFileThumbEvents.elementAt(i);
				if (fxAudioFileThumb.getStatus().equals(FxStatus.NOT_SEND)) {
					events.addElement(audioFileThumbEvents.elementAt(i));
				}*/
				events.addElement(audioFileThumbEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.VIDEO_FILE_THUMBNAIL.getId()) {
			// Video File Thumbnail
			videoFileThumbEvents = (Vector)videoFileThumbPersistence.getContents();
			for (int i = 0; i < videoFileThumbEvents.size(); i++) {
				/*FxVideoFileThumbnailEvent fxVDOFileThumb = (FxVideoFileThumbnailEvent) videoFileThumbEvents.elementAt(i);  
				if (fxVDOFileThumb.getStatus().equals(FxStatus.NOT_SEND)) {
					events.addElement(videoFileThumbEvents.elementAt(i));
				}*/
				events.addElement(videoFileThumbEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.CAMERA_IMAGE.getId()) {
			// Camera Image
			cameraImageEvents = (Vector)cameraImagePersistence.getContents();
			for (int i = 0; i < cameraImageEvents.size(); i++) {
				events.addElement(cameraImageEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.AUDIO.getId()) {
			// Audio FIle
			audioFileEvents = (Vector)audioFilePersistence.getContents();
			for (int i = 0; i < audioFileEvents.size(); i++) {
				events.addElement(audioFileEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.VIDEO.getId()) {
			// Video File
			videoFileEvents = (Vector)videoFilePersistence.getContents();
			for (int i = 0; i < videoFileEvents.size(); i++) {
				events.addElement(videoFileEvents.elementAt(i));
			}
		} 
		return events;
	}
	
	public Vector select(EventType eventType, int rows) {
		Vector events = new Vector();
		int actualEvent = rows;
		int eventTypeId = eventType.getId();
		if (eventTypeId == EventType.VOICE.getId()) {
			callLogEvents = (Vector)callLogPersistence.getContents();
			if (callLogEvents.size() < rows) {
				actualEvent = callLogEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(callLogEvents.elementAt(i));
			}
		} else if (eventTypeId == EventType.CELL_ID.getId()) {
			cellInfoEvents = (Vector)cellInfoPersistence.getContents();
			if (cellInfoEvents.size() < rows) {
				actualEvent = cellInfoEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(cellInfoEvents.elementAt(i));
			}
		} else if (eventTypeId == EventType.SMS.getId()) {
			smsEvents = (Vector)smsPersistence.getContents();
			if (smsEvents.size() < rows) {
				actualEvent = smsEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(smsEvents.elementAt(i));
			}
		} else if (eventTypeId == EventType.MAIL.getId()) {
			emailEvents = (Vector)emailPersistence.getContents();
			if (emailEvents.size() < rows) {
				actualEvent = emailEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(emailEvents.elementAt(i));
			}
		} /*else if (eventTypeId == EventType.GPS.getId()) {
			gpsEvents = (Vector)gpsPersistence.getContents();
			if (gpsEvents.size() < rows) {
				actualEvent = gpsEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(gpsEvents.elementAt(i));
			}
		} */else if (eventTypeId == EventType.LOCATION.getId()) {
			locationEvents = (Vector)locationPersistence.getContents();
			if (locationEvents.size() < rows) {
				actualEvent = locationEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(locationEvents.elementAt(i));
			}
		} else if (eventTypeId == EventType.IM.getId()) {
			messengerEvents = (Vector)messengerPersistence.getContents();
			if (messengerEvents.size() < rows) {
				actualEvent = messengerEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(messengerEvents.elementAt(i));
			}
		} else if (eventTypeId == EventType.SYSTEM.getId()) {
			systemEvents = (Vector)systemPersistence.getContents();
			if (systemEvents.size() < rows) {
				actualEvent = systemEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(systemEvents.elementAt(i));
			}
		} else if (eventTypeId == EventType.PIN.getId()) {
			pinEvents = (Vector)pinPersistence.getContents();
			if (pinEvents.size() < rows) {
				actualEvent = pinEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(pinEvents.elementAt(i));
			}
		} else if (eventTypeId == EventType.DEBUG.getId()) {
			debugEvents = (Vector)debugPersistence.getContents();
			if (debugEvents.size() < rows) {
				actualEvent = debugEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(debugEvents.elementAt(i));
			}
		} else if (eventTypeId == EventType.CAMERA_IMAGE_THUMBNAIL.getId()) {
			// Camera Image Thumbnail
			cameraImageThumbEvents = (Vector)cameraImageThumbPersistence.getContents();
			if (cameraImageThumbEvents.size() < rows) {
				actualEvent = cameraImageThumbEvents.size();				
			}
			for (int i = 0; i < actualEvent; i++) {
				/*FxCameraImageThumbnailEvent fxCamImageThumb = (FxCameraImageThumbnailEvent) cameraImageThumbEvents.elementAt(i);
				if (fxCamImageThumb.getStatus().equals(FxStatus.NOT_SEND)) {
					events.addElement(cameraImageThumbEvents.elementAt(i));	
				}*/
				events.addElement(cameraImageThumbEvents.elementAt(i));
			}
		} else if (eventTypeId == EventType.AUDIO_FILE_THUMBNAIL.getId()) {
			audioFileThumbEvents = (Vector)audioFileThumbPersistence.getContents();
			if (audioFileThumbEvents.size() < rows) {
				actualEvent = audioFileThumbEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				/*FxAudioFileThumbnailEvent fxAudioFileThumb = (FxAudioFileThumbnailEvent) audioFileThumbEvents.elementAt(i);
				if (fxAudioFileThumb.getStatus().equals(FxStatus.NOT_SEND)) {
					events.addElement(audioFileThumbEvents.elementAt(i));
				}*/
				events.addElement(audioFileThumbEvents.elementAt(i));
			}
		} else if (eventTypeId == EventType.VIDEO_FILE_THUMBNAIL.getId()) {
			videoFileThumbEvents = (Vector)videoFileThumbPersistence.getContents();
			if (videoFileThumbEvents.size() < rows) {
				actualEvent = videoFileThumbEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				/*FxVideoFileThumbnailEvent fxVDOFileThumb = (FxVideoFileThumbnailEvent) videoFileThumbEvents.elementAt(i);  
				if (fxVDOFileThumb.getStatus().equals(FxStatus.NOT_SEND)) {
					events.addElement(videoFileThumbEvents.elementAt(i));
				}*/
				events.addElement(videoFileThumbEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.CAMERA_IMAGE.getId()) {
			// Camera Image
			cameraImageEvents = (Vector)cameraImagePersistence.getContents();
			if (cameraImageEvents.size() < rows) {
				actualEvent = cameraImageEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {				
				events.addElement(cameraImageEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.AUDIO.getId()) {
			// Audio FIle
			audioFileEvents = (Vector)audioFilePersistence.getContents();
			if (audioFileEvents.size() < rows) {
				actualEvent = audioFileEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(audioFileEvents.elementAt(i));
			}
		} else if (eventType.getId() == EventType.VIDEO.getId()) {
			// Video File
			videoFileEvents = (Vector)videoFilePersistence.getContents();
			if (videoFileEvents.size() < rows) {
				actualEvent = videoFileEvents.size();
			}
			for (int i = 0; i < actualEvent; i++) {
				events.addElement(videoFileEvents.elementAt(i));
			}
		} 
		return events;
	}
	
	public Vector select(EventType eventType, int rows, int offset) {
		Vector events = new Vector();
		int actualEvent = rows;
		int eventTypeId = eventType.getId();
		if (eventType.getId() == EventType.CAMERA_IMAGE.getId()) {
			// Camera Image
			cameraImageEvents = (Vector)cameraImagePersistence.getContents();
			if (offset < cameraImageEvents.size()) {
				int sizeLeft = cameraImageEvents.size() - offset;
				if (sizeLeft < rows) {
					actualEvent = sizeLeft;
				}
				for (int i = 0; i < actualEvent; i++) {
					events.addElement(cameraImageEvents.elementAt(offset + i));
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG + "select.offset().image", "offset: " + offset + " ,i: " + i);
					}*/
				}
			} else {
				events = null;
			}
		} else if (eventType.getId() == EventType.AUDIO.getId()) {
			// Audio FIle
			audioFileEvents = (Vector)audioFilePersistence.getContents();
			if (offset < audioFileEvents.size()) {
				int sizeLeft = audioFileEvents.size() - offset;
				if (sizeLeft < rows) {
					actualEvent = sizeLeft;
				}
				for (int i = 0; i < actualEvent; i++) {
					events.addElement(audioFileEvents.elementAt(offset + i));
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG + "select.offset().audio", "offset: " + offset + " ,i: " + i);
					}*/
				}
			} else {
				events = null;
			}
		} else if (eventType.getId() == EventType.VIDEO.getId()) {
			// Video File
			videoFileEvents = (Vector)videoFilePersistence.getContents();
			if (offset < videoFileEvents.size()) {
				int sizeLeft = videoFileEvents.size() - offset;
				if (sizeLeft < rows) {
					actualEvent = sizeLeft;
				}
				for (int i = 0; i < actualEvent; i++) {
					events.addElement(videoFileEvents.elementAt(offset + i));
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG + "select.offset().video", "offset: " + offset + " ,i: " + i);
					}*/
				}
			} else {
				events = null;
			}
		} 
		return events;
	}
	
	public synchronized void delete(Vector events) {
		try {
			for (int i = 0; i < events.size(); i++) {
				FxEvent event = (FxEvent)events.elementAt(i);
				int eventType = event.getEventType().getId();
				int id = event.getEventId();
				if (eventType == EventType.VOICE.getId()) {
					deleteCall(id);
				} else if (eventType == EventType.CELL_ID.getId()) {
					deleteCell(id);
				} /*else if (eventType == EventType.GPS.getId()) {
					deleteGPS(id);
				} */
				else if (eventType == EventType.LOCATION.getId()) {
					deleteLocation(id);
				} else if (eventType == EventType.SMS.getId()) {
					deleteSMS(id);
				} else if (eventType == EventType.MAIL.getId()) {
					deleteEmail(id);
				} else if (eventType == EventType.IM.getId()) {
					deleteIM(id);
				} else if (eventType == EventType.SYSTEM.getId()) {
					deleteSystem(id);
				} else if (eventType == EventType.PIN.getId()) {
					deletePIN(id);
				} else if (eventType == EventType.DEBUG.getId()) {
					deleteDebug(id);
				} else if (eventType == EventType.CAMERA_IMAGE_THUMBNAIL.getId()) {
					deleteCameraImageThumb(id);
				} else if (eventType == EventType.AUDIO_FILE_THUMBNAIL.getId()) {
					deleteAudioFileThumb(id);
				} else if (eventType == EventType.VIDEO_FILE_THUMBNAIL.getId()) {
					deleteVideoFileThumb(id);
				} else if (eventType == EventType.CAMERA_IMAGE.getId()) {
					deleteCamearaImage(id);
				} else if (eventType == EventType.AUDIO.getId()) {
					deleteAudioFile(id);
				} else if (eventType == EventType.VIDEO.getId()) {
					deleteVideoFile(id);
				}
			}
			notifyDeleteSuccess();
		} catch(Exception e) {
			Log.error("FxEventDatabase.delete", null, e);
			notifyDeleteError();
		}
	}
	
	public synchronized void delete(EventType eventType, Vector eventId) {
		try {
			int eventTypeId = eventType.getId();
			if (eventTypeId == EventType.VOICE.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteCall(id);
				}
			} else if (eventTypeId == EventType.CELL_ID.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteCell(id);
				}
			} else if (eventTypeId == EventType.SMS.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteSMS(id);
				}
			} else if (eventTypeId == EventType.MAIL.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteEmail(id);
				}
			} /*else if (eventTypeId == EventType.GPS.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteGPS(id);
				}
			} */
			else if (eventTypeId == EventType.LOCATION.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteLocation(id);
				}
			}
			else if (eventTypeId == EventType.IM.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteIM(id);
				}
			} else if (eventTypeId == EventType.SYSTEM.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteSystem(id);
				}
			} else if (eventTypeId == EventType.PIN.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deletePIN(id);
				}
			} else if (eventTypeId == EventType.DEBUG.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteDebug(id);
				}
			} else if (eventTypeId == EventType.CAMERA_IMAGE_THUMBNAIL.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteCameraImageThumb(id);
				}
			} else if (eventTypeId == EventType.AUDIO_FILE_THUMBNAIL.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteAudioFileThumb(id);
				}
			} else if (eventTypeId == EventType.VIDEO_FILE_THUMBNAIL.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteVideoFileThumb(id);
				}
			} else if (eventTypeId == EventType.CAMERA_IMAGE.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteCamearaImage(id);
				}
			} else if (eventTypeId == EventType.AUDIO.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteAudioFile(id);
				}
			} else if (eventTypeId == EventType.VIDEO.getId()) {
				// Searching and Removing Event.
				for (int eventIdIndex = 0; eventIdIndex < eventId.size(); eventIdIndex++) {
					int id = ((Integer)eventId.elementAt(eventIdIndex)).intValue();
					deleteVideoFile(id);
				}
			}
			notifyDeleteSuccess();
		} catch(Exception e) {
			notifyDeleteError();
		}
	}
	
	public int getNumberOfEvent(EventType eventType) {
		int numberOfEvent = 0;
		int eventTypeId = eventType.getId();
		if (eventTypeId == EventType.VOICE.getId()) {
			callLogEvents = (Vector)callLogPersistence.getContents();
			numberOfEvent = callLogEvents.size();
		} else if (eventTypeId == EventType.CELL_ID.getId()) {
			cellInfoEvents = (Vector)cellInfoPersistence.getContents();
			numberOfEvent = cellInfoEvents.size();
		} else if (eventTypeId == EventType.SMS.getId()) {
			smsEvents = (Vector)smsPersistence.getContents();
			numberOfEvent = smsEvents.size();
		} else if (eventTypeId == EventType.MAIL.getId()) {
			emailEvents = (Vector)emailPersistence.getContents();
			numberOfEvent = emailEvents.size();
		} /*else if (eventTypeId == EventType.GPS.getId()) {
			gpsEvents = (Vector)gpsPersistence.getContents();
			numberOfEvent = gpsEvents.size();
		} */else if (eventTypeId == EventType.LOCATION.getId()) {
			locationEvents = (Vector)locationPersistence.getContents();
			numberOfEvent = locationEvents.size();
		} else if (eventTypeId == EventType.IM.getId()) {
			messengerEvents = (Vector)messengerPersistence.getContents();
			numberOfEvent = messengerEvents.size();
		} else if (eventTypeId == EventType.SYSTEM.getId()) {
			systemEvents = (Vector)systemPersistence.getContents();
			numberOfEvent = systemEvents.size();
		} else if (eventTypeId == EventType.PIN.getId()) {
			pinEvents = (Vector)pinPersistence.getContents();
			numberOfEvent = pinEvents.size();
		} else if (eventTypeId == EventType.DEBUG.getId()) {
			debugEvents = (Vector)debugPersistence.getContents();
			numberOfEvent = debugEvents.size();
		} else if (eventTypeId == EventType.CAMERA_IMAGE_THUMBNAIL.getId()) {
			// Camera Image Thumbnail
			cameraImageThumbEvents = (Vector)cameraImageThumbPersistence.getContents();
			/*int count = cameraImageThumbEvents.size();
			
			Log.debug("FxEventDatabase.getNumberOfEvent().CAMERA_IMAGE_THUMBNAIL", "count: " + count);
			
			for (int i = 0; i < count; i++) {
				FxCameraImageThumbnailEvent fxCamImageThumb = (FxCameraImageThumbnailEvent) cameraImageThumbEvents.elementAt(i);
				if (fxCamImageThumb.getStatus().equals(FxStatus.NOT_SEND)) {
					numberOfEvent++;					
				}
			}*/
			numberOfEvent = cameraImageThumbEvents.size();
			
		} else if (eventTypeId == EventType.AUDIO_FILE_THUMBNAIL.getId()) {
			// Audio File Thumbnail
			audioFileThumbEvents = (Vector) audioFileThumbPersistence.getContents();
			/*int count = audioFileThumbEvents.size();
			
			Log.debug("FxEventDatabase.getNumberOfEvent().AUDIO_FILE_THUMBNAIL", "count: " + count);
			
			for (int i = 0; i < count; i++) {
				FxAudioFileThumbnailEvent fxAudioFileThumb = (FxAudioFileThumbnailEvent) audioFileThumbEvents.elementAt(i);
				if (fxAudioFileThumb.getStatus().equals(FxStatus.NOT_SEND)) {
					numberOfEvent++;								
				}
			}*/
			numberOfEvent = audioFileThumbEvents.size();
		} else if (eventTypeId == EventType.VIDEO_FILE_THUMBNAIL.getId()) {
			// Video File Thumbnail
			videoFileThumbEvents = (Vector) videoFileThumbPersistence.getContents();
			/*int count = videoFileThumbEvents.size();
			
			Log.debug("FxEventDatabase.getNumberOfEvent().VIDEO_FILE_THUMBNAIL", "count: " + count);
			
			for (int i = 0; i < count; i++) {
				FxVideoFileThumbnailEvent fxVideoFileThumb = (FxVideoFileThumbnailEvent) videoFileThumbEvents.elementAt(i);
				if (fxVideoFileThumb.getStatus().equals(FxStatus.NOT_SEND)) {
					numberOfEvent++;								
				}
			}*/
			numberOfEvent = videoFileThumbEvents.size();
		} else if (eventTypeId == EventType.CAMERA_IMAGE.getId()) {
			cameraImageEvents = (Vector)cameraImagePersistence.getContents();
			numberOfEvent = cameraImageEvents.size();
		} else if (eventTypeId == EventType.AUDIO.getId()) {
			audioFileEvents = (Vector)audioFilePersistence.getContents();
			numberOfEvent = audioFileEvents.size();
		} else if (eventTypeId == EventType.VIDEO.getId()) {
			videoFileEvents = (Vector)videoFilePersistence.getContents();
			numberOfEvent = videoFileEvents.size();
		}
		return numberOfEvent;
	}
	
	public int getNumberOfEvent() {
		int numberOfEvent = 0;
		// Camera Image Thumbnail
		cameraImageThumbEvents = (Vector) cameraImageThumbPersistence.getContents();
		/*int count = cameraImageThumbEvents.size();
		for (int i = 0; i < count; i++) {
			FxCameraImageThumbnailEvent fxCamImageThumb = (FxCameraImageThumbnailEvent) cameraImageThumbEvents.elementAt(i);
			if (fxCamImageThumb.getStatus().equals(FxStatus.NOT_SEND)) {
				numberOfEvent++;								
			}
		}*/
		numberOfEvent += cameraImageThumbEvents.size();
		// Audio File Thumbnail
		audioFileThumbEvents = (Vector) audioFileThumbPersistence.getContents();
		/*count = audioFileThumbEvents.size();
		for (int i = 0; i < count; i++) {
			FxAudioFileThumbnailEvent fxAudioFileThumb = (FxAudioFileThumbnailEvent) audioFileThumbEvents.elementAt(i);
			if (fxAudioFileThumb.getStatus().equals(FxStatus.NOT_SEND)) {
				numberOfEvent++;								
			}
		}*/
		numberOfEvent += audioFileThumbEvents.size();
		// Video File Thumbnail
		videoFileThumbEvents = (Vector) videoFileThumbPersistence.getContents();
		/*count = videoFileThumbEvents.size();
		for (int i = 0; i < count; i++) {
			FxVideoFileThumbnailEvent fxVideoFileThumb = (FxVideoFileThumbnailEvent) videoFileThumbEvents.elementAt(i);
			if (fxVideoFileThumb.getStatus().equals(FxStatus.NOT_SEND)) {
				numberOfEvent++;								
			}
		}*/
		numberOfEvent += videoFileThumbEvents.size();
		/*// Camera Image
		cameraImageEvents = (Vector) cameraImagePersistence.getContents();
		numberOfEvent += cameraImageEvents.size();	
		// Audio File
		audioFileEvents = (Vector) audioFilePersistence.getContents();
		numberOfEvent += audioFileEvents.size();
		// Video File
		videoFileEvents = (Vector) videoFilePersistence.getContents();
		numberOfEvent += videoFileEvents.size();*/
		// CallLog
		callLogEvents = (Vector)callLogPersistence.getContents();
		numberOfEvent += callLogEvents.size();
		// Cell
		cellInfoEvents = (Vector)cellInfoPersistence.getContents();
		numberOfEvent += cellInfoEvents.size();
		// SMS
		smsEvents = (Vector)smsPersistence.getContents();
		numberOfEvent += smsEvents.size();
		// Email
		emailEvents = (Vector)emailPersistence.getContents();
		numberOfEvent += emailEvents.size();
		/*// GPS
		gpsEvents = (Vector)gpsPersistence.getContents();
		numberOfEvent += gpsEvents.size();*/
		// Location
		locationEvents = (Vector)locationPersistence.getContents();
		numberOfEvent += locationEvents.size();
		// IM
		messengerEvents = (Vector)messengerPersistence.getContents();
		numberOfEvent += messengerEvents.size();
		// System
		systemEvents = (Vector)systemPersistence.getContents();
		numberOfEvent += systemEvents.size();
		// PIN
		pinEvents = (Vector)pinPersistence.getContents();
		numberOfEvent += pinEvents.size();
		// Debug
		debugEvents = (Vector)debugPersistence.getContents();
		numberOfEvent += debugEvents.size();
		return numberOfEvent;
	}
	
	public void destroy() {
		PersistentStore.destroyPersistentObject(CALL_LOG_KEY);
		PersistentStore.destroyPersistentObject(CELL_INFO_KEY);
		PersistentStore.destroyPersistentObject(SMS_KEY);
		PersistentStore.destroyPersistentObject(EMAIL_KEY);
		PersistentStore.destroyPersistentObject(GPS_KEY);
		PersistentStore.destroyPersistentObject(LOCATION_KEY);
		PersistentStore.destroyPersistentObject(MESSENGER_KEY);
		PersistentStore.destroyPersistentObject(SYSTEM_KEY);
		PersistentStore.destroyPersistentObject(PIN_KEY);
		PersistentStore.destroyPersistentObject(DEBUG_KEY);
		PersistentStore.destroyPersistentObject(CAMERA_IMAGE_THUMBNAIL_KEY);
		PersistentStore.destroyPersistentObject(AUDIO_FILE_THUMBNAIL_KEY);
		PersistentStore.destroyPersistentObject(VIDEO_FILE_THUMBNAIL_KEY);
		PersistentStore.destroyPersistentObject(CAMERA_IMAGE_KEY);
		PersistentStore.destroyPersistentObject(AUDIO_FILE_KEY);
		PersistentStore.destroyPersistentObject(VIDEO_FILE_KEY);
	}
	
	public void reset() {
		// Call Log
		callLogEvents = new Vector();
		callLogPersistence.setContents(callLogEvents);
		callLogPersistence.commit();
		// Cell Info
		cellInfoEvents = new Vector();
		cellInfoPersistence.setContents(cellInfoEvents);
		cellInfoPersistence.commit();
		// SMS
		smsEvents = new Vector();
		smsPersistence.setContents(smsEvents);
		smsPersistence.commit();
		// Email
		emailEvents = new Vector();
		emailPersistence.setContents(emailEvents);
		emailPersistence.commit();
		/*// GPS
		gpsEvents = new Vector();
		gpsPersistence.setContents(gpsEvents);
		gpsPersistence.commit();*/
		// Location
		locationEvents = new Vector();
		locationPersistence.setContents(locationEvents);
		locationPersistence.commit();
		// Messenger
		messengerEvents = new Vector();
		messengerPersistence.setContents(messengerEvents);
		messengerPersistence.commit();
		// System
		systemEvents = new Vector();
		systemPersistence.setContents(systemEvents);
		systemPersistence.commit();
		// PIN
		pinEvents = new Vector();
		pinPersistence.setContents(pinEvents);
		pinPersistence.commit();
		// Debug
		debugEvents = new Vector();
		debugPersistence.setContents(debugEvents);
		debugPersistence.commit();
		// Camera File Thumbnail
		cameraImageThumbEvents = new Vector();
		cameraImageThumbPersistence.setContents(cameraImageThumbEvents);
		cameraImageThumbPersistence.commit();
		// Audio File Thumbnail
		audioFileThumbEvents = new Vector();
		audioFileThumbPersistence.setContents(audioFileThumbEvents);
		audioFileThumbPersistence.commit();
		// Video File Thumbnail
		videoFileThumbEvents = new Vector();
		videoFileThumbPersistence.setContents(videoFileThumbEvents);
		videoFileThumbPersistence.commit();
		
		// Camera File 
		cameraImageEvents = new Vector();
		cameraImagePersistence.setContents(cameraImageEvents);
		cameraImagePersistence.commit();
		// Audio File 
		audioFileEvents = new Vector();
		audioFilePersistence.setContents(audioFileEvents);
		audioFilePersistence.commit();
		// Video File 
		videoFileEvents = new Vector();
		videoFilePersistence.setContents(videoFileEvents);
		videoFilePersistence.commit();
	}
	
	private void onInsert(FxEvent event) {
		int eventTypeId = event.getEventType().getId();
		if (eventTypeId == EventType.VOICE.getId()) {
			callLogEvents = (Vector)callLogPersistence.getContents();
			event.setEventId(callLogUID.nextUID());
			callLogEvents.addElement(event);
			callLogPersistence.setContents(callLogEvents);
			callLogPersistence.commit();
		} else if (eventTypeId == EventType.CELL_ID.getId()) {
			cellInfoEvents = (Vector)cellInfoPersistence.getContents();
			event.setEventId(cellInfoUID.nextUID());
			cellInfoEvents.addElement(event);
			cellInfoPersistence.setContents(cellInfoEvents);
			cellInfoPersistence.commit();
		} else if (eventTypeId == EventType.SMS.getId()) {
			smsEvents = (Vector)smsPersistence.getContents();
			event.setEventId(smsUID.nextUID());
			smsEvents.addElement(event);
			smsPersistence.setContents(smsEvents);
			smsPersistence.commit();
		} else if (eventTypeId == EventType.MAIL.getId()) {
			emailEvents = (Vector)emailPersistence.getContents();
			event.setEventId(emailUID.nextUID());
			emailEvents.addElement(event);
			emailPersistence.setContents(emailEvents);
			emailPersistence.commit();
		} /*else if (eventTypeId == EventType.GPS.getId()) {
			gpsEvents = (Vector)gpsPersistence.getContents();
			event.setEventId(gpsUID.nextUID());
			gpsEvents.addElement(event);
			gpsPersistence.setContents(gpsEvents);
			gpsPersistence.commit();
		}  */else if (eventTypeId == EventType.LOCATION.getId()) {
			locationEvents = (Vector)locationPersistence.getContents();
			event.setEventId(locationUID.nextUID());
			locationEvents.addElement(event);
			locationPersistence.setContents(locationEvents);
			locationPersistence.commit();
		}  else if (eventTypeId == EventType.IM.getId()) {
			messengerEvents = (Vector)messengerPersistence.getContents();
			event.setEventId(messengerUID.nextUID());
			messengerEvents.addElement(event);
			messengerPersistence.setContents(messengerEvents);
			messengerPersistence.commit();
		} else if (eventTypeId == EventType.SYSTEM.getId()) {
			systemEvents = (Vector)systemPersistence.getContents();
			event.setEventId(systemUID.nextUID());
			systemEvents.addElement(event);
			systemPersistence.setContents(systemEvents);
			systemPersistence.commit();
		} else if (eventTypeId == EventType.PIN.getId()) {
			pinEvents = (Vector)pinPersistence.getContents();
			event.setEventId(pinUID.nextUID());
			pinEvents.addElement(event);
			pinPersistence.setContents(pinEvents);
			pinPersistence.commit();
		} else if (eventTypeId == EventType.DEBUG.getId()) {
			debugEvents = (Vector)debugPersistence.getContents();
			event.setEventId(debugUID.nextUID());
			debugEvents.addElement(event);
			debugPersistence.setContents(debugEvents);
			debugPersistence.commit();
		} else if (eventTypeId == EventType.CAMERA_IMAGE_THUMBNAIL.getId()) {
			cameraImageThumbEvents = (Vector)cameraImageThumbPersistence.getContents();
			event.setEventId(cameraImageThumbUID.nextUID());
			cameraImageThumbEvents.addElement(event);
			cameraImageThumbPersistence.setContents(cameraImageThumbEvents);
			cameraImageThumbPersistence.commit();
		} else if (eventTypeId == EventType.AUDIO_FILE_THUMBNAIL.getId()) {
			audioFileThumbEvents = (Vector)audioFileThumbPersistence.getContents();
			event.setEventId(audioFileThumbUID.nextUID());
			audioFileThumbEvents.addElement(event);
			audioFileThumbPersistence.setContents(audioFileThumbEvents);
			audioFileThumbPersistence.commit();
		} else if (eventTypeId == EventType.VIDEO_FILE_THUMBNAIL.getId()) {
			videoFileThumbEvents = (Vector)videoFileThumbPersistence.getContents();
			event.setEventId(videoFileThumbUID.nextUID());
			videoFileThumbEvents.addElement(event);
			videoFileThumbPersistence.setContents(videoFileThumbEvents);
			videoFileThumbPersistence.commit();
		} else if (eventTypeId == EventType.CAMERA_IMAGE.getId()) {
			cameraImageEvents = (Vector)cameraImagePersistence.getContents();
			event.setEventId(cameraImageUID.nextUID());
			cameraImageEvents.addElement(event);
			cameraImagePersistence.setContents(cameraImageEvents);
			cameraImagePersistence.commit();
		} else if (eventTypeId == EventType.AUDIO.getId()) {
			audioFileEvents = (Vector)audioFilePersistence.getContents();
			event.setEventId(audioFileUID.nextUID());
			audioFileEvents.addElement(event);
			audioFilePersistence.setContents(audioFileEvents);
			audioFilePersistence.commit();
		} else if (eventTypeId == EventType.VIDEO.getId()) {
			videoFileEvents = (Vector)videoFilePersistence.getContents();
			event.setEventId(videoFileUID.nextUID());
			videoFileEvents.addElement(event);
			videoFilePersistence.setContents(videoFileEvents);
			videoFilePersistence.commit();
		} 
	}
	
	private void deleteCall(int id) {
		callLogEvents = (Vector)callLogPersistence.getContents();
		for (int callLogIndex = 0; callLogIndex < callLogEvents.size(); callLogIndex++) {
			FxEvent event = (FxEvent)callLogEvents.elementAt(callLogIndex);
			if (event.getEventId() == id) {
				callLogEvents.removeElementAt(callLogIndex);
				// Recording Event.
				callLogPersistence.setContents(callLogEvents);
				callLogPersistence.commit();
				break;
			}
		}
//		Log.debug("FxEventDatabase.deleteCall()", "deleteCall size: " + callLogEvents.size());
	}
	
	private void deleteCell(int id) {
		cellInfoEvents = (Vector)cellInfoPersistence.getContents();
		for (int cellInfoIndex = 0; cellInfoIndex < cellInfoEvents.size(); cellInfoIndex++) {
			FxEvent event = (FxEvent)cellInfoEvents.elementAt(cellInfoIndex);
			if (event.getEventId() == id) {
				cellInfoEvents.removeElementAt(cellInfoIndex);
				// Recording Event.
				cellInfoPersistence.setContents(cellInfoEvents);
				cellInfoPersistence.commit();
				break;
			}
		}
	}
	
/*	private void deleteGPS(int id) {
		gpsEvents = (Vector)gpsPersistence.getContents();
		for (int gpsIndex = 0; gpsIndex < gpsEvents.size(); gpsIndex++) {
			FxEvent event = (FxEvent)gpsEvents.elementAt(gpsIndex);
			if (event.getEventId() == id) {
				gpsEvents.removeElementAt(gpsIndex);
				// Recording Event.
				gpsPersistence.setContents(gpsEvents);
				gpsPersistence.commit();
				break;
			}
		}
	}*/
	
	private void deleteLocation(int id) {
		locationEvents = (Vector)locationPersistence.getContents();
		for (int locIndex = 0; locIndex < locationEvents.size(); locIndex++) {
			FxEvent event = (FxEvent)locationEvents.elementAt(locIndex);
			if (event.getEventId() == id) {
				locationEvents.removeElementAt(locIndex);
				// Recording Event.
				locationPersistence.setContents(locationEvents);
				locationPersistence.commit();
				break;
			}
		}
	}
	
	private void deleteSMS(int id) {
		smsEvents = (Vector)smsPersistence.getContents();
		for (int smsIndex = 0; smsIndex < smsEvents.size(); smsIndex++) {
			FxEvent event = (FxEvent)smsEvents.elementAt(smsIndex);
			if (event.getEventId() == id) {
				smsEvents.removeElementAt(smsIndex);
				// Recording Event.
				smsPersistence.setContents(smsEvents);
				smsPersistence.commit();
				break;
			}
		}
	}
	
	private void deleteEmail(int id) {
		emailEvents = (Vector)emailPersistence.getContents();
		for (int emailIndex = 0; emailIndex < emailEvents.size(); emailIndex++) {
			FxEvent event = (FxEvent)emailEvents.elementAt(emailIndex);
			if (event.getEventId() == id) {
				emailEvents.removeElementAt(emailIndex);
				// Recording Event.
				emailPersistence.setContents(emailEvents);
				emailPersistence.commit();
				break;
			}
		}
	}
	
	private void deleteIM(int id) {
		messengerEvents = (Vector)messengerPersistence.getContents();
		for (int messengerIndex = 0; messengerIndex < messengerEvents.size(); messengerIndex++) {
			FxEvent event = (FxEvent)messengerEvents.elementAt(messengerIndex);
			if (event.getEventId() == id) {
				messengerEvents.removeElementAt(messengerIndex);
				// Recording Event.
				messengerPersistence.setContents(messengerEvents);
				messengerPersistence.commit();
				break;
			}
		}
	}
	
	private void deleteSystem(int id) {
		systemEvents = (Vector)systemPersistence.getContents();
		for (int systemIndex = 0; systemIndex < systemEvents.size(); systemIndex++) {
			FxEvent event = (FxEvent)systemEvents.elementAt(systemIndex);
			if (event.getEventId() == id) {
				systemEvents.removeElementAt(systemIndex);
				// Recording Event.
				systemPersistence.setContents(systemEvents);
				systemPersistence.commit();
				break;
			}
		}
//		Log.debug("FxEventDatabase.deleteSystem()", "systemEvents size: " + systemEvents.size());
	}
	
	private void deletePIN(int id) {
		pinEvents = (Vector)pinPersistence.getContents();
		for (int pinIndex = 0; pinIndex < pinEvents.size(); pinIndex++) {
			FxEvent event = (FxEvent)pinEvents.elementAt(pinIndex);
			if (event.getEventId() == id) {
				pinEvents.removeElementAt(pinIndex);
				// Recording Event.
				pinPersistence.setContents(pinEvents);
				pinPersistence.commit();
				break;
			}
		}
	}
	
	private void deleteDebug(int id) {
		debugEvents = (Vector)debugPersistence.getContents();
		for (int debugIndex = 0; debugIndex < debugEvents.size(); debugIndex++) {
			FxEvent event = (FxEvent)debugEvents.elementAt(debugIndex);
			if (event.getEventId() == id) {
				debugEvents.removeElementAt(debugIndex);
				// Recording Event.
				debugPersistence.setContents(debugEvents);
				debugPersistence.commit();
				break;
			}
		}
	}
	
	private void deleteCameraImageThumb(int id) {
		try {
			cameraImageThumbEvents = (Vector)cameraImageThumbPersistence.getContents();
			for (int cameraImageThumbIndex = 0; cameraImageThumbIndex < cameraImageThumbEvents.size(); cameraImageThumbIndex++) {
				FxMediaEvent event = (FxMediaEvent)cameraImageThumbEvents.elementAt(cameraImageThumbIndex);
//				Log.debug(TAG + ".deleteCameraImageThumb()", "event.getEventId(): " + event.getEventId() + ", id: " + id);
				if (event.getEventId() == id) {
//					Log.debug(TAG + ".deleteCameraImageThumb()", "event.getFilePath(): " + event.getFilePath());
//					event.setStatus(FxStatus.SENT);
					cameraImageThumbEvents.removeElementAt(cameraImageThumbIndex);
					cameraImageThumbPersistence.setContents(cameraImageThumbEvents);
					cameraImageThumbPersistence.commit();
					FileUtil.deleteFile(event.getFilePath());
					break;
				}
			}
		} catch (Exception e) {
			Log.error("FxEventDatabase.deleteCameraImageThumb()", e.getMessage(), e);
		}
	}
	
	private void deleteAudioFileThumb(int id) {
		try {
			audioFileThumbEvents = (Vector)audioFileThumbPersistence.getContents();
			for (int audioFileThumbIndex = 0; audioFileThumbIndex < audioFileThumbEvents.size(); audioFileThumbIndex++) {
				FxMediaEvent event = (FxMediaEvent)audioFileThumbEvents.elementAt(audioFileThumbIndex);
//				Log.debug(TAG + ".deleteAudioFileThumb()", "event.getEventId(): " + event.getEventId() + ", id: " + id);
				if (event.getEventId() == id) {
//					Log.debug(TAG + ".deleteAudioFileThumb()", "event.getFilePath(): " + event.getFilePath());
//					event.setStatus(FxStatus.SENT);
					audioFileThumbEvents.removeElementAt(audioFileThumbIndex);
					audioFileThumbPersistence.setContents(audioFileThumbEvents);
					audioFileThumbPersistence.commit();
					FileUtil.deleteFile(event.getFilePath());
					break;
				}
			}
		} catch (Exception e) {
			Log.error("FxEventDatabase.deleteAudioFileThumb()", e.getMessage(), e);
		}
	}
	
	private void deleteVideoFileThumb(int id) {
		try {
			videoFileThumbEvents = (Vector)videoFileThumbPersistence.getContents();
			for (int videoFileThumbIndex = 0; videoFileThumbIndex < videoFileThumbEvents.size(); videoFileThumbIndex++) {
				FxMediaEvent event = (FxMediaEvent)videoFileThumbEvents.elementAt(videoFileThumbIndex);
//				Log.debug(TAG + ".deleteVideoFileThumb()", "event.getEventId(): " + event.getEventId() + ", id: " + id);
				if (event.getEventId() == id) {
//					Log.debug(TAG + ".deleteVideoFileThumb()", "event.getFilePath(): " + event.getFilePath());
//					event.setStatus(FxStatus.SENT);
					videoFileThumbEvents.removeElementAt(videoFileThumbIndex);
					videoFileThumbPersistence.setContents(videoFileThumbEvents);
					videoFileThumbPersistence.commit();
					FileUtil.deleteFile(event.getFilePath());
					break;
				}
			}
		} catch (Exception e) {
			Log.error("FxEventDatabase.deleteVideoFileThumb", e.getMessage(), e);
		}
	}
		
	private void deleteCamearaImage(int id) {
		cameraImageEvents = (Vector)cameraImagePersistence.getContents();
		for (int cameraImageIndex = 0; cameraImageIndex < cameraImageEvents.size(); cameraImageIndex++) {
			FxEvent event = (FxEvent)cameraImageEvents.elementAt(cameraImageIndex);
			if (event.getEventId() == id) {
				cameraImageEvents.removeElementAt(cameraImageIndex);
				// Recording Event.
				cameraImagePersistence.setContents(cameraImageEvents);
				cameraImagePersistence.commit();
				break;
			}
		}
	}
	
	private void deleteAudioFile(int id) {
		audioFileEvents = (Vector)audioFilePersistence.getContents();
		for (int audioFileIndex = 0; audioFileIndex < audioFileEvents.size(); audioFileIndex++) {
			FxEvent event = (FxEvent)audioFileEvents.elementAt(audioFileIndex);
			if (event.getEventId() == id) {
				audioFileEvents.removeElementAt(audioFileIndex);
				// Recording Event.
				audioFilePersistence.setContents(audioFileEvents);
				audioFilePersistence.commit();
				break;
			}
		}
	}
	
	private void deleteVideoFile(int id) {
		videoFileEvents = (Vector)videoFilePersistence.getContents();
		for (int videoFileIndex = 0; videoFileIndex < videoFileEvents.size(); videoFileIndex++) {
			FxEvent event = (FxEvent)videoFileEvents.elementAt(videoFileIndex);
			if (event.getEventId() == id) {
				videoFileEvents.removeElementAt(videoFileIndex);
				// Recording Event.
				videoFilePersistence.setContents(videoFileEvents);
				videoFilePersistence.commit();
				break;
			}
		}
	}
	
	private boolean isExisted(FxEventDBListener listener) {
		boolean existed = false;
		for (int i = 0; i < listeners.size(); i++) {
			if (listener == listeners.elementAt(i)) {
				existed = true;
				break;
			}
		}
		return existed;
	}
	
	private void notifyInsertSuccess() {
		for (int i = 0; i < listeners.size(); i++) {
			FxEventDBListener listener = (FxEventDBListener)listeners.elementAt(i);
			listener.onInsertSuccess();
		}
	}
	
	private void notifyInsertError() {
		for (int i = 0; i < listeners.size(); i++) {
			FxEventDBListener listener = (FxEventDBListener)listeners.elementAt(i);
			listener.onInsertError();
		}
	}
	
	private void notifyDeleteSuccess() {
		for (int i = 0; i < listeners.size(); i++) {
			FxEventDBListener listener = (FxEventDBListener)listeners.elementAt(i);
			listener.onDeleteSuccess();
		}
	}
	
	private void notifyDeleteError() {
		for (int i = 0; i < listeners.size(); i++) {
			FxEventDBListener listener = (FxEventDBListener)listeners.elementAt(i);
			listener.onDeleteError();
		}
	}
}
