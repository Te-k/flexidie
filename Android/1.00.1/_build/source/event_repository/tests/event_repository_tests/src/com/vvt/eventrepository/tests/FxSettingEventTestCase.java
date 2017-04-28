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
import com.vvt.eventrepository.dao.SettingsDao;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxSettingEvent;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.logger.FxLog;

public class FxSettingEventTestCase extends
		ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private static final String TAG = "FxSettingEventTestCase";
	private Context mTestContext;
	private SettingsDao mSettingDao;
	private FxDatabaseManager mDatabaseManager = null;

	public FxSettingEventTestCase() {
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
		mSettingDao = (SettingsDao) daoFactory
				.createDaoInstance(FxEventType.SETTINGS);
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

		events = mSettingDao.select(QueryOrder.QueryNewestFirst, 1);

		Assert.assertTrue((events.size() > -1) ? true : false);
	}

	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> settingEvents = GenerrateTestValue.getEvents(
				FxEventType.SETTINGS, 1);
		FxSettingEvent settingEvent = (FxSettingEvent) settingEvents.get(0);

		long rowId = 0;

		rowId = mSettingDao.insert(settingEvent);

		Assert.assertTrue((rowId > 0) ? true : false);
	}

	public void test_delete() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> settingEvents = GenerrateTestValue.getEvents(
				FxEventType.SETTINGS, 1);
		FxSettingEvent settingEvent_1 = (FxSettingEvent) settingEvents.get(0);
		FxSettingEvent settingEvent_2 = (FxSettingEvent) settingEvents.get(0);

		long refId = -1;
		long newId = -1;

		List<FxEvent> events = new ArrayList<FxEvent>();
		int rowNumber = 0;

		long id = 0;
		// insert
		 
		mSettingDao.insert(settingEvent_1);
		id = mSettingDao.insert(settingEvent_2);
		 

		// query
		events = mSettingDao.select(QueryOrder.QueryNewestFirst, 1);
		refId = events.get(0).getEventId();

		// delete
		try {
			rowNumber = mSettingDao.delete(id);
		} catch (FxDbIdNotFoundException e) {
			e.printStackTrace();
		}

		// query
		events = mSettingDao.select(QueryOrder.QueryNewestFirst, 1);
		newId = events.get(0).getEventId();

		Assert.assertTrue(((newId < refId) && rowNumber > 0) ? true : false);
	}

	public void test_count() {
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mSettingDao.countEvent();
		eventCountInfo.setCount(FxEventType.SETTINGS, eventCount);

		boolean coutStatus = false;

		int coutByType = -1;
		int coutByDirection_in = -1;
		int coutByDirection_out = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.SETTINGS);
		coutByDirection_in = eventCountInfo.count(FxEventType.SETTINGS,
				FxEventDirection.IN);
		coutByDirection_out = eventCountInfo.count(FxEventType.SETTINGS,
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
