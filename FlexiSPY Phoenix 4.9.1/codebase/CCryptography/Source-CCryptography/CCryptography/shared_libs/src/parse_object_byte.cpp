#include "fx_leak_debug.h"
#include "parse_object.h"

using std::string;

/**
* Bytes object to hole the buffers
*/
ObjByteSize::ObjByteSize ( bool bBigEndian, int16_t iSizeOfSize, uint32_t iItem )
{
	m_iItem = iItem;
	m_iSize  = iSizeOfSize;
	m_bBigEndian = bBigEndian;
}

void ObjByteSize::serialize ( char* pOutbuffer,  uint32_t &iSize )
{
	iSize = m_iSize;
		
	memset( pOutbuffer, 0, iSize );

	size_t tempitem = m_iItem;

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


void ObjByteSize::serialize ( Stream* pOutstream )
{
	char* pBuffer = new char[m_iSize];

	serialize ( pBuffer,  m_iSize );

	pOutstream->write ( pBuffer, 1, m_iSize );
	
	delete [] pBuffer;
}


void ObjByteSize::parse ( const char* pBuffer, const uint32_t iSize )
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
			throw "Invalid ObjByteSize Size";
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
			throw "Invalid ObjByteSize Size";
	}
			

}

ParseItemType ObjByteSize::getType()  
{ 
	return TypeByteSize; 
} 

uint32_t ObjByteSize::getValue () 
{ 
	return m_iItem;
}



ObjByte::ObjByte ( const char* pInBuffer,  const size_t iSize )
{ 
	m_pItem = new BufferParseContainer ( pInBuffer, iSize );
}

ObjByte::ObjByte (  string sFileName )
{ 
	m_pItem = new FileParseContainer ( sFileName, PARSER_MAX_READ_CHUNK );
}

ObjByte::~ObjByte () 
{ 
	delete m_pItem; 
} 

ParseItemType ObjByte::getType()  
{ 
	return TypeByte; 
} 
	
void ObjByte::serialize ( char* pOutbuffer,  uint32_t &iSize )
{
	m_pItem->serialize(  pOutbuffer,  iSize );
}

void ObjByte::serialize ( Stream* pOutstream )
{
	m_pItem->serialize( pOutstream );	
}

void ObjByte::parse ( const char* pBuffer, const uint32_t iSize )
{
	delete m_pItem; 
		
	m_pItem = new BufferParseContainer ( pBuffer, iSize );
	
}
	
ObjParseContainer* ObjByte::getValue () 
{ 
	return m_pItem; 
}

size_t ObjByte::getSize () 
{ 
	return m_pItem->getSize(); 
}


