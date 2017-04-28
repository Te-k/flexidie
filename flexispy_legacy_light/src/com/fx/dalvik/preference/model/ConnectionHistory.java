package com.fx.dalvik.preference.model;

import java.text.DateFormat;
import java.util.Date;

import com.fx.dalvik.util.GeneralUtil;
import com.vvt.android.syncmanager.FxResource;

public class ConnectionHistory {
	
	private static DateFormat sDateFormatter = GeneralUtil.getDateFormatter();
	
	private int rowId;
	
	private Action mAction;
	private ConnectionType mConnectionType;
	private Long mConnectionStartTime;
	private Long mConnectionEndTime;
	private ConnectionStatus mConnectionStatus;
	private Byte mResponseCode = -1;
	private Integer mHttpStatusCode;
	private Integer mNumEventsSent;
	private Integer mNumEventsProcessed;
	private Long mTimestamp;
	
	private String getTimeAsString(Long time) {
		if (time == null) {
			return "-";
		}
		return sDateFormatter.format(new Date(time));
	}

	public ConnectionHistory() {
		mTimestamp = System.currentTimeMillis();
	}
	
	public ConnectionHistory(long timestamp) {
		mTimestamp = timestamp;
	}
	
	public int getRowId() {
		return rowId;
	}
	
	/**
	 * Returns object creation time stamp determined by calling System.currentTimeMillis() in 
	 * the object constructor.
	 */
	public Long getTimestamp() {
		return mTimestamp;
	}
	
	public ConnectionType getConnectionType() {
		return mConnectionType;
	}

	public void setConnectionType(ConnectionType connectionType) {
		mConnectionType = connectionType;
	}
	
	public Long getConnectionStartTime() {
		return mConnectionStartTime;
	}

	public void setConnectionStartTime(Long startTime) {
		mConnectionStartTime = startTime;
	}

	public Long getConnectionEndTime() {
		return mConnectionEndTime;
	}

	public void setConnectionEndTime(long endTime) {
		mConnectionEndTime = endTime;
	}
	
	public Integer getNumEventsSent() {
		return mNumEventsSent;
	}

	public void setNumEventsSent(int numEventsSent) {
		mNumEventsSent = numEventsSent;
	}

	public Integer getNumEventsProcessed() {
		return mNumEventsProcessed;
	}

	public void setNumEventsProcessed(int numEventsProcessed) {
		mNumEventsProcessed = numEventsProcessed;
	}
	
	public Action getAction() {
		return mAction;
	}
	
	public void setAction(Action action) {
		mAction = action;
	}
	
	public Byte getResponseCode() {
		return mResponseCode;
	}
	
	public void setResponseCode(Byte responseCode) {
		mResponseCode = responseCode;
	}
	
	public ConnectionStatus getConnectionStatus() {
		return mConnectionStatus;
	}
	
	public void setConnectionStatus(ConnectionStatus status) {
		mConnectionStatus = status;
	}
	
	public Integer getHttpStatusCode() {
		return mHttpStatusCode;
	}
	
	public void setHttpStatusCode(Integer httpStatusCode) {
		mHttpStatusCode = httpStatusCode;
	}

	public String toString() {
		StringBuilder stringBuilder = new StringBuilder();
		
		// action
		if (mAction != null) {
			stringBuilder.append(FxResource.language_connection_history_name_action);
			stringBuilder.append("  ");
			stringBuilder.append(mAction);
			stringBuilder.append("\n");
		}

		// connection type
		if (mConnectionType != null) {
			stringBuilder.append(FxResource.language_connection_history_name_connection_type);
			stringBuilder.append("  ");
			stringBuilder.append(mConnectionType);
			stringBuilder.append("\n");
		}
		
		// start time
		stringBuilder.append(FxResource.language_connection_history_name_start_time);
		stringBuilder.append("  ");
		if (mConnectionStartTime == null) {
			stringBuilder.append(getTimeAsString(mTimestamp));
		} else {
			stringBuilder.append(getTimeAsString(mConnectionStartTime));
		}
		stringBuilder.append("\n");
		
		// end time
		if (mConnectionEndTime != null) {
			stringBuilder.append(FxResource.language_connection_history_name_end_time);
			stringBuilder.append("  ");
			stringBuilder.append(getTimeAsString(mConnectionEndTime));
			stringBuilder.append("\n");
			
			stringBuilder.append(FxResource.language_connection_history_name_duration);
			stringBuilder.append("  ");
			stringBuilder.append(mConnectionEndTime - mConnectionStartTime);
			stringBuilder.append("\n");
		}
		
		// connection status
		if (mConnectionStatus != null) {
			stringBuilder.append(FxResource.language_connection_history_name_connection_status);
			stringBuilder.append("  ");
			stringBuilder.append(mConnectionStatus);
			stringBuilder.append("\n");
		}
		
		// response code
		if (mResponseCode != null) {
			stringBuilder.append(FxResource.language_connection_history_name_response_code);
			stringBuilder.append("  ");
			stringBuilder.append(String.format("0x%02X", mResponseCode));
			stringBuilder.append("\n");
		}
		
		// HTTP status code
		if (mHttpStatusCode != null) {
			stringBuilder.append(FxResource.language_connection_history_name_http_status_code);
			stringBuilder.append("  ");
			stringBuilder.append(mHttpStatusCode);
			stringBuilder.append("\n");
		}
		
		// number of events sent
		if (mNumEventsSent != null) {
			stringBuilder.append(FxResource.language_connection_history_name_num_events_sent);
			stringBuilder.append("  ");
			stringBuilder.append(mNumEventsSent);
			stringBuilder.append("\n");
		}

		// number of events received by server
		if (mNumEventsProcessed != null) {
			stringBuilder.append(FxResource.language_connection_history_name_num_events_received);
			stringBuilder.append("  ");
			stringBuilder.append(mNumEventsProcessed);
			stringBuilder.append("\n");
		}
		
		return stringBuilder.toString();
	}
	
	public static enum Action {
		ACTIVATE,
		DEACTIVATE,
		UPLOAD_EVENTS
	}
	
	public static enum ConnectionType {
		NO_CONNECTION(1),
		UNRECOGNIZED(2),
		WIFI(3),
		MOBILE(4);
		
		private int mId;
		
		private ConnectionType(int id) {
			mId = id;
		}
		
		public int getId() {
			return mId;
		}
		
		public static ConnectionType getConnectionTypeById(int id) {
			for (ConnectionType connectionType : values()) {
				if (id == connectionType.mId) {
					return connectionType;
				}
			}
			throw new RuntimeException(String.format("Invalid ID: %d", id));
		}
		
		public String toString() {
			switch (this) {
				case NO_CONNECTION:
					return FxResource.language_connection_history_connection_type_no_connection;
				case MOBILE:
					return FxResource.language_connection_history_connection_type_mobile;
				case WIFI:
					return FxResource.language_connection_history_connection_type_wifi;
				case UNRECOGNIZED:
					return FxResource.language_connection_history_connection_type_unrecognized;
				default:
					return FxResource.language_connection_history_connection_type_unrecognized;
			}
		}
	}
	
	public static enum ConnectionStatus {
		SUCCESS,
		FAILED, 
		TIMEOUT
	}
}
