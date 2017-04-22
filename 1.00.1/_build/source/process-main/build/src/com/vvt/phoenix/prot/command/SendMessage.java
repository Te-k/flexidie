package com.vvt.phoenix.prot.command;

public class SendMessage implements CommandData{
	
	//Members
	private int mCategory;
	private int mPriority;
	private String mMessage;

	@Override
	public int getCmd() {
		return CommandCode.SEND_MESSAGE;
	}
	
	/**
	 * Constructor
	 */
	public SendMessage(){
		mCategory = 0;
		mPriority = MessagePriority.NORMAL;
	}
	
	public int getCategory(){
		return mCategory;
	}
	public void setCategory(int category){
		mCategory = category;
	}
	
	public int getPriority(){
		return mPriority;
	}
	/**
	 * @param priority: MessagePriority
	 */
	public void setPriority(int priority){
		mPriority = priority;
	}
	
	public String getMessage(){
		return mMessage;
	}
	public void setMessage(String message){
		mMessage = message;
	}

}
