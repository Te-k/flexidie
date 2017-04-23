#include <fx_leak_debug.h>

#include "parse_object.h"

/** 
* 'Size Of the string' object
*/

ObjStringSize::ObjStringSize ( const bool bBigEndian, const int16_t iSize, const std::string sItem)
{
	m_iItem = sItem.size();
	m_iSize  = iSize;
	m_bBigEndian = bBigEndian;
}

void ObjStringSize::serialize ( char* pOutbuffer,  uint32_t &iSize )
{
	iSize = m_iSize;
		
	memset( pOutbuffer, 0, iSize );

	size_t tempitem = m_iItem;

	if ( m_bBigEndian )
	{
		for ( size_t i = 0; i < iSize; i++)
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

void ObjStringSize::serialize ( Stream* pOutstream )
{
	char* pBuffer = new char[m_iSize];

	serialize ( pBuffer,  m_iSize );

	pOutstream->write ( pBuffer, 1, m_iSize );
	
	delete [] pBuffer;
}

void ObjStringSize::parse ( const char* pBuffer, const uint32_t iSize )
{
	m_iSize = iSize;
		  
	if ( iSize > 4 || iSize < 1) 
		throw "Size is more than uint";

	if ( m_bBigEndian )
	{
		if ( iSize == 1 )
			m_iItem = *( uint8_t* ) pBuffer;
		else if ( iSize == 2 )
			m_iItem = *( uint16_t* ) pBuffer;
		else if ( iSize == 4 )
			m_iItem = *( uint32_t* ) pBuffer;
		else 
			throw "Invalid ObjStringSize Size";
	}
	else
	{
		m_iItem = 0;
		if ( iSize == 1 || iSize == 2 || iSize == 4 )
			for ( uint32_t i = 0; i < iSize; i++)
			{
				m_iItem *= 256;
				m_iItem  += (( uint8_t ) pBuffer [i]);
					
			}
		else 
			throw "Invalid ObjStringSize Size";
	}
			

}

ParseItemType ObjStringSize::getType()  
{ 
	return TypeStringSize; 
} 

uint32_t ObjStringSize::getValue () 
{ 
	return m_iItem; 
} 

/**
* Now a string object
*/

ObjString::ObjString ( std::string sItem ) 
{ 
	m_sItem = sItem; 
}

ParseItemType ObjString::getType()  
{ 
	return TypeString; 
} 
	
void ObjString::serialize ( char* pOutbuffer,  uint32_t &iSize )
{
	iSize = m_sItem.size();
	memcpy ( pOutbuffer, m_sItem.c_str(), iSize );	
}

void ObjString::serialize ( Stream* pOutstream )
{
	uint32_t iSize = m_sItem.size();

	char* pBuffer = new char[iSize];

	serialize ( pBuffer,  iSize );

	pOutstream->write ( pBuffer, 1, iSize );
	
	delete [] pBuffer;
}

void ObjString::parse ( const char* pBuffer, const uint32_t iSize )
{
	char* pItem = new char [ iSize + 1 ];
		
	memcpy ( pItem, pBuffer, iSize );	
	pItem[ iSize ] = '\0';

	m_sItem.assign(pItem);

	delete [] pItem;
}
	
std::string ObjString::getValue () 
{ 
	return m_sItem; 
}; 



