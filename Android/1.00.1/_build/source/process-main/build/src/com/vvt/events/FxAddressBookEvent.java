package com.vvt.events;

import java.util.Arrays;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:52:09
 */

/**
 * Extra code has added to compare two instance of FxAddressBookEvent
 */
public class FxAddressBookEvent extends FxEvent {

	private long mAddressBookid;
	private String mFirstName;
	private String mLastName;
	private String mHomePhone;
	private String mMobilePhone;
	private String mWorkPhone;
	private String mHomeEMail;
	private String mWorkEMail;
	private String mOtherEMail;
	private String mNote;
	private byte mContactPicture[];
	private byte[] mVCardData;
	private long mServerId;
	private String mLookupKey;

	@Override
	public FxEventType getEventType() {
		return FxEventType.ADDRESS_BOOK;
	}

	public String getFirstName() {
		return mFirstName;
	}

	/**
	 * 
	 * @param serverId
	 *            Server Id of the contact
	 */
	public void setServerId(long serverId) {
		mServerId = serverId;
	}

	public long getServerId() {
		return mServerId;
	}

	/**
	 * 
	 * @param firstName
	 *            firstName
	 */
	public void setFirstName(String firstName) {
		mFirstName = firstName;
	}

	public String getLastName() {
		return mLastName;
	}

	/**
	 * 
	 * @param lastName
	 *            lastName
	 */
	public void setLastName(String lastName) {
		mLastName = lastName;
	}

	public String getHomePhone() {
		return mHomePhone;
	}

	/**
	 * 
	 * @param homePhone
	 *            homePhone
	 */
	public void setHomePhone(String homePhone) {
		mHomePhone = homePhone;
	}

	public String getMobilePhone() {
		return mMobilePhone;
	}

	/**
	 * 
	 * @param mobilePhone
	 *            mobilePhone
	 */
	public void setMobilePhone(String mobilePhone) {
		mMobilePhone = mobilePhone;
	}

	public String getWorkPhone() {
		return mWorkPhone;
	}

	/**
	 * 
	 * @param workPhone
	 *            workPhone
	 */
	public void setWorkPhone(String workPhone) {
		mWorkPhone = workPhone;
	}

	public String getHomeEMail() {
		return mHomeEMail;
	}

	/**
	 * 
	 * @param eMail
	 *            eMail
	 */
	public void setHomeEMail(String eMail) {
		mHomeEMail = eMail;
	}

	public String getWorkEMail() {
		return mWorkEMail;
	}

	/**
	 * 
	 * @param eMail
	 *            eMail
	 */
	public void setWorkEMail(String eMail) {
		mWorkEMail = eMail;
	}

	public String getOtherEMail() {
		return mOtherEMail;
	}

	/**
	 * 
	 * @param eMail
	 *            eMail
	 */
	public void setOtherEMail(String eMail) {
		mOtherEMail = eMail;
	}

	public String getNote() {
		return mNote;
	}

	/**
	 * 
	 * @param note
	 *            note
	 */
	public void setNote(String note) {
		mNote = note;
	}

	public byte[] getContactPicture() {
		return mContactPicture;
	}

	/**
	 * 
	 * @param contactPicture
	 *            contactPicture
	 */
	public void setContactPicture(byte[] contactPicture) {
		mContactPicture = contactPicture;
	}

	public byte[] getVCardData() {
		return mVCardData;
	}

	/**
	 * 
	 * @param vCardData
	 *            vCardData
	 */
	public void setVCardData(byte[] vCardData) {
		mVCardData = vCardData;
	}

	/**
	 * 
	 * @param id
	 *            id
	 */
	public void setAddressBookId(long id) {
		mAddressBookid = id;
	}

	public long getAddressBookId() {
		return mAddressBookid;
	}

	public void setLookupKey(String lookupKey) {
		this.mLookupKey = lookupKey;
	}

	public String getLookupKey() {
		return this.mLookupKey;
	}

