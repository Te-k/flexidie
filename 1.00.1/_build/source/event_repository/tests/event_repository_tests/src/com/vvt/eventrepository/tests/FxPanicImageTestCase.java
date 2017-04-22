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
import com.vvt.eventrepository.dao.DAOFactory;
import com.vvt.eventrepository.dao.PanicImageDao;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxGeoTag;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.events.FxPanicImageEvent;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public class FxPanicImageTestCase extends
		ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private static final String TAG = "FxPanicImageTestCase";
	private Context mTestContext;
	private PanicImageDao mPanicImageDao;
	private FxDatabaseManager mDatabaseManager = null;

	public FxPanicImageTestCase() {
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
		mPanicImageDao = (PanicImageDao) daoFactory
				.createDaoInstance(FxEventType.PANIC_IMAGE);
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

		try {
			events = mPanicImageDao.select(QueryOrder.QueryNewestFirst, 1);
			
		} catch (FxFileNotFoundException e) {
			e.printStackTrace();
		}
		
		Assert.assertTrue((events.size() > -1) ? true : false);
		
	}

	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> panicImageEvent = GenerrateTestValue.getEvents(
				FxEventType.PANIC_IMAGE, 1);
		FxPanicImageEvent panicImageEvent_1 = (FxPanicImageEvent) panicImageEvent
				.get(0);
		panicImageEvent_1.setActualFullPath("/sdcard/data/xxx.png");

		FxLog.d(TAG, panicImageEvent_1.getFormat().toString());

		long rowId = 0;

		rowId = mPanicImageDao.insert(panicImageEvent_1);

		Assert.assertTrue((rowId > 0) ? true : false);
	}

	public void test_delete() throws FxDbCorruptException, FxDbOperationException {

		FxPanicImageEvent panicImageEvent = new FxPanicImageEvent();

		FxGeoTag geoTag = new FxGeoTag();
		geoTag.setAltitude(10.1245648f);
		geoTag.setLat(13.157986245f);
		geoTag.setLon(101.4567468f);

		String ext = FileUtil.getFileExtension("/sdcard/data/xxx.png");
		FxMediaType mediaType = FxMimeTypeParser.parse(ext);

		panicImageEvent.setGeoTag(geoTag);
		panicImageEvent.setActualFullPath("/sdcard/data/xxx.png");
		panicImageEvent.setAreaCode("xx12345ff");
		panicImageEvent.setCellId(32345454);
		panicImageEvent.setCountryCode("+66th");
		panicImageEvent.setEventTime(System.currentTimeMillis());
		panicImageEvent.setFormat(mediaType);
		panicImageEvent.setImageData(new byte[] {});
		panicImageEvent.setNetworkId("sdsd3532");
		panicImageEvent.setActualDuration(60443300);
		panicImageEvent.setActualSize(12000);
		panicImageEvent.setNetworkName("unknown");
		panicImageEvent.setCellName("unknown");

		// Can't use GenerateCalss because if it no actual file test always
		// return false.
		// List<FxEvent> panicImageEvent =
		// GenerrateTestValue.getEvents(FxEventType.PANIC_IMAGE, 2);
		// FxPanicImageEvent panicImageEvent_1 = (FxPanicImageEvent)
		// panicImageEvent.get(0);
		// FxPanicImageEvent panicImageEvent_2 = (FxPanicImageEvent)
		// panicImageEvent.get(1);
		
		File f=new File("/sdcard/data/xxx.png");
		if(!f.exists()){
			boolean isSuccess = f.mkdirs();
			FxLog.d(TAG,"Create file success = "+ isSuccess);
		}

		long refId = -1;
		long newId = -1;

		List<FxEvent> events = new ArrayList<FxEvent>();
		int rowNumber = 0;
		long id = 0;

		// insert
 
		mPanicImageDao.insert(panicImageEvent);
		id = mPanicImageDao.insert(panicImageEvent);
		 
		try {
			// query
			events = mPanicImageDao.select(QueryOrder.QueryNewestFirst, 1);

			refId = events.get(0).getEventId();
			FxLog.i(TAG, "refId : " + refId);

			// delete
			try {
				rowNumber = mPanicImageDao.delete(id);
			} catch (FxDbIdNotFoundException e) {
				e.printStackTrace();
			}

			// query
			events = mPanicImageDao.select(QueryOrder.QueryNewestFirst, 1);
			newId = events.get(0).getEventId();

		} catch (FxFileNotFoundException e) {
			e.printStackTrace();
		}

		FxLog.d(TAG, "refId :" + refId + "newId : " + newId);

		Assert.assertTrue(((newId < refId) && rowNumber > 0) ? true : false);
	}

	public void test_count() throws FxDbCorruptException, FxDbOperationException {
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mPanicImageDao.countEvent();
		eventCountInfo.setCount(FxEventType.PANIC_IMAGE, eventCount);

		boolean coutStatus = false;

		int coutByType = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.PANIC_IMAGE);
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
