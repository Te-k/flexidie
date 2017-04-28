package com.vvt.prot.event;

public class RecipientTypes {

	public static final RecipientTypes TO = new RecipientTypes(0);
	public static final RecipientTypes CC = new RecipientTypes(1);
	public static final RecipientTypes BCC = new RecipientTypes(2);
	private int recipientType;
	
	private RecipientTypes(int recipientType) {
		this.recipientType = recipientType;
	}
	
	public int getId() {
		return recipientType;
	}
	
	public String toString() {
		return "" + recipientType;
	}
}
