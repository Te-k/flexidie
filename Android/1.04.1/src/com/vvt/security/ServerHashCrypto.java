package com.vvt.security;

import java.nio.ByteBuffer;
import java.util.Random;
import java.util.zip.CRC32;

public class ServerHashCrypto {

	/**
	 * 
	 * @param serverHash; 16 bytes server hash
	 * @return shuffle cipher
	 * when encrypt 16 bytes server hash with AES 128 bits
	 * we will get 32 bytes cipher text and then we shuffle it
	 * with fake data to produce 128 bytes result
	 */
	public static byte[] encryptServerHash(byte[] serverHash){
		//1 encrypt 16 bytes server hash to 32 bytes plain text
		byte[] cipher = FxSecurity.encrypt(serverHash, false);
		//System.out.println("cipher len = "+cipher.length);
		if(cipher == null){
			return null;
		}
		//2 build array link
		byte[] arrayLink = buildArrayLink();
		//3 let shuffle
		byte[] result = shuffle(cipher, arrayLink);

		return result;
	}
	
	/**
	 * @param cipher
	 * @return server hash
	 * get 128 bytes shuffle data and extract server hash from it
	 */
	public static byte[] decryptServerHash(byte[] cipherShuffle){
		byte[] arrayLink = buildArrayLink();
		byte[] cipher = extractCipherShuffle(cipherShuffle, arrayLink);
		byte[] plainText = FxSecurity.decrypt(cipher, false);
		
		return plainText;
	}
	
	private static byte[] buildArrayLink(){

		byte[] arrayLink = new byte[48];
		arrayLink[0] = 2;
		arrayLink[1] = 0;
		arrayLink[2] = 1;
		arrayLink[3] = 3;
		arrayLink[4] = 3;
		arrayLink[5] = 2;
		arrayLink[6] = 1;
		arrayLink[7] = 1;
		arrayLink[8] = 0;
		arrayLink[9] = 1;
		arrayLink[10] = 2;
		arrayLink[11] = 3;
		arrayLink[12] = 1;
		arrayLink[13] = 3;
		arrayLink[14] = 1;
		arrayLink[15] = 2;
		arrayLink[16] = 0;
		arrayLink[17] = 1;
		arrayLink[18] = 1;
		arrayLink[19] = 3;
		arrayLink[20] = 2;
		arrayLink[21] = 1;
		arrayLink[22] = 3;
		arrayLink[23] = 1;
		arrayLink[24] = 0;
		arrayLink[25] = 2;
		arrayLink[26] = 2;
		arrayLink[27] = 1;
		arrayLink[28] = 3;
		arrayLink[29] = 2;
		arrayLink[30] = 0;
		arrayLink[31] = 3;
		arrayLink[32] = 0;
		arrayLink[33] = 2;
		arrayLink[34] = 1;
		arrayLink[35] = 3;
		arrayLink[36] = 2;
		arrayLink[37] = 1;
		arrayLink[38] = 3;
		arrayLink[39] = 1;
		arrayLink[40] = 2;
		arrayLink[41] = 3;
		arrayLink[42] = 2;
		arrayLink[43] = 1;
		arrayLink[44] = 3;
		arrayLink[45] = 2;
		arrayLink[46] = 0;
		arrayLink[47] = 1;
		
		return arrayLink;
	}
	
	private static byte[] shuffle(byte[] cipher, byte[] arrayLink){
		Random random = new Random();
		CRC32 crc = null;
		//ByteBuffer result = ByteBuffer.allocate(128);
		ByteBuffer result = ByteBuffer.allocate(192);
		ByteBuffer salt = null;
		
		//for(int i=0; i<32; i++){	// loop for each block (for 128 bytes we use 4 bytes/block -> total 32 blocks)
		for(int i=0; i<48; i++){	// loop for each block (for 192 bytes we use 4 bytes/block -> total 48 blocks)
			salt = ByteBuffer.allocate(4);
			// Prepare pattern
			// produce 4 bytes checksum
			crc = new CRC32();
			crc.update(random.nextInt());
			salt.putInt((int) crc.getValue());
			// fill a byte of cipher to pattern pointed by ArrayLink
			byte[] chunk = salt.array();
			chunk[arrayLink[i]] = cipher[i];
			result.put(chunk);
		}
		
		return result.array();
	}
	
	private static byte[] extractCipherShuffle(byte[] shuffle, byte[] arrayLink){
		//1 prepare buffer and result
		ByteBuffer buffer = ByteBuffer.wrap(shuffle);
		//ByteBuffer result = ByteBuffer.allocate(32);
		ByteBuffer result = ByteBuffer.allocate(48);
		
		//2 extract
		byte[] chunk = new byte[4];
		//for(int i=0; i<32; i++){
		for(int i=0; i<48; i++){
			buffer.get(chunk);
			result.put(chunk[arrayLink[i]]);
		}
				
		return result.array();
	}
}

