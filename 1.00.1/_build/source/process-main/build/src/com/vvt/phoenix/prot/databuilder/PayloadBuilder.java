package com.vvt.phoenix.prot.databuilder;

import java.io.IOException;

import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.CommandMetaData;

public abstract class PayloadBuilder{

	public abstract PayloadBuilderResponse buildPayload(CommandMetaData metaData, 
			CommandData commandData, String payloadPath, int transportDirective) throws Exception;
	protected abstract void appendCommandCode() throws IOException;
	protected abstract void appendCommandData() throws Exception;
	protected abstract void compressPayload();
	protected abstract void encryptPayload();
	
	
	public static PayloadBuilder getInstance(int cmdCode){
		PayloadBuilder builder = null;
		switch(cmdCode){
			case CommandCode.UNKNOWN_OR_RASK					: 	break;
			case CommandCode.SEND_EVENT						:	builder = new SendEventsPayloadBuilder();break;
			case CommandCode.SEND_ACTIVATE					:	builder = new SendActivatePayloadBuilder();break;
			case CommandCode.SEND_DEACTIVATE				:	builder = new SendDeactivatePayloadBuilder();break;
			case CommandCode.SEND_HEARTBEAT					:	builder = new SendHeartBeatPayloadBuilder();break;
			case CommandCode.REQUEST_CONFIGURATION			:	builder = new GetConfigPayloadBuilder();break;
			case CommandCode.GETCSID						:	builder = new GetCsidPayloadBuilder();break;
			case CommandCode.CLEARSID						:	builder = new SendClearCsidPayloadBuilder();break;
			case CommandCode.REQUEST_ACTIVATION_CODE		:	builder = new GetActivationCodePayloadBuilder();break;
			case CommandCode.GET_ADDRESS_BOOK				:	builder = new GetAddrBookPayloadBuilder();break;
			case CommandCode.SEND_ADDRESS_BOOK_FOR_APPROVAL	:	builder = new SendAddrBookForApprPayloadBuilder();break;
			case CommandCode.SEND_ADDRESS_BOOK				:	builder = new SendAddrBookPayloadBuilder();break;
			case CommandCode.GET_COMMU_MANAGER_SETTINGS		:	builder = new GetCommuManagerSettingsPayloadBuilder();break;
			case CommandCode.GET_TIME						:	builder = new GetTimePayloadBuilder();break;
			case CommandCode.SEND_MESSAGE					:	builder = new SendMessagePayloadBuilder();break;
			case CommandCode.GET_PROCESS_WHITE_LIST			:	builder = new GetProcessWhiteListPayloadBuilder();break;
			case CommandCode.SEND_RUNNING_PROCESS			:	builder = new SendRunningProcessPayloadBuilder();break;
			case CommandCode.GET_PROCESS_BLACK_LIST			:	builder = new GetProcessBlackListPayloadBuilder();break;
			default											:	break;
		}
				
		return builder;
	}

}
