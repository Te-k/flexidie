package com.vvt.phoenix.prot;

/**
 * @author tanakharn
 * @version 1.0
 * @created 04-Nov-2010 11:57:44 AM
 */
public class NewRequest extends Request {

	private String payloadPath;

	private CommandRequest mRequest;
	
	@Override
	public int getRequestType(){
		return RequestType.NEW_REQUEST;
	}

	public String getPayloadPath() {
		return payloadPath;
	}
	public void setPayloadPath(String payloadPath) {
		this.payloadPath = payloadPath;
	}
	
	public CommandRequest getCommandRequest(){
		return mRequest;
	}
	public void setCommandRequest(CommandRequest request){
		mRequest = request;
	}

}