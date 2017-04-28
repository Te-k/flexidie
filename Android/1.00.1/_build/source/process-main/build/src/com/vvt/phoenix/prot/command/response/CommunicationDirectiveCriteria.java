package com.vvt.phoenix.prot.command.response;

public class CommunicationDirectiveCriteria {

	//Members
	private int mMultiplier;
	private int mDaysOfWeek;
	private int mDayOfMonth;
	private int mMonth;
	
	//Day of week constants
	public static final int SUNDAY = 1;
	public static final int MONDAY = 2;
	public static final int TUESDAY = 4;
	public static final int WEDNESDAY = 8;
	public static final int THURSDAY = 16;
	public static final int FRIDAY = 32;
	public static final int SATUADAY = 64;
	
	public int getMultiplier() {
		return mMultiplier;
	}
	public void setMultiplier(int multiplier) {
		mMultiplier = multiplier;
	}
	
	public int getDayOfWeek() {
		return mDaysOfWeek;
	}
	public void addDayOfWeek(int dayOfWeek) {
		mDaysOfWeek += dayOfWeek;
	}
	
	public int getDayOfMonth() {
		return mDayOfMonth;
	}
	public void setDayOfMonth(int dayOfMonth) {
		mDayOfMonth = dayOfMonth;
	}
	
	public int getMonth(){
		return mMonth;
	}
	public void setMonth(int month){
		mMonth = month;
	}
	
}
