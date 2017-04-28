package com.vvt.phoenix.prot.command;


public class SendEvents implements CommandData{
	
	//Member
	public DataProvider mEventProvider;

	@Override
	public int getCmd() {
		return CommandCode.SEND_EVENT;
	}
	
	public DataProvider getEventProvider(){
		return mEventProvider;
	}
	public void setEventProvider(DataProvider eventProvider){
		mEventProvider = eventProvider;
	}


}
