package com.vvt.eventrepository;

/**
 * @author aruna
 * @version 1.0
 * @created 01-Sep-2011 04:15:59
 */
public interface RepositoryChangeListener {

	public void onEventAdd();

	public void onReachMaxEventNumber();

	public void onSystemEventAdd();

	public void onPanicEventAdd();
	
	public void onSettingEventAdd();
}