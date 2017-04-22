// act as HttpRequest caller

package com.vvt.phoenix.http.test;

import java.util.HashMap;
import java.util.Iterator;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.http.request.FxHttpRequest;

public class HttpRequestTester {
	private static final String TAG = "HttpRequestTester";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	public void testHttpRequest(){
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl("www.dew.com");
		request.setMethod("POST");
		
		//1 prepare intput
		byte[] byteInput = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
		String fileInputPath = "/sdcard/FileItem.dat";
		String fileInputPath2 = "/sdcard/FileItem2.dat";
		
		//2 add data to request
		request.addDataItem(byteInput);
		request.addFileDataItem(fileInputPath);
		request.addFileDataItem(fileInputPath2, 5);
		request.setRequestHeader("dew", "OK");
		request.setRequestHeader("Milky", "BBoy");
		
		//3 get request header
		displayHeader(request);
		
		//4 get size
		Log.v(TAG, "Number of elements in request: "+request.dataItemCount());
		
	}
	
	private void displayHeader(FxHttpRequest request){
		HashMap<String, String> header = request.getRequestHeader();
		Iterator<String> keyIter = header.keySet().iterator();
		while(keyIter.hasNext()){
			String key = keyIter.next();
			Log.v(TAG, "Key: "+key+", Value: "+header.get(key));
		}
	}
}
