package com.vvt.eventrepository;

import java.util.HashSet;

/**
 * @author aruna
 * @version 1.0
 * @created 01-Sep-2011 04:16:00
 */
public class RepositoryChangePolicy {

	private int m_MaxNumber;
	public HashSet<RepositoryChangeEvent> m_RepositoryChangeEvent;

	public RepositoryChangePolicy() {
		m_RepositoryChangeEvent = new HashSet<RepositoryChangeEvent>();
	}

	public void addChangeEvent(RepositoryChangeEvent event) {
		m_RepositoryChangeEvent.add(event);
	}

	public HashSet<RepositoryChangeEvent> getChangeEvent() {
		return m_RepositoryChangeEvent;
	}

	public int getMaxEventNumber() {
		return m_MaxNumber;
	}

	public void setMaxEventNumber(int maxNumber) {
		m_MaxNumber = maxNumber;
	}

}