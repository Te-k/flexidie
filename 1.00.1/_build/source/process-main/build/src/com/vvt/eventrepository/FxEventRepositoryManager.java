package com.vvt.eventrepository;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import android.content.Context;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.dao.ActualMediaDao;
import com.vvt.eventrepository.dao.DAOFactory;
import com.vvt.eventrepository.dao.EventBaseCount;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.eventresult.EventKeys;
import com.vvt.eventrepository.eventresult.EventResultSet;
import com.vvt.eventrepository.querycriteria.EventQueryPriority;
import com.vvt.eventrepository.querycriteria.QueryCriteria;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.events.FxAudioConversationEvent;
import com.vvt.events.FxAudioConversationThumbnailEvent;
import com.vvt.events.FxAudioFileEvent;
import com.vvt.events.FxAudioFileThumnailEvent;
import com.vvt.events.FxCameraImageEvent;
import com.vvt.events.FxCameraImageThumbnailEvent;
import com.vvt.events.FxMediaType;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbNotOpenException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;
import com.vvt.exceptions.io.FxFileSizeNotAllowedException;
import com.vvt.logger.FxLog;

/**
 * @author aruna
 * @version 1.0
 * @created 01-Sep-2011 04:15:58
 */
public class FxEventRepositoryManager implements FxEventRepository {
	public static final String TAG = "FxEventRepositoryManager";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private FxDatabaseManager m_DatabaseManager;
	private EventQueryPriority m_EventQueryPriority;
	private RepositoryChangeMap m_RepositoryChangeMap;
	private DatabaseCorruptExceptionListener m_DatabaseCorruptExceptionListener;
	
	public FxEventRepositoryManager(Context context, String writablePath) {
		m_DatabaseManager = new FxDatabaseManager(context, writablePath);
		m_RepositoryChangeMap = new RepositoryChangeMap();
		m_EventQueryPriority = new EventQueryPriority();
	}
	
	public synchronized void setEventQueryPriority(EventQueryPriority defaultPriority) throws FxNullNotAllowedException {
		
		if(defaultPriority == null)
			throw new FxNullNotAllowedException("defaultPriority can not be null");
		
		m_EventQueryPriority = defaultPriority;
	}

	/**
	 * Open the repository for use.
	 * @throws FxDbOpenException If there are errors opening or creating the table structure
	 * @throws FxDbCorruptException If the database is corroupted
	 */
	public synchronized void openRepository() throws FxDbOpenException, FxDbCorruptException {
		m_DatabaseManager.openDb();
	}

	/**
	 * Close the repository
	 */
	public synchronized void closeRespository() {
		m_DatabaseManager.closeDb();
	}

	/**
	 * Deletes the repository from disk
	 * @throws IOException
	 */
	public synchronized void deleteRepository() throws IOException {
		m_DatabaseManager.dropDb();
	}

	public synchronized void clearRespository() { 
		DAOFactory factory = new DAOFactory(m_DatabaseManager.getDb());
		
		for (FxEventType eventType : FxEventType.values()) {
			try {
				factory.createDaoInstance(eventType).deleteAll();
			} catch (FxNotImplementedException e) {
				FxLog.e(TAG, e.toString());
			} catch (FxDbCorruptException e) {
				FxLog.e(TAG, e.toString());
			} catch (FxDbOperationException e) {
				FxLog.e(TAG, e.toString());
			}  catch (Throwable t) {
				FxLog.e(TAG, t.toString());
			}
		}
	}
	
