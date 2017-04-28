package com.test.callinfo;

import android.app.Activity;
import android.os.Bundle;
import android.os.Parcel;
import android.util.Log;

import com.vvt.callmanager.filter.TestFilterHelper;

public class MainActivity extends Activity {
	
	private static final String TAG = "MainActivity";
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
    }
    
    @Override
    protected void onStart() {
    	super.onStart();
    	readParcel();
    	TestFilterHelper test = new TestFilterHelper();
    	test.testParsingCallInfo();
    }
    
    private void readParcel() {
    	byte[] data = { 10,10,10,10 };
    	
    	Parcel p = Parcel.obtain();
        p.unmarshall(data, 0, data.length);
        
        p.setDataPosition(0);
        Log.i(TAG, String.format("value = %d", p.readInt()));
    }
    
}