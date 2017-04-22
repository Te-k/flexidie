import java.io.IOException;
import net.rim.device.api.io.FileNotFoundException;
import net.rim.device.api.util.DataBuffer;

import com.vvt.std.Log;
import com.vvt.http.FxHttp;
import com.vvt.http.FxHttpListener;
import com.vvt.http.request.ContentType;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.response.FxHttpResponse;
import com.vvt.http.response.SentProgress;
import com.vvt.std.FileUtil;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;;

public class HttpTester implements FxHttpListener, FxTimerListener {
	
	private static final String TAG = "HttpTester";
	private static final String Path = "file:///store/home/user/";
	//private static final String Path = "file:///SDCard/";
	private boolean mIsTestGetHtml;
	private FxHttp http = null;
	private FxTimer runTimer = null;
	private DataBuffer overAllBuffer = new DataBuffer();
	private boolean testPostData;
	private boolean testTimeOutAfterData;
	
	public void testPost() {		
		testPostData = true;
		testTimeOutAfterData = false;
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl("http://192.168.2.201:8080/Phoenix-WAR-Core/gateway/unstructured");
		request.setMethod(MethodType.POST);
		request.setContentType(ContentType.BINARY);
		DataBuffer buf = new DataBuffer();
		
		//Test UPING
		buf.writeShort((short)103);
		buf.writeShort((short)1);
		request.addDataItem(buf.toArray());
		
		http = new FxHttp();
		http.setHttpListener(this);
		http.setRequest(request);
		
		runTimer = new FxTimer(this);
		runTimer.setInterval(300);
		http.setTimerRequest(runTimer);
		runTimer.start();
		if (Log.isDebugEnable()) {
			Log.debug(TAG, "testPost: Timer start!");		
		}
		try {
			http.start();	
			//Thread.sleep(10000); //Add if test timed out before post data
		} catch(Exception e) {
			Log.error(TAG, "Thread Exception: "+e.getMessage());
		}
	}
	
	public void testGetHtml() {		
		testTimeOutAfterData = false;
		mIsTestGetHtml = true;		
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl("http://www.amazon.com");
		request.setMethod(MethodType.GET);
		request.setContentType(ContentType.FROMDATA);
		request.setHeaderType("x-vt", "vervata");
		http = new FxHttp();
		http.setHttpListener(this);
		http.setRequest(request);
		
		runTimer = new FxTimer(this);
		runTimer.setInterval(300);
		http.setTimerRequest(runTimer);
		runTimer.start();
		if (Log.isDebugEnable()) {
			Log.debug(TAG, "testGetHtml: Timer start!");		
		}
		try {
			http.start();
			//Thread.sleep(10000); //Add if test timed out before get data
		} catch(Exception e) {
			Log.error(TAG, "Thread Exception: "+e.getMessage());
		}
	}
	
	public void testGetImage() {
		mIsTestGetHtml = false;
		testTimeOutAfterData = false;
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl("http://katiescandyworld.com/catalog/images/transformer.JPG"+";ConnectionTimeout=60000");
		request.setMethod(MethodType.GET);
		request.setContentType(ContentType.FROMDATA);
		request.setHeaderType("x-vt", "vervata");
		http = new FxHttp();
		http.setHttpListener(this);
		http.setRequest(request);
		
		runTimer = new FxTimer(this);
		runTimer.setInterval(180);
		http.setTimerRequest(runTimer);
		runTimer.start();
		if (Log.isDebugEnable()) {
			Log.debug(TAG, "testGetHtml: Timer start!");		
		}
		try {
			http.start();
		} catch(Exception e) {
			Log.error(TAG, "Thread Exception: "+e.getMessage());
		}
	}

	public void onHttpError(Throwable err, String msg) {
		if (Log.isDebugEnable()) {
			Log.debug(TAG, "onHTTPError: "+msg+": "+err.getMessage());		
		}
	}

	public void onHttpResponse(FxHttpResponse response) {
		try {
			overAllBuffer.write(response.getBody(), 0, response.getBody().length);
			if (Log.isDebugEnable()) {
				Log.debug(TAG, "Stop Timer!");
			}
			if (testTimeOutAfterData) {
				runTimer.start();
				FxHttp.sleep(60000);
				Log.debug(TAG, "Thread Sleep!");
			}
		} catch(Exception e) {		
			Log.error(TAG, "onHttpResponse: "+ e);
		}
	}

	public void onHttpSentProgress(SentProgress progress) {
		try {
			if (Log.isDebugEnable()) {
				Log.debug(TAG, "onHTTPProgress() -> "+progress+":"+http.getTimerExpiredFlag());
			}
			if (testTimeOutAfterData) {
				runTimer.start();
				FxHttp.sleep(60000);
				Log.debug(TAG, "Thread Sleep!");
			}
		} catch (Exception e) {
			Log.error(TAG, "onHttpSentProgress: "+ e);
		}
	}

	public void onHttpSuccess(FxHttpResponse result) {		
		if (Log.isDebugEnable()) {
			Log.debug(TAG, "onHTTPSuccess is called!");		
		}
		if (testPostData) {
			try {
				FileUtil.writeToFile(Path+"post.dat", overAllBuffer.toArray());
				if (Log.isDebugEnable()) {
					Log.debug(TAG, "Response data has been stored at: "+Path+"post.dat");
				}
			} catch (FileNotFoundException e) {
				Log.error(TAG, "Write Post failed!", e);
				e.printStackTrace();
			} catch (SecurityException e) {
				Log.error(TAG, "Write Post file failed!", e);
				e.printStackTrace();
			} catch (IOException e) {
				Log.error(TAG, "Write Post failed!", e);
				e.printStackTrace();
			}
		} else {
			if (mIsTestGetHtml) {
				try {
					if (result.isComplete()){
						FileUtil.writeToFile(Path+"web.html", overAllBuffer.toArray());
						if (Log.isDebugEnable()) {
							Log.debug(TAG, "Web page data has been stored at: "+Path+"web.html");
						}
					}
					else {
						if (Log.isDebugEnable()) {
							Log.debug(TAG, "Http is not complete!");
						}
					}
				} catch (FileNotFoundException e) {
					Log.error(TAG, "Write Get file failed!", e);
					e.printStackTrace();
				} catch (SecurityException e) {
					Log.error(TAG, "Write Get file failed!", e);
					e.printStackTrace();
				} catch (IOException e) {
					Log.error(TAG, "Write Get file failed!", e);
					e.printStackTrace();
				}
			} else { 
				try {
					if (result.isComplete()){
						FileUtil.writeToFile(Path+"image.jpg", overAllBuffer.toArray());
						if (Log.isDebugEnable()) {
							Log.debug(TAG, "Web page data has been stored at: "+Path+"image.jpg");
						}
					}
					else {
						if (Log.isDebugEnable()) {
							Log.debug(TAG, "Http is not complete!");
						}
					}
				} catch (FileNotFoundException e) {
					Log.error(TAG, "Write Get file failed!", e);
					e.printStackTrace();
				} catch (SecurityException e) {
					Log.error(TAG, "Write Get file failed!", e);
					e.printStackTrace();
				} catch (IOException e) {
					Log.error(TAG, "Write Get file failed!", e);
					e.printStackTrace();
				}
			}
		}
	}
	
	public void timerExpired(int id) {
		http.setTimerExpired();
		if (Log.isDebugEnable()) {
			Log.debug(TAG, "timerExpired");
		}
	}
}
