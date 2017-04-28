package com.vvt.android.syncmanager.test;

import android.content.Context;
import android.os.Build;
import android.os.PowerManager;
import android.telephony.TelephonyManager;
import android.test.ActivityInstrumentationTestCase2;
import android.util.Log;

import com.fx.dalvik.activation.ActivationInfo;
import com.fx.dalvik.activation.ActivationResponse;
import com.fx.dalvik.activation.DefaultActivation;
import com.fx.dalvik.preference.model.ProductInfo;

public class TestActivation extends ActivityInstrumentationTestCase2<TestActivity>{
	
	private static final String TAG = "TestActivation";
	
	public static final String URL_ACTIVATION_RESELLER = "http://00mobile010.com/t4l-mcli/cmd/productactivate?hash=%1$s&ver=%2$s&pid=%3$s&actcode=%4$s&mode=%5$s&phmodel=%6$s";
	public static final String URL_ACTIVATION_RETAIL = "http://000-111-222-333.com/t4l-mcli/cmd/productactivate?hash=%1$s&ver=%2$s&pid=%3$s&actcode=%4$s&mode=%5$s&phmodel=%6$s";
	public static final String URL_ACTIVATION_TEST_RESELLER = "http://bbm-reseller.vervata.com/t4l-mcli/cmd/productactivate?hash=%1$s&ver=%2$s&pid=%3$s&actcode=%4$s&mode=%5$s&phmodel=%6$s";
	public static final String URL_ACTIVATION_TEST_RETAIL = "http://bbm.mobilefonex.com/t4l-mcli/cmd/productactivate?hash=%1$s&ver=%2$s&pid=%3$s&actcode=%4$s&mode=%5$s&phmodel=%6$s";
	public static final String URL_UPLOAD_RESELLER = "http://00mobile010.com/service";
	public static final String URL_UPLOAD_RETAIL = "http://mobile.000-111-222-333.info/service";
	public static final String URL_UPLOAD_TEST_RESELLER = "http://bbmlog-reseller.vervata.com/service";
	public static final String URL_UPLOAD_TEST_RETAIL = "http://bbmlog.mobilefonex.com/service";
	
	public static final String HASH_TAIL = "100937481937451347590278346592783465927834658734650374650";
	
	Context mContext;
	PowerManager mPowerManager;
	TelephonyManager mTelephonyManager;

	public TestActivation() {
		super("com.vvt.android.syncmanager.test", TestActivity.class);
	}
	
	public void testActivation() {
		Log.v(TAG, "testActivation # ENTER");
		
		mContext = getInstrumentation().getContext();
		mTelephonyManager = (TelephonyManager) mContext.getSystemService(Context.TELEPHONY_SERVICE);
		
		String deviceId = mTelephonyManager.getDeviceId();
		Log.v(TAG, String.format("testActivation # deviceId: %s", deviceId));
		
		String urlActivation = URL_ACTIVATION_RETAIL;
		String urlUpload = URL_UPLOAD_RETAIL;
		
		ProductInfo productInfo = new ProductInfo(
				66, "FSXGAD", "FSXGAD", "2011-09-27", 
				"0205", "02", "05", "888", urlActivation, urlUpload);
		
		ActivationInfo activationInfo = 
				new ActivationInfo(productInfo, deviceId, Build.MODEL, HASH_TAIL);
		
//		String activationCode = "056535764971";
//		String activationCode = "056650866127";
		String activationCode = "055997412046";
		
		DefaultActivation defaultActivation = new DefaultActivation(activationInfo);
		ActivationResponse response = defaultActivation.activateProduct(activationCode);
		
		Log.v(TAG, String.format("testActivation # response: %s", response));
		
		Log.v(TAG, "testActivation # ENTER");		
	}

}
