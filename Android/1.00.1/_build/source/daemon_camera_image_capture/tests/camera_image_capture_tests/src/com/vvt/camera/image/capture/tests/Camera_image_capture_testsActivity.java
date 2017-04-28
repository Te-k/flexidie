package com.vvt.camera.image.capture.tests;

import java.util.List;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

import com.vvt.appcontext.AppContext;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.capture.camera.image.FxCameraImageCapture;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.logger.FxLog;

public class Camera_image_capture_testsActivity extends Activity {
	private TextView mTextView;  
	private AppContext mAppContext;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        mTextView = (TextView)findViewById(R.id.textView);
       
        mAppContext = new AppContextImpl(this);
        
        EventListener eventListener = new EventListener();
        
        FxCameraImageCapture cameraImageCapture = new FxCameraImageCapture(mAppContext);
        
        try {
        	cameraImageCapture.register(eventListener);
			cameraImageCapture.startCapture();
		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}

    }
    
    class EventListener implements FxEventListener
    {
    	@Override
    	public void onEventCaptured(final List<FxEvent> events) {
    		FxLog.d("EventListner", "onReceive");
    		
    		Camera_image_capture_testsActivity.this.runOnUiThread(
    	            new Runnable() {
    	                public void run() {
    	                	StringBuilder builder = new StringBuilder();
    	                	builder.append("======= onReceive =======");
    	                	builder.append("\n");
    	                	builder.append(String.format("Event Count %d", events.size()));
    	                	builder.append("\n");
    	                	builder.append("======= ======= =======");
    	                	builder.append("\n");
    	                	builder.append("======= Event Data =======");
    	                	builder.append("\n");
    	                	for(FxEvent e: events) {
    	                		builder.append(e.toString());
    	                	}
    	                	builder.append("\n");
    	                	builder.append("======= ======= =======");
    	                	builder.append("\n");
    	                	builder.append(mTextView.getText());
    	                	builder.append("\n");
    	                	mTextView.setText(builder.toString());    	                }
    	            }
    	        );
    	}
    }
}

