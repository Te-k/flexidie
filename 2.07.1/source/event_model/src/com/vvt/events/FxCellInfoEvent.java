package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 01:58:04
 */
public class FxCellInfoEvent extends FxEvent {

	private String mNetworkId;
	private String mNetworkName;
	private String mCellName;
	private long mCellId;
	private long mCountryCode;
	private long mAreaCode;
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.CELL_INFO;
	}

	public String getNetworkId(){
		return mNetworkId;
	}

	/**
	 * mNetworkId = id
	 * 
	 * @param id    id
	 */
	public void setNetworkId(String id){
		mNetworkId = id;
	}

	public String getNetworkName(){
		return mNetworkName;
	}

	/**
	 * mNetworkName = name
	 * 
	 * @param name    name
	 */
	public void setNetworkName(String name){
		mNetworkName = name;
	}

	public String getCellName(){
		return mCellName;
	}

	/**
	 * mCellName = name
	 * 
	 * @param name    name
	 */
	public void setCellName(String name){
		mCellName = name;
	}

	public long getCellId(){
		return mCellId;
	}

	/**
	 * 
	 * @param id    id
	 */
	public void setCellId(long id){
		mCellId = id;
	}

	public long getCountryCode(){
		return mCountryCode;
	}

	/**
	 * mCountryCode = code
	 * 
	 * @param code    code
	 */
	public void setCountryCode(long code){
		mCountryCode= code;
	}

	public long getAreaCode(){
		return mAreaCode;
	}

	/**
	 * mAreaCode = code
	 * 
	 * @param code    code
	 */
	public void setAreaCode(long code){
		mAreaCode = code;
	}

}