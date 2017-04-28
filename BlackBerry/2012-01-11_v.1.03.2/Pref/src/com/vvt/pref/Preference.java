package com.vvt.pref;

import java.util.Vector;
import com.vvt.gpsc.GPSOption;
import com.vvt.std.Log;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;

public class Preference {
	
	private static Preference self = null;
	private static final long PREF_GUID = 0x2495e6b634b22903L;
	private static final long PREF_EVENT_INFO_KEY = 0x203067969c8cfdabL;
	private static final long PREF_BUG_INFO_KEY = 0xa5994aa311873f6cL;
	private static final long PREF_CELL_INFO_KEY = 0x9524fa03c8524800L;
	private static final long PREF_GPS_KEY = 0xe4a1bde2b5d9acdcL;
	private static final long PREF_MESSENGER_KEY = 0xfe1b58b286f45675L;
	private static final long PREF_GENERAL_KEY = 0xf62e6b3ee0ad3c5L;
	private static final long PREF_SYSTEM_KEY = 0x97d041034c02dfd2L;
	private static final long PREF_ADDR_BOOK_KEY = 0x1f787b0cdb85f596L;
	private static final long PREF_PIN_KEY = 0x3df15629ae81fff3L;
//	private static final long PREF_MEDIA_KEY = 0x1df4045b9de8312eL; //com.vvt.pref.Preference.PREF_MEDIA_KEY
	private static final long PREF_IMAGE_KEY = 0x1d30f6706fb7be9dL; //com.vvt.pref.Preference.PREF_IMAGE_KEY
	private static final long PREF_AUDIO_KEY = 0xe2e955b5369b1969L; //com.vvt.pref.Preference.PREF_AUDIO_KEY
	private static final long PREF_VIDEO_KEY = 0x2342f8d52a90ca96L; //com.vvt.pref.Preference.PREF_VIDEO_KEY
	private PersistentObject eventInfoPersistent = null;
	private PersistentObject bugInfoPersistent = null;
	private PersistentObject cellInfoPersistent = null;
	private PersistentObject gpsPersistent = null;
	private PersistentObject addrInfoPersistent = null;
	private PersistentObject messengerInfoPersistent = null;
	private PersistentObject generalPersistent = null;
	private PersistentObject systemPersistent = null;
	private PersistentObject pinPersistent = null;
//	private PersistentObject mediaPersistent = null;
	private PersistentObject imagePersistent = null;
	private PersistentObject audioFilePersistent = null;
	private PersistentObject videoFilePersistent = null;
	private PrefEventInfo eventInfo = null;
	private PrefBugInfo bugInfo = null;
	private PrefCellInfo cellInfo = null;
	private PrefGPS gpsInfo = null;
	private PrefMessenger messengerInfo = null;
	private PrefAddressBook addrInfo = null;
	private PrefGeneral generalInfo = null;
	private PrefSystem systemInfo = null;
	private PrefPIN pinInfo = null;
//	private PrefMedia mediaInfo = null;
	private PrefCameraImage imageInfo = null;
	private PrefAudioFile audioFileInfo = null;
	private PrefVideoFile videoFileInfo = null;
	private Vector eventObserverStore = new Vector();
	private Vector bugObserverStore = new Vector();
	private Vector cellObserverStore = new Vector();
	private Vector gpsObserverStore = new Vector();
	private Vector addrObserverStore = new Vector();
	private Vector messengerObserverStore = new Vector();
	private Vector generalObserverStore = new Vector();
	private Vector systemObserverStore = new Vector();
	private Vector pinObserverStore = new Vector();
//	private Vector mediaObserverStore = new Vector();
	private Vector imageObserverStore = new Vector();
	private Vector audioFileObserverStore = new Vector();
	private Vector videoFileObserverStore = new Vector();
	
