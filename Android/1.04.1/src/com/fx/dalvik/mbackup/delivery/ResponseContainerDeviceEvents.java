package com.fx.dalvik.mbackup.delivery;

import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;

public final class ResponseContainerDeviceEvents extends ResponseContainer {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
	
	private static final String TAG = "ResponseContainerDeviceEvents";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	private int mDeviceEventsProcessed;

//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------

    public ResponseContainerDeviceEvents(String code, 
    									 String message, 
    									 boolean errorFlag, 
    									 int deviceEventsProcessed) { 
    	super(code, message, errorFlag);
    	if (LOCAL_LOGV) FxLog.d(TAG, "ResponseContainerDeviceEvents # ENTER ...");
    	mDeviceEventsProcessed = deviceEventsProcessed;
    }
    
    public int getDeviceEventsProcessed() { 
    	return mDeviceEventsProcessed; 
    }
    
    public void setDeviceEventsProcessed(int deviceEventsProcessed) {
    	mDeviceEventsProcessed = deviceEventsProcessed; 
    }

	public String toString() {
		return String.format("ResponseContainerDeviceEvents = " +
				" SUPER = %1$s , DeviceEventsProcessed = %2$d }", 
				super.toString(), 
				mDeviceEventsProcessed);
	};

	public boolean canBeRetried() {
		
		boolean retryFlag = true;	

		switch (getCodeAsInt()) {
			case RESPONSE_NOT_RECOGNIZED:
				retryFlag = false;
				break;
		}						
		
		return retryFlag;
	}
}
