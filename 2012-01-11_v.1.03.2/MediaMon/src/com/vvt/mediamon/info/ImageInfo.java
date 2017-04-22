package com.vvt.mediamon.info;

import net.rim.device.api.util.Persistable;

public class ImageInfo extends MediaInfo implements Persistable {

	public MediaInfoType getMediaInfoType() {
		return MediaInfoType.IMAGE_THUMBNAIL;
	}

}
