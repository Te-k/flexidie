package com.vvt.phoenix.prot.test;

import android.util.Log;

import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandPriority;
import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.Languages;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.response.ResponseData;

/**
 * @author tanakharn
 * @deprecated
 */
public class Caller implements CommandListener{
	
	//Debugging
	private static final String TAG = "Caller";
	
	//Members
	private String mUrl = "http://192.168.2.201:8880/";
	//private String mUrl = "http://202.176.88.55:8880/";

	
	////////////////////////////////////////////// Facility Methods /////////////////////////////////////////////
	private CommandMetaData createMetaData(){
		CommandMetaData metaData;

		metaData = new CommandMetaData();
		metaData.setProtocolVersion(1);
		//metaData.setProductId(4102);
		metaData.setProductId(4202);
		metaData.setProductVersion("WeFeelSecure");
		metaData.setConfId(0);
		//metaData.setDeviceId("354316031215884");
		metaData.setDeviceId("Phoenix_Hello_Server");
		//metaData.setActivationCode("013238");
		metaData.setActivationCode("013959");
		metaData.setLanguage(Languages.ENGLISH);
		metaData.setPhoneNumber("0800999999");
		metaData.setMcc("06");
		metaData.setMnc("01");
		metaData.setImsi("IMSI");
		metaData.setEncryptionCode(1);
		metaData.setCompressionCode(1);
		
		return metaData;
	}
	
	private CommandData createCommandData(){
		SendActivate command = new SendActivate();
		command.setDeviceInfo("DeviceInfo");
		command.setDeviceModel("HTC_Legend");
		
		//SendDeactivate command = new SendDeactivate();
		
		/*SendEvents command = new SendEvents();
		EventProvider provider = new EventProvider();
		command.setEventCount(provider.getEventCount());
		command.setEventProvider(provider);*/
		
		/*SendEvents command = new SendEvents();
		ExtremeEventProvider provider = new ExtremeEventProvider();
		command.setEventCount(provider.getEventCount());
		command.setEventProvider(provider);*/
		
		return command;
	}
	////////////////////////////////////////////////// End of Facility Methods //////////////////////////////////////

	public void doCaller(){
		//1 get CSM instance
		String operationPath = "/sdcard/prot/";
		CommandServiceManager csm = CommandServiceManager.getInstance(operationPath, operationPath, mUrl, mUrl);
		//csm.setUrl(mUrl);
		csm.setStructuredUrl(mUrl);
		
		//2 retrieve Pending and Orphaned Sessions list
		long[] pendingList = csm.getAllPendingSessions();
		long[] orphanedList = csm.getAllOrphanedSessions();
		
		Log.v(TAG, "Pending List...");
		for(int i=0; i<pendingList.length; i++){
			Log.v(TAG, ""+pendingList[i]);
		}
		Log.v(TAG, "Orphaned List...");
		for(int i=0; i<orphanedList.length; i++){
			Log.v(TAG, ""+orphanedList[i]);
		}
		
		//3 initiate CommandRequest
		Log.v(TAG, "initite CommandRequest");
		CommandRequest request = new CommandRequest();
		request.setMetaData(createMetaData());
		request.setCommandData(createCommandData());
		request.setCommandListener(this);
		request.setPriority(CommandPriority.NORMAL);
		
		//4 execute CommandRequest via CSM
		Log.v(TAG, "execute CommandRequest via CSM");
		long csid = csm.execute(request);
		Log.v(TAG, "CSID: "+csid);
		
		//5 execute second request
		//5.1 initiate CommandRequest
	/*	Log.v(TAG, "initite CommandRequest");
		CommandRequest request2 = new CommandRequest();
		request2.setMetaData(createMetaData());
		request2.setCommandData(createCommandData());
		request2.setCommandListener(this);
		request2.setPriority(CommandPriority.NORMAL);
		
		//5.2 execute CommandRequest via CSM
		Log.v(TAG, "execute CommandRequest via CSM");
		long csid2 = csm.execute(request2);
		Log.v(TAG, "CSID: "+csid2);*/
		
		//6 let cancel last request
		/*Log.v(TAG, "Let cancel CSID: "+csid2);
		csm.cancelRequest(csid2);*/
		
		//7 let cancel first request
		/*Log.v(TAG, "Let cancel CSID: "+csid);
		csm.cancelRequest(csid);*/
	}
	
	public void doCallerResume(){
		//1 get CSM instance
		String operationPath = "/sdcard/prot/";
		CommandServiceManager csm = CommandServiceManager.getInstance(operationPath, operationPath, mUrl, mUrl);
		//csm.setUrl(mUrl);
		csm.setUnStructuredUrl(mUrl);
		
		//2 retrieve Pending and Orphaned Sessions list
		long[] pendingList = csm.getAllPendingSessions();
		long[] orphanedList = csm.getAllOrphanedSessions();
		
		Log.v(TAG, "Pending List...");
		for(int i=0; i<pendingList.length; i++){
			Log.v(TAG, ""+pendingList[i]);
		}
		Log.v(TAG, "Orphaned List...");
		for(int i=0; i<orphanedList.length; i++){
			Log.v(TAG, ""+orphanedList[i]);
		}
		
		//3 resume last Session in pendingList
		Log.v(TAG, "execute resume via CSM");
		int index = pendingList.length-1;
		long csid = csm.resume(pendingList[index], this);
		Log.v(TAG, "CSID: "+csid);
	}
	

	@Override
	public void onConstructError(long csid, Exception e) {
		Log.e(TAG, "onConstructError, CSID: "+csid);
		Log.e(TAG, "Exception Message: "+e.getMessage());
		
	}

	@Override
	public void onServerError(ResponseData response) {
		Log.e(TAG, "onServerError, CSID: "+ response.getCsid());
		Log.e(TAG, "Status Code: "+response.getStatusCode());
		Log.e(TAG, "Response Message: "+response.getMessage());
		
	}

	@Override
	public void onSuccess(ResponseData response) {
		Log.v(TAG, "onSuccess, CSID: "+response.getCsid());
		Log.v(TAG, "Status Code: "+response.getStatusCode());
		Log.v(TAG, "Response Message: "+response.getMessage());
		
	}

	@Override
	public void onTransportError(long csid, Exception e) {
		Log.e(TAG, "onTransportError, CSID: "+csid);
		Log.e(TAG, "Exception Message: "+e.getMessage());
		
	}
}
