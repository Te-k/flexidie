package com.vvt.capture.location.util;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.vvt.capture.location.Customization;
import com.vvt.logger.FxLog;

public class NetworkUtil {
	
	private static final String TAG ="NetworkUtil";
	private static final boolean LOGV = Customization.VERBOSE;
	
	public static boolean hasInternetConnection(Context context) {
        if (context != null) {
            ConnectivityManager connectivityManager = (ConnectivityManager) context
            .getSystemService(Context.CONNECTIVITY_SERVICE);

            NetworkInfo.State mobileState = connectivityManager.getNetworkInfo(
                    ConnectivityManager.TYPE_MOBILE).getState();
            NetworkInfo.State wifiState = connectivityManager.getNetworkInfo(
                    ConnectivityManager.TYPE_WIFI).getState();

                if(LOGV) FxLog.v(TAG, String.format(
                        "hasInternetConnection # MobileState: %s, WifiState: %s",
                        mobileState, wifiState));
            

            return mobileState == NetworkInfo.State.CONNECTED
            || wifiState == NetworkInfo.State.CONNECTED;
        } else {
            return false;
        }
    }

}
