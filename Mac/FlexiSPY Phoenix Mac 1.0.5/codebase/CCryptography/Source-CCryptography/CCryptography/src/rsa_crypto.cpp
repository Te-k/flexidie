#include <rsa_crypto.h>
#include <padding.h>
#include <rsa.h>
#include <cstddef>

#include <exception>


using namespace Cryptography;
using std::exception;

RSACrypto::RSACrypto ()
: m_eKey(0), m_szTotalSize (0)
{

}

RSACrypto::~RSACrypto ()
{
	if ( m_eKey )
	{
		delete m_eKey;
		m_eKey = 0;
	}

}
	
void RSACrypto::setKey ( const char*	pModulusData, 
					const size_t	sModulusSize,
					const char*	pExponentData, 
					const size_t	sExponentSize )
{
	// set the size too	
	m_szTotalSize = sModulusSize;

	m_eKey = new Key ( pModulusData, sModulusSize, pExponentData, sExponentSize );

}



char* RSACrypto::encrypt ( const char* pDataIn, const size_t szSize, size_t & szOutputSize )
 {
	

		if ( !m_eKey || !m_szTotalSize )
		{
			throw "Invalid Argument";
		}
		
		cPadding* pd = cPaddingFactory::createInstance ( cPadding::PKCS1PADDING );

		// we use 16 byte AES
		size_t szPaddedSize = m_szTotalSize;

		char* sBuffer = pd->createPaddedItem (  pDataIn, szSize, szPaddedSize );
		// Append Pading 

		// Result size will be equal to the padded size
		char* sResult = RSA::encryptBlock ( sBuffer, szPaddedSize, szOutputSize, *m_eKey );

		delete [] sBuffer;
		delete pd;

		return sResult;
 }

char* RSACrypto::decrypt ( const char* pDataIn, const size_t szSize, size_t & szOutputSize )
{

		
		if ( !m_eKey || !m_szTotalSize )
		{
			throw "Invalid Argument";
		}
		
		// we use 16 byte AES
		size_t szPaddedSize = 0;

		// Result size will be equal to the padded size
		char* sBuffer = RSA::decryptBlock ( pDataIn, szSize, szPaddedSize, *m_eKey );

		// unpad it
		cPadding* pd = cPaddingFactory::createInstance ( cPadding::PKCS1PADDING );
		char* sResult = pd->createUnpaddedItem (  sBuffer, szPaddedSize, szOutputSize );
		
		// Append Pading 
		delete []sBuffer ;
		delete pd;

		return sResult;
}
