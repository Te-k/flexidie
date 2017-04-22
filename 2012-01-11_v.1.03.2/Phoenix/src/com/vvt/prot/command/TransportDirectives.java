package com.vvt.prot.command;

import net.rim.device.api.util.Persistable;

public class TransportDirectives implements Persistable {
	
	public static final TransportDirectives UNKNOWN = new TransportDirectives(0);
	public static final TransportDirectives RESUMABLE = new TransportDirectives(1);
	public static final TransportDirectives NON_RESUMABLE = new TransportDirectives(2);
	public static final TransportDirectives RSEND = new TransportDirectives(3);
	public static final TransportDirectives RASK = new TransportDirectives(4);
	private int transportId;
	
	private TransportDirectives(int transportId) {
		this.transportId = transportId;
	}
	
	public int getId() {
		return transportId;
	}
	
	public String toString() {
		return "" + transportId;
	}
	
	public boolean equals(TransportDirectives obj) {
		return this.transportId == obj.transportId;
	}
	
}