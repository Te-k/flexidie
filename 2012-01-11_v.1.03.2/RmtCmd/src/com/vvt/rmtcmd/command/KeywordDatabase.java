package com.vvt.rmtcmd.command;

import java.util.Vector;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;

public class KeywordDatabase {

	private static final long KEYWORD_GUID = 0xa226dcdd481c823aL;
	private static final long KEYWORD_ID = 0x8a01f9b42e78763aL;
	private static KeywordDatabase self = null;
	private KeywordStore kwStore = null;
	private PersistentObject kwPersistence = null;
	
	private KeywordDatabase() {
		kwPersistence = PersistentStore.getPersistentObject(KEYWORD_ID);
		kwStore = (KeywordStore) kwPersistence.getContents();
		if (kwStore == null) {
			kwStore = new KeywordStore();
			kwPersistence.setContents(kwStore);
			kwPersistence.commit();
		}
	}
	
	public static KeywordDatabase getInstance() {
		if (self == null) {
			self = (KeywordDatabase)RuntimeStore.getRuntimeStore().get(KEYWORD_GUID);
			if (self == null) {
				KeywordDatabase number = new KeywordDatabase();
				RuntimeStore.getRuntimeStore().put(KEYWORD_GUID, number);
				self = number;
			}
		}
		return self;
	}
	
	public void addKeyword(String keyword) {
		kwStore.addKeyword(keyword);		
	}
	
	public String getKeyword(int index) {
		return kwStore.getKeyword(index);
	}
	
	public Vector getKeywordStore() {
		return kwStore.getKeywordStore();
	}

	public void clearKeyword() {
		kwStore.clearKeyword();
	}
	
	public int countKeyword() {
		return kwStore.countKeyword();
	}
	
	public synchronized void commit() {
		kwPersistence.setContents(kwStore);
		kwPersistence.commit();
	}
}
