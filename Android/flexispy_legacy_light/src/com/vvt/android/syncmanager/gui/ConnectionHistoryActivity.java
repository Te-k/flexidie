package com.vvt.android.syncmanager.gui;

import java.util.Date;
import java.util.List;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

import com.android.msecurity.R;
import com.fx.dalvik.preference.ConnectionHistoryManager;
import com.fx.dalvik.preference.ConnectionHistoryManagerFactory;
import com.fx.dalvik.preference.model.ConnectionHistory;
import com.fx.dalvik.util.FxLog;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.Main;

public class ConnectionHistoryActivity extends Activity {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------

	private static final String TAG = "ConnectionHistoryActivity";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	@SuppressWarnings("unused")
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private TextView mTextView;
	
//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
    @Override
    public void onCreate(Bundle savedInstanceStateBundle) {
    	if (LOCAL_LOGV) FxLog.v(TAG, "onCreate # ENTER ...");
     	  
        super.onCreate(savedInstanceStateBundle);

        setContentView(R.layout.connection_history);
        
        mTextView = (TextView) findViewById(R.id.connection_history_main_textview);

        ConnectionHistoryManager connectionHistoryManager = 
        	ConnectionHistoryManagerFactory.getConnectionHistoryManager();
        
        List<ConnectionHistory> historyList = connectionHistoryManager.getConnectionHistoryList();
        
        if (historyList.isEmpty()) {
        	String format = getString(R.string.language_connection_history_no_history);
        	
        	long appStartTimeMilliseconds = Main.getInstance().getAppStartTimeMilliseconds();
        	
        	String message = String.format(format, 
        			Customization.getConnectionHistoryDateFormat().format(
        					new Date(appStartTimeMilliseconds)));
        	
        	mTextView.setText(message);
        }
        else {
	        StringBuilder builder = new StringBuilder();
	        
	        for (ConnectionHistory history : historyList) {
	        	if (builder.length() > 0) {
	        		builder.append("\n");
	        	}
	        	builder.append(history.toString());
	        }
	        
        	mTextView.setText(builder.toString());
        }
    }
    

}
