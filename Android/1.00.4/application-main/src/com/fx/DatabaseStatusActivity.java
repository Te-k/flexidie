package com.fx;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.widget.TextView;

import com.android.msecurity.R;
import com.fx.maind.ref.DatabaseRecords;
import com.fx.maind.ref.command.RemoteGetDatabaseRecords;
import com.fx.socket.SocketCmd;
import com.fx.util.Customization;
import com.vvt.logger.FxLog;

public class DatabaseStatusActivity extends Activity {
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	private static final String TAG = "DatabaseStatusActivity";
	
	TextView mTextView = null;
	
	@Override
	public void onCreate(Bundle aSavedInstanceStateBundle) {
		if (LOGV) FxLog.v(TAG, "onCreate # ENTER ...");

		super.onCreate(aSavedInstanceStateBundle);
		setContentView(R.layout.generic_settings);
		
		mTextView = (TextView) findViewById(R.id.details_textview);
		
		new UITask().execute(new RemoteGetDatabaseRecords());
		
		if (LOGV) FxLog.v(TAG, "onCreate # EXIT ...");
	}
	
	private class UITask extends AsyncTask<SocketCmd<?, ?>, Void, String> {
		private Object result = null;
		private ProgressDialog pDialog;
		
		protected void onPreExecute() {
			pDialog = ProgressDialog.show(
					DatabaseStatusActivity.this, "", 
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
	    	if (result != null) onPostExecuteTask(result);	
	    }
	}
	
	private void onPostExecuteTask(Object result) {
		if (LOGV) FxLog.v(TAG, "onPostExecuteTask # ENTER ...");
		
		if(result != null) {
			if (result instanceof DatabaseRecords) {
				DatabaseRecords response = (DatabaseRecords) result;
				
				int totalCalls = response.getIncomingCall() + response.getOutgoingCall() + response.getMissedCall();
				int totalSms = response.getIncomingSMS() + response.getOutgoingSMS();
				int totalMms = response.getIncomingMMS() + response.getOutgoingMMS();
				int totalEmail = response.getIncomingEmail() + response.getOutgoingEmail();
				int totalIM = response.getIncomingIM() + response.getOutgoingIM();
				
				StringBuilder sb = new StringBuilder();
				sb.append(String.format(getString(R.string.language_database_status_event_total), response.getTotalEvents())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_call), totalCalls, response.getIncomingCall(), response.getOutgoingCall(), response.getMissedCall())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_sms), totalSms, response.getIncomingSMS(), response.getOutgoingSMS())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_mms), totalMms, response.getIncomingMMS(), response.getOutgoingMMS())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_email), totalEmail, response.getIncomingEmail(), response.getOutgoingEmail())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_im), totalIM, response.getIncomingIM(), response.getOutgoingIM())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_location), response.getGPS())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_image), response.getImage())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_audio), response.getAudio())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_video), response.getVideo())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_wallpaper), response.getWallpaper())).append("\r\n");
				sb.append(String.format(getString(R.string.language_database_status_event_system), response.getSystem())).append("\r\n");
				
				mTextView.setText(sb.toString());
			}
		}
		if (LOGV) FxLog.v(TAG, "onPostExecuteTask # EXIT ...");
	}
}
