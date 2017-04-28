package com.vvt.base;

/**
 * @author aruna
 * @version 1.0
 * @created 13-Jul-2011 10:52:37
 */

/**
 * Provides license related information
 */

public class FxLicenseInfo {

	private boolean m_isActivated;
	private String m_ActivationCode;

	public void setIsActivate(boolean isActivated) {
		m_isActivated = isActivated;
	}

	public boolean getActivated() {
		return m_isActivated;
	}

	public void setActivationCode(String activationCode) {
		m_ActivationCode = activationCode;
	}

	public String getActivationCode() {
		return m_ActivationCode;
	}

}