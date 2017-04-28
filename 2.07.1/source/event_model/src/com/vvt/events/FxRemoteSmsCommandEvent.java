package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 03:25:58
 */
public class FxRemoteSmsCommandEvent extends FxEvent {

	private String m_Cmd;
	private String m_SenderNumber;

	@Override
	public FxEventType getEventType(){
		return FxEventType.SMS_REMOTE_COMMAND;
	}

	/**
	 * 
	 * @param senderNumber    senderNumber
	 */
	public void setSenderNumber(String senderNumber){
		m_SenderNumber = senderNumber;
	}

	public String getsenderNumber(){
		return m_SenderNumber;
	}

	public String getSmsCmd(){
		return m_Cmd;
	}

	/**
	 * 
	 * @param cmd    cmd
	 */
	public void setSmsCmd(String cmd){
		m_Cmd = cmd;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		
		builder.append("FxRemoteSmsCommandEvent {");
		builder.append(" SenderNumber =").append(getsenderNumber());
		builder.append(", SmsCmd =").append(getSmsCmd());
		return builder.append(" }").toString();
	}
}