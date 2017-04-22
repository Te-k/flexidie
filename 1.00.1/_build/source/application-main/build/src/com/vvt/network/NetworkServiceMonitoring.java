package com.vvt.network;

import android.content.Context;
import android.os.Looper;
import android.telephony.CellLocation;
import android.telephony.PhoneStateListener;
import android.telephony.ServiceState;
import android.telephony.TelephonyManager;
import android.telephony.cdma.CdmaCellLocation;
import android.telephony.gsm.GsmCellLocation;

import com.vvt.logger.FxLog;

public class NetworkServiceMonitoring extends Thread {
	
	private static final String TAG = "NetworkMonitoring";
	
	private TelephonyManager mTelephonyManager;
	private OnNetworkChangeListener mListener;
	private NetworkServiceInfo mCurrentNetwork;
	
	public NetworkServiceMonitoring(Context context, OnNetworkChangeListener listener) {
		mTelephonyManager = 
				(TelephonyManager) context.getSystemService(
						Context.TELEPHONY_SERVICE);
		mListener = listener;
		mCurrentNetwork = new NetworkServiceInfo();
	}
	
	@Override
	public void run() {
		Looper.prepare();
		
		PhoneStateListener listener = new NetworkChangeListener();
		
		mTelephonyManager.listen(listener, PhoneStateListener.LISTEN_SERVICE_STATE);
		
		Looper.loop();
	}
	
	private class NetworkChangeListener extends PhoneStateListener {
		@Override
		public void onServiceStateChanged(ServiceState serviceState) {
			super.onServiceStateChanged(serviceState);
			
			boolean toNotify = false;
					
			NetworkServiceInfo.State state = getNetworkState(serviceState);
			
			if (state == NetworkServiceInfo.State.ACTIVE) {
				NetworkServiceInfo.Type type = getNetworkType();
				
				// Logic for notification
				toNotify = mCurrentNetwork.getState() != NetworkServiceInfo.State.ACTIVE ||
						mCurrentNetwork.getType() != type;
				
				// Update current networkInfo
				mCurrentNetwork.setState(NetworkServiceInfo.State.ACTIVE);
				mCurrentNetwork.setType(type);
			}
			else {
				// Logic for notification
				toNotify = mCurrentNetwork.getState() != NetworkServiceInfo.State.INACTIVE;
				
				// Update current networkInfo
				mCurrentNetwork.setState(NetworkServiceInfo.State.INACTIVE);
				mCurrentNetwork.setType(NetworkServiceInfo.Type.UNKNOWN);
			}
			
			if (toNotify) {
				FxLog.d(TAG, String.format(
						"onServiceStateChanged # info: %s", mCurrentNetwork));
				
				if (mListener != null) {
					mListener.onNetworkChange(mCurrentNetwork);
				}
			}
		}
	}
	
	private NetworkServiceInfo.State getNetworkState(ServiceState serviceState) {
		int state = serviceState.getState();
		return state == ServiceState.STATE_IN_SERVICE ? 
				NetworkServiceInfo.State.ACTIVE : NetworkServiceInfo.State.INACTIVE;
	}
	
	private NetworkServiceInfo.Type getNetworkType() {
		CellLocation cellLocation = mTelephonyManager.getCellLocation();
		return cellLocation instanceof GsmCellLocation ? NetworkServiceInfo.Type.GSM : 
			cellLocation instanceof CdmaCellLocation ? NetworkServiceInfo.Type.CDMA : 
				NetworkServiceInfo.Type.UNKNOWN;
	}

	public interface OnNetworkChangeListener {
		public void onNetworkChange(NetworkServiceInfo info);
	}
}
