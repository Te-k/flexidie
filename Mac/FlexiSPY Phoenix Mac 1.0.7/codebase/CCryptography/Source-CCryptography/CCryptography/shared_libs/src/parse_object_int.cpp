#include <fx_leak_debug.h>

#include "parse_object.h"

/** 
* Unsigned integer object
*/

ObjUInt::ObjUInt ( const bool bBigEndian, 
				   const uint32_t item, 
				   const int16_t iSize )
{ 
	m_Item = 0; 
	m_bBigEndian = bBigEndian; 
	m_Item = item; 
	m_iSize = iSize; 
}

ParseItemType ObjUInt::getType()  
{ 
	return TypeUInt; 
} 
	
void ObjUInt::serialize ( char* pOutbuffer,  uint32_t &iSize )
{
	iSize = m_iSize;
		
	memset( pOutbuffer, 0, iSize );

	uint32_t tempitem = m_Item;

	if ( m_bBigEndian )
	{
		for ( uint32_t i = 0; i < iSize; i++)
		{
			pOutbuffer[i] = (char) (tempitem % 256);
			tempitem /= 256;
		}	
	}
	else
	{
		for ( uint32_t i = 0; i < iSize; i++)
		{
			pOutbuffer[iSize - i - 1] = (char) (tempitem % 256);
			tempitem /= 256;
		}
	}
}

void ObjUInt::serialize ( Stream* pOutstream )
{
	char* pBuffer = new char[m_iSize];

	serialize ( pBuffer,  m_iSize );

	pOutstream->write ( pBuffer, 1, m_iSize );
	
	delete [] pBuffer;
}

void ObjUInt::parse ( const char* pBuffer, const uint32_t iSize )
{
	m_iSize = iSize;
		  
	if ( iSize > 4 || iSize < 1) 
		throw "Size is more than uint";

	if ( m_bBigEndian )
	{
		if ( iSize == 1 )
			m_Item = *( uint8_t* ) pBuffer;
		else if ( iSize == 2 )
			m_Item = *( uint16_t* ) pBuffer;
		else if ( iSize == 4 )
			m_Item = *( uint32_t* ) pBuffer;
		else 
			throw "Invalid Uint Size";
	}
	else
	{
		m_Item = 0;
		if ( iSize == 1 || iSize == 2 || iSize == 4 )
			for ( uint32_t i = 0; i < iSize; i++)
			{
				m_Item *= 256;
				m_Item  += (( uint8_t ) pBuffer [i]);
					
			}
		else 
			throw "Invalid Uint Size";
	}
}
	
uint32_t ObjUInt::getValue () 
{ 
	return m_Item; 
}; 



