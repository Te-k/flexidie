package com.vvt.mediamon.seeker;

import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.std.Log;

public class MediaSeekerDb {

	private static MediaSeekerDb self;
	public  static 	final long MEDIADB_GUID 	= 0xba157e8b4e6272b9L; 
	private static final long MEDIA_MAPPING_KEY = 0xfdba5b53399d297L; //com.vvt.mediamon.seeker.MediaDb.MEDIA_MAPPING_KEY
	private PersistentObject mediaMappingPersistence = null;	
	private MediaMapping mediaMapping = null;
	
	private MediaSeekerDb()	{
		/*if (Log.isDebugEnable()) {
			Log.debug("MediaSeekerDb.constructor()", "ENTER");
		}*/
		mediaMappingPersistence = PersistentStore.getPersistentObject(MEDIA_MAPPING_KEY);
		synchronized (mediaMappingPersistence) {
			/*if (Log.isDebugEnable()) {
				Log.debug("MediaDb.constructor()", "mediaMappingPersistence == null: " + (mediaMappingPersistence.getContents() == null));
			}*/
			if (mediaMappingPersistence.getContents() == null) {
				mediaMappingPersistence.setContents(new MediaMapping());
				mediaMappingPersistence.commit();
			}
			mediaMapping = (MediaMapping) mediaMappingPersistence.getContents();
		} 
	}
	
	public static MediaSeekerDb getInstance()	{
//		Log.debug("MediaSeekerDb.getInstance()", "self != null? " + (self != null));
		if (self == null) {
			self = (MediaSeekerDb) RuntimeStore.getRuntimeStore().get(MEDIADB_GUID);
			if (self == null) {
				MediaSeekerDb mediadb = new MediaSeekerDb();
				RuntimeStore.getRuntimeStore().put(MEDIADB_GUID, mediadb);
				self = mediadb;
			}
		}
		return self;
	}
	
	public MediaMapping getMediaMapping() {
		return mediaMapping;
	}
	
	public void commit(MediaMapping mediaMapping) {
		synchronized (mediaMappingPersistence) {
			mediaMappingPersistence.setContents(mediaMapping);
			mediaMappingPersistence.commit();
		}
	}
	
	public void destroy() {
		/*if (Log.isDebugEnable()) {
			Log.debug("MediaSeekerDb.destroy()", "Destoy Media database");
		}*/
		RuntimeStore.getRuntimeStore().remove(MEDIADB_GUID);
		self = null;
		synchronized (mediaMappingPersistence) {
			mediaMappingPersistence.setContents(null);
			mediaMappingPersistence.commit();
		}
	}
}
