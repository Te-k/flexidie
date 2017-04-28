 #include <fx_leak_debug.h>

#include "parse_object.h"

/** 
* floating point and double object
*/

ObjFloat::ObjFloat ( const double item, int iSize )
{ 
	if ( iSize == sizeof ( float ) )
	{
		m_Item._float = ( float )item; 
	}
	else if ( iSize == sizeof ( double ) )
	{
		m_Item._double = item; 
	}

	m_iSize = iSize; 
}

ParseItemType ObjFloat::getType()  
{ 
	return TypeUInt; 
} 

// Serialize using big-endian ( the server is Java );
// Since the c++ is little endian, we will need to reverse the item.
void ObjFloat::serialize ( char* output_buffer,  uint32_t &item_size )
{
	item_size = m_iSize;

	if ( item_size == sizeof ( float ) )
	{
		float FlostItem = m_Item._float;
		for ( uint32_t i = 0; i < item_size; i ++ )
		{
			output_buffer [item_size - i - 1] = *( reinterpret_cast<char*>(&FlostItem) + i);
		}
	}
	else if ( item_size ==  sizeof ( double )  )
	{
		double DoubleItem = m_Item._double;
		for ( uint32_t i = 0; i < item_size; i ++ )
		{
			output_buffer [item_size - i - 1] = *( reinterpret_cast<char*>(&DoubleItem) + i );
		}
	}
	else 
	{
		// can't match item
		item_size = 0;
	}
}

void ObjFloat::serialize ( Stream* pOutstream )
{
	char* pBuffer = new char[m_iSize];

	serialize ( pBuffer,  m_iSize );

	pOutstream->write ( pBuffer, 1, m_iSize );
	
	delete [] pBuffer;
}

// parse item
// c++ and Java use different endian so we will swap the bits.
void ObjFloat::parse ( const char* input_buffer, const uint32_t input_size )
{
	
	if ( input_size != sizeof ( float )  && input_size != sizeof ( double ) ) 
		throw StringException ( "this item is neither float or double" );

	m_iSize = input_size;

	if ( input_size == sizeof ( float ) )
	{
		float Output;

		for ( uint32_t i = 0; i < input_size; i ++ )
		{
			 *( reinterpret_cast<char*>(&Output) + i ) = input_buffer [input_size - i - 1];
		}
		
	    m_Item._float = Output;
	}
	else if ( input_size == sizeof ( double ) )
	{
		double Output;

		for ( uint32_t i = 0; i < input_size; i ++ )
		{
			 *( reinterpret_cast<char*>(&Output) + i ) = input_buffer [input_size - i - 1];
		}
		
		m_Item._double = Output;
	}
}
	
float ObjFloat::getFloatValue () 
{ 
	return m_Item._float; 
}; 

double ObjFloat::getDoubleValue () 
{ 
	return m_Item._double; 
}; 



