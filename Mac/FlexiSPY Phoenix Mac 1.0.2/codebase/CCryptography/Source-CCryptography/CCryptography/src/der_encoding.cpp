#include <der_encoding.h>

using namespace Cryptography;

cDerEncoding::cDerEncoding()
	: m_lCurIdx (0)
{
	// nothing for now
}

cDerEncoding::~cDerEncoding()
{
	// nothing for now
}


void cDerEncoding::registerListener ( IEncodingListener * oListener ) 
{
	m_vecListeners.push_back ( oListener );
}


void cDerEncoding::decode ( const char* arrData, const size_t szSize )
{
	size_t szChildSize = 0;

	cDerNode* pDecodedNode = cNodeFactory::generateNode ( arrData, szSize, szChildSize, this );

	// Currently we only use information from the callback and dont' actually used the result note, so delete it.
	delete pDecodedNode;
}


void cDerEncoding::OnItemFound ( int16_t iType, char * arrData, size_t szSize )
{
	std::vector<IEncodingListener*>::iterator it = m_vecListeners.begin();

	
	for ( ; it != m_vecListeners.end(); it++ )
	{
		(*it)->OnDataFound ( m_lCurIdx, arrData, szSize );
	}
	m_lCurIdx ++;
}

/** Will generate object node based on item type.
*/

cDerNode* cNodeFactory::generateNode ( const char* pInput, 
									  size_t szSize, 
									  size_t & szChildSize,
									  IDerNodeListener* oListener )
{
	char iType = pInput[0];
	cDecodingException exptn; 
	size_t szNewSize = 0;

	cDerNode* pNewNode = 0;
	// Sequence
	if ( iType == 0x30 )
	{
		szNewSize = (size_t) pInput[1];
		if ( szNewSize > szSize - 2 )
		{
			// The size of the child must not be more than parent
			throw exptn;
		}

		// total child size = item size + header ( 2 bytes )
		szChildSize = szNewSize + 2;
		pNewNode = new cSequenceNode ( pInput + 2, szNewSize, oListener );
	}
	else if ( iType == 0x00 ) //reserved bit
	{
		// reserved, just skip
		szNewSize = 0;
		if ( szNewSize > szSize - 1 )
		{
			// The size of the child must not be more than parent
			throw exptn;
		}

		szChildSize = szNewSize + 1;
	}
	else if ( iType == 0x02 ) //Integer
	{
		szNewSize = (size_t) pInput[1];
		if ( szNewSize > szSize - 2 )
		{
			// The size of the child must not be more than parent
			throw exptn;
		}

		szChildSize = szNewSize + 2;
		pNewNode = new cIntegerNode ( pInput + 2, szNewSize, oListener  );
	}
	else if ( iType == 0x03 ) //bitstring, similar to sequence but has 1 unused bit
	{
		szNewSize = (size_t) pInput[1];
		if ( szNewSize > szSize - 2 )
		{
			
			// The size of the child must not be more than parent
			throw exptn;
		}

		szChildSize = szNewSize + 2;	
		pNewNode = new cSequenceNode ( pInput + 2, szNewSize, oListener  );
	
	}
	else if ( iType == 0x06 ) //Object Id
	{
		szNewSize = (size_t) pInput[1];
		if ( szNewSize > szSize - 2 )
		{
			// The size of the child must not be more than parent
			throw exptn;
		}

		szChildSize = szNewSize + 2;
		pNewNode = new cObjectIdNode ( pInput + 2, szNewSize, oListener  );
	}
	else if ( iType == 0x05 ) //NULL
	{
		szNewSize = (size_t) pInput[1];
		if ( szNewSize > szSize - 2 )
		{
			// The size of the child must not be more than parent
			throw exptn;
		}

		szChildSize = szNewSize + 2;
		pNewNode = new cNullNode ( pInput + 2, szNewSize, oListener  );
	}
	else 
	{
		// unsupported type
		throw exptn;
	}
	
	// Return size and node
	return pNewNode;
	
}
	

cNullNode::cNullNode ( const char* iInput, size_t szSize, IDerNodeListener* oListener  )
{
	// it's null
}

cSequenceNode::cSequenceNode ( const char* iInput, size_t szSize, IDerNodeListener* oListener  )
{

	cDecodingException exptn; 
	size_t szRemaining = szSize;
	size_t szChildSize = 0;

	// squence note should not be less than 2
	if ( szRemaining < 2 )
		throw exptn;

	size_t szOffset = 0;
	while ( szRemaining > 0 )
	{
		szChildSize = 0;
		cDerNode* nChild = cNodeFactory::generateNode ( iInput + szOffset, szRemaining, szChildSize, oListener  );
	
		// deduct the remaining
		szRemaining -= szChildSize;
		szOffset += szChildSize;

		// Size error;
		if ( szChildSize <= 0 || szRemaining < 0 )
			throw exptn;
		
		if ( nChild != 0 )
			m_arrItems.push_back ( nChild );
	}
	
}

cSequenceNode::~cSequenceNode ()
{
	std::vector<cDerNode*>::iterator it = m_arrItems.begin();
	for ( ; it != m_arrItems.end(); it++ )
	{
		delete (*it);
		(*it) = 0;
	}

	m_arrItems.clear();

}

cObjectIdNode::cObjectIdNode  ( const char* iInput, size_t szSize, IDerNodeListener* oListener  )
		: m_arrItems(0)
{
	cDecodingException exptn; 
	m_arrItems = new char[ szSize ];

	memcpy ( m_arrItems, iInput, szSize * sizeof (char ));

	// fire to the listener
	oListener->OnItemFound( 0x06, m_arrItems, szSize );
}


cObjectIdNode::~cObjectIdNode  ( )
{
	if ( m_arrItems != 0 )
		delete [] m_arrItems;

}

cIntegerNode::cIntegerNode  ( const char* iInput, size_t szSize, IDerNodeListener* oListener  )
	: m_arrItems(0)
{
	cDecodingException exptn; 
	m_arrItems = new char[ szSize ];

	memcpy ( m_arrItems, iInput, szSize );

	oListener->OnItemFound( 0x02, m_arrItems, szSize );

}


cIntegerNode::~cIntegerNode  ( )
{
	if ( m_arrItems != 0 )
		delete [] m_arrItems;

}


