package com.vvt.videoc;

import java.io.IOException;
import com.vvt.event.FxEventCapture;
import com.vvt.event.FxVideoFileThumbnailEvent;
import com.vvt.event.constant.FxStatus;
import com.vvt.mediamon.MediaMonitor;
import com.vvt.mediamon.MediaMonitorListener;
import com.vvt.mediamon.info.MediaInfo;
import com.vvt.mediamon.info.MediaInfoType;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;

public class VideoCapture extends FxEventCapture implements MediaMonitorListener {
	
	private final String TAG = "VideoCapture"; 
	private MediaMonitor mediaMon = new MediaMonitor();
	
	public void startCapture() {
		try {
			Log.debug(TAG + ".startCapture()", "isEnabled: " + isEnabled() + "sizeOfFxEventListener: " + sizeOfFxEventListener());
			if (!isEnabled() && sizeOfFxEventListener() > 0) {
				Log.debug(TAG + ".startCapture()", "ENTER");
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

	private void resetMadiaCapture() {
		setEnabled(false);
		mediaMon.removeMediaMonitorListener(this);
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
		fxVDOFileThumbEvent.setStatus(FxStatus.NOT_SEND);
		// To notify event.
		notifyEvent(fxVDOFileThumbEvent);	
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
		if (mediaInfo.getMediaInfoType() == MediaInfoType.VIDEO_THUMBNAIL) {
			initFxVideoFileThumbnailEvent(mediaInfo);
		}
	}
}
