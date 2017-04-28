package com.vvt.eventdelivery;

import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.exceptions.database.FxDbIdNotFoundException;

public interface EventDelivery {

	public void deliverRegularEvents();
	public void deliverRegularEvents(DeliveryListener listener);
	public void deliverSystemEvents();
	public void deliverSettingsEvents();
	public void deliverPanicEvents();
	public void deliverActualMedia(int paringId, DeliveryListener listener) throws FxDbIdNotFoundException;
	
	public enum Type {
		TYPE_PANIC, TYPE_SYSTEM, TYPE_SETTINGS, TYPE_REGULAR, TYPE_ACTUAL_MEDIA
	}
}
