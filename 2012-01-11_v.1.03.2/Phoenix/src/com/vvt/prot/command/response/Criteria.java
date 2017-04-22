package com.vvt.prot.command.response;

public class Criteria {

	private int multiplier = 0;
	private int dayOfMonth = 0;
	private int month = 0;
	private DayOfWeek dayOfWeek = DayOfWeek.UNKNOWN;
	
	public int getMultiplier() {
		return multiplier;
	}
	
	public int getDayOfMonth() {
		return dayOfMonth;
	}
	
	public int getMonth() {
		return month;
	}
	
	public DayOfWeek getDayOfWeek() {
		return dayOfWeek;
	}
	
	public void setMultiplier(int multiplier) {
		this.multiplier = multiplier;
	}
	
	public void setDayOfMonth(int dayOfMonth) {
		this.dayOfMonth = dayOfMonth;
	}
	
	public void setMonth(int month) {
		this.month = month;
	}
	
	public void setDayOfWeek(DayOfWeek dayOfWeek) {
		this.dayOfWeek = dayOfWeek;
	}
}
