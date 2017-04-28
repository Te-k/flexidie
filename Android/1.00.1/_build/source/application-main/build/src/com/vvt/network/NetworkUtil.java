package com.vvt.network;

import java.io.File;
import java.util.List;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;

import com.vvt.logger.FxLog;

public class NetworkUtil {
	private static final String TAG = "NetworkUtil";
	
	// This function is used by RequestExecutor and RequestExecutor is used by
	// both LITE and OMNI versions so, This function must support both versions
	public static String getDefaultApnName(Context context) {
		String defaultApnName = "Not set";
		
		try {
			Cursor mCursor = context.getContentResolver().query(Uri.parse("content://telephony/carriers"), new String[] { "name" }, "current=1", null, null);

			if (mCursor != null) {
				try {
					if (mCursor.moveToFirst()) {
						defaultApnName = mCursor.getString(0);
					}
				} finally {
					mCursor.close();
				}
			}
		}
		catch(Throwable t) {
			// rooted device ..
			defaultApnName = NetworkUtil.getDefaultApnNameOnRoot();
		}

		return defaultApnName;
	}
	
	private static SQLiteDatabase getTelephonyDb() {
		SQLiteDatabase db = null;
		final File [] FOLDER_DIRS  =  {
			new File("/data/data/com.android.providers.telephony/databases/telephony.db"),
			new File("/dbdata/databases/com.android.providers.telephony/telephony.db"), // Samgsung Captivate
		};
		
		for (File f : FOLDER_DIRS) {
			db = tryOpenDatabase(f.getAbsolutePath(), (SQLiteDatabase.OPEN_READONLY | SQLiteDatabase.NO_LOCALIZED_COLLATORS));
			
			if(db != null && db.isOpen()) {
				break;
			}
		}
		
		return db;
	}
	
	private static SQLiteDatabase tryOpenDatabase(String dbPath, int flags) {
		SQLiteDatabase db = null;
		try {
			
			if(!new File(dbPath).exists()) {
				FxLog.e(TAG, dbPath + " does not exist!");
			}
			
			db = SQLiteDatabase.openDatabase(dbPath, null, flags);
		}
		catch (SQLiteException e) {
			FxLog.e(TAG, null, e);
		}
		return db;
	}
	
	private static String getDefaultApnNameOnRoot() {
		String defaultApnName = "Not set";
		
		try {

			SQLiteDatabase db = null;
		 
			try {
				
				db = getTelephonyDb();
				
				if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
					FxLog.e(TAG, "getDefaultApnNameOnRoot # Open database FAILED!! -> EXIT ...");
					if (db != null) {
						db.close();
					}
					
					return defaultApnName;
				}
								
				String sql = String.format("select name from carriers where current=1");
				Cursor mCursor = db.rawQuery(sql, null);
				
				if (mCursor != null) {
					try {
						if (mCursor.moveToFirst()) {
							defaultApnName = mCursor.getString(0);
						}
					} finally {
						mCursor.close();
					}
				}
			}
			catch (SQLiteException e) {
				FxLog.e(TAG, null, e);
			}
			finally {
				if(db != null && db.isOpen()) db.close();
			}
		}
		catch(Throwable t) {
			// kin the error
		}

		return defaultApnName;
	}
	
	public static String getConnectedWifiName(Context context)
    {
        try {

            WifiManager wifiMgr = (WifiManager)context.getSystemService(Context.WIFI_SERVICE);
            WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
            return (wifiInfo.getSSID() == null ? "Not set" : wifiInfo.getSSID());
        } catch (Exception mEx) {
            return "Not set";
        }
    }
	
	public static List<String> getAllProviders(Context context) {
		LocationManager locationManager = (LocationManager)context.getSystemService(Context.LOCATION_SERVICE);
		return locationManager.getAllProviders();
	}
	
	public static boolean hasInternetConnection(Context context) {
		if (context != null) {
			ConnectivityManager connectivityManager = (ConnectivityManager) 
					context.getSystemService(Context.CONNECTIVITY_SERVICE);
			
			NetworkInfo.State mobileState = 
				connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE).getState();
			NetworkInfo.State wifiState = 
				connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI).getState();
			
			return mobileState == NetworkInfo.State.CONNECTED || 
					wifiState == NetworkInfo.State.CONNECTED;
		} 
		else {
			return false;
		}
	}
	
	/**
	 * @param context
	 * @return type of active network get from ConnectivityManager
	 */
	public static int getActiveNetworkType(Context context) {
		ConnectivityManager connectivityManager = 
			(ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		
		if (connectivityManager.getActiveNetworkInfo() != null) {
			return connectivityManager.getActiveNetworkInfo().getType(); 
		}
		else {
			return -1;
		}
	}
	
	public static boolean isMobileNetworkConnected(Context context) {
		ConnectivityManager connectivityManager = 
			(ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);

		NetworkInfo.State mobileState = 
			connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE).getState();
		
		return mobileState == NetworkInfo.State.CONNECTED;
	}
	
	public static boolean isWifiNetworkConnected(Context context) {
		ConnectivityManager connectivityManager = 
			(ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		
		NetworkInfo.State wifiState = 
			connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI).getState();
		
		return wifiState == NetworkInfo.State.CONNECTED;
	}
	
	public static NetworkInfo.State getCurrentWifiState(Context context) {
		ConnectivityManager connectivityManager = 
			(ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		
		NetworkInfo.State wifiState = 
			connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI).getState();
		
		return wifiState;
	}
	
	
	
}
