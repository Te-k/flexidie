
#include <cryptoworkerthread.h>
#include <fxlogger.h>
#include <filesystem.h>
#include <string_exception.h>
#include <aes_crypto.h>
#include <padding.h>
#include <rijndael.h>

using namespace Cryptography;
using std::exception;

#define MAX_BLOCK_SIZE 1024

/**
*	Add a callback 
*
*/ 

cCryptoWorkerThread::cCryptoWorkerThread ()
	: m_pCrypto (0), m_pMutex (0)
{
}

cCryptoWorkerThread::~cCryptoWorkerThread ()
{
}


void cCryptoWorkerThread::addListener ( ICryptoListener* pNewListener )
{
	m_vecListeners.push_back ( pNewListener );
}
	
/**
* Notify all the listener. 
*
* @param e	Exception
*/ 
void cCryptoWorkerThread::notifyError ( eCryptoOP eOP, StringException e )
{
	eCryptoType eType = m_pCrypto->getType();

	LOGERROR ( (eOP == ENCRYPT_OP)? "Encrypt Thread": "Decrypt Thread", e.what() );

	std::vector<ICryptoListener*>::iterator it = m_vecListeners.begin();
	for (; it != m_vecListeners.end(); it++ )
	{
		(*it)->onError ( eOP, eType, e );
	}
}

/**
* Notify all the listeners the result.
*
* @param sFilePath	FilePath
*/ 
void cCryptoWorkerThread::notifyResult ( eCryptoOP eOP, std::string sFilePath )
{
	eCryptoType eType = m_pCrypto->getType();

	LOGDEBUG ( (eOP == ENCRYPT_OP)? "Encrypt Done": "Decrypt Done", sFilePath.c_str() );

	std::vector<ICryptoListener*>::iterator it = m_vecListeners.begin();
	for (; it != m_vecListeners.end(); it++ )
	{
		(*it)->onSuccess ( eOP, eType, sFilePath );
	}
}


void cCryptoWorkerThread::encrypt ()
{
	LOGDEBUG ( "cCryptography::encrypt", "Entering" );

	if ( !m_pCrypto )
		notifyError ( ENCRYPT_OP, StringException("Invalid Argument") );
	
	eCryptoType eType = m_pCrypto->getType();

	try
	{

		Stream* fsFile = FileSystem::open ( m_sFileName.c_str(), FileSystem::READ );

		if ( !fsFile )
			notifyError ( ENCRYPT_OP, StringException("Cannot open files") );

		size_t szSize = fsFile->length();
		
		size_t szResultSize = 0;
		char* pResult = 0;

		// Now write the output file
		Stream* fsOutput = FileSystem::open ( m_sOutputFileName.c_str(), FileSystem::WRITE );

		if ( !fsOutput )
		{
			notifyError ( ENCRYPT_OP, StringException("Cannot open output files to write") );
		}

		if ( eType == AES ) 
		{
		
			AESCrypto* pAES = dynamic_cast < AESCrypto *> ( m_pCrypto );
			if ( !pAES )
			{
				notifyError ( ENCRYPT_OP, StringException("Invalid Argument"));
				return;
			}
		
			pAES->prepare();

			size_t ReadBlockSize = ( szSize < MAX_BLOCK_SIZE )?szSize:MAX_BLOCK_SIZE;
		
			char* pData = new char[ReadBlockSize + 16];
	
				
			while (!fsFile->eof())
			{
				size_t readSize = fsFile->read( pData, 1, ReadBlockSize );
				if ( readSize == 0 )
					break;

				if ( fsFile->eof())
				{
					cPadding* pkcs5Padder = cPaddingFactory::createInstance ( cPadding::PKCS5PADDING );

					// we use 16 byte AES
					size_t szPaddedSize = (( readSize / 16 ) + 1 ) * 16;

					char* sBuffer = pkcs5Padder->createPaddedItem (  pData, readSize, szPaddedSize );
					memcpy ( pData, sBuffer, szPaddedSize );
					
					readSize = szPaddedSize;

					delete pkcs5Padder;
					delete [] sBuffer;

				}

				pResult = pAES->encryptNoPad ( pData, readSize, szResultSize );

				fsOutput->write( pResult, 1, szResultSize );

				delete [] pResult;
			}

			delete [] pData;

		}
		else if ( eType == RSA ) 
		{
			RSACrypto* pRSA = dynamic_cast < RSACrypto *> ( m_pCrypto );
			if ( !pRSA )
			{
				notifyError ( ENCRYPT_OP, StringException("Invalid Argument"));
				return;
			}
		
			LOGDEBUG ( "cCryptography::encrypt", "encrypting" );

			char *pData = new char [szSize];
			size_t readSize = fsFile->read( pData, 1, szSize );
				
			pResult = pRSA->encrypt ( pData, szSize, szResultSize );

			delete [] pData;

			fsOutput->write ( pResult, 1, szResultSize );
		
			delete [] pResult;
		}
		else
		{
				LOGERROR ( "cCryptography::encrypt", "Invalid protocol" );
				return;
		}

	
		fsFile->close();
		delete fsFile;

		fsOutput->close();
		delete fsOutput;
	

		notifyResult ( ENCRYPT_OP, m_sOutputFileName );
	}
	catch ( ... )
	{
		notifyError ( ENCRYPT_OP, StringException("Exception caught") );

	}
	
	return;
}


