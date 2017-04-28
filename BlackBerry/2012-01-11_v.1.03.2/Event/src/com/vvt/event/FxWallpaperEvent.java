package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.EventType;

public class FxWallpaperEvent extends FxMediaEvent implements Persistable {

	public FxWallpaperEvent() {
		setEventType(EventType.WALLPAPER);
	}

}
