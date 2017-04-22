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
import com.vvt.eventrepository.dao.SystemDao;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxSystemEvent;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.logger.FxLog;

public class FxSystemEventTestCase extends
		ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private static final String TAG = "FxSystemEventTestCase";
	private Context mTestContext;
	private SystemDao mSystemDao;
	private FxDatabaseManager mDatabaseManager = null;

	public FxSystemEventTestCase() {
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
		mSystemDao = (SystemDao) daoFactory
				.createDaoInstance(FxEventType.SYSTEM);
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

		events = mSystemDao.select(QueryOrder.QueryNewestFirst, 1);

		Assert.assertTrue((events.size() > -1) ? true : false);
	}

	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> systemEvent = GenerrateTestValue.getEvents(
				FxEventType.SYSTEM, 1);
		FxSystemEvent systemEvent_1 = (FxSystemEvent) systemEvent.get(0);

		long rowId = 0;

		rowId = mSystemDao.insert(systemEvent_1);
		 
		Assert.assertTrue((rowId > 0) ? true : false);
	}

	public void test_delete() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> systemEvent = GenerrateTestValue.getEvents(
				FxEventType.SYSTEM, 2);
		FxSystemEvent systemEvent_1 = (FxSystemEvent) systemEvent.get(0);
		FxSystemEvent systemEvent_2 = (FxSystemEvent) systemEvent.get(1);

		long refId = -1;
		long newId = -1;

		List<FxEvent> events = new ArrayList<FxEvent>();
		int rowNumber = 0;

		long id = 0;
		// insert
 
		mSystemDao.insert(systemEvent_1);
		id = mSystemDao.insert(systemEvent_2);
		 
		// query
		events = mSystemDao.select(QueryOrder.QueryNewestFirst, 1);
		refId = events.get(0).getEventId();

		// delete
		try {
			rowNumber = mSystemDao.delete(id);
		} catch (FxDbIdNotFoundException e) {
			e.printStackTrace();
		}

		// query
		events = mSystemDao.select(QueryOrder.QueryNewestFirst, 1);
		newId = events.get(0).getEventId();

		Assert.assertTrue(((newId < refId) && rowNumber > 0) ? true : false);
	}

	public void test_count() throws FxDbCorruptException, FxDbOperationException {
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mSystemDao.countEvent();
		eventCountInfo.setCount(FxEventType.SYSTEM, eventCount);

		boolean coutStatus = false;

		int coutByType = -1;
		int coutByDirection_in = -1;
		int coutByDirection_out = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.SYSTEM);
		coutByDirection_in = eventCountInfo.count(FxEventType.SYSTEM,
				FxEventDirection.IN);
		coutByDirection_out = eventCountInfo.count(FxEventType.SYSTEM,
				FxEventDirection.OUT);
		coutTotal = eventCountInfo.countTotal();

		FxLog.d(TAG,
				String.format(
						"coutByType : %s\ncoutByDirection_in : %s\ncoutByDirection_out : %s\ncoutTotal : %s",
						coutByType, coutByDirection_in, coutByDirection_out,
						coutTotal));

		if (coutByType > -1 && coutByDirection_in > -1
				&& coutByDirection_out > -1 && coutTotal > -1) {
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
