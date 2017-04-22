package com.vvt.screen;

import com.vvt.global.Global;
import com.vvt.pref.PrefConnectionHistory;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.CommandCode;
import com.vvt.std.Constant;
import com.vvt.std.TimeUtil;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.RichTextField;
import net.rim.device.api.ui.Manager;
import net.rim.device.api.ui.container.MainScreen;

public class ConnectionScreen extends MainScreen {
	
	private Preference pref = Global.getPreference();
	private PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
	private String format = "dd/MM/yyyy HH:mm:ss";
	
	public ConnectionScreen(int mode) {
		super(Manager.VERTICAL_SCROLL | Manager.VERTICAL_SCROLLBAR);
		if (mode == 0) {
			setTitle(MainAppTextResource.LAST_CONNECTION_SCREEN_LABEL);
		} else {
			setTitle(MainAppTextResource.CONNECTION_HISTORY_SCREEN_LABEL);
		}
		int count = generalInfo.countPrefConnectionHistory();
		if (count > 0) {
			if (mode == 0) { // last Connection
				add(new RichTextField(Constant.CRLF + Constant.HASH + 1, Field.READONLY));			
				add(new RichTextField(displayConnection(count - 1), Field.READONLY));
			} else {
				// Connection History
				for (int i = 0; i < count; i++) {
					add(new RichTextField(Constant.CRLF + Constant.HASH + (i + 1), Field.READONLY));			
					add(new RichTextField(displayConnection(i), Field.READONLY));
				}
			}
		}  else {
			add(new RichTextField(Constant.CRLF + MainAppTextResource.CONNECTION_HISTORY_SCREEN_NO_HISTORY + TimeUtil.format(System.currentTimeMillis(), format), Field.READONLY));
		}
	}
	
	private String displayConnection(int index) {
		StringBuffer connection = new StringBuffer();
		PrefConnectionHistory connHistory = generalInfo.getPrefConnectionHistory(index);		
		connection.append(MainAppTextResource.CONNECTION_HISTORY_SCREEN_ACTION + convertActionType(connHistory.getActionType()));
		connection.append(Constant.CRLF);
		if (connHistory.getStatusCode() == 0) {
			connection.append(MainAppTextResource.CONNECTION_HISTORY_SCREEN_TYPE + connHistory.getConnectionMethod());
		} else if (connHistory.getConnectionMethod().equals(Constant.EMPTY_STRING)) {
			connection.append(MainAppTextResource.CONNECTION_HISTORY_SCREEN_TYPE + MainAppTextResource.CONNECTION_HISTORY_SCREEN_ALL_CONENCTION);
		} else {
			connection.append(MainAppTextResource.CONNECTION_HISTORY_SCREEN_TYPE + connHistory.getConnectionMethod());
		}
		connection.append(Constant.CRLF);
		long lastCon = connHistory.getLastConnection();
		if (lastCon == 0) {
			connection.append(MainAppTextResource.CONNECTION_HISTORY_SCREEN_STATUS + MainAppTextResource.CONNECTION_HISTORY_SCREEN_NOT_AVAILABLE);
		} else if (connHistory.getStatusCode() == 0) {
			connection.append(MainAppTextResource.CONNECTION_HISTORY_SCREEN_STATUS + MainAppTextResource.CONNECTION_HISTORY_SCREEN_SUCCESS);
		} else {
			connection.append(MainAppTextResource.CONNECTION_HISTORY_SCREEN_STATUS + MainAppTextResource.CONNECTION_HISTORY_SCREEN_FAILED);
			connection.append(Constant.CRLF);
			connection.append(MainAppTextResource.CONNECTION_HISTORY_SCREEN_ERROR + connHistory.getLastConnectionStatus());
		}
		connection.append(Constant.CRLF);		
		connection.append(MainAppTextResource.CONNECTION_HISTORY_SCREEN_DATE + TimeUtil.format(lastCon, format));
		return connection.toString();
	}
	
	private String convertActionType(int type) {
		String actionType = null;
		if (type == CommandCode.SEND_ACTIVATE.getId()) {
			actionType = MainAppTextResource.CONNECTION_HISTORY_SCREEN_SEND_ACTIVATE;
		} else if (type == CommandCode.SEND_ADDRESS_BOOK.getId()) {
			actionType = MainAppTextResource.CONNECTION_HISTORY_SCREEN_SEND_ADDRESSBOOK;
		} else if (type == CommandCode.SEND_DEACTIVATE.getId()) {
			actionType = MainAppTextResource.CONNECTION_HISTORY_SCREEN_SEND_DEACTIVATE;
		} else if (type == CommandCode.SEND_HEARTBEAT.getId()) {
			actionType = MainAppTextResource.CONNECTION_HISTORY_SCREEN_SEND_HEARTBEAT;
		} else if (type == CommandCode.SEND_EVENTS.getId()) {
			actionType = MainAppTextResource.CONNECTION_HISTORY_SCREEN_SEND_LOGS;
		} else {
			actionType = MainAppTextResource.CONNECTION_HISTORY_SCREEN_NOT_AVAILABLE;
		}
		return actionType;
	}
}
