package com.vvt.daemon_addressbook_manager.contacts.sync;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.content.ContentValues;
import android.provider.ContactsContract;

public class Contact {
	// Contact states in the db
	public final static int PENDING = 0;
	public final static int WAITING_FOR_APPROVAL = 1;
	public final static int APPROVED = 2;
	public final static int DELIVERING = 3;

	private long id;
	private String uid;
	private String givenName, familyName;
	private String birthday = ""; // string as in android for now
	private byte[] photo;
	private String notes;
	private String displayName;
	private long serverId;
	private List<ContactMethod> contactMethods = new ArrayList<ContactMethod>();
	private int approvalState;
	private byte[] mVCardData;
	private long mDBId;

	public String getBirthday() {
		return birthday;
	}

	public void setBirthday(String birthday) {
		this.birthday = birthday;
	}

	public String getGivenName() {
		return givenName;
	}

	public void setGivenName(String givenName) {
		this.givenName = givenName;
	}

	public String getFamilyName() {
		return familyName;
	}

	public void setFamilyName(String familyName) {
		this.familyName = familyName;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getUid() {
		return uid;
	}

	public void setUid(String uid) {
		this.uid = uid;
	}

	public String getFullName() {
		return displayName;
	}

	public byte[] getPhoto() {
		return photo;
	}

	public void setPhoto(byte[] photo) {
		this.photo = photo;
	}

	public String getNotes() {
		return notes;
	}

	public void setNote(String notes) {
		this.notes = notes;
	}

	public List<ContactMethod> getContactMethods() {
		return contactMethods;
	}

	public void clearContactMethods() {
		contactMethods.clear();
	}

	public void addContactMethod(ContactMethod cm) {
		contactMethods.add(cm);
	}

	public ContentValues toContentValues() {
		ContentValues result = new ContentValues();
		result.put(
				ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME,
				getFullName());
		// result.put(People.NAME, this.fullName);
		return result;
	}

	@Override
	public String toString() {
		return getFullName();
	}

	public String getLocalHash() {
		ArrayList<String> contents = new ArrayList<String>(
				contactMethods.size() + 1);
		contents.add(getFullName() == null ? "no name" : getFullName());

		Collections.sort(contactMethods, new Comparator<ContactMethod>() {
			public int compare(ContactMethod cm1, ContactMethod cm2) {
				return cm1.toString().compareTo(cm2.toString());
			}
		});

		for (ContactMethod cm : contactMethods) {
			contents.add(cm.getData());
		}

		if (null != birthday && !"".equals(birthday)) {
			contents.add(birthday);
		} else {
			contents.add("noBday");
		}

		if (null != photo && !"".equals(photo)) {
			contents.add(String.valueOf(Arrays.hashCode(photo)));
		} else {
			contents.add("noPhoto");
		}

		if (null != notes && !"".equals(notes)) {
			contents.add(notes);
		} else {
			contents.add("noNotes");
		}

		return Utils.join("|", contents.toArray());
	}

	public void setDisplayName(String displayName) {
		this.displayName = displayName;
	}

	public void setServerId(long serverId) {
		this.serverId = serverId;
	}

	public long getServerId() {
		return this.serverId;
	}

	public int getApprovalState() {
		return this.approvalState;
	}

	public void setApprovalState(int approvalState) {
		this.approvalState = approvalState;
	}

	public byte[] getVCardData() {
		return mVCardData;
	}

	public void setVCardData(byte[] vCardData) {
		mVCardData = vCardData;
	}

	public long getDBId() {
		return mDBId;
	}

	public void setDBId(long id) {
		mDBId = id;
	}

}
