package com.vvt.eventrepository.tests;

import java.util.ArrayList;
import java.util.List;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.dao.CallLogDao;
import com.vvt.eventrepository.dao.DAOFactory;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxCallLogEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;

public class FxCallLogDaoTestCase extends ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private Context mTestContext;
	private CallLogDao mCallLogDao;
	private FxDatabaseManager mDatabaseManager = null;
	
	public FxCallLogDaoTestCase() {
		super("com.vvt.eventrepository.tests", Event_repository_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();		
		
		mDatabaseManager = new FxDatabaseManager(mTestContext);
		 
			try {
				mDatabaseManager.openDb();
				mDatabaseManager.getDb().acquireReference();
				
			} catch (FxDbOpenException e) {
				Assert.fail(e.toString());
			} catch (FxDbCorruptException e) {
				Assert.fail(e.toString());
			}
		 
		DAOFactory  daoFactory = new DAOFactory(mDatabaseManager.getDb());
		mCallLogDao = (CallLogDao) daoFactory.createDaoInstance(FxEventType.CALL_LOG);
	}

	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}

	public void setTestContext(Context context) {
		mTestContext = context;
	}

	public Context getTestContext() {
		return mTestContext;
	}
	
	
	public void test_query() throws FxDbCorruptException, FxDbOperationException {

		
		List<FxEvent> events = new ArrayList<FxEvent>();

		events = mCallLogDao.select(QueryOrder.QueryNewestFirst,1);
			
		Assert.assertTrue((events.size() > -1) ? true : false);
	}
	
	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

//		FxCallLogEvent callLogEvent = new FxCallLogEvent();
//		callLogEvent.setContactName("Kitaro_nu");
//		callLogEvent.setDirection(FxEventDirection.IN);
//		callLogEvent.setDuration(60000);
//		callLogEvent.setNumber("0866205848");
//		callLogEvent.setEventTime(System.currentTimeMillis());
		
		List<FxEvent> callLog = GenerrateTestValue.getEvents(FxEventType.CALL_LOG, 1);
		FxCallLogEvent callLog_1 = (FxCallLogEvent) callLog.get(0);
		
		
		long rowId = 0;
		
 
			rowId = mCallLogDao.insert(callLog_1);
		 
		
		Assert.assertTrue((rowId > 0) ? true : false);
	}
	
	
	public void test_delete() throws FxDbCorruptException, FxDbOperationException {

//		FxCallLogEvent callLogEvent = new FxCallLogEvent();
//		callLogEvent.setContactName("Kitaro_nu");
//		callLogEvent.setDirection(FxEventDirection.OUT);
//		callLogEvent.setDuration(60000);
//		callLogEvent.setNumber("0866205848");
//		callLogEvent.setEventTime(System.currentTimeMillis());
		
		List<FxEvent> callLog = GenerrateTestValue.getEvents(FxEventType.CALL_LOG, 2);
		FxCallLogEvent callLog_1 = (FxCallLogEvent) callLog.get(0);
		FxCallLogEvent callLog_2 = (FxCallLogEvent) callLog.get(1);

		long refId = -1;
		long newId = -1;
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		int rowNumber = 0;
		
		long id = 0;
		// insert
 
			mCallLogDao.insert(callLog_1);
			id = mCallLogDao.insert(callLog_2);
		 
		

		// query
		events = mCallLogDao.select(QueryOrder.QueryNewestFirst, 1);
		refId = events.get(0).getEventId();

		// delete
		try {
			rowNumber = mCallLogDao.delete(id);
		} catch (FxDbIdNotFoundException e) {
			e.printStackTrace();
		}

		// query
		events = mCallLogDao.select(QueryOrder.QueryNewestFirst, 1);
		newId = events.get(0).getEventId();
			
		
		
		Assert.assertTrue(((newId < refId) && rowNumber > 0) ? true : false);
	}
	
	public void test_count() throws FxDbCorruptException, FxDbOperationException{
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mCallLogDao.countEvent();
		eventCountInfo.setCount(FxEventType.CALL_LOG, eventCount);
		

		boolean coutStatus = false;
		
		int coutByType = -1;
		int coutByDirection = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.CALL_LOG);
		coutByDirection = eventCountInfo.count(FxEventType.CALL_LOG,FxEventDirection.IN);
		coutTotal = eventCountInfo.countTotal();
		
		if (coutByType > -1 && coutByDirection > -1 && coutTotal > -1) {
			coutStatus = true;
		}
		Assert.assertTrue((coutStatus) ? true : false);
		
	}

}
