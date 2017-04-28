#include <stdint.h>
#include <cstring>
#include <String.h>
#include <stdlib.h>
#include <string_exception.h>

#include "padding.h"

using namespace Cryptography;

cPadding* cPaddingFactory::createInstance ( cPadding::PaddingType eType )
{
	switch ( eType )
	{
	case cPadding::PKCS5PADDING:
		return new cPKCS5Padding();
		break;
	case cPadding::PKCS1PADDING:
		return new cPKCS1Padding();
		break;
	}

	return 0;
}
/**
* ctor
*
* @param szBlockSize  The block size in byte : 16 (128 bit) 24 ( 192 bit ) 32 (256 bit)
*/
cPKCS5Padding::cPKCS5Padding ()
{
}

char* cPKCS5Padding::createPaddedItem( const char* stRawItem, const size_t szOriginalSize, const size_t szPaddedSize )
{
		
		// calculate the last item t0 be the 
		if ( stRawItem == 0 )
		{
			throw StringException("cPKCS5Padding::createPaddedItem-Parameter Error");
		}	

	
		// genearate output
		char* stOutput = new char [ szPaddedSize ];
		memcpy ( stOutput, stRawItem, szOriginalSize );


		size_t szNumToFill = ( szPaddedSize - szOriginalSize );
		if ( szNumToFill < 0 || szNumToFill > 255)
		{
			throw StringException("cPKCS5Padding::createPaddedItem-Parameter Error");
		}	

		char chNumtoFill = (char) szNumToFill;

		for ( int i = 0; i < chNumtoFill; i ++)
		{
			stOutput[szOriginalSize + i] = chNumtoFill;
		}

		return stOutput;
}

char* cPKCS5Padding::createUnpaddedItem( const char* stPaddedItem, const size_t szPaddedSize, size_t & szOriginalSize )
{
	
		// Verify the item
		if ( stPaddedItem == 0 ) 
		{
			throw StringException("cPKCS5Padding: Calculating error");
		}

		// check last bit
		unsigned char iLastbyte = ( stPaddedItem[ szPaddedSize-1 ] );
		if (  iLastbyte == 0 || iLastbyte > szPaddedSize )
		{
			throw StringException("cPKCS5Padding: There is no Padding applied");
		}
		
		// check padding bits pettern
		for ( size_t i = szPaddedSize - 1; i >= szPaddedSize - iLastbyte; i-- )
		{
			if ( stPaddedItem[i] != iLastbyte )
			{
				throw StringException("cPKCS5Padding: Padding bit error");
			}
		}

		// Now get the item
		szOriginalSize = ( szPaddedSize - iLastbyte );
		char* stUnpaddedItem = new char [ szOriginalSize ];
		memcpy ( stUnpaddedItem, stPaddedItem, szOriginalSize );
		
		return stUnpaddedItem;
}

/**
*   Return a new allocated data and padded it to the desired sized
*
*	@param  stRawItem  Original Message
* 	@param  szOriginalSize The original message size;
* 	@param 	szPaddedSize   Expected message size ( the calller needs to call it )
*
*	@return New Padded Message
*/
char* cPKCS1Padding::createPaddedItem( const char* stRawItem, const size_t szOriginalSize, const size_t szPaddedSize )

{
		
		// Verify the item
		if (( stRawItem == 0 ) ||
		   ( szPaddedSize - szOriginalSize < 7 ))
		{
			throw StringException("cPKCS1Padding::AppendPadData: Param error");
		}

		size_t szEndPadPos = szPaddedSize - szOriginalSize; 

		// move mem to the back
		char* stOutputItem = new char [ szPaddedSize ];
		memcpy ( stOutputItem + szEndPadPos, stRawItem, szOriginalSize );
		
		stOutputItem[0] = 0x00;
		stOutputItem[1] = 0x02;
		for ( size_t i = 2; i < szEndPadPos-1; i++ )
		{
			stOutputItem[i] = (char) ( rand () % 255  + 1) ; // fill it with positive unsigned char ( 0 -255 ) 

			if ( stOutputItem[i] == 0 )
			{
				stOutputItem[i] = 1;
			}
		}
		stOutputItem[szEndPadPos-1] = 0x00;

		return stOutputItem;
}	


/**
*   allocate a new data and unpad the message to it
*
*	@param  stPaddedItem  Input data (padded)
* 	@param  szPaddedSize The current size (padded);
* 	@param 	[OUT] szReturnSize  Size of the unpadded Data
*
*	@return New Unpadded Message
*/
char* cPKCS1Padding::createUnpaddedItem( const char* stPaddedItem, const size_t szPaddedSize, size_t & szNewSize )
{
		// convert first for the easy use
		char* stIntPtr = ( char* ) ( stPaddedItem );
		
		// Verify the item
		if (( stPaddedItem == 0 ) ||
		   ( szPaddedSize == 0 ))  
		{
			throw StringException("cPKCS1Padding::GenerateUnpaddedItem: Parameter errors");
		}

		size_t i = 0;

		// create a pointer to use
		char* pItem = stIntPtr;

		// First check whether there's actually a padd 
		// 0x0 (Optional?) | 0x2 | Random data(No 0x0)| 0x0 | Message 
		if ( *pItem == 0x0 )
		{
			i ++;
			pItem++;
		}
		if ( *pItem != 0x2 )
		{
			// can't find a thing, return null;
			return 0;
		}

		// there's padding let go through the message until the end
		for (; i < szPaddedSize - 1; i++, pItem ++ )
		{
			if (*pItem == 0x0)
			{
				pItem ++;
				// There's no padding let's return the whole string
				szNewSize = szPaddedSize - i - 1;
				char* ret = new char[szNewSize];
				memcpy ( ret, pItem, szNewSize );
				return ret;
			}
		}

		// can't find a thing, return null;
		return 0;
}
