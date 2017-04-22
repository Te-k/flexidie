package com.vvt.activation_manager_tests;

import java.util.List;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.activation_manager.ActivationListener;
import com.vvt.activation_manager.ActivationManager;
import com.vvt.activation_manager.ActivationManagerImp;
import com.vvt.appcontext.AppContext;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.connectionhistorymanager.ConnectionHistoryManagerImp;
import com.vvt.datadeliverymanager.DataDeliveryManager;
import com.vvt.datadeliverymanager.enums.ErrorResponseType;
import com.vvt.datadeliverymanager.enums.ServerStatusType;
import com.vvt.datadeliverymanager.interfaces.PccRmtCmdListener;
import com.vvt.datadeliverymanager.interfaces.ServerStatusErrorListener;
import com.vvt.exceptions.FxConcurrentRequestNotAllowedException;
import com.vvt.exceptions.FxExecutionTimeoutException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseManagerImpl;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.response.PCC;
import com.vvt.server_address_manager.ServerAddressManager;
import com.vvt.server_address_manager.ServerAddressManagerImpl;

 

public class ActivationManagerTestCase  extends ActivityInstrumentationTestCase2<Activation_manager_testsActivity>  {
	@SuppressWarnings("unused")
	private static final String TAG = "ActivationManagerTestCase";
	
	private Context mTestContext;
	private DataDeliveryManager mDataDeliveryManager = null;
	private ServerAddressManager mMockServerAddressManager;
	private MockActivationListener mMockActivationListener = new MockActivationListener();
	boolean isActivationCompleted = false;
	private AppContext mAppContext; 
	private LicenseManager mLicenseManager;
	
	public ActivationManagerTestCase(String pkg,Class<Activation_manager_testsActivity> activityClass) {
		super(pkg, activityClass);
	}
	
	public ActivationManagerTestCase() {
		super("com.vvt.activation_manager_tests", Activation_manager_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();
		mAppContext = new AppContextImpl(mTestContext);
		((AppContextImpl) mAppContext).createPhoneInfo();
		((AppContextImpl) mAppContext).createProductInfo();
			
		
		mLicenseManager = new LicenseManagerImpl(mTestContext);
		
		mMockServerAddressManager = new ServerAddressManagerImpl(mAppContext);
		mMockServerAddressManager.setServerUrl("http://58.137.119.229/RainbowCore");
		
		try {
			mDataDeliveryManager = new DataDeliveryManager();
			mDataDeliveryManager.setAppContext(mAppContext);
			mDataDeliveryManager.setCommandServiceManager(createCommandServiceManager());
			mDataDeliveryManager.setConnectionHistory(new ConnectionHistoryManagerImp(mTestContext.getCacheDir().getAbsolutePath()) {});
			mDataDeliveryManager.setLicenseManager(mLicenseManager);
			mDataDeliveryManager.setPccRmtCmdListener(new MockRmtCommandListener());
			mDataDeliveryManager.setServerAddressManager(mMockServerAddressManager);
			mDataDeliveryManager.setServerStatusErrorListener(new MockServerStatusErrorListener());
			mDataDeliveryManager.initialize();
			
		} catch (FxNullNotAllowedException e) {
			FxLog.e("setUp", e.toString());
		}
	}

	private CommandServiceManager createCommandServiceManager() {
		String dbPath = mTestContext.getFilesDir().getAbsolutePath() + "/";
		String payloadPath = mTestContext.getFilesDir().getAbsolutePath() + "/";

		CommandServiceManager manager = CommandServiceManager.getInstance(dbPath, payloadPath);
		return manager;
	}	 
	 
	/*public void test_AutoActivation() throws FxNullNotAllowedException, FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException
	{
		ActivationManager activationManager = new ActivationManagerImp(mDataDeliveryManager, mMockServerAddressManager, mAppContext);
		activationManager.autoActivate(mMockActivationListener);
		
		LicenseManager mgr = new LicenseManagerImpl(mTestContext);
		((ActivationManagerImp)activationManager).setLicenseManager(mgr);
		
		// Wait here till we get the response back from the activation.
		while(!isActivationCompleted)
		{
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
			}
		}
	}
	

	public void test_ActivateWithUrl() throws FxNullNotAllowedException, FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException {
		ActivationManager activationManager = new ActivationManagerImp(mDataDeliveryManager, mMockServerAddressManager, mAppContext);
		LicenseManager mgr = new LicenseManagerImpl(mTestContext);
		((ActivationManagerImp)activationManager).setLicenseManager(mgr);
		
		final String productActivationUrl = "http://58.137.119.229/RainbowCore/gateway";
		
		mMockServerAddressManager.setServerUrl(productActivationUrl);
		activationManager.autoActivate(productActivationUrl, mMockActivationListener);
		
		// Wait here till we get the response back from the activation.
		while(!isActivationCompleted)
		{
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
			}
		}
	}*/
	 

	public void test_ActivateWithCode() throws FxNullNotAllowedException, FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException { 
		ActivationManager activationManager = new ActivationManagerImp();
		((ActivationManagerImp)activationManager).setDataDelivery(mDataDeliveryManager);
		((ActivationManagerImp)activationManager).setAppContext(mAppContext);
		((ActivationManagerImp)activationManager).setServerAddressManager(mMockServerAddressManager);
		((ActivationManagerImp)activationManager).setLicenseManager(mLicenseManager);
		((ActivationManagerImp)activationManager).initialize();

		final String activationCode = "01206";
		isActivationCompleted = false;
			
		LicenseInfo licenseInfo = new LicenseInfo();
		licenseInfo.setActivationCode(activationCode);
		licenseInfo.setLicenseStatus(LicenseStatus.UNKNOWN);
		
		mLicenseManager.updateLicense(licenseInfo);
		
		((ActivationManagerImp)activationManager).setLicenseManager(mLicenseManager);
		activationManager.activate(activationCode, mMockActivationListener);
		
		// Wait here till we get the response back from the activation.
		while(!isActivationCompleted)
		{
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
			}
		}
	}
	