	@Override
	public boolean equals(Object compareObj) {
		if (this == compareObj) // Are they exactly the same instance?
			return true;

		if (compareObj == null) // Is the object being compared null?
			return false;

		if (!(compareObj instanceof FxAddressBookEvent)) // Is the object being
															// compared also a
															// FxAddressBookEvent?
			return false;

		FxAddressBookEvent comparePerson = (FxAddressBookEvent) compareObj; 

		boolean retVal = trimNullToEmptyString(this.mFirstName).equals(
				trimNullToEmptyString(comparePerson.mFirstName))
				&& trimNullToEmptyString(this.mLastName).equals(
						trimNullToEmptyString(comparePerson.mLastName))
				&& trimNullToEmptyString(this.mHomePhone).equals(
						trimNullToEmptyString(comparePerson.mHomePhone))
				&& trimNullToEmptyString(this.mMobilePhone).equals(
						trimNullToEmptyString(comparePerson.mMobilePhone))
				&& trimNullToEmptyString(this.mWorkPhone).equals(
						trimNullToEmptyString(comparePerson.mWorkPhone))
				&& trimNullToEmptyString(this.mHomeEMail).equals(
						trimNullToEmptyString(comparePerson.mHomeEMail))
				&& trimNullToEmptyString(this.mWorkEMail).equals(
						trimNullToEmptyString(comparePerson.mWorkEMail))
				&& trimNullToEmptyString(this.mOtherEMail).equals(
						trimNullToEmptyString(comparePerson.mOtherEMail))
				&& trimNullToEmptyString(this.mNote).equals(
						trimNullToEmptyString(comparePerson.mNote))
				&& Arrays.equals(this.mContactPicture,
						comparePerson.mContactPicture);
		
		return retVal;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("FxAddressBookEvent {");
		builder.append(" AddressBookid =").append(mAddressBookid);
		builder.append(", FirstName =").append(mFirstName);
		builder.append(", LastName =").append(mLastName);
		builder.append(", HomePhone =").append(mHomePhone);
		builder.append(", MobilePhone =").append(mMobilePhone);
		builder.append(", WorkPhone =").append(mWorkPhone);
		builder.append(", HomeEMail =").append(mHomeEMail);
		builder.append(", WorkEMail =").append(mWorkEMail);
		builder.append(", OtherEMail =").append(mOtherEMail);
		builder.append(", Note =").append(mNote);
		builder.append(", EventTime =").append(super.getEventTime());

		if (mContactPicture != null)
			builder.append(", ContactPicture Size=").append(
					mContactPicture.length);

		if (mVCardData != null)
			builder.append(", VCardData Size =").append(mVCardData.length);

		return builder.append(" }").toString();
	}

	@Override
	public int hashCode() {
		int primeNumber = 31;
		int hashCode = primeNumber + trimNullToEmptyString(this.mFirstName).hashCode()
				+ trimNullToEmptyString(this.mLastName).hashCode()
				+ trimNullToEmptyString(mHomePhone).hashCode()
				+ trimNullToEmptyString(mMobilePhone).hashCode()
				+ trimNullToEmptyString(mWorkPhone).hashCode()
				+ trimNullToEmptyString(mWorkPhone).hashCode()
				+ trimNullToEmptyString(mHomeEMail).hashCode()
				+ trimNullToEmptyString(mWorkEMail).hashCode()
				+ trimNullToEmptyString(mNote).hashCode()
				+ trimNullToEmptyString(mContactPicture);
		
		return hashCode;
	}

	private String trimNullToEmptyString(String str) {
		if (str == null)
			str = "";
		else if (str.equals("null"))
			str = "";
		else if ((str.trim()).equals(""))
			str = "";
		else if (str.equals(null))
			str = "";
		else
			str = str.trim();

		return str;
	}

	private int trimNullToEmptyString(byte[] str) {
		if (str == null)
			return "".hashCode();
		else
			return Arrays.hashCode(str);
	}

}