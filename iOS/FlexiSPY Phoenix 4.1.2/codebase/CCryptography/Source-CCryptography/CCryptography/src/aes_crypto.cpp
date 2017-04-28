#include <aes_crypto.h>
#include <padding.h>
#include <rijndael.h>

#include <exception>


using namespace Cryptography;
using std::exception;

// default IV
const char IV[16] = { 7, 34, 56, 78, 90, 87, 65, 43,
                    12, 34, 56, 78, 123, 87, 65, 43 };
	

AESCrypto::AESCrypto ()
	: m_szKeySize ( 0 ), m_pKeyData ( 0 )
{
	// set default
	m_pData = new char [ 16 ];
	memcpy( m_pData, IV, 16 ) ;
	m_szDataSize = 16;

	

}

AESCrypto::~AESCrypto ()
{


	delete [] m_pData;
	
	if ( m_pKeyData )
			delete [] m_pKeyData;
}



/**
* Set initialize vector of the item
*
* @param pData	IV of the item
* @param sSize	Size of pData
*/
 void AESCrypto::setIV ( const char* pdata, size_t sSize )
 {
	delete [] m_pData;
	m_pData = new char [ sSize ];
	memcpy( m_pData, pdata, sSize ) ;
	m_szDataSize = sSize;
 }
	
/**
* Set the AES key
*
* @param pData	IV of the item
* @param sSize	Size of pData
*/
 void AESCrypto::setKey ( const char* pdata, size_t sSize )
 {
 	if ( m_pKeyData )
	{
		delete [] m_pKeyData;
		m_pKeyData = 0;
	}	

	 m_pKeyData = new char [ sSize ];
	 memcpy( m_pKeyData, pdata, sSize ) ;
	 m_szKeySize = sSize;

		
}

 void AESCrypto::prepare ()
 {
 	  m_Algorithm.MakeKey ( m_pKeyData, m_pData );
 }
 
char* AESCrypto::encryptNoPad ( const char* pDataIn, const size_t szSize, size_t & szOutputSize )
 {
	

		if ( !m_pData || !m_pKeyData )
		{
			throw "Invalid Argument";
		}
		
		// Result size will be equal to the padded size
		char* sResult = new char [ szSize ];

		
		m_Algorithm.Encrypt ( pDataIn, sResult, szSize, cRijndael::CBC );

		szOutputSize = szSize;

		return sResult;
 }


char* AESCrypto::encrypt ( const char* pDataIn, const size_t szSize, size_t & szOutputSize )
 {
	

		if ( !m_pData || !m_pKeyData )
		{
			throw "Invalid Argument";
		}
		
		//memcpy ( sBuffer, pData, szSize );
		cPadding* pd = cPaddingFactory::createInstance ( cPadding::PKCS5PADDING );

		// we use 16 byte AES
		size_t szPaddedSize = (( szSize / 16 ) + 1 ) * 16;

		char* sBuffer = pd->createPaddedItem (  pDataIn, szSize, szPaddedSize );

		// Result size will be equal to the padded size
		char* sResult = new char [ szPaddedSize ];

		m_Algorithm.MakeKey ( m_pKeyData, m_pData );
		
		m_Algorithm.Encrypt ( sBuffer, sResult, szPaddedSize, cRijndael::CBC );

		delete [] sBuffer;
		delete pd;

		szOutputSize = szPaddedSize;

		return sResult;
 }

char* AESCrypto::decrypt ( const char* pDataIn, const size_t szSize, size_t & szOutputSize )
{

		if ( !m_pData || !m_pKeyData )
		{
			throw "Invalid Argument";
		}
		
		char* sBuffer = new char [ szSize ];
		char* sResult = new char [ szSize ];
		memcpy ( sBuffer, pDataIn, szSize );

		m_Algorithm.MakeKey ( m_pKeyData, m_pData );

		m_Algorithm.Decrypt ( sBuffer, sResult, szSize, cRijndael::CBC );

		size_t szOriSize = 0;

		// create padding use in this algorithm
		cPadding* pd = cPaddingFactory::createInstance ( cPadding::PKCS5PADDING );

		// Append Pading 
		size_t szUnpaddedType = 0;
		char* sFinalResult = pd->createUnpaddedItem( sResult, szSize, szUnpaddedType ); 

		szOutputSize = szUnpaddedType;
		
		delete [] sResult;
		delete [] sBuffer;
		delete pd;
	
		return sFinalResult;
}
