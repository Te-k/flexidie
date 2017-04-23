#include <x509decoder.h>
#include <decodingexception.h>
#include <string>

using namespace Cryptography;
using namespace std;


	
cX509Decoder::cX509Decoder( const char* iInput, const size_t szSize, cEncoding* oCodec ):
	m_oCodec ( 0 ), m_sModu ( 0 ), m_sExpo ( 0 )
{
	cDecodingException DecExcept;
	cAlgorithmNotFoundException AlNotFoundExcept;

	if ( ! oCodec )
		throw DecExcept;

	// check the encoding type that it supports ( only DER for now )
	if ( oCodec->getEncoding() != "DER" )
		throw AlNotFoundExcept;

	m_oCodec =  oCodec;

	ProcessInput ( iInput, szSize );
}

cX509Decoder::~cX509Decoder()
{
	
	if ( m_sModu )
		delete [] m_sModu;
	
	if ( m_sExpo )
		delete [] m_sExpo; 

	if ( m_oCodec ) 
		delete m_oCodec; 

}

void cX509Decoder::OnDataFound ( int32_t idx, char* pData, size_t szSize )
{
	if ( idx == 1 )
	{
		if ( pData[0] == 0 && szSize > 2 )
		{
			// there is prefix  00
			m_szModuSize = szSize - 1;
			m_sModu	 = new char [ m_szModuSize ];
			memcpy ( m_sModu, pData + 1, m_szModuSize );
		}
		else
		{
			m_szModuSize = szSize;
			m_sModu	 = new char [ m_szModuSize ];
			memcpy ( m_sModu, pData, m_szModuSize );
		}
	}
	else if ( idx == 2 )  
	{
		m_szExpoSize = szSize;
		m_sExpo = new char [ m_szExpoSize ];
		memcpy ( m_sExpo, pData, m_szExpoSize );
	}
}

bool cX509Decoder::ProcessInput( const char* arrData, const size_t szSize )
{
	bool bEnd = false;

	m_oCodec->registerListener ( this );
	m_oCodec->decode ( arrData, szSize );

	return true;
}


