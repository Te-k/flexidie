#ifndef _BUFFER_H
#define _BUFFER_H

#include <stdio.h>
#include <string.h>
#include <filesystem.h>
#include <string>
// buffer class
// handle the buffer

class Buffer  
{
	// buffer data
	char* m_pData;

	//size of the buffer
	size_t m_iSize;

	// do not allow normal user to use default constructor
	Buffer () {};

public:
	
	/**
	* return the buffer
	*/
	const char* getData () const { return m_pData; };


	/*
	* append the buffer with another buffer
	*/
	void append ( Buffer* const sBuff ) 
	{
		char* ret = new char[m_iSize +  sBuff->getSize()];

		memcpy ( ret, m_pData, m_iSize);
		memcpy ( ret + m_iSize, sBuff->getData(), sBuff->getSize());

		delete [] m_pData;
		m_pData = ret;
	}

		
	/**
	* return the size
	*/
	size_t getSize () const { return m_iSize; };


	/**
	* ctor
	*/
	Buffer ( char* pData, size_t iSize ) { m_pData = new char[iSize]; memcpy(m_pData, pData, iSize); m_iSize = iSize;}

	/**
	* ctor
	*/
	Buffer ( const char* pData, const size_t iSize ) { m_pData = new char[iSize]; memcpy(m_pData, pData, iSize); m_iSize = iSize;}

	/**
	* copy ctor
	*/
	Buffer ( Buffer const & input ) { m_iSize = input.getSize(); m_pData = new char[m_iSize]; memcpy(m_pData, input.getData() , m_iSize);  } 


	/**
	* Initialize from file
	*/
	Buffer ( std::string sFileName )
	{
		Stream* st = FileSystem::open( sFileName.c_str(), FileSystem::READ );
		if (! st )
		{
			throw "can't open the file";
		}

		m_iSize = st->length();;
		m_pData = new char [m_iSize];
		
		size_t iRetSize = st->read ( m_pData, 1, m_iSize );
		if ( iRetSize != m_iSize )
		{
			throw "can't read the file";
		}
		
		st->close();
		delete st;

	}

	static Buffer* transferOwnerFrom ( char* sBuff, size_t iSize  )
	{
		Buffer* pNewBuffer = new Buffer ();
		pNewBuffer->m_pData = sBuff;
		pNewBuffer->m_iSize = iSize;

		return pNewBuffer;
	}

	/**
	* dtor
	*/
	virtual ~Buffer() { delete [] m_pData; }
};

#endif