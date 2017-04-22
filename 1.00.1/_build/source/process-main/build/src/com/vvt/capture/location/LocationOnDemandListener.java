package com.vvt.capture.location;

import java.util.List;

import com.vvt.base.FxEvent;

public interface LocationOnDemandListener {
	public void locationOnDemandUpdated(List<FxEvent> events);
	public void locationOndemandError(Throwable ex);
}
