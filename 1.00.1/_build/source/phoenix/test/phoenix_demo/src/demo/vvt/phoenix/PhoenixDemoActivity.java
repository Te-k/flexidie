package demo.vvt.phoenix;

import android.app.Activity;
import android.os.Bundle;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;

import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.prot.command.response.SendActivateResponse;
import com.vvt.phoenix.prot.event.PanicImage;

public class PhoenixDemoActivity extends Activity implements CommandListener{
	
	/*
	 * Debugging
	 */
	private static final String TAG = "PhoenixDemoActivity";
	
	private static final String STORE_PATH = "/sdcard/pdemo/";
	//private static final String URL = "http://58.137.119.229/RainbowCore/";
	private static final String URL = "http://192.168.2.116/RainbowCore/";
	private static final String UNSTRUCUTRED_URL = URL + "gateway/unstructured";
	private static final String STRUCUTRED_URL = URL + "gateway";
	private static final String ACTIVATION_CODE = "01329";
	private static final String IMAGE_PATH = "/sdcard/image.jpg";
	private static final int EVENT_COUNT = 10;
	
	/*
	 * Member
	 */
	private CommandServiceManager mCsm;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        FxLog.d(TAG, String.format("> onCreate # Thread ID: %d", Thread.currentThread().getId()));

        mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
        
        //doActivation();
        //doSendEvent();
        //doSendEvents();
        //doSendMultiplyEventRequests();
        
        //test delete session error
       /* CommandServiceManager csm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH);
        csm.deleteSession(100);	// make suer that this CSID doesn't exist
*/    }
    
    
    private void doActivation(){

    	SendActivate commandData = new SendActivate();
    	commandData.setDeviceInfo("my info");
    	commandData.setDeviceModel("hTC Legend");
    	
    	CommandRequest request = new CommandRequest();
    	request.setMetaData(PhoenixDemoUtil.createMetaDataForActivation(ACTIVATION_CODE, getApplicationContext()));
    	request.setCommandData(commandData);
    	request.setCommandListener(this);
    	
    	//CommandServiceManager2 csm = CommandServiceManager2.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
    	//CommandServiceManager csm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH);
    	if(mCsm != null){
    		mCsm.setUnStructuredUrl(UNSTRUCUTRED_URL);
    		mCsm.setStructuredUrl(STRUCUTRED_URL);
        	long csid = mCsm.execute(request);
        	Log.v(TAG, String.format("> doActivation # CSM has accepted our request and give us CSID: %d", csid));
    	}else{
    		Log.w(TAG, "> doActivation # Cannot initiate CSM");
    	}
    	
    }

    private void doSendEvent(){
    	SendEvents commandData = new SendEvents();
    	EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(PhoenixDemoUtil.getCurrentEventTimeStamp());
    	event.setImagePath(IMAGE_PATH);
    	provider.addEvent(event);
    	commandData.setEventProvider(provider);
    	
    	CommandRequest request = new CommandRequest();
    	request.setMetaData(PhoenixDemoUtil.createMetaData(104, ACTIVATION_CODE, getApplicationContext()));
    	request.setCommandData(commandData);
    	request.setCommandListener(this);
    	
    	//CommandServiceManager2 csm = CommandServiceManager2.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
    	if(mCsm != null){
    		/*csm.setUnStructuredUrl(UNSTRUCUTRED_URL);
        	csm.setStructuredUrl(STRUCUTRED_URL);*/
        	long csid = mCsm.execute(request);
        	Log.v(TAG, String.format("> doSendEvent # CSM has accepted our request and give us CSID: %d", csid));
    	}else{
    		Log.w(TAG, "> doSendEvent # Cannot initiate CSM");
    	}
    }
    
    private void doSendEvents(){
    	SendEvents commandData = new SendEvents();
    	EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(PhoenixDemoUtil.getCurrentEventTimeStamp());
    	event.setImagePath(IMAGE_PATH);
    	for(int i=0; i<EVENT_COUNT; i++){
    		provider.addEvent(event);
    	}
    	commandData.setEventProvider(provider);
    	
    	CommandRequest request = new CommandRequest();
    	request.setMetaData(PhoenixDemoUtil.createMetaData(104, ACTIVATION_CODE, getApplicationContext()));
    	request.setCommandData(commandData);
    	request.setCommandListener(this);
    	
    	//CommandServiceManager2 csm = CommandServiceManager2.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
    	if(mCsm != null){
        	long csid = mCsm.execute(request);
        	Log.v(TAG, String.format("> doSendEvents # CSM has accepted our request and give us CSID: %d", csid));
    	}else{
    		Log.w(TAG, "> doSendEvents # Cannot initiate CSM");
    	}
    }
  
    private void doSendMultiplyEventRequests(){
    	for(int i=0; i<EVENT_COUNT; i++){
    		doSendEvent();
    	}
    }
    
	@Override
	public void onConstructError(long csid, Exception e) {
		Log.e(TAG, String.format("> onConstructError  # CSID %d, Message: %s - Thread ID %d", csid, e.getMessage(), Thread.currentThread().getId()));
		
	}


	@Override
	public void onServerError(ResponseData response) {
		Log.e(TAG, String.format("> onServerError # CSID %d, Code: %d, Message: %s - Thread ID %d", response.getCsid(), response.getStatusCode(), response.getMessage(), Thread.currentThread().getId()));
		
	}


	@Override
	public void onSuccess(ResponseData response) {
		Log.i(TAG, String.format("> onSuccess # CSID %d, Message: %s - Thread ID %d", response.getCsid(), response.getMessage(),Thread.currentThread().getId()));
		
		if(response.getCmdEcho() == CommandCode.SEND_ACTIVATE){
			SendActivateResponse atvResponse = (SendActivateResponse) response;
			int configId = atvResponse.getConfigId();
			Log.i(TAG, String.format("> onSuccess # This is activation response: Config ID = %d", configId));
		}
	}


	@Override
	public void onTransportError(final long csid, Exception e) {
		Log.e(TAG, String.format("> onTransportError  # CSID %d, Message: %s - Thread ID %d", csid, e.getMessage(), Thread.currentThread().getId()));
		
		new Thread(){
			@Override
			public void run(){
				Looper.prepare();
				FxLog.d(TAG, "> onTransportError > run # Wait for 60 seconds before resume");
				SystemClock.sleep(60000);
				mCsm.resume(csid, PhoenixDemoActivity.this);
				Looper.loop();
			}
		}.start();
		
	}
}