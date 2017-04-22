package com.vvt.eventrepository.tests;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.dao.ActualMediaDao;
import com.vvt.eventrepository.dao.CameraImageThumbnailDao;
import com.vvt.eventrepository.dao.DAOFactory;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxCameraImageThumbnailEvent;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.logger.FxLog;

public class FxCameraImageThumbnailTestCase extends
		ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private static final String TAG = "FxCameraImageThumbnailTestCase";
	private Context mTestContext;
	private CameraImageThumbnailDao mCameraImageDao;
	private ActualMediaDao mActualMediaDao;
	private FxDatabaseManager mDatabaseManager = null;

	public FxCameraImageThumbnailTestCase() {
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
		mCameraImageDao = (CameraImageThumbnailDao) daoFactory
				.createDaoInstance(FxEventType.CAMERA_IMAGE_THUMBNAIL);
		mActualMediaDao = (ActualMediaDao) daoFactory
				.createDaoInstance(FxEventType.ACTUAL_MEDIA_DAO);
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

		events = mCameraImageDao.select(QueryOrder.QueryNewestFirst, 1);

		Assert.assertTrue((events.size() > -1) ? true : false);
	}

	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> cameraImageEvent = GenerrateTestValue.getEvents(
				FxEventType.CAMERA_IMAGE_THUMBNAIL, 2);
		FxCameraImageThumbnailEvent cameraImageEvent_1 = (FxCameraImageThumbnailEvent) cameraImageEvent
				.get(0);

		FxLog.d(TAG, cameraImageEvent_1.getFormat().toString());

		long rowId = 0;
 
			rowId = mCameraImageDao.insert(cameraImageEvent_1);
		 

		Assert.assertTrue((rowId > 0) ? true : false);
	}

	public void test_delete() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> cameraImageEvent = GenerrateTestValue.getEvents(
				FxEventType.CAMERA_IMAGE_THUMBNAIL, 2);
		FxCameraImageThumbnailEvent cameraImageEvent_1 = (FxCameraImageThumbnailEvent) cameraImageEvent
				.get(0);
		FxCameraImageThumbnailEvent cameraImageEvent_2 = (FxCameraImageThumbnailEvent) cameraImageEvent
				.get(1);
		
		cameraImageEvent_2.setThumbnailFullPath("/sdcard/data/xxx.png");
		
		//create file 
		File f =  new File("/sdcard/data/xxx.png");
		if (!f.exists()) {
			f.mkdirs();
			
		}
		
		boolean isHasFile = f.exists();

		long refId = -1;
		long newId = -1;

		List<FxEvent> events = new ArrayList<FxEvent>();
		int rowNumber = 0;
		long id = 0;

		// insert
		 
			mCameraImageDao.insert(cameraImageEvent_1);
			id = mCameraImageDao.insert(cameraImageEvent_2);
		 

		// query
		events = mCameraImageDao.select(QueryOrder.QueryNewestFirst, 1);

		refId = events.get(0).getEventId();
		
		try {
			// automatic delete from thumbnail table.
			rowNumber = mActualMediaDao.update(id, true);
			FxLog.d(TAG,"Number = "+ rowNumber);
		} catch (FxDbIdNotFoundException e) {
			e.printStackTrace();
		}

		boolean isNotHasFile = !f.exists();

		// query
		events = mCameraImageDao.select(QueryOrder.QueryNewestFirst, 1);
		newId = events.get(0).getEventId();

		Assert.assertTrue(((newId < refId) && rowNumber > 0 && isHasFile &&isNotHasFile) ? true : false);
	}

	
//	public void test_delete_image() {
//		List<FxEvent> cameraImageEvent = GenerrateTestValue.getEvents(
//				FxEventType.CAMERA_IMAGE_THUMBNAIL, 1);
//		FxCameraImageThumbnailEvent cameraImageEvent_1 = (FxCameraImageThumbnailEvent) cameraImageEvent
//				.get(0);
//		cameraImageEvent_1.setThumbnailFullPath("/sdcard/data/xxx.png");
//
//		// delete
//		try {
//			int rowNumber = mCameraImageDao.delete(7);
//			Log.d(TAG, "rowNumber = " + rowNumber);
//		} catch (FxDbIdNotFoundException e) {
//			e.printStackTrace();
//		}
//	}

	public void test_count() throws FxDbCorruptException, FxDbOperationException {
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mCameraImageDao.countEvent();
		eventCountInfo.setCount(FxEventType.CAMERA_IMAGE, eventCount);

		boolean coutStatus = false;

		int coutByType = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.CAMERA_IMAGE);
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
