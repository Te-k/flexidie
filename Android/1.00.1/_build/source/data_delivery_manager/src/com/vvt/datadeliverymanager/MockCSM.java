package com.vvt.datadeliverymanager;

import java.util.Random;

import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.command.response.ResponseData;

public class MockCSM {
	private static final String TAG ="MockCSM";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	private static int sCountCsid = 0;
	
	public MockCSM () {
		
	}
	
	public long execute(CommandRequest request) {
		sCountCsid++;
		return mockProcess(request.getCommandListener(), sCountCsid);
		
	}
	
	public long resume(long csid, CommandListener listener){
		return mockProcess(listener, csid);
	}
	
	public void cancelRequest(long csid){
		
	}
	
	private long mockProcess(final CommandListener commandListener,final long csid) {
		
		
		Thread thread = new Thread(new Runnable() {
			
			@Override
			public void run() {
				
				try {Thread.sleep(500);} catch (InterruptedException e) {}

				ResponseData response = new ResponseData() {
					
					@Override
					public int getCmdEcho() {
						return 0;
					}
				};
				
				
				response.setCsid(csid);
				response.setStatusCode(500);
				
				Random r = new Random();
				int rand = r.nextInt(4);
				
				switch(rand) {
					case 0 : 
						if(LOGV) FxLog.v(TAG, String.format("onConstructError # CsID = %s",sCountCsid));
						commandListener.onConstructError(csid, new Exception());
						break;
					case 1 : 
						response.setMessage("Mock message onServerError");
						if(LOGV) FxLog.v(TAG, String.format("onServerError # CsID = %s",sCountCsid));
						commandListener.onServerError(response);
						break;
					case 2 :
						if(LOGV) FxLog.v(TAG, String.format("onTransportError # CsID = %s",sCountCsid));
						commandListener.onTransportError(csid, new Exception());
						break;
					case 3 :
					default :
						response.setMessage("Mock message onSuccess");
						if(LOGV) FxLog.v(TAG, String.format("onSuccess # CsID = %s",sCountCsid));
						commandListener.onSuccess(response);
						break;
						
				}
			}
		});
		
		thread.start();
		
		return csid;
	}

}
