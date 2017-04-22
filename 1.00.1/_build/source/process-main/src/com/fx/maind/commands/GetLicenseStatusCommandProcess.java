package com.fx.maind.commands;

import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.GetLicenseStatusCommand;
import com.daemon_bridge.GetLicenseStatusCommandResponse;
import com.fx.maind.ref.Customization;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;

public class GetLicenseStatusCommandProcess {
	private static final String TAG = "GetLicenseStatusCommandProcess";
	private static final boolean VERBOSE = true;
	private static boolean LOGV = Customization.DEBUG ? VERBOSE : false;
	
	public static GetLicenseStatusCommandResponse execute(AppEngine appEngine, GetLicenseStatusCommand getLicenseStatusCommand) {
		if(LOGV) FxLog.d(TAG, "# execute START");
		
		LicenseManager licenseManager = appEngine.getLicenseManager();
		GetLicenseStatusCommandResponse commandResponse  = null;
		
		try {
			LicenseStatus licenseStatus  = licenseManager.getLicenseInfo().getLicenseStatus();
			if(LOGV) FxLog.d(TAG, "# application licenseStatus :" + licenseStatus);
			
			GetLicenseStatusCommandResponse.LicenseStatus licenseStatus2 = GetLicenseStatusCommandResponse.LicenseStatus.valueOf(licenseStatus.name());
			
			commandResponse = new GetLicenseStatusCommandResponse(CommandResponseBase.SUCCESS);
			commandResponse.setStatusCode(licenseStatus2);
			
			if(LOGV) FxLog.d(TAG, "# execute licenseStatus2 is" + licenseStatus2.toString());
		}
		catch(Throwable t) {
			if(LOGV) FxLog.e(TAG, t.toString());
			commandResponse = new GetLicenseStatusCommandResponse(CommandResponseBase.ERROR);
		}
		
		if(LOGV) FxLog.d(TAG, "# execute EXIT");
		return commandResponse;
	}
}
