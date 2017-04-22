package com.vvt.daemon_addressbook_manager;

import java.util.ArrayList;
import java.util.List;

public class ApprovedContact {
	private String displayName;
	private List<String> emails;
	private List<String> numbers;
	
	public ApprovedContact() {
		emails = new ArrayList<String>();
		numbers = new ArrayList<String>();
	}
	
	public void setDisplayName(String displayName) {
		this.displayName = displayName;
	}
	
	public String getDisplayName() {
		return this.displayName;
	}
	
	public void addEmail(String email) {
		emails.add(email);
	}
	
	public List<String> getEmails() {
		return emails;
	}
	
	public void addNumber(String number) {
		numbers.add(number);
	}
	
	public List<String> getNumbers() {
		return numbers;
	}
}
