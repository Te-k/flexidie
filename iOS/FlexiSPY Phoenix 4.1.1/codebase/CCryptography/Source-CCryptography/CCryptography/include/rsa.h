/* ****************************************************************************
 * 
 *                              RSA.h
 * 
 * Author: Nedim Srndic
 * Release date: 16th of June 2008
 * 
 * An implementation of the RSA public-key cryptography algorithm. 
 * 
 * RSA supports: 
 * 
 *      - Message encryption (string and file) (Encrypt())
 *      - Message decryption (string and file) (Decrypt())
 *      - Public/private keypair generation (GenerateKeyPair())
 * 
 * NOTE: All methods are static. Instantiation, copying and assignment of 
 *      objects of type RSA is forbidden. 
 * 
 * NOTE: it is highly recommended to call 
 *              std::srand(time(NULL));
 *      once when the program starts and before any use of methods provided by the 
 *      RSA class. Calling the srand() function randomizes the standard C++ 
 *      pseudorandom number generator, so that it provides different series of 
 *      pseudorandom numbers every time the program is run. This greatly improves 
 *      security. 
 * 
 * ****************************************************************************
 */

#ifndef RSA_H_
#define RSA_H_

#include <string>
#include <fstream>
#include <String.h>

#include "key.h"

namespace Cryptography
{

class RSA
{
        private:
                /* Instantiation of objects of type RSA is forbidden. */
                RSA()
                {}
                /* Copying of objects of type RSA is forbidden. */
                RSA(const RSA &rsa);
                /* Assignment of objects of type RSA is forbidden. */
                RSA &operator=(const RSA &rsa);
               
		        /* Throws an exception if "key" is too short to be used. */
                static void checkKeyLength(const Key &key);
                /* Transforms a std::string message into a BigInt message. */
        public:  
			   
			   /**
			   * Encrypt the Chuck of chars
			   *
			   * @param sChunk	Byte array to encrypt.
			   * @param szSize	Size of the chunk
			   * @param szRetSzie Return size.
			   * @param Key		public key to encrypt
			   */
				static char* encryptBlock (const char* sChunk,
											const size_t szSize,  
											size_t& szRetSize, 
											const Key &key);
				
				/**
			   * Encrypt the Chuck of chars
			   *
			   * @param sChunk	Byte array to encrypt.
			   * @param szSize	Size of the chunk
			   * @param szRetSzie Return size.
			   * @param Key		private key to dencrypt
			   */
                static char* decryptBlock (const char* sChunk,
											const size_t szSize,  
											size_t& szRetSize, 
											const Key &key);

				
				  /* Tests the file for 'eof', 'bad ' errors and throws an exception. */
                static void fileError(bool eof, bool bad);
     
    };

} // name space

#endif /*RSA_H_*/
