package com.vvt.prot.event;

public class Direction {
	
	public static final Direction UNKNOWN = new Direction(0);
	public static final Direction IN = new Direction(1);
	public static final Direction OUT = new Direction(2);
	public static final Direction MISSED_CALL = new Direction(3);
	public static final Direction LOCAL_IM = new Direction(4);
	private int directionType;
	
	private Direction(int directionType) {
		this.directionType = directionType;
	}
	
	public int getId() {
		return directionType;
	}
	
	public String toString() {
		return "" + directionType;
	}
}