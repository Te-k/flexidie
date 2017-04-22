package com.vvt.remotecommandmanager;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.eventrepository.DatabaseCorruptExceptionListener;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.eventrepository.RepositoryChangeListener;
import com.vvt.eventrepository.RepositoryChangePolicy;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.eventresult.EventKeys;
import com.vvt.eventrepository.eventresult.EventResultSet;
import com.vvt.eventrepository.querycriteria.EventQueryPriority;
import com.vvt.eventrepository.querycriteria.QueryCriteria;
import com.vvt.events.FxAlertGpsEvent;
import com.vvt.events.FxCallLogEvent;
import com.vvt.events.FxCameraImageEvent;
import com.vvt.events.FxCameraImageThumbnailEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxPanicStatusEvent;
import com.vvt.events.FxSMSEvent;
import com.vvt.events.FxSettingElement;
import com.vvt.events.FxSettingEvent;
import com.vvt.events.FxSystemEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbNotOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;
import com.vvt.exceptions.io.FxFileSizeNotAllowedException;
import com.vvt.logger.FxLog;

public class TEST_EventRepositoryMock implements FxEventRepository  {

	private static final String TAG = "EventRepositoryMock";
	DataProviderType dataProviderType;
	private int mRegularEventCountRound = 1;
	private int mPanicEventCountRound = 1;
	private int mSystemEventCountRound = 1;
	private int mSettingEventCountRound = 1;
	
	
	public TEST_EventRepositoryMock(DataProviderType dataProviderType) {
		this.dataProviderType = dataProviderType;
	}
	
	@Override
	public EventResultSet getRegularEvents(QueryCriteria criteria)
			throws FxNullNotAllowedException, FxNotImplementedException,
			FxDbNotOpenException, FxFileNotFoundException, FxDbOperationException {

		EventResultSet resultSet = new EventResultSet();
		List<FxEvent> myList = new ArrayList<FxEvent>();
		
		List<FxEventType> listType = criteria.getEventTypes();
		if (listType.size() < 1) {
			EventQueryPriority eventQueryPriority = new EventQueryPriority();
			listType = eventQueryPriority.getNormalPriorityEvents();
		}

		
		FxEvent event = null;
		
		if(dataProviderType == DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR) {
			if(mRegularEventCountRound < 3) {
				for(FxEventType e : listType) { 	
					event = mockFxEvent(e);
					if(event != null) {
						myList.add(event);
					}
				}
				mRegularEventCountRound++;
			} 
			
			resultSet.addEvents(myList);
		}
		
		if(dataProviderType == DataProviderType.DATA_PROVIDER_TYPE_PANIC) {
			for (FxEventType e : listType) {
				event = mockFxEvent(e);
				if (event != null) {
					myList.add(event);
				}
			}
			resultSet.addEvents(myList);
		}
		
		if(dataProviderType == DataProviderType.DATA_PROVIDER_TYPE_SYSTEM) {
			if(mSystemEventCountRound < 3) {
				for(FxEventType e : listType) { 
					event = mockFxEvent(e);
					if(event != null) {
						myList.add(event);
					}
				}
				mSystemEventCountRound++;
			} else {
				mSystemEventCountRound = 1;
			}
			resultSet.addEvents(myList);
		}
		
		if(dataProviderType == DataProviderType.DATA_PROVIDER_TYPE_SETTINGS) {
			if(mSettingEventCountRound < 3) {
				for(FxEventType e : listType) { 
					event = mockFxEvent(e);
					if(event != null) {
						myList.add(event);
					}
				}
				mSettingEventCountRound++;
			} else {
				mSettingEventCountRound = 1;
			}
			resultSet.addEvents(myList);
		}
		
		return resultSet;
	}
	
