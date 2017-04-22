package com.vvt.locationcapture.tests;

import android.app.Dialog;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;

import com.vvt.capture.location.util.LocationCallingModule;

public class SettingSpecDialog extends Dialog implements OnItemSelectedListener{
	
	private Context mContext;
	@SuppressWarnings("unused")
	private String mKeepState;
	private long mTrackingTimeInterval;
	@SuppressWarnings("unused")
	private long mTimeOut;
	private String mCaptureMode;
	@SuppressWarnings("unused")
	private String mAllowGetGlocation;
	@SuppressWarnings("unused")
	private String mAllowGetCellID;
	
	private SharedPreferences prefs;
	
	private Button bt_OK;
	private Button bt_cancel;
	private EditText mTimeInterval_et;
	@SuppressWarnings("unused")
	private EditText mTimeOut_et;

	public SettingSpecDialog(Context context) {
		super(context);
		mContext = context;
	}
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setTitle("Setting Spec Capture");
		setContentView(R.layout.form);
		
		prefs = PreferenceManager.getDefaultSharedPreferences(mContext);
		  
		//Mode
		final Spinner spnMode = (Spinner) findViewById(R.id.spinner_mode);
		int mode = prefs.getInt(Location_capture_testsActivity.MODULE, LocationCallingModule.MODULE_PANIC.getNumber());
		LocationCallingModule callingModule = LocationCallingModule.forValue(mode);
		if(LocationCallingModule.MODULE_CORE == callingModule) {
			ArrayAdapter<CharSequence> adapter1 = ArrayAdapter.createFromResource(
						mContext, R.array.mode_core, android.R.layout.simple_spinner_item);
			 adapter1.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
			 spnMode.setAdapter(adapter1);
			 spnMode.setOnItemSelectedListener(this);
		} else if(LocationCallingModule.MODULE_PANIC == callingModule){
			ArrayAdapter<CharSequence> adapter1 = ArrayAdapter.createFromResource(
						mContext, R.array.mode_panic, android.R.layout.simple_spinner_item);
			 adapter1.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
			 spnMode.setAdapter(adapter1);
			 spnMode.setOnItemSelectedListener(this);
		} else if(LocationCallingModule.MODULE_ALERT == callingModule){
			ArrayAdapter<CharSequence> adapter1 = ArrayAdapter.createFromResource(
					mContext, R.array.mode_panic, android.R.layout.simple_spinner_item);
		 adapter1.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		 spnMode.setAdapter(adapter1);
		 spnMode.setOnItemSelectedListener(this);
		} else {
				ArrayAdapter<CharSequence> adapter1 = ArrayAdapter.createFromResource(
						mContext, R.array.mode_ondemand, android.R.layout.simple_spinner_item);
			 adapter1.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
			 spnMode.setAdapter(adapter1);
			 spnMode.setOnItemSelectedListener(this);
		}
		
		
		
		 
//		//Is keep state 
//		 final Spinner spnKeepState = (Spinner) findViewById(R.id.spinner_keepstate);
//		 String keepstate = prefs.getString(Location_capture_testsActivity.KEEP_STATE, "Unknown");
//		if (keepstate.equals("True")) {
//			ArrayAdapter<CharSequence> adapter2 = ArrayAdapter.createFromResource(
//						mContext, R.array.keepState_true,android.R.layout.simple_spinner_item);
//			adapter2.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
//			spnKeepState.setAdapter(adapter2);
//			spnKeepState.setOnItemSelectedListener(this);
//		 } else {
//			 ArrayAdapter<CharSequence> adapter2 = ArrayAdapter.createFromResource(
//						mContext, R.array.keepState_false,android.R.layout.simple_spinner_item);
//				adapter2.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
//				spnKeepState.setAdapter(adapter2);
//				spnKeepState.setOnItemSelectedListener(this);
//		 }
		 
		
		
//		//Is Gloc 
//		final Spinner spnGloc = (Spinner) findViewById(R.id.spinner_Gloc);
//		 String gloc = prefs.getString(Location_capture_testsActivity.G_LOC, "Unknown");
//		if (gloc.equals("False")) {
//			ArrayAdapter<CharSequence> adapter3 = ArrayAdapter.createFromResource(
//					mContext, R.array.state_false,android.R.layout.simple_spinner_item);
//			adapter3.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
//			spnGloc.setAdapter(adapter3);
//			spnGloc.setOnItemSelectedListener(this);
//		} else {
//			ArrayAdapter<CharSequence> adapter3 = ArrayAdapter.createFromResource(
//					mContext, R.array.state_true,android.R.layout.simple_spinner_item);
//			adapter3.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
//			spnGloc.setAdapter(adapter3);
//			spnGloc.setOnItemSelectedListener(this);
//		}
		
		 
		
//		//Is keep cell ID 
//		final Spinner spnCellId = (Spinner) findViewById(R.id.spinner_cellId);
//		String cellId = prefs.getString(Location_capture_testsActivity.CELL_ID, "Unknown");
//		if (cellId.equals("False")) {
//			ArrayAdapter<CharSequence> adapter4 = ArrayAdapter.createFromResource(
//					mContext, R.array.state_false,android.R.layout.simple_spinner_item);
//			adapter4.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
//			spnCellId.setAdapter(adapter4);
//			spnCellId.setOnItemSelectedListener(this);
//		} else {
//			ArrayAdapter<CharSequence> adapter4 = ArrayAdapter.createFromResource(
//					mContext, R.array.state_true,android.R.layout.simple_spinner_item);
//			adapter4.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
//			spnCellId.setAdapter(adapter4);
//			spnCellId.setOnItemSelectedListener(this);
//		}
		
