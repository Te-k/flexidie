package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxDebugMode;

public abstract class FxDebugMessageEvent extends FxEvent implements Persistable {
	
	
	public FxDebugMessageEvent() {
		setEventType(EventType.DEBUG);
	}
	
	public abstract FxDebugMode getMode();
}
