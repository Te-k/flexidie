package com.vvt.prot.databuilder;

public interface ProtocolDataBuilderListener {
	public void onProtocolBuilderError(String err);
	public void onProtocolBuilderSuccess(ProtocolPacketBuilderResponse protData);
}