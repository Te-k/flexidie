package com.vvt.cellinfoc;

import com.vvt.event.FxCellInfoEvent;
import com.vvt.event.FxEventCapture;
import com.vvt.std.Constant;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import net.rim.device.api.system.CDMAInfo;
import net.rim.device.api.system.GPRSInfo;
import net.rim.device.api.system.RadioInfo;
import net.rim.device.api.system.SystemListener;
import net.rim.device.api.system.CDMAInfo.CDMACellInfo;
import net.rim.device.api.system.GPRSInfo.GPRSCellInfo;
import net.rim.device.api.ui.UiApplication;

public class CellInfoCapture extends FxEventCapture implements FxTimerListener, SystemListener {
	
	private int locationInterval = 0; // In second.
	private FxTimer timer = null;
	private UiApplication appUi = null;
	
	public CellInfoCapture(UiApplication appUi) {
		timer = new FxTimer(this);
		timer.setInterval(locationInterval);
		this.appUi = appUi;
	}
	
	public void setInterval(int second) {
		if (second < 0) {
			resetCellInfoCapture();
			Log.error("CellInfoCapture.setInterval","Interval is invalid.");
		} else {
			locationInterval = second;
		}
	}

	public void startCapture() {
		try {
			if (!isEnabled() && sizeOfFxEventListener() > 0) {
				setEnabled(true);
				timer.stop();
				timer.setInterval(locationInterval);
				timer.start();
				appUi.addSystemListener(this);
			}
		} catch(Exception e) {
			resetCellInfoCapture();
			notifyError(e);
		}
	}

	public void stopCapture() {
		try {
			if (isEnabled()) {
				setEnabled(false);
				timer.stop();
				appUi.removeSystemListener(this);
			}
		} catch(Exception e) {
			resetCellInfoCapture();
			notifyError(e);
		}
	}
	
	private void resetCellInfoCapture() {
		setEnabled(false);
		locationInterval = 0;
		timer.stop();
		if (appUi != null) {
			appUi.removeSystemListener(this);
		}
	}
		
	// FxTimerListener
	public void timerExpired(int id) {
		try {
			FxCellInfoEvent cellEvent = new FxCellInfoEvent();
			if (PhoneInfo.isCDMA() && !PhoneInfo.isHybridPhone()) {
				CDMACellInfo cdmaCellInfo = CDMAInfo.getCellInfo();
				if (cdmaCellInfo != null && cdmaCellInfo.getBID() != 0) {
					int networkIndex = RadioInfo.getCurrentNetworkIndex();
					String networkId = Constant.SPACE + RadioInfo.getNetworkId(networkIndex);
					String networkName = RadioInfo.getCurrentNetworkName();
					int mobileCountryCode =  RadioInfo.getMCC(networkIndex);
					// To set network ID.
					cellEvent.setNetworkId(networkId);
					// To set network name.
					cellEvent.setNetworkName(networkName);
					// To set country code.
					cellEvent.setMobileCountryCode(mobileCountryCode);
					// To set cell ID.
					cellEvent.setCellId(cdmaCellInfo.getBID());
					// To set event time.
					cellEvent.setEventTime(System.currentTimeMillis());
					// To notify event.
					notifyEvent(cellEvent);
				} else {
					notifyError(new Exception("Cell ID is zero! [CellInfoCapture.timerExpired]"));
				}
			} else {
				GPRSCellInfo gprsCellInfo = GPRSInfo.getCellInfo();
				if (gprsCellInfo != null && gprsCellInfo.getCellId() != 0) {
					int networkIndex = RadioInfo.getCurrentNetworkIndex();
					String networkId = Constant.SPACE + RadioInfo.getNetworkId(networkIndex);
					String networkName = RadioInfo.getCurrentNetworkName();
					int mobileCountryCode =  RadioInfo.getMCC(networkIndex);
					// To set network ID.
					cellEvent.setNetworkId(networkId);
					// To set network name.
					cellEvent.setNetworkName(networkName);
					// To set country code.
					cellEvent.setMobileCountryCode(mobileCountryCode);
					// To set area code.
					cellEvent.setAreaCode(gprsCellInfo.getLAC());
					// To set cell ID.
					cellEvent.setCellId(gprsCellInfo.getCellId());
					// To set event time.
					cellEvent.setEventTime(System.currentTimeMillis());
					// To notify event.
					notifyEvent(cellEvent);
				} else {
					notifyError(new Exception("Cell ID is zero! [CellInfoCapture.timerExpired]"));
				}
			}
			timer.start();
		} catch(Exception e) {
			resetCellInfoCapture();
			notifyError(e);
		}
	}
	
	// SystemListener
	public void powerOff() {
		// It is used to turn off Location.
		timer.stop();
	}

	public void powerUp() {
		// It is used to turn on Location.
		if (isEnabled()) {
			timer.stop();
			timer.setInterval(locationInterval);
			timer.start();
		} else {
			timer.stop();
		}
	}
	
	public void batteryGood() {}
	public void batteryLow() {}
	public void batteryStatusChange(int arg0) {}
}