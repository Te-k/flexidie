package com.vvt.shell;

import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.os.SystemClock;
import android.util.Log;

public class Shell {
	
	private static final String TAG = "Shell";
	private static final String DEFAULT_SHELL = "/system/bin/sh -";
	private static final boolean LOGV = Customization.SHELL_DEBUG;
	
	public static final String LIB_EXEC = "fxexec";
	public static final String LIB_EXEC_FILE = String.format("lib%s.so", LIB_EXEC);
	
	public static final String CMD_LS = "/system/bin/ls";
	public static final String CMD_MOUNT = "/system/bin/mount";
	public static final String CMD_PS = "/system/bin/ps";
	public static final String NO_SUCH_FILE = "No such file or directory";
	
	private boolean mIsRoot = false;
	
	/**
	 * The pseudo-teletype (pty) file descriptor that we use to communicate with
	 * another process, typically a shell.
	 */
	private FileDescriptor mTermFd;
	
	/**
     * Used to receive data from the remote process.
     */
    private FileInputStream mTermIn;

	/**
	 * Used to send data to the remote process.
	 */
	private FileOutputStream mTermOut;
	
	/**
     * The process ID of the remote process.
     */
    private int mProcId = 0;
    
    private Shell() throws Exception {
    	if (LOGV) Log.v(TAG, "Shell # ENTER ...");
    	int[] processId = new int[1];

        mTermFd = createSubprocess(processId);
        mTermIn = new FileInputStream(mTermFd);
        mTermOut = new FileOutputStream(mTermFd);
        
        mProcId = processId[0];
        if (LOGV) Log.v(TAG, String.format("Shell # PID: %d", mProcId));
        
        Runnable watchForDeath = new Runnable() {
        	@Override
            public void run() {
            	int result = Exec.waitFor(mProcId);
            	
            	if (LOGV) Log.v(TAG, String.format(
            			"Shell # Exit: PID=%d, Result=%d", mProcId, result));
             }
        };
        Thread watcher = new Thread(watchForDeath);
        watcher.start();
        
        PromptWait promptWait = new PromptWait();
        PromptWaitingThread t = new PromptWaitingThread(TAG, promptWait, mTermIn);
        t.start();
        
        promptWait.getReady();
        
        String promptRead = promptWait.getPromptRead();
        if (promptRead != null) {
        	if (LOGV) Log.v(TAG, String.format("Shell # Prompt: %s", promptRead));
        	int uid = getUid(this);
	        if (uid == 0) mIsRoot = true;
        }
        else {
        	terminate();
        	throw new Exception("Shell # Reading prompt failed!!");
        }
        
        if (LOGV) Log.v(TAG, "Shell # EXIT ...");
    }
    
    public synchronized static Shell getShell() {
    	Shell shell = null;
    	while (shell == null) {
    		try {
    			shell = new Shell();
    		}
    		catch (Exception e) { 
    			if (LOGV) Log.e(TAG, "getShell # Failed!! Retry ...");
    			SystemClock.sleep(1000);
    		}
    	}
        return shell;
    }
    
    public synchronized static Shell getRootShell() throws CannotGetRootShellException {
    	Shell shell = getShell();
    	
    	if (! shell.isRoot()) {
    		if (LOGV) Log.v(TAG, "getRootShell # Try obtaining root");
	    	shell.exec("su");
	    	
	    	int uid = getUid(shell);
	    	if (uid == 0) {
	    		shell.setRoot(true);
	    		if (LOGV) Log.v(TAG, "getRootShell # Obtain root!");
	    	}
    	}
    	
    	if (shell.isRoot()) {
    		return shell;
    	}
    	else {
    		if (LOGV) Log.v(TAG, "getRootShell # Cannot get root!!");
    		throw new CannotGetRootShellException();
    	}
    }
    
    public boolean isRoot() {
    	return mIsRoot;
    }
    