	private FxEvent mockFxEvent(FxEventType type) {
		
		FxEvent event = null;
		
		switch (type) {
			case CALL_LOG : 
				List<FxEvent> callEvents  = TEST_GenerrateTestValue.getEvents(
						FxEventType.CALL_LOG, 1);
				FxCallLogEvent call = (FxCallLogEvent) callEvents.get(0);
				call.setDirection(FxEventDirection.IN);
				call.setEventId(1);
				event = call;
				break;
			case SMS :
				List<FxEvent> smsEvents  = TEST_GenerrateTestValue.getEvents(
						FxEventType.SMS, 1);
				FxLog.d(TAG,smsEvents.toString());
				FxSMSEvent sms = (FxSMSEvent) smsEvents.get(0);
				sms.setDirection(FxEventDirection.IN);
				sms.setEventId(2);
				event = sms;
				break;
			case CAMERA_IMAGE_THUMBNAIL :
				List<FxEvent> thumbEvents  = TEST_GenerrateTestValue.getEvents(
						FxEventType.CAMERA_IMAGE_THUMBNAIL, 1);
				FxCameraImageThumbnailEvent thumb = (FxCameraImageThumbnailEvent) thumbEvents.get(0);
				thumb.setActualFullPath("actualFullPath");
				thumb.setEventId(3);
				thumb.setThumbnailFullPath("/sdcard/data/xxx.png");
				event = thumb;
				break;
			case PANIC_STATUS : 
				if(mPanicEventCountRound < 3) {
					List<FxEvent> statusEvents = TEST_GenerrateTestValue.getEvents(
							FxEventType.PANIC_STATUS, 1);
					FxPanicStatusEvent statusEvent = (FxPanicStatusEvent) statusEvents.get(0);
					statusEvent.setEventId(4);
					event = statusEvent;
					mPanicEventCountRound++;
				}
				break;
			case ALERT_GPS : 
				if(mPanicEventCountRound < 6) {
					List<FxEvent> alertEvents = TEST_GenerrateTestValue.getEvents(
							FxEventType.ALERT_GPS, 1);
					FxAlertGpsEvent gpsEvent = (FxAlertGpsEvent) alertEvents.get(0);
					gpsEvent.setEventId(5);
					event = gpsEvent;
					mPanicEventCountRound++;
				} else {
					mPanicEventCountRound = 1;
				}
				break;
			case SYSTEM :
				List<FxEvent> systemGpsEvents = TEST_GenerrateTestValue.getEvents(
						FxEventType.SYSTEM, 1);
				FxSystemEvent systemEvent = (FxSystemEvent) systemGpsEvents.get(0);
				systemEvent.setEventId(5);
				event = systemEvent;
				break;
			case SETTINGS :
				FxSettingEvent settingsEvent = new FxSettingEvent();
				settingsEvent.setEventId(6);
				settingsEvent.setEventTime(System.currentTimeMillis());
				settingsEvent.addSettingElement(new FxSettingElement());
				event = settingsEvent;
				break;
			default :
				break;
		}
		return event;
	}

	@Override
	public EventResultSet getMediaEvents(QueryCriteria criteria)
			throws FxNullNotAllowedException, FxNotImplementedException,
			FxFileNotFoundException, FxDbNotOpenException, FxDbCorruptException, FxDbOperationException {
		
		List<FxEvent> myList = null;
		
		if(dataProviderType == DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR) {
			final FxCameraImageThumbnailEvent thumb = new FxCameraImageThumbnailEvent();
			thumb.setActualFullPath("actualFullPath");
			thumb.setActualSize(100);
			thumb.setData(null);
			thumb.setEventId(1);
			thumb.setEventTime(100);
			thumb.setFormat(FxMediaType.AAC);
			thumb.setGeo(null);
			thumb.setParingId(100);
			thumb.setThumbnailFullPath("sssss");
			
			myList = new ArrayList<FxEvent>(Arrays.asList(thumb));
		}
		
		EventResultSet resultSet = new EventResultSet();
		resultSet.addEvents(myList);
		
		mRegularEventCountRound++;
		//finish test regular media and non media.
		if(mRegularEventCountRound > 6){
			resultSet = new EventResultSet();
			mRegularEventCountRound = 1;
		} 
		return resultSet;
		
		
	}
	
	@Override
	public FxEvent getActualMedia(long paringId)
			throws FxNotImplementedException, FxDbOperationException {

		FxLog.d(TAG,"paringId = "+ paringId);
		
		if(paringId >= 1 && paringId <= 50) {
			FxCameraImageEvent e = new FxCameraImageEvent();
			e.setEventId(paringId);
			e.setEventTime(0);
			e.setFileName("fileName");
			e.setFormat(FxMediaType.AAC_PLUS);
			e.setGeo(null);
			e.setImageData(null);
			e.setParingId(paringId);
			return e;
		}
		
		return null;
	}

	@Override
	public void insert(FxEvent events) throws FxNullNotAllowedException,
	FxDbNotOpenException, FxNotImplementedException, FxDbOperationException {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void insert(List<FxEvent> events) throws FxNullNotAllowedException,
	FxDbNotOpenException, FxNotImplementedException, FxDbOperationException {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void delete(EventKeys evKeys) throws FxDbNotOpenException,
	FxNotImplementedException, FxNullNotAllowedException,
	FxDbIdNotFoundException, FxDbOperationException {
		// TODO Auto-generated method stub
		
	}

	@Override
	public EventCountInfo getCount() throws FxNotImplementedException,
	FxDbNotOpenException, FxDbCorruptException, FxDbOperationException {
		return null;
	}

	@Override
	public int getTotalEventCount() throws FxDbNotOpenException, FxDbCorruptException, FxDbOperationException {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void addRepositoryChangeListener(RepositoryChangeListener listener,
			RepositoryChangePolicy policy) throws FxNullNotAllowedException {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void removeRepositoryChangeListener(RepositoryChangeListener listener) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void updateMediaThumbnailStatus(long id, boolean status)
			throws FxDbIdNotFoundException {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void addDatabaseCorruptExceptionListener(
			DatabaseCorruptExceptionListener listener) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void deleteActualMedia(long paringId)
			throws FxDbIdNotFoundException {
		// TODO Auto-generated method stub
		
	}

	@Override
	public FxEvent validateMedia(long paringId)
			throws FxNotImplementedException, FxDbOperationException,
			FxFileNotFoundException, FxDbIdNotFoundException,
			FxFileSizeNotAllowedException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getDBSize() {
		// TODO Auto-generated method stub
		return 0;
	}
		 
}