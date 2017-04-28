package com.vvt.phoenix.util.test;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.SimpleTimeZone;
import java.util.TimeZone;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.util.FxTime;

public class TimeTest {
	// Debug fields
	private static final String TAG = "com.vvt.util.TimeTest";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	public void timeTest(){
		if(LOCAL_LOGV)Log.v(TAG, FxTime.getCurrentTime());
		//if(LOCAL_LOGV)Time.timeTest();
	}
	
	
}
