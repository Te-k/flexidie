
#ifndef _PARSE_OBJECT_H
#define _PARSE_OBJECT_H

#include "string"
#include "stdint.h"
#include "list"
#include "filesystem.h"
#include "buffer.h"
#include "component_exception.h"

#define USE_COMMAND_SPEC static const int ColumnCount; static const MessageColumn Spec[]; 

#define PARSER_MAX_READ_CHUNK 100000

enum ParseItemType 
{
	TypeUInt = 0,
	TypeString = 1,
	TypeStringSize = 2,
	TypeByte = 3,
	TypeByteSize = 4,
	TypeCommand = 5,
	TypeCommandSize = 6,
	TypeFloat = 7
};

struct MessageColumn
{
	std::string Name;
	ParseItemType Type;
	int16_t Size;
};

class ParseObj
{
public:

	// get the type
	virtual ParseItemType getType() = 0;

	// serialize data to char buffer
	virtual void serialize ( char* pOutbuffer,  uint32_t &iSize ) = 0;
	
	// serialize to file stream
	virtual void serialize ( Stream* pOutstream ) = 0;
	
	// parse from byte data
	virtual void parse ( const char* pBuffer, const uint32_t iSize ) = 0;
	
	// virtua; dtor
	virtual  ~ParseObj() {};
};

class ObjUInt : public ParseObj
{
private:
	uint32_t m_Item;
	bool m_bBigEndian; 
	uint32_t m_iSize;

public:

	// ctor
	ObjUInt( const bool bBigEndian = false, const uint32_t item = 0, const int16_t iSize = 0 ); 

	// dtor
	virtual ParseItemType getType();
	
	/**
	* Serialize to byte buffer
	* The output buffer needs to be allocated beforehand.
	*
	* @param OutputBuffer [In/Out] the buffer to write the data in.
	* @param Size	[Out]		The size.
	*/
	virtual void serialize ( char* pOutbuffer,  uint32_t &iSize );

	// serialize to file stream
	virtual void serialize ( Stream* pOutstream );

	// parse buffser data
	virtual void parse ( const char* pBuffer, const uint32_t iSize );
	
	// get the int value
	uint32_t getValue (); 

};


class ObjFloat : public ParseObj
{
union floatType
{
  float _float;
  double _double;
};


private:
	floatType m_Item;
	uint32_t m_iSize;

public:

	// ctor
	ObjFloat( const double item, int iSize = 4 ); 

	// dtor
	virtual ParseItemType getType();
	
	/**
	* Serialize to byte buffer
	* The output buffer needs to be allocated beforehand.
	*
	* @param OutputBuffer [In/Out] the buffer to write the data in.
	* @param Size	[Out]		The size.
	*/
	virtual void serialize ( char* output_buffer,  uint32_t &size );

	// serialize to file stream
	virtual void serialize ( Stream* output_stream );

	// parse buffser data
	virtual void parse ( const char* input_buffer, const uint32_t size );
	
	// get the int value
	float getFloatValue (); 
	
	// get the d value
	double getDoubleValue (); 

};


class ObjStringSize : public ParseObj
{
private:
	uint32_t m_iItem;
	uint32_t m_iSize;
	bool m_bBigEndian; 

public:

	/**
	* ctor
	*
	* @param iSize Size is the size of the size bit ( usually just 1 or 2 bytes ).
	*/
	ObjStringSize ( const bool bBigEndian = false, const int16_t iSize = 0, const std::string sItem = "");

	// serialize to byte array
	virtual void serialize ( char* pOutbuffer,  uint32_t &iSize );
	
	// serialize to file stream
	virtual void serialize ( Stream* pOutstream );

	// parse data from byte array
	virtual void parse ( const char* pBuffer, const uint32_t iSize );

	// return "stringsize"
	virtual ParseItemType getType();

	// get value
	uint32_t getValue (); 

};



class ObjString : public ParseObj
{
private:
	std::string m_sItem;
	
public:

	//ctor
	ObjString ( std::string sItem = "" ); 

	//return object string type
	virtual ParseItemType getType();
	
	/**
	* Serialize to byte stream
	* The output buffer needs to be allocated beforehand.
	*
	* @param OutputBuffer [In/Out] the buffer to write the data in.
	* @param Size	[Out]		The size.
	*/
	virtual void serialize ( char* pOutbuffer,  uint32_t &iSize );

	// serialize to file stream
	virtual void serialize ( Stream* pOutstream );

	// parse data from byte stream
	virtual void parse ( const char* pBuffer, const uint32_t iSize );
	
	// get value
	std::string getValue (); 

};



class ObjByteSize : public ParseObj
{
private:
	uint32_t m_iItem;
	uint32_t m_iSize;
	bool m_bBigEndian; 

public:

	/**
	* ctor
	*
	* @param iSize Size is the size of the size bit ( usually just 1 or 2 bytes ).
	*/
	ObjByteSize ( bool bBigEndian = false, int16_t iSizeOfSize = 0, uint32_t iItem = 0 );

