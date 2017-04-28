package com.vvt.phoenix.prot.test;

import java.util.concurrent.PriorityBlockingQueue;

import android.util.Log;

import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandPriority;
import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.NewRequest;
import com.vvt.phoenix.prot.Request;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.Languages;
import com.vvt.phoenix.prot.command.SendAddrBookForApproval;
import com.vvt.phoenix.prot.command.SendAddressBook;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.command.response.ResponseData;

/**
 * @author tanakharn
 * This class act as Caller
 * @deprecated
 */
public class CommandServiceManagerTest implements CommandListener{

	//Debugging
	private static final String TAG = "CommandServiceManagerTest";
	
	//Members

	private CommandMetaData createMetaData(){
		CommandMetaData metaData;

		metaData = new CommandMetaData();
		metaData.setProtocolVersion(1);
		metaData.setProductId(4);
		metaData.setProductVersion("FXS2.0");
		metaData.setConfId(2);
		metaData.setDeviceId("N1");
		metaData.setActivationCode("1150");
		metaData.setLanguage(Languages.THAI);
		metaData.setPhoneNumber("0800999999");
		metaData.setMcc("MCC");
		metaData.setMnc("MNC");
		metaData.setImsi("IMSI");
		metaData.setEncryptionCode(1);
		metaData.setCompressionCode(1);
		
		return metaData;
	}
	
	public void testCSM(){
		String operationPath = "/sdcard/prot/";
		String url = "xxx.xxx";
		CommandServiceManager csm = CommandServiceManager.getInstance(operationPath, operationPath, url, url);
		
		// show pending and orphaned sessions
		long[] pending = csm.getAllPendingSessions();
		long[] orphaned = csm.getAllOrphanedSessions();
		Log.v(TAG, "Pending Session...");
		for(int i=0; i<pending.length; i++){
			Log.v(TAG, ""+pending[i]);
		}
		Log.v(TAG, "Orphaned Session...");
		for(int i=0; i<orphaned.length; i++){
			Log.v(TAG, ""+orphaned[i]);
		}
		
		SendEvents data = new SendEvents();
		CommandMetaData meta = createMetaData();
		CommandRequest req = new CommandRequest();
		req.setMetaData(meta);
		req.setCommandData(data);
		req.setCommandListener(this);
		req.setPriority(CommandPriority.NORMAL);
		Log.v(TAG, "CSID: "+csm.execute(req));
		//showQPeekDetail(csm.getQ());
		
		SendAddressBook data2 = new SendAddressBook();
		req = new CommandRequest();
		req.setMetaData(meta);
		req.setCommandData(data2);
		req.setCommandListener(this);
		req.setPriority(CommandPriority.HIGH);
		Log.v(TAG, "CSID: "+csm.execute(req));
		//showQPeekDetail(csm.getQ());
		
		SendAddrBookForApproval data3 = new SendAddrBookForApproval();
		req = new CommandRequest();
		req.setMetaData(meta);
		req.setCommandData(data3);
		req.setCommandListener(this);
		req.setPriority(CommandPriority.HIGHEST);
		Log.v(TAG, "CSID: "+csm.execute(req));
		//showQPeekDetail(csm.getQ());
		
		SendEvents data4 = new SendEvents();
		req = new CommandRequest();
		req.setMetaData(meta);
		req.setCommandData(data4);
		req.setCommandListener(this);
		req.setPriority(CommandPriority.NORMAL);
		Log.v(TAG, "CSID: "+csm.execute(req));
		//showQPeekDetail(csm.getQ());
		
		
		
		//showQDetail(csm.getQ());
	}
	
	private void showQPeekDetail(PriorityBlockingQueue<Request> q){
		Log.v(TAG, "Q Size: "+ q.size());
		//Log.v(TAG, "Peek Request Type: "+ q.peek().getRequestType());
		Log.v(TAG, "Peek Priority: "+ q.peek().getPriority());
		
		NewRequest newR = (NewRequest) q.peek();
		Log.v(TAG, "Peek Command Code: "+newR.getCommandRequest().getCommandData().getCmd());
		
	}
	
	private void showQDetail(PriorityBlockingQueue<Request> q){
		
		Log.v(TAG, "Q Summary ...");
		
		Log.v(TAG, "Q Size: "+ q.size());

		Request r = q.poll();
		while(r != null){
			Log.v(TAG, "Priority: "+ r.getPriority());
			NewRequest newR = (NewRequest) r;
			Log.v(TAG, "Command Code: "+newR.getCommandRequest().getCommandData().getCmd());
			r = q.poll();
		}
	}

	@Override
	public void onConstructError(long csid, Exception e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onServerError(ResponseData response) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onSuccess(ResponseData response) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onTransportError(long csid, Exception e) {
		// TODO Auto-generated method stub
		
	}
	
	

}
