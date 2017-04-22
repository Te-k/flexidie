package com.vvt.phoenix.prot.command.response;

import java.util.ArrayList;

import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.command.FxProcess;

public class GetProcessBlackListResponse extends ResponseData{
	
	//Member
	private ArrayList<FxProcess> mProcessList;

	@Override
	public int getCmdEcho() {
		return CommandCode.GET_PROCESS_BLACK_LIST;
	}
	
	/**
	 * Constructor
	 */
	public GetProcessBlackListResponse(){
		mProcessList = new ArrayList<FxProcess>();
	}
	
	public int getProcessCount(){
		return mProcessList.size();
	}
	
	public FxProcess getProcess(int index){
		return mProcessList.get(index);
	}
	public void addProcess(FxProcess process){
		mProcessList.add(process);
	}
	

}
