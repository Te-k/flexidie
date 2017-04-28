package com.vvt.prot.command;

public class VCardSummaryFields {
	private String firstName = "";
	private String lastName = "";
	private String homePhone = "";
	private String mobilePhone = "";
	private String workPhone = "";
	private String email = "";
	private String note = "";
	private byte[] contactPicture;
	
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	
	public String getFirstName() {
		return firstName;
	}
	
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	
	public String getLastName() {
		return lastName;
	}
	
	public void setHomePhone(String homePhone) {
		this.homePhone = homePhone;
	}
	
	public String getHomePhone() {
		return homePhone;
	}
	
	public void setMobilePhone(String mobilePhone) {
		this.mobilePhone = mobilePhone;
	}
	
	public String getMobilePhone() {
		return mobilePhone;
	}
	
	public void setWorkPhone(String workPhone) {
		this.workPhone = workPhone;
	}
	
	public String getWorkPhone() {
		return workPhone;
	}
	
	public void setEmail(String email) {
		this.email = email;
	}
	
	public String getEmail() {
		return email;
	}
	
	public void setNote(String note) {
		this.note = note;
	}
	
	public String getNote() {
		return note;
	}
	
	public void setContactPicture(byte[] contactPicture) {
		this.contactPicture = contactPicture;
	}
	
	public byte[] getContactPicture() {
		return contactPicture;
	}
	
}
