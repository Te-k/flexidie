package com.vvt.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.PrintWriter;
import java.io.Serializable;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.channels.FileChannel;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.InflaterInputStream;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;

import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.Shell;

public final class GeneralUtil {
	
	private static final String TAG = "GeneralUtil";
	private static boolean LOGV = Customization.VERBOSE;
	private static boolean LOGD = Customization.DEBUG;
	
	/**
	 * Retrieve a value from a specific column of a queried cursor
	 * @return value object
	 */
	public static Object getCursorValue(Cursor cursor, Class<?> valueClass, String valueColumn) {
		Object value = null;
		
		if (cursor.moveToNext()) {
    		if (valueClass == String.class) {
    			value = cursor.getString(cursor.getColumnIndex(valueColumn));
    		}
    		else if (valueClass == Boolean.class) {
    			value = cursor.getInt(cursor.getColumnIndex(valueColumn));
    			value = ((Integer) value).intValue() > 0 ? true : false;
    		}
    		else if (valueClass == Integer.class) {
    			value = Integer.valueOf(cursor.getInt(cursor.getColumnIndex(valueColumn)));
    		}
    		else if (valueClass == Long.class) {
    			value = Long.valueOf(cursor.getLong(cursor.getColumnIndex(valueColumn)));
    		}
    		else if (valueClass == Double.class) {
    			value = Double.valueOf(cursor.getDouble(cursor.getColumnIndex(valueColumn)));
    		}
    	}
		
		return value;
	}
	
	/**
	 * Retrieve content values object for updating a specific field in a table
	 */
	public static ContentValues getUpdatingContentValues(String key, Object value) {
		ContentValues values = new ContentValues();
		
		if (value instanceof String) {
			values.put(key, (String) value);
		}
		else if (value instanceof Boolean) {
			Integer intValue = (Boolean) value ? 1 : 0;
			values.put(key, (Integer) intValue);
		}
		else if (value instanceof Integer) {
			values.put(key, (Integer) value);
		}
		else if (value instanceof Long) {
			values.put(key, (Long) value);
		}
		else if (value instanceof Double) {
			values.put(key, (Double) value);
		}
		return values;
	}
	
	public static boolean isNullOrEmptyString(String text) {
		return text == null || "".equalsIgnoreCase(text) ? true : false;
	}
	
	public static String stackTraceToString(Throwable throwable) {
		StringWriter stringWriter = new StringWriter();
		PrintWriter printWriter = new PrintWriter(stringWriter);
		throwable.printStackTrace(printWriter);
		return stringWriter.toString();
	}

	/**
	 * Adjust the phone number input by user to the appropriate format. 
	 * (e.g. trim space characters)
	 * 
	 * @param   inputPhoneNumber the number entered by user
	 * @return  If the input is not the valid phone number, this method will return 
	 *          <code>null</code>.
	 */
	public static String formatInputPhoneNumber(String inputPhoneNumber) {
		inputPhoneNumber = inputPhoneNumber.trim();
		if (inputPhoneNumber.length() == 0) {
			return null;
		}
		return inputPhoneNumber;
	}
	
	public static void copyFile(String input, String output) throws IOException {
		if (LOGV) FxLog.v(TAG, "copyFile # ENTER ...");
		
		File in = new File(input);
		File out = new File(output);
		
		FileChannel inChannel = new FileInputStream(in).getChannel();
		FileChannel outChannel = new FileOutputStream(out).getChannel();	    
		try {
			inChannel.transferTo(0, inChannel.size(), outChannel);
		} catch (IOException e) {
			throw e;
		} finally {
			if (inChannel != null) inChannel.close();
			if (outChannel != null) outChannel.close();
		}
	}
	
	public static boolean isFileExist(String filePath) {
		return new File(filePath).exists();
	}
	
	public static int countSpecificWord(String text, String findingWord) {
		if (findingWord == null || findingWord.length() < 1) {
			return 0;
		}
		
		int count = 0;
		int idx = text.indexOf(findingWord);
		
		while (idx >= 0) {
			count++;
			
			// Avoid array index out of bound
			if (idx + findingWord.length() >= text.length()) {
				break;
			}
			
			// Log must be printed after checking length of text
			System.out.println(String.format(
					"count: %d, pointer: %d, char at pointer: '%s'", 
					count, idx + findingWord.length(), text.charAt(idx + findingWord.length())));
			
			// Look for next word
			idx = text.indexOf(findingWord, idx + findingWord.length());
		}
		
		return count;
	}
	
	public static boolean isDeviceRebooting(String[] args) {
		return args != null && args.length > 0 && "reboot".equals(args[0]);
	}
	
	public static boolean isRadioProcessStarting(String[] args) {
		return args != null && args.length > 0 && "radio".equals(args[0]);
	}
	
	public static boolean isEmptyArgument(String[] args) {
		return args == null || args.length == 0 || args[0].trim().length() == 0;
	}
	
