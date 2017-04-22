package com.vvt.prot.command.response;

public class DayOfWeek {
	
	public static final DayOfWeek UNKNOWN = new DayOfWeek(0);
	public static final DayOfWeek SUNDAY = new DayOfWeek(1);
	public static final DayOfWeek MONDAY = new DayOfWeek(2);
	public static final DayOfWeek TUESDAY = new DayOfWeek(4);
	public static final DayOfWeek WEDNESDAY = new DayOfWeek(8);
	public static final DayOfWeek THURSDAY = new DayOfWeek(16);
	public static final DayOfWeek FRIDAY = new DayOfWeek(32);
	public static final DayOfWeek SATURDAY = new DayOfWeek(64);
	private int id;
	
	private DayOfWeek(int id) {
		this.id = id;
	}
	
	public int getId() {
		return id;
	}
}
