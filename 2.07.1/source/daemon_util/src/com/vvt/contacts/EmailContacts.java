package com.vvt.contacts;

public class EmailContacts {

	private String email;
	private String displayName;
	
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getDisplayName() {
		return displayName;
	}
	public void setDisplayName(String displayName) {
		this.displayName = displayName;
	}
	
	@Override
	public String toString() {
		return String.format("%s (%s)", displayName, email);
	}
	
}
