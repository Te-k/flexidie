package com.fx.dalvik.preference;

import java.util.List;

import com.fx.dalvik.preference.model.ConnectionHistory;

public interface ConnectionHistoryManager {

	public void addConnectionHistory(ConnectionHistory connectionHistory);
	public List<ConnectionHistory> getConnectionHistoryList();
	public ConnectionHistory getLatestConnectionHistory();
}
