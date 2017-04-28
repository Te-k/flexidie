package com.fx.maind.delivery;


import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;

public final class ResponseContainerDeviceEvents extends ResponseContainer {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
	
	private static final String TAG = "ResponseContainerDeviceEvents";
	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
	private int mEventsProcessed;

//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------

    public ResponseContainerDeviceEvents(String code, 
    									 String message, 
    									 boolean errorFlag, 
    									 int deviceEventsProcessed) { 
    	super(code, message, errorFlag);
    	if (LOCAL_LOGV) FxLog.v(TAG, "ResponseContainerDeviceEvents # ENTER ...");
    	mEventsProcessed = deviceEventsProcessed;
    }
    
    public int getEventsProcessed() { 
    	return mEventsProcessed; 
    }
    
    public void setDeviceEventsProcessed(int deviceEventsProcessed) {
    	mEventsProcessed = deviceEventsProcessed; 
    }

	public String toString() {
		return String.format("ResponseContainerDeviceEvents = " +
				"{ SUPER = %1$s , DeviceEventsProcessed = %2$d }", 
				super.toString(), 
				mEventsProcessed);
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
