#ifndef _RSA_CRYPTO_H
#define _RSA_CRYPTO_H

#include "crypto.h"
#include "rsa.h"
#include <String.h>

namespace Cryptography
{

/**
* RSA parameters handling class
*/
class RSACrypto: public cCrypto
{
	Key* m_eKey;	//either public or private key
	size_t m_szTotalSize;  //we use modulous size as total size
public:
	/**
	* Ctor
	*/
	RSACrypto();

	/**
	* dtor
	*/
	virtual ~RSACrypto();


	/**
	* Get the type of the item
	*
	* @return "RSA"
	*/
	virtual eCryptoType getType() { return RSA; }


	/**
	* Set the RSA public or private key (depending on whether it's encryption or decryption
	*
	* @param sKey Keytype
	*/
	virtual void setKey ( Key* pRSAKey,  const size_t	sModulusSize ) { m_eKey = pRSAKey; m_szTotalSize  = sModulusSize; } ;


	/**
	* Set the RSA public or private key (depending on whether it's encryption or decryption
	*
	* @param pData	IV of the item
	* @param sSize	Size of pData
	*/
	virtual void setKey ( const char*	pModulusData, 
						  const size_t	sModulusSize,
						  const char*	pExponentData, 
						  const size_t	sExponentSize );
	
	/**
	* Encrypt the data
	*
	* @param pDataIn	Data Input
	* @param siSize    size of the input
	* @param [OUT] siOutputSize    size of the return value
	* 
	* return Encrypted string
	*/
	virtual char* encrypt ( const char* pDataIn, const size_t szSize, size_t & szOutputSize );


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
