package com.vvt.datadeliverymanager.interfaces;

import com.vvt.datadeliverymanager.DeliveryRequest;

/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 11:10:49
 */
public interface DataDelivery {

	/**
	 * 
	 * @param deliveryRequest
	 */
	public void deliver(DeliveryRequest deliveryRequest) ;
	
}