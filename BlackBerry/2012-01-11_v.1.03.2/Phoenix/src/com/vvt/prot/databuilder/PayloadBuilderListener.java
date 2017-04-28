package com.vvt.prot.databuilder;

public interface PayloadBuilderListener {

	public void onPayloadBuilderError(Exception e);
	public void onPayloadBuilderCompleted(PayloadBuilderResponse response);
}