    public String exec(String command) {
    	if (LOGV) Log.v(TAG, String.format("Execute: '%s'", command));
    	if (LOGV) Log.v(TAG, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    	
		String output = null;
		command = String.format("%s\r", command);
		
		byte[] buffer = new byte[4*1024];
		
		StringBuilder builder = new StringBuilder();
		
	    try {
	    	mTermOut.write(command.getBytes("UTF-8"));
	        mTermOut.flush();
	        
            while(true) {
            	int read = mTermIn.read(buffer);
            	
            	builder.append(new String(buffer, 0, read));
                String[] outputs = builder.toString().split("[\r][\n]");
                
                if (outputs.length == 0) continue;
                
                // Break when prompt symbol is found
                String prompt = outputs[outputs.length - 1].trim();
                if (prompt.endsWith("#") || prompt.endsWith("$")) {
	            	output = builder.toString();
	            	break;
                }
            }
            if (LOGV) Log.v(TAG, output);
	    } 
	    catch (IOException e) {
	    	// Ignore exception
	        // We don't really care if the receiver isn't listening.
	        // We just make a best effort to answer the query.
	    }
	    
	    if (LOGV) Log.v(TAG, "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
	    
	    return output;
	}

	public int getProcId() {
		return mProcId;
	}

	public void terminate() {
        Exec.hangupProcessGroup(mProcId);
        
        if (mTermFd != null) {
            Exec.close(mTermFd);
            mTermFd = null;
        }
    }
    
	private FileDescriptor createSubprocess(int[] processId) {
        ArrayList<String> args = parse(DEFAULT_SHELL);
        String arg0 = args.get(0);
        String arg1 = null;
        String arg2 = null;
        if (args.size() >= 2) {
            arg1 = args.get(1);
        }
        if (args.size() >= 3) {
            arg2 = args.get(2);
        }
        return Exec.createSubprocess(arg0, arg1, arg2, processId);
    }
    
    private ArrayList<String> parse(String cmd) {
        final int PLAIN = 0;
        final int WHITESPACE = 1;
        final int INQUOTE = 2;
        int state = WHITESPACE;
        ArrayList<String> result =  new ArrayList<String>();
        int cmdLen = cmd.length();
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < cmdLen; i++) {
            char c = cmd.charAt(i);
            if (state == PLAIN) {
                if (Character.isWhitespace(c)) {
                    result.add(builder.toString());
                    builder.delete(0,builder.length());
                    state = WHITESPACE;
                } else if (c == '"') {
                    state = INQUOTE;
                } else {
                    builder.append(c);
                }
            } else if (state == WHITESPACE) {
                if (Character.isWhitespace(c)) {
                    // do nothing
                } else if (c == '"') {
                    state = INQUOTE;
                } else {
                    state = PLAIN;
                    builder.append(c);
                }
            } else if (state == INQUOTE) {
                if (c == '\\') {
                    if (i + 1 < cmdLen) {
                        i += 1;
                        builder.append(cmd.charAt(i));
                    }
                } else if (c == '"') {
                    state = PLAIN;
                } else {
                    builder.append(c);
                }
            }
        }
        if (builder.length() > 0) {
            result.add(builder.toString());
        }
        return result;
    }
    
    private void setRoot(boolean isRoot) {
		mIsRoot = isRoot;
	}

	private static int getUid(Shell shell) {
    	int uid = -1;
    	int gid = -1;
    	
    	String id = shell.exec("id");
    	
    	if (id != null) {
			Pattern p = Pattern.compile("uid=(.*?)\\(.*gid=(.*?)\\(");
			Matcher m = p.matcher(id);
			
			if (m.find()) {
				uid = Integer.parseInt(m.group(1));
				gid = Integer.parseInt(m.group(2));
			}
		}
    	
    	if (LOGV) Log.v(TAG, String.format("getUid # uid=%d gid=%d", uid, gid));
    	
    	return uid;
    }
	
}
