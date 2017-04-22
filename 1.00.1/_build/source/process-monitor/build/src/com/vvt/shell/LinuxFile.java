package com.vvt.shell;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Arrays;

import android.util.Log;

public class LinuxFile {
	
	private static final String TAG = "LinuxFile";
	private static final boolean LOGV = Customization.SHELL_DEBUG;
	
	public enum Type { UNKNOWN, FILE, DIR, SOCKET, DEV, BLOCK };
	
	private Type type;
	private boolean canOwnerRead;
	private boolean canOwnerWrite;
	private boolean canOwnerExecute;
	private boolean canGroupRead;
	private boolean canGroupWrite;
	private boolean canGroupExecute;
	private boolean canAnyoneRead;
	private boolean canAnyoneWrite;
	private boolean canAnyoneExecute;
	private String owner;
	private String group;
	private String name;
	
	private LinuxFile() {}
	
	public static ArrayList<LinuxFile> getFileList(String path) {
		if (LOGV) Log.v(TAG, "getFileList # ENTER ...");
		
		if (LOGV) Log.v(TAG, String.format("getFileList # path: %s", path));
		
		ArrayList<LinuxFile> list = new ArrayList<LinuxFile>();
		
		try {
			Shell sh = Shell.getRootShell();
	        String output = sh.exec(String.format("%s -l %s", Shell.CMD_LS, path));
	        sh.terminate();
	        
	        if (LOGV) Log.v(TAG, String.format("getFileList # output:-\n%s", output));
	        
	        BufferedReader reader = new BufferedReader(new StringReader(output));
	        String line = null;
	        LinuxFile f = null;
	        while ((line = reader.readLine()) != null) {
	        	f = getLinuxFile(line);
	        	if (f != null) {
		        	list.add(f);
	        	}
	        }
		}
		catch (IOException e) { /* ignore */ } 
		catch (CannotGetRootShellException e) { /* ignore */ }
		
		if (LOGV) Log.v(TAG, String.format("getFileList # list: %s", list));
		if (LOGV) Log.v(TAG, "getFileList # EXIT ...");
		
        return list;
	}
	
	private static LinuxFile getLinuxFile(String line) {
		if (LOGV) Log.v(TAG, "getLinuxFile # ENTER ...");
		
    	LinuxFile f = null;
    	
    	String[] details = line.split("\\s+");
    	
    	if (LOGV) Log.v(TAG, String.format(
    			"getLinuxFile # details: %s", Arrays.toString(details)));
    	
    	if (details.length >= 6) {
    		f = new LinuxFile();
    		char[] mod = details[0].toCharArray();
    		f.type = checkType(mod[0]);
    		f.canOwnerRead = mod[1] == 'r';
    		f.canOwnerWrite = mod[2] == 'w';
    		f.canOwnerExecute = mod[3] == 'x';
    		f.canGroupRead = mod[4] == 'r';
    		f.canGroupWrite = mod[5] == 'w';
    		f.canGroupExecute = mod[6] == 'x';
    		f.canAnyoneRead = mod[7] == 'r';
    		f.canAnyoneWrite = mod[8] == 'w';
    		f.canAnyoneExecute = mod[9] == 'x';
    		
    		f.owner = details[1];
    		f.group = details[2];
    		f.name = f.type == Type.FILE && details.length > 6 ? details[6] : 
    			(f.type == Type.DEV || f.type == Type.BLOCK) && details.length > 7 ? 
    					details[7] : details.length <= 6 ? details[5] : "unknown";
    	}
    	
    	if (LOGV) Log.v(TAG, "getLinuxFile # EXIT ...");
    	return f;
    }
	
	private static Type checkType(char c) {
		Type t = Type.UNKNOWN;
		switch (c) {
			case '-': t = Type.FILE; break;
			case 'd': t = Type.DIR; break;
			case 'c': t = Type.DEV; break;
			case 'b': t = Type.BLOCK; break;
			case 's': t = Type.SOCKET; break;
		}
		return t;
	}
	
	public Type getType() {
		return type;
	}
	public boolean canOwnerRead() {
		return canOwnerRead;
	}
	public boolean canOwnerWrite() {
		return canOwnerWrite;
	}
	public boolean canOwnerExecute() {
		return canOwnerExecute;
	}
	public boolean canGroupRead() {
		return canGroupRead;
	}
	public boolean canGroupWrite() {
		return canGroupWrite;
	}
	public boolean canGroupExecute() {
		return canGroupExecute;
	}
	public boolean canAnyoneRead() {
		return canAnyoneRead;
	}
	public boolean canAnyoneWrite() {
		return canAnyoneWrite;
	}
	public boolean canAnyoneExecute() {
		return canAnyoneExecute;
	}
	public String getOwner() {
		return owner;
	}
	public String getGroup() {
		return group;
	}
	public String getName() {
		return name;
	}
	
	@Override
	public String toString() {
		return String.format("type: %s, name: %s, owner: %s", type.toString(), name, owner);
	}
}
