package throwaway;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

import net.rim.device.api.crypto.BlockDecryptor;
import net.rim.device.api.crypto.BlockEncryptor;
import net.rim.device.api.crypto.CryptoException;
import net.rim.device.api.crypto.OAEPFormatterEngine;
import net.rim.device.api.crypto.OAEPUnformatterEngine;
import net.rim.device.api.crypto.PKCS1SignatureSigner;
import net.rim.device.api.crypto.PKCS1SignatureVerifier;
import net.rim.device.api.crypto.RSACryptoSystem;
import net.rim.device.api.crypto.RSADecryptorEngine;
import net.rim.device.api.crypto.RSAEncryptorEngine;
import net.rim.device.api.crypto.RSAKeyPair;
import net.rim.device.api.crypto.RSAPrivateKey;
import net.rim.device.api.crypto.RSAPublicKey;
import net.rim.device.api.util.DataBuffer;

public class RSASecurity {


	private	long	testSize	= 50;
	
	public RSASecurity()	{
		
	}
	
	
	public void runBatch()	{
        try {
        	
            String message = "Welcome to the Advanced Tutorial for the Crypto API";
            byte[] data = message.getBytes();

            // Create the RSAKeyPair that will be used for all of these operations.
            RSAKeyPair senderKeyPair 	= new RSAKeyPair( new RSACryptoSystem( 1024 ));
            RSAKeyPair recipientKeyPair = new RSAKeyPair( new RSACryptoSystem( 1024 ));

            // First, we want to sign the data with the sender's private key.
            byte[] signature = sign( senderKeyPair.getRSAPrivateKey(), data );
           
            // Next, we want to encrypt the data for the recipient.
            byte[] ciphertext = encrypt( recipientKeyPair.getRSAPublicKey(), data );
            
            ///////////////////////////////////////////////////////////////////////////
            /// At this point pretend that the data has been sent to the recipient  ///
            /// and the recipient is going to decrypt and verify the data.          ///
            ///////////////////////////////////////////////////////////////////////////

            // Decrypt the data.
            byte[] plaintext = decrypt( recipientKeyPair.getRSAPrivateKey(), ciphertext );
            
            // Verify that the decrypted data equals the original message.
            String message2 = new String( plaintext );
            if( message.equals( message2 )) {
                // The encryption/decryption operation worked as expected.
            } else {

            }

            // Verify the signature.
            boolean verified = verify( senderKeyPair.getRSAPublicKey(), data, signature );

            if( verified ) {

            } else {
            }
        } 
        catch( CryptoException e ) {
        } 
        catch( IOException e ) {
        }
        catch (Exception e) {
        }
	}
	
	public void run()	{
        try {
        	
            String message = "Welcome to the Advanced Tutorial for the Crypto API";
            byte[] data = message.getBytes();

            // Create the RSAKeyPair that will be used for all of these operations.
            RSAKeyPair senderKeyPair 	= new RSAKeyPair( new RSACryptoSystem( 1024 ));
            RSAKeyPair recipientKeyPair = new RSAKeyPair( new RSACryptoSystem( 1024 ));

            // First, we want to sign the data with the sender's private key.
            byte[] signature = sign( senderKeyPair.getRSAPrivateKey(), data );
            
            // Next, we want to encrypt the data for the recipient.
            byte[] ciphertext = encrypt( recipientKeyPair.getRSAPublicKey(), data );
            
            ///////////////////////////////////////////////////////////////////////////
            /// At this point pretend that the data has been sent to the recipient  ///
            /// and the recipient is going to decrypt and verify the data.          ///
            ///////////////////////////////////////////////////////////////////////////

            // Decrypt the data.
            byte[] plaintext = decrypt( recipientKeyPair.getRSAPrivateKey(), ciphertext );
            
            // Verify that the decrypted data equals the original message.
            String message2 = new String( plaintext );
            if( message.equals( message2 )) {
                // The encryption/decryption operation worked as expected.
            } else {
            }

            // Verify the signature.
            boolean verified = verify( senderKeyPair.getRSAPublicKey(), data, signature );

            if( verified ) {
            } else {
            }
        } 
        catch( CryptoException e ) {
        } 
        catch( IOException e ) {
        }
        catch (Exception e) {
        }
	}
	
