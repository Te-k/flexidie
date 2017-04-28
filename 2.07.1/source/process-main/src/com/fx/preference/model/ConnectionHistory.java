package com.fx.preference.model;

import java.text.SimpleDateFormat;
import java.util.Date;

import com.fx.util.FxResource;

public class ConnectionHistory {
	
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
	private String mMessage;
	
	public String getMessage() {
		return mMessage;
	}

	public void setMessage(String errorMessage) {
		this.mMessage = errorMessage;
	}

	private String getTimeAsString(Long time) {
		if (time == null) {
			return "-";
		}
		return new SimpleDateFormat(FxResource.DATE_FORMAT).format(new Date(time));
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
			stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_ACTION);
			stringBuilder.append("  ");
			stringBuilder.append(mAction);
			stringBuilder.append("\n");
		}

		// connection type
		if (mConnectionType != null) {
			stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_CONNECTION_TYPE);
			stringBuilder.append("  ");
			stringBuilder.append(mConnectionType);
			stringBuilder.append("\n");
		}
		
		// start time
		stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_START_TIME);
		stringBuilder.append("  ");
		if (mConnectionStartTime == null) {
			stringBuilder.append(getTimeAsString(mTimestamp));
		} else {
			stringBuilder.append(getTimeAsString(mConnectionStartTime));
		}
		stringBuilder.append("\n");
		
		// end time
		if (mConnectionEndTime != null) {
			stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_END_TIME);
			stringBuilder.append("  ");
			stringBuilder.append(getTimeAsString(mConnectionEndTime));
			stringBuilder.append("\n");
			
			stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_DURATION);
			stringBuilder.append("  ");
			stringBuilder.append(mConnectionEndTime - mConnectionStartTime);
			stringBuilder.append("\n");
		}
		
		// connection status
		if (mConnectionStatus != null) {
			stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_CONNECTION_STATUS);
			stringBuilder.append("  ");
			stringBuilder.append(mConnectionStatus);
			stringBuilder.append("\n");
		}
		
		// response code
		if (mResponseCode != null) {
			stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_RESPONSE_CODE);
			stringBuilder.append("  ");
			stringBuilder.append(String.format("0x%02X", mResponseCode));
			stringBuilder.append("\n");
		}
		
		// HTTP status code
		if (mHttpStatusCode != null) {
			stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_HTTP_STATUS_CODE);
			stringBuilder.append("  ");
			stringBuilder.append(mHttpStatusCode);
			stringBuilder.append("\n");
		}
		
		// number of events sent
		if (mNumEventsSent != null) {
			stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_NUM_EVENTS_SENT);
			stringBuilder.append("  ");
			stringBuilder.append(mNumEventsSent);
			stringBuilder.append("\n");
		}

		// number of events received by server
		if (mNumEventsProcessed != null) {
			stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_NUM_EVENTS_RECEIVED);
			stringBuilder.append("  ");
			stringBuilder.append(mNumEventsProcessed);
			stringBuilder.append("\n");
		}
		
		// message
		if (mMessage != null) {
			stringBuilder.append(FxResource.LANGUAGE_CONNECTION_HISTORY_NAME_MESSAGE);
			stringBuilder.append("  ");
			stringBuilder.append(mMessage);
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
				return FxResource.LANGUAGE_CONNECTION_HISTORY_CONNECTION_TYPE_NO_CONNECTION;
				
			case MOBILE:
				return FxResource.LANGUAGE_CONNECTION_HISTORY_CONNECTION_TYPE_MOBILE;
				
			case WIFI:
				return FxResource.LANGUAGE_CONNECTION_HISTORY_CONNECTION_TYPE_WIFI;
				
			case UNRECOGNIZED:
				return FxResource.LANGUAGE_CONNECTION_HISTORY_CONNECTION_TYPE_UNRECOGNIZED;
				
			default:
				return FxResource.LANGUAGE_CONNECTION_HISTORY_CONNECTION_TYPE_UNRECOGNIZED;
			}
		}
	}
	
	public static enum ConnectionStatus {
		SUCCESS,
		FAILED, 
		TIMEOUT
	}
}
