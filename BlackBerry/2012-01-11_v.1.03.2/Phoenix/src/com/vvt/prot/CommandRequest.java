package com.vvt.prot;

public class CommandRequest {
	
	private CommandListener cmdListener	= null;
	private CommandData 	cmdData		= null;
	private CommandMetaData cmdMetaData	= null;
	private String 			url			= null;
	private Priorities 		priority	= Priorities.NORMAL;
	
	public CommandRequest()	{		
	}
	
	public void setCommandData(CommandData cmdData) {
		this.cmdData = cmdData;
	}
	
	public CommandData getCommandData() {
		return cmdData;
	}
	
	public void setCommandMetaData(CommandMetaData cmdMetaData) {
		this.cmdMetaData = cmdMetaData;
	}
	
	public CommandMetaData getCommandMetaData() {
		return cmdMetaData;
	}
	
	public void setUrl(String url) {
		this.url = url;
	}
	
	public String getUrl() {
		return url;
	}
	
	public void setCommandListener(CommandListener cmdListener) {
		this.cmdListener = cmdListener;
	}
	
	public CommandListener getCommandListener() {
		return cmdListener;
	}
	
	public void setPriority(Priorities priority) {
		this.priority = priority;
	}
	
	public Priorities getPriority() {
		return priority;
	}
}
