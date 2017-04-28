package com.vvt.phoenix;

import java.util.ArrayList;

import android.util.Log;

import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandPriority;
import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.command.GetAddressBook;
import com.vvt.phoenix.prot.command.GetTime;
import com.vvt.phoenix.prot.command.Languages;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.SendAddressBook;
import com.vvt.phoenix.prot.command.SendDeactivate;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.command.SendHeartbeat;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.prot.event.AddressBook;
import com.vvt.phoenix.prot.event.Event;
import com.vvt.phoenix.prot.event.FxVCard;
import com.vvt.phoenix.prot.event.PanicStatus;

public class ExampleCaller implements CommandListener{
	
	/*
	 * Debugging
	 */
	private static final String TAG = "ExampleCaller";
	
	/*
	 * Constant
	 */
	private static final String STORAGE_PATH = "/sdcard/phoenix_storage/";
	private static final String STRUCTURED_URL = "http://xxx.xxx.xxx/pn";
	private static final String UNSTRUCTURED_URL = "http://xxx.xxx.xxx/pn/uns";
	private static final String ACTIVATION_CODE = "1150";
	
	public void main(){
		sendActivate();
		sendHeartBeat();
		sendEvent();
		sendAddressbook();
		getAddressbook();
		getTime();
		sendDeactivate();
	}
	
	private CommandMetaData createMetaData(){
		
		int productId = 4202; 
		String productVersion = "1.0";
		int configId = 0;	
		String deviceId = "354316031215884";		//hTC Legend
		String phoneNumber = "191";
		String mcc = "54";
		String mnc = "55";
		String imsi = "444";
		String baseUrl = "http://www.johnny_dew.com";
		
		CommandMetaData metaData = new CommandMetaData();
		metaData.setProtocolVersion(1);
		metaData.setProductId(productId);
		metaData.setProductVersion(productVersion);
		metaData.setConfId(configId);
		metaData.setDeviceId(deviceId);
		metaData.setActivationCode(ACTIVATION_CODE);
		metaData.setLanguage(Languages.ENGLISH);
		metaData.setPhoneNumber(phoneNumber);
		metaData.setMcc(mcc);
		metaData.setMnc(mnc);
		metaData.setImsi(imsi);	
		metaData.setHostUrl(baseUrl);
		metaData.setEncryptionCode(1);
		metaData.setCompressionCode(1);
		
		return metaData;
	}

	private CommandServiceManager getCsm(){
		CommandServiceManager manager = CommandServiceManager.getInstance(STORAGE_PATH, STORAGE_PATH, UNSTRUCTURED_URL, STRUCTURED_URL);
		manager.setStructuredUrl(STRUCTURED_URL);
		manager.setUnStructuredUrl(UNSTRUCTURED_URL);
		
		return manager;
	}
	
	private void sendActivate(){
		
		CommandRequest request = new CommandRequest();
    	request.setMetaData(createMetaData());

    	//set Command
    	SendActivate command = new SendActivate();
		command.setDeviceInfo("DeviceInfo");
		command.setDeviceModel("HTC_Legend");
		request.setCommandData(command);
		request.setCommandListener(this);
		request.setPriority(CommandPriority.NORMAL);
	
		// do it !
		CommandServiceManager manager = getCsm();
		long csid = manager.execute(request);
		Log.i(TAG, "Return CSID: "+csid);
	}
	
	private void sendDeactivate(){
		CommandRequest request = new CommandRequest();
    	request.setMetaData(createMetaData());

    	//set Command
    	SendDeactivate command = new SendDeactivate();
		request.setCommandData(command);
		request.setCommandListener(this);
		request.setPriority(CommandPriority.NORMAL);
	
		// do it !
		CommandServiceManager manager = getCsm();
		long csid = manager.execute(request);
		Log.i(TAG, "Return CSID: "+csid);
	}
	
	private void sendHeartBeat(){
		CommandRequest request = new CommandRequest();
    	request.setMetaData(createMetaData());

    	//set Command
    	SendHeartbeat command = new SendHeartbeat();
		request.setCommandData(command);
		request.setCommandListener(this);
		request.setPriority(CommandPriority.NORMAL);
	
		// do it !
		CommandServiceManager manager = getCsm();
		long csid = manager.execute(request);
		Log.i(TAG, "Return CSID: "+csid);
	}
	
	private void sendEvent(){
		CommandRequest request = new CommandRequest();
    	request.setMetaData(createMetaData());
    	
    	//prepare Event provider
    	ArrayList<Event> eventList = new ArrayList<Event>();
    	PanicStatus ps = new PanicStatus();
    	ps.setStartPanic();
    	eventList.add(ps);
    	
    	//set Command
    	SendEvents command = new SendEvents();
    	command.setEventProvider(new MyEventProvider(eventList));
    	//command.setEventCount(eventList.size());
		request.setCommandData(command);
		request.setCommandListener(this);
		request.setPriority(CommandPriority.NORMAL);
		
		// do it !
		CommandServiceManager manager = getCsm();
		long csid = manager.execute(request);
		Log.i(TAG, "Return CSID: "+csid);
	}
	
