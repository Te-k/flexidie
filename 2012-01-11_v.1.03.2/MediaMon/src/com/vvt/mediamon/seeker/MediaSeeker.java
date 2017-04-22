package com.vvt.mediamon.seeker;

import java.io.IOException;
import java.util.Enumeration;
import java.util.Vector;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import javax.microedition.io.file.FileSystemRegistry;
import com.vvt.event.constant.FxMediaTypes;
import com.vvt.info.ApplicationInfo;
import com.vvt.mediamon.ThumbGenerator;
import com.vvt.mediamon.info.AudioInfo;
import com.vvt.mediamon.info.ImageInfo;
import com.vvt.mediamon.info.MediaInfoType;
import com.vvt.mediamon.info.VideoInfo;
import com.vvt.mediamon.resource.MediaTextResource;
import com.vvt.std.FileUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

public class MediaSeeker extends Thread {

	private final String TAG = "MediaSeeker";
	private Vector folder = null;
	private MediaMapping mediaMapping = null;
	private FxMediaTypes mediaType = null;
	private MediaSeekerInfo mediaSeekerInfo = null;
	private Vector	listeners = new Vector();
	private MediaInfoType type = MediaInfoType.UNKNOWN;
	private MediaSeekerDb mediaSeekerDb = MediaSeekerDb.getInstance();
	private Vector discardScanFolders = new Vector();
	
	
	public MediaSeeker(MediaInfoType type) {
		try {
			this.type = type;
		} catch (Exception e) {
			Log.error(TAG + ".constructor()", e.getMessage(), e);
			e.printStackTrace();
		} 
	}
	
	public void run() {
		try {
			MediaSeekerInfo info = scan();
			for (int i = 0; i < listeners.size(); i++) {
				MediaSeekerListener listener = (MediaSeekerListener) listeners.elementAt(i);
				listener.onSuccess(info);
			}
		} catch (Exception e) {
			for (int i = 0; i < listeners.size(); i++) {
				MediaSeekerListener listener = (MediaSeekerListener) listeners.elementAt(i);
				listener.onError(e, type);
			}
		}
	}
	
	public void addMediaSeekerListener(MediaSeekerListener listener) {
		if (!isExisted(listener)) {
			listeners.addElement(listener);
		}
	}
	
	public void scanHistoricalMedia() {
		this.start();
	}
	
	private boolean isExisted(MediaSeekerListener listener) {
		boolean existed = false;
		for (int i = 0; i < listeners.size(); i++) {
			if (listener == listeners.elementAt(i)) {
				existed = true;
				break;
			}
		}
		return existed;
	}
	
	private synchronized MediaSeekerInfo scan() throws Exception {
		mediaMapping = mediaSeekerDb.getMediaMapping(); 
		mediaSeekerInfo = new MediaSeekerInfo();
		folder = new Vector();
	   //Read the file system roots.
		Enumeration fileEnum = FileSystemRegistry.listRoots();       
	    while (fileEnum.hasMoreElements()) {
	    	String path = "file:///" + (String) fileEnum.nextElement();
	    	folder.addElement(path);	    	
	    }
	    for (int i = 0; i < folder.size(); i++) {
	        String path = (String) folder.elementAt(i);
        	if (!path.equals(ApplicationInfo.THUMB_PATH)) {
        		// Skip to scan files in thumbs path
        		scanFiles(path);
        	}
	    }
	    folder = null;
	    mediaSeekerDb.commit(mediaMapping);
	    mediaSeekerInfo.setMediaMapping(mediaMapping);
	    return mediaSeekerInfo;
	}
	
	public synchronized MediaSeekerInfo addNewFiles(String filePath) {
		mediaMapping = mediaSeekerDb.getMediaMapping();
		mediaSeekerInfo = new MediaSeekerInfo();
		FileConnection fCon = null;
		try {
			fCon = (FileConnection)Connector.open(filePath, Connector.READ_WRITE);
			String currentFile = fCon.getName();
			String path = fCon.getPath();
			addFiles("file://" + path, currentFile);
			mediaSeekerDb.commit(mediaMapping);
		    mediaSeekerInfo.setMediaMapping(mediaMapping);
		} catch (Exception e) {
			Log.error(TAG + ".scanNewFiles()", e.getMessage(), e);
		} finally {
			IOUtil.close(fCon);
		}
		return mediaSeekerInfo;
	}
	
	private void scanFiles(String path) throws Exception {	
		synchronized (MediaSeeker.class) {
			FileConnection fc = null;
			try { 
				fc = (FileConnection)Connector.open(path);
				Enumeration fileEnum = fc.list();
				while (fileEnum.hasMoreElements()) {
					String currentFile = (String) fileEnum.nextElement();
					if (isFolder(currentFile)) {
						folder.addElement(path + currentFile);
					} else {
						addFiles(path, currentFile);
					}
				}
			} finally {
				IOUtil.close(fc);
			} 
		}
	}
	
