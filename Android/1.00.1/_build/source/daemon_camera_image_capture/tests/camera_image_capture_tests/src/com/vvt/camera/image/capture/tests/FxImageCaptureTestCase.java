package com.vvt.camera.image.capture.tests;

import java.util.HashMap;
import java.util.List;

import junit.framework.Assert;
import android.content.Context;
import android.net.Uri;
import android.provider.MediaStore;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.appcontext.AppContext;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.capture.camera.image.FxCameraImageCapture;
import com.vvt.capture.camera.image.FxCameraImageHelper;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;
import com.vvt.logger.FxLog;

@SuppressWarnings("rawtypes")
public class FxImageCaptureTestCase extends ActivityInstrumentationTestCase2 {
	private Context mTestContext;
	private AppContext mAppContext;

	@SuppressWarnings("unchecked")
	public FxImageCaptureTestCase() {
		//very important
		super("com.vvt.capture.image.tests", Camera_image_capture_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();
		mAppContext = new AppContextImpl(mTestContext);
	}

	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}

	public void setTestContext(Context context) {
		mTestContext = context;
	}

	public Context getTestContext() {
		return mTestContext;
	}
	
	public void test_getAllImagesWithExternalMedia()
	{
		Uri EXTERNAL_CONTENT_URI =  MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
		HashMap<Long, String> list = FxCameraImageHelper.getAllImages(mTestContext, EXTERNAL_CONTENT_URI);
		
		if(list.size() <=0) {
			Assert.fail("Incorrect no of events receieved for external.");
		}
		
	}
	
	public void test_getAllImagesWithInternalMedia()
	{
		Uri INTERNAL_CONTENT_URI =  MediaStore.Images.Media.INTERNAL_CONTENT_URI;
		HashMap<Long, String> list = FxCameraImageHelper.getAllImages(mTestContext, INTERNAL_CONTENT_URI);
		
		if(list.size() < 0) {
			Assert.fail("Incorrect no of events receieved for external.");
		}
	}
	
	public void test_getWhatsDeletedWithNull()
	{
		List<FxEvent>  list = FxCameraImageHelper.getWhatsDeleted(null, null);
		
		if(list == null) {
			Assert.fail("can not be null.");
		}
	}
	
	
	public void test_getWhatsNewWithNull()
	{
		
		Uri EXTERNAL_CONTENT_URI =  MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
		
		List<FxEvent>  list = FxCameraImageHelper.getWhatsNew(mAppContext, EXTERNAL_CONTENT_URI, null, null);
		
		if(list == null) {
			Assert.fail("can not be null.");
		}
	}
	
	public void test_getNewerMediaByIdWithInvalidRef()
	{
		Uri EXTERNAL_CONTENT_URI =  MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
		
		List<FxEvent>  list = FxCameraImageHelper.getNewerMediaById(mAppContext, EXTERNAL_CONTENT_URI, -1);
		
		if(list.size() > 0) {
			Assert.fail("can not have any events.");
		}
	}
 
	
	public void test_FxCallLogCapture_register_withDummyEventListner() {
		FxEventListener listner = new  DummyEventListener();
		FxCameraImageCapture capture = new FxCameraImageCapture(mAppContext);
		try {
			capture.register(listner);
			capture.startCapture();
		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}
		
		try {
			capture.stopCapture();
			capture.unregister();
			
		} catch (FxOperationNotAllowedException e) {
			e.printStackTrace();
		}
	}
}

class DummyEventListener implements FxEventListener
{
	@Override
	public void onEventCaptured(final List<FxEvent> events) {
		FxLog.d("EventListner", "onReceive");
		
	}
}
