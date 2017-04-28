
#include <decoderfactory.h>
#include <x509decoder.h>
#include <der_encoding.h>

#include <algorithmnotfoundexception.h>

using namespace Cryptography;

cDecoder* cDecoderFactory::getInstance ( const char* iInput, const size_t szSize, std::string sInstanceName, std::string sEncoding )
{
	if ( sInstanceName == "X509" )
	{
		if ( sEncoding == "DER" )
		{
			cEncoding* oNewCodec = new cDerEncoding ();
			cDecoder* item = new cX509Decoder( iInput, szSize, oNewCodec );
			return item;
		}
	}

	cAlgorithmNotFoundException Excptn;
	throw ( Excptn );

	return 0;
}