	/*public void test_ActivateWithCode_Concurrent_Test() throws FxNullNotAllowedException, FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException { 
		ActivationManager activationManager = new ActivationManagerImp(mDataDeliveryManager, mMockServerAddressManager, mAppContext);
		final String activationCode = "01206";
		isActivationCompleted = false;
		boolean isSuccess = false;
		
		LicenseInfo licenseInfo = new LicenseInfo();
		licenseInfo.setActivationCode(activationCode);
		licenseInfo.setLicenseStatus(LicenseStatus.UNKNOWN);
		mLicenseManager.updateLicense(licenseInfo);
		
		((ActivationManagerImp)activationManager).setLicenseManager(mLicenseManager);
		activationManager.activate(activationCode, mMockActivationListener);
		
		try {
			activationManager.activate(activationCode, mMockActivationListener);
			isSuccess = false;
		}
		catch(FxConcurrentRequestNotAllowedException ex) {
			isSuccess = true;
		}
		
		assertTrue(isSuccess);
	}
 
	public void test_ActivateWithCodeAndUrl() throws FxNullNotAllowedException, FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException {
		ActivationManager activationManager = new ActivationManagerImp(mDataDeliveryManager, mMockServerAddressManager, mAppContext);
		final String activationCode = "01206";
		final String productActivationUrl = "http://58.137.119.229/RainbowCore";
		isActivationCompleted = false;
		
		LicenseInfo licenseInfo = new LicenseInfo();
		licenseInfo.setActivationCode(activationCode);
		licenseInfo.setLicenseStatus(LicenseStatus.UNKNOWN);
		mLicenseManager.updateLicense(licenseInfo);
		
		mMockServerAddressManager.setServerUrl(productActivationUrl);
		
		((ActivationManagerImp)activationManager).setLicenseManager(mLicenseManager);
		activationManager.activate(productActivationUrl, activationCode, mMockActivationListener);
		
		// Wait here till we get the response back from the activation.
		while(!isActivationCompleted)
		{
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
			}
		}
	}
	
	public void test_ActivateWithCodeAndUrl_Concurrent_Test() throws FxNullNotAllowedException, FxExecutionTimeoutException, FxConcurrentRequestNotAllowedException {
		ActivationManager activationManager = new ActivationManagerImp(mDataDeliveryManager, mMockServerAddressManager, mAppContext);
		final String activationCode = "01206";
		final String productActivationUrl = "http://58.137.119.229/RainbowCore";
		isActivationCompleted = false;
		boolean isSuccess = false;
		
		LicenseInfo licenseInfo = new LicenseInfo();
		licenseInfo.setActivationCode(activationCode);
		licenseInfo.setLicenseStatus(LicenseStatus.UNKNOWN);
		mLicenseManager.updateLicense(licenseInfo);
		
		mMockServerAddressManager.setServerUrl(productActivationUrl);
		
		LicenseManager mgr = new LicenseManagerImpl(mTestContext);
		((ActivationManagerImp)activationManager).setLicenseManager(mgr);
		
		activationManager.activate(productActivationUrl, activationCode, mMockActivationListener);
		
		try {
			activationManager.activate(productActivationUrl, activationCode, mMockActivationListener);
			isSuccess = false;
		}
		catch(FxConcurrentRequestNotAllowedException ex) {
			isSuccess = true;
		}
		
		assertTrue(isSuccess);
		
	}
		 */
/*	public void test_Deactivate_Test() throws FxNullNotAllowedException, FxExecutionTimeoutException, FxConcurrentRequestNotAllowedException {
		ActivationManager activationManager = new ActivationManagerImp(mDataDeliveryManager, mMockServerAddressManager, mAppContext);
		
		LicenseManager mgr = new LicenseManagerImpl(mTestContext);
		((ActivationManagerImp)activationManager).setLicenseManager(mgr);
		isActivationCompleted = false;
		
		activationManager.deactivate(mMockActivationListener);
		
		// Wait here till we get the response back from the activation.
		while(!isActivationCompleted)
		{
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
			}
		}
	}*/
	
	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}

	public void setTestContext(Context context) {
		mTestContext = context;
	}
	
	class MockActivationListener implements ActivationListener  {

		@Override
		public void onSuccess() {
			isActivationCompleted = true;
		}

		@Override
		public void onError(ErrorResponseType paramErrorResponseType, int paramInt,
				String paramString) {
			
			Assert.fail(paramString);
			
			isActivationCompleted = true;
		}	
	}
}
 

/*class MockServerAddressManager implements ServerAddressManager
{

	@Override
	public void setServerUrl(String sereverUrl) {
		
	}

	@Override
	public String getStructuredServerUrl() {
		return "http://58.137.119.229/RainbowCore/gateway";
	}

	@Override
	public String getUnstructuredServerUrl() {
		return "http://58.137.119.229/RainbowCore/gateway/unstructured";
	}

	@Override
	public String getBaseServerUrl() {
		return "http://58.137.119.229/RainbowCore";
		return "";
	}

	 
}*/

class MockServerStatusErrorListener implements ServerStatusErrorListener {

	@Override
	public void onServerStatusErrorListener(
			ServerStatusType paramServerStatusType) {
		// TODO Auto-generated method stub
		
	}
	
}

class MockRmtCommandListener implements PccRmtCmdListener {

	@Override
	public void onReceivePCC(List<PCC> pcc) {
		// TODO Auto-generated method stub
		
	}
	
}
