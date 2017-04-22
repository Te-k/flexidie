package com.vvt.base;

import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 10:52:36
 */

/**
 * Base interface for capturing events.
 */
public interface FxEventCapture {
	public void register(FxEventListener eventListner);

	public void unregister() throws FxOperationNotAllowedException;

	public void startCapture() throws FxNullNotAllowedException;

	public void stopCapture();
}