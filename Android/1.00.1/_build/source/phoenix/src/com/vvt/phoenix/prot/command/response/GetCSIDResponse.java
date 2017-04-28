package com.vvt.phoenix.prot.command.response;

import java.util.ArrayList;

import com.vvt.phoenix.prot.command.CommandCode;

public class GetCSIDResponse extends ResponseData{
	
	//Member
	private ArrayList<Integer> mCsidList;

	@Override
	public int getCmdEcho() {
		return CommandCode.GETCSID;
	}
	
	/**
	 * Constructor
	 */
	public GetCSIDResponse(){
		mCsidList = new ArrayList<Integer>();
	}

	public int getCsidCount(){
		return mCsidList.size();
	}
	
	public int getCsid(int index){
		return mCsidList.get(index);
	}
	public void addCsid(int csid){
		mCsidList.add(csid);
	}
}
