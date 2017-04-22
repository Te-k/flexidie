package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.FxDebugMode;

public class FxGpsBatteryLifeDebugEvent extends FxBatteryLifeDebugEvent implements Persistable {
	
	// FxBatteryLifeDebugEvent
	public FxDebugMode getMode() {
		return FxDebugMode.GPS;
	}
}
