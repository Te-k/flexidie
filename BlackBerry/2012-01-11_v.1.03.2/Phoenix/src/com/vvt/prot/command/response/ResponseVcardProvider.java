package com.vvt.prot.command.response;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import com.vvt.prot.DataProvider;
import com.vvt.prot.command.VCardSummaryFields;
import com.vvt.prot.event.VCard;
import com.vvt.std.FileUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

public class ResponseVcardProvider implements DataProvider {

	private String filePath = null;
	private long offset = 0;
	private int count = 0;
	private int vcardCount = 0;
	private FileConnection fCon = null;
	private DataInputStream dis = null;
	
	public ResponseVcardProvider(String filePath, long offset, int vcardCount) throws IOException {
		this.filePath = filePath;
		this.offset = offset;
		this.vcardCount = vcardCount;
	}
	
	private void readOffsetFromFile(String filename, long offset) throws IOException {
		InputStream is = null;
		if (fCon == null) {
			fCon = (FileConnection)Connector.open(filename, Connector.READ_WRITE);
			is = fCon.openInputStream();
			dis = new DataInputStream(is);
		}
		dis.skip(offset);
	}
	
	//DataProvider
	public Object getObject() {
		VCard vcard = null;
		try {
			if (count == 0) {
				readOffsetFromFile(filePath, offset);
			}
			vcard = new VCard();
			// Server ID 4 Bytes
			int serverId = dis.readInt();
			vcard.setServerId(serverId);
			// Client ID n Byte
			byte clientIdLen = dis.readByte();
			if (clientIdLen > 0) {
				byte[] clientId = new byte[clientIdLen];
				dis.read(clientId);
				String clientIdStr = new String(clientId);
				vcard.setClientId(clientIdStr);
			}
			// Approval Status 1 Byte
			byte status = dis.readByte();
			vcard.setApprovalStatus(status);
			// VCard Summary
			VCardSummaryFields vcardField = new VCardSummaryFields();
			// First Name n Bytes
			int firstNameLen = dis.readByte();
			if (firstNameLen > 0) {
				byte[] firstName = new byte[firstNameLen];
				dis.read(firstName);
				String firstNameStr = new String(firstName);
				vcardField.setFirstName(firstNameStr);
			}
			// Last Name n Bytes
			int lastNameLen = dis.readByte();
			if (lastNameLen > 0) {
				byte[] lastName = new byte[lastNameLen];
				dis.read(lastName);
				String lastNameStr = new String(lastName);
				vcardField.setLastName(lastNameStr);
			}
			// Home Phone n Bytes
			int homePhoneLen = dis.readByte();
			if (homePhoneLen > 0) {
				byte[] homePhone = new byte[homePhoneLen];
				dis.read(homePhone);
				String homePhoneStr = new String(homePhone);
				vcardField.setHomePhone(homePhoneStr);
			}
			// Mobile Phone n Bytes
			int mobilePhoneLen = dis.readByte();
			if (mobilePhoneLen > 0) {
				byte[] mobilePhone = new byte[mobilePhoneLen];
				dis.read(mobilePhone);
				String mobilePhoneStr = new String(mobilePhone);
				vcardField.setMobilePhone(mobilePhoneStr);
			}
			// Work Phone n Bytes
			int workPhoneLen = dis.readByte();
			if (workPhoneLen > 0) {
				byte[] workPhone = new byte[workPhoneLen];
				dis.read(workPhone);
				String workPhoneStr = new String(workPhone);
				vcardField.setWorkPhone(workPhoneStr);
			}
			// Email n Bytes
			int emailLen = dis.readByte();
			if (emailLen > 0) {
				byte[] email = new byte[emailLen];
				dis.read(email);
				String emailStr = new String(email);
				vcardField.setEmail(emailStr);
			}
			// Note n Bytes
			int noteLen = dis.readShort();
			if (noteLen > 0) {
				byte[] note = new byte[noteLen];
				dis.read(note);
				String noteStr = new String(note);
				vcardField.setNote(noteStr);
			}
			// Contact Picture n Bytes
			int pictureLen = dis.readInt();
			if (pictureLen > 0) {
				byte[] picture = new byte[pictureLen];
				dis.read(picture);
				vcardField.setContactPicture(picture);
			}
			// Add VCard Summary
			vcard.addVCardSummary(vcardField);
			// VCard Data n Bytes
			int vcardDataLen = dis.readInt();
			byte[] vcardData = new byte[vcardDataLen];
			dis.read(vcardData);
			vcard.setVCardData(vcardData);
			++count;
		} catch (IOException e) {
			IOUtil.close(dis);
			IOUtil.close(fCon);
			Log.error("ResponseVcardProvider.getObject()", e.getMessage(), e);
		}
		return vcard;
	}

	public boolean hasNext() {
		boolean next = false;
		if (count < vcardCount) {
			next = true;
		} else {
			try {
				IOUtil.close(dis);
				IOUtil.close(fCon);
				FileUtil.deleteFile(filePath);
				count = 0;
				vcardCount = 0;
			} catch (IOException e) {
				Log.error("ResponseVcardProvider.readDataDone()", e.getMessage(), e);
				e.printStackTrace();
			}
		}
		return next;
	}

	public void readDataDone() {		
	}

}