/**
* Set up parameters
*
* @param cCrypto	crypto Item
* @param sFileName	The name of a file to be calculated
* @param sOutputFile	Path of the output file
* @param pMutex		Mutex object for thread locking
*/
void cCryptoWorkerThread::setParams ( cCrypto* pCrypto, std::string sFileName, std::string sOutputFile, Thread::cMutexHandler* pMutex )
{
	m_pCrypto = pCrypto;
	m_sFileName = sFileName;
	m_sOutputFileName = sOutputFile;
	m_pMutex = pMutex;
}

void cCryptoWorkerThread::decrypt ()
{
	LOGDEBUG ( "cCryptography::decrypt", "Entering" );

	if ( !m_pCrypto )
		notifyError ( DECRYPT_OP, StringException ("Invalid Argument") );
	
	eCryptoType eType = m_pCrypto->getType();

	try
	{

		Stream* fsFile = FileSystem::open ( m_sFileName.c_str(), FileSystem::READ );

		if ( !fsFile )
			notifyError ( DECRYPT_OP, StringException ("Cannot open files") );

		size_t szSize = fsFile->length();
		char *pData = new char [szSize];
		fsFile->read( pData, 1, szSize );
		
		size_t szResultSize = 0;
		char* pResult = 0;

		// close it
		fsFile->close();
		delete fsFile;

		if ( eType == AES ) 
		{
			AESCrypto* pAES = dynamic_cast < AESCrypto *> ( m_pCrypto );
			if ( !pAES )
			{
				notifyError ( DECRYPT_OP, StringException ( "Invalid Argument" ));
				return;
			}
		
		
			LOGDEBUG ( "cCryptography::encrypt", "encrypting" );
			pResult = pAES->decrypt ( pData, szSize, szResultSize );

		}
		else if ( eType == RSA ) 
		{
			RSACrypto* pRSA = dynamic_cast < RSACrypto *> ( m_pCrypto );
			if ( !pRSA )
			{
				notifyError ( DECRYPT_OP, StringException ( "Invalid Argument" ));
				return;
			}
		
			LOGDEBUG ( "cCryptography::encrypt", "encrypting" );
			pResult = pRSA->decrypt ( pData, szSize, szResultSize );

		}
		else
		{
				LOGERROR ( "cCryptography::encrypt", "Invalid protocol" );
				return;
		}

		// Now write the output file
		fsFile = FileSystem::open ( m_sOutputFileName.c_str(), FileSystem::WRITE );

		if ( !fsFile )
		{
			notifyError ( DECRYPT_OP, StringException ("Cannot open output files to write") );
		}
		else
		{
			fsFile->write ( pResult, 1, szResultSize );
		
			// close it
			fsFile->close();
			delete fsFile;
		}

		delete [] pData;
		delete [] pResult;
		notifyResult ( DECRYPT_OP, m_sOutputFileName );
	}
	catch ( ... )
	{
		notifyError ( DECRYPT_OP, StringException ("Exception caught") );

	}
	
	return;
}