		mTimeInterval_et = (EditText) findViewById(R.id.timeInterval);
//		mTimeOut_et = (EditText) findViewById(R.id.timeOut);
		mTimeInterval_et.setText(Long.toString(prefs.getLong(Location_capture_testsActivity.TIME_INTERVAL, 300000)));
//		mTimeOut_et.setText(Long.toString(prefs.getLong(Location_capture_testsActivity.TIME_OUT, 180000)));
		
		bt_OK = (Button) findViewById(R.id.ok);
		bt_cancel = (Button) findViewById(R.id.cancle);
		
		bt_OK.setOnClickListener(new View.OnClickListener() {
			
			public void onClick(View arg0) {
				
				mTrackingTimeInterval = Long.parseLong(mTimeInterval_et.getText().toString());
//				mTimeOut = Long.parseLong(mTimeOut_et.getText().toString());
				mCaptureMode = (String) spnMode.getSelectedItem();
				int module = 0;
				if(mCaptureMode.equals("ON_DEMAND")) {
					module = 3;
				} else if(mCaptureMode.equals("PANIC")){
					module = 1;
				} else if(mCaptureMode.equals("ALERT")){
					module = 2;
				} else {
					module = 0;
				}
//				mKeepState = (String) spnKeepState.getSelectedItem();
//				mAllowGetGlocation = (String) spnGloc.getSelectedItem();
//				mAllowGetCellID = (String) spnCellId.getSelectedItem();
				dismiss();
				
				prefs = PreferenceManager.getDefaultSharedPreferences(mContext);
				SharedPreferences.Editor editor = prefs.edit();
				 editor.putLong(Location_capture_testsActivity.TIME_INTERVAL, mTrackingTimeInterval);
//				 editor.putLong(Location_capture_testsActivity.TIME_OUT, mTimeOut);
				 editor.putInt(Location_capture_testsActivity.MODULE, module);
//				 editor.putString(Location_capture_testsActivity.KEEP_STATE, mKeepState);
//				 editor.putString(Location_capture_testsActivity.G_LOC, mAllowGetGlocation);
//				 editor.putString(Location_capture_testsActivity.CELL_ID, mAllowGetCellID);
				 editor.commit();
			}
		});
		
		bt_cancel.setOnClickListener(new View.OnClickListener() {
			
			public void onClick(View v) {
				dismiss();
			}
		});
		
		
		
	}

	public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2,
			long arg3) {
		// TODO Auto-generated method stub
		
	}

	public void onNothingSelected(AdapterView<?> arg0) {
		// TODO Auto-generated method stub
		
	}

}
