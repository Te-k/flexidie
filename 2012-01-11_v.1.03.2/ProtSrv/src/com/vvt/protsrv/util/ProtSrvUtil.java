package com.vvt.protsrv.util;

import com.vvt.global.Global;
import com.vvt.info.ServerUrl;
import com.vvt.std.Log;

public class ProtSrvUtil {

	private String TAG = "ProtSrvUtil";
	private ServerUrl serverUrl = Global.getServerUrl();
	
	public String getBaseServerUrl() {
		String http = "http://";
		String core = "/Core/gateway";
//		String gateway = "/gateway";
		String defaultPort = "80";
		String url = serverUrl.getServerActivationUrl();
		/*if (url.startsWith(http)) {
			url = url.substring(http.length());
		}
		int coreIndex = url.indexOf(core);
		if (coreIndex != -1) {
			url = url.substring(0, coreIndex);
		}
		int colonIndex = url.indexOf(":");
		if (colonIndex != -1) {
			String port = url.substring(colonIndex + 1);
			if (port.equals(defaultPort)) {
				// remove port 80
				url = url.substring(0, colonIndex);
			}
		}*/
		if (!url.startsWith(http)) {
			url = http+ url; 
		}
		int coreIndex = url.indexOf(core);
		if (coreIndex == -1) {
			url = url + core;
		} 
		int colonIndex = url.indexOf(":", http.length());
		if (colonIndex != -1) {
			String port = url.substring(colonIndex + 1);
			if (port.equals(defaultPort)) {
				// remove port 80
				url = url.substring(0, colonIndex);
			}
		}
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG + "getBaseServerUrl()", "url = " + url);
		}*/
		return url;
	}
}
