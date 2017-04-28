package com.vvt.protsrv.addr;

public class ApprovalStatus {
	public static final ApprovalStatus NO_STATUS = new ApprovalStatus(0);
	public static final ApprovalStatus AWAITING_APPROVAL = new ApprovalStatus(1);
	public static final ApprovalStatus APPROVED = new ApprovalStatus(2);
	public static final ApprovalStatus NOT_APPROVED = new ApprovalStatus(3);
	private int state;
	
	private ApprovalStatus(int state) {
		this.state = state;
	}

	public int getId() {
		return state;
	}
}
