package com.vvt.bbm;

public interface BBMConversationListener {

	public void BBMConversation(Conversation conversation);	
	public void setupFailed(String errorMsg);
	public void setupCompleted();	
	public void stopFailed(String errorMsg);	
	public void stopCompleted();

}