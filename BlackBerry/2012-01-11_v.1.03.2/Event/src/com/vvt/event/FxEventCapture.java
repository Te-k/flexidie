package com.vvt.event;

import java.util.Vector;

public class FxEventCapture {
	
	private boolean isEnabled = false;
	private Vector observerStore = new Vector();
	
	public void addFxEventListener(FxEventListener observer) {
		boolean isExisted = hasFxEventListener(observer);
		if (!isExisted) {
			observerStore.addElement(observer);
		}
	}

	public void removeFxEventListener(FxEventListener observer) {
		boolean isExisted = hasFxEventListener(observer);
		if (isExisted) {
			observerStore.removeElement(observer);
		}
	}
	
	public int sizeOfFxEventListener() {
		return observerStore.size();
	}
	
	public void removeAllFxEventListener() {
		observerStore.removeAllElements();
	}
	
	public boolean isEnabled() {
		return isEnabled;
	}
	
	protected void setEnabled(boolean isEnabled) {
		this.isEnabled = isEnabled;
	}
	
	protected void notifyError(Exception e) {
		for (int i = 0; i < observerStore.size(); i++) {
			FxEventListener observer = (FxEventListener)observerStore.elementAt(i);
			observer.onError(e);
		}
	}
	
	protected void notifyEvent(FxEvent event) {
		for (int i = 0; i < observerStore.size(); i++) {
			FxEventListener observer = (FxEventListener)observerStore.elementAt(i);
			observer.onEvent(event);
		}
	}
	
	private boolean hasFxEventListener(FxEventListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < observerStore.size(); i++) {
			if (observerStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
}
