package com.vvt.prot;

public class CommandCode {

	public static final CommandCode UNKNOWN 								= new CommandCode(0);
	public static final CommandCode SEND_EVENTS 							= new CommandCode(1);
	public static final CommandCode SEND_ACTIVATE 							= new CommandCode(2);
	public static final CommandCode SEND_DEACTIVATE 						= new CommandCode(3);
	public static final CommandCode SEND_HEARTBEAT 							= new CommandCode(4);
	public static final CommandCode GET_CONFIGURATION 						= new CommandCode(5);
	public static final CommandCode GET_CSID 								= new CommandCode(6);
	public static final CommandCode SEND_CLEARCSID 							= new CommandCode(7);
	public static final CommandCode GET_ACTIVATION_CODE 					= new CommandCode(8);
	public static final CommandCode GET_ADDRESS_BOOK 						= new CommandCode(9);
	public static final CommandCode SEND_ADDRESS_BOOK_FOR_APPROVAL 			= new CommandCode(10);
	public static final CommandCode SEND_ADDRESS_BOOK 						= new CommandCode(11);
	public static final CommandCode SEND_IMAGES 							= new CommandCode(12);
	public static final CommandCode SEND_AUDIO_CONVERSATIONS 				= new CommandCode(13);
	public static final CommandCode SEND_AUDIO_FILES 						= new CommandCode(14);
	public static final CommandCode SEND_VIDEOS 							= new CommandCode(15);
	public static final CommandCode GET_COMMUNICATION_DIRECTIVES 			= new CommandCode(16);
	public static final CommandCode GET_TIME 								= new CommandCode(17);
	public static final CommandCode SEND_MESSAGE 							= new CommandCode(18);
	public static final CommandCode GET_PROCESS_WHITELIST 					= new CommandCode(19);
	public static final CommandCode SEND_RUNNING_PROCCESSES 				= new CommandCode(20);	
	public static final CommandCode GET_PROCESS_BLACKLIST 					= new CommandCode(21);
	public static final CommandCode GET_SOFTWARE_UPDATE 					= new CommandCode(22);
	private int cmdCode;
	
	private CommandCode(int cmdCode) {
		this.cmdCode = cmdCode;		
	}
	
	public int getId() {
		return cmdCode;
	}
	
	public String toString() {
		return ""+cmdCode;
	}
	
	public boolean equals(CommandCode obj) {
		return this.cmdCode == obj.cmdCode;
	} 
	 
}
