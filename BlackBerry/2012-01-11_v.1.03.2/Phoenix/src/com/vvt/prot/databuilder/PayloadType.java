package com.vvt.prot.databuilder;

public class PayloadType {

	public static final PayloadType FILE = new PayloadType(0);
	public static final PayloadType BUFFER = new PayloadType(1);
	private int type;
	
	private PayloadType(int type) {
		this.type = type;
	}
	
	public boolean equals(PayloadType obj) {
		return this.type == obj.type;
	} 
	
	public String toString() {
		return "" + type;
	}
}