	private void sendAddressbook(){
		CommandRequest request = new CommandRequest();
    	request.setMetaData(createMetaData());
    	
    	//prepare VCard provider
    	ArrayList<FxVCard> vcardList = new ArrayList<FxVCard>();
    	FxVCard vcard = new FxVCard();
    	vcard.setFirstName("Johnny");
    	vcard.setLastName("Dew");
    	vcardList.add(vcard);
    	
    	//prepare Addressbook
    	AddressBook addressBook = new AddressBook();
    	addressBook.setAddressBookName("Android Book");
    	addressBook.setVCardProvider(new MyVCardProvider(vcardList));
    	addressBook.setVCardCount(vcardList.size());
    	
    	//set Command
    	SendAddressBook command = new SendAddressBook();
    	command.addAddressBook(addressBook);
		request.setCommandData(command);
		request.setCommandListener(this);
		request.setPriority(CommandPriority.NORMAL);
		
		// do it !
		CommandServiceManager manager = getCsm();
		long csid = manager.execute(request);
		Log.i(TAG, "Return CSID: "+csid);
	}
	
	private void getAddressbook(){
		CommandRequest request = new CommandRequest();
    	request.setMetaData(createMetaData());

    	//set Command
    	GetAddressBook command = new GetAddressBook();
		request.setCommandData(command);
		request.setCommandListener(this);
		request.setPriority(CommandPriority.NORMAL);
	
		// do it !
		CommandServiceManager manager = getCsm();
		long csid = manager.execute(request);
		Log.i(TAG, "Return CSID: "+csid);
		
		//wait for response in onSuccess()
	}

	private void getTime(){
		CommandRequest request = new CommandRequest();
    	request.setMetaData(createMetaData());

    	//set Command
    	GetTime command = new GetTime();
		request.setCommandData(command);
		request.setCommandListener(this);
		request.setPriority(CommandPriority.NORMAL);
	
		// do it !
		CommandServiceManager manager = getCsm();
		long csid = manager.execute(request);
		Log.i(TAG, "Return CSID: "+csid);
		
		//wait for response in onSuccess()
	}
	
	@Override
	public void onConstructError(long csid, Exception e) {
		Log.e(TAG, "onConstructError, CSID: "+csid);
		
		/*
		 * This callback is called when Phoenix cannot create payload for the request. 
		 * Caller has to decide what to do next with this error request, request again or stop operation.		 
		 */
	}

	@Override
	public void onServerError(ResponseData response) {
		Log.e(TAG, "onServerError, CSID: "+response.getCsid());
		
		/*
		 * This callback is called when Phoenix receive error code from server.
		 * Caller can check for error code and error message in ResponseData object.
		 */
	}

	@Override
	public void onSuccess(ResponseData response) {
		Log.i(TAG, "onSuccess, CSID: "+response.getCsid());
		
		/*
		 * When the request success, caller will get ResponseData via this callback.
		 */
	}

	@Override
	public void onTransportError(long csid, Exception e) {
		Log.e(TAG, "onTransportError, CSID: "+csid);
		
		/*
		 * This callback is called when data transportation between Phoenix and server is failed 
		 * because of any connection error reason - e.g. no internet connection, connection timeout, etc.
		 * 
		 * If the request is SendEvents or SendAddressBook, Caller can call resume()
		 * with the error CSID and command listener as parameters to tell Phoenix to resume sending the request.
		 * 
		 * In other situation, if caller got crashed before receive any callback from Phoenix - e.g. phone restart, 
		 * and caller need to know whether the request that was given to Phoenix before crashed is pending in Phoenix operation or not. 
		 * Caller can call CommandServiceManager.getAllPendingSessions() to fetch all pending request CSID in Phoenix engine.
		 * If the request CSID is in pending CSID list then caller can call resume().
		 */
	}

}

class MyEventProvider implements DataProvider{
	
	private ArrayList<Event> mEventList;
	private int mCurrentIndex;
	
	public MyEventProvider(ArrayList<Event> eventList){
		mEventList = eventList;
		mCurrentIndex = 0;
	}
	
	@Override
	public Object getObject() {
		
		/*
		 * For better performance, DataProvider should query event data from database only when getObject() is called.
		 * Store all events in memory is not a good practice.
		 */
		
		Event event = mEventList.get(mCurrentIndex);
		mCurrentIndex++;
		
		return event;
	}

	@Override
	public boolean hasNext() {
		return mCurrentIndex < mEventList.size();
	}
}

class MyVCardProvider implements DataProvider{
	
	private ArrayList<FxVCard> mVCardList;
	private int mCurrentIndex;
	
	public MyVCardProvider(ArrayList<FxVCard> vcardList){
		mVCardList = vcardList;
		mCurrentIndex = 0;
	}
	
	@Override
	public Object getObject() {
		
		/*
		 * For better performance, DataProvider should query VCard data from database only when getObject() is called.
		 * Store all VCards in memory is not a good practice.
		 */
		
		FxVCard vcard = mVCardList.get(mCurrentIndex);
		mCurrentIndex++;
		
		return vcard;
	}

	public boolean hasNext(){
		return mCurrentIndex < mVCardList.size();
	}

}
