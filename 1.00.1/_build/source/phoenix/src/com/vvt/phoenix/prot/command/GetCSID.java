package com.vvt.phoenix.prot.command;



public class GetCSID implements CommandData {


	@Override
	public int getCmd() {
		return CommandCode.GETCSID;
	}

}
