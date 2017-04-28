package com.vvt.network;

public class NetworkServiceInfo {

	public static enum State { UNKNOWN, ACTIVE, INACTIVE};
	public static enum Type { UNKNOWN, GSM, CDMA };
	
	private State state;
	private Type type;
	
	public NetworkServiceInfo() {
		state = State.UNKNOWN;
		type = Type.UNKNOWN;
	}
	
	public State getState() {
		return state;
	}
	public void setState(State state) {
		this.state = state;
	}
	public Type getType() {
		return type;
	}
	public void setType(Type type) {
		this.type = type;
	}
	
	@Override
	public String toString() {
		return String.format(
				"NetworkInfo: state=%s, type=%s", 
				state.toString(), type.toString());
	}
	
	@Override
	public boolean equals(Object obj) {
		return state == ((NetworkServiceInfo) obj).getState() && 
				type == ((NetworkServiceInfo) obj).getType();
	}
	
	@Override
	public int hashCode() {
		String temp = state.toString() + type.toString();
		return temp.hashCode();
	}
	
}
