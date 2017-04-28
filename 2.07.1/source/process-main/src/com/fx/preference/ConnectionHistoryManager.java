package com.fx.preference;

import java.util.List;

import android.net.Uri;

import com.fx.activation.Response;
import com.fx.preference.model.ConnectionHistory;

public interface ConnectionHistoryManager {
	
	public static final Uri URI_NEW_RECORD_ADDED = 
			Uri.parse("content://com.fx.pref/new_conn_history_added");

	public void addConnectionHistory(ConnectionHistory connectionHistory);
	public List<ConnectionHistory> getConnectionHistoryList();
	public ConnectionHistory getLatestConnectionHistory();
	
	public void setActivationResponse(Response response);
	public Response getActivationResponse();
}