	/**
	 * Insert a FxEvent to the repository.
	 * @param events List of events to insert.
	 * @throws FxNullNotAllowedException If a required parameter is null.
	 * @throws FxDbNotOpenException If the database is unavailable to read.
	 * @throws FxDbInsertException If there is an error inserting.
	 * @throws FxNotImplementedException If you try to insert into a class that does not support insert into database.
	 * @throws FxDbOperationException 
	 */
	@Override
	public synchronized void insert(FxEvent event) throws FxDbNotOpenException, FxNotImplementedException, FxNullNotAllowedException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG, "insert # START currentThread Id : " + Thread.currentThread().getId());
		
		verifyDatabaseIsOpened();
		
		if (event == null)
			throw new FxNullNotAllowedException("events can not be null");
		
		DAOFactory factory = new DAOFactory(m_DatabaseManager.getDb());
		try {
			long id = factory.createDaoInstance(event.getEventType()).insert(event);
			if(LOGV) FxLog.v(TAG, "insert #  Row Id : " + id +  " insert : " + event.toString());
			
		} catch (FxDbCorruptException cex) {
			if(m_DatabaseCorruptExceptionListener != null) {
				m_DatabaseCorruptExceptionListener.onCorrupt();
			}
			else {
				throw new FxDbOperationException(cex.getMessage());
			}
		}
				
		triggerListers(event);
		if(LOGV) FxLog.v(TAG, "insert # EXIT currentThread Id : " + Thread.currentThread().getId());
	}

	/**
	 * Insert a list of <code>FxEvent</code> to repository.
	 * @param events List of events to insert.
	 * @throws FxNullNotAllowedException If a required parameter is null.
	 * @throws FxDbNotOpenException If the database is unavailable to read.
	 * @throws FxDbInsertException If there is an error inserting.
	 * @throws FxNotImplementedException If you try to insert into a class that does not support insert into database.
	 * @throws FxDbOperationException 
	 */
	@Override
	public synchronized void insert(List<FxEvent> events)
			throws FxNullNotAllowedException, FxNotImplementedException,
			FxDbNotOpenException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG, "List insert # START currentThread Id : " + Thread.currentThread().getId());

		verifyDatabaseIsOpened();

		if (events == null)
			throw new FxNullNotAllowedException("events can not be null");
		
		for (FxEvent fxevent : events) {
			if(LOGV) FxLog.v(TAG, "# insert : " + fxevent.toString());

			insert(fxevent);
			
			// TODO: fail retry to be implemented.
		}
		
		if(LOGV) FxLog.v(TAG, "List insert # EXIT currentThread Id : " + Thread.currentThread().getId());
	}
	
	/**
	 * Delete records from repository
	 * @param evKeys 
	 * @throws FxDbNotOpenException
	 * @throws FxNotImplementedException
	 * @throws FxDbIdNotFoundException 
	 * @throws FxDbOperationException 
	 */
	@Override
	public synchronized void delete(EventKeys evKeys)
			throws FxDbNotOpenException, FxNotImplementedException,
			FxNullNotAllowedException, FxDbIdNotFoundException,
			FxDbOperationException {
		
		if(LOGV) FxLog.v(TAG, "delete START # currentThread Id : " + Thread.currentThread().getId());
		
		if (evKeys == null)
			throw new FxNullNotAllowedException("evKeys can not be null");

		verifyDatabaseIsOpened();
		 
//		synchronized (m_DatabaseManager) {
			DAOFactory factory = new DAOFactory(m_DatabaseManager.getDb());
			if(LOGV) FxLog.v(TAG, "factory created!");

			try {
				for (FxEventType eventType : evKeys.getKeys()) {
					if(LOGV) FxLog.v(TAG, "eventType :" + eventType.getNumber());
					
					List<Long> ids = evKeys.getEventIDs(eventType);
					if(LOGV) FxLog.v(TAG, "Deleteing id count :" + ids.size());
					
					for (long id : ids) {
						if(LOGV) FxLog.v(TAG, "Deleteing ID :" + id);
						
						factory.createDaoInstance(eventType).delete(id);
						int deletCount = factory.createDaoInstance(FxEventType.EVENT_BASE).delete(id);
						
						if(LOGV) FxLog.d(TAG, deletCount + " were deleted!");
					}
				}
				
			} catch (FxDbCorruptException cex) {
				if (m_DatabaseCorruptExceptionListener != null) {
					m_DatabaseCorruptExceptionListener.onCorrupt();
				} else {
					throw new FxDbOperationException(cex.getMessage());
				}
			}
//		}

		if(LOGV) FxLog.v(TAG, "delete EXIT # currentThread Id : " + Thread.currentThread().getId());
	}

	/**
	 * @throws FxDbOperationException 
	 * @throws FxDbIdNotFoundException 
	 * Update Media Thumbail status as Sent to server.
	 * @throws  
	 */
	@Override
	public synchronized void updateMediaThumbnailStatus(long id, boolean isDelivered) throws FxDbIdNotFoundException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG, "updateMediaThumbnailStatus START # currentThread Id : " + Thread.currentThread().getId());
		if(LOGV) FxLog.v(TAG, "updateMediaThumbnailStatus # id : " + id + " isDelivered : " + isDelivered);
		
		DAOFactory factory = new DAOFactory(m_DatabaseManager.getDb());
		ActualMediaDao dao = (ActualMediaDao)factory.createDaoInstance(FxEventType.ACTUAL_MEDIA_DAO);
		
		try {
			dao.update(id, isDelivered);
		}
		catch(FxDbCorruptException cex) {
			if(m_DatabaseCorruptExceptionListener != null) {
				m_DatabaseCorruptExceptionListener.onCorrupt();
			}
			else {
				throw new FxDbOperationException(cex.getMessage());
			}	
		}	
		
		if(LOGV) FxLog.v(TAG, "updateMediaThumbnailStatus EXIT # currentThread Id : " + Thread.currentThread().getId());
	}
	
	/**
	 * Returns a EventResultSet of regular events based on <code>QueryCriteria</code> Default priority event types are
	 * @param criteria denotes a data selection criteria 
	 * <code>
	 * CALL_LOG, SMS, MAIL, MMS, IM, LOCATION, CELL_INFO, DEBUG_EVENT, SIM_CHANGE
	 * </code>
	 * @throws FxDbOperationException 
	 */
	@Override
	public synchronized EventResultSet getRegularEvents(QueryCriteria criteria)
			throws FxNullNotAllowedException, FxNotImplementedException, FxDbNotOpenException, FxFileNotFoundException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG, "getRegularEvents # ENTER  Thread Id : " + Thread.currentThread().getId());
		
		// validate all the parameter are set, if not throw exception
		verifyDatabaseIsOpened();
		verifyQueryCriteria(criteria);
	
		List<FxEventType> eventTypes = criteria.getEventTypes();
		
		if(eventTypes.size() == 0)
			eventTypes = m_EventQueryPriority.getNormalPriorityEvents();
		else {
			// User has set the types, prioritise the list based on our proitiry definition.
			eventTypes = m_EventQueryPriority.prioritise(eventTypes);
		}
		
		EventResultSet eventResultSet =  getEvents(criteria, eventTypes);
		if(LOGV) FxLog.v(TAG, "getRegularEvents # EXIT  Thread Id : " + Thread.currentThread().getId());
		return eventResultSet;
	}

	/**
	 * Returns a EventResultSet of media events based on <code>QueryCriteria</code> Default priority event types are
	 *  <code>
	 * ADDRESS_BOOK, WALLPAPER_THUMBNAIL, CAMERA_IMAGE_THUMBNAIL, AUDIO_CONVERSATION_THUMBNAIL, AUDIO_FILE_THUMBNAIL
	 * VIDEO_FILE_THUMBNAIL, WALLPAPER, CAMERA_IMAGE, AUDIO_CONVERSATION, AUDIO_FILE, VIDEO_FILE
	 * </code>
	 * @param criteria denotes a data selection criteria
	 * @throws FxDbNotOpenException 
	 * @throws FxDbOperationException 
	 * @throws FxDbCorruptException 
	 */
	@Override
	public synchronized EventResultSet getMediaEvents(QueryCriteria criteria)
			throws FxNullNotAllowedException, FxNotImplementedException, FxFileNotFoundException, FxDbNotOpenException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG, "getMediaEvents # ENTER Thread Id : " + Thread.currentThread().getId());
		
		// validate all the parameter are set, if not throw exception
		verifyDatabaseIsOpened();
		verifyQueryCriteria(criteria);
	
		List<FxEventType> eventTypes = criteria.getEventTypes();
		
		if(eventTypes.size() == 0)
			eventTypes = m_EventQueryPriority.getLowPriorityEvents();
		else {
			// User has set the types, prioritise the list based on our proitiry
			// definition.
			eventTypes = m_EventQueryPriority.prioritise(eventTypes);
		}
	
		EventResultSet eventResultSet  = getEvents(criteria, eventTypes);
		
		if(LOGV) FxLog.v(TAG, "getMediaEvents # ENTER Thread Id : " + Thread.currentThread().getId());
		return eventResultSet;
	}

	/**
	 * get a actual media event
	 * @param int Id (pairing id) of the original image.
	 * @throws FxDbInsertException 
	 * @throws FxNotImplementedException 
	 * @throws FxDbOperationException 
	 * @throws FxDbCorruptException 
	 * @throws FxFileSizeNotAllowedException 
	 * @throws FxDbIdNotFoundException 
	 * @throws FxFileNotFoundException 
	 */
	@Override
	public synchronized FxEvent getActualMedia(long paringId) throws FxNotImplementedException, FxDbOperationException{
		if(LOGV) FxLog.v(TAG, "getActualMedia # ENTER Thread Id : " + Thread.currentThread().getId());
		if(LOGD) FxLog.d(TAG, "getActualMedia # paringId : "  + paringId);
		
		
		FxEvent retEvent = null;
		DAOFactory factory = new DAOFactory(m_DatabaseManager.getDb());
		ActualMediaDao dao = (ActualMediaDao)factory.createDaoInstance(FxEventType.ACTUAL_MEDIA_DAO);
		
		try	 {
			retEvent = dao.select(paringId);
			
			if(retEvent == null) {
				if(LOGE) FxLog.e(TAG, "getActualMedia # retEvent is null");
			}
			else {
				if(LOGV) FxLog.v(TAG, "getActualMedia # retEvent is "+ retEvent.toString());
			}
			
		}
		/* NOTE: These errors are checked in RCM and insert a system event We just need to create a dummy
		 * and send to server */
		catch(FxDbIdNotFoundException dbIdNotFoundException) {
			if(LOGE) FxLog.e(TAG, dbIdNotFoundException.toString());
			retEvent = getEmptyAudioEvent(paringId);
		}
		catch (FxFileSizeNotAllowedException fileSizeNotAllowedException) {
			if(LOGE) FxLog.e(TAG, fileSizeNotAllowedException.toString());
			retEvent = getEmptyAudioEvent(paringId);
		}
		catch(FxFileNotFoundException fileNotFoundException) {
			if(LOGE) FxLog.e(TAG, fileNotFoundException.toString());
			// Return 0 size to indicate file not available to the server. 
			retEvent = getEmptyAudioEvent(paringId);
		}
		catch (FxDbCorruptException cex) {
			if(LOGE) FxLog.e(TAG, cex.toString());
			
			if(m_DatabaseCorruptExceptionListener != null) {
				m_DatabaseCorruptExceptionListener.onCorrupt();
			}
			else {
				throw new FxDbOperationException(cex.getMessage());
			}
		}
		
		if(LOGV) FxLog.v(TAG, "getActualMedia # EXIT Thread Id : " + Thread.currentThread().getId());
		return retEvent;
	}
	
	@Override
	public synchronized void deleteActualMedia(long paringId) throws FxDbIdNotFoundException {
		if(LOGV) FxLog.v(TAG, "deleteActualMedia # START Thread Id : " + Thread.currentThread().getId());
		if(LOGV) FxLog.v(TAG, "deleteActualMedia # paringId : " + paringId);
		
		DAOFactory factory = new DAOFactory(m_DatabaseManager.getDb());
		ActualMediaDao dao = (ActualMediaDao)factory.createDaoInstance(FxEventType.ACTUAL_MEDIA_DAO);
		FxEvent e;
		
		try {
			e = dao.select(paringId);
			String fileName = null;
			
			if(e.getEventType() == FxEventType.AUDIO_CONVERSATION) {
				FxAudioConversationEvent event = (FxAudioConversationEvent)e;
				fileName = event.getFileName();
				
			} else if (e.getEventType() == FxEventType.AUDIO_CONVERSATION_THUMBNAIL) {
				FxAudioConversationThumbnailEvent event = (FxAudioConversationThumbnailEvent)e;
				fileName = event.getActualFullPath();
				
			} else if (e.getEventType() == FxEventType.AUDIO_FILE) {
				FxAudioFileEvent event = (FxAudioFileEvent)e;
				fileName = event.getFileName();
				
			} else if (e.getEventType() == FxEventType.AUDIO_FILE_THUMBNAIL) {
				FxAudioFileThumnailEvent event  = (FxAudioFileThumnailEvent)e;
				fileName = event.getActualFullPath();
				
			} else if (e.getEventType() == FxEventType.CAMERA_IMAGE) {
				FxCameraImageEvent event  = (FxCameraImageEvent)e;
				fileName = event.getFileName();
				
			} else if (e.getEventType() == FxEventType.CAMERA_IMAGE_THUMBNAIL) {
				FxCameraImageThumbnailEvent event  = (FxCameraImageThumbnailEvent)e;
				fileName = event.getActualFullPath();
			}
			
			if(fileName != null) {
				File f = new File(fileName);
				
				if(f.exists()) {
					f.delete();
				}	
			}
		
		} catch (FxFileNotFoundException e1) {
			if(LOGE) FxLog.e(TAG, e1.getMessage());
		} catch (FxFileSizeNotAllowedException e1) {
			if(LOGE) FxLog.e(TAG, e1.getMessage()); 
		}
		catch (FxDbCorruptException e1) {
			if (m_DatabaseCorruptExceptionListener != null) {
				m_DatabaseCorruptExceptionListener.onCorrupt();
			} else {
				if(LOGE) FxLog.e(TAG, e1.getMessage());
			}
		} catch (FxDbOperationException e1) {
			if(LOGE) FxLog.e(TAG, e1.getMessage());
		}
		
		dao.delete(paringId);
		
		if(LOGV) FxLog.v(TAG, "deleteActualMedia # EXIT Thread Id : " + Thread.currentThread().getId());
	}
	
	@Override
	public synchronized FxEvent validateMedia(long paringId)
			throws FxNotImplementedException, FxDbOperationException,
			FxFileNotFoundException, FxDbIdNotFoundException,
			FxFileSizeNotAllowedException {
		if(LOGV) FxLog.v(TAG, "validateMedia # START Thread Id : " + Thread.currentThread().getId());
		
		DAOFactory factory = new DAOFactory(m_DatabaseManager.getDb());
		ActualMediaDao dao = (ActualMediaDao)factory.createDaoInstance(FxEventType.ACTUAL_MEDIA_DAO);
		FxEvent retEvent = null;
		
		try	 {
			retEvent = dao.select(paringId);
		}
		catch (FxDbCorruptException cex) {
			if(LOGE) FxLog.e(TAG, cex.getMessage());
			
			if(m_DatabaseCorruptExceptionListener != null) {
				m_DatabaseCorruptExceptionListener.onCorrupt();
			}
			else {
				throw new FxDbOperationException(cex.getMessage());
			}
		}
		
		if(LOGV) FxLog.v(TAG, "validateMedia # EXIT Thread Id : " + Thread.currentThread().getId());
		return retEvent;
	}
	
	
	private synchronized FxAudioFileEvent getEmptyAudioEvent(long paringId) {
		if(LOGV) FxLog.v(TAG, "getEmptyAudioEvent # START Thread Id : " + Thread.currentThread().getId());
		
		FxAudioFileEvent ae = new FxAudioFileEvent();
		ae.setFormat(FxMediaType.UNKNOWN);
		ae.setParingId(paringId);
		ae.setEventTime(new Date().getTime());
		
		if(LOGV) FxLog.v(TAG, "getEmptyAudioEvent # EXIT Thread Id : " + Thread.currentThread().getId());
		return ae;
	}

	@Override
	public synchronized int getTotalEventCount() throws FxDbNotOpenException, FxDbOperationException  {
		if(LOGV) FxLog.v(TAG, "getTotalEventCount # START Thread Id : " + Thread.currentThread().getId());
		
		verifyDatabaseIsOpened();
			
		EventBaseCount dao = new EventBaseCount(m_DatabaseManager.getDb());
		int totalEventCount = -1;
		
		try {
			totalEventCount = dao.getTotalEventCount();
		} catch (FxDbCorruptException cex) {
			if (m_DatabaseCorruptExceptionListener != null) {
				m_DatabaseCorruptExceptionListener.onCorrupt();
			} else {
				throw new FxDbOperationException(cex.getMessage());
			}
		}

		if(LOGV) FxLog.v(TAG, "getTotalEventCount # EXIT Thread Id : " + Thread.currentThread().getId());
		return totalEventCount;
	}

	/**
	 * Returns <code>EventCountInfo</code> which contains underlaying database table row counts.
	 * @throws FxDbNotOpenException If the database is unavailable to count. 
	 * @throws FxDbOperationException 
	 * @throws FxDbCorruptException 
	 */
	@Override
	public synchronized EventCountInfo getCount() throws FxDbNotOpenException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG, "getCount # START Thread Id : " + Thread.currentThread().getId());
		
		verifyDatabaseIsOpened();
		
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventBaseCount eventBaseCount = new EventBaseCount(m_DatabaseManager.getDb());
		EventCount detailedCount = new EventCount();
	
		try{
			for (FxEventType eventType : FxEventType.values()) {
				detailedCount = eventBaseCount.countEvent(eventType);
				eventCountInfo.setCount(eventType, detailedCount);
			}
		} catch (FxDbCorruptException cex) {
			if (m_DatabaseCorruptExceptionListener != null) {
				m_DatabaseCorruptExceptionListener.onCorrupt();
			} else {
				throw new FxDbOperationException(cex.getMessage());
			}
		}
	
		if(LOGV) FxLog.v(TAG, "getCount # EXIT Thread Id : " + Thread.currentThread().getId());
		return eventCountInfo;
	}

	/**
	 * Add a repository change listner. 
	 * 
	 * @param listener Listner to notify on change
	 * @param policy defines the notification criteria
	 * @throws FxNullNotAllowedException if any required parameters are null
	 */
	@Override
	public synchronized void addRepositoryChangeListener(RepositoryChangeListener lister, RepositoryChangePolicy policy) throws FxNullNotAllowedException {
		if(lister == null)
			throw new FxNullNotAllowedException("RepositoryChangeListener can not be null");
		
		if(policy == null)
			throw new FxNullNotAllowedException("RepositoryChangePolicy can not be null");
		
		if(policy.getChangeEvent().size() <= 0)
			throw new FxNullNotAllowedException("RepositoryChangePolicy should contain one or more RepositoryChangeEvents");
		
		// If the lister type is a MAX event listner, make sure MaxNoOfEvents are defied.
		HashSet<RepositoryChangeEvent> policies = policy.getChangeEvent();
		if( policies.contains(RepositoryChangeEvent.EVENT_REACH_MAX_NUMBER)  && policy.getMaxEventNumber() == 0) {
			throw new FxNullNotAllowedException("policy set to EVENT_REACH_MAX_NUMBER but MaxEventNumber not set");
		}
		 
		m_RepositoryChangeMap.addListnerPolicy(lister, policy);
	}

	/**
	 * Removes a repository change notification listner
	 * @param listener to be removed.
	 */
	@Override
	public synchronized void removeRepositoryChangeListener(RepositoryChangeListener listener) {
		if(listener != null)
			m_RepositoryChangeMap.removeListnerPolicy(listener);
	}

	private EventResultSet getEvents(QueryCriteria criteria, List<FxEventType> eventTypes)
			throws FxNullNotAllowedException, FxNotImplementedException, FxFileNotFoundException, FxDbOperationException  {
		if(LOGV) FxLog.v(TAG, "getEvents # START Thread Id : " + Thread.currentThread().getId());
		
		
		int limit = criteria.getLimit();
		QueryOrder order = criteria.getQueryOrder();
		DAOFactory factory = new DAOFactory(m_DatabaseManager.getDb());
		List<FxEvent> totalEvents = new ArrayList<FxEvent>();
		List<FxEvent> result = null;
	
		try {
			// query each type that's defined in the evet types
			for (FxEventType eventType : eventTypes) {
				result = factory.createDaoInstance(eventType).select(order, limit);
				totalEvents.addAll(result);
		
				// calculate the remaning count
				limit -= result.size();
		
				if (limit <= 0)
					break;
			}
		} catch (FxDbCorruptException cex) {
			if (m_DatabaseCorruptExceptionListener != null) {
				m_DatabaseCorruptExceptionListener.onCorrupt();
			} else {
				throw new FxDbOperationException(cex.getMessage());
			}
		}
		
	
		EventResultSet resultSet = new EventResultSet();
		resultSet.addEvents(totalEvents);
		
		if(LOGV) FxLog.v(TAG, "getEvents # EXIT Thread Id : " + Thread.currentThread().getId());
		return resultSet;
	}

	/**
	 * Get all types of <code>RepositoryChangeEvent</code> and check whether they need to be notified.
	 * @param fxevent
	 * @throws FxNotImplementedException If the <code>RepositoryChangeEvent</code> not defined.
	 * @throws FxDbNotOpenException If the database is unavailable.
	 * @throws FxDbOperationException 
	 */
	private void triggerListers(FxEvent fxevent) throws FxNotImplementedException, FxDbNotOpenException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG, "triggerListers # ENTER Thread Id : " + Thread.currentThread().getId());
		
		// List of listners thats need to be informed.
		HashMap<RepositoryChangeEvent, List<RepositoryChangeListener>> listners = new HashMap<RepositoryChangeEvent, List<RepositoryChangeListener>>();
	
		// Notify listeners listening to each type of change
		for (RepositoryChangeEvent eventType : RepositoryChangeEvent.values()) {
			 
			if (eventType == RepositoryChangeEvent.EVENT_ADD) {
				List<RepositoryChangeListener> addListners = m_RepositoryChangeMap.getListeners(eventType);
				
				if (addListners.size() > 0) {
					if(LOGV) FxLog.v(TAG, "triggerListers # listners count: " +  addListners.size() + " eventType :" + eventType);
					listners.put(eventType, addListners);
				}
				
			} else if (eventType == RepositoryChangeEvent.EVENT_REACH_MAX_NUMBER) {
				int totalCount = getTotalEventCount();
				
				List<RepositoryChangeListener> maxListners = m_RepositoryChangeMap
						.getListeners(RepositoryChangeEvent.EVENT_REACH_MAX_NUMBER, totalCount);
				
				if (maxListners.size() > 0) {
					if(LOGV) FxLog.v(TAG, "triggerListers # listners count: " +  maxListners.size() + " eventType :" + eventType);
					listners.put(eventType, maxListners);
				}
	
			} else if (eventType == RepositoryChangeEvent.PANIC_EVENT_ADD) {
				if (fxevent.getEventType() == FxEventType.ALERT_GPS
						|| fxevent.getEventType() == FxEventType.PANIC_IMAGE
						|| fxevent.getEventType() == FxEventType.PANIC_STATUS
						|| fxevent.getEventType() == FxEventType.PANIC_GPS) {
					List<RepositoryChangeListener> addListners = m_RepositoryChangeMap.getListeners(eventType);
					
					if(LOGV) FxLog.v(TAG, "triggerListers # listners count: " +  addListners.size() + " eventType :" + eventType);
					listners.put(eventType, addListners);
				}
			} else if (eventType == RepositoryChangeEvent.SYSTEM_EVENT_ADD) {
				if (fxevent.getEventType() == FxEventType.SYSTEM) {
					List<RepositoryChangeListener> addListners = m_RepositoryChangeMap.getListeners(eventType);
					
					if(LOGV) FxLog.v(TAG, "triggerListers # listners count: " +  addListners.size() + " eventType :" + eventType);
					listners.put(eventType, addListners);
				}
			} else if(eventType == RepositoryChangeEvent.SETTING_EVENT_ADD) { 
				if (fxevent.getEventType() == FxEventType.SETTINGS) {
					List<RepositoryChangeListener> addListners = m_RepositoryChangeMap.getListeners(eventType);
					
					if(LOGV) FxLog.v(TAG, "triggerListers # listners count: " +  addListners.size() + " eventType :" + eventType);
					listners.put(eventType, addListners);
				}
			} else {
				throw new FxNotImplementedException("Listner type:"  + eventType + " not found!");
			}
		}
		
		if(LOGV) FxLog.v(TAG, "triggerListers # listners count: " +  listners.size());
	
		// notify listners thats listening to above
		notifyListeners(listners);
		
		if(LOGV) FxLog.v(TAG, "triggerListers # EXIT Thread Id : " + Thread.currentThread().getId());
	}

	/**
	 * Notify a listner
	 * @param listners Listners and their types
	 */
	private void notifyListeners(HashMap<RepositoryChangeEvent, List<RepositoryChangeListener>> listners) {
		Set<Entry<RepositoryChangeEvent, List<RepositoryChangeListener>>> set = listners.entrySet(); 
		Iterator<Entry<RepositoryChangeEvent, List<RepositoryChangeListener>>> i = set.iterator(); 
		
		if(LOGV) FxLog.v(TAG, "notifyListeners # START Thread Id : " + Thread.currentThread().getId());
		
		while(i.hasNext()) { 
			Map.Entry<RepositoryChangeEvent, List<RepositoryChangeListener>> me = i.next(); 
			RepositoryChangeEvent eventType =  me.getKey();
		 
			List<RepositoryChangeListener> listnersList =  me.getValue();
			
			if(eventType == RepositoryChangeEvent.EVENT_ADD) {
				for(RepositoryChangeListener e: listnersList) {
					
					if(LOGV) FxLog.v(TAG, "notifyListeners # onEventAdd");
					e.onEventAdd();
				}
			} else if (eventType == RepositoryChangeEvent.EVENT_REACH_MAX_NUMBER) {
				for(RepositoryChangeListener e: listnersList) {

					if(LOGV) FxLog.v(TAG, "notifyListeners # notifying " + e.toString() + " onReachMaxEventNumber");
					e.onReachMaxEventNumber();
				}
			} else if (eventType == RepositoryChangeEvent.PANIC_EVENT_ADD) {
				for(RepositoryChangeListener e: listnersList) {
					
					if(LOGV) FxLog.v(TAG, "notifyListeners # notifying " + e.toString() + " onPanicEventAdd");
					e.onPanicEventAdd();
				}
				
			} else if (eventType == RepositoryChangeEvent.SYSTEM_EVENT_ADD) {
				for(RepositoryChangeListener e: listnersList) {
					
					if(LOGV) FxLog.v(TAG, "notifyListeners # notifying " + e.toString() + " onSystemEventAdd");
					e.onSystemEventAdd();
				}
			} else if (eventType == RepositoryChangeEvent.SETTING_EVENT_ADD) {
				for(RepositoryChangeListener e: listnersList) {
					
					if(LOGV) FxLog.v(TAG, "notifyListeners # onSettingEventAdd");
					e.onSettingEventAdd();
				}
			}
		}
		
		if(LOGV) FxLog.v(TAG, "notifyListeners # EXIT Thread Id : " + Thread.currentThread().getId());
	}

	private void verifyDatabaseIsOpened() throws FxDbNotOpenException {
		if(!m_DatabaseManager.isDbOpen())
			throw new FxDbNotOpenException("Database is closed. call openRepository to open the database before calling this method");
	}

	private void verifyQueryCriteria(QueryCriteria criteria) throws FxNullNotAllowedException {
		if(criteria == null)
			 throw new FxNullNotAllowedException("criteria can not be null");
		 
		 int rowLimit = criteria.getLimit();
		 
		 if(rowLimit<=0)
			 throw new FxNullNotAllowedException("EventTypes in QueryCriteria in can not be null");
		 
		 if(rowLimit > 200)
			 throw new FxNullNotAllowedException("Limit can not be more than 200");
		 
	}

	@Override
	public synchronized void addDatabaseCorruptExceptionListener(DatabaseCorruptExceptionListener listener) {
		m_DatabaseCorruptExceptionListener = listener;
	}

	@Override
	public synchronized long getDBSize() {
		return m_DatabaseManager.getDBSize();
	}
}