package com.vvt.connectionhistorymanager;



/**
 * @author Aruna
 * @version 1.0
 * @created 07-Nov-2011 04:46:52
 */
public interface ConnectionHistoryManager {

	public void addConnectionHistory(ConnectionHistoryEntry e);
	
	public void clearAllHistory();
	
	public String getAllHistory();

	public int getHistroyCount();

	public void setMaximumEntry(int maxEntry);
	
	public ConnectionHistoryEntry getLastConnection();
}