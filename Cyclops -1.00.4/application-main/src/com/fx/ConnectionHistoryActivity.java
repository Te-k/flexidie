package com.fx;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.widget.TextView;

import com.android.msecurity.R;
import com.fx.maind.ref.command.RemoteGetConnectionHistoryString;
import com.fx.socket.SocketCmd;
import com.fx.util.Customization;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class ConnectionHistoryActivity extends Activity {
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	private static final String TAG = "ConnectionHistoryActivity";

	private TextView mTextView = null;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.last_connection);
		mTextView = (TextView) findViewById(R.id.connection_history_main_textview);
		new UITask().execute(new RemoteGetConnectionHistoryString());
	}
	
	private class UITask extends AsyncTask<SocketCmd<?, ?>, Void, String> {
		private Object result = null;
		private ProgressDialog pDialog;
		
		protected void onPreExecute() {
			pDialog = ProgressDialog.show(
					ConnectionHistoryActivity.this, "", 
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
	    	if(result != null) onPostExecuteTask(result);	
	    }
	}
	
	private void onPostExecuteTask(Object result) {
		if(result instanceof String) {
			String response =  (String) result;
			
			if(FxStringUtils.isEmptyOrNull(response)) {
				mTextView.setText("No connection has been made");
			}
			else {
				mTextView.setText(response);
			}
			
			
		}
	}
}
