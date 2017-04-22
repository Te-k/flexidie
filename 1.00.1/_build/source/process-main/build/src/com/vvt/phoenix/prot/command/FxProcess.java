package com.vvt.phoenix.prot.command;

public class FxProcess {
	
	//Members
	private int mCategory;
	private String mName;
	
	public int getCategory(){
		return mCategory;
	}
	/**
	 * @param category from ProcessCategory
	 */
	public void setCategory(int category){
		mCategory = category;
	}
	
	public String getName(){
		return mName;
	}
	public void setName(String name){
		mName = name;
	}
}
