package com.vvt.activation_manager;

import com.vvt.exceptions.FxConcurrentRequestNotAllowedException;
import com.vvt.exceptions.FxExecutionTimeoutException;


/**
 * @author Aruna
 * @version 1.0
 * @created 15-Nov-2011 11:24:29
 */
public interface ActivationManager {

	/**
	 * 
	 * @param listener
	 * @throws FxExecutionTimeoutException 
	 */
	public void autoActivate(ActivationListener listener) throws FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException; 

	/**
	 * 
	 * @param url
	 * @param listener
	 * @throws FxExecutionTimeoutException 
	 */
	public void autoActivate(String url, ActivationListener listener) throws FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException;

	/**
	 * 
	 * @param url
	 * @param actCode
	 * @param listener
	 * @throws FxExecutionTimeoutException 
	 */
	public void activate(String url, String actCode, ActivationListener listener) throws FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException;

	/**
	 * 
	 * @param actCode
	 * @param listener
	 * @throws FxExecutionTimeoutException 
	 */
	public void activate(String actCode, ActivationListener listener) throws FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException;

	/**
	 * 
	 * @param listener
	 * @throws FxExecutionTimeoutException 
	 */
	public void deactivate(String activationCode, ActivationListener listener) throws FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException;

}