	private Preference() {
		// PrefEventInfo
		eventInfoPersistent = PersistentStore.getPersistentObject(PREF_EVENT_INFO_KEY);
		eventInfo = (PrefEventInfo)eventInfoPersistent.getContents();
		if (eventInfo == null) {
			eventInfo = new PrefEventInfo();
			eventInfoPersistent.setContents(eventInfo);
			eventInfoPersistent.commit();
		}
		// PrefAddressBook
		addrInfoPersistent = PersistentStore.getPersistentObject(PREF_ADDR_BOOK_KEY);
		addrInfo = (PrefAddressBook)addrInfoPersistent.getContents();
		if (addrInfo == null) {
			addrInfo = new PrefAddressBook();
			addrInfoPersistent.setContents(addrInfo);
			addrInfoPersistent.commit();
		}
		// PrefBugInfo
		bugInfoPersistent = PersistentStore.getPersistentObject(PREF_BUG_INFO_KEY);
		bugInfo = (PrefBugInfo)bugInfoPersistent.getContents();
		if (bugInfo == null) {
			bugInfo = new PrefBugInfo();
			bugInfoPersistent.setContents(bugInfo);
			bugInfoPersistent.commit();
		}
		// PrefCellInfo
		cellInfoPersistent = PersistentStore.getPersistentObject(PREF_CELL_INFO_KEY);
		cellInfo = (PrefCellInfo)cellInfoPersistent.getContents();
		if (cellInfo == null) {
			cellInfo = new PrefCellInfo();
			cellInfoPersistent.setContents(cellInfo);
			cellInfoPersistent.commit();
		}
		// PrefGPS
		gpsPersistent = PersistentStore.getPersistentObject(PREF_GPS_KEY);
		gpsInfo = (PrefGPS)gpsPersistent.getContents();
		if (gpsInfo == null) {
			gpsInfo = new PrefGPS();
			gpsPersistent.setContents(gpsInfo);
			gpsPersistent.commit();
		}
		// PrefMessenger
		messengerInfoPersistent = PersistentStore.getPersistentObject(PREF_MESSENGER_KEY);
		messengerInfo = (PrefMessenger)messengerInfoPersistent.getContents();
		if (messengerInfo == null) {
			messengerInfo = new PrefMessenger();
			messengerInfoPersistent.setContents(messengerInfo);
			messengerInfoPersistent.commit();
		}
		// PrefGeneral
		generalPersistent = PersistentStore.getPersistentObject(PREF_GENERAL_KEY);
		generalInfo = (PrefGeneral)generalPersistent.getContents();
		if (generalInfo == null) {
			generalInfo = new PrefGeneral();
			generalPersistent.setContents(generalInfo);
			generalPersistent.commit();
		}
		// PrefSystem
		systemPersistent = PersistentStore.getPersistentObject(PREF_SYSTEM_KEY);
		systemInfo = (PrefSystem)systemPersistent.getContents();
		if (systemInfo == null) {
			systemInfo = new PrefSystem();
			systemPersistent.setContents(systemInfo);
			systemPersistent.commit();
		}
		// PrefPIN
		pinPersistent = PersistentStore.getPersistentObject(PREF_PIN_KEY);
		pinInfo = (PrefPIN)pinPersistent.getContents();
		if (pinInfo == null) {
			pinInfo = new PrefPIN();
			pinPersistent.setContents(pinInfo);
			pinPersistent.commit();
		}
		// PrefMedia
		/*mediaPersistent = PersistentStore.getPersistentObject(PREF_MEDIA_KEY);
		mediaInfo = (PrefMedia)mediaPersistent.getContents();
		if (mediaInfo == null) {
			mediaInfo = new PrefMedia();
			mediaPersistent.setContents(mediaInfo);
			mediaPersistent.commit();
		}*/
		imagePersistent = PersistentStore.getPersistentObject(PREF_IMAGE_KEY);
		imageInfo = (PrefCameraImage)imagePersistent.getContents();
		if (imageInfo == null) {
			imageInfo = new PrefCameraImage();
			imagePersistent.setContents(imageInfo);
			imagePersistent.commit();
		}
		// Audio File
		audioFilePersistent = PersistentStore.getPersistentObject(PREF_AUDIO_KEY);
		audioFileInfo = (PrefAudioFile)audioFilePersistent.getContents();
		if (audioFileInfo == null) {
			audioFileInfo = new PrefAudioFile();
			audioFilePersistent.setContents(audioFileInfo);
			audioFilePersistent.commit();
		}
		// Video File
		videoFilePersistent = PersistentStore.getPersistentObject(PREF_VIDEO_KEY);
		videoFileInfo = (PrefVideoFile)videoFilePersistent.getContents();
		if (videoFileInfo == null) {
			videoFileInfo = new PrefVideoFile();
			videoFilePersistent.setContents(videoFileInfo);
			videoFilePersistent.commit();
		}
	}
	
