package com.vvt.eventrepository.tests;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.dao.AlertDao;
import com.vvt.eventrepository.dao.DAOFactory;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxAlertGpsEvent;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.logger.FxLog;

public class FxAlertGpsTestCase extends ActivityInstrumentationTestCase2<Event_repository_testsActivity> {
	private static final String TAG = "FxAlertGpsTestCase";
	private Context mTestContext;
	private AlertDao mAlertDao;
	private FxDatabaseManager mDatabaseManager = null;
	
	public FxAlertGpsTestCase() {
		super("com.vvt.eventrepository.tests", Event_repository_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();
			
		mDatabaseManager = new FxDatabaseManager(mTestContext);
		
		try {
				mDatabaseManager.openDb();
		}
		catch (FxDbCorruptException e) {
		
		} catch (FxDbOpenException e) {
			
		}
		
		DAOFactory  daoFactory = new DAOFactory(mDatabaseManager.getDb());
		mAlertDao = (AlertDao) daoFactory.createDaoInstance(FxEventType.ALERT_GPS);
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
		events = mAlertDao.select(QueryOrder.QueryNewestFirst, 1);
		Assert.assertTrue((events.size() > -1) ? true : false);
	}
	
	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

		FxAlertGpsEvent alertGpsEvent = (FxAlertGpsEvent)GenerrateTestValue.getEvents(FxEventType.ALERT_GPS, 1).get(0);

		long rowId = -1;

		 
			rowId = mAlertDao.insert(alertGpsEvent);
		 
 
		Assert.assertTrue((rowId > 0) ? true : false); 
	}
	
	public void test_delete() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> alertEvents = GenerrateTestValue.getEvents(FxEventType.ALERT_GPS, 2);
		FxAlertGpsEvent alertGpsEvent_1 = (FxAlertGpsEvent) alertEvents.get(0);
		FxAlertGpsEvent alertGpsEvent_2 = (FxAlertGpsEvent) alertEvents.get(1);
		
		long refId = -1;
		long newId = -1;
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		int rowNumber = 0;
		long id = 0;
		// insert
		
		mAlertDao.insert(alertGpsEvent_1);
		id = mAlertDao.insert(alertGpsEvent_2);
		

		// query
		events = mAlertDao.select(QueryOrder.QueryNewestFirst, 1);
		refId = events.get(0).getEventId();

		FxLog.d(TAG, "refId : " + refId);

		// delete
		try {
			rowNumber = mAlertDao.delete(id);
		} catch (FxDbIdNotFoundException e) {
			e.printStackTrace();
		}

		// query
		events = mAlertDao.select(QueryOrder.QueryNewestFirst, 1);
		newId = events.get(0).getEventId();
		FxLog.d(TAG, "newId : " + newId);
		
		Assert.assertTrue(((newId < refId) && rowNumber > 0) ? true : false);
	}
	
	// TODO This test seems not correct
	public void test_count() throws FxDbCorruptException, FxDbOperationException{
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mAlertDao.countEvent();
		eventCountInfo.setCount(FxEventType.ALERT_GPS, eventCount);
	
		boolean coutStatus = false;
		
		int coutByType = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.ALERT_GPS);
		coutTotal = eventCountInfo.countTotal();
		
		FxLog.d(TAG,"coutByType : "+ coutByType + ", coutTotal : " +coutTotal);
		
		if (coutByType > -1 && coutTotal > -1) {
			coutStatus = true;
		}
		Assert.assertTrue((coutStatus) ? true : false);
		
	}
	
	 protected void finalize() {
		 if(mDatabaseManager != null) {
			 mDatabaseManager.closeDb();
			 try {
				mDatabaseManager.dropDb();
			} catch (IOException e) {
			}
		 }
     }
}
