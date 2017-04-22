package com.vvt.capture.simchange.tests;


import java.util.List;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import com.vvt.appcontext.AppContextImpl;
import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.capture.simchange.SimChangeManagerImpl;
import com.vvt.license.LicenseManagerImpl;

public class Sim_change_capture_testsActivity extends Activity {

	private TextView mTextView;  

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		mTextView = (TextView)findViewById(R.id.textView);



		EventListner eventListner = new EventListner();

		SimChangeManagerImpl simChangeCapture = new SimChangeManagerImpl();
		simChangeCapture.setAppContext(new AppContextImpl(this));
		simChangeCapture.setEventListener(eventListner);
		simChangeCapture.setLicenseManager(new LicenseManagerImpl(this));



	}

	class EventListner implements FxEventListener
	{
		@Override
		public void onEventCaptured(final List<FxEvent> events) {
			Log.d("EventListner", "onReceive");

			Sim_change_capture_testsActivity.this.runOnUiThread(
					new Runnable() {
						public void run() {
							StringBuilder builder = new StringBuilder();
							builder.append("======= onReceive =======");
							builder.append("\n");
							builder.append(String.format("Event Count %d", events.size()));
							builder.append("\n");
							builder.append("======= ======= =======");
							builder.append("\n");
							builder.append("======= Event Data =======");
							builder.append("\n");
							for(FxEvent e: events) {
								builder.append(e.toString());
							}
							builder.append("\n");
							builder.append("======= ======= =======");
							builder.append("\n");
							builder.append(mTextView.getText());
							builder.append("\n");
							mTextView.setText(builder.toString());    	                }
					}
					);
		}
	}
}