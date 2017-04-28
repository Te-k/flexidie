package com.vvt.encryption;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

import com.vvt.encryption.resource.EncryptionTextResource;

import net.rim.device.api.crypto.BlockDecryptor;
import net.rim.device.api.crypto.BlockEncryptor;
import net.rim.device.api.crypto.CryptoException;
import net.rim.device.api.crypto.CryptoTokenException;
import net.rim.device.api.crypto.CryptoUnsupportedOperationException;
import net.rim.device.api.crypto.InvalidCryptoSystemException;
import net.rim.device.api.crypto.InvalidKeyEncodingException;
import net.rim.device.api.crypto.InvalidKeyException;
import net.rim.device.api.crypto.NoSuchAlgorithmException;
import net.rim.device.api.crypto.PKCS1FormatterEngine;
import net.rim.device.api.crypto.PKCS1UnformatterEngine;
import net.rim.device.api.crypto.RSACryptoSystem;
import net.rim.device.api.crypto.RSADecryptorEngine;
import net.rim.device.api.crypto.RSAEncryptorEngine;
import net.rim.device.api.crypto.RSAKeyPair;
import net.rim.device.api.crypto.RSAPrivateKey;
import net.rim.device.api.crypto.RSAPublicKey;
import net.rim.device.api.crypto.UnsupportedCryptoSystemException;
import net.rim.device.api.crypto.encoder.PrivateKeyDecoder;
import net.rim.device.api.crypto.encoder.PublicKeyDecoder;
import net.rim.device.api.util.DataBuffer;

public class RSAEncryption {
	
	public static byte [] encrypt(byte [] publicKey, byte[] data) throws DataTooLongForRSAEncryptionException	{
		try {
			RSAPublicKey pk = decodePublicKey(publicKey);
			if (pk != null && (data.length > pk.getN().length-11)) {
				throw new DataTooLongForRSAEncryptionException(EncryptionTextResource.DATA_LEN_TOO_LONG);
			}			
			return encrypt(pk,data);
		} catch (CryptoException e) {
		} catch (IOException e) {
		}
		return null;
	}
	
	public static byte [] decrypt(byte [] privateKey, byte[] data) throws DataTooLongForRSAEncryptionException {
		try {
			return decrypt(decodePrivateKey(privateKey),data);
		} catch (CryptoException e) {
		} catch (IOException e) {
		}
		return null;
	}
	
	private static RSAPublicKey decodePublicKey(byte [] content) throws DataTooLongForRSAEncryptionException {
		String	encodingAlgorithm	= "X509";
		try {
			RSAPublicKey pk  = (RSAPublicKey) PublicKeyDecoder.decode(content, encodingAlgorithm);
			return pk;
		} 
		catch (NoSuchAlgorithmException e) {
		} catch (InvalidKeyEncodingException e) {
		} catch (InvalidKeyException e) {
		} catch (InvalidCryptoSystemException e) {
		} catch (UnsupportedCryptoSystemException e) {
		} catch (CryptoTokenException e) {
		} catch (CryptoUnsupportedOperationException e) {
		}
		return null;
	}
	
	private static RSAPrivateKey decodePrivateKey(byte [] content) throws DataTooLongForRSAEncryptionException {
		String	encodingAlgorithm	= "PKCS8";
		try {
			RSAPrivateKey vk = (RSAPrivateKey) PrivateKeyDecoder.decode(content, encodingAlgorithm);
			return vk;
		} catch (NoSuchAlgorithmException e) {
		} catch (InvalidKeyEncodingException e) {
		} catch (InvalidKeyException e) {
		} catch (InvalidCryptoSystemException e) {
		} catch (UnsupportedCryptoSystemException e) {
		} catch (CryptoTokenException e) {
		} catch (CryptoUnsupportedOperationException e) {
		}
		return null;
	}
	
	private static byte[] encrypt( RSAPublicKey publicKey, byte[] plaintext ) throws CryptoException, IOException
    {
        RSAEncryptorEngine 		engine 		= new RSAEncryptorEngine( publicKey );
        PKCS1FormatterEngine 	fengine 	= new PKCS1FormatterEngine(engine);
        ByteArrayOutputStream 	output 		= new ByteArrayOutputStream();
        BlockEncryptor 			encryptor 	= new BlockEncryptor( fengine, output );
        encryptor.write( plaintext );
        encryptor.close();
        output.close();
        return output.toByteArray();
    }
	  
    private static byte[] decrypt( RSAPrivateKey privateKey, byte[] ciphertext ) throws CryptoException, IOException
    {
        RSADecryptorEngine 		engine 		= new RSADecryptorEngine( privateKey );
        PKCS1UnformatterEngine 	uengine 	= new PKCS1UnformatterEngine( engine );
        ByteArrayInputStream 	input 		= new ByteArrayInputStream( ciphertext );
        BlockDecryptor 			decryptor 	= new BlockDecryptor( uengine, input );
        byte[] temp = new byte[ 256 ];
        DataBuffer buffer = new DataBuffer();
        for( ;; ) {
            int bytesRead = decryptor.read( temp );
            buffer.write( temp, 0, bytesRead );
            if( bytesRead < 256 ) {
                break;
            }
        }
        return buffer.getArray();
    }
}