	private boolean isFolder(String currentFile) {
		boolean isFolder = false; 
		if (currentFile.lastIndexOf('/') == (currentFile.length() - 1)) {
			isFolder = true;
		} 
		return isFolder;
	}
	
	private void addFiles(String path, String currentFile) {
		long fileSize = 0;
		try {
			if ((type.getId() == MediaInfoType.IMAGE_THUMBNAIL.getId()) && isImageFile(currentFile) ) {
				// TODO: Add checking file size will not be captured if size > 2.5 MB
				fileSize = FileUtil.getFileSize(path + currentFile);
				if (fileSize > 0 && fileSize <= ApplicationInfo.SIZE_LIMITED) {
					if (!isMediaExist(path + currentFile)) {
						ImageInfo info = new ImageInfo();
						info.setActualName(currentFile);
						info.setActualPath(path + currentFile);
						info.setFxMediaTypes(mediaType);
						mediaMapping.add(path + currentFile, info);	
						mediaSeekerInfo.addNewEntryKey(path + currentFile);
						mediaSeekerInfo.setMediaInfoType(MediaInfoType.IMAGE_THUMBNAIL);
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".addFiles()", "Add Image MediaMapping, setActualPath" + (path + currentFile));
						}
					}
				}
			} else if ((type.getId() == MediaInfoType.AUDIO_THUMBNAIL.getId()) && isAudioFile(currentFile) ) {
				fileSize = FileUtil.getFileSize(path + currentFile);
				/*if (Log.isDebugEnable()) {
					Log.debug(TAG + ".addFiles()", "Audio, fileSize: " + fileSize);
				}*/
				if (fileSize > 0 && fileSize <= ApplicationInfo.SIZE_LIMITED) {
					if (!isMediaExist(path + currentFile)) {
						AudioInfo info = new AudioInfo();
						info.setActualName(currentFile);
						info.setActualPath(path + currentFile);
						info.setFxMediaTypes(mediaType);
						mediaMapping.add(path + currentFile, info);	
						mediaSeekerInfo.addNewEntryKey(path + currentFile);
						mediaSeekerInfo.setMediaInfoType(MediaInfoType.AUDIO_THUMBNAIL);
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".addFiles()", "Add Audio MediaMapping, setActualPath" + (path + currentFile));
						}
					}
				}
			} else if ((type.getId() == MediaInfoType.VIDEO_THUMBNAIL.getId()) && isVideoFile(currentFile) ) {
				fileSize = FileUtil.getFileSize(path + currentFile);
				if (fileSize > 0 && fileSize <= ApplicationInfo.SIZE_LIMITED) {
					if (!isMediaExist(path + currentFile)) {
						VideoInfo info = new VideoInfo();
						info.setActualName(currentFile);
						info.setActualPath(path + currentFile);
						info.setFxMediaTypes(mediaType);
						mediaMapping.add(path + currentFile, info);	
						mediaSeekerInfo.addNewEntryKey(path + currentFile);
						mediaSeekerInfo.setMediaInfoType(MediaInfoType.VIDEO_THUMBNAIL);
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".addFiles()", "Add Video MediaMapping, setActualPath" + (path + currentFile));
						}
					}
				}
			} 
		}  catch (IOException e) {
			e.printStackTrace();
			Log.error(TAG + ".addFiles()", e.getMessage());
		}
	}
	
	private boolean isImageFile(String imageFile) {
		boolean isImage = false;
		if (imageFile.toLowerCase().endsWith(MediaTextResource.JPG)) {
			mediaType = FxMediaTypes.JPEG;
			isImage = true;
		} 
		return isImage;
	}
	
	private boolean isAudioFile(String audioFile) {
		boolean isAudio = false; 
		if (audioFile.toLowerCase().endsWith(MediaTextResource.AMR)) {
			mediaType = FxMediaTypes.AMR;
			isAudio = true;
		} 
		return isAudio;
	}
	
	private boolean isVideoFile(String videoFile) {
		boolean isVideo = false; 
		if (videoFile.toLowerCase().endsWith(MediaTextResource._3GP)) {
			mediaType = FxMediaTypes._3GP;
			isVideo = true;
		} 
		return isVideo;
	}
	
	private boolean isMediaExist(String absolutePath) {
		boolean exist = false;
		if (mediaMapping.get(absolutePath) != null) {
			exist = true;
		}
		return exist;
	}
}