	// serialize to byte buffer
	virtual void serialize ( char* pOutbuffer,  uint32_t &iSize );
	
	// serialize to file stream
	virtual void serialize ( Stream* pOutstream );
	
	// Parse item from byte buffer
	virtual void parse ( const char* pBuffer, const uint32_t iSize );

	// return Object byte size type
	virtual ParseItemType getType();

	// get the int value
	uint32_t getValue (); 

};


// container for buffer parse object
class ObjParseContainer
{
public:
	// return the size
	virtual size_t getSize() = 0;

	/**
	* Serialize to byte stream
	* The output buffer needs to be allocated beforehand.
	*
	* @param OutputBuffer [In/Out] the buffer to write the data in.
	* @param Size	[Out]		The size.
	*/
	virtual void serialize ( char* pOutbuffer,  uint32_t &iSize ) = 0;

	/**
	* Serialize to file stream
	*
	* @param pOutputStream output file stream
	*/
	virtual void serialize ( Stream* pOutstream ) = 0;

	/**
	* Get the buffer
	*/
	virtual const char* getBuffer () = 0;

	// dtor
	virtual ~ObjParseContainer(){};
};

class BufferParseContainer:public ObjParseContainer
{
	Buffer* m_pBuffer;

public:

	// ctor
	BufferParseContainer( const char* pInBuffer, const size_t iSize  )
	{
		m_pBuffer = new Buffer ( pInBuffer, iSize );
	}

	//dtir
	virtual ~BufferParseContainer(){ delete m_pBuffer; };

	// serialize to buffer array
	virtual void serialize ( char* pOutbuffer,  uint32_t &iSize )
	{
		memcpy ( pOutbuffer, m_pBuffer->getData(), m_pBuffer->getSize() );
		iSize = m_pBuffer->getSize();
	}

	// serialize to file stream
	virtual void serialize ( Stream* pOutstream )
	{
		pOutstream->write ( m_pBuffer->getData(), 1, m_pBuffer->getSize());
	}

	// get buffer data
	virtual const char* getBuffer () { return m_pBuffer->getData();} 

	// get buffer size
	virtual size_t getSize() { return m_pBuffer->getSize(); }

};


class FileParseContainer:public ObjParseContainer
{
	std::string m_pFileName;
	uint32_t m_iBlockSize;
public:
	// ctor
	FileParseContainer( std::string sFileName, uint32_t iBlockSize )
	{
		m_pFileName = sFileName;
		m_iBlockSize = iBlockSize;
	}

	// dtor
	virtual ~FileParseContainer(){};

	// get the size
	virtual size_t getSize() { return FileSystem::fileSize( m_pFileName.c_str() ) ; }

	//serialize data to byte array
	virtual void serialize ( char* pOutbuffer,  uint32_t &iSize )
	{
		Stream *st = FileSystem::open( m_pFileName.c_str(), FileSystem::READ );

		iSize = st->read( pOutbuffer, 1, getSize() );

		st->close();
		delete st;
	}

	// serialize data to file stream
	virtual void serialize ( Stream* pOutstream )
	{

		Stream *st = FileSystem::open( m_pFileName.c_str(), FileSystem::READ );
		if ( !st )
			throw ComponentException( COMP_ID_CSM, "Error: can't open payload files" );
		uint32_t iOutSize = 0;
		uint32_t iReadSize = 0;
		char* tmp = new char [ m_iBlockSize ];

		while (!st->eof())
		{
			iReadSize = st->read( tmp, 1, m_iBlockSize );
			iOutSize = pOutstream->write( tmp, 1, iReadSize );
			if ( !iOutSize) break;
		}

		delete [] tmp;

		st->close();
		delete st;
	}

	// get the buffer
	// currently it does not support file to buffer stuffs.
	virtual const char* getBuffer () { return 0; }

};


class ObjByte: public ParseObj
{
private:
	// container
	ObjParseContainer *m_pItem;

public:
	// ctor for buffer processing
	ObjByte ( const char* pOutbuffer = 0,  const size_t iSize = 0 );

	// for file processing
	ObjByte ( std::string sFileName );

	// dtor
	virtual ~ObjByte ();

	virtual ParseItemType getType();
	
	/**
	* Serialize to byte stream
	* The output buffer needs to be allocated beforehand.
	*
	* @param OutputBuffer [In/Out] the buffer to write the data in.
	* @param Size	[Out]		The size.
	*/
	virtual void serialize ( char* pOutbuffer,  uint32_t &iSize );

	/**
	* Serialize to file stream
	*
	* @param pOutputStream output file stream
	* @iSize pOutputSize
	*/
	virtual void serialize ( Stream* pOutstream );

	// parse item
	virtual void parse ( const char* pBuffer, const uint32_t iSize );
	
	// get the value
	ObjParseContainer* getValue (); 

	// get the size of the item
	size_t getSize (); 

};



#endif
