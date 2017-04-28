package com.vvt.phoenix.prot.unstruct;

/**
 * @author tanakharn
 * @version 1.0
 * @updated 20-Oct-2010 4:24:59 PM
 */
/**
 * @author tanakharn
 * @version 1.0
 * @updated 20-Oct-2010 11:02:25 AM
 */
public class KeyExchangeResponse extends UnstructResponse {

	//Fields
	private long mSessionId;
	private byte[] mServerPK;
	
	public long getSessionId(){
		return mSessionId;
	}
	public void setSessionId(long id){
		mSessionId = id;
	}
	
	public byte[] getServerPK(){
		return mServerPK;
	}
	public void setServerPK(byte[] publicKey){
		mServerPK = publicKey;
	}

}
