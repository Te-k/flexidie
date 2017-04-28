package com.vvt.screen;

import com.vvt.global.Global;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.ui.resource.MainAppTextResource;
import com.vvt.version.VersionInfo;
import net.rim.device.api.system.Application;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.container.PopupScreen;
import net.rim.device.api.ui.container.VerticalFieldManager;

public class AboutPopup extends PopupScreen {
	
	private LicenseManager license = Global.getLicenseManager();
	private LicenseInfo licenseInfo = null;
	
	public AboutPopup() {
		super(new VerticalFieldManager(Field.USE_ALL_WIDTH | Field.USE_ALL_HEIGHT));
		try {
			licenseInfo = license.getLicenseInfo();
			add(new LabelField(Constant.SPACE, Field.NON_FOCUSABLE));
			StringBuffer ver = new StringBuffer();
			ver.append(MainAppTextResource.ABOUT_POPUP_PRODUCT_ID + VersionInfo.getProductId());
			ver.append(Constant.CRLF);
			ver.append(MainAppTextResource.ABOUT_POPUP_PRODUCT_CONFIG + licenseInfo.getProductConfID());
			ver.append(Constant.CRLF);
			ver.append(MainAppTextResource.ABOUT_POPUP_APP_VERSION + VersionInfo.getFullVersion());
			ver.append(Constant.CRLF);
			ver.append(VersionInfo.getDescription());
			add(new LabelField(ver.toString(), Field.NON_FOCUSABLE));
		} catch(Exception e) {
			Log.error("AboutPopup.constructor", null, e);
		}
	}

	public boolean onClose() {
		UiApplication.getUiApplication().popScreen(this);
		return true;
	}
}