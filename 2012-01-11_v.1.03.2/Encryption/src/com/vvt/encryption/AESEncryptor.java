package com.vvt.encryption;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;

import com.vvt.encryption.resource.EncryptionTextResource;

import net.rim.device.api.crypto.AESDecryptorEngine;
import net.rim.device.api.crypto.AESEncryptorEngine;
import net.rim.device.api.crypto.AESKey;
import net.rim.device.api.crypto.BlockDecryptor;
import net.rim.device.api.crypto.BlockEncryptor;
import net.rim.device.api.crypto.CBCDecryptorEngine;
import net.rim.device.api.crypto.CBCEncryptorEngine;
import net.rim.device.api.crypto.CryptoTokenException;
import net.rim.device.api.crypto.CryptoUnsupportedOperationException;
import net.rim.device.api.crypto.DESDecryptorEngine;
import net.rim.device.api.crypto.DESEncryptorEngine;
import net.rim.device.api.crypto.DESKey;
import net.rim.device.api.crypto.InitializationVector;
import net.rim.device.api.crypto.PKCS5FormatterEngine;
import net.rim.device.api.crypto.PKCS5UnformatterEngine;

public class AESEncryptor extends Thread	{

	private static final byte[] iv = new byte[] { 	
		 7, 34, 56, 78,  90, 87, 65, 43,  
		12, 34, 56, 78, 123, 87, 65, 43 } ;
	
	private byte[] 		_key 		= null;
	private String 		_inputFile 	= "";
	private String 		_outputFile = "";
	private AESListener	_listener	= null;
	
	public AESEncryptor(byte[] keyData, 
			String inputFile, String outputFile,
			AESListener listener)	{
		_key 		= keyData;
		_inputFile 	= inputFile;
		_outputFile = outputFile;
		_listener	= listener;
	}

	public void encrypt()	{
		this.start();
	}
	
	public byte[] generateKey()	{
		byte[] keyData = AESKeyGenerator.generateAESKey();
		return keyData;
	}
	
	public static byte[] encrypt(byte[] keyData, byte[] input) throws IOException	{
		try {
			AESKey 				key 		= new AESKey( keyData );
			AESEncryptorEngine 	desEngine 	= new AESEncryptorEngine( key );
			CBCEncryptorEngine 	cbcEngine 	= new CBCEncryptorEngine( desEngine, new InitializationVector( iv ) );
			PKCS5FormatterEngine formatter 	= new PKCS5FormatterEngine( cbcEngine );
			ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
			BlockEncryptor encryptor = new BlockEncryptor( formatter, outputStream );
			encryptor.write( input, 0, input.length );
			encryptor.close();
			byte[] output = outputStream.toByteArray();
			
			return output;
		} 
		catch (CryptoTokenException e) {
			return ("CryptoTokenException").getBytes();
		} 
		catch (CryptoUnsupportedOperationException e) {
			return ("CryptoUnsupportedOperationException").getBytes();
		}
	}
	
	public void run() {
		if (_listener != null)	{
			try {
				encrypt(_key, _inputFile, _outputFile, _listener);
			}
			catch (IOException e) {
				_listener.AESEncryptionError("IOException Error:"+e.getMessage());
			}
		}
		else {
			_listener.AESEncryptionError(EncryptionTextResource.AES_LISTENER_NOT_FOUND);
		}
	}
	
	private void encrypt(byte[] keyData, 
			String inputFile, String outputFile,
			AESListener listener) throws IOException	{
		
		DataInputStream 	data 	= null;
		DataOutputStream 	out 	= null;
	
		try {
			FileConnection fileInput 	= (FileConnection)Connector.open(inputFile,  Connector.READ);
			FileConnection fileOutput 	= (FileConnection)Connector.open(outputFile, Connector.READ_WRITE);

			if (fileInput.exists())	{
				if (! fileOutput.exists())	{
					fileOutput.create();
				}
				long start = System.currentTimeMillis();
				data	= fileInput.openDataInputStream();
				out 	= fileOutput.openDataOutputStream();
				
				AESKey 					key 			= new AESKey( keyData );
				AESEncryptorEngine 		desEngine 		= new AESEncryptorEngine( key );
				CBCEncryptorEngine 		cbcEngine 		= new CBCEncryptorEngine( desEngine, new InitializationVector( iv ) );
				PKCS5FormatterEngine 	formatter 		= new PKCS5FormatterEngine( cbcEngine );
				BlockEncryptor 			encryptor 		= new BlockEncryptor( formatter, out );
				
				int c;
		        while ((c = data.read()) != -1) {
		        	encryptor.write(c);
		        }			
				encryptor.close();
				out.close();
				data.close();

				long stop = System.currentTimeMillis();
				listener.AESEncryptionCompleted(outputFile+" in "+(stop-start)+" ms.");
			}
			else {
				listener.AESEncryptionError(EncryptionTextResource.SOURCE_FILE_NOT_FOUND + inputFile);
			}
		} 
		catch (CryptoTokenException e) {
			listener.AESEncryptionError("CryptoTokenException:"+e.getMessage());
		} 
		catch (CryptoUnsupportedOperationException e) {
			listener.AESEncryptionError("CryptoUnsupportedOperationException:"+e.getMessage());
		}
	}
	
}
