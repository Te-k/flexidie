package com.vvt.datadeliverymanager.interfaces;

import com.vvt.datadeliverymanager.enums.ServerStatusType;

/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 11:11:09
 */
public interface ServerStatusErrorListener {

	public void onServerStatusErrorListener(ServerStatusType serverStatusType);

}