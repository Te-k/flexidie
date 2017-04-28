package com.server_address_manager_tests;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.appcontext.AppContext;
import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.productinfo.ProductInfo;
import com.vvt.server_address_manager.ServerAddressManager;
import com.vvt.server_address_manager.ServerAddressManagerImpl;

 

public class ServerAddressManagerTestCase  extends ActivityInstrumentationTestCase2<Server_address_manager_testsActivity>  {
	@SuppressWarnings("unused")
	private static final String TAG = "ServerAddressManagerTestCase";
	
	private Context mTestContext;
	boolean isActivationCompleted = false;
	 
	public ServerAddressManagerTestCase() {
		super("com.server_address_manager_tests", Server_address_manager_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();
	}
	
/*	public void test_setServerUrl() { 
		AppContextMock appContextMock = new AppContextMock();
		
		ServerAddressManager adm = new ServerAddressManagerImpl(appContextMock);
		adm.setServerUrl("http://58.137.119.229/RainbowCore/");
	}
	*/
	
	public void test_clearServerUrl() { 
		AppContextMock appContextMock = new AppContextMock();
		ServerAddressManager adm = new ServerAddressManagerImpl(appContextMock);
		adm.clearServerUrl(); // Clear user urls
		
		adm.setServerUrl("http://58.137.119.229/RainbowCore/");
		
		assertTrue(adm.queryServerUrl().size() == 2);
		
		adm.clearServerUrl();
		
		assertTrue(adm.queryServerUrl().size() == 1);
	}
	
	public void test_queryServerUrl() { 
		AppContextMock appContextMock = new AppContextMock();
		ServerAddressManager adm = new ServerAddressManagerImpl(appContextMock);
		adm.clearServerUrl(); // Clear user urls
		
		adm.setServerUrl("http://58.137.119.229/RainbowCore/");
		
		assertTrue(adm.queryServerUrl().size() == 2);
	}

	public void test_getStructuredServerUrl() { 
		AppContextMock appContextMock = new AppContextMock();
		ServerAddressManager adm = new ServerAddressManagerImpl(appContextMock);
		adm.setServerUrl("http://58.137.119.229/RainbowCore/");
		
		Assert.assertEquals(adm.getStructuredServerUrl(), "http://58.137.119.229/RainbowCore/gateway");
	}
	
	public void test_getUnstructuredServerUrl() { 
		AppContextMock appContextMock = new AppContextMock();
		ServerAddressManager adm = new ServerAddressManagerImpl(appContextMock);
		adm.setServerUrl("http://58.137.119.229/RainbowCore/");
		
		Assert.assertEquals(adm.getUnstructuredServerUrl(), "http://58.137.119.229/RainbowCore/gateway/unstructured");
	}
	
	public void test_setRequireBaseServerUrl_with_null() { 
		AppContextMock appContextMock = new AppContextMock();
		ServerAddressManager adm = new ServerAddressManagerImpl(appContextMock);
		adm.setRequireBaseServerUrl(false);
		
		Assert.assertSame(adm.getBaseServerUrl(), null);
	}
	
	public void test_setRequireBaseServerUrl_without_null() { 
		AppContextMock appContextMock = new AppContextMock();
		ServerAddressManager adm = new ServerAddressManagerImpl(appContextMock);
		adm.setRequireBaseServerUrl(true);
		
		adm.setServerUrl("http://58.137.119.229/RainbowCore/");
		
		String baseServerUrl = adm.getBaseServerUrl();
		
		if(!baseServerUrl.equalsIgnoreCase("http://58.137.119.229/RainbowCore/")) {
			Assert.fail();
		}
	}  
	
	private class AppContextMock implements AppContext
	{

		@Override
		public ProductInfo getProductInfo() {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public PhoneInfo getPhoneInfo() {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public Context getApplicationContext() {
			return mTestContext;
		}

		@Override
		public String getWritablePath() {
			return mTestContext.getCacheDir().getAbsolutePath();
		}
		
	}
	
}
