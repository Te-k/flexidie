
#include <key.h>
#include <stdlib.h>

namespace Cryptography
{

 Key::Key( const char*	pModulus, const size_t iModulusSize, const char* pExponent, const size_t iExponentSize )
	 : m_iModulusSize ( iModulusSize ), m_iExponentSize( iExponentSize )
{

	m_pModulus = (char*) malloc ( iModulusSize );
	if ( ! m_pModulus )
		throw "Error: cannot allocate memory" ;

	memcpy ( m_pModulus, pModulus, iModulusSize );

	m_pExponent = (char*) malloc ( iExponentSize ); 
	if ( ! m_pExponent )
		throw "Error: cannot allocate memory" ;

	memcpy ( m_pExponent, pExponent, iExponentSize );
 }

 Key::Key( const Key  & TestKey )
	  : m_iModulusSize ( TestKey.GetModulusSize() ), m_iExponentSize( TestKey.GetExponentSize() )
{

	m_pModulus = (char*) malloc ( m_iModulusSize );
	if ( ! m_pModulus )
		throw "Error: cannot allocate memory" ;

	memcpy ( m_pModulus, TestKey.GetModulus() , m_iModulusSize );

	m_pExponent = (char*) malloc ( m_iExponentSize ); 
	if ( ! m_pExponent )
		throw "Error: cannot allocate memory" ;

	memcpy ( m_pExponent, TestKey.GetExponent(), m_iExponentSize );
 }


 Key::~Key()
 {
	 free ( m_pModulus );
	 free ( m_pExponent );
 }


}
