package com.vvt.eventrepository.tests;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.dao.ActualMediaDao;
import com.vvt.eventrepository.dao.AudioFileThumbnailDao;
import com.vvt.eventrepository.dao.DAOFactory;
import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxAudioFileThumnailEvent;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.logger.FxLog;

public class FxAudioFileThumbnaiTestCase extends ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private static final String TAG = "FxAudioFileThumbnaiTestCase";
	private Context mTestContext;
	private AudioFileThumbnailDao mAudioFileThumbnailDao;
	private ActualMediaDao mActualMediaDao;
	private FxDatabaseManager mDatabaseManager = null;
	
	public FxAudioFileThumbnaiTestCase() {
		super("com.vvt.eventrepository.tests", Event_repository_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
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
		 
		DAOFactory  daoFactory = new DAOFactory(mDatabaseManager.getDb());
		mAudioFileThumbnailDao = (AudioFileThumbnailDao) daoFactory.createDaoInstance(FxEventType.AUDIO_FILE_THUMBNAIL);
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
	
	public void test_query() throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> events = new ArrayList<FxEvent>();
		events = mAudioFileThumbnailDao.select(QueryOrder.QueryNewestFirst,1);

		Assert.assertTrue((events.size() > -1) ? true : false);
	}
	
	public void test_insert() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> audioFile = GenerrateTestValue.getEvents(FxEventType.AUDIO_FILE_THUMBNAIL, 1);
		FxAudioFileThumnailEvent audioFile_1 = (FxAudioFileThumnailEvent) audioFile.get(0);
		

		long rowId = 0;
		
 
		rowId = mAudioFileThumbnailDao.insert(audioFile_1);
		 
		Assert.assertTrue((rowId > 0) ? true : false);
	}
	
	public void test_delete() throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> audioFile = GenerrateTestValue.getEvents(FxEventType.AUDIO_FILE_THUMBNAIL, 2);
		FxAudioFileThumnailEvent audioFile_1 = (FxAudioFileThumnailEvent) audioFile.get(0);
		FxAudioFileThumnailEvent audioFile_2 = (FxAudioFileThumnailEvent) audioFile.get(1);

		long refId = -1;
		long newId = -1;
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		int rowNumber = 0;
		long id = 0;
		
		// insert
 		mAudioFileThumbnailDao.insert(audioFile_1);
		id = mAudioFileThumbnailDao.insert(audioFile_2);
		 

		// query
		events = mAudioFileThumbnailDao.select(QueryOrder.QueryNewestFirst, 1);
		refId = events.get(0).getEventId();

		try {
			// automatic delete from thumbnail table.
			rowNumber = mActualMediaDao.update(id, true);
			FxLog.d(TAG,"Number = "+ rowNumber);
		} catch (FxDbIdNotFoundException e) {
			e.printStackTrace();
		}
		
//		// delete
//		try {
//			rowNumber = mAudioFileThumbnailDao.delete(id);
//		} catch (FxDbIdNotFoundException e) {
//			e.printStackTrace();
//		}

		// query
		events = mAudioFileThumbnailDao.select(QueryOrder.QueryNewestFirst, 1);
		newId = events.get(0).getEventId();

		Assert.assertTrue(((newId < refId) && rowNumber > 0) ? true : false);
	}
	
	public void test_count() throws FxDbCorruptException, FxDbOperationException{
		EventCountInfo eventCountInfo = new EventCountInfo();
		EventCount eventCount = mAudioFileThumbnailDao.countEvent();
		eventCountInfo.setCount(FxEventType.AUDIO_FILE, eventCount);
		
		boolean coutStatus = false;
		
		int coutByType = -1;
		int coutTotal = -1;
		coutByType = eventCountInfo.count(FxEventType.AUDIO_FILE);
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
