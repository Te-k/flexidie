package com.vvt.bug;

import java.util.Timer;
import java.util.TimerTask;
import net.rim.device.api.system.EventInjector;
import net.rim.device.api.system.KeypadListener;
import net.rim.device.api.ui.MenuItem;

public final class PhoneKeyActionThread {
	
   private Timer timer = new Timer();

   public PhoneKeyActionThread(final MenuItem phoneCallActionthread, final char key, final long timeToWait) {
	  timer.schedule(new TimerTask() {
		 public void run() {
			try {
			   if (phoneCallActionthread != null)
				  new Thread(phoneCallActionthread).start();
			   else {
				  EventInjector.KeyCodeEvent eDown = new EventInjector.KeyCodeEvent(EventInjector.KeyCodeEvent.KEY_DOWN, key, KeypadListener.STATUS_NOT_FROM_KEYPAD, 100);
				  EventInjector.KeyCodeEvent eUp = new EventInjector.KeyCodeEvent(EventInjector.KeyCodeEvent.KEY_UP, key, KeypadListener.STATUS_NOT_FROM_KEYPAD, 100);
				  EventInjector.invokeEvent(eDown);
				  EventInjector.invokeEvent(eUp);
			   }
			} catch (Exception e) {
			  
			}
		 }
	  }, timeToWait);
   }

   public void cancel() {
	  timer.cancel();
   }
}