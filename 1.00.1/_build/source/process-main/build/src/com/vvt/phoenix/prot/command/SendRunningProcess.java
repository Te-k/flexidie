package com.vvt.phoenix.prot.command;

import java.util.ArrayList;

public class SendRunningProcess implements CommandData{
	
	//Member
	private ArrayList<FxProcess> mProcessList;

	@Override
	public int getCmd() {
		return CommandCode.SEND_RUNNING_PROCESS;
	}

	/**
	 * Constructor 
	 */
	public SendRunningProcess(){
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
