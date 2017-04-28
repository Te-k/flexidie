package com.sample.smspdu;

import android.app.Activity;
import android.os.Bundle;


public class MainActivity extends Activity {
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
    }
    
    @Override
    protected void onStart() {
    	super.onStart();
    	TestSmsDecoding test = new TestSmsDecoding();
    	test.testPrintSms();
    }
    
}