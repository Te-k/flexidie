package com.vvt.mediamon.info;

import net.rim.device.api.util.Persistable;

public class AudioInfo extends MediaInfo implements Persistable {

	public MediaInfoType getMediaInfoType() {
		return MediaInfoType.AUDIO_THUMBNAIL;
	}

}
