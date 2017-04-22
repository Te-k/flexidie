package com.vvt.connectionhistorymanager;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.StreamCorruptedException;
import java.text.SimpleDateFormat;
import java.util.Iterator;
import java.util.LinkedList;

import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;

/**
 * @author Aruna
 * @version 1.0
 * @created 07-Nov-2011 04:46:54
 */
public class ConnectionHistoryRepository {
	private static final String TAG = "ConnectionHistoryRepository";
	@SuppressWarnings("unused")
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	private static final String FILENAME = "connectionhistoryrepo.ser";
	
	private String writablePath;
	
	public ConnectionHistoryRepository(String writablePath) {
		this.writablePath = writablePath;
	}
	
	public LinkedList<ConnectionHistoryEntry> getAll() {
		return open();
	}

	/**
	 * 
	 * @param entry
	 */
	public void insert(ConnectionHistoryEntry entry) {
		LinkedList<ConnectionHistoryEntry> list = getAll();
		list.addFirst(entry);
		save(list);
	}
	
	@SuppressWarnings("unchecked")
	private LinkedList<ConnectionHistoryEntry> open() {
		// use buffering
		InputStream file;
		LinkedList<ConnectionHistoryEntry> repo = new LinkedList<ConnectionHistoryEntry>();

		try {

			final File persistedFile = getPersisedFile();

			if (persistedFile.exists()) {
				file = new FileInputStream(persistedFile);

				InputStream buffer = new BufferedInputStream(file);
				ObjectInput input = new ObjectInputStream(buffer);

				try {
					repo = (LinkedList<ConnectionHistoryEntry>) input.readObject();
				} catch (ClassNotFoundException e) {
					FxLog.e(TAG, e.toString());
				} finally {
					input.close();
				}
			} else {
				return repo;
			}

		} catch (FileNotFoundException e) {
			if (LOGE) FxLog.e(TAG, e.toString());
		} catch (StreamCorruptedException e) {
			if (LOGE) FxLog.e(TAG, e.toString());
		} catch (IOException e) {
			if (LOGE) FxLog.e(TAG, e.toString());
		}

		return repo;
	}

	private File getPersisedFile() {
		final File persistedFile = new File(Path.combine(writablePath, FILENAME));
		return persistedFile;
	}
	
	private void save(LinkedList<ConnectionHistoryEntry> list) {
		try {
			final File persistedFile = getPersisedFile();
			
			OutputStream file = new FileOutputStream(persistedFile);
			OutputStream buffer = new BufferedOutputStream(file);
			ObjectOutput output = new ObjectOutputStream(buffer);
			try {
				output.writeObject(list);
			} finally {
				output.close();
			}
		} catch (IOException e) {
			if (LOGE) FxLog.e(TAG, e.toString());
		}
	}

	public boolean deleteAll() {
		final File persistedFile = getPersisedFile();
		
		if(persistedFile.exists()) {
			return persistedFile.delete();
		}
		else		
			return true;
	}

	public int getHistroyCount() {
		return open().size();
	}

	public String getAllHistoryAsString() {
		LinkedList<ConnectionHistoryEntry> list = getAll();
		StringBuilder db = new StringBuilder();
		Iterator<ConnectionHistoryEntry> it = list.iterator();
		int counter = 1;
		
		while (it.hasNext()) {
			ConnectionHistoryEntry entry = (ConnectionHistoryEntry) it.next();
			
			if(db.length() != 0) {
				db.append("\n").append("\n");
			}
			
			db.append("No: ").append(counter).append("\n");
			db.append("Action: ").append(CommandCode.toReadableName(entry.getAction())).append("\n");
			db.append("Connection Type: ");
			
			if(entry.getConnectionType() == ConnectionType.GPRS) {
				db.append("GPRS").append("\n");
			}
			else if(entry.getConnectionType() == ConnectionType.WIFI) {
				db.append("Wireless LAN").append("\n");
			}
			else {
				db.append("UNKNOWN").append("\n");
			}
			
			db.append("Status: ");
			if(entry.getStatus() == Status.SUCCESS) {
				db.append("Operation success").append("\n");
			}
			else {
				db.append("Operation failed").append("\n");
				
				db.append("Message: ");
				db.append(entry.getMessage()).append("[").append(entry.getStatusCode()).append("]") .append("\n");
			}
			 
			db.append("APN: ");
			db.append(entry.getAPN()).append("\n");
			
			db.append("Date: ");
			
			String time = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(entry.getDate());
			db.append(time);
			
			counter += 1;
		}
		
		return db.toString();
	}

	public void deleteOldestEntry() {
		LinkedList<ConnectionHistoryEntry> list = open();
		list.remove(list.getLast());
		save(list);
	}

	public ConnectionHistoryEntry getLastConnection() {
		ConnectionHistoryEntry firstElement = null;
		LinkedList<ConnectionHistoryEntry> list = open();
		
		try {
			firstElement = list.getFirst();
		}
		catch(Throwable ex) {}
		
		return firstElement;
	}

}