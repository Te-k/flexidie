package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.EventType;

public class FxVideoFileEvent extends FxMediaEvent implements Persistable {
	
	public FxVideoFileEvent() {
		setEventType(EventType.VIDEO);
	}	
}
