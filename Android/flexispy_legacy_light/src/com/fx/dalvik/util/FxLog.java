package com.fx.dalvik.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringReader;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.util.Log;

public class FxLog {
	
	private static final boolean WRITE = true;
	private static final boolean SHOW = true;
	
	private static final String ERROR = "ERROR";
	private static final String WARNING = "WARNING";
	private static final String INFO = "INFO";
	private static final String DEBUG = "DEBUG";
	private static final String VERBOSE = "VERBOSE";
	
	private static final String sFilePath = "/sdcard/fx_error.log";
	
	private static final DateFormat sDateFormatter = 
		new SimpleDateFormat("MM-dd HH:mm:ss.SSS");
	
	private static File sFile;
	
	public static void e(String tag, String msg) {
		writeFxLog(ERROR, tag, msg);
		if (SHOW) Log.e(tag, msg);
	}
	
	public static void e(String tag, String msg, Throwable e) {
		writeFxLog(ERROR, tag, msg, e);
		if (SHOW) Log.e(tag, msg, e);
	}
	
	public static void w(String tag, String msg) {
		writeFxLog(WARNING, tag, msg);
		if (SHOW) Log.w(tag, msg);
	}
	
	public static void w(String tag, String msg, Throwable e) {
		writeFxLog(WARNING, tag, msg, e);
		if (SHOW) Log.w(tag, msg, e);
	}
	
	public static void i(String tag, String msg) {
		if (WRITE) writeFxLog(INFO, tag, msg);
		if (SHOW) Log.i(tag, msg);
	}
	
	public static void i(String tag, String msg, Throwable e) {
		if (WRITE) writeFxLog(INFO, tag, msg, e);
		if (SHOW) Log.i(tag, msg, e);
	}
	
	public static void d(String tag, String msg) {
		if (WRITE) writeFxLog(DEBUG, tag, msg);
		if (SHOW) Log.d(tag, msg);
	}
	
	public static void d(String tag, String msg, Throwable e) {
		if (WRITE) writeFxLog(DEBUG, tag, msg, e);
		if (SHOW) Log.d(tag, msg, e);
	}
	
	public static void v(String tag, String msg) {
		if (WRITE) writeFxLog(VERBOSE, tag, msg);
		if (SHOW) Log.v(tag, msg);
	}
	
	public static void v(String tag, String msg, Throwable e) {
		if (WRITE) writeFxLog(VERBOSE, tag, msg, e);
		if (SHOW) Log.v(tag, msg, e);
	}
	
	public static void deleteFxFxLogFile() {
		if (sFile != null && sFile.exists()) {
			sFile.delete();
		}
	}
	
	private static void createFxLogFile() {
		sFile = new File(sFilePath);
		
		if (! sFile.exists()) {
			try { sFile.createNewFile(); }
			catch (IOException e) { /* ignore */ }
		}
	}
	
	private synchronized static void writeFxLog(
			String level, String tag, String msg, Throwable e) {
		
		StringBuilder b = new StringBuilder();
		b.append(msg).append("\t").append(e.toString());
		writeFxLog(level, tag, b.toString());
	}
	
	private synchronized static void writeFxLog(String level, String tag, String msg) {
		if (sFile == null) {
			createFxLogFile();
		}
		
		if (sFile == null || !sFile.canWrite()) {
			return;
		}
		
		try {
			BufferedReader reader = new BufferedReader(new StringReader(msg), 256);
			BufferedWriter writer = new BufferedWriter(new FileWriter(sFile, true), 256);
			
			Date date = new Date();
			date.setTime(System.currentTimeMillis());
			String time = sDateFormatter.format(date);
			
			String line = null;
			while ((line = reader.readLine()) != null) {
				writer.append(time);
				writer.append("\t");
				
				writer.append(String.format("%s/%s", level, tag));
				writer.append("\t");
				
				writer.append(line);
				writer.append("\r\n");
			}
			writer.flush();
			writer.close();
		}
		catch (IOException e) { /* ignore */ }
	}
	
}
