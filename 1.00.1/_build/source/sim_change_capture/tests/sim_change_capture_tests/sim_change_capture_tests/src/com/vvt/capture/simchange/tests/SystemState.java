package com.vvt.capture.simchange.tests;

import java.util.List;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.vvt.appcontext.AppContextImpl;
import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.capture.simchange.SimChangeManagerImpl;
import com.vvt.license.LicenseManagerImpl;

public final class SystemState extends BroadcastReceiver {

	// ------------------------------------------------------------------------------------------------------------------------
	// PRIVATE API
	// ------------------------------------------------------------------------------------------------------------------------

	@SuppressWarnings("unused")
	private static final String TAG = "SystemState";

	// ------------------------------------------------------------------------------------------------------------------------
	// PUBLIC API
	// ------------------------------------------------------------------------------------------------------------------------

	/*
	 * This method will only be called once It will definitely be called when
	 * the device reboots -> ApplicationState#isCaptureEnabled is not
	 * appropriate because the started services handle this state change
	 */
	@Override
	public void onReceive(Context context, Intent intent) {


		EventListner eventListner = new EventListner();

		SimChangeManagerImpl simChangeCapture = new SimChangeManagerImpl();
		simChangeCapture.setAppContext(new AppContextImpl(context));
		simChangeCapture.setEventListener(eventListner);
		simChangeCapture.setLicenseManager(new LicenseManagerImpl(context));

	}

	class EventListner implements FxEventListener
	{
		@Override
		public void onEventCaptured(final List<FxEvent> events) {
			
			Log.d("EventListner", "onReceive");

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
			builder.append("\n");
			
			Log.d("EventListner", builder.toString());

		}
	}
}
