package throwaway;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;

import com.vvt.encryption.AESKeyGenerator;
import com.vvt.encryption.AESListener;

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

public class AESEngine implements Runnable	{

	private byte[] iv 		= new byte[] { 	7, 34, 56, 78, 
											90, 87, 65, 43,  
											12, 34, 56, 78, 
											123, 87, 65, 43 } ;
	
	public AESEngine()	{
	}
		
	public byte[] generateKey()	{
		byte[] keyData = AESKeyGenerator.generateAESKey();
		return keyData;
	}
	
	public byte[] encrypt(byte[] keyData, byte[] input) throws IOException	{
		try {
			AESKey 				key 		= new AESKey( keyData );
			AESEncryptorEngine 	desEngine 	= new AESEncryptorEngine( key );
			CBCEncryptorEngine 	cbcEngine 	= new CBCEncryptorEngine( desEngine, new InitializationVector( iv ) );
			PKCS5FormatterEngine formatter = new PKCS5FormatterEngine( cbcEngine );
			
			// Create a stream from the input byte array.
			ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
			
			// Now we create the Encryptor using the CBCEncryptorEngine.
			BlockEncryptor encryptor = new BlockEncryptor( formatter, outputStream );
			
			// Finally, we can write the data to encrypt.
			encryptor.write( input, 0, input.length );
			
			// We want to close the output stream and grab the bytes.
			// NOTE: It is especially important to call close with padding
			// encoders, as it ensures that the last block is encoded properly.
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
	
	public byte[] decrypt(byte[] keyData, byte[] cipher) throws IOException	{
		try {			
			AESKey 				key 		= new AESKey( keyData );
			AESDecryptorEngine 	desEngine 	= new AESDecryptorEngine( key );
			CBCDecryptorEngine 	cbcEngine 	= new CBCDecryptorEngine( desEngine, new InitializationVector( iv ) );
			PKCS5UnformatterEngine unformatter = new PKCS5UnformatterEngine( cbcEngine );
			
			// Create a stream from the input byte array.
			ByteArrayInputStream inputStream = new ByteArrayInputStream( cipher );
			
			// Now we create the Decryptor using the CBCDecryptorEngine.
			BlockDecryptor decryptor = new BlockDecryptor( unformatter, inputStream );

			//Input
			byte[] input = new byte [cipher.length];
			
			// Finally, we can read in the decrypted data.
			decryptor.read( input, 0, input.length );
			
			// Close the decryptor and the input stream.
			decryptor.close();
			inputStream.close();
			
			return input;
		} 
		catch (CryptoTokenException e) {
			return "CryptoTokenException".getBytes();
		} 
		catch (CryptoUnsupportedOperationException e) {
			return "CryptoUnsupportedOperationException".getBytes();
		}
	}

	public void run() {
		
	}
	
	public void encrypt(byte[] keyData, 
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

				long stop = System.currentTimeMillis();
				listener.AESEncryptionCompleted(outputFile+" in "+(stop-start)+" ms.");
			}
			else {
				listener.AESEncryptionError("No source file : "+inputFile);
			}
		} 
		catch (CryptoTokenException e) {
			listener.AESEncryptionError("CryptoTokenException:"+e.getMessage());
		} 
		catch (CryptoUnsupportedOperationException e) {
			listener.AESEncryptionError("CryptoUnsupportedOperationException:"+e.getMessage());
		}
	}
	
	public void decrypt(byte[] keyData, 
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
				listener.AESEncryptionError("No source file : "+inputFile);
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
