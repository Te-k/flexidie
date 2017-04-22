package com.vvt.screen;

import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.system.Application;
import net.rim.device.api.ui.component.GaugeField;
import net.rim.device.api.ui.container.MainScreen;

public class ProgressThread extends Thread {
	
	private GaugeField progressBar = new GaugeField("", 0, 100, 0, GaugeField.NO_TEXT);
	private MainScreen screen = null;
	private boolean flag = true;
	
	public ProgressThread(MainScreen screen) {
		this.screen = screen;
	}
	
	public void stopProgressThread() {
		flag = false;
	}

	public void run() {
		try {
			// To add progress bar.
			Application.getApplication().invokeLater(new Runnable() {
				public void run() {
					synchronized (Application.getEventLock()) {
						screen.add(progressBar);
					}
				}
			});
			progressBar.setValue(0);
			int min = progressBar.getValueMin();
			int max = progressBar.getValueMax();
			int next = (max - min) / 100;
			int value = 0;
			while (flag) {
				progressBar.setLabel(MainAppTextResource.PROGRESS_THREAD_CONNECTING);
				value = progressBar.getValue() + next;
				if (value >= max) {
					value = min;
				}
				progressBar.setValue(value);
				Thread.sleep(153);
			}
			progressBar.setLabel(Constant.EMPTY_STRING);
			progressBar.setValue(0);
			// To remove progress bar.
			Application.getApplication().invokeLater(new Runnable() {
				public void run() {
					synchronized (Application.getEventLock()) {
						screen.delete(progressBar);
					}
				}
			});
		} catch (Exception e) {
			Log.error("ProgressThread.run()", null, e);
		}
	}
}
