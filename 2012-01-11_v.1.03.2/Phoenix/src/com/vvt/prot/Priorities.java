package com.vvt.prot;

public class Priorities {
	
	public static final Priorities NORMAL 	= new Priorities(0);
	public static final Priorities HIGH 	= new Priorities(1);
	public static final Priorities HIGHEST 	= new Priorities(2);
	
	private int priority;
	
	private Priorities(int priority) {
		this.priority = priority;
	}
	
	public int getPriority() {
		return priority;
	}
	
	public String name() {
		return "" + priority;
	}
	
	public int compareTo(Priorities p)	{
		int result = 0;
		if (this.priority < p.priority)	{
			result = -1;
		}
		else if (this.priority > p.priority)	{
			result = 1;
		}
		return result;
	}
}