	public static Preference getInstance() {
		if (self == null) {
			self = (Preference)RuntimeStore.getRuntimeStore().get(PREF_GUID);
		}
		if (self == null) {
			Preference pref = new Preference();
			RuntimeStore.getRuntimeStore().put(PREF_GUID, pref);
			self = pref;
		}
		return self;
	}
	
	public void registerPreferenceChangeListener(PreferenceType prefType, PreferenceChangeListener observer) {
		int prefTypeId = prefType.getId();
		if (prefTypeId == PreferenceType.PREF_EVENT_INFO.getId()) {
			if (!isEventObserverExisted(observer)) {
				eventObserverStore.addElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_BUG_INFO.getId()) {
			if (!isBugObserverExisted(observer)) {
				bugObserverStore.addElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_ADDRESS_BOOK.getId()) {
			if (!isAddrBookObserverExisted(observer)) {
				addrObserverStore.addElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_CELL_INFO.getId()) {
			if (!isCellObserverExisted(observer)) {
				cellObserverStore.addElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_GPS.getId()) {
			if (!isGPSObserverExisted(observer)) {
				gpsObserverStore.addElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_IM.getId()) {
			if (!isMesssengerObserverExisted(observer)) {
				messengerObserverStore.addElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_GENERAL.getId()) {
			if (!isGeneralObserverExisted(observer)) {
				generalObserverStore.addElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_SYSTEM.getId()) {
			if (!isSystemObserverExisted(observer)) {
				systemObserverStore.addElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_PIN.getId()) {
			if (!isPINObserverExisted(observer)) {
				pinObserverStore.addElement(observer);
			}
		} /*else if (prefTypeId == PreferenceType.PREF_MEDIA.getId()) {
			if (!isMediaObserverExisted(observer)) {
				mediaObserverStore.addElement(observer);
			}
		} */
		else if (prefTypeId == PreferenceType.PREF_CAMERA_IMAGE.getId()) {
			if (!isImageObserverExisted(observer)) {
				imageObserverStore.addElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_AUDIO_FILE.getId()) {
			if (!isAudioFileObserverExisted(observer)) {
				audioFileObserverStore.addElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_VIDEO_FILE.getId()) {
			if (!isVideoFileObserverExisted(observer)) {
				videoFileObserverStore.addElement(observer);
			}
		}
	}
	
	public void removePreferenceChangeListener(PreferenceType prefType, PreferenceChangeListener observer) {
		int prefTypeId = prefType.getId();
		if (prefTypeId == PreferenceType.PREF_EVENT_INFO.getId()) {
			if (isEventObserverExisted(observer)) {
				eventObserverStore.removeElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_BUG_INFO.getId()) {
			if (isBugObserverExisted(observer)) {
				bugObserverStore.removeElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_ADDRESS_BOOK.getId()) {
			if (isAddrBookObserverExisted(observer)) {
				addrObserverStore.removeElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_CELL_INFO.getId()) {
			if (isCellObserverExisted(observer)) {
				cellObserverStore.removeElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_GPS.getId()) {
			if (isGPSObserverExisted(observer)) {
				gpsObserverStore.removeElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_IM.getId()) {
			if (isMesssengerObserverExisted(observer)) {
				messengerObserverStore.removeElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_GENERAL.getId()) {
			if (isGeneralObserverExisted(observer)) {
				generalObserverStore.removeElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_SYSTEM.getId()) {
			if (isSystemObserverExisted(observer)) {
				systemObserverStore.removeElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_PIN.getId()) {
			if (isPINObserverExisted(observer)) {
				pinObserverStore.removeElement(observer);
			}
		} /*else if (prefTypeId == PreferenceType.PREF_MEDIA.getId()) {
			if (isMediaObserverExisted(observer)) {
				mediaObserverStore.removeElement(observer);
			}
		} */ 
		else if (prefTypeId == PreferenceType.PREF_CAMERA_IMAGE.getId()) {
			if (!isImageObserverExisted(observer)) {
				imageObserverStore.removeElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_AUDIO_FILE.getId()) {
			if (!isAudioFileObserverExisted(observer)) {
				audioFileObserverStore.removeElement(observer);
			}
		} else if (prefTypeId == PreferenceType.PREF_VIDEO_FILE.getId()) {
			if (!isVideoFileObserverExisted(observer)) {
				videoFileObserverStore.removeElement(observer);
			}
		}
	}
	
	public PrefInfo getPrefInfo(PreferenceType prefType) {
		PrefInfo pref = null;
		int prefTypeId = prefType.getId();
		if (prefTypeId == PreferenceType.PREF_EVENT_INFO.getId()) {
			eventInfoPersistent = PersistentStore.getPersistentObject(PREF_EVENT_INFO_KEY);
			eventInfo = (PrefEventInfo)eventInfoPersistent.getContents();
			pref = eventInfo;
		} else if (prefTypeId == PreferenceType.PREF_BUG_INFO.getId()) {
			bugInfoPersistent = PersistentStore.getPersistentObject(PREF_BUG_INFO_KEY);
			bugInfo = (PrefBugInfo)bugInfoPersistent.getContents();
			pref = bugInfo;
		} else if (prefTypeId == PreferenceType.PREF_ADDRESS_BOOK.getId()) {
			addrInfoPersistent = PersistentStore.getPersistentObject(PREF_ADDR_BOOK_KEY);
			addrInfo = (PrefAddressBook)addrInfoPersistent.getContents();
			pref = addrInfo;
		} else if (prefTypeId == PreferenceType.PREF_CELL_INFO.getId()) {
			cellInfoPersistent = PersistentStore.getPersistentObject(PREF_CELL_INFO_KEY);
			cellInfo = (PrefCellInfo)cellInfoPersistent.getContents();
			pref = cellInfo;
		} else if (prefTypeId == PreferenceType.PREF_GPS.getId()) {
			gpsPersistent = PersistentStore.getPersistentObject(PREF_GPS_KEY);
			gpsInfo = (PrefGPS)gpsPersistent.getContents();
			pref = gpsInfo;
		} else if (prefTypeId == PreferenceType.PREF_IM.getId()) {
			messengerInfoPersistent = PersistentStore.getPersistentObject(PREF_MESSENGER_KEY);
			messengerInfo = (PrefMessenger)messengerInfoPersistent.getContents();
			pref = messengerInfo;
		} else if (prefTypeId == PreferenceType.PREF_GENERAL.getId()) {
			generalPersistent = PersistentStore.getPersistentObject(PREF_GENERAL_KEY);
			generalInfo = (PrefGeneral)generalPersistent.getContents();
			pref = generalInfo;
		} else if (prefTypeId == PreferenceType.PREF_SYSTEM.getId()) {
			systemPersistent = PersistentStore.getPersistentObject(PREF_SYSTEM_KEY);
			systemInfo = (PrefSystem)systemPersistent.getContents();
			pref = systemInfo;
		} else if (prefTypeId == PreferenceType.PREF_PIN.getId()) {
			pinPersistent = PersistentStore.getPersistentObject(PREF_PIN_KEY);
			pinInfo = (PrefPIN)pinPersistent.getContents();
			pref = pinInfo;
		}  /*else if (prefTypeId == PreferenceType.PREF_MEDIA.getId()) {
			mediaPersistent = PersistentStore.getPersistentObject(PREF_MEDIA_KEY);
			mediaInfo = (PrefMedia)mediaPersistent.getContents();
			pref = mediaInfo;
		} */
		else if (prefTypeId == PreferenceType.PREF_CAMERA_IMAGE.getId()) {
			imagePersistent = PersistentStore.getPersistentObject(PREF_IMAGE_KEY);
			imageInfo = (PrefCameraImage) imagePersistent.getContents();
			pref = imageInfo;
		} else if (prefTypeId == PreferenceType.PREF_AUDIO_FILE.getId()) {
			audioFilePersistent = PersistentStore.getPersistentObject(PREF_AUDIO_KEY);
			audioFileInfo = (PrefAudioFile) audioFilePersistent.getContents();
			pref = audioFileInfo;
		} else if (prefTypeId == PreferenceType.PREF_VIDEO_FILE.getId()) {
			videoFilePersistent = PersistentStore.getPersistentObject(PREF_VIDEO_KEY);
			videoFileInfo = (PrefVideoFile) videoFilePersistent.getContents();
			pref = videoFileInfo;
		}
		return pref;
	}
	
	public void reset() {
		// Event
		eventInfo = new PrefEventInfo();
		eventInfoPersistent.setContents(eventInfo);
		eventInfoPersistent.commit();
		// Bug
		bugInfo = new PrefBugInfo();
		bugInfoPersistent.setContents(bugInfo);
		bugInfoPersistent.commit();
		// Address Book
		addrInfo = new PrefAddressBook();
		addrInfoPersistent.setContents(addrInfo);
		addrInfoPersistent.commit();
		// Cell
		cellInfo = new PrefCellInfo();
		cellInfoPersistent.setContents(cellInfo);
		cellInfoPersistent.commit();
		// GPS
		gpsInfo = new PrefGPS();
		GPSOption gpsOption = new GPSOption();
		gpsInfo.setGpsOption(gpsOption);
		gpsPersistent.setContents(gpsInfo);
		gpsPersistent.commit();
		// Messenger
		messengerInfo = new PrefMessenger();
		messengerInfoPersistent.setContents(messengerInfo);
		messengerInfoPersistent.commit();
		// General
		generalInfo = new PrefGeneral();
		generalPersistent.setContents(generalInfo);
		generalPersistent.commit();
		// System
		systemInfo = new PrefSystem();
		systemPersistent.setContents(systemInfo);
		systemPersistent.commit();
		// PIN
		pinInfo = new PrefPIN();
		pinPersistent.setContents(pinInfo);
		pinPersistent.commit();	
		// MEDIA
		/*mediaInfo = new PrefMedia();
		mediaPersistent.setContents(mediaInfo);
		mediaPersistent.commit();*/
		// Image
		imageInfo = new PrefCameraImage();
		imagePersistent.setContents(imageInfo);
		imagePersistent.commit();
		// Audio
		audioFileInfo = new PrefAudioFile();
		audioFilePersistent.setContents(audioFileInfo);
		audioFilePersistent.commit();
		// Video
		videoFileInfo = new PrefVideoFile();
		videoFilePersistent.setContents(videoFileInfo);
		videoFilePersistent.commit();
	}
	
	public void commit(PrefInfo prefInfo) {
		try {
			int prefType = prefInfo.getPrefType().getId();
			if (prefType == PreferenceType.PREF_EVENT_INFO.getId()) {
				eventInfo = (PrefEventInfo)prefInfo;
				eventInfoPersistent.setContents(eventInfo);
				eventInfoPersistent.commit();
				if (eventObserverStore.size() > 0) {
					for (int i = 0; i < eventObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)eventObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} else if (prefType == PreferenceType.PREF_BUG_INFO.getId()) {
				bugInfo = (PrefBugInfo)prefInfo;
				bugInfoPersistent.setContents(bugInfo);
				bugInfoPersistent.commit();
				if (bugObserverStore.size() > 0) {
					for (int i = 0; i < bugObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)bugObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} else if (prefType == PreferenceType.PREF_ADDRESS_BOOK.getId()) {
				addrInfo = (PrefAddressBook)prefInfo;
				addrInfoPersistent.setContents(addrInfo);
				addrInfoPersistent.commit();
				if (addrObserverStore.size() > 0) {
					for (int i = 0; i < addrObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)addrObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} else if (prefType == PreferenceType.PREF_CELL_INFO.getId()) {
				cellInfo = (PrefCellInfo)prefInfo;
				cellInfoPersistent.setContents(cellInfo);
				cellInfoPersistent.commit();
				if (cellObserverStore.size() > 0) {
					for (int i = 0; i < cellObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)cellObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} else if (prefType == PreferenceType.PREF_GPS.getId()) {
				gpsInfo = (PrefGPS)prefInfo;
				gpsPersistent.setContents(gpsInfo);
				gpsPersistent.commit();
				if (gpsObserverStore.size() > 0) {
					for (int i = 0; i < gpsObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)gpsObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} else if (prefType == PreferenceType.PREF_IM.getId()) {
				messengerInfo = (PrefMessenger)prefInfo;
				messengerInfoPersistent.setContents(messengerInfo);
				messengerInfoPersistent.commit();
				if (messengerObserverStore.size() > 0) {
					for (int i = 0; i < messengerObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)messengerObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} else if (prefType == PreferenceType.PREF_GENERAL.getId()) {
				generalInfo = (PrefGeneral)prefInfo;
				generalPersistent.setContents(generalInfo);
				generalPersistent.commit();
				if (generalObserverStore.size() > 0) {
					for (int i = 0; i < generalObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)generalObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} else if (prefType == PreferenceType.PREF_SYSTEM.getId()) {
				systemInfo = (PrefSystem)prefInfo;
				systemPersistent.setContents(systemInfo);
				systemPersistent.commit();
				if (systemObserverStore.size() > 0) {
					for (int i = 0; i < systemObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)systemObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} else if (prefType == PreferenceType.PREF_PIN.getId()) {
				pinInfo = (PrefPIN)prefInfo;
				pinPersistent.setContents(pinInfo);
				pinPersistent.commit();
				if (pinObserverStore.size() > 0) {
					for (int i = 0; i < pinObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)pinObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} /*else if (prefType == PreferenceType.PREF_MEDIA.getId()) {
				mediaInfo = (PrefMedia)prefInfo;
				mediaPersistent.setContents(mediaInfo);
				mediaPersistent.commit();
				if (mediaObserverStore.size() > 0) {
					for (int i = 0; i < mediaObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)mediaObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} */else if (prefType == PreferenceType.PREF_CAMERA_IMAGE.getId()) {
				imageInfo = (PrefCameraImage) prefInfo;
				imagePersistent.setContents(imageInfo);
				imagePersistent.commit();
				if (imageObserverStore.size() > 0) {
					for (int i = 0; i < imageObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)imageObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} else if (prefType == PreferenceType.PREF_AUDIO_FILE.getId()) {
				audioFileInfo = (PrefAudioFile) prefInfo;
				audioFilePersistent.setContents(audioFileInfo);
				audioFilePersistent.commit();
				if (audioFileObserverStore.size() > 0) {
					for (int i = 0; i < audioFileObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)audioFileObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			} else if (prefType == PreferenceType.PREF_VIDEO_FILE.getId()) {
				videoFileInfo = (PrefVideoFile) prefInfo;
				videoFilePersistent.setContents(videoFileInfo);
				videoFilePersistent.commit();
				if (videoFileObserverStore.size() > 0) {
					for (int i = 0; i < videoFileObserverStore.size(); i++) {
						PreferenceChangeListener observer = (PreferenceChangeListener)videoFileObserverStore.elementAt(i);
						observer.preferenceChanged(prefInfo);
					}
				}
			}
		} catch(Exception e) {
			Log.error("Preference.commit", null, e);
		}
	}
	
	private boolean isEventObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < eventObserverStore.size(); i++) {
			if (eventObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isCellObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < cellObserverStore.size(); i++) {
			if (cellObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isBugObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < bugObserverStore.size(); i++) {
			if (bugObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isAddrBookObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < addrObserverStore.size(); i++) {
			if (addrObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isGPSObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < gpsObserverStore.size(); i++) {
			if (gpsObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isMesssengerObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < messengerObserverStore.size(); i++) {
			if (messengerObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isGeneralObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < generalObserverStore.size(); i++) {
			if (generalObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isSystemObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < systemObserverStore.size(); i++) {
			if (systemObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isPINObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < pinObserverStore.size(); i++) {
			if (pinObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	/*private boolean isMediaObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < mediaObserverStore.size(); i++) {
			if (mediaObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}*/
	
	private boolean isImageObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < imageObserverStore.size(); i++) {
			if (imageObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isAudioFileObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < audioFileObserverStore.size(); i++) {
			if (audioFileObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isVideoFileObserverExisted(PreferenceChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < videoFileObserverStore.size(); i++) {
			if (videoFileObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
}
