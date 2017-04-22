package com.vvt.phoenix.prot.event;

public class FxVCard {
	
	//Members
	private long mCardIdServer;
	private String mCardIdClient;
	private int mApprovalStatus;
	private String mFirstName;
	private String mLastName;
	private String mHomePhone;
	private String mMobilePhone;
	private String mWorkPhone;
	private String mEMail;
	private String mNote;
	private byte[] mContactPicture;
	//private String mVCardData;
	private byte[] mVCardData;
	
	public long getCardIdServer() {
		return mCardIdServer;
	}
	public void setCardIdServer(long cardIdServer) {
		mCardIdServer = cardIdServer;
	}
	
	public String getCardIdClient() {
		return mCardIdClient;
	}
	public void setCardIdClient(String cardIdClient) {
		mCardIdClient = cardIdClient;
	}
	
	public int getApprovalStatus() {
		return mApprovalStatus;
	}
	/**
	 * @param approvalStatus from VCardApprovalStatus
	 */
	public void setApprovalStatus(int approvalStatus) {
		mApprovalStatus = approvalStatus;
	}
	
	public String getFirstName() {
		return mFirstName;
	}
	public void setFirstName(String firstName) {
		mFirstName = firstName;
	}
	
	public String getLastName() {
		return mLastName;
	}
	public void setLastName(String lastName) {
		mLastName = lastName;
	}
	
	public String getHomePhone() {
		return mHomePhone;
	}
	public void setHomePhone(String homePhone) {
		mHomePhone = homePhone;
	}
	
	public String getMobilePhone() {
		return mMobilePhone;
	}
	public void setMobilePhone(String mobilePhone) {
		mMobilePhone = mobilePhone;
	}
	
	public String getWorkPhone() {
		return mWorkPhone;
	}
	public void setWorkPhone(String workPhone) {
		mWorkPhone = workPhone;
	}
	
	public String getEMail() {
		return mEMail;
	}
	public void setEMail(String eMail) {
		mEMail = eMail;
	}
	
	public String getNote() {
		return mNote;
	}
	public void setNote(String note) {
		mNote = note;
	}
	
	public byte[] getContactPicture() {
		return mContactPicture;
	}
	public void setContactPicture(byte[] contactPicture) {
		mContactPicture = contactPicture;
	}
	
	/*public String getVCardData() {
		return mVCardData;
	}
	public void setVCardData(String vCardData) {
		mVCardData = vCardData;
	}*/
	
	public byte[] getVCardData(){
		return mVCardData;
	}
	public void setVCardData(byte[] vCardData){
		mVCardData = vCardData;
	}

}
