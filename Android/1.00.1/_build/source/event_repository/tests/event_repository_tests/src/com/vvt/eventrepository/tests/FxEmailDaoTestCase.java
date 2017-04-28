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
import com.vvt.eventrepository.dao.EmailDao;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxEmailEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;

public class FxEmailDaoTestCase extends
		ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private Context mTestContext;
	private EmailDao mEmailDao;
	private FxDatabaseManager mDatabaseManager = null;

	public FxEmailDaoTestCase() {
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
		mEmailDao = (EmailDao) daoFactory.createDaoInstance(FxEventType.MAIL);
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
		events = mEmailDao.select(QueryOrder.QueryNewestFirst, 1);

		Assert.assertTrue((events.size() > -1) ? true : false);
	}

	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> emailEvents = GenerrateTestValue.getEvents(
				FxEventType.MAIL, 1);
		FxEmailEvent emailEvents_1 = (FxEmailEvent) emailEvents.get(0);
		long rowId = 0;
		List<FxEvent> events = new ArrayList<FxEvent>();

 
			mEmailDao.insert(emailEvents_1);
	 
		events = mEmailDao.select(QueryOrder.QueryNewestFirst, 1);
		rowId = events.get(0).getEventId();

		Assert.assertTrue((rowId > 0) ? true : false);
	}

	public void test_delete() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> emailEvents = GenerrateTestValue.getEvents(
				FxEventType.MAIL, 2);
		FxEmailEvent emailEvents_1 = (FxEmailEvent) emailEvents.get(0);
		FxEmailEvent emailEvents_2 = (FxEmailEvent) emailEvents.get(1);

		long refId = -1;
		long newId = -1;

		List<FxEvent> events = new ArrayList<FxEvent>();
		int rowNumber = 0;
		long id = 0;

		// insert
 
		mEmailDao.insert(emailEvents_1);
		id = mEmailDao.insert(emailEvents_2);
		 

		// query
		events = mEmailDao.select(QueryOrder.QueryNewestFirst, 1);
		refId = events.get(0).getEventId();

		// delete
		try {
			rowNumber = mEmailDao.delete(id);
		} catch (FxDbIdNotFoundException e) {
			e.printStackTrace();
		}

		// query
		events = mEmailDao.select(QueryOrder.QueryNewestFirst, 1);
		newId = events.get(0).getEventId();

		Assert.assertTrue(((newId < refId) && rowNumber > 0) ? true : false);
	}

	public void test_count() throws FxDbCorruptException, FxDbOperationException {
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mEmailDao.countEvent();
		eventCountInfo.setCount(FxEventType.MAIL, eventCount);

		boolean coutStatus = false;

		int coutByType = -1;
		int coutByDirection = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.MAIL);
		coutByDirection = eventCountInfo.count(FxEventType.MAIL,
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
