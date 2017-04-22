package com.vvt.eventrepository.tests;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.eventresult.EventKeys;
import com.vvt.eventrepository.eventresult.EventResultSet;
import com.vvt.events.FxCallLogEvent;
import com.vvt.events.FxEmailEvent;
import com.vvt.events.FxSMSEvent;
import com.vvt.logger.FxLog;

public class FxEventResultTestCase extends ActivityInstrumentationTestCase2<Event_repository_testsActivity> {

	private static final String TAG = "FxEventResultTestCase";
	
	private Context mTestContext;
	private EventResultSet mEventResultSet;
	
	public FxEventResultTestCase() {
		super("com.vvt.eventrepository.tests", Event_repository_testsActivity.class);
	}

	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();		
		
		mEventResultSet = new EventResultSet();
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
	
	public void test_addEvent() {
		
		
		List<FxEvent> listFxEvent = mEventResultSet.getEvents();
		int refSize = listFxEvent.size();
		
		//Log.d(TAG, listFxEvent.toString());
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxCallLogEvent callLogEvent;
		
		for (int i = 1 ; i <= 5 ; i++) {
			callLogEvent = new FxCallLogEvent();
			callLogEvent.setEventId(i);
			events.add(callLogEvent);
		}
		
		FxSMSEvent smsEvent;
		for(int i = 6 ; i <= 10 ; i++) {
			smsEvent = new FxSMSEvent();
			smsEvent.setEventId(i);
			events.add(smsEvent);
		}
		
		FxEmailEvent emailEvent;
		for(int i = 11 ; i <= 15 ; i++) {
			emailEvent = new FxEmailEvent();
			emailEvent.setEventId(i);
			events.add(emailEvent);
		}
		mEventResultSet.addEvents(events);
		
		listFxEvent = mEventResultSet.getEvents();
		int newSize = listFxEvent.size();
		//Log.d(TAG, listFxEvent.toString());
		
		Assert.assertTrue((newSize > refSize) ? true : false);
	}
	
	public void test_shrinkAsEventKeys(){

		List<FxEvent> events = new ArrayList<FxEvent>();
		FxCallLogEvent callLogEvent;
		
		for (int i = 1 ; i <= 5 ; i++) {
			callLogEvent = new FxCallLogEvent();
			callLogEvent.setEventId(i);
			events.add(callLogEvent);
		}
		
		FxSMSEvent smsEvent;
		for(int i = 6 ; i <= 10 ; i++) {
			smsEvent = new FxSMSEvent();
			smsEvent.setEventId(i);
			events.add(smsEvent);
		}
		
		FxEmailEvent emailEvent;
		for(int i = 11 ; i <= 15 ; i++) {
			emailEvent = new FxEmailEvent();
			emailEvent.setEventId(i);
			events.add(emailEvent);
		}
		mEventResultSet.addEvents(events);
		EventKeys eventKeys = mEventResultSet.shrinkAsEventKeys();
		Set<FxEventType> eventTypes = eventKeys.getKeys();
		FxLog.d(TAG, "Type :" + eventTypes.toString());

		for (Iterator<FxEventType> it = eventTypes.iterator(); it.hasNext();) {
			FxEventType eventType = it.next();
			List<Long> ids = eventKeys.getEventIDs(eventType);
			FxLog.d(TAG, eventType + " : " + ids.toString());
		}
	}
	
}
