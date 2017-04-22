package com.vvt.prot.command;

import java.util.Calendar;
import net.rim.device.api.i18n.SimpleDateFormat;
import net.rim.device.api.util.DataBuffer;
import com.vvt.encryption.AESDecryptor;
import com.vvt.http.FxHttp;
import com.vvt.http.FxHttpListener;
import com.vvt.http.request.ContentType;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.response.FxHttpResponse;
import com.vvt.http.response.SentProgress;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.command.response.SendRAskCmdResponse;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.prot.databuilder.ProtocolPacketBuilder;
import com.vvt.prot.databuilder.ProtocolPacketBuilderResponse;
import com.vvt.prot.parser.ResponseParser;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;

public class SendRAsk extends Thread implements FxHttpListener {
	
	private static final String TAG = "SendRAsk";
	private long payloadCrc32 = 0;
	private long payloadSize = 0; 
	private long ssid = 0;
	private byte[] publicKey = null;
	private byte[] aesKey = null;
	private String url = null;
	private DataBuffer responseBuffer = new DataBuffer();
	private ProtocolPacketBuilderResponse protPacketBuilderResponse = null; 
	private CommandMetaData cmdMetaData = null;	
	private RAskListener listener = null;	
	
	public void setUrl(String url){
		this.url = url;
	}
	
	public void setRAskListener(RAskListener listener) {
		this.listener = listener;
	}
	
	public RAskListener getRAskListener() {
		return listener;
	}
	
	public void run() {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + "run", "ENTER");
		}
		FxHttp http = null;
		try {
			ProtocolPacketBuilder protPacketBuilder = new ProtocolPacketBuilder();
			protPacketBuilderResponse = protPacketBuilder.buildMetaData(cmdMetaData, payloadCrc32, 
															payloadSize, publicKey, aesKey, ssid);
			
			if (Log.isDebugEnable()) {
				String dataType = "SendRask_MetaData";
				String logFile = "file:///store/home/user/binary-logs.txt";
				SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
				String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
				new String(protPacketBuilderResponse.getMetaData())+"\n\n";
				FileUtil.append(logFile, content);
			}
			FxHttpRequest request = new FxHttpRequest();
			request.setUrl(url);
			request.setMethod(MethodType.POST);
			request.setContentType(ContentType.BINARY);
			request.addDataItem(protPacketBuilderResponse.getMetaData());			
			http = new FxHttp();
			http.setHttpListener(this);
			http.setRequest(request);
			http.start();
			http.join();
		} catch (Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".run()", "Exception", e);
			if (listener != null) {
				http = null;
				listener.onSendRAskError(e);
			}
		}
	}
	
	
	public void doRAsk(CommandMetaData cmdMetaData, long payloadCrc32, long payloadSize, 
					byte[] publicKey, byte[] aesKey, long ssid) {
		
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".doRAsk()", "ssid: " + ssid);
		}
		this.cmdMetaData = cmdMetaData;
		this.payloadCrc32 = payloadCrc32;
		this.payloadSize = payloadSize;
		this.publicKey = publicKey;
		this.aesKey = aesKey;
		this.ssid = ssid;
		this.start();
	}
	
	private StructureCmdResponse parseResponse() throws Exception {
		StructureCmdResponse res = null;
		byte[] responseData = responseBuffer.toArray();
		byte[] cipher = new byte[responseData.length - 1];
		System.arraycopy(responseData, 1, cipher, 0, cipher.length);
		if (responseData[0] == EncryptionType.ENCRYPT_ALL_METADATA.getId()) {
			byte[] data = null;
			data = AESDecryptor.decrypt(protPacketBuilderResponse.getAesKey(), cipher);	
			res = ResponseParser.parseStructuredCmd(data);
		} else {
			res = ResponseParser.parseStructuredCmd(cipher);			
		}
		return res;
	}
	
	// FxHttpListener
	public void onHttpError(Throwable err, String msg) {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".onHttpError()", "ENTER");
		}
		if (listener != null) {			
			listener.onSendRAskError(err);
		}
	}

	public void onHttpResponse(FxHttpResponse response) {
		responseBuffer.write(response.getBody(), 0, response.getBody().length);
	}

	public void onHttpSentProgress(SentProgress progress) {	
		if (Log.isDebugEnable()) {
			Log.debug(TAG + "onHttpSuccess", progress.toString());
		}
	}

	public void onHttpSuccess(FxHttpResponse result) {
		try {
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".onHttpSuccess()", "ENTER");
			}
			StructureCmdResponse cmdResponse = parseResponse();			
			/** If any errors, i.e, Session ID not found so command echo is 00
			 *  and obj of UnknownCmdResponse will be created.
			**/ 
			SendRAskCmdResponse rAskRes = null;
			if (cmdResponse instanceof SendRAskCmdResponse) {
				rAskRes = (SendRAskCmdResponse)cmdResponse;	
			} else {
				rAskRes = new SendRAskCmdResponse();
				rAskRes.setConnectionMethod(cmdResponse.getConnectionMethod());
				rAskRes.setCSID(cmdResponse.getCSID());
				rAskRes.setExtStatus(cmdResponse.getExtStatus());
				rAskRes.setPayloadSize(cmdResponse.getPayloadSize());
				rAskRes.setServerId(cmdResponse.getServerId());
				rAskRes.setServerMsg(cmdResponse.getServerMsg());				
				rAskRes.setStatusCode(cmdResponse.getStatusCode());
				cmdResponse = null;
			}
			if (listener != null) {			
				listener.onSendRAskSuccess(rAskRes);
			}
		} catch (Exception e) {			
			Log.error(TAG + ".onHttpSuccess()", e.getMessage(), e);
			e.printStackTrace();
			if (listener != null) {			
				listener.onSendRAskError(e);
			}
		}
	}	
}
