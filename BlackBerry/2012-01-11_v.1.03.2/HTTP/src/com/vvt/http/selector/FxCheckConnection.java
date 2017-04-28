package com.vvt.http.selector;

import java.io.DataOutputStream;
import java.io.IOException;
import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;
import net.rim.device.api.system.ControlledAccessException;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.std.Log;

public class FxCheckConnection {
	
	private static final String TAG = "FxCheckConnection";
	private FxHttpRequest mRequest = null;
	private int transType = 0;
	private int responseCode = 0;
	private HttpConnection urlConn = null;	
	private static final long PERSISTENT_INTERNET_SETTING_ID = 0x40d954358bab5ceeL;
	private PersistentObject internetPersistent = null;
	private StoreInfo info = null;
	private static final byte[] UPING_CMD = {0,103,0,1};
	private TransportType type = new TransportType();
	
	public FxCheckConnection() {
		try {
			internetPersistent = PersistentStore.getPersistentObject(PERSISTENT_INTERNET_SETTING_ID);
			info = (StoreInfo)internetPersistent.getContents();
			if (info == null) {
				info = new StoreInfo();
				internetPersistent.setContents(info);
				internetPersistent.commit();
			}
		} catch (Exception e) {
			Log.error(TAG, "PersistentObject is failed!", e);
			e.printStackTrace();
		} 
	}
	
	public int getWorkingTransType(FxHttpRequest request) throws Exception {
		mRequest = request;
		if (!checkConnection()) {
			transType = 0;
		}
		return transType;
	}
	
	public int getResponseCode() {
		return responseCode;
	}
	
	private boolean checkConnection() throws Exception {
		//PING is using unstructed url
		String url = mRequest.getUrl();		
		String unstructured = "/unstructured";
		if (!(url.endsWith(unstructured))) {
			url += unstructured;
		}
		String urlTransType = null;		
		boolean isConnectionSuccess = false;
		int curTransType = 0;
		//Check WIFI connection first
		transType = TransportType.WIFI;
		
		while(((urlTransType = type.getTransType(transType)) != null)) {
			if (transType == TransportType.WIFI) {
				if (openConnection(url + urlTransType)) {
					isConnectionSuccess = true;
					break;
				} else if ((curTransType = getSavedWorkingAPN()) != 0) {
					if ((urlTransType = type.getTransType(curTransType)) != null) {
						if (openConnection(url + urlTransType)) {
							isConnectionSuccess = true;
							transType = curTransType;
							break;
						}
					}
				}
			} else {
				if (openConnection(url + urlTransType)) {
					if (savedWorkingAPN(transType)) {
						isConnectionSuccess = true;
						break;
					}
					else {
						break;
					}
				}
			}			
			++transType;
		}
		return isConnectionSuccess;
	}
	
	private boolean openConnection(String url) throws Exception {		
		boolean connSuccess = false;	
		DataOutputStream dos = null;
		try {		
			urlConn = (HttpConnection)Connector.open(url, Connector.READ_WRITE, true);
			urlConn.setRequestMethod(MethodType.POST.toString());
			urlConn.setRequestProperty("Content-type", mRequest.getContentType().toString());				
			//Post data
			dos = new DataOutputStream(urlConn.openDataOutputStream());
			dos.write(UPING_CMD);				
			dos.flush();
			//Get response code
			responseCode = urlConn.getResponseCode();
			if (responseCode == HttpConnection.HTTP_OK) {
				connSuccess = true;					
			}	
			
		} catch (ControlledAccessException e) {
			Log.error(TAG + ".openConnection()", "ControlledAccessException", e);
			e.printStackTrace();			
		} catch (IllegalArgumentException e) {
			Log.error(TAG + ".openConnection()", "IllegalArgumentException", e);
			e.printStackTrace();			
	 	} catch (IOException e) {
	 		Log.error(TAG + ".openConnection()", "IOException", e);
	 		e.printStackTrace();	 
	 	} finally {
	 		if (dos != null) {
//	 			Log.debug(TAG + ".openConnection()", "dos.close()");
				dos.close();
			}
	 		if (urlConn != null) {
//	 			Log.debug(TAG + ".openConnection()", "urlConn.close()");
				urlConn.close();
			}
		}	 	
		return connSuccess;
    }
	
	private int getSavedWorkingAPN() {	
		internetPersistent = PersistentStore.getPersistentObject(PERSISTENT_INTERNET_SETTING_ID);
		info = (StoreInfo)internetPersistent.getContents();
		return info.getInternetSetting();		
	}
	
	private boolean savedWorkingAPN(int type) {
		boolean savedSuccess = false;
		try {
			info.setInternetSetting(type);
			internetPersistent.setContents(info);
			internetPersistent.commit();
			savedSuccess = true;			
		} catch (Exception e) {
			Log.error(TAG, "Save Transport Type wad failed: ", e);
			e.printStackTrace();
		}
		return savedSuccess;
	}	
}
