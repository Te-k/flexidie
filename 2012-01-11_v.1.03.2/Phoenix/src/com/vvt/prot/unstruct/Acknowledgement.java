package com.vvt.prot.unstruct;

import com.vvt.http.FxHttp;
import com.vvt.http.FxHttpListener;
import com.vvt.http.request.ContentType;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.response.FxHttpResponse;
import com.vvt.http.response.SentProgress;
import com.vvt.prot.parser.UnstructParser;
import com.vvt.prot.unstruct.request.AckRequest;
import com.vvt.prot.unstruct.response.AckCmdResponse;
import com.vvt.std.Log;

public class Acknowledgement extends Thread implements FxHttpListener {

	private byte[] deviceId = null;
	private int code = 0;
	private long sessionId = 0;
	private AcknowledgeListener listener = null;	
	private String url = "";
	
	public Acknowledgement() {
		code = 1;
	}
	
	public void setUrl(String url){
		this.url = url;
	}
	
	public void setSessionId(long sessionId) {
		this.sessionId = sessionId;
	}
	
	public void setDeviceId(byte[] deviceId) {
		this.deviceId = deviceId;
	}
	
	public void setAcknowledgeListener(AcknowledgeListener listener){
		this.listener = listener;
	}
	
	public void doAcknowledge() {
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl(url);
		request.setMethod(MethodType.POST);
		request.setContentType(ContentType.BINARY);
		AckRequest actRequest = new AckRequest();
		actRequest.setCode(code);
		actRequest.setDeviceId(deviceId);
		actRequest.setSessionId(sessionId);
		try {
			byte[] data = UnstructParser.parseRequest(actRequest);
			request.addDataItem(data);
			FxHttp http = new FxHttp();
			http.setHttpListener(this);
			http.setRequest(request);			
			http.start();
			http.join();
		} catch(Exception e) {
			e.printStackTrace();
			Log.error("Acknowledgement.doAcknowledge()", e.getMessage(), e);
			if (listener != null) {
				listener.onAcknowledgeError(e);
			}
		}
	}
	
	public void doAcknowledgeSecure() {
		this.start();
	}
	
	// FxHttpListener
	public void onHttpError(Throwable err, String msg) {
		if (listener != null) {
			listener.onAcknowledgeError(err);
		}
	}

	public void onHttpResponse(FxHttpResponse response) {		
	}

	public void onHttpSentProgress(SentProgress progress) {		
	}

	public void onHttpSuccess(FxHttpResponse result) {		
		if (listener != null) {
			AckCmdResponse ackResponse = new AckCmdResponse();
			listener.onAcknowledgeSuccess(ackResponse);
		}
	} 
}