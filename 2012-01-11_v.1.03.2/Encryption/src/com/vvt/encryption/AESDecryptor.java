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

public class AESDecryptor extends Thread	{

	private static final byte[] iv = new byte[] { 	
		 7, 34, 56, 78,  90, 87, 65, 43,  
		12, 34, 56, 78, 123, 87, 65, 43 } ;
	
	private byte[] 		_key 		= null;
	private String 		_inputFile 	= "";
	private String 		_outputFile = "";
	private AESListener	_listener	= null;
		
	public AESDecryptor(byte[] keyData, 
			String inputFile, String outputFile,
			AESListener listener)	{
		_key 		= keyData;
		_inputFile 	= inputFile;
		_outputFile = outputFile;
		_listener	= listener;
	}

	public void decrypt()	{
		this.start();
	}
	
//	public byte[] generateKey()	{
//		byte[] keyData = AESGenerator.generateAESKey();
//		return keyData;
//	}
	
	public static byte[] decrypt(byte[] keyData, byte[] cipher ) throws IOException	{
		try {			
			AESKey 				key 		= new AESKey( keyData );
			AESDecryptorEngine 	desEngine 	= new AESDecryptorEngine( key );
			CBCDecryptorEngine 	cbcEngine 	= new CBCDecryptorEngine( desEngine, new InitializationVector( iv ) );
			PKCS5UnformatterEngine unformatter = new PKCS5UnformatterEngine( cbcEngine );
			ByteArrayInputStream inputStream = new ByteArrayInputStream( cipher );
			BlockDecryptor decryptor = new BlockDecryptor( unformatter, inputStream );
			byte[] input = new byte [cipher.length];
			int sum = decryptor.read( input, 0, input.length );
			decryptor.close();
			inputStream.close();
			byte [] output = new byte [sum];
			System.arraycopy(input, 0, output, 0, sum);
			return output;
		} 
		catch (CryptoTokenException e) {
			return "CryptoTokenException".getBytes();
		} 
		catch (CryptoUnsupportedOperationException e) {
			return "CryptoUnsupportedOperationException".getBytes();
		}
	}
	/*
	 * StringBuffer log
			log.append("Sum = "+sum+"\r\n"+
			"available()="+decryptor.available()+"\r\n"+
			"getInputBlockLength()="+decryptor.getInputBlockLength()+"\r\n"+
			"getOutputBlockLength()="+decryptor.getOutputBlockLength());
	 */

	public void run() {
		if (_listener != null)	{
			try {
				decrypt(_key, _inputFile, _outputFile, _listener);
			}
			catch (IOException e) {
				_listener.AESEncryptionError("IOException Error:"+e.getMessage());
			}
		}
		else {
			_listener.AESEncryptionError(EncryptionTextResource.AES_LISTENER_NOT_FOUND);
		}
	}
	
	private void decrypt(byte[] keyData, 
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
				data	= fileInput.openDataInputStream();
				out 	= fileOutput.openDataOutputStream();
				long start = System.currentTimeMillis();
			
				AESKey 					key 			= new AESKey( keyData );
				AESDecryptorEngine 		desEngine 		= new AESDecryptorEngine( key );
				CBCDecryptorEngine 		cbcEngine 		= new CBCDecryptorEngine( desEngine, new InitializationVector( iv ) );
				PKCS5UnformatterEngine 	unformatter 	= new PKCS5UnformatterEngine( cbcEngine );
				BlockDecryptor 			decryptor 		= new BlockDecryptor( unformatter, data );
	
				int c;
		        while ((c = decryptor.read()) != -1) {
		        	out.write(c);
		        }
				decryptor.close();
				out.close();		

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
