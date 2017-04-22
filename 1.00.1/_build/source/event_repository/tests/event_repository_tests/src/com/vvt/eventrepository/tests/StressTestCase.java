package com.vvt.eventrepository.tests;

import java.io.IOException;
import java.util.Random;

import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.FxEventRepositoryManager;
import com.vvt.eventrepository.dao.AlertDao;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.eventresult.EventResultSet;
import com.vvt.eventrepository.querycriteria.QueryCriteria;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbNotOpenException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;

@SuppressWarnings("rawtypes")
public class StressTestCase extends ActivityInstrumentationTestCase2 {
	 
	@SuppressWarnings("unused")
	private static final String TAG = "StressTestCase";
	
	private Context mTestContext;
	
	@SuppressWarnings("unused")
	private AlertDao mAlertDao;
	
	@SuppressWarnings("unchecked")
	public StressTestCase() {
		super("com.vvt.eventrepository.tests", Event_repository_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();
		
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
	
 
	private int getUserThinkTime() {
		// 1 and 10 seconds
		
		Random rand = new Random();
		int min = 1, max = 10;

		// nextInt is normally exclusive of the top value,
		// so add 1 to make it inclusive
		int randomNum = rand.nextInt(max - min + 1) + min;
		randomNum *= 1000;
		return randomNum;
	}
	
 
	public void test_Insert() throws FxDbOpenException, IOException,
			InterruptedException, FxNotImplementedException,
			FxNullNotAllowedException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException
	{
		final int MAX_EVENTS = 50000;
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		for(int i= 0; i <= MAX_EVENTS; i ++) {
			FxEvent event = null; 
			event = GenerrateTestValue.getRandomEvent();
			eventRepositoryManager.insert(event);
			Thread.sleep(getUserThinkTime());
		}		
		
		eventRepositoryManager.openRepository();
		//eventRepositoryManager.deleteRepository();
	}
	
	 
	@SuppressWarnings("unused")
	public void test_getTotalCount() throws FxDbOpenException,
			IOException, FxNotImplementedException,
			FxNullNotAllowedException,
			InterruptedException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException
	{
		final int MAX_EVENTS = 1000;
		final FxEventType[] TYPES_LIST = { FxEventType.CALL_LOG,
											FxEventType.SMS,
											FxEventType.MMS,
											FxEventType.MAIL,
											FxEventType.SIM_CHANGE,
											FxEventType.CAMERA_IMAGE_THUMBNAIL,
											FxEventType.AUDIO_FILE_THUMBNAIL,
											FxEventType.VIDEO_FILE_THUMBNAIL,
											FxEventType.LOCATION,
											FxEventType.SYSTEM,
											FxEventType.PANIC_GPS,
											FxEventType.PANIC_IMAGE,
											FxEventType.PANIC_STATUS,
											FxEventType.IM
											};
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		for(FxEventType t: TYPES_LIST)	{
			for(int i= 0; i <= MAX_EVENTS; i ++) {
				FxEvent event = null; 
				event = GenerrateTestValue.getRandomEvent();
				eventRepositoryManager.insert(event);
				Thread.sleep(getUserThinkTime());
			}
		}
		
		assertEquals(MAX_EVENTS, eventRepositoryManager.getTotalEventCount());
	}
 
	
	@SuppressWarnings("unused")
	public void test_getCount() throws FxDbOpenException, IOException,
			FxNotImplementedException,
			FxNullNotAllowedException,
			InterruptedException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		final int MAX_EVENTS = 1000;
		final FxEventType[] TYPES_LIST = { FxEventType.CALL_LOG,
											FxEventType.SMS,
											FxEventType.MMS,
											FxEventType.MAIL,
											FxEventType.SIM_CHANGE,
											FxEventType.CAMERA_IMAGE_THUMBNAIL,
											FxEventType.AUDIO_FILE_THUMBNAIL,
											FxEventType.VIDEO_FILE_THUMBNAIL,
											FxEventType.LOCATION,
											FxEventType.SYSTEM,
											FxEventType.PANIC_GPS,
											FxEventType.PANIC_IMAGE,
											FxEventType.PANIC_STATUS,
											FxEventType.IM
											};
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		for(FxEventType eventType: TYPES_LIST)	{
			for(int i= 0; i <= MAX_EVENTS; i ++) {
				FxEvent event = null;
				event = GenerrateTestValue.getRandomEvent();
				eventRepositoryManager.insert(event);
				Thread.sleep(getUserThinkTime());
			}
		}
		
		EventCountInfo c = eventRepositoryManager.getCount();
		
		//Check total count
		assertEquals(c.countTotal(), (MAX_EVENTS *  TYPES_LIST.length));
		
		// Check individual count for type
		for(FxEventType eventType: TYPES_LIST)	{
			int insertCount = c.count(eventType);
			assertEquals(MAX_EVENTS, insertCount);
		}
		 
	}

	@SuppressWarnings("unused")
	public void test_getRegularEvents() throws IOException, FxDbOpenException,
			FxNullNotAllowedException,
			FxNotImplementedException, FxFileNotFoundException,
			InterruptedException, FxDbNotOpenException, FxDbOperationException, FxDbCorruptException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		final int MAX_EVENTS = 1000;
		
		final FxEventType[] TYPES_LIST = { FxEventType.CALL_LOG,
				FxEventType.SMS,
				FxEventType.MMS,
				FxEventType.MAIL,
				FxEventType.LOCATION
				};
		
		// Insert..
		for(FxEventType t: TYPES_LIST)	{
			for(int i= 0; i <= MAX_EVENTS; i ++) {
				FxEvent event = null; 
				event = GenerrateTestValue.getRandomEvent();
				eventRepositoryManager.insert(event);
				Thread.sleep(getUserThinkTime());
			}
		}
		
		for(FxEventType t: TYPES_LIST) {
			QueryCriteria criteria = new QueryCriteria();
			criteria.addEventType(t);
			EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
			
			assertEquals(MAX_EVENTS, result.getEvents().size());
		}
		
	}
	@SuppressWarnings("unused")
	public void test_getMediaEvents() throws IOException, FxDbOpenException,
			FxNotImplementedException,
			FxNullNotAllowedException,
			InterruptedException, FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		final int MAX_EVENTS = 10000;
		
		final FxEventType[] TYPES_LIST = { FxEventType.CAMERA_IMAGE_THUMBNAIL,
				FxEventType.AUDIO_FILE_THUMBNAIL,
				FxEventType.VIDEO_FILE_THUMBNAIL
				};
		
		// Insert..
		for(FxEventType t: TYPES_LIST)	{
			for(int i= 0; i <= MAX_EVENTS; i ++) {
				FxEvent event = null; 
				event = GenerrateTestValue.getRandomEvent();
				eventRepositoryManager.insert(event);
				Thread.sleep(getUserThinkTime());
			}
		}
		
		for(FxEventType t: TYPES_LIST) {
			QueryCriteria criteria = new QueryCriteria();
			criteria.addEventType(t);
			EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
			
			assertEquals(MAX_EVENTS, result.getEvents().size());
		}
		 
	}
	
	@SuppressWarnings("unused")
	public void test_delete() throws IOException, FxDbOpenException,
			FxNotImplementedException,
			FxNullNotAllowedException,
			InterruptedException, FxFileNotFoundException,
			FxDbIdNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		final int MAX_EVENTS = 1000;
		final FxEventType[] TYPES_LIST = { FxEventType.CALL_LOG,
											FxEventType.SMS,
											FxEventType.MMS,
											FxEventType.MAIL,
											FxEventType.SIM_CHANGE,
											FxEventType.CAMERA_IMAGE_THUMBNAIL,
											FxEventType.AUDIO_FILE_THUMBNAIL,
											FxEventType.VIDEO_FILE_THUMBNAIL,
											FxEventType.LOCATION,
											FxEventType.SYSTEM,
											FxEventType.PANIC_GPS,
											FxEventType.PANIC_IMAGE,
											FxEventType.PANIC_STATUS,
											FxEventType.IM
											};
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		for(FxEventType eventType: TYPES_LIST)	{
			for(int i= 0; i <= MAX_EVENTS; i ++) {
				FxEvent event = null; 
				event = GenerrateTestValue.getRandomEvent();
				eventRepositoryManager.insert(event);
				Thread.sleep(getUserThinkTime());
			}
		}
		
		boolean notAllDeleted = true;
		
		while(notAllDeleted) {
			
			QueryCriteria criteria = new QueryCriteria();
			criteria.addEventType(FxEventType.CALL_LOG);
			criteria.addEventType(FxEventType.SMS);
			criteria.addEventType(FxEventType.MMS);
			criteria.addEventType(FxEventType.MAIL);
			criteria.addEventType(FxEventType.SIM_CHANGE);
			criteria.addEventType(FxEventType.LOCATION);
			criteria.addEventType(FxEventType.SYSTEM);
			criteria.addEventType(FxEventType.PANIC_GPS);
			criteria.addEventType(FxEventType.PANIC_IMAGE);
			criteria.addEventType(FxEventType.PANIC_STATUS);
			criteria.addEventType(FxEventType.IM);
			
			EventResultSet rResult = eventRepositoryManager.getRegularEvents(criteria);
			int rEvents = rResult.getEvents().size();
			
			if( rEvents > 0)			
				eventRepositoryManager.delete(rResult.shrinkAsEventKeys());
			
			criteria.clearEventTypes();
			criteria.addEventType(FxEventType.CAMERA_IMAGE_THUMBNAIL);
			criteria.addEventType(FxEventType.AUDIO_FILE_THUMBNAIL);
			criteria.addEventType(FxEventType.VIDEO_FILE_THUMBNAIL);
			
			EventResultSet mEvents = eventRepositoryManager.getMediaEvents(criteria);
			int mEventsSize = mEvents.getEvents().size();
			
			if( mEventsSize > 0)			
				eventRepositoryManager.delete(mEvents.shrinkAsEventKeys());
			
			if(rEvents == 0 && mEventsSize == 0)
				notAllDeleted = false;
		}
	}
	
	public void test_simultaneous_read_write() throws IOException, FxDbOpenException, InterruptedException, FxDbCorruptException 
	{
		@SuppressWarnings("unused")
		Thread readThread;
		Thread writeThread;
		
		final int MAX_EVENTS = 1000;
		final FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		readThread = new Thread(new Runnable() {
			@SuppressWarnings("unused")
			public void run() {
				QueryCriteria criteria = new QueryCriteria();
				criteria.setLimit(QueryCriteria.MAX);
				criteria.addEventType(FxEventType.CALL_LOG);
				criteria.addEventType(FxEventType.SMS);
				criteria.addEventType(FxEventType.MMS);
				criteria.addEventType(FxEventType.MAIL);
				criteria.addEventType(FxEventType.SIM_CHANGE);
				criteria.addEventType(FxEventType.LOCATION);
				criteria.addEventType(FxEventType.SYSTEM);
				criteria.addEventType(FxEventType.PANIC_GPS);
				criteria.addEventType(FxEventType.PANIC_IMAGE);
				criteria.addEventType(FxEventType.PANIC_STATUS);
				criteria.addEventType(FxEventType.IM);
				
				try {
					
					EventResultSet rResult = eventRepositoryManager.getRegularEvents(criteria);
					
					criteria.clearEventTypes();
					criteria.addEventType(FxEventType.CAMERA_IMAGE_THUMBNAIL);
					criteria.addEventType(FxEventType.AUDIO_FILE_THUMBNAIL);
					criteria.addEventType(FxEventType.VIDEO_FILE_THUMBNAIL);
					
					rResult = eventRepositoryManager.getRegularEvents(criteria);
				} catch (FxNullNotAllowedException e) {
					e.printStackTrace();
				} catch (FxNotImplementedException e) {
					e.printStackTrace();
				} catch (FxFileNotFoundException e) {
					e.printStackTrace();
				} catch (FxDbNotOpenException e) {
					e.printStackTrace();
				} catch (FxDbOperationException e) {
					e.printStackTrace();
				}
			}
		});
		
		writeThread = new Thread(new Runnable() {
			public void run() {
				for (int i = 0; i <= MAX_EVENTS; i++) {
					FxEvent event = null;
					
					try {
						event = GenerrateTestValue.getRandomEvent();
						eventRepositoryManager.insert(event);
					} catch (FxNotImplementedException e1) {
						e1.printStackTrace();
					} catch (FxNullNotAllowedException e1) {
						e1.printStackTrace();
					} catch (FxDbNotOpenException e) {
						e.printStackTrace();
					} catch (FxDbOperationException e) {
						e.printStackTrace();
					}
					
					try {
						Thread.sleep(getUserThinkTime());
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}

		});
		
		writeThread.start();
		
		do {
			Thread.sleep(10000);
		} while (writeThread.isAlive());
		
	}
	
	
	public void test_simultaneous_read_write_delete() throws IOException,
			FxDbOpenException, InterruptedException, FxDbCorruptException 
	{
		Thread readThread;
		Thread writeThread;
		Thread deleteThread;
		
		final int MAX_EVENTS = 1000;
		final FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		writeThread = new Thread(new Runnable() {
			public void run() {
				for (int i = 0; i <= MAX_EVENTS; i++) {
					FxEvent event = null;
					
					try {
						event = GenerrateTestValue.getRandomEvent();
						eventRepositoryManager.insert(event);
					} catch (FxNotImplementedException e1) {
						e1.printStackTrace();
					} catch (FxNullNotAllowedException e1) {
						e1.printStackTrace();
					} catch (FxDbNotOpenException e) {
						e.printStackTrace();
					} catch (FxDbOperationException e) {
						e.printStackTrace();
					}
					
					try {
						Thread.sleep(getUserThinkTime());
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}

		});
		
		readThread = new Thread(new Runnable() {
			
			@SuppressWarnings("unused")
			public void run() {
				QueryCriteria criteria = new QueryCriteria();
				criteria.setLimit(QueryCriteria.MAX);
				criteria.addEventType(FxEventType.CALL_LOG);
				criteria.addEventType(FxEventType.SMS);
				criteria.addEventType(FxEventType.MMS);
				criteria.addEventType(FxEventType.MAIL);
				criteria.addEventType(FxEventType.SIM_CHANGE);
				criteria.addEventType(FxEventType.LOCATION);
				criteria.addEventType(FxEventType.SYSTEM);
				criteria.addEventType(FxEventType.PANIC_GPS);
				criteria.addEventType(FxEventType.PANIC_IMAGE);
				criteria.addEventType(FxEventType.PANIC_STATUS);
				criteria.addEventType(FxEventType.IM);
				
				try {
					EventResultSet rResult = eventRepositoryManager.getRegularEvents(criteria);
					
					criteria.clearEventTypes();
					criteria.addEventType(FxEventType.CAMERA_IMAGE_THUMBNAIL);
					criteria.addEventType(FxEventType.AUDIO_FILE_THUMBNAIL);
					criteria.addEventType(FxEventType.VIDEO_FILE_THUMBNAIL);
					
					rResult = eventRepositoryManager.getRegularEvents(criteria);
					
				} catch (FxNullNotAllowedException e) {
					e.printStackTrace();
				} catch (FxNotImplementedException e) {
					e.printStackTrace();
				} catch (FxFileNotFoundException e) {
					e.printStackTrace();
				} catch (FxDbNotOpenException e) {
					e.printStackTrace();
				} catch (FxDbOperationException e) {
					e.printStackTrace();
				}
			}
		});
		
		deleteThread = new Thread(new Runnable() {
			public void run() {
				QueryCriteria criteria = new QueryCriteria();
				criteria.setLimit(QueryCriteria.MAX);
				criteria.addEventType(FxEventType.CALL_LOG);
				criteria.addEventType(FxEventType.SMS);
				criteria.addEventType(FxEventType.MMS);
				criteria.addEventType(FxEventType.MAIL);
				criteria.addEventType(FxEventType.SIM_CHANGE);
				criteria.addEventType(FxEventType.LOCATION);
				criteria.addEventType(FxEventType.SYSTEM);
				criteria.addEventType(FxEventType.PANIC_GPS);
				criteria.addEventType(FxEventType.PANIC_IMAGE);
				criteria.addEventType(FxEventType.PANIC_STATUS);
				criteria.addEventType(FxEventType.IM);
				
				try {
					
					EventResultSet rResult = eventRepositoryManager.getRegularEvents(criteria);
					eventRepositoryManager.delete(rResult.shrinkAsEventKeys());
					
					criteria.clearEventTypes();
					criteria.addEventType(FxEventType.CAMERA_IMAGE_THUMBNAIL);
					criteria.addEventType(FxEventType.AUDIO_FILE_THUMBNAIL);
					criteria.addEventType(FxEventType.VIDEO_FILE_THUMBNAIL);
					
					rResult = eventRepositoryManager.getRegularEvents(criteria);
					eventRepositoryManager.delete(rResult.shrinkAsEventKeys());
				}	
				catch (FxNullNotAllowedException e) {
					e.printStackTrace();
				} catch (FxNotImplementedException e) {
					e.printStackTrace();
				} catch (FxFileNotFoundException e) {
					e.printStackTrace();
				} catch (FxDbIdNotFoundException e) {
					e.printStackTrace();
				} catch (FxDbNotOpenException e) {
					e.printStackTrace();
				} catch (FxDbOperationException e) {
					e.printStackTrace();
				}
			}
		});
		
		writeThread.start();
		readThread.start();
		deleteThread.start();
		
		do {
			Thread.sleep(10000);
		} while (writeThread.isAlive());
	}

	
}
