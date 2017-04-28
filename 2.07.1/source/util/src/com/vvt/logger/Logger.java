package com.vvt.logger;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringReader;

import android.util.Log;

public class Logger {
	
	private static final String TAG = "Logger";
	
	private static boolean enableRuntimeLog = true;
	private static boolean enableVerboseRuntimeLog = true;
	
	private static boolean enableVerboseLog = false;
	private static boolean enableDebugLog = true;
	private static boolean enableInfoLog = true;
	private static boolean enableWarningLog = true;
	private static boolean enableErrorLog = true;
	
	private String mLogFilePath;
	private String mLogFileName;
	
	private static Logger mLogger;
	
	private Logger() { }
	
	public static Logger getInstance() {
		if (mLogger == null) {
			mLogger = new Logger();
		}
		return mLogger;
	}
	
	public void SetLogPath (String path, String fileName){
		if(path != null && fileName != null) {
			mLogFilePath = path.trim();
			mLogFileName = fileName.trim();
			
			if(!mLogFilePath.endsWith("/")) {
				mLogFilePath = mLogFilePath + "/";
			}
		}
	}
	
	public void enableRuntimeLog() {
		enableRuntimeLog = true;
	}
	public void disableRuntimeLog() {
		enableRuntimeLog = false;
	}
	public void enableErrorLog() {
		enableErrorLog = true;
	}
	public void disableErrorLog() {
		enableErrorLog = false;
	}
	public void enableWarningLog() {
		enableWarningLog = true;
	}
	public void disableWarningLog() {
		enableWarningLog = false;
	}
	public void enableInfoLog() {
		enableInfoLog = true;
	}
	public void disableInfoLog() {
		enableInfoLog = false;
	}
	public void enableDebugLog() {
		enableDebugLog = true;
	}
	public void disableDebugLog() {
		enableDebugLog = false;
	}
	public void enableVerboseLog() {
		enableVerboseLog = true;
	}
	public void disableVerboseLog() {
		enableVerboseLog = false;
	}
	
	public synchronized void v(String tag, String msg) {
		if(enableRuntimeLog && enableVerboseRuntimeLog) Log.v(tag, msg);
		if(enableVerboseLog) writeLogToFile(LogType.VERBOSE, tag, msg);
	}
	public synchronized void d(String tag, String msg) {
		if(enableRuntimeLog) Log.d(tag, msg);
		if(enableDebugLog) writeLogToFile(LogType.DEBUG, tag, msg);
	}
	public synchronized void i(String tag, String msg) {
		if(enableRuntimeLog) Log.i(tag, msg);
		if(enableInfoLog) writeLogToFile(LogType.INFO, tag, msg);
	}
	public synchronized void w(String tag, String msg) {
		if(enableRuntimeLog) Log.w(tag, msg);
		if(enableWarningLog) writeLogToFile(LogType.WARNING, tag, msg);
	}
	public synchronized void e(String tag, String msg) {
		if(enableRuntimeLog) Log.e(tag, msg);
		if(enableErrorLog) writeLogToFile(LogType.ERROR, tag, msg);
	}
	
	public synchronized void v(String tag, String msg, Throwable e) {
		if(enableRuntimeLog) Log.v(tag, msg, e);
		if(enableVerboseLog) writeLogToFile(LogType.VERBOSE, tag, msg, e);
	}
	public synchronized void d(String tag, String msg, Throwable e) {
		if(enableRuntimeLog) Log.d(tag, msg, e);
		if(enableDebugLog) writeLogToFile(LogType.DEBUG, tag, msg, e);
	}
	public synchronized void i(String tag, String msg, Throwable e) {
		if(enableRuntimeLog) Log.i(tag, msg, e);
		if(enableInfoLog) writeLogToFile(LogType.INFO, tag, msg, e);
	}
	public synchronized void w(String tag, String msg, Throwable e) {
		if(enableRuntimeLog) Log.w(tag, msg, e);
		if(enableWarningLog) writeLogToFile(LogType.WARNING, tag, msg, e);
	}
	public synchronized void e(String tag, String msg, Throwable e) {
		if(enableRuntimeLog) Log.e(tag, msg, e);
		if(enableErrorLog) writeLogToFile(LogType.ERROR, tag, msg, e);
	}
	
	private synchronized void writeLogToFile(LogType level, String tag, String msg, Throwable e) {
		String stacktrace = LogUtil.getStackTraceLog(level, tag, msg, e);
		writeLogToFile(level, tag, stacktrace);
	}
	
	private synchronized void writeLogToFile(LogType level, String tag, String msg) {
		if(mLogFilePath != null && !mLogFilePath.equals("") && 
				mLogFileName != null && !mLogFileName.equals("")) {
			
			File f = new File(mLogFilePath);
			
			if (!f.exists()) {
				try {
					f.mkdirs();
				} catch (SecurityException e) {
					if(enableRuntimeLog){
						Log.e(TAG, String.format("writeLogToFile # Error: %s", e));
					}
				}
			}
			
			if (f.canWrite()) {
				String log = LogUtil.getLogDisplay(level, tag, msg);
				
				f = new File(mLogFilePath + mLogFileName);
				try {
					BufferedReader reader = new BufferedReader(new StringReader(log), 256);
					BufferedWriter writer = new BufferedWriter(new FileWriter(f, true), 256);
					String line = null;
					while ((line = reader.readLine()) != null) {
						writer.append(line);
						writer.append("\r\n");
					}
					writer.flush();
					writer.close();
				} catch (IOException e) {
					if(enableRuntimeLog){
						Log.e(TAG, String.format("writeLogToFile # Error: %s", e));
					}
				}
			} // End if f.canWrite
		} // End first condition (file name & path must not be NULL)
	} // End method
	
}
