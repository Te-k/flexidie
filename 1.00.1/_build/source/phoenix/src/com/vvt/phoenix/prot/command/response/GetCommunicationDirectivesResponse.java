package com.vvt.phoenix.prot.command.response;

import java.util.ArrayList;

import com.vvt.phoenix.prot.command.CommandCode;

public class GetCommunicationDirectivesResponse extends ResponseData{
	
	//Members
	private ArrayList<CommunicationDirective> mRuleList;

	@Override
	public int getCmdEcho() {
		return CommandCode.GET_COMMU_MANAGER_SETTINGS;
	}
	
	public GetCommunicationDirectivesResponse(){
		mRuleList = new ArrayList<CommunicationDirective>();
	}
	
	public int getCount(){
		return mRuleList.size();
	}
	
	public CommunicationDirective getCommunicationRule(int index){
		return mRuleList.get(index);
	}
	public void addCommunicationRule(CommunicationDirective rule){
		mRuleList.add(rule);
	}

}
