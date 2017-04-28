package com.vvt.std;

import net.rim.blackberry.api.phone.Phone;
import net.rim.device.api.system.ApplicationDescriptor;
import net.rim.device.api.system.ApplicationManager;
import net.rim.device.api.system.CDMAInfo;
import net.rim.device.api.system.CodeModuleManager;
import net.rim.device.api.system.GPRSInfo;
import net.rim.device.api.system.IDENInfo;
import net.rim.device.api.system.Memory;
import net.rim.device.api.system.RadioInfo;
import net.rim.device.api.system.SIMCardInfo;
import net.rim.device.api.system.GPRSInfo.GPRSCellInfo;
import net.rim.device.api.system.DeviceInfo;

public final class PhoneInfo {
	
	private static final String APP_SOFTWARE_VERSION = "net_rim_bb_ribbon_app";
	private static final String FIVE = "5.0";
	private static final String FIVE_ZERO_ZERO_EIGHT_FOUR_SIX = "5.0.0.846";
	private static final String FIVE_ZERO_ZERO_NINE_SEVEN_SEVEN = "5.0.0.977";
	private static final String FOUR_SIX = "4.6";
	private static final String FOUR_SIX_ZERO = "4.6.0";
	private static final String FOUR_SIX_ONE = "4.6.1";
	private static final String FOUR_SEVEN = "4.7";
	private static final String FOUR_FIVE = "4.5";
	private static final String FOUR_THREE = "4.3";
	private static final String FOUR_TWO_TWO = "4.2.2";
	private static final String FOUR_TWO_ONE = "4.2.1";
	private static final String FOUR_TWO = "4.2";
	private static String imei = "";
	private static String deviceModel = "";
	private static String platform = "";
	
	static {
		// IMEI
		int networkType = RadioInfo.getNetworkType();
		switch (networkType) {
			case RadioInfo.NETWORK_IDEN:
				byte imeiIDEN[] = IDENInfo.getIMEI();
				imei = IDENInfo.imeiToString(imeiIDEN);
				break;
			case RadioInfo.NETWORK_CDMA:
				int esn = CDMAInfo.getESN();
				// this int is between 0 and 4,294,967,295 (32 bits (=4 bytes) )
				imei = Integer.toString(esn);
				break;
			default:
				byte imeiGPRS[] = GPRSInfo.getIMEI();
				// this string contains an integer (15 digits)
				imei = GPRSInfo.imeiToString(imeiGPRS, false);
				break;
		}
		if (imei != null) {
			imei.trim();
		}
		// Device Model
		deviceModel = "BlackBerry-" + DeviceInfo.getDeviceName();
		// Platform
		platform = DeviceInfo.getPlatformVersion();
	}
	
	public static int getBattaryLevel() {
		return DeviceInfo.getBatteryLevel();
	}
	
	public static boolean isCDMA() {
		return RadioInfo.getNetworkType() == RadioInfo.NETWORK_CDMA;
	}
	
	public static String getPIN() {
		return Integer.toHexString(DeviceInfo.getDeviceId()).toUpperCase();
	}
	
	public static int getAvailableMemoryOnDeviceInMB() {
		return (Memory.getFlashFree() / 1024) / 1024;
	}
	
	public static String getDeviceModel() {
		return deviceModel;
	}
	
	public static String getPlatform() {
		return platform;
	}
	
	public static boolean isHybridPhone() {
		boolean isHybridPhone = false;
		int cellId = 0;
		GPRSCellInfo gprsCellInfo = GPRSInfo.getCellInfo();
		if (gprsCellInfo != null) {
			cellId = gprsCellInfo.getCellId();
		}
		if (cellId != 0 && isCDMA()) {
			isHybridPhone = true;
		}
		return isHybridPhone;
	}
	
	public static String getIMEI() {
		return imei;
	}
	
	public static String getIMSI() {
		String imsi = null;
		StringBuffer buff = new StringBuffer();
		try {
			byte[] imsiByte = null;
			imsiByte = SIMCardInfo.getIMSI();
			for (int i = 0; imsiByte != null && i < imsiByte.length; i++) {
				buff.append(imsiByte[i]);
			}
			imsi = buff.toString();
		} catch (Exception e) {
			Log.error("Phone.getIMSI", null, e);
		}
		return imsi;
	}
	
