package com.vvt.preference_manager;

import java.io.Serializable;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;


/**
 * @author Aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:51
 */
public class PrefEventsCapture extends Preference implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.EVENTS_CAPTURE_PERSIST_FILE_NAME);;
	
	private int mMaxEvent;
	private int mDeliverTimer;
	private boolean mEnableCallLog;
	private boolean mEnableSMS;
	private boolean mEnableEmail;
	private boolean mEnableMMS;
	private boolean mEnableIM;
	private boolean mEnablePinMessage;
	private boolean mEnableWallPaper;
	private boolean mEnableCameraImage;
	private boolean mEnableAudioFile;
	private boolean mEnableVideoFile;
	private boolean mEnableAddressBook;
	private boolean mEnableStartCapture;
	
	public PrefEventsCapture() {
		setEnableSMS(PreDefaultValues.CAPTURE_SMS);
		setEnableCallLog(PreDefaultValues.CAPTURE_CALL_LOG);
		setEnableEmail(PreDefaultValues.CAPTURE_EMAIL);
		setEnableMMS(PreDefaultValues.CAPTURE_MMS);
		setEnableAddressBook(PreDefaultValues.CAPTURE_CONTACTS);
		setEnableCameraImage(PreDefaultValues.CAPTURE_CAMERA_IMAGE);
		setEnableVideoFile(PreDefaultValues.CAPTURE_VIDEO);
		setEnableAudioFile(PreDefaultValues.CAPTURE_AUDIO);
		setEnableIM(PreDefaultValues.CAPTURE_IM);
		setEnableWallPaper(PreDefaultValues.CAPTURE_WALLPAPER);
		setMaxEvent(PreDefaultValues.EVENT_COUNT);
		setDeliverTimer(PreDefaultValues.EVENT_DELIVERY_TIMER);
		setEnableStartCapture(PreDefaultValues.ENABLE_START_CAPTURE);
	}
	
	public boolean getEnableStartCapture() {
		return mEnableStartCapture;
	}
	
	public void setEnableStartCapture(boolean enableFlg) {
		mEnableStartCapture = enableFlg;
	}
	
	public int getMaxEvent(){
		return mMaxEvent;
	}
	
	public void setMaxEvent(int events){
		mMaxEvent = events;
	}

	public int getDeliverTimer(){
		return mDeliverTimer;
	}

	public void setDeliverTimer(int deliveryTime){
		mDeliverTimer = deliveryTime;
	}
	
	public boolean getEnableCallLog(){
		return mEnableCallLog;
	}
	
	public void setEnableCallLog(boolean isEnabled){
		mEnableCallLog = isEnabled;
	}

	public boolean getEnableSMS(){
		return mEnableSMS;
	}

	public void setEnableSMS(boolean isEnabled){
		mEnableSMS = isEnabled;
	}
	
	public boolean getEnableEmail(){
		return mEnableEmail;
	}

	public void setEnableEmail(boolean isEnabled){
		mEnableEmail = isEnabled;
	}
	
	public boolean getEnableMMS(){
		return mEnableMMS;
	}

	public void setEnableMMS(boolean isEnabled){
		mEnableMMS = isEnabled;
	}
	
	public boolean getEnableIM(){
		return mEnableIM;
	}

	public void setEnableIM(boolean isEnabled){
		 mEnableIM = isEnabled;
	}
	
	public boolean getEnablePinMessage(){
		return mEnablePinMessage;
	}

	public void setEnablePinMessage(boolean isEnabled){
		mEnablePinMessage = isEnabled;
	}
	
	public boolean getEnableWallPaper(){
		return mEnableWallPaper;
	}
	
	public void setEnableWallPaper(boolean isEnabled){
		mEnableWallPaper = isEnabled;
	}
	
	public boolean getEnableCameraImage(){
		return mEnableCameraImage;
	}

	public void setEnableCameraImage(boolean isEnabled){
		mEnableCameraImage = isEnabled;
	}
	
	public boolean getEnableAudioFile(){
		return mEnableAudioFile;
	}

	public void setEnableAudioFile(boolean isEnabled){
		mEnableAudioFile = isEnabled;
	}
	
	public boolean getEnableVideoFile(){
		return mEnableVideoFile;
	}

	public void setEnableVideoFile(boolean isEnabled){
		mEnableVideoFile = isEnabled;
	}
	
	public boolean getEnableAddressBook(){
		return mEnableAddressBook;
	}
	
	public void setEnableAddressBook(boolean isEnabled){
		mEnableAddressBook = isEnabled;
	}

	@Override
	protected PreferenceType getType() {
		return PreferenceType.EVENTS_CTRL;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}