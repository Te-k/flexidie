package com.vvt.prot.unstruct;

import com.vvt.http.FxHttp;
import com.vvt.http.FxHttpListener;
import com.vvt.http.request.ContentType;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.response.FxHttpResponse;
import com.vvt.http.response.SentProgress;
import com.vvt.prot.parser.UnstructParser;
import com.vvt.prot.unstruct.request.AckSecRequest;
import com.vvt.prot.unstruct.response.AckSecCmdResponse;
import com.vvt.std.Log;

public class AcknowledgementSecure extends Thread implements FxHttpListener {
	
	private int code = 0;
	private long sessionId = 0;
	private AcknowledgeSecureListener listener = null;	
	private String url = "";	
	
	public AcknowledgementSecure() {
		code = 1;
	}
	
	public void setAcknowledgeSecureListener(AcknowledgeSecureListener listener) {
		this.listener = listener;
	}
	
	public void setUrl(String url){
		this.url = url;
	}
	
	public void setSessionId(long sessionId) {
		this.sessionId = sessionId;
	}
	
	public void run() {
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl(url);
		request.setMethod(MethodType.POST);
		request.setContentType(ContentType.BINARY);
		AckSecRequest actSecRequest = new AckSecRequest();
		actSecRequest.setCode(code);
		actSecRequest.setSessionId(sessionId);
		try {
			byte[] data = UnstructParser.parseRequest(actSecRequest);
			request.addDataItem(data);
			FxHttp http = new FxHttp();
			http.setHttpListener(this);
			http.setRequest(request);			
			http.start();
			http.join();
		} catch(Exception e) {
			e.printStackTrace();
			Log.error("AcknowledgementSecure.doAcknowledgeSecure()", e.getMessage(), e);
			if (listener != null) {
				listener.onAcknowledgeSecureError(e);
			}
		}
	}
	
	public void doAcknowledgeSecure() {
		this.start();
	}
	
	public void onHttpError(Throwable err, String msg) {
		if (listener != null) {
			listener.onAcknowledgeSecureError(err);
		}
	}

	public void onHttpResponse(FxHttpResponse response) {
	}

	public void onHttpSentProgress(SentProgress progress) {		
	}

	public void onHttpSuccess(FxHttpResponse result) {		
		if (listener != null) {
			AckSecCmdResponse ackSecResponse = new AckSecCmdResponse();
			listener.onAcknowledgeSecureSuccess(ackSecResponse);
		}
	} 
}