	public static String[] getTokenArray(String string, String delimiters) {
		StringTokenizer tokenizer = new StringTokenizer(string, delimiters);
		String[] tokenArray = new String[tokenizer.countTokens()];
		for (int i = 0; tokenizer.hasMoreTokens(); i++) {
			tokenArray[i] = tokenizer.nextToken().trim();
		}
		return tokenArray;
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
	
	public static boolean getRandomBoolean() {
		return Math.random() >= 0.5;
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
	
	/**
	 * Make a phone number ready for comparison.
	 * By removing leading characters e.g. +, -, and 0
	 * @param number
	 */
	public static String cleanPhoneNumber(String number) {
		if (number == null) {
			return null;
		}
		
		// Remove symbol + - ( )
		String cleanedNumber = 
			number.replace("+", "").replace("-", "")
				.replace("(", "").replace(")", "").replace(" ", "");
		
		// Remove beginning zero
		if (cleanedNumber.startsWith("0")) {
			Pattern p = Pattern.compile("[0]+");
			Matcher m = p.matcher(cleanedNumber);
			cleanedNumber = m.replaceFirst("");
		}
		
		return cleanedNumber;
	}
	
	public static String getUncompressedContent(byte[] input) {
		StringBuffer buff = new StringBuffer();
        
		try {
        	InflaterInputStream in = new InflaterInputStream(new ByteArrayInputStream(input));
        	BufferedReader reader = new BufferedReader(new InputStreamReader(in, "UTF-8"));
        	
        	String line = null;
        	while ((line = reader.readLine()) != null) {
        		buff.append(line);
        	}
        }
        catch (IOException e) {
        	FxLog.e(TAG, String.format("getUncompressedContent # Error: %s", e));
        }
        return buff.toString();
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
	
	public static void promptUninstallApplication(Context context) {
		Uri uriData = Uri.parse(String.format("package:%s", context.getPackageName()));
		Intent intent = new Intent(Intent.ACTION_DELETE);
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		intent.setData(uriData);
		context.startActivity(intent);
	}
	
	public static void collectSystemLog(String path) {
		if (path == null) {
			return;
		}
		String fullPath = String.format("%s/logcat.log", path);
		
		if (LOGD) {
			FxLog.i(TAG, String.format("collectSystemLog # Redirect logcat to %s", fullPath));
		}
		try {
			Shell shell = Shell.getRootShell();
			shell.exec(String.format("rm %s", fullPath));
			shell.exec(String.format("logcat -d -f %s", fullPath));
			shell.terminate();
		}
		catch (CannotGetRootShellException e) {
			FxLog.e(TAG, "collectSystemLog # Cannot get root shell!!");
		}
	}
	
	public static boolean serializeObject(Serializable obj, String pathOutput) 
			throws FileNotFoundException, IOException {
		boolean isSuccess = false;
		File f = new File(pathOutput);
		f.createNewFile();
		ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream(f));
		out.writeObject(obj);
		out.flush();
		out.close();
		isSuccess = true;
		return isSuccess;
	}
	
	public static Object deserializeObject(String path) 
			throws FileNotFoundException, IOException, ClassNotFoundException {
		Object obj = null;
		ObjectInputStream in = new ObjectInputStream(new FileInputStream(new File(path)));
		obj = in.readObject();
		in.close(); // FileInputStream must be closed after use to avoid memory leaks.
		return obj;
	}
	
	public static void writeToFile(String path, String msg, boolean append) {
		File logFile = createFile(path);
		
		if (logFile == null || !logFile.canWrite()) {
			if (LOGV) FxLog.v(TAG, String.format(
					"writeToFile # Cannot write to a specific path: %s", path));
			return;
		}
		
		try {
			BufferedReader reader = new BufferedReader(new StringReader(msg), 256);
			BufferedWriter writer = new BufferedWriter(new FileWriter(logFile, append), 256);
			
			String line = null;
			while ((line = reader.readLine()) != null) {
				writer.append(line);
				writer.append("\r\n");
			}
			writer.flush();
			writer.close();
		}
		catch (IOException e) { /* ignore */ }
	}
	
	private static String getDirectoryPath(String path) {
		String[] folders = path.split("/");
		StringBuilder builder = new StringBuilder();
		for (int i = 0; i < folders.length - 1; i++) {
			builder.append(folders[i]).append("/");
		}
		builder.replace(builder.length()-1, builder.length(), "");
		return builder.toString();
	}

	private static File createFile(String path) {
		String dirPath = getDirectoryPath(path);
		File dir = new File(dirPath);
		if (! dir.exists()) {
			if (dir.mkdirs()) {
				if (LOGV) FxLog.v(TAG, String.format(
						"createFile # Directory is created: %s", dirPath));
				
				Shell shell = Shell.getShell();
				shell.exec(String.format("chmod 777 %s", dirPath));
				shell.terminate();
			}
			else {
				if (LOGV) FxLog.v(TAG, String.format(
						"createFile # Create directory failed: %s", dirPath));
			}
		}
		
		File f = new File(path);
		
		if (! f.exists()) {
			try { 
				if (f.createNewFile()) {
					if (LOGV) FxLog.v(TAG, String.format(
							"createFile # File is created: %s", path));
					
					Shell shell = Shell.getShell();
					shell.exec(String.format("chmod 666 %s", path));
					shell.terminate();
				}
				
			}
			catch (IOException e) { /* ignore */ }
		}
		
		return f;
	}
	
}