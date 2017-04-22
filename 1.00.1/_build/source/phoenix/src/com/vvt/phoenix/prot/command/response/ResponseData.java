package com.vvt.phoenix.prot.command.response;

import java.util.ArrayList;

public abstract class ResponseData {

	//Members
	private long mCsid;
	//private boolean mIsEncrypt;
	//private long mCrc32;
	private int mServerId;
	private int mStatusCode;
	private String mMessage;
	private int mExtendedStatus;
	//private Pcc mCmdNext;
	private ArrayList<PCC> mPccList;
	
	public abstract int getCmdEcho();
	
	/**
	 * Constructor
	 */
	public ResponseData(){
		mPccList = new ArrayList<PCC>();
	}
	
	public long getCsid(){
		return mCsid;
	}
	public void setCsid(long csid){
		mCsid = csid;
	}
	
	/*public boolean isEncrypt(){
		return mIsEncrypt;
	}
	public void setEncrypt(boolean flag){
		mIsEncrypt = flag;
	}
	
	public long getCrc32(){
		return mCrc32;
	}
	public void setCrc32(long crc){
		mCrc32 = crc;
	}
	*/
	public int getServerId(){
		return mServerId;
	}
	public void setServerId(int id){
		mServerId = id;
	}
	
	public int getStatusCode(){
		return mStatusCode;
	}
	public void setStatusCode(int code){
		mStatusCode = code;
	}

	public String getMessage(){
		return mMessage;
	}
	public void setMessage(String message){
		mMessage = message;
	}
	
	public int getExtendedStatus(){
		return mExtendedStatus;
	}
	public void setExtendedStatus(int status){
		mExtendedStatus = status;
	}
	
	/*public Pcc getCmdNext(){
		return mCmdNext;
	}
	public void setCmdNext(Pcc cmdNext){
		mCmdNext = cmdNext;
	}*/
	
	public int getPccCount(){
		return mPccList.size();
	}
	public PCC getPcc(int index){
		return mPccList.get(index);
	}
	public void addPcc(PCC pcc){
		mPccList.add(pcc);
	}
	
}
