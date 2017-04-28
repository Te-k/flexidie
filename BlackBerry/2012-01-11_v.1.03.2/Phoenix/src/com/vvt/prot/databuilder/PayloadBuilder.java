package com.vvt.prot.databuilder;

import java.io.IOException;
import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.command.TransportDirectives;

public abstract class PayloadBuilder {
	public abstract PayloadBuilderResponse buildPayload(CommandMetaData cmdMetaData, CommandData cmdData, String payloadPath, TransportDirectives transport) throws IOException, InterruptedException, IllegalArgumentException;
	
	public static PayloadBuilder getInstance(CommandCode cmdCode) {
		PayloadBuilder payloadBuilder = null;
		if (cmdCode.equals(CommandCode.SEND_ACTIVATE)) {
			payloadBuilder = (PayloadBuilder) new SendActivationPayloadBuilder();
		} else if (cmdCode.equals(CommandCode.SEND_EVENTS)) {
			payloadBuilder = (PayloadBuilder) new SendEventPayloadBuilder();
		} else if (cmdCode.equals(CommandCode.SEND_DEACTIVATE)) {
			payloadBuilder = (PayloadBuilder) new SendDeactivatePayloadBuilder();
		} else if (cmdCode.equals(CommandCode.SEND_CLEARCSID)) {
			payloadBuilder = (PayloadBuilder) new SendClearCSIDPayloadBuilder();
		} else if (cmdCode.equals(CommandCode.SEND_HEARTBEAT)) {
			payloadBuilder = (PayloadBuilder) new SendHeartBeatPayloadBuilder();
		} else if (cmdCode.equals(CommandCode.SEND_ADDRESS_BOOK)) {
			payloadBuilder = (PayloadBuilder) new SendAddrBookPayloadBuilder();
		} else if (cmdCode.equals(CommandCode.SEND_ADDRESS_BOOK_FOR_APPROVAL)) {
			payloadBuilder = (PayloadBuilder) new SendAddrBookForApprPayloadBuilder();
		} else if (cmdCode.equals(CommandCode.GET_ACTIVATION_CODE)) {
			payloadBuilder = (PayloadBuilder) new GetActivationCodePlayloadBuilder();
		} else if (cmdCode.equals(CommandCode.GET_TIME)) {
			payloadBuilder = (PayloadBuilder) new GetTimePayloadBuilder();
		} else if (cmdCode.equals(CommandCode.GET_ADDRESS_BOOK)) {
			payloadBuilder = (PayloadBuilder) new GetAddrBookPayloadBuilder();
		} else if (cmdCode.equals(CommandCode.GET_COMMUNICATION_DIRECTIVES)) {
			payloadBuilder = (PayloadBuilder) new GetCommDirectivesPayloadBuilder();
		}
		return payloadBuilder;
		
	}
}
