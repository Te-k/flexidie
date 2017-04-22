package com.vvt.preference_manager_tests;

import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.preference_manager.PrefDeviceLock;
import com.vvt.preference_manager.PrefEmergencyNumber;
import com.vvt.preference_manager.PrefEventsCapture;
import com.vvt.preference_manager.PrefHomeNumber;
import com.vvt.preference_manager.PrefKeyword;
import com.vvt.preference_manager.PrefLocation;
import com.vvt.preference_manager.PrefMonitorNumber;
import com.vvt.preference_manager.PrefNotificationNumber;
import com.vvt.preference_manager.PrefPanic;
import com.vvt.preference_manager.PrefWatchList;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceManagerImpl;
import com.vvt.preference_manager.PreferenceType;
import com.vvt.preference_manager.WatchFlag;

public class PreferenceManagerTestCase  extends ActivityInstrumentationTestCase2<Preference_manager_testsActivity> {
	public PreferenceManagerTestCase() {
		super("com.vvt.preference_manager_tests", Preference_manager_testsActivity.class);
	}

	private Context mTestContext;
	
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
	
	/*public void test_getPreference() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		for (PreferenceType i : PreferenceType.values()) {
			Preference p = preferenceManager.getPreference(i);
		}
	}*/
	
	 public void test_PrefDeviceLock() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefDeviceLock preference = new PrefDeviceLock();
		preference.setDeviceLockMessage("lock");
		preference.setEnableAlertSound(true);
		preference.setLocationInterval(1);
		
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefDeviceLock lastSavedPre = (PrefDeviceLock)preferenceManager.getPreference(PreferenceType.DEVICE_LOCK);
		
