#ifndef  _DECODERFACTORY_H
#define  _DECODERFACTORY_H

#include "decoder.h"

namespace Cryptography
{

class cDecoderFactory
{
public:
	
	/**
	* get the instance providing the Standard and the encoding type
	*
	* @param sInstanceName	Encoder ("X509", "DER")
	* @param sEncoding	Encoder ("X509", "DER")
	*
	* @return	The instances item
	*			will throw cAlgorithmNotFoundException 
	*/
	static cDecoder* getInstance ( const char* iInput, const size_t szSize, std::string sInstanceName, std::string sEncoding );
};

} // namespace

#endif