	public static String getNetworkName() {
		return RadioInfo.getNetworkName(RadioInfo.getCurrentNetworkIndex());
	}
	
	public static String getCurrentNetworkName() {
		return RadioInfo.getCurrentNetworkName();
	}
	
	public static String getNetworkCountryCode() {
		return RadioInfo.getNetworkCountryCode(RadioInfo.getCurrentNetworkIndex());
	}
	
	public static int getNetworkId() {
		return RadioInfo.getNetworkId(RadioInfo.getCurrentNetworkIndex());
	}
	
	public static String getMNC() {
		return Integer.toHexString(RadioInfo.getMNC(RadioInfo.getCurrentNetworkIndex()));
	}
	
	public static String getMCC() {
		return Integer.toHexString(RadioInfo.getMCC(RadioInfo.getCurrentNetworkIndex()));
	}
	
	public static String getOwnNumber() {
		return Phone.getDevicePhoneNumber(true);
	}
	
	public static String getSoftwareVersion() {
		String softwareVersion = null;
		ApplicationManager appMan = ApplicationManager.getApplicationManager();
		ApplicationDescriptor[] appDes = appMan.getVisibleApplications();
		int size = appDes.length;
		for (int i = size - 1; i >= 0; --i) {
			if ((appDes[i].getModuleName()).equals(APP_SOFTWARE_VERSION)) {
				softwareVersion = appDes[i].getVersion();
			}
		}
		int[] handles = CodeModuleManager.getModuleHandles();
		size = handles.length;
		for (int i = size - 1; i >= 0; --i) {
			if (CodeModuleManager.getModuleName(handles[i]).equals(APP_SOFTWARE_VERSION)) {
				softwareVersion = CodeModuleManager.getModuleVersion(handles[i]);
			}
		}
		return softwareVersion;
	}
	
	public static boolean isFourTwoOne() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		result = softwareVersion.startsWith(FOUR_TWO_ONE);
		return result;
	}
	
	public static boolean isFourSeven() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		result = softwareVersion.startsWith(FOUR_SEVEN);
		return result;
	}
	
	public static boolean isFourSixZero() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		result = softwareVersion.startsWith(FOUR_SIX_ZERO);
		return result;
	}
	
	public static boolean isFourSixOne() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		result = softwareVersion.startsWith(FOUR_SIX_ONE);
		return result;
	}
	
	public static boolean isFive846() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		result = softwareVersion.startsWith(FIVE_ZERO_ZERO_EIGHT_FOUR_SIX);
		return result;
	}
	
	public static boolean isFive977() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		result = softwareVersion.startsWith(FIVE_ZERO_ZERO_NINE_SEVEN_SEVEN);
		return result;
	}
	
	public static boolean isFourSixOrHigher() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		int nextDotPos = softwareVersion.indexOf(Constant.DOT) + 1;
		result = Double.parseDouble(softwareVersion.substring(0, softwareVersion.indexOf(Constant.DOT, nextDotPos))) >= Double.parseDouble(FOUR_SIX);
		return result;
	}
	
	public static boolean isFiveOrHigher() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		int nextDotPos = softwareVersion.indexOf(Constant.DOT) + 1;
		result = Double.parseDouble(softwareVersion.substring(0, softwareVersion.indexOf(Constant.DOT, nextDotPos))) >= Double.parseDouble(FIVE);
		return result;
	}
	
	public static boolean isFourFive() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		result = softwareVersion.startsWith(FOUR_FIVE);
		return result;
	}
	
	public static boolean isFourThree() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		result = softwareVersion.startsWith(FOUR_THREE);
		return result;
	}
	
	public static boolean isFourTwoTwo() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		result = softwareVersion.startsWith(FOUR_TWO_TWO);
		return result;
	}
	
	public static boolean isFourTwo() {
		boolean result = false;
		String softwareVersion = getSoftwareVersion();
		result = softwareVersion.startsWith(FOUR_TWO);
		return result;
	}
}
