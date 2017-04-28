package com.vvt.eventrepository.tests;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.dao.DAOFactory;
import com.vvt.eventrepository.dao.PanicGpsDao;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxPanicGpsEvent;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.logger.FxLog;

public class FxPanicGpsTestCase extends
		ActivityInstrumentationTestCase2<Event_repository_testsActivity> {
	private static final String TAG = "FxPanicGpsTestCase";
	private Context mTestContext;
	private PanicGpsDao mPanicGpsDao;
	private FxDatabaseManager mDatabaseManager = null;

	public FxPanicGpsTestCase() {
		super("com.vvt.eventrepository.tests",
				Event_repository_testsActivity.class);
	}

	@Override
	protected void setUp() throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();

		mDatabaseManager = new FxDatabaseManager(mTestContext);

		 
		try {
			mDatabaseManager.openDb();
		} catch (FxDbOpenException e) {
			Assert.fail(e.toString());
		} catch (FxDbCorruptException e) {
			Assert.fail(e.toString());
		}
		 
		DAOFactory daoFactory = new DAOFactory(mDatabaseManager.getDb());
		mPanicGpsDao = (PanicGpsDao) daoFactory
				.createDaoInstance(FxEventType.PANIC_GPS);
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
		events = mPanicGpsDao.select(QueryOrder.QueryNewestFirst, 1);
		Assert.assertTrue((events.size() > -1) ? true : false);
	}

	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> panicGpsEvent = GenerrateTestValue.getEvents(
				FxEventType.PANIC_GPS, 1);
		FxPanicGpsEvent panicGpsEvent_1 = (FxPanicGpsEvent) panicGpsEvent
				.get(0);

		FxLog.d(TAG, panicGpsEvent_1.toString());

		long rowId = -1;

		rowId = mPanicGpsDao.insert(panicGpsEvent_1);

		Assert.assertTrue((rowId > 0) ? true : false);
	}

	public void test_delete() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> panicGpsEvent = GenerrateTestValue.getEvents(
				FxEventType.PANIC_GPS, 2);
		FxPanicGpsEvent panicGpsEvent_1 = (FxPanicGpsEvent) panicGpsEvent
				.get(0);
		FxPanicGpsEvent panicGpsEvent_2 = (FxPanicGpsEvent) panicGpsEvent
				.get(1);

		long refId = -1;
		long newId = -1;

		List<FxEvent> events = new ArrayList<FxEvent>();
		int rowNumber = 0;
		long id = 0;
		// insert
 
		mPanicGpsDao.insert(panicGpsEvent_1);
		id = mPanicGpsDao.insert(panicGpsEvent_2);

		// query
		events = mPanicGpsDao.select(QueryOrder.QueryNewestFirst, 1);
		refId = events.get(0).getEventId();

		FxLog.d(TAG, "refId : " + refId);

		// delete
		try {
			rowNumber = mPanicGpsDao.delete(id);
		} catch (FxDbIdNotFoundException e) {
			e.printStackTrace();
		}

		// query
		events = mPanicGpsDao.select(QueryOrder.QueryNewestFirst, 1);
		newId = events.get(0).getEventId();
		FxLog.d(TAG, "newId : " + newId);

		Assert.assertTrue(((newId < refId) && rowNumber > 0) ? true : false);
	}

	public void test_count() throws FxDbCorruptException, FxDbOperationException {
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mPanicGpsDao.countEvent();
		eventCountInfo.setCount(FxEventType.PANIC_GPS, eventCount);

		boolean coutStatus = false;

		int coutByType = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.PANIC_GPS);
		coutTotal = eventCountInfo.countTotal();

		FxLog.d(TAG, "coutByType : " + coutByType + ", coutTotal : " + coutTotal);

		if (coutByType > -1 && coutTotal > -1) {
			coutStatus = true;
		}
		Assert.assertTrue((coutStatus) ? true : false);

	}

	protected void finalize() {
		if (mDatabaseManager != null) {
			mDatabaseManager.closeDb();
			try {
				mDatabaseManager.dropDb();
			} catch (IOException e) {
			}
		}
	}
}
