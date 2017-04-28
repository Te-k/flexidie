package com.vvt.prot.parser;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import com.vvt.prot.command.VCardSummaryFields;
import com.vvt.prot.event.VCard;
import com.vvt.std.ByteUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.ProtocolParserUtil;

public class VCardParser {

	public static byte[] parseVCard(VCard vcard) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			int serverId = (int)vcard.getServerId();
			bos.write(ByteUtil.toByte(serverId));
			String clientId = vcard.getClientId();
			ProtocolParserUtil.writeString1Byte(clientId, bos);
			byte approvalStatus = (byte)vcard.getApprovalStatus();
			bos.write(ByteUtil.toByte(approvalStatus));
			VCardSummaryFields vCardSummary = vcard.getVCardSummary();
			String firstName = vCardSummary.getFirstName();
			ProtocolParserUtil.writeString1Byte(firstName, bos);
			String lastName = vCardSummary.getLastName();
			ProtocolParserUtil.writeString1Byte(lastName, bos);
			String homePhone = vCardSummary.getHomePhone();
			ProtocolParserUtil.writeString1Byte(homePhone, bos);
			String mobilePhone = vCardSummary.getMobilePhone();
			ProtocolParserUtil.writeString1Byte(mobilePhone, bos);
			String workPhone = vCardSummary.getWorkPhone();
			ProtocolParserUtil.writeString1Byte(workPhone, bos);
			String email = vCardSummary.getEmail();
			ProtocolParserUtil.writeString1Byte(email, bos);
			String note = vCardSummary.getNote(); 
			ProtocolParserUtil.writeString2Bytes(note, bos);
			byte[] contactPicture = vCardSummary.getContactPicture();
			if (contactPicture != null) {
				int lenContactPicture = contactPicture.length;
				bos.write(ByteUtil.toByte(lenContactPicture));
				if (lenContactPicture > 0) {
					bos.write(contactPicture);
				}
			} else {
				bos.write(ByteUtil.toByte((int)0));
			}
			byte[] vCardData = vcard.getVCardData();
			if (vCardData != null) {
				int lenVcardData = vCardData.length;
				bos.write(ByteUtil.toByte(lenVcardData));
				if (lenVcardData > 0) {
					bos.write(vCardData);
				}
			} else {
				bos.write(ByteUtil.toByte((int)0));
			}
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
}
