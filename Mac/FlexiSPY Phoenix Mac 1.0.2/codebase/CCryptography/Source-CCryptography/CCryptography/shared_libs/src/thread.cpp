#include <thread.h>
#include <threadfactory.h>

namespace Thread 
{



cThread::cThread ( cThreadFactory *ftFactory ) 
{
	m_factInstance = ftFactory; 
};


cThread::~cThread ( void ) 
{  
	if ( m_factInstance != NULL )
		m_factInstance->removeThread( this );
}

} //namespace