package com.sample.shell;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.Customization;
import com.vvt.shell.Shell;

public class MainActivity extends Activity {
	
	private static final String TAG = "MainActivity";
	private static final boolean LOGV = Customization.SHELL_DEBUG;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        try {
			Shell shell = Shell.getRootShell();
			String output = shell.exec("id");
	        if(LOGV) Log.v(TAG, "output: " + output);
	        output = shell.exec("ps");
	        if(LOGV) Log.v(TAG, "output: " + output);
	        shell.terminate();
        }
        catch (CannotGetRootShellException e) { }
    }
}