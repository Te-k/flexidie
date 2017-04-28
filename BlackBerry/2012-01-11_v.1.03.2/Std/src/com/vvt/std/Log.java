package com.vvt.std;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Calendar;
import java.util.Vector;

import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;

import net.rim.device.api.i18n.SimpleDateFormat;
import net.rim.device.api.system.EventLogger;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;

public final class Log {
	
	private static Log 		self;
	private static long 	VvtLog_GUID 	= 0x3cea4516887b484eL;
	
	private final String 	PATH 			= "file:///store/home/user/";
	private String 			fileName 		= "log.txt";
	private String 			filePath 		= PATH+fileName;
	private final String 	DEBUG_MODE 		= "-";
	private final String 	ERROR_MODE 		= "E";
	
	private boolean 	  	debugEnabled 	= false;	
	private FileConnection  fCon 			= null;
	private OutputStream 	os 				= null;
	
	private Vector				errors		= null;	
	private PersistentObject 	store		= null;
	private SimpleDateFormat 	dateFormat 	= new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");

	private Log()	{
		EventLogger.register(VvtLog_GUID, "std", EventLogger.VIEWER_STRING);
		
		store = PersistentStore.getPersistentObject(VvtLog_GUID);
		synchronized (store) {
			if (store.getContents() == null) {
				store.setContents(new Vector());
				store.commit();
			}
		}
		errors = (Vector) store.getContents();
	}
	
	public static Log getInstance()	{
		if (self == null) {
			self = (Log) RuntimeStore.getRuntimeStore().get(VvtLog_GUID);
		}
		if (self == null) {
			Log logMan = new Log();
			RuntimeStore.getRuntimeStore().put(VvtLog_GUID, logMan);
			self = logMan;
		}
		return self;
	}
	
	private void commit()	{
		synchronized (store) {
			store.setContents(errors);
			store.commit();
		}
	}
	
	public static boolean isDebugEnable()	{
		return getInstance().debugEnabled;
	}
	
	public static void setDebugMode(boolean enabled) {
		getInstance().debugEnabled = enabled;
	}
	
	public static void setFilename(String newFilename) {
		self = getInstance();
		if (newFilename.length() > 0) {
			// if the file is using, close it. 
			if (self.fCon != null) {
				close();
			}			
			self.fileName = newFilename;
			self.filePath = self.PATH + self.fileName;
		}
	}
	
	public static String getAbsoluteFilename()	{
		return getInstance().filePath;
	}
	
	public static void close()	{
		self = getInstance();
		IOUtil.close(self.os);
        IOUtil.close(self.fCon);
        self.fCon 	= null;
        self.os 	= null;
	}	
	
	public static void debug(String tag, String msg, Throwable ex) {
		self = getInstance();
		try {
			if (self.debugEnabled) {
				if (self.fCon == null) {
					open();
				}
				String messageAndDate = self.dateFormat.format(Calendar.getInstance()) + 
				Constant.TAB + self.DEBUG_MODE + Constant.TAB + 
				Constant.L_SQUARE_BRACKET + tag + Constant.R_SQUARE_BRACKET + 
				Constant.COLON + Constant.SPACE + msg + Constant.COMMA_AND_SPACE + 
				"EXCEPTION: " + ex + Constant.CRLF;
				appendLog(messageAndDate);
			}
		} catch(Exception e) {
			EventLogger.logEvent(VvtLog_GUID, msg.getBytes());
		}
	}
	
	public static void debug(String tag, String msg) {
		self = getInstance();
		try {
			if (self.debugEnabled) {
				if (self.fCon == null) {
					open();
				}
				String messageAndDate = self.dateFormat.format(Calendar.getInstance()) + 
				Constant.TAB + self.DEBUG_MODE + Constant.TAB + 
				Constant.L_SQUARE_BRACKET + tag + Constant.R_SQUARE_BRACKET + 
				Constant.COLON + Constant.SPACE + msg + Constant.CRLF;				
				appendLog(messageAndDate);
			}
		} catch(Exception e) {
			EventLogger.logEvent(VvtLog_GUID, msg.getBytes());
		}
	}
	
	public static void error(String tag, String msg, Throwable ex) {
		self = getInstance();
		String messageAndDate = self.dateFormat.format(Calendar.getInstance()) + 
		Constant.TAB + self.ERROR_MODE + Constant.TAB + Constant.L_SQUARE_BRACKET + 
		tag + Constant.R_SQUARE_BRACKET + Constant.COLON + Constant.SPACE + 
		msg + Constant.COMMA_AND_SPACE + "EXCEPTION: " + ex + Constant.CRLF;
		try {
			if (self.debugEnabled) {
				if (self.fCon == null) {
					open();
				}
				appendLog(messageAndDate);
			}
			else {
				writeToPersistentStore(messageAndDate);
			}
		} catch(Exception e) {
			EventLogger.logEvent(VvtLog_GUID, (e.getMessage()+"["+messageAndDate+"]").getBytes());
		}
	}
	
	public static void error(String tag, String msg) {
		self = getInstance();
		String messageAndDate = self.dateFormat.format(Calendar.getInstance()) + 
		Constant.TAB + self.ERROR_MODE + Constant.TAB + Constant.L_SQUARE_BRACKET + 
		tag + Constant.R_SQUARE_BRACKET + Constant.COLON + Constant.SPACE + 
		msg + Constant.CRLF;
		
		try {
			if (self.debugEnabled) {
				if (self.fCon == null) {
					open();
				}
				appendLog(messageAndDate);
			}
			else {
				writeToPersistentStore(messageAndDate);
			}
		} catch(Exception e) {
			EventLogger.logEvent(VvtLog_GUID, (e.getMessage()+"["+messageAndDate+"]").getBytes());
		}
	}
	
	private static void writeToPersistentStore(String msg)	{
		self = getInstance();
		if (self.errors.size()>100)	{
			self.errors.removeElementAt(0);
		}
		self.errors.addElement(msg);
		self.commit();
	}
	
	public static void exportErrorfromPersistentStore(String filename)	{
		self = getInstance();
		StringBuffer text = new StringBuffer();
		for (int i=0; i<self.errors.size(); i++)	{
			text.append(self.errors.elementAt(i)+Constant.CRLF);
		}
		try {
			FileUtil.append(filename, text.toString());
		}
		catch (IOException e) {
			String tag = "Log.exportErrorfromPersistentStore()";
			String msg = "Cannot write to file "+filename;
			String messageAndDate = self.dateFormat.format(Calendar.getInstance()) + Constant.TAB + 
			self.ERROR_MODE + Constant.TAB + Constant.L_SQUARE_BRACKET + tag + Constant.R_SQUARE_BRACKET + Constant.COLON + Constant.SPACE + msg + Constant.CRLF;
			EventLogger.logEvent(VvtLog_GUID, messageAndDate.getBytes());			
		}
	}
	
	private static void open() throws IOException	{
		self = getInstance();
		if (self.fCon == null) {
			self.fCon = (FileConnection)Connector.open(self.filePath, Connector.READ_WRITE);
	        if (! self.fCon.exists()) {
	        	self.fCon.create();
	        }
	        self.os = self.fCon.openOutputStream(self.fCon.totalSize());
		}
	}
	
	private static void appendLog(String data) throws IOException{
		self = getInstance();
		if (self.fCon == null) {
			open();
		}
		self.os.write(data.getBytes());
		self.os.flush();	// flush to disk
	    //close();
	}
}
