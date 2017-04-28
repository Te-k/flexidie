package com.vvt.connectionhistorymanager;




/**
 * @author Aruna
 * @version 1.0
 * @created 07-Nov-2011 04:46:54
 */
public class ConnectionHistoryManagerImp implements ConnectionHistoryManager {
	
	private String mWritablePath;
	public int mMaxRepoEntries = 50;
	
	public ConnectionHistoryManagerImp(String writablePath) {
		this.mWritablePath = writablePath;
	}

	public synchronized void addConnectionHistory(ConnectionHistoryEntry entry) {
		ConnectionHistoryRepository repo = new ConnectionHistoryRepository(mWritablePath);
		
		if(repo.getHistroyCount() >= mMaxRepoEntries) {
			repo.deleteOldestEntry();
		}
		
		repo.insert(entry);
	}

	public synchronized void clearAllHistory() {
		ConnectionHistoryRepository repo = new ConnectionHistoryRepository(mWritablePath);
		repo.deleteAll();
	}
 
	public synchronized int getHistroyCount() {
		ConnectionHistoryRepository repo = new ConnectionHistoryRepository(mWritablePath);
		return repo.getHistroyCount();
	}

	public synchronized void setMaximumEntry(int maxEntry) {
		mMaxRepoEntries = maxEntry;
	}

	public synchronized String getAllHistory() {
		ConnectionHistoryRepository repo = new ConnectionHistoryRepository(mWritablePath);
		return repo.getAllHistoryAsString();
	}

	public synchronized ConnectionHistoryEntry getLastConnection() {
		ConnectionHistoryRepository repo = new ConnectionHistoryRepository(mWritablePath);
		return repo.getLastConnection();
	}
}