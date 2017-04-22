package com.vvt.phoenix.prot.command;

public class CommandMetaDataWrapper {
	
	private int mTransportDirective;
	private int mPayloadSize;
	private long mPayloadCrc32;
	private CommandMetaData mMetaData;
	
	public int getTransportDirective() {
		return mTransportDirective;
	}
	/**
	 * @param transportDirective from TransportDirectives
	 */
	public void setTransportDirective(int transportDirective) {
		mTransportDirective = transportDirective;
	}
	
	public int getPayloadSize() {
		return mPayloadSize;
	}
	public void setPayloadSize(int paylodSize) {
		mPayloadSize = paylodSize;
	}
	
	public long getPayloadCrc32() {
		return mPayloadCrc32;
	}
	public void setPayloadCrc32(long payloadCrc32) {
		mPayloadCrc32 = payloadCrc32;
	}
	
	public CommandMetaData getCommandMetaData() {
		return mMetaData;
	}
	public void setCommandMetaData(CommandMetaData metaData) {
		mMetaData = metaData;
	}

}
