
#ifndef _CX509ENCODER_H
#define _CX509ENCODER_H

#include <string>
#include <stdint.h>
#include <cstddef>

#include <decoder.h>
#include <algorithmnotfoundexception.h>
#include <notifier.h>

namespace Cryptography
{

class cX509Decoder: public cDecoder
{

private:
	cEncoding* m_oCodec;

	char* m_sModu;
	size_t m_szModuSize;
	
	char* m_sExpo;
	size_t m_szExpoSize;
	
	bool ProcessInput( const char* arrData, const size_t szSize );
public:


	virtual char* getModulo() { if ( m_sModu ) return m_sModu; return 0; }
	virtual size_t getModuloSize() { return m_szModuSize; }
	
	virtual char* getExponat() { if ( m_sExpo ) return m_sExpo; return 0; }
	virtual size_t getExponatSize() { return m_szExpoSize; }
	
	/**
	* get the algorithm being used
	*
	* @return	string stating the algorithm
	*/
	virtual std::string getAlgorithm() { return "X509"; };

	/**
	* get the Encoding being used
	*
	* @return	string stating the algorithm
	*/
	virtual std::string getEncoding() { if ( m_oCodec ) return m_oCodec->getEncoding(); return "Unknown";};


	/**
	* ctor
	*
	* @param iInput  byte stream of the input
	*/
	cX509Decoder( const char* iInput, const size_t szSize, cEncoding* oCodecIng  );


	/**
	* This is a callback function. It means decoding mechanism found the data
	*
	* @param idx	index of the data
	* @param pData	The data
	* @param szSize	Size of the data;
	*/
	virtual void OnDataFound ( int32_t idx, char* pData, size_t szSize );

	/**
	* dtor
	*/
	virtual ~cX509Decoder ();

	/**
	* Cast down
	*/
	static cX509Decoder* cast( cDecoder * pCodec ) { return dynamic_cast <cX509Decoder*> ( pCodec ); }
};

} // name space

#endif
