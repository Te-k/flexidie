package com.vvt.datadeliverymanager.interfaces;

import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.RequestExecutor;

/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 11:10:51
 */
public interface DeliveryListener {

	public RequestExecutor RequestExecutor = null;

	/**
	 * 
	 * @param response
	 */
	public void onFinish(DeliveryResponse response);

	/**
	 * 
	 * @param response
	 */
	public void onProgress(DeliveryResponse response);

}