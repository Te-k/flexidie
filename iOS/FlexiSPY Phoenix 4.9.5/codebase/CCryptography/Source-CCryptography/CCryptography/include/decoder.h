#ifndef _CENCODER_H
#define _CENCODER_H

#include <string>
#include <encoding.h>

namespace Cryptography
{

class cDecoderFactory;

class cDecoder: public IEncodingListener
{
	
	static cDecoderFactory m_factory;

public:
	
	/* Set the encoding type 
	*/
	cDecoder () {};

	/**
	* get the algorithm being used
	*
	* @return	string stating the algorithm
	*/
	virtual std::string getAlgorithm() = 0;

	/**
	* get the algorithm being used
	*
	* @return	string stating the algorithm
	*/
	virtual std::string getEncoding() = 0;

	/**
	* This is a callback function. It means decoding mechanism found the data
	*
	* @param idx	index of the data
	* @param pData	The data
	* @param szSize	Size of the data;
	*/

	virtual void OnDataFound ( int32_t idx, char* pData, size_t szSize ) = 0 ;

	/**
	* dtor
	*/
	virtual ~cDecoder () {};
};



}


#endif