#ifndef _AES_CRYPTO_H
#define _AES_CRYPTO_H

#include "crypto.h"
#include <rijndael.h>

namespace Cryptography
{

/**
* AES parameters handling class
*/
class AESCrypto: public cCrypto
{
	size_t m_szDataSize;
	char* m_pData;
	
	size_t m_szKeySize;
	char* m_pKeyData;

	cRijndael m_Algorithm;

public:
	/**
	* Ctor
	*/
	AESCrypto();

	/**
	* dtor
	*/
	virtual ~AESCrypto();


	/**
	* Get the type of the item
	*
	* @return "AES"
	*/
	virtual eCryptoType getType() { return AES; }

	/**
	* Set initialize vector of the item
	*
	* @param pData	IV of the item
	* @param sSize	Size of pData
	*/
	virtual void setIV ( const char* pdata, size_t sSize );
	
	/**
	* Set the AES key
	*
	* @param pData	IV of the item
	* @param sSize	Size of pData
	*/
	virtual void setKey ( const char* pdata, size_t sSize );

	/**
	* Encrypt the data
	* No need to call prepare().
	*
	* @param pDataIn	Data Input
	* @param siSize    size of the input
	* @param [OUT] siOutputSize    size of the return value
	* 
	* return Encrypted string
	*/
	virtual char* encrypt ( const char* pDataIn, const size_t szSize, size_t & szOutputSize );

	/**
	* encrypt without padding first, prepare() need to be called before calling this one
	*/
	virtual char* encryptNoPad ( const char* pDataIn, const size_t szSize, size_t & szOutputSize );

	/**
	* prepared, function for encryptNoPad() function
	*/
	virtual void prepare ();

	/**
	* Decrypt the data
	*
	* @param pDataIn	Data Input
	* @param siSize    size of the input
	* @param [OUT] siOutputSize    size of the return value
	* 
	* return Decrypted string
	*/
	virtual char* decrypt ( const char* pDataIn, const size_t szSize, size_t & szOutputSize );
};

} // namespace
#endif
