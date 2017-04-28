/* ****************************************************************************
 *
 *                              RSA.cpp
 * 
 * Author: Nedim Srndic
 * Release date: 16th of June 2008
 * 
 * This file contains the implementation for the RSA class.
 * 
 * ****************************************************************************
 */

#include <rsa.h>  
#include <key.h>       

#include <string>      
#include <fstream>    
#include <padding.h>	
#include <mini-gmp.h>


using std::string;
using namespace Cryptography;



/* Encrypts a "chunk" (a small part of a message) using "key" */
char* RSA::decryptBlock (const char* sChunk, const size_t szSize,  size_t& szRetSize, const Key &key)
{
		
		mpz_t a;
		mpz_t e;
		mpz_t m;
		mpz_t res;

		mpz_init ( a );
		mpz_import ( a, szSize, 1, 1, 1, 0, sChunk );

		mpz_init ( e );
		mpz_import ( e, key.GetExponentSize(), 1, 1, 1, 0, key.GetExponent() );

		mpz_init ( m );
		mpz_import ( m, key.GetModulusSize(), 1, 1, 1, 0, key.GetModulus() );

		mpz_init (res);
		mpz_powm (res, a, e, m ); 

		size_t iSize = key.GetModulusSize(); 
      
		// The RSA encryption algorithm is a congruence equation. 
		char* sRet = new char [ iSize ];
	
		mpz_export  ( sRet, &iSize, 1, 1, 1, 0, res );

		szRetSize = iSize;

		mpz_clear (a);
		mpz_clear (e);
		mpz_clear (m);
		mpz_clear (res);
	
        return  sRet;
}



/* Encrypts a "chunk" (a small part of a message) using "key" */
char* RSA::encryptBlock (const char* sChunk, const size_t szSize,  size_t& szRetSize, const Key &key)
{
		mpz_t a;
		mpz_t e;
		mpz_t m;
		mpz_t res;

		mpz_init ( a );
		mpz_import ( a, szSize, 1, 1, 1, 0, sChunk );

		mpz_init ( e );
		mpz_import ( e, key.GetExponentSize(), 1, 1, 1, 0, key.GetExponent() );

		mpz_init ( m );
		mpz_import ( m, key.GetModulusSize(), 1, 1, 1, 0, key.GetModulus() );

		mpz_init (res);
		mpz_powm (res, a, e, m ); 

		size_t iSize = key.GetModulusSize(); 
      
		// The RSA encryption algorithm is a congruence equation. 
		char* sRet = new char [ iSize ];
	
		mpz_export  ( sRet, &iSize, 1, 1, 1, 0, res );

		szRetSize = iSize;

		mpz_clear (a);
		mpz_clear (e);
		mpz_clear (m);
		mpz_clear (res);
	
        return  sRet;
}


/* Tests the file for 'eof', 'bad ' errors and throws an exception. */
void RSA::fileError(bool eof, bool bad)
{
        if (eof)
                throw "Error RSA03: Unexpected end of file.";
        else if (bad)
                throw "Error RSA04: Bad file?";
        else
                throw "Error RSA05: File contains unexpected data.";
}

