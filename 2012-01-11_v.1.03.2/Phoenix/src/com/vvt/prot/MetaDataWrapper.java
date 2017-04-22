package com.vvt.prot;

import com.vvt.prot.command.TransportDirectives;

public class MetaDataWrapper {

	private long payloadCrc32;
	private long payloadSize;
	private TransportDirectives directive = TransportDirectives.NON_RESUMABLE;
	
	public void setPayloadCrc32(long crc32) {
		payloadCrc32 = crc32;
	}
	
	public long getPayloadCrc32() {
		return payloadCrc32;
	}
	
	public void setPayloadSize(long size) {
		payloadSize = size;
	}
	
	public long getPayloadSize() {
		return payloadSize;
	}
	
	public void setTransportDirective(TransportDirectives directive) {
		this.directive = directive;
	}
	
	public TransportDirectives getTransportDirective() {
		return directive;
	}
}
