package com.vvt.prot;

public class ExecutorState {
	
	public static final ExecutorState IDLE = new ExecutorState(0);
	public static final ExecutorState DEQUEUE = new ExecutorState(1);
	public static final ExecutorState REQUEST_KEYEXCHANGE = new ExecutorState(2);
	public static final ExecutorState BUILD_PAYLOAD = new ExecutorState(3);
	public static final ExecutorState SEND_REQUEST = new ExecutorState(4);
	public static final ExecutorState READ_RESPONSE = new ExecutorState(5);
	private int type;
	
	private ExecutorState(int type) {
		this.type = type;
	}

	public int getStateId() {
		return type;
	}
	
	public String name() {
		return "" + type;
	}
}
