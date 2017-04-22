package com.vvt.pinc;

import net.rim.blackberry.api.mail.Message;

public interface PinListener {

	public void done(String msg);
	public void error(String msg);	
	public void pinMessageAdded(Message message);
	
}
