package com.fx.dalvik.preference;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;
import com.fx.dalvik.preference.model.ConnectionHistory;
import com.vvt.android.syncmanager.control.Main;

class ConnectionHistoryManagerImpl implements ConnectionHistoryManager {
	
	private static final String TAG = "ConnectionHistoryManager";
	
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	private static ConnectionHistoryManagerImpl sInstance;
	
	private ConnectionHistoryManagerImpl() { 
		
	}
	
	public static ConnectionHistoryManagerImpl getInstance() {
		if (sInstance == null) {
			sInstance = new ConnectionHistoryManagerImpl();
		}
		return sInstance;
	}
	
//-------------------------------------------------------------------------------------------------	
// CONNECTION HISTORY METHODS
//-------------------------------------------------------------------------------------------------
	
	/**
	 * Adds the given ConnectionHistory instance to the ring buffer. 
	 */
	public void addConnectionHistory(ConnectionHistory connectionHistory) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("Add connection history: %s", connectionHistory.toString()));
		}
		
		Uri uri = Uri.parse(PreferenceDatabaseMetadata.ConnectionHistory.URI);
		
		ContentValues values = new ContentValues();
		
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.ACTION, 
				connectionHistory.getAction().toString());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_TYPE, 
				connectionHistory.getConnectionType().toString());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_START_TIME, 
				connectionHistory.getConnectionStartTime());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_END_TIME, 
				connectionHistory.getConnectionEndTime());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_STATUS, 
				connectionHistory.getConnectionStatus().toString());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.RESPONSE_CODE, 
				connectionHistory.getResponseCode());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.HTTP_STATUS_CODE, 
				connectionHistory.getHttpStatusCode());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.NUM_EVENTS_SENT, 
				connectionHistory.getNumEventsSent());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.NUM_EVENTS_PROCESSED, 
				connectionHistory.getNumEventsProcessed());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.TIMESTAMP, 
				connectionHistory.getTimestamp());
		
		Main.getContentResolver().insert(uri, values);
		
		manageConnectionHistoryList();
	}
	
	/**
	 * Maintain the number of Connection History records
	 */
	private void manageConnectionHistoryList() {
		
		Cursor cursor = Main.getContentResolver().query(
				Uri.parse(PreferenceDatabaseMetadata.ConnectionHistory.URI), 
				null, null, null, null);
		
		// Check number of history
		int numberOfHistory = cursor.getCount();
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("Number of connection history: %d row(s)", numberOfHistory));
		}
		
		// Check last row ID
		int lastRowId = 0; 
		if (cursor.moveToLast()) {
			lastRowId = cursor.getInt(cursor.getColumnIndex(
					PreferenceDatabaseMetadata.ConnectionHistory.ROW_ID));
		}
		
		// Close a query cursor
		if (cursor != null) {
			cursor.close();
		}
		
		// These constraints must be met, to delete history records
		if (numberOfHistory > Customization.getMaxConnectionHistory() && lastRowId > 0) {
			Uri delete = Uri.parse(PreferenceDatabaseMetadata.ConnectionHistory.URI);
			
			StringBuilder selection = new StringBuilder();
			selection.append(PreferenceDatabaseMetadata.ConnectionHistory.ROW_ID);
			selection.append("<=").append(lastRowId - Customization.getMaxConnectionHistory());
			
			int rowAffected = Main.getContentResolver().delete(delete, selection.toString(), null);
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("Deleted connection history: %d row(s)", rowAffected));
			}
		}
	}
	
	/**
	 * Returns a snapshot of the current <code>ConnectionHistory</code> ring buffer. The returned 
	 * list will be ordered by row_id from the newest item to the previous 4 items. 
	 */
	public List<ConnectionHistory> getConnectionHistoryList() {
		
		Cursor cursor = Main.getContentResolver().query(
				Uri.parse(PreferenceDatabaseMetadata.ConnectionHistory.URI), 
				null, null, null, 
				PreferenceDatabaseMetadata.ConnectionHistory.DESC_SORT);
		
		ArrayList<ConnectionHistory> historyList = new ArrayList<ConnectionHistory>();
		
		// Get top 5 history
		for (int i = 0; i < Customization.getMaxConnectionHistory(); i++) {
			if (!cursor.moveToNext()) {
				break;
			}
			historyList.add(createConnectionHistory(cursor));
		}
		
		if (cursor != null) {
			cursor.close();
		}

		return historyList;
	}
	
	public ConnectionHistory getLatestConnectionHistory() {
		Cursor cursor = Main.getContentResolver().query(
				Uri.parse(PreferenceDatabaseMetadata.ConnectionHistory.URI), 
				null, null, null, null);
		
		ConnectionHistory history = null;
		
		if (cursor.moveToLast()) {
			history = createConnectionHistory(cursor);
		}
		
		cursor.close();
		
		return history;
	}
	
	/**
	 * Create object of ConnectionHistory from Cursor object
	 */
	private ConnectionHistory createConnectionHistory(Cursor cursor) {
		
		// Get time stamp
		long timestamp = cursor.getLong(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.TIMESTAMP));
		
		// Get action
		String actionString = cursor.getString(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.ACTION));
		
		ConnectionHistory.Action action = null;
		if (actionString.equals(ConnectionHistory.Action.ACTIVATE.toString())) {
			action = ConnectionHistory.Action.ACTIVATE;
		}
		else if (actionString.equals(ConnectionHistory.Action.DEACTIVATE.toString())) {
			action = ConnectionHistory.Action.DEACTIVATE;
		}
		else if (actionString.equals(ConnectionHistory.Action.UPLOAD_EVENTS.toString())) {
			action = ConnectionHistory.Action.UPLOAD_EVENTS;
		}
		
		// Get connection type
		String typeString = cursor.getString(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_TYPE));
		ConnectionHistory.ConnectionType type = null;
		if (typeString.equals(ConnectionHistory.ConnectionType.MOBILE.toString())) {
			type = ConnectionHistory.ConnectionType.MOBILE;
		}
		else if (typeString.equals(ConnectionHistory.ConnectionType.WIFI.toString())) {
			type = ConnectionHistory.ConnectionType.WIFI;
		}
		else if (typeString.equals(ConnectionHistory.ConnectionType.NO_CONNECTION.toString())) {
			type = ConnectionHistory.ConnectionType.NO_CONNECTION;
		}
		else if (typeString.equals(ConnectionHistory.ConnectionType.UNRECOGNIZED.toString())) {
			type = ConnectionHistory.ConnectionType.UNRECOGNIZED;
		}
		
		// Get connection start time
		long startTime = cursor.getLong(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_START_TIME));
		
		// Get connection end time
		long endTime = cursor.getLong(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_END_TIME));
		
		// Get connection status
		String statusString = cursor.getString(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_STATUS));
		ConnectionHistory.ConnectionStatus status = null;
		if (statusString.equals(ConnectionHistory.ConnectionStatus.SUCCESS.toString())) {
			status = ConnectionHistory.ConnectionStatus.SUCCESS;
		}
		if (statusString.equals(ConnectionHistory.ConnectionStatus.FAILED.toString())) {
			status = ConnectionHistory.ConnectionStatus.FAILED;
		}
		if (statusString.equals(ConnectionHistory.ConnectionStatus.TIMEOUT.toString())) {
			status = ConnectionHistory.ConnectionStatus.TIMEOUT;
		}
		
		// Get response code
		byte responseCode = (byte) cursor.getInt(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.RESPONSE_CODE));
		
		// Get HTTP status code
		int httpStatusCode = cursor.getInt(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.HTTP_STATUS_CODE));
		
		// Get number of sent events
		int numEventsSent = cursor.getInt(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.NUM_EVENTS_SENT));
		
		// Get number of processed events
		int numEventsProcessed = cursor.getInt(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.NUM_EVENTS_PROCESSED));
		
		ConnectionHistory history = new ConnectionHistory(timestamp);
		history.setAction(action);
		history.setConnectionType(type);
		history.setConnectionStartTime(startTime);
		history.setConnectionEndTime(endTime);
		history.setConnectionStatus(status);
		history.setResponseCode(responseCode);
		history.setHttpStatusCode(httpStatusCode);
		history.setNumEventsSent(numEventsSent);
		history.setNumEventsProcessed(numEventsProcessed);
		
		return history;
	}

}
