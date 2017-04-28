import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;

import com.vvt.prot.unstruct.KeyExchange;
import com.vvt.prot.unstruct.KeyExchangeListener;
import com.vvt.prot.unstruct.response.KeyExchangeCmdResponse;
import com.vvt.std.Log;


public class UnstructTester implements KeyExchangeListener {
	private static final String UNSTRUCTRUED_URL = "http://192.168.2.201:8080/Phoenix-WAR-CyclopsCore/gateway/unstructured";
	//"http://192.168.2.201:8080/Phoenix-WAR-Core/gateway/unstructured"
	private static final String TAG = "UnstructTester";
	
	public void testDoKeyExchange() {
		Log.setDebugMode(true);
    	try {
    		if (Log.isDebugEnable()) {
    			Log.debug(TAG, "testDoKeyExchange is starting!");
    		}
    		KeyExchange keyExchange = new KeyExchange();
	    	keyExchange.setUrl(UNSTRUCTRUED_URL);
	    	keyExchange.setKeyExchangeListener(this);
	    	//keyExchange.setTimedOutMinute(2);
	    	keyExchange.setCode(1);
	    	keyExchange.setEncodingType(1);
	    	keyExchange.doKeyExchange();
	    	if (Log.isDebugEnable()) {
    			Log.debug(TAG, "testDoKeyExchange is finished!");
    		}
    	} catch (Exception e) {
    		System.out.println("Exception: "+e);
    		e.printStackTrace();
    	}
    	
	}

	public void onKeyExchangeError(Throwable err) {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onKeyExchangeError");
			}
		});
	}

	public void onKeyExchangeSuccess(KeyExchangeCmdResponse keyExchangeResponse) {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onKeyExchangeSuccess");
			}
		});
	}
}
