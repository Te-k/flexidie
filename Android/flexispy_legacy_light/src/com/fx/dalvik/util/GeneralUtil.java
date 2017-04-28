package com.fx.dalvik.util;

import java.io.File;
import java.lang.reflect.Method;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;

import com.fx.dalvik.util.FxLog;

import android.net.Uri;
import android.view.View;
import android.view.inputmethod.InputMethodManager;

import com.fx.android.common.Customization;
import com.fx.android.common.http.HttpWrapper;
import com.fx.android.common.http.HttpWrapperResponse;

public class GeneralUtil {
	
//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
	private static final String TAG = "GeneralUtils";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOGE = Customization.DEBUG ? DEBUG : false;
	
	private static DateFormat sDateFormat;
	
	
//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	public static DateFormat getDateFormatter() {
		if (sDateFormat == null) {
			sDateFormat = new SimpleDateFormat("dd/MM/yy HH:mm:ss");
		}
		return sDateFormat;
	}
	
	/**
	 * Converts the data bytes to a string using format 1. 
	 */
	public static String bytesToString1(byte[] aData) {
		StringBuilder aOut = new StringBuilder();
		if (aData != null) {
			for (int i = 0 ; i < aData.length ; i++) {
				aOut.append(String.format(" [%2d]=%02X", i, aData[i]));
			}
		}
		return aOut.toString();
	}
	
	/**
	 * Converts the data bytes to a string using format 2. 
	 */
	public static String bytesToString2(byte[] aData) {
		StringBuilder aOut = new StringBuilder();
		if (aData != null) {
			for (int i = 0 ; i < aData.length ; i++) {
				byte b = aData[i];
				char c = (char) b;
				if ((c >= 'a' && c <= 'z') || 
					(c >= 'A' && c <= 'Z') || 
					(c >= '0' && c <= '9') || 
					(c == '@') ||
					(c == '/') ||
					(c == ' ') || 
					(c == '.')) {
					aOut.append(c);
				} else {
					aOut.append(String.format("\\x%02X", b));
				}
			}
		}
		return aOut.toString();
	}
	
	/**
	 * Converts the data bytes starting from the given index to the index aEndIndex - 1 
	 * to a string using format 2. 
	 */
	public static String bytesToString2(byte[] aData, int aStartIndex, int aEndIndex) {
		StringBuilder aOut = new StringBuilder();
		if (aData != null) {
			for (int i = 0 ; i < aData.length ; i++) {
				if (i >= aStartIndex && i < aEndIndex) {
					byte b = aData[i];
					char c = (char) b;
					if ((c >= 'a' && c <= 'z') || 
						(c >= 'A' && c <= 'Z') || 
						(c >= '0' && c <= '9') || 
						(c == '@') ||
						(c == '/') ||
						(c == ' ') || 
						(c == '.')) {
						aOut.append(c);
					} else {
						aOut.append(String.format("\\x%02X", b));
					}
				}
			}
		}
		return aOut.toString();
	}
	
	/**
	 * Converts the data bytes to a string using format 3. 
	 */
	public static String bytesToString3(byte[] aData) {
		StringBuilder out = new StringBuilder();
		if (aData != null) {
			boolean addSpace = false;
			out.append("<");
			for (int i = 0 ; i < aData.length ; i++) {
				if (addSpace) {
					out.append(" ");
					addSpace = false;
				}
				byte b = aData[i];
				out.append(String.format("%02x", b));
				if (i % 4 == 3) {
					addSpace = true;
				}
			}
			out.append(">");
		}
		return out.toString();
	}
	
	/**
	 * Converts the data bytes to a string using format 4. 
	 */
	public static String bytesToString4(byte[] aData) {
		StringBuilder out = new StringBuilder();
		if (aData != null) {
			for (int i = 0 ; i < aData.length ; i++) {
				out.append(String.format("%02X", aData[i]));
			}
		}
		return out.toString();
	}

	/**
	 * Deletes the given File. The given File can be a file or a directory. 
	 * The directory can be deleted even if it is not empty. 
	 */
	public static boolean deleteFile(File aFile) {
		if (aFile.isDirectory()) {
			String[] aChildren = aFile.list();
			for (int i = 0 ; i < aChildren.length ; i++) {
				boolean aSuccess = deleteFile(new File(aFile, aChildren[i]));
				if (! aSuccess) {
					return false;
				}
			}
		}
		return aFile.delete();
	}
	
	/**
	 * Deletes file or directory of the given path. 
	 * The directory can be deleted even if it is not empty. 
	 */
	public static boolean deletePath(String aPath) {
		return deleteFile(new File(aPath));
	}
	
	/**
	 * Convert the given URL to the short URL by using Tiny URL web service.
	 * If any error occurs during conversion, the method will return the original URL.
	 * 
	 * @param aLongUrl
	 * @return
	 */
	public static String shortenUrl(String aLongUrl) {
		if (LOGV) {
			FxLog.v(TAG, "shortenUrl # ENTER ...");
			FxLog.v(TAG, String.format("Original URL: %s", aLongUrl));
		}
		try {
			HttpWrapper aHttpWrapper = HttpWrapper.getInstance();
			HttpWrapperResponse aResponse = null;
			aResponse = aHttpWrapper.httpGet(
					String.format("http://tinyurl.com/api-create.php?url=%s", aLongUrl));
			if (aResponse.getHttpStatusCode() == 200) {
				if (LOGV) {
					FxLog.v(TAG, String.format("Short URL: %s", aResponse.toString()));
				}
				return aResponse.toString();
			}
		} catch (Exception e) {
			if (LOGE) FxLog.e(TAG, "An error occurs, return the original URL.", e);
		}
		return aLongUrl;
	}
	
	
	/**
	 * Hides soft keyboard for the given view. 
	 */
	public static void hideSoftInput(Context aContext, View aView) {
		InputMethodManager aInputMethodManager = 
				(InputMethodManager) aContext.getSystemService(Context.INPUT_METHOD_SERVICE);
		if (aInputMethodManager != null && aView != null) {
			aInputMethodManager.hideSoftInputFromWindow(aView.getWindowToken(), 0);
		}
	}

	public static boolean isNullOrEmptyString(String aString) {
		return aString == null || "".equalsIgnoreCase(aString) ? true : false;
	}
	
	public static String[] getTokenArray(String string, String delimiters) {
		StringTokenizer tokenizer = new StringTokenizer(string, delimiters);
		String[] tokenArray = new String[tokenizer.countTokens()];
		for (int i = 0; tokenizer.hasMoreTokens(); i++) {
			tokenArray[i] = tokenizer.nextToken().trim();
		}
		return tokenArray;
	}
	
	public static String getCleanedEmailBody(String input) {
		if (input == null) {
			return null;
		}
		
		Pattern p = null;
		Matcher m = null;
		String output = null;
		
		// replace BR with \n
		p = Pattern.compile("<[/]*br[^>]*>");
		m = p.matcher(input);
		output = m.replaceAll("\n");
		
		p = Pattern.compile("<[/]*p[^>]*>");
		m = p.matcher(output);
		output = m.replaceAll("\n");
		
		p = Pattern.compile("<[^<>]*>");
		m = p.matcher(output);
		output = m.replaceAll("");
		
		return output.trim();
	}
	
	public static String getTimeDisplayValue(int second) {		
		int minute = second / 60;
		
		// Value is greater than a minute
		if (minute > 0) {
			int hour = second / 3600;
			
			// Value is greater than an hour
			if (hour > 0) {
				return String.format("%d %s", hour, hour == 1 ? "hr" : "hrs");
			}
			// Value is less than an hour
			else {
				return String.format("%d %s", minute, minute == 1 ? "min" : "mins");
			}
		}
		// Value is less than a minute
		else {
			return String.format("%d %s", second, second == 1 ? "sec" : "secs");
		}
	}
	
	public static void promptUninstallApplication(Context context) {
		Uri uriData = Uri.parse(String.format("package:%s", context.getPackageName()));
		Intent intent = new Intent(Intent.ACTION_DELETE);
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		intent.setData(uriData);
		context.startActivity(intent);
	}
	
	public static String formatCapturedPhoneNumber(String number) {
		boolean isEmptyString = number == null || number.trim().length() == 0;
		boolean isParsable = false;
		int parsedInt = 1;
		try {
			parsedInt = Integer.parseInt(number);
			isParsable = true;
		}
		catch (NumberFormatException e) { /* ignore */ }
		
		if (isEmptyString || isParsable && parsedInt < 0) {
			number = "Unknown";
		}
		
		return number;
	}
	
	public static void killPackage(Context context, String packageName) {
		if (LOGV) FxLog.v(TAG, "killPackage # ENTER ...");
		ActivityManager am = 
				(ActivityManager) context.getSystemService(
						Context.ACTIVITY_SERVICE);
		
		boolean isNewMethodFound = false;
		
		try {
			Class<?> clsAm = ActivityManager.class;
			Method metKillBgProc = clsAm.getDeclaredMethod("killBackgroundProcesses", String.class);
			metKillBgProc.setAccessible(true);
			metKillBgProc.invoke(am, packageName);
			isNewMethodFound = true;
			if (LOGV) FxLog.v(TAG, "killPackage # AM killBackgroundProcesses() is invoked");
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(TAG, String.format("killPackage # Error: %s", e));
		}
		
		if (!isNewMethodFound) {
			am.restartPackage(packageName);
			if (LOGV) FxLog.v(TAG, "killPackage # AM restartPackage() is invoked");
		}
		
		if (LOGV) FxLog.v(TAG, "killPackage # EXIT ...");
	}
	
}
