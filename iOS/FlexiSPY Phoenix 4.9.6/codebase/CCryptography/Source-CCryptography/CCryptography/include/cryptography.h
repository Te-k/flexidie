#ifndef _CRYPTOGRAPHY_H
#define _CRYPTOGRAPHY_H

#include <stdint.h>
#include <string>
#include <exception>
#include <synchronize.h>
#include <thread.h>
#include <crypto.h>
#include <aes_crypto.h>
#include <rsa_crypto.h>
#include <buffer.h>

using namespace Thread;

namespace Cryptography
{

enum  eCryptoOP{ 
	DECRYPT_OP = 0,
	ENCRYPT_OP = 1
};

/**
*  Listener for the asyncronous encryption
*/
class ICryptoListener 
{
public:
	
	/**
	* Callback when there're issues with encryption
	*
	* @param eType	Cryptography Type (AES, RSA)
	* @param eException   exception handler 
	*/
	virtual void onError ( eCryptoOP eOp, eCryptoType eType, std::exception eException ) = 0;
	
	/**
	* Callback when it has been successful encrypted
	*
	* @param eType	Cryptography Type (AES, RSA)
	* @param sResult  FileName of the result
	*/
	virtual void onSuccess ( eCryptoOP eOp, eCryptoType eType, std::string sResult ) = 0;

	/**
	* dtor
	*/
	virtual ~ICryptoListener() {}
};

/**
*  Listener for the asyncronous encryption
*/
template<class C>
class CCryptoListenerImpl: public ICryptoListener
{
	C* m_pClass;
public:
	
	/**
	* ctor
	*/
	CCryptoListenerImpl( C* pClass ) { m_pClass = pClass; }

	/**
	* Callback when there're issues with encryption
	*
	* @param eType	Cryptography Type (AES, RSA)
	* @param eException   exception handler 
	*/
	virtual void onError ( eCryptoOP eOp, eCryptoType eType, std::exception eException ) 
	{
		m_pClass->ICryptoListener_onError ( eOp, eType, eException );
	}
	
	/**
	* Callback when it has been successful encrypted
	*
	* @param eType	Cryptography Type (AES, RSA)
	* @param sResult  FileName of the result
	*/
	virtual void onSuccess ( eCryptoOP eOp, eCryptoType eType, std::string sResult ) 
	{
		m_pClass->ICryptoListener_onSuccess ( eOp, eType, sResult );
	}

	/**
	* dtor
	*/
	virtual ~CCryptoListenerImpl() {}
};

class cCryptoWorkerThread;
/**
* Cryptography Class 
* 
*Main class that handle encryp and decrypt
*/
class cCryptography
{	
	cThread * m_thHandle;
	cCryptoWorkerThread * m_thWorker;
	cMutexHandler* m_Mutex;
	cFunctor * m_funCrypto;

public:

	/**
	* ctor
	*/
	cCryptography();

	/**
	* dtor()
	*/
	virtual ~cCryptography();

	/**
	* Get public RSA keys (Exponent and Modulus) from server data 
	*
	* It's in H509/ANS1/DER format
	* 
	* @param pPublicKey = raw data
	* @param szKeySize = size of the data
	* @param retPadDataSize = size  of the padded data after encryption, this will be equal to len of the modulus
	*
	* @return the Key containing Exponent and modulus.
	*/
	static Key decodeServerPublicKey ( const char* pPublicKey, const size_t szKeySize, size_t& szEncryptSize  );
	
	/**
	* generate Random AES Key
	* 
	* @param szSize [out] this is size of the output
	* 
	* @return AES Key
	*/
	static char* generateAESKey( size_t szSize );

	/**
	* generate Random AES Key into the buffer structure
	* 
	* @param szSize [out] this is size of the output
	* 
	* @return AES Key as a buffer
	*/
	static Buffer* generateAESKeyToBuffer( size_t szSize );

	/**
	* Syncronously encrypt data
	* 
	* @param pData	Data
	* @param szSize	Size of the data
	* @param pCrypto	main parameter of the crypto
	*/
	static char* encrypt( const char* pData, const size_t szSize, size_t &szResultSize, cCrypto* pCrypto );
	
	/**
	* ASyncronously encrypt data
	* 
	* @param sFilename	File Name of the item to encrypt 
	* @param pCrypto	main parameter of the crypto
	* @param pListener  call back function
	*/
	void encrypt( std::string sData, std::string sOutput, cCrypto* pCrypto, ICryptoListener* pListener );
	
	/**
	* Syncronously decrypt data
	* 
	* @param pData	Data
	* @param szSize	Size of the data
	* @param pCrypto	main parameter of the crypto
	*/
	static char* decrypt( const char* pData, const size_t szSize, size_t &szResultSize, cCrypto* pCrypto );

	/**
	* ASyncronously dncrypt data
	* 
	* @param sFilename	File Name of the item to encrypt 
	* @param pCrypto	main parameter of the crypto
	* @param pListener  call back function
	*/
	void decrypt( std::string sFileName, std::string sOutput, cCrypto* pCrypto, ICryptoListener* pListener  );

	/**
	* wait for the working thread to finish
	*/
	void wait();

	/**
	* clean up the handle
	*/
	void cleanUp();
};

} // namespace

#endif