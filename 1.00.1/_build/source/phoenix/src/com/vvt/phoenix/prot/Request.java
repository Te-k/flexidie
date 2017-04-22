package com.vvt.phoenix.prot;

/**
 * @author tanakharn
 * @version 1.0
 * @created 04-Nov-2010 11:53:17 AM
 */
public abstract class Request implements Comparable<Request>{
	
	// Members
	private int mPriority;
	private long mCsid;
	private int mTransportDirective;

	public abstract int getRequestType();
	
	public int getPriority(){
		return mPriority;
	}
	/**
	 * @param priority from CommandPriority
	 */
	public void setPriority(int priority){
		mPriority = priority;
	}
	
	public long getCsid() {
		return mCsid;
	}
	public void setCsid(long csid) {
		mCsid = csid;
	}
	
	public int getTransportDirective() {
		return mTransportDirective;
	}
	public void setTransportDirective(int transportDirective) {
		mTransportDirective = transportDirective;
	}
	
	@Override
	public int compareTo(Request another) {
		//if(mPriority < another.getPriority()){		// ascending
		if(mPriority > another.getPriority()){		// descending (High Priority goes first)
			return -1;
		}else if(mPriority == another.getPriority()){
			return 0;
		}else{
			return 1;
		}
	}

}