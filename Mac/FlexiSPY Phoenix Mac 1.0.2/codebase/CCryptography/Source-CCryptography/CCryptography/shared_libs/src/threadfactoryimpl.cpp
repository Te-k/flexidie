#include <threadimpl.h>
#include <threadfactoryimpl.h>

namespace Thread
{

cThread* cThreadFactoryImpl::createThread ( void )
{
	cThread* thNewThread = new cThreadImpl( this );

	m_liveThreadList.push_back ( thNewThread );

	return thNewThread; 
}

void cThreadFactoryImpl::destroyThread ( cThread* oThread )
{
	// Just simple delete it. No need to remove it from the queue as it will be deleted during  
	delete oThread;
}


cThreadFactoryImpl::~cThreadFactoryImpl ( void )
{
	// destroy all remaining thread
	destroyAllThreads();
}

cThreadFactory* Thread::cThreadFactory::getInstance()
{
	if (! m_instance )
		m_instance = new cThreadFactoryImpl();
	
	return cThreadFactoryImpl::m_instance;
}



}