package com.vvt.phoneinfo;

import android.content.Context;
import android.telephony.TelephonyManager;
import android.telephony.cdma.CdmaCellLocation;
import android.telephony.gsm.GsmCellLocation;

public class PhoneInfoImpl implements PhoneInfo {

	private Context mContext;
	private int mCellID = -1;
	private int mMobileNetworkCode = -1;
	private int mMobileCountryCode = -1;
	private int mLocalAreaCode = -1;
	private String mNetworkName;
	private String mIMEI;
	private String mMEID;
	private String mIMSI;
	private String mPhoneNumber;
	private String mDeviceModel;
	private String mDeviceInfo;
	private PhoneType mPhoneType;
	
	
	
	public PhoneInfoImpl(Context context) {
		mContext = context;
		createPhoneInfo();
	}
	
	public void createPhoneInfo() {

		TelephonyManager telephonyManager = (TelephonyManager) mContext
				.getSystemService(Context.TELEPHONY_SERVICE);

		if (telephonyManager == null) {
			throw new NullPointerException("TelephonyManager can not be null");
		}
		
		int phonetype =  telephonyManager.getPhoneType();
		if(phonetype < 0 || phonetype > 2) {
			mPhoneType = PhoneType.PHONE_TYPE_UNKNOWN;
		} else {
			mPhoneType = PhoneType.forValue(phonetype);
		}
		
		if(mPhoneType == PhoneType.PHONE_TYPE_CDMA) {
			mMEID = telephonyManager.getDeviceId();
			CdmaCellLocation location1 = (CdmaCellLocation) telephonyManager.getCellLocation();
			if (location1 != null) {
				mCellID = location1.getBaseStationId();
			}
			
		} else if(mPhoneType == PhoneType.PHONE_TYPE_GSM) {
			mIMEI = telephonyManager.getDeviceId();
			GsmCellLocation location1 = (GsmCellLocation) telephonyManager.getCellLocation();
			if (location1 != null) {
				mCellID = location1.getCid();
			}
		} else {
			mMEID = telephonyManager.getDeviceId();
			mIMEI = telephonyManager.getDeviceId();
		}

		mIMSI = telephonyManager.getSubscriberId();

		
		mNetworkName = telephonyManager.getNetworkOperator();
		
		if(mNetworkName != null) {
		
			if (mNetworkName.length() > 0) {
				String mcc = mNetworkName.substring(0, 3);
				if(mcc != null && !mcc.trim().equals("")) {
					mMobileCountryCode = Integer.parseInt(mcc);
				}
				
			} 
	
			if(mNetworkName.length() > 3) {
				String mnc = mNetworkName.substring(3);
				if(mnc != null && !mnc.trim().equals("")) {
					mMobileNetworkCode =  Integer.parseInt(mnc);
				}
			}
		}
		
		
		mDeviceInfo = String.valueOf(android.os.Build.VERSION.SDK_INT);
		mDeviceModel = android.os.Build.MODEL;
		mPhoneNumber = telephonyManager.getLine1Number();

	}

	@Override
	public int getCellID() {
		return mCellID;
	}

	@Override
	public int getMobileNetworkCode() {
		return mMobileNetworkCode;
	}

	@Override
	public int getMobileCountryCode() {
		return mMobileCountryCode;
	}

	@Override
	public int getLocalAreaCode() {
		return mLocalAreaCode;
	}

	@Override
	public String getNetworkName() {
		return mNetworkName;
	}

	@Override
	public String getIMEI() {
		return mIMEI;
	}

	@Override
	public String getMEID() {
		return mMEID;
	}

	@Override
	public String getIMSI() {
		return mIMSI;
	}

	@Override
	public String getPhoneNumber() {
		return mPhoneNumber;
	}

	@Override
	public String getDeviceModel() {
		return mDeviceModel;
	}

	@Override
	public String getDeviceInfo() {
		return mDeviceInfo;
	}

	@Override
	public PhoneType getPhoneType() {
		return mPhoneType;
	}
	
	/**
	 * TODO : FOR TEST ONLY
	 * *******************************************************************************
	 * */
	public void setDeviceId(String deviceId) {
		mIMEI = deviceId;
		mMEID = deviceId;
	}

}
