package com.vvt.phoenix.prot.command.response;

import java.util.ArrayList;

public class PCC {
	
	// Members
	private int mPccCode;
	private ArrayList<String> mArgumentList;
	
	/**
	 * Constructor
	 */
	public PCC(int code){
		mPccCode = code;
		mArgumentList = new ArrayList<String>();
	}
	
	public int getPccCode(){
		return mPccCode;
	}
	/**
	 * @param code from PccCode
	 */
	public void setPccCode(int code){
		mPccCode = code;
	}
	
	public int getArgumentCount(){
		return mArgumentList.size();
	}
	public String getArgument(int index){
		return mArgumentList.get(index);
	}
	public void addArgument(String arg){
		mArgumentList.add(arg);
	}

}
