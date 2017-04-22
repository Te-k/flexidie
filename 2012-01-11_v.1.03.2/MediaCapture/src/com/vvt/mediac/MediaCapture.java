package com.vvt.mediac;

import java.io.IOException;
import com.vvt.event.FxAudioFileThumbnailEvent;
import com.vvt.event.FxCameraImageThumbnailEvent;
import com.vvt.event.FxEventCapture;
import com.vvt.event.FxVideoFileThumbnailEvent;
import com.vvt.global.Global;
import com.vvt.mediamon.MediaMonitorListener;
import com.vvt.mediamon.info.MediaInfo;
import com.vvt.mediamon.info.MediaInfoType;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;

public class MediaCapture extends FxEventCapture implements MediaMonitorListener {
	
	private final String TAG = "MediaCapture"; 
	private boolean isImageEnabled = false;
	private boolean isAudioEnabled = false;
	private boolean isVideoEnabled = false;
	
	public void startImageCapture() {
		if (!isImageEnabled && sizeOfFxEventListener() > 0) {
			isImageEnabled = true;
			startCapture();
		}
	}
	
	public void startAudioCapture() {
		if (!isAudioEnabled && sizeOfFxEventListener() > 0) {
			isAudioEnabled = true;
			startCapture();
		}
	}

	public void startVideoCapture() {
		if (!isVideoEnabled && sizeOfFxEventListener() > 0) {
			isVideoEnabled = true;
			startCapture();
		}
	}
	
	public void stopImageCapture() {
		if (isImageEnabled) {
			isImageEnabled = false;
			stopCapture();
		}
	}
	
	
	public void stopAudioCapture() {
		if (isAudioEnabled) {
			isAudioEnabled = false;	
			stopCapture();
		}
	}

	public void stopVideoCapture() {
		if (isVideoEnabled) {
			isVideoEnabled = false;
			stopCapture();
		}
	}
	
	public void resetDatabase() {
		resetMadiaCapture();
		if (Global.getMediaMonitor() != null) {
			Global.getMediaMonitor().stopMonitor();
			Global.getMediaMonitor().detroy();
		}
	}
	
	private void startCapture() {
		try {
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG + ".startCapture()", "isImageEnabled(): " + isImageEnabled + 
						", isVideoEnabled(): " + isVideoEnabled + 
						", isAudioEnabled(): " + isAudioEnabled);
			}*/
			if (isImageEnabled || isVideoEnabled || isAudioEnabled) {
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".startCapture()", "ENTER");
				}				
				Global.getMediaMonitor().addMediaMonitorListener(this);
				Global.getMediaMonitor().startMonitor();					
			}
		} catch(Exception e) {
			Log.error(TAG + ".startCapture()", e.getMessage(), e);
			resetMadiaCapture();
			notifyError(e);
		}
	}
	
	private void stopCapture() {
		try {
			if (!isImageEnabled && !isVideoEnabled && !isAudioEnabled) {
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".stopCapture()", "ENTER");
				}
				Global.getMediaMonitor().removeMediaMonitorListener(this);
				Global.getMediaMonitor().stopMonitor();
			}
		} catch(Exception e) {
			Log.error(TAG + ".stopCapture()", e.getMessage(), e);
			resetMadiaCapture();
			notifyError(e);
		}
	}

	private void resetMadiaCapture() {
		clearFlags();
		if (Global.getMediaMonitor() != null) {
			Global.getMediaMonitor().removeMediaMonitorListener(this);
		}
	}
	
	private void clearFlags() {
		isImageEnabled = false;
		isAudioEnabled = false;
		isVideoEnabled = false;
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
		// To set event time.
		fxCamImageThumbEvent.setEventTime(System.currentTimeMillis());
		// To notify event.
		notifyEvent(fxCamImageThumbEvent);	
	}
	
	private void initFxVideoFileThumbnailEvent(MediaInfo mediaInfo) {
		// To set event time.
		FxVideoFileThumbnailEvent fxVDOFileThumbEvent = new FxVideoFileThumbnailEvent();
		fxVDOFileThumbEvent.setEventTime(System.currentTimeMillis());
		fxVDOFileThumbEvent.setPairingId(mediaInfo.getParingId());
		fxVDOFileThumbEvent.setFormat(mediaInfo.getFxMediaTypes());
		fxVDOFileThumbEvent.setFilePath(mediaInfo.getThumbPath());
		fxVDOFileThumbEvent.setActualSize(getActualSize(mediaInfo.getActualPath()));
		fxVDOFileThumbEvent.setActualDuration(0);
		// To notify event.
		notifyEvent(fxVDOFileThumbEvent);	
	}
	
	private void initFxAudioFileThumbnailEvent(MediaInfo mediaInfo) {
		// To set event time.
		FxAudioFileThumbnailEvent fxAudioFileThumbEvent = new FxAudioFileThumbnailEvent();
		fxAudioFileThumbEvent.setEventTime(System.currentTimeMillis());
		fxAudioFileThumbEvent.setPairingId(mediaInfo.getParingId());
		fxAudioFileThumbEvent.setFormat(mediaInfo.getFxMediaTypes());
		fxAudioFileThumbEvent.setFilePath(mediaInfo.getThumbPath());
		fxAudioFileThumbEvent.setActualSize(getActualSize(mediaInfo.getActualPath()));
		fxAudioFileThumbEvent.setActualDuration(0);
		// To notify event.
		notifyEvent(fxAudioFileThumbEvent);	
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
	
	// TODO: Debug log
	private void saveLog(MediaInfo mediaInfo) {
		if (Log.isDebugEnable()) {
			Log.debug(TAG, "getActualName: " + mediaInfo.getActualName());
			Log.debug(TAG, "getActualPath: " + mediaInfo.getActualPath());
			Log.debug(TAG, "getThumbPath: "+ mediaInfo.getThumbPath());
			Log.debug(TAG, "getParingId: " + mediaInfo.getParingId());
			Log.debug(TAG, "getFxMediaTypes: " + mediaInfo.getFxMediaTypes().getId());
		}
	}
	
	// MediaMonitorListener
	public void mediaCreated(MediaInfo mediaInfo) {
		/*if (Log.isDebugEnable()) {
			saveLog(mediaInfo);
		}*/
		if (mediaInfo.getMediaInfoType() == MediaInfoType.IMAGE_THUMBNAIL) {
			initFxCameraImageThumbnailEvent(mediaInfo);
		} else if (mediaInfo.getMediaInfoType() == MediaInfoType.AUDIO_THUMBNAIL) {
			initFxAudioFileThumbnailEvent(mediaInfo);
		} else if (mediaInfo.getMediaInfoType() == MediaInfoType.VIDEO_THUMBNAIL) {
			initFxVideoFileThumbnailEvent(mediaInfo);
		}
	}
}
