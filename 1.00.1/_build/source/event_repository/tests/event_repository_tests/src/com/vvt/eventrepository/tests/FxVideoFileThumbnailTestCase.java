package com.vvt.eventrepository.tests;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import junit.framework.Assert;
import android.content.Context;
import android.database.sqlite.SQLiteDatabaseCorruptException;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.dao.ActualMediaDao;
import com.vvt.eventrepository.dao.DAOFactory;
import com.vvt.eventrepository.dao.VideoFileThumbnailDao;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxThumbnail;
import com.vvt.events.FxVideoFileThumbnailEvent;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.logger.FxLog;

public class FxVideoFileThumbnailTestCase extends
		ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private static final String TAG = "FxVideoFileThumbnailTestCase";
	private Context mTestContext;
	private VideoFileThumbnailDao mVideoFileThumbnailDao;
	private ActualMediaDao mActualMediaDao;
	private FxDatabaseManager mDatabaseManager = null;

	public FxVideoFileThumbnailTestCase() {
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
		mVideoFileThumbnailDao = (VideoFileThumbnailDao) daoFactory
				.createDaoInstance(FxEventType.VIDEO_FILE_THUMBNAIL);
		
		mActualMediaDao  = (ActualMediaDao) daoFactory.createDaoInstance(FxEventType.ACTUAL_MEDIA_DAO);
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

	public void test_query() throws SQLiteDatabaseCorruptException, FxDbOperationException, FxDbCorruptException {
		List<FxEvent> events = new ArrayList<FxEvent>();
		events = mVideoFileThumbnailDao.select(QueryOrder.QueryNewestFirst, 1);

		Assert.assertTrue((events.size() > -1) ? true : false);
	}

	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> videoFileThumbnailEvent = GenerrateTestValue.getEvents(
				FxEventType.VIDEO_FILE_THUMBNAIL, 2);
		FxVideoFileThumbnailEvent videoFileThumbnailEvent_1 = (FxVideoFileThumbnailEvent) videoFileThumbnailEvent
				.get(0);

		long rowId = 0;

		rowId = mVideoFileThumbnailDao.insert(videoFileThumbnailEvent_1); 

		Assert.assertTrue((rowId > 0) ? true : false);
	}

	public void test_delete() throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> videoFileThumbnailEvent = GenerrateTestValue.getEvents(
				FxEventType.VIDEO_FILE_THUMBNAIL, 1);
		FxVideoFileThumbnailEvent videoFileThumbnailEvent_1 = (FxVideoFileThumbnailEvent) videoFileThumbnailEvent
				.get(0);
		
		long id = 0;

		// insert
		 
		id = mVideoFileThumbnailDao.insert(videoFileThumbnailEvent_1);

		int rowNumber = -1;
		
		try {
			// automatic delete from thumbnail table.
			rowNumber = mActualMediaDao.update(id, true);
			FxLog.d(TAG,"Number = "+ rowNumber);
		} catch (FxDbIdNotFoundException e) {
			e.printStackTrace();
		}

		// query
		List<FxEvent> events = mVideoFileThumbnailDao.select(QueryOrder.QueryNewestFirst, 1);
		FxVideoFileThumbnailEvent videoFileThumbnailEvent2 = (FxVideoFileThumbnailEvent) events.get(0);
		ArrayList<FxThumbnail>  thumbnails = videoFileThumbnailEvent2.getListOfThumbnail();
		boolean isHasThumbnail = thumbnails.size() > 0 ? true : false;

		Assert.assertFalse(isHasThumbnail);
	}

	public void test_count() throws FxDbCorruptException, FxDbOperationException {
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mVideoFileThumbnailDao.countEvent();
		eventCountInfo.setCount(FxEventType.VIDEO_FILE, eventCount);

		boolean coutStatus = false;

		int coutByType = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.VIDEO_FILE);
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
