package com.vvt.eventdelivery;

import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.eventrepository.FxEventRepository;

public class InitializeParameters {

	private int callerId;
	private DataDelivery dataDelivery;
	private FxEventRepository eventRepository;
	
	public int getCallerId() {
		return callerId;
	}
	public void setCallerId(int callerId) {
		this.callerId = callerId;
	}
	
	public DataDelivery getDataDelivery() {
		return dataDelivery;
	}
	public void setDataDelivery(DataDelivery dataDelivery) {
		this.dataDelivery = dataDelivery;
	}
	public FxEventRepository getEventRepository() {
		return eventRepository;
	}
	public void setEventRepository(FxEventRepository eventRepository) {
		this.eventRepository = eventRepository;
	}
	
}
