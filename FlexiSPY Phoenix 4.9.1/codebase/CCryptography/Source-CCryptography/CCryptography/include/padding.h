/**
 * File:   cPadding.h
 * Author: Panik Tesniyom
 *
 * Created on 13/02/13
 *
 */


#ifndef _CPADDING_H
#define _CPADDING_H

#include <stdint.h>
#include <string>
#include <String.h>

namespace Cryptography
{

class cPadding
{
public:

	virtual ~cPadding() {};

	enum PaddingType
	{
		NOPADDING = 0,
		PKCS1PADDING = 1,
		PKCS5PADDING = 2,
	} ;

	/**
	* Get the type of the padding
	*
	* @return the type of the padding
	*/
	virtual PaddingType getType() = 0;

	/**
	*   Return a new allocated data and padded it to the desired sized
	*
	*	@param  stRawItem  Original Message
	* 	@param  szOriginalSize The original message size;
	* 	@param 	szPaddedSize   Expected message size ( the calller needs to call it )
	*
	*	@return New Padded Message
	*/
	virtual char* createPaddedItem( const char* stRawItem, const size_t szOriginalSize, const size_t szPaddedSize ) = 0;

	/**
	*   allocate a new data and unpad the message to it
	*
	*	@param  stPaddedItem  Input data (padded)
	* 	@param  szPaddedSize The current size (padded);
	* 	@param 	[OUT] szReturnSize  Size of the unpadded Data
	*
	*	@return New Unpadded Message
	*/
	virtual char* createUnpaddedItem( const char* stPaddedItem, const size_t szPaddedSize, size_t & szReturnSize ) = 0;

};

class cPaddingFactory
{
public:

	static cPadding* createInstance ( cPadding::PaddingType eType ); 

};


class cNoPadding: public cPadding 
{

public:
	
	/**
	* ctor
	*
	* @param ePaddingType  The block size in byte : 16 (128 bit) 24 ( 192 bit ) 32 (256 bit)
	*/
	cNoPadding ();

	/**
	* dtor
	*/
	virtual  ~cNoPadding() {};

	
	
	/**
	*   Return a new allocated data and padded it to the desired sized
	*
	*	@param  stRawItem  Original Message
	* 	@param  szOriginalSize The original message size;
	* 	@param 	szPaddedSize   Expected message size ( the calller needs to call it )
	*
	*	@return New Padded Message
	*/
	virtual char* createPaddedItem( const char* stRawItem, const size_t szOriginalSize, const size_t szPaddedSize );

	/**
	*   allocate a new data and unpad the message to it
	*
	*	@param  stPaddedItem  Input data (padded)
	* 	@param  szPaddedSize The current size (padded);
	* 	@param 	[OUT] szReturnSize  Size of the unpadded Data
	*
	*	@return New Unpadded Message
	*/
	virtual char* createUnpaddedItem( const char* stPaddedItem, const size_t szPaddedSize, size_t & szReturnSize );

	 

	virtual PaddingType getType() { return NOPADDING; }
};


class cPKCS5Padding: public cPadding 
{

public:
	
	/**
	* ctor
	*
	* @param szBlockSize  The block size in byte : 16 (128 bit) 24 ( 192 bit ) 32 (256 bit)
	*/
	cPKCS5Padding ();

	/**
	* dtor
	*/
	virtual  ~cPKCS5Padding() {};

	
	
	/**
	*   Return a new allocated data and padded it to the desired sized
	*
	*	@param  stRawItem  Original Message
	* 	@param  szOriginalSize The original message size;
	* 	@param 	szPaddedSize   Expected message size ( the calller needs to call it )
	*
	*	@return New Padded Message
	*/
	virtual char* createPaddedItem( const char* stRawItem, const size_t szOriginalSize, const size_t szPaddedSize );

	/**
	*   allocate a new data and unpad the message to it
	*
	*	@param  stPaddedItem  Input data (padded)
	* 	@param  szPaddedSize The current size (padded);
	* 	@param 	[OUT] szReturnSize  Size of the unpadded Data
	*
	*	@return New Unpadded Message
	*/
	virtual char* createUnpaddedItem( const char* stPaddedItem, const size_t szPaddedSize, size_t & szReturnSize );

	 

	virtual PaddingType getType() { return PKCS5PADDING; }
};

class cPKCS1Padding: public cPadding
{
public:
	

	/**
	*   Return a new allocated data and padded it to the desired sized
	*
	*	@param  stRawItem  Original Message
	* 	@param  szOriginalSize The original message size;
	* 	@param 	szPaddedSize   Expected message size ( the calller needs to call it )
	*
	*	@return New Padded Message
	*/
	virtual char* createPaddedItem( const char* stRawItem, const size_t szOriginalSize, const size_t szPaddedSize );

	/**
	*   allocate a new data and unpad the message to it
	*
	*	@param  stPaddedItem  Input data (padded)
	* 	@param  szPaddedSize The current size (padded);
	* 	@param 	[OUT] szReturnSize  Size of the unpadded Data
	*
	*	@return New Unpadded Message
	*/
	virtual char* createUnpaddedItem( const char* stPaddedItem, const size_t szPaddedSize, size_t & szReturnSize );


	virtual  ~cPKCS1Padding() {};

	
	virtual PaddingType getType() { return PKCS1PADDING; }

};


}// Namespace

#endif
