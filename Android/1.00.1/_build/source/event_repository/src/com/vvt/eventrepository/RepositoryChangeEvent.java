package com.vvt.eventrepository;

/**
 * @author aruna
 * @version 1.0
 * @created 01-Sep-2011 04:16:01
 */
public enum RepositoryChangeEvent {
	EVENT_ADD(0),
	EVENT_REACH_MAX_NUMBER(1),
	SYSTEM_EVENT_ADD(2),
	PANIC_EVENT_ADD(3),
	SETTING_EVENT_ADD(4);
	
	private int number;

	RepositoryChangeEvent(int number) {
       this.number = number;
    }

    public int getNumber() {
        return number;
    }
} 