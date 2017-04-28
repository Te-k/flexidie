package com.vvt.phoenix.prot.test.unstruct;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import android.util.Log;

import com.vvt.phoenix.prot.unstruct.KeyExchangeResponse;
import com.vvt.phoenix.prot.unstruct.UnstructuredManager;

public class UnstructuredManagerTest {
	//Debugging
	private static final String TAG = "UnstructuredManagerTest";
	
	public void testKeyExchange(){
		/*KeyExchange exchange = new KeyExchange();
		exchange.setKeyExchangeListener(this);
		exchange.setUrl("http://192.168.2.201:8080/Phoenix-WAR-Core/gateway/unstructured");
		exchange.doKeyExchange();*/
		
		UnstructuredManager manager = new UnstructuredManager("http://192.168.2.201:8880/Phoenix-WAR-Core/gateway/unstructured");
		//manager.setUrl("http://192.168.2.201:8080/Phoenix-WAR-CyclopsCore/gateway/unstructured");
		KeyExchangeResponse response = manager.doKeyExchange(1, 1);
		
		Log.v(TAG, "KeyExchangerResponse");
		if(response.isResponseOk()){
			Log.v(TAG, "Status Code: "+response.getStatusCode());
			Log.v(TAG, "SessionID: "+response.getSessionId());
			Log.v(TAG, "Public Key: "+response.getServerPK());
			Log.v(TAG, "Public Key Length: "+response.getServerPK().length);
			writeKeyToFile(response);
		}else{
			Log.e(TAG, "KeyExchange failed");
			Log.e(TAG, "Error Msg: "+response.getErrorMessage());
		}
	}
	
	private void writeKeyToFile(KeyExchangeResponse response){
		File f = new File("/sdcard/prot/key.pk");
		
		try{
			FileOutputStream fOut = new FileOutputStream(f);
			fOut.write(response.getServerPK());
			fOut.close();
		}catch(IOException e){
			Log.e(TAG, e.getMessage());
		}
		
		
	}
	
}
