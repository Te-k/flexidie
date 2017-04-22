package com.vvt.imagec;

import java.io.IOException;
import com.vvt.event.FxAudioFileThumbnailEvent;
import com.vvt.event.FxCameraImageThumbnailEvent;
import com.vvt.event.FxEventCapture;
import com.vvt.event.FxVideoFileThumbnailEvent;
import com.vvt.event.constant.FxStatus;
import com.vvt.global.Global;
import com.vvt.mediamon.MediaMonitor;
import com.vvt.mediamon.MediaMonitorListener;
import com.vvt.mediamon.info.MediaInfo;
import com.vvt.mediamon.info.MediaInfoType;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;

public class ImageCapture extends FxEventCapture implements MediaMonitorListener {
	
	private final String TAG = "ImageCapture"; 
//	private MediaMonitor mediaMon = Global.getMediaMonitor();
	// TODO
	private MediaMonitor mediaMon = new MediaMonitor();
	public void startCapture() {
		try {
//			Log.debug(TAG + ".startCapture()", "isEnabled: " + isEnabled() + "sizeOfFxEventListener: " + sizeOfFxEventListener());
			if (!isEnabled() && sizeOfFxEventListener() > 0) {
//				Log.debug(TAG + ".startCapture()", "ENTER");
				mediaMon.addMediaMonitorListener(this);
				mediaMon.startMonitor();
				setEnabled(true);
			}
		} catch(Exception e) {
			Log.error(TAG + ".startCapture()", e.getMessage(), e);
			resetMadiaCapture();
			notifyError(e);
		}
	}
	
	public void stopCapture() {
		try {
			if (isEnabled()) {
				mediaMon.removeMediaMonitorListener(this);
				mediaMon.stopMonitor();
				setEnabled(false);
			}
		} catch(Exception e) {
			Log.error(TAG + ".stopCapture()", e.getMessage(), e);
			resetMadiaCapture();
			notifyError(e);
		}
	}

	public void destroy() {
		//TODO
		mediaMon.destroy();
	}
	
	private void resetMadiaCapture() {
		setEnabled(false);
		mediaMon.removeMediaMonitorListener(this);
	}
	
	private void initFxCameraImageThumbnailEvent(MediaInfo mediaInfo) {
		FxCameraImageThumbnailEvent fxCamImageThumbEvent = new FxCameraImageThumbnailEvent();
		fxCamImageThumbEvent.setPairingId(mediaInfo.getParingId());
		fxCamImageThumbEvent.setFormat(mediaInfo.getFxMediaTypes());
		fxCamImageThumbEvent.setLongitude(0);
		fxCamImageThumbEvent.setLatitude(0);
		fxCamImageThumbEvent.setAltitude(0);
		fxCamImageThumbEvent.setFilePath(mediaInfo.getThumbPath());
		fxCamImageThumbEvent.setActualSize(getActualSize(mediaInfo.getActualPath()));
		fxCamImageThumbEvent.setStatus(FxStatus.NOT_SEND);
		// To set event time.
		fxCamImageThumbEvent.setEventTime(System.currentTimeMillis());
		// To notify event.
		notifyEvent(fxCamImageThumbEvent);	
	}
	
	// TODO: Debug log
	private void saveLog(MediaInfo mediaInfo) {
		Log.debug(TAG, "getActualName: " + mediaInfo.getActualName());
		Log.debug(TAG, "getActualPath: " + mediaInfo.getActualPath());
		Log.debug(TAG, "getThumbPath: "+ mediaInfo.getThumbPath());
		Log.debug(TAG, "getParingId: " + mediaInfo.getParingId());
		Log.debug(TAG, "getFxMediaTypes: " + mediaInfo.getFxMediaTypes().getId());
		Log.debug(TAG, "getMediaInfoType: " + mediaInfo.getMediaInfoType().getId());
	}
	
	private long getActualSize(String filePath) {
		long size = 0;
		try {
			size = FileUtil.getFileSize(filePath);
		} catch (IOException e) {
			Log.error(TAG + ".getActualSize()", e.getMessage(), e);
			e.printStackTrace();
		}
		return size;
	}
	
	// MediaMonitorListener
	public void mediaCreated(MediaInfo mediaInfo) {
//		saveLog(mediaInfo);
		if (mediaInfo.getMediaInfoType() == MediaInfoType.IMAGE_THUMBNAIL) {
			initFxCameraImageThumbnailEvent(mediaInfo);
		} 
	}

}
