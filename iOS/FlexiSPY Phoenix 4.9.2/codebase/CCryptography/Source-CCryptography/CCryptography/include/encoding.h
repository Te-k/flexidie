#ifndef _ENCODING_H
#define _ENCODING_H

#include <string>
#include <vector>
#include <stdint.h>
#include <decodingexception.h>
#include <notifier.h>
#include <String.h>

namespace Cryptography
{


/**
* Listener Interface for the Codec
*/
class IEncodingListener 
{
public:

	/** 
	* Call Back when the data is found
	*
	* @param idx	the sequence number of the data found
	* @param pData	The data found
	* @param szSize	Size of the data found
	*/
	virtual void OnDataFound ( int32_t idx, char* pData, size_t Size ) = 0;

	/** 
	* virtual dtor 
	* This is needed or the children won't do their own dtor
	*/
	virtual ~IEncodingListener() {};
};

/**
* Codec
*/
class cEncoding 
{

public:
	
	/** 
	* virtual dtor 
	* This is needed or the children won't do their own dtor
	*/
	virtual ~cEncoding () {};
	
	/**
	* Register result listener
	*
	* @param oListener the listener
	*/
	virtual void registerListener ( IEncodingListener * oListener ) = 0;

	/**
	* Decode the Byte array
	*
	* @param arrData	Data
	* @param szSize		Size of Data
	*/
	virtual void decode ( const char* arrData, const size_t szSize ) = 0;

	/** 
	* Return the encoding name
	*/
	virtual std::string getEncoding() = 0;

};


}// name space
#endif