    /**
     * Encrypt the plaintext passed into this method using the public key.  The ciphertext should
     * be returned from the method.
     * @param publicKey an RSAPublicKey that should be used for encrypting the data.
     * @param plaintext the data to be encrypted.
     * @return the ciphertext or encrypted data.
     */
    private byte[] encrypt( RSAPublicKey publicKey, byte[] plaintext ) throws CryptoException, IOException
    {
        // Create the encryptor engine.
        RSAEncryptorEngine engine = new RSAEncryptorEngine( publicKey );

        // Use the OAEP padding for the encryption.  Note that this
        // defaults to using SHA1.
        OAEPFormatterEngine fengine = new OAEPFormatterEngine( engine );

        ByteArrayOutputStream output = new ByteArrayOutputStream();
        BlockEncryptor encryptor = new BlockEncryptor( fengine, output );

        // Write out the data.
        encryptor.write( plaintext );
        encryptor.close();
        output.close();

        return output.toByteArray();
    }

    /**
     * Decrypt the ciphertext passed into this method using the public key.  The plaintext should
     * be returned from the method.
     * @param privateKey an RSAPrivateKey that should be used for decrypting the data.
     * @param ciphertext the data to be decrypted.
     * @return the plaintext or decrypted data.
     */
    private  byte[] decrypt( RSAPrivateKey privateKey, byte[] ciphertext ) throws CryptoException, IOException
    {
        // Create the decryptor engine.
        RSADecryptorEngine engine = new RSADecryptorEngine( privateKey );

        // Use the OAEP padding.
        OAEPUnformatterEngine uengine = new OAEPUnformatterEngine( engine );

        ByteArrayInputStream input = new ByteArrayInputStream( ciphertext );
        BlockDecryptor decryptor = new BlockDecryptor( uengine, input );

        // Now, read in the data.  Remember that the last 20 bytes represent the SHA1 hash of the decrypted data.
        byte[] temp = new byte[ 100 ];
        DataBuffer buffer = new DataBuffer();

        for( ;; ) {
            int bytesRead = decryptor.read( temp );
            buffer.write( temp, 0, bytesRead );

            if( bytesRead < 100 ) {
                // We ran out of data.
                break;
            }
        }

        return buffer.getArray();
    }

    /**
     * Use the data and the private key to produce a signature that will provide data integrity
     * and data authentication.
     * @param privateKey the private key to use for signing the data.
     * @param data the data to be signed.
     * @return the signature.
     */
    private static byte[] sign( RSAPrivateKey privateKey, byte[] data ) throws CryptoException
    {
        // Create the PKCS1 signature signer.  This is the standard method used
        // to create a signature with an RSA key.  Note that by default this uses
        // a SHA digest.
        PKCS1SignatureSigner signer = new PKCS1SignatureSigner( privateKey );
        signer.update( data );

        byte[] signature = new byte[ signer.getLength() ];
        signer.sign( signature, 0 );

        return signature;
    }

    /**
     * Use the data and the public key to verifying that the signature is correct.
     * @param publicKey the Public Key to use for verification.
     * @param data the data that the signature was created with.
     * @param signature the signature on the data.
     * @return a boolean indicating whether or not the signature is valid.
     */
    private static boolean verify( RSAPublicKey publicKey, byte[] data, byte[] signature ) throws CryptoException
    {
        PKCS1SignatureVerifier verifier = new PKCS1SignatureVerifier( publicKey, signature, 0 );
        verifier.update( data );
        return verifier.verify();
    }
	
}
