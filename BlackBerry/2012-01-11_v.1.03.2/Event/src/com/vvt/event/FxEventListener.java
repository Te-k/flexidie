package com.vvt.event;

public interface FxEventListener {
	public void onEvent(FxEvent event);
	public void onError(Exception e);
}
