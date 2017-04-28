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
import com.vvt.eventrepository.dao.MmsDao;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxMMSEvent;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;

public class FxMmsDaoTestCase extends
		ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private Context mTestContext;
	private MmsDao mMmsDao;
	private FxDatabaseManager mDatabaseManager = null;

	public FxMmsDaoTestCase() {
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
		mMmsDao = (MmsDao) daoFactory.createDaoInstance(FxEventType.MMS);
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
		events = mMmsDao.select(QueryOrder.QueryNewestFirst, 1);

		Assert.assertTrue((events.size() > -1) ? true : false);
	}

	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> mmsEvent = GenerrateTestValue.getEvents(FxEventType.MMS,
				1);
		FxMMSEvent mmsEvent_1 = (FxMMSEvent) mmsEvent.get(0);

		long rowId = 0;
		List<FxEvent> events = new ArrayList<FxEvent>();

		mMmsDao.insert(mmsEvent_1);

		events = mMmsDao.select(QueryOrder.QueryNewestFirst, 1);
		rowId = events.get(0).getEventId();

		Assert.assertTrue((rowId > 0) ? true : false);
	}

	public void test_delete() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> mmsEvent = GenerrateTestValue.getEvents(FxEventType.MMS,
				2);
		FxMMSEvent mmsEvent_1 = (FxMMSEvent) mmsEvent.get(0);
		FxMMSEvent mmsEvent_2 = (FxMMSEvent) mmsEvent.get(1);

		long refId = -1;
		long newId = -1;

		List<FxEvent> events = new ArrayList<FxEvent>();
		int rowNumber = 0;
		long id = 0;

		// insert
 
		mMmsDao.insert(mmsEvent_1);
		id = mMmsDao.insert(mmsEvent_2);
		 

		// query
		events = mMmsDao.select(QueryOrder.QueryNewestFirst, 1);
		refId = events.get(0).getEventId();

		// delete
		try {
			rowNumber = mMmsDao.delete(id);
		} catch (FxDbIdNotFoundException e) {
			e.printStackTrace();
		}

		// query
		events = mMmsDao.select(QueryOrder.QueryNewestFirst, 1);
		newId = events.get(0).getEventId();

		Assert.assertTrue(((newId < refId) && rowNumber > 0) ? true : false);
	}

	public void test_count() throws FxDbCorruptException, FxDbOperationException {
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mMmsDao.countEvent();
		eventCountInfo.setCount(FxEventType.MMS, eventCount);

		boolean coutStatus = false;

		int coutByType = -1;
		int coutByDirection = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.MMS);
		coutByDirection = eventCountInfo.count(FxEventType.MMS,
				FxEventDirection.IN);
		coutTotal = eventCountInfo.countTotal();

		if (coutByType > -1 && coutByDirection > -1 && coutTotal > -1) {
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
