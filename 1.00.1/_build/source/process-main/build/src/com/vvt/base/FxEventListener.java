package com.vvt.base;

import java.util.List;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 10:54:56
 */

/**
 * Base class that will receive events from a component.
 */
public interface FxEventListener {

	public void onEventCaptured(List<FxEvent> events);

}