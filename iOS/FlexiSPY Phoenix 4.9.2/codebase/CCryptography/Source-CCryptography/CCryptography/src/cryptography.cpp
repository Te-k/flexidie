#include <string_exception.h>
#include <filesystem.h>
#include <fxlogger.h>
#include <exception>
#include <cstdlib> 
#include <time.h>

#include "cryptography.h"
#include "aes_crypto.h"
#include "decoderfactory.h"
#include "x509decoder.h"
#include "rijndael.h"
#include "padding.h"
#include "cryptoworkerthread.h"

using std::exception;
using namespace Cryptography;


/**
* ctor
*/
cCryptography::cCryptography()
	:m_thHandle(0), m_thWorker(0), m_funCrypto(0)
{
	m_Mutex = cMutexHandler::GenerateMutex();

}

cCryptography::~cCryptography()
{
	cleanUp();
	delete m_Mutex;
}

void cCryptography::cleanUp()
{
	try
	{
		if ( m_thHandle )
		{
			m_thHandle->join();
			delete m_thHandle;
			m_thHandle = 0;
		}
	}
	catch ( ... )
	{
		//do nothing
	}

	if ( m_thWorker )
	{
		delete m_thWorker;
		m_thWorker = 0;
	}

	if ( m_funCrypto )
	{
		delete m_funCrypto;
		m_funCrypto = 0;
	}


}

Key cCryptography::decodeServerPublicKey ( const char* pPublicKey, const size_t szKeySize, size_t &szEncryptSize  )
{

		LOGDEBUG ( "cCryptography::decodeServerPublicKey", "Entering" );

		// Greate instance
		cDecoder* decodec =	cDecoderFactory::getInstance ( pPublicKey, szKeySize, "X509", "DER" );

		// In rsa, padded data size will euqate to the size of the modulus
		szEncryptSize = cX509Decoder::cast(decodec)->getModuloSize();

		// Generate new key
		Key kNewKey( cX509Decoder::cast(decodec)->getModulo(), 
					 szEncryptSize,
					 cX509Decoder::cast(decodec)->getExponat(),
					 cX509Decoder::cast(decodec)->getExponatSize() 
					);

		// crean up
		delete decodec;

		LOGDEBUG ( "cCryptography::decodeServerPublicKey", "Exiting" );

		return kNewKey;
		
}


/* randomly generate the first item
*/
char* cCryptography::generateAESKey ( size_t szSize )
{
	LOGDEBUG ( "cCryptography::generateAESKey", "Entering" );

	char* newItem = new char[szSize];

	srand ( ( unsigned int ) time(0));

	for ( size_t i = 0; i < szSize; i++ )
	{
		newItem [i] = rand() % 256;
	}

	LOGDEBUG ( "cCryptography::generateAESKey", "Exiting" );
	
	return newItem;
}

Buffer* cCryptography::generateAESKeyToBuffer ( size_t szSize )
{
	char* pAesKey = generateAESKey ( szSize );
	Buffer* pNewBuffer = new Buffer ( pAesKey, szSize );
	delete [] pAesKey;

	return pNewBuffer;
}

char* cCryptography::encrypt( const char* pData, const size_t szSize, size_t &szResultSize, cCrypto* pCrypto )
{
	LOGDEBUG ( "cCryptography::encrypt", "Entering" );

	if ( !pCrypto )
		throw  StringException ("Invalid Argument") ;
	
	if ( pCrypto->getType() == AES ) 
	{
		AESCrypto* pAES = dynamic_cast < AESCrypto *> ( pCrypto );
		if ( !pAES )
		{
			LOGERROR ( "cCryptography::encrypt", "Wrong Arguments" );
			throw StringException ("Invalid Argument");
		}
		
		
		LOGDEBUG ( "cCryptography::encrypt", "leaving" );
	
		return pAES->encrypt ( pData, szSize, szResultSize );
	}
	else if ( pCrypto->getType() == RSA ) 
	{
		RSACrypto* pRSA = dynamic_cast < RSACrypto *> ( pCrypto );
		if ( !pRSA )
		{
			LOGERROR ( "cCryptography::encrypt", "Wrong Arguments" );
			throw "Invalid Argument";
		}
		
		
		LOGDEBUG ( "cCryptography::encrypt", "leaving" );
	
		return pRSA->encrypt ( pData, szSize, szResultSize );
	}

	
	LOGERROR ( "cCryptography::encrypt", "unsupport type" );
	
	throw StringException ("Unsupported type") ;

	return 0;
}





void cCryptography::encrypt( std::string sFileName, std::string sOutputFilename, cCrypto* pCrypto, ICryptoListener* pListener )
{
	LOGDEBUG ( "cCryptography::encrypt", "Entering" );

	if ( ( !pCrypto ) || 
	   ( !FileSystem::fileExists ( sFileName.c_str() )))
			throw StringException ("Invalid Argument");

	cleanUp();

	m_thHandle = cThread::createThread();

	// Create the running thread to be bound with the handle
    m_thWorker = new cCryptoWorkerThread();


	m_thWorker->addListener ( pListener );
	m_thWorker->setParams ( pCrypto, sFileName, sOutputFilename, m_Mutex );

	// Bind the running thread with the functor (cCrypto*, std::string, cMutexHandler*, IEncryptListener*) 
	m_funCrypto = bind<cCryptoWorkerThread>( &cCryptoWorkerThread::encrypt, m_thWorker );
	
	LOGDEBUG  ( "cCRC32::calculate", "Async calculate: Starting a worker thread" );
	m_thHandle->start ( m_funCrypto );

}




char* cCryptography::decrypt( const char* pData, const size_t szSize, size_t &szResultSize, cCrypto* pCrypto )
{
	LOGDEBUG ( "cCryptography::encrypt", "Entering" );

	if ( !pCrypto )
		throw StringException ("Invalid Argument");
	
	
	if ( pCrypto->getType() == AES ) 
	{
		AESCrypto* pAES = dynamic_cast < AESCrypto *> ( pCrypto );
		if ( !pAES )
		{
			LOGERROR ( "cCryptography::encrypt", "Wrong Arguments" );
			throw StringException ("Invalid Argument");
		}
		
		LOGDEBUG ( "cCryptography::encrypt", "Leaving  " );
		return pAES->decrypt ( pData, szSize, szResultSize );;
	}
	else if ( pCrypto->getType() == RSA ) 
	{
		RSACrypto* pRSA = dynamic_cast < RSACrypto *> ( pCrypto );
		if ( !pRSA )
		{
			LOGERROR ( "cCryptography::encrypt", "Wrong Arguments" );
			throw StringException ("Invalid Argument");
		}
		
		LOGDEBUG ( "cCryptography::encrypt", "Leaving  " );
	
		return pRSA->decrypt ( pData, szSize, szResultSize );;
	}

	LOGDEBUG ( "cCryptography::encrypt", "Exiting" );
	return 0;
}


void cCryptography::decrypt( std::string sFileName, std::string sOutputFilename, cCrypto* pCrypto, ICryptoListener* pListener )
{
	LOGDEBUG ( "cCryptography::decrypt async", "Entering" );

	if ( ( !pCrypto ) || 
	   ( !FileSystem::fileExists ( sFileName.c_str() )))
			throw StringException ("Invalid Argument");
	
	cleanUp();

	m_thHandle = cThread::createThread();

	// Create the running thread to be bound with the handle
	m_thWorker = new cCryptoWorkerThread();


	m_thWorker->addListener ( pListener );
	m_thWorker->setParams ( pCrypto, sFileName, sOutputFilename, m_Mutex );

	// Bind the running thread with the functor (cCrypto*, std::string, cMutexHandler*, IEncryptListener*) 
	m_funCrypto = bind<cCryptoWorkerThread>( &cCryptoWorkerThread::decrypt, m_thWorker );

	LOGDEBUG  ( "cCryptography::decrypt async", "Async calculate: Starting a worker thread" );
	m_thHandle->start ( m_funCrypto );

}

void cCryptography::wait ()
{
	if ( m_thHandle )
		m_thHandle->join();
}
