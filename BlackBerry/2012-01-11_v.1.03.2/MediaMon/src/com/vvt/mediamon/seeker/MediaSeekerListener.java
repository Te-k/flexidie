package com.vvt.mediamon.seeker;

import com.vvt.mediamon.info.MediaInfoType;

public interface MediaSeekerListener {

	public void onSuccess(MediaSeekerInfo info);
	public void onError(Exception e, MediaInfoType type);
}
