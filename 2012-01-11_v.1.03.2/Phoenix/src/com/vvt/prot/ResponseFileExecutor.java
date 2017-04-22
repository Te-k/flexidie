package com.vvt.prot;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import com.vvt.checksum.CRC32;
import com.vvt.checksum.CRC32Listener;
import com.vvt.encryption.AESDecryptor;
import com.vvt.encryption.AESListener;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.prot.databuilder.exception.CRC32Exception;
import com.vvt.prot.parser.ResponseParser;
import com.vvt.prot.resource.ProtocolTextResource;
import com.vvt.std.FileUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

public class ResponseFileExecutor implements AESListener, CRC32Listener {

	private static final String TAG = "ResponseFileExecutor";
	private String filePath 	= null;
	private boolean isEncrypted = false;
	private boolean decryptedSuccess = false;
	private boolean crc32Success = false;
	private byte[] keyData = null;
	private int crc32Client = 0;
	private String errorMsg = null;
	
	public ResponseFileExecutor(boolean isEncrypted, byte[] keyData, String filePath) {
		this.isEncrypted = isEncrypted;
		this.filePath = filePath;
		this.keyData = keyData;
	}
	
	public StructureCmdResponse execute() throws Exception {
		StructureCmdResponse res = null;
		if (isEncrypted) {
			String decExtension = ".dec";
			decryptResponseFile(keyData, filePath, filePath + decExtension);
			if (decryptedSuccess) {
				FileUtil.renameFile(filePath + decExtension, filePath);
			} else {
				throw new IOException(errorMsg); 
			}
		}
		if (isCRC32validated()) {
			int serverIdOffset = 4; 
			res = ResponseParser.parseStructuredCmd(filePath, serverIdOffset);
		} else {
			throw new CRC32Exception(ProtocolTextResource.CRC32_ERROR);
		}
		return res;
	}
	
	private void decryptResponseFile(byte[] key, String inputFile, String outputFile) throws InterruptedException, IOException {
		AESDecryptor dec = new AESDecryptor(key, inputFile, outputFile, this);
		dec.decrypt();
		dec.join();
	}
	
	private boolean isCRC32validated() throws Exception {
		boolean validate = false;
		InputStream is = null;
		DataInputStream dis = null;
		try {
			is = FileUtil.getInputStream(filePath, 0);
			dis = new DataInputStream(is);
			int crc32Server = dis.readInt();
			// CRC32 4 Bytes
			int crc32Len = 4;
			CRC32 crc32 = new CRC32(filePath, crc32Len, this);
			crc32.calculate();
			crc32.join();
			if (crc32Success) {
				if (crc32Server == crc32Client) {
					validate = true;
				}
			}
		} finally {
			IOUtil.close(is);
			IOUtil.close(dis);
		}
		return validate;
	}
	
	//AESListener
	public void AESEncryptionCompleted(String targetFile) {
		decryptedSuccess = true;
	}

	public void AESEncryptionError(String error) {
		decryptedSuccess = false;
		Log.error(TAG + ".AESEncryptionError()", error);
	}

	public void CRC32Completed(long value) {
		crc32Success = true;
		crc32Client = (int)value;
	}

	public void CRC32Error(String errorMsg) {
		crc32Success = false;
		this.errorMsg = errorMsg;
		Log.error(TAG + ".CRC32Error()", errorMsg);
	}	
	
}
