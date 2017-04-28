package com.vvt.activation_manager;

import com.vvt.datadeliverymanager.enums.ErrorResponseType;


/**
 * @author Aruna
 * @version 1.0
 * @created 15-Nov-2011 11:24:29
 */
public interface ActivationListener {

	public void onSuccess();

	public void onError(ErrorResponseType errorType, int code, String msg);

}