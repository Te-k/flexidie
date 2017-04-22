package com.vvt.datadeliverymanager.store;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import android.content.Context;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.exceptions.FxListenerNotFoundException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.logger.FxLog;

/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 11:10:58
 */
public class RequestStore {

	private static final String TAG = "RequestStore";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	
	private static RequestStore instance = null;
	private static Context mContext;
	
	private BlockingQueue<DeliveryRequest> mNewQueue = null;
	private PersistedStoreHelper mPersistedStoreHelper = null;
	private HashMap<DeliveryListener, Integer> mlistenerMap = null;  
	
	// Private constructor prevents instantiation from other classes
	private RequestStore(String path) {
		if(LOGV) FxLog.v(TAG, "RequestStore # START");
		if(LOGD) FxLog.d(TAG, "RequestStore # path:" + path);
		
		mNewQueue = new LinkedBlockingQueue<DeliveryRequest>();
		mPersistedStoreHelper = new PersistedStoreHelper(mContext, path);
		mlistenerMap = new HashMap<DeliveryListener, Integer>();
		if(LOGV) FxLog.v(TAG, "RequestStore # EXIT");
	}

	public static RequestStore getInstance(Context context, String path) {
		if (instance == null) {
			mContext = context;

			instance = new RequestStore(path);
		}
		return instance;
	}
	
	public void initializeStore() {
		mPersistedStoreHelper.initailStore();
	}

	/**
	 * Insert a new request to request store.
	 * @param deliveryRequest request to insert.
	 * @throws FxNullNotAllowedException if deliveryRequest is null
	 * @throws FxListenerNotFoundException if the listener in DeliveryRequest is null
	 */
	public synchronized void insertRequest(DeliveryRequest deliveryRequest) {
		if(deliveryRequest != null) {
			if(LOGV) FxLog.v(TAG, "insertRequest # ENTER ...");
			if(LOGD) FxLog.d(TAG, "insertRequest # deliveryRequest :" + deliveryRequest.toString());
			
			//Request with callerID but no listener will be managed (by reset caller ID).
			cleanupListener(deliveryRequest);
			
			mNewQueue.add(deliveryRequest);
	
			// Validating the listener (caller ID <= 0 means no listener set)
			if(isValidListener(deliveryRequest.getCallerID())) {
				// Avoid duplicated registration from the same caller
				if(!mlistenerMap.containsKey(deliveryRequest.getDeliveryListener())) {
					mlistenerMap.put(deliveryRequest.getDeliveryListener(), deliveryRequest.getCallerID());
				}
			}
			
			// Make persisted request resumable immediately
			// get the cmd id and caller id and update the persistence store
			if(mPersistedStoreHelper.hasDeliveryRequest(deliveryRequest.getCommandData().getCmd())) {
				// Yes, Update the request as resumeable ..
				mPersistedStoreHelper.updateRequestAsResumeable(
						deliveryRequest.getCommandData().getCmd(),deliveryRequest.getRequestPriority());
			}
		} else {
			if(LOGW) FxLog.w(TAG,"deliveryRequest is null");
		}
		if(LOGV) FxLog.v(TAG, "insertRequest # EXIT ...");
	}
	
	/**
	 * if request have callerID but no listener, we will set callerID to -1 that mean ignore listener.
	 * @param deliveryRequest
	 */
	private void cleanupListener(DeliveryRequest deliveryRequest) {
		boolean hasCallerId = isValidListener(deliveryRequest.getCallerID());
		DeliveryListener deliveryListener = deliveryRequest.getDeliveryListener(); 
		if(hasCallerId && deliveryListener == null) {
			deliveryRequest.setCallerID(-1);
			if(LOGW) FxLog.w(TAG,"Listener is null for the caller id:" + deliveryRequest.getCallerID());
		}
	}
	
	/**
	 * Check whether caller id is valid. If less than 0 that means there is no listener to this request. Eg. SendHeartBeat
	 * @param callerId
	 * @return
	 */
	private boolean isValidListener(int callerId) {
		return (callerId > 0);
	}
	
	/**
	 * Update a request state in the persiststore
	 * @param deliveryRequest
	 * @throws FxNullNotAllowedException
	 */
	synchronized public boolean updateRequest(DeliveryRequest deliveryRequest) {
		if(deliveryRequest != null) {
			// Persist everything except command meta data and listener
			return mPersistedStoreHelper.updateRequest(deliveryRequest);
		} else {
			return false;
		}
	}

	/**
	 * Deletes a request in the persist store
	 * @param csmCmdCode command id
	 * @param callerID caller id
	 */
	public void deleteRequest(long csid) {
		if(LOGV) FxLog.v(TAG, "deleteRequest # START");
		if(LOGV) FxLog.v(TAG, "deleteRequest # delete csid:" + csid);
		boolean isSuccess = mPersistedStoreHelper.deleteRequest(csid);
		if(LOGV) FxLog.v(TAG, "deleteRequest # delete isSuccess :" + isSuccess);
		if(LOGV) FxLog.v(TAG, "deleteRequest # EXIT");
	}
	
	/**
	 * Steps:
	 * <p>
 	 *	1. Pick the one that is ready to resume from persistence store. (high priority first or older one first)
 	 *</p> <p>
	 *	2.1 If there is an item in the persist store then
	 *</p> <p>
	 *	2.1.1 Compare priority with the all the requests in the new queue and pick the highest priority request
	 *</p><p>
	 *	2.1.2 If it is same priority choose the one persist store request.
	 *</p><p>
	 *	2.2 Look in the queue for the highest priority, if not select same priority
	 *</p><p>
	 * @return <code>DeliveryRequest<code>  with the highest priority or oldest
	 * @throws FxListenerNotFoundException if the listener in DeliveryRequest is null
	 */
 	synchronized public DeliveryRequest getProperRequest() throws FxListenerNotFoundException {
 		if(LOGV) FxLog.v(TAG, "getProperRequest # ENTER ....");
 		
		 // 1. Pick the one that is ready to resume from persistence store. (high priority first or older one first)
		DeliveryRequest resumableRequest = mPersistedStoreHelper.getResumeableDeliveryRequest();
		DeliveryRequest ret = null;

		if (resumableRequest != null) {
			if(LOGD) FxLog.d(TAG, "getProperRequest # resumableRequest is null ....");
			
			// 2.1 If there is an item in the persist store then
			List<DeliveryRequest> requestsInQueue = new ArrayList<DeliveryRequest>();
			requestsInQueue.addAll(getAllRequestsInQueue());

			// 2.1.1 Compare priority with the all the requests in the new queue and pick the higest priority request
			ret = getHigherPriorityDeliveryRequest(resumableRequest, requestsInQueue);

			if (ret == null) // 2.1.2 If it is same priority choose the one persist store request.
				ret = resumableRequest;

		} else { // 2.2  Look in the queue for the highest priority, if not select same priority
			List<DeliveryRequest> inputs = new ArrayList<DeliveryRequest>();
			inputs.addAll(getAllRequestsInQueue());
			ret = getHighestPriorityDeliveryRequest(inputs);
		}

		if (ret != null) {
			if(LOGV) FxLog.v(TAG, "getProperRequest # ret is not null ....");
			
			if (isQueuedRequest(ret)) {
				if(LOGD) FxLog.d(TAG, "getProperRequest # ret is Queued request ....");
				
				//set REQUEST_TYPE_PERSISTED for save to db.
				ret.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_PERSISTED);
				ret.setCSID(-1);
				saveToPersistedStore(ret);
				//set REQUEST_TYPE_NEW for sent to Executor.
				ret.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
			} else {
				if(LOGD) FxLog.d(TAG, "getProperRequest # ret is not a Queued request ....");
				ret.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_PERSISTED);
			}

			if(LOGV) FxLog.v(TAG, "getProperRequest # caller id is " + ret.getCallerID());
			
			if (isValidListener(ret.getCallerID())) {
				if(LOGV) FxLog.v(TAG, "getProperRequest # isValidListener is  true");
				setListenerIfNull(ret);
			}
			else {
				if(LOGV) FxLog.v(TAG, "getProperRequest # isValidListener is  false");
			}
		}

		if(LOGV) FxLog.v(TAG, "getProperRequest # EXIT ....");
		return ret;
	}
 	
 	/**
 	 * Set the listener if it's not set
 	 * @param request
 	 * @throws FxListenerNotFoundException If no listner found to attach
 	 */
 	private void setListenerIfNull(DeliveryRequest request) throws FxListenerNotFoundException {
 		if(LOGV) FxLog.v(TAG, "setListenerIfNull START ....");
 		
 		if(request.getDeliveryListener() == null) {
 			if(LOGD) FxLog.d(TAG, "setListenerIfNull # getDeliveryListener is  null");
 			request.setDeliveryListener(getListener(request.getCallerID(), request.getCommandData().getCmd(),request.getCsId()));
 		}
 		
 		if(LOGV) FxLog.v(TAG, "setListenerIfNull EXIT ....");
 	}
 	/**
 	 * Select a listner from the map. if not found return null
 	 * @param callerId Caller id of the listener
 	 * @param cmdId Command Id
 	 * @return <code>DeliveryListener</code> if not found retrun <code>null</code>
 	 * @throws FxListenerNotFoundException
 	 */
 	private DeliveryListener getListener(int callerId, int cmdId, long csid) throws FxListenerNotFoundException {
 		if(LOGV) FxLog.v(TAG, "getListener START ....");
 		
		DeliveryListener dListener = null;
		Set<Entry<DeliveryListener, Integer>> set = mlistenerMap.entrySet();
		Iterator<Entry<DeliveryListener, Integer>> i = set.iterator();
		Map.Entry<DeliveryListener, Integer> me = null;
		
		while (i.hasNext()) {
			me = i.next();
			if (me.getValue() == callerId) {
				dListener = me.getKey();

				if (dListener == null) {
					FxListenerNotFoundException exc = new FxListenerNotFoundException(
							"Listener for the caller id:" + callerId
									+ " found null");
					exc.setCmdID(cmdId);
					exc.setCallerID(callerId);
					exc.setCSID(csid);
					throw exc;
				}
				else
					break;
			}
		}
 		
		if(LOGV) FxLog.v(TAG, "getListener dListener is " + dListener);
		if(LOGV) FxLog.v(TAG, "getListener EXIT ....");
 		return dListener;
 	}
	
 	/**
 	 * Check whether request is in the queue still.
 	 * @param request to check
 	 * @return true if it's in the queue else false.
 	 */
	private boolean isQueuedRequest(DeliveryRequest request) {
		return (request.getDeliveryRequestType() == DeliveryRequestType.REQUEST_TYPE_NEW); 
	}	 
	
	/**
	 * Save a <code> DeliveryRequest <code> to persisted store
	 * @param request
	 */
	private void saveToPersistedStore(DeliveryRequest request) {
		removeDeliveryRequest(request);
		mPersistedStoreHelper.save(request);
	}	
	
	/**
	 * Get all the requests currently held in the queue.
	 * @return <code> List</code> of DeliveryRequest
	 */
	private List<DeliveryRequest> getAllRequestsInQueue() {
		DeliveryRequest[] tmp = new DeliveryRequest[mNewQueue.size()];
		mNewQueue.toArray(tmp);
		return Arrays.asList(tmp);
	}	
	
	/**
	 * Removes a <code>DeliveryRequest</code> from queue.
	 * @param deliveryRequest
	 */
	private void removeDeliveryRequest(DeliveryRequest deliveryRequest) {
		if(mNewQueue.contains(deliveryRequest))
			mNewQueue.remove(deliveryRequest);
	}

	/**
	 * Sort by priority and select the top most one
	 * @param list
	 * @return Higest priority one from the queue
	 */
	private DeliveryRequest getHighestPriorityDeliveryRequest(List<DeliveryRequest> list) {
		
		DeliveryRequest ret = null;
		DeliveryRequest topRequest = null;
		DeliveryRequest nextRequest = null;
		
		for(int i = 0; i < list.size(); i ++) {
			if( i == 0) {
				topRequest = list.get(i);
				ret = topRequest; 
			}
			else {
				nextRequest =  list.get(i);
				
				if(nextRequest.getRequestPriority().getNumber() > topRequest.getRequestPriority().getNumber()) {
					topRequest = nextRequest;
					ret = nextRequest;
				}
			}
		}
		 
		
		/*HashMap<DeliveryRequest, Integer> map = new HashMap<DeliveryRequest, Integer>();
		DeliveryRequest ret = null;
		int priority = -1;
		DeliveryRequest deliveryRequest = null;
		
		for (Iterator<DeliveryRequest> it = list.iterator(); it.hasNext();) {
			deliveryRequest = it.next();
			priority = deliveryRequest.getRequestPriority().getNumber();
			map.put(deliveryRequest, priority);
		}
		
		 
		
		HashMap<DeliveryRequest, Integer> priorityMap = (HashMap<DeliveryRequest, Integer>) MapUtil
				.sortByValueDesc(map);

		Collection<DeliveryRequest> c = priorityMap.keySet();
		Iterator<DeliveryRequest> itr = c.iterator();
		while (itr.hasNext()) {
			ret = itr.next();
			break;
		}*/

		return ret;
	}
	
	/**
	 *  Compare the base with the list and check whether list has higher priority requests
	 * @param baseDeliveryRequest
	 * @param listToCompare
	 * @return Null if not found a request with grater priority othewise grater priority request 
	 */
	private DeliveryRequest getHigherPriorityDeliveryRequest(DeliveryRequest baseDeliveryRequest, List<DeliveryRequest> listToCompare) {
		
		DeliveryRequest higherPriorityRequest = null;
		DeliveryRequest deliveryRequest = null;
		
		for (Iterator<DeliveryRequest> it = listToCompare.iterator(); it.hasNext();) {
			deliveryRequest = it.next();
			if(deliveryRequest.getRequestPriority().getNumber() > baseDeliveryRequest.getRequestPriority().getNumber()) {
				higherPriorityRequest = deliveryRequest;
				break;
			}
		}
		
		return higherPriorityRequest;
	}
	
	/**
	 * Add a listener and a caller id to the internal map. 
	 * @param listener
	 * @param callerID
	 * @throws FxNullNotAllowedException if the listener is null
	 */
	public void mapCallerIDAndListener(int callerID, DeliveryListener listener) 
			throws FxNullNotAllowedException {
		if(listener == null)
			throw new FxNullNotAllowedException("listener can not be null");
		mlistenerMap.put(listener, callerID);
	}
	
	/**
	 * Check for pending requests for a caller in the persist store
	 * @param callerId id of the caller.
	 * @return
	 */
	public boolean isRequestPending(int callerId) {
		return mPersistedStoreHelper.isRequestPending(callerId);
	}
	
	/**
	 * Make a request can be resume immediately
	 * @param cmdCode
	 */
	synchronized public boolean updateCanRetryWithCsid(long csid) {
		return mPersistedStoreHelper.updateRequestAsResumeableWithCsid(csid);
	}
	
	/**
	 * Make a request can be resume immediately
	 * @param cmdCode
	 */
	synchronized public boolean updateCanRetryWithCmdAndPriority(int cmd, PriorityRequest priority) {
		return mPersistedStoreHelper.updateRequestAsResumeable(cmd, priority);
	}
	
	/**
	 *  Written to support unit-test code ..
	 */
	public void clearStore() {
		mPersistedStoreHelper.clearStore();
		mNewQueue.clear();
		mlistenerMap.clear();
	}

}