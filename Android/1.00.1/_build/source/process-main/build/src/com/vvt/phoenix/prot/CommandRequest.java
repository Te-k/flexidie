package com.vvt.phoenix.prot;

import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.CommandMetaData;

public class CommandRequest {

	//Members
	private int mPriority;
	private CommandMetaData mMetaData;
	private CommandData mCommandData;
	private CommandListener mListener;
		
	public int getPriority(){
		return mPriority;
	}
	/**
	 * @param priority in CommandPriority
	 */
	public void setPriority(int priority){
		mPriority = priority;
	}
	
	public CommandMetaData getMetaData(){
		return mMetaData;
	}
	public void setMetaData(CommandMetaData metaData){
		mMetaData = metaData;
	}
	
	public CommandData getCommandData(){
		return mCommandData;
	}
	public void setCommandData(CommandData data){
		mCommandData = data;
	}
	
	/*public long getCsid(){
		return mCsid;
	}
	public void setCsid(long csid){
		mCsid = csid;
	}*/
	
	public CommandListener getCommandListener(){
		return mListener;
	}
	public void setCommandListener(CommandListener listener){
		mListener = listener;
	}
	
	/*public String getPayloadPath(){
		return mPayloadPath;
	}
	public void setPayloadPath(String path){
		mPayloadPath = path;
	}*/
}