		assertEquals(lastSavedPre.getDeviceLockMessage(), preference.getDeviceLockMessage());
		assertEquals(lastSavedPre.getEnableAlertSound(), preference.getEnableAlertSound());
		assertEquals(lastSavedPre.getLocationInterval(), preference.getLocationInterval());
	} 
	
	public void test_PrefEmergencyNumber() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefEmergencyNumber preference = new PrefEmergencyNumber();
		preference.addEmergencyNumber("911");
		
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefEmergencyNumber lastSavedPre = (PrefEmergencyNumber)preferenceManager.getPreference(PreferenceType.EMERGENCY_NUMBER);
		assertTrue(lastSavedPre.getEmergencyNumber().size() == 1);
		
		assertEquals(lastSavedPre.getEmergencyNumber().get(0).toString(), "911");
		
	} 
	
	public void test_PrefEmergencyNumber_Clear() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefEmergencyNumber preference = new PrefEmergencyNumber();
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefEmergencyNumber lastSavedPre = (PrefEmergencyNumber)preferenceManager.getPreference(PreferenceType.EMERGENCY_NUMBER);
		assertTrue(lastSavedPre.getEmergencyNumber().size() == 0);
	} 
	
	public void test_PrefEventsCapture() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefEventsCapture preference = new PrefEventsCapture();
		preference.setDeliverTimer(100);
		preference.setEnableAddressBook(true);
		preference.setEnableAudioFile(true);
		preference.setEnableVideoFile(true);
		preference.setEnableCallLog(true);
		preference.setEnableEmail(true);
		preference.setEnableSMS(true);
		preference.setEnableVideoFile(true);
		preference.setMaxEvent(100);
				 
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefEventsCapture lastSavedPre = (PrefEventsCapture)preferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
		 
		assertEquals(lastSavedPre.getDeliverTimer(), preference.getDeliverTimer());
		assertEquals(lastSavedPre.getEnableAddressBook(), preference.getEnableAddressBook());
		assertEquals(lastSavedPre.getEnableAudioFile(), preference.getEnableAudioFile());
		assertEquals(lastSavedPre.getEnableVideoFile(), preference.getEnableVideoFile());
		assertEquals(lastSavedPre.getEnableCallLog(), preference.getEnableCallLog());
		assertEquals(lastSavedPre.getEnableEmail(), preference.getEnableEmail());
		assertEquals(lastSavedPre.getEnableSMS(), preference.getEnableSMS());
		assertEquals(lastSavedPre.getEnableVideoFile(), preference.getEnableVideoFile());
		assertEquals(lastSavedPre.getMaxEvent(), preference.getMaxEvent());
		
	}
	
	public void test_PrefHomeNumber() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefHomeNumber preference = new PrefHomeNumber();
		preference.addHomeNumber("911");
		
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefHomeNumber lastSavedPre = (PrefHomeNumber)preferenceManager.getPreference(PreferenceType.HOME_NUMBER);

		assertTrue(lastSavedPre.getHomeNumber().size() == 1);
		assertEquals(lastSavedPre.getHomeNumber().get(0).toString(), "911");
	}
	
	public void test_PrefHomeNumber_Clear() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefHomeNumber preference = new PrefHomeNumber();
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefHomeNumber lastSavedPre = (PrefHomeNumber)preferenceManager.getPreference(PreferenceType.HOME_NUMBER);

		assertTrue(lastSavedPre.getHomeNumber().size() == 0);
	}
	
	public void test_PrefKeyword() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefKeyword preference = new PrefKeyword();
		preference.addKeyword("911");
		
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefKeyword lastSavedPre = (PrefKeyword)preferenceManager.getPreference(PreferenceType.KEYWORD);

		assertTrue(lastSavedPre.getKeyword().size() == 1);
		assertEquals(lastSavedPre.getKeyword().get(0).toString(), "911");
	}
	
	public void test_PrefKeyword_Clear() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefKeyword preference = new PrefKeyword();
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefKeyword lastSavedPre = (PrefKeyword)preferenceManager.getPreference(PreferenceType.KEYWORD);

		assertTrue(lastSavedPre.getKeyword().size() == 0);
	}
	
	public void test_PrefLocation() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefLocation preference = new PrefLocation();
		preference.setEnableLocation(true);
		preference.setLocationInterval(100);
		
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefLocation lastSavedPre = (PrefLocation)preferenceManager.getPreference(PreferenceType.LOCATION);

		assertEquals(lastSavedPre.getEnableLocation(), preference.getEnableLocation());
		assertEquals(lastSavedPre.getLocationInterval(), preference.getLocationInterval());
	}
	
	public void test_PrefMonitorNumber() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefMonitorNumber preference = new PrefMonitorNumber();
		preference.addMonitorNumber("911");
		preference.setEnableMonitor(true);
		
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefMonitorNumber lastSavedPre = (PrefMonitorNumber)preferenceManager.getPreference(PreferenceType.MONITOR_NUMBER);

		assertEquals(lastSavedPre.getEnableMonitor(), preference.getEnableMonitor());
		assertTrue(lastSavedPre.getMonitorNumber().size() == 1);
		assertEquals(lastSavedPre.getMonitorNumber().get(0).toString(), "911");
	}
	
	public void test_PrefNotificationNumber_Clear() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefNotificationNumber preference = new PrefNotificationNumber();
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefNotificationNumber lastSavedPre = (PrefNotificationNumber)preferenceManager.getPreference(PreferenceType.NOTIFICATION_NUMBER);

		assertTrue(lastSavedPre.getNotificationNumber().size() == 0);
	} 
	
	public void test_PrefPanic() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefPanic preference = new PrefPanic();
		preference.setEnablePanicSound(true);
		preference.setPanicImageInterval(100);
		preference.setPanicLocationInterval(100);
		preference.setPanicMessage("msg");
				
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefPanic lastSavedPre = (PrefPanic)preferenceManager.getPreference(PreferenceType.PANIC);

		assertEquals(lastSavedPre.getEnablePanicSound(), preference.getEnablePanicSound());
		assertEquals(lastSavedPre.getPanicImageInterval(), preference.getPanicImageInterval());
		assertEquals(lastSavedPre.getPanicLocationInterval(), preference.getPanicLocationInterval());
		assertEquals(lastSavedPre.getPanicMessage(), preference.getPanicMessage());
	}
	 
	
	public void test_PrefWatchList() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefWatchList preference = new PrefWatchList();
		preference.addWatchFlag(WatchFlag.WATCH_IN_ADDRESSBOOK, true);
		preference.addWatchNumber("911");
				
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefWatchList lastSavedPre = (PrefWatchList)preferenceManager.getPreference(PreferenceType.WATCH_LIST);

		assertEquals(lastSavedPre.getWatchFlag(), preference.getWatchFlag());
		assertTrue(lastSavedPre.getWatchNumber().size() == 1);
		assertEquals(lastSavedPre.getWatchNumber().get(0).toString(), "911");
	}
	
	public void test_PrefWatchList_Clear() {
		String writeablePath = mTestContext.getCacheDir().getAbsolutePath();
		PreferenceManager preferenceManager = new PreferenceManagerImpl(writeablePath);
		
		PrefWatchList preference = new PrefWatchList();
		preferenceManager.savePreferenceAndNotifyChange(preference);
		
		PrefWatchList lastSavedPre = (PrefWatchList)preferenceManager.getPreference(PreferenceType.WATCH_LIST);
		assertTrue(lastSavedPre.getWatchNumber().size() == 0);
	}
	
}
