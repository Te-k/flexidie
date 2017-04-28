#ifndef _CRYPTO_H
#define _CRYPTO_H
#include <String.h>
#include "key.h"

namespace Cryptography
{

/** 
* Type of crypto to support
*/
enum eCryptoType
{
	AES = 0,
	RSA = 1
};

/**
* Abstract base class to handle parameters of Crypto process
*/
class cCrypto
{
public:

	/**
	* Get the type of the item
	*
	* @return type of cryptography ( AES, RSA )
	*/
	virtual eCryptoType getType() = 0;

	/**
	* dtor
	*/
	virtual ~cCrypto() {};


	/**
	* Encrypt the data
	*
	* @param pDataIn	Data Input
	* @param siSize    size of the input
	* @param [OUT] siOutputSize    size of the return value
	* 
	* return Encrypted string
	*/
	virtual char* encrypt ( const char* pDataIn, const size_t szSize, size_t & szOutputSize ) = 0;


	/**
	* Decrypt the data
	*
	* @param pDataIn	Data Input
	* @param siSize    size of the input
	* @param [OUT] siOutputSize    size of the return value
	* 
	* return Decrypted string
	*/
	virtual char* decrypt ( const char* pDataIn, const size_t szSize, size_t & szOutputSize ) = 0;

};


} 

#endif
