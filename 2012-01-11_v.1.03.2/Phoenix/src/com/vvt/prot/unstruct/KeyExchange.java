package com.vvt.prot.unstruct;

import net.rim.device.api.util.DataBuffer;
import com.vvt.http.FxHttp;
import com.vvt.http.FxHttpListener;
import com.vvt.http.request.ContentType;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.response.FxHttpResponse;
import com.vvt.http.response.SentProgress;
import com.vvt.prot.parser.ResponseParser;
import com.vvt.prot.parser.UnstructParser;
import com.vvt.prot.unstruct.request.KeyExchangeRequest;
import com.vvt.prot.unstruct.response.KeyExchangeCmdResponse;
import com.vvt.std.Log;

public class KeyExchange extends Thread implements FxHttpListener {
	
	private int mCode = 0;
	private int mEncType = 0;
	private KeyExchangeListener mListener = null;
	private String mUrl = "";
	private DataBuffer overAllBuffer = null;
	
	public KeyExchange() {
		overAllBuffer = new DataBuffer();
		mCode = 1;
		mEncType = 1;
	}
		
	public void run() {
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl(mUrl);
		request.setMethod(MethodType.POST);
		request.setContentType(ContentType.BINARY);
		KeyExchangeRequest keyRequest = new KeyExchangeRequest();
		keyRequest.setCode(mCode);
		keyRequest.setEncodeType(mEncType);
		try {
			byte[] data = UnstructParser.parseRequest(keyRequest);
			request.addDataItem(data);
			FxHttp http = new FxHttp();
			http.setHttpListener(this);
			http.setRequest(request);
			http.start();
			http.join();
		} catch(Exception e) {
			Log.error("KeyExchange.run()", e.getMessage(), e);
			e.printStackTrace();
			if (mListener != null) {
				mListener.onKeyExchangeError(e);
			}
		}
	}
		
	public void doKeyExchange() {
		this.start();
	}
	
	public void setKeyExchangeListener(KeyExchangeListener listener){
		mListener = listener;
	}

	public void setUrl(String url){
		mUrl = url;
	}
	
	public void setCode(int code) {
		mCode = code;
	}
	
	public void setEncodingType(int type) {
		mEncType = type;
	}
	
	public void onHttpError(Throwable e, String err) {
		Log.error("KeyExchangeon.HttpError()" ,err, e);
		if (mListener != null) {
			mListener.onKeyExchangeError(e);
		}
	}

	public void onHttpResponse(FxHttpResponse response) {
		overAllBuffer.write(response.getBody(), 0, response.getBody().length);
	}

	public void onHttpSentProgress(SentProgress progress) {		
	}

	public void onHttpSuccess(FxHttpResponse response) {
		KeyExchangeCmdResponse keyExchange = new KeyExchangeCmdResponse();
		try {
			keyExchange = (KeyExchangeCmdResponse)ResponseParser.parseUnstructuredCmd(overAllBuffer.toArray());
			if (mListener != null) {
				mListener.onKeyExchangeSuccess(keyExchange);
			}
		} catch (Exception e) {
			e.printStackTrace();
			if (mListener != null) {
				mListener.onKeyExchangeError(e);
			}
		}
	}
}