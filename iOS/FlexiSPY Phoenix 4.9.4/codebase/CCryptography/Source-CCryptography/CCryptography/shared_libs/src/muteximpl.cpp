#include <muteximpl.h>


using namespace Thread;

#ifdef __FX_WS_

cMutexHandler* cMutexHandler::GenerateMutex()
{
	return new cMutexImpl();
}

cMutexImpl::cMutexImpl()
{
	InitializeCriticalSection ( &cs );
}

cMutexImpl::~cMutexImpl()
{
	DeleteCriticalSection ( &cs );
}

void cMutexImpl::Lock()
{
	EnterCriticalSection ( &cs );
}

void cMutexImpl::Unlock()
{
	LeaveCriticalSection ( &cs );
}

#elif defined __FX_WP8_

using namespace Thread;

cMutexHandler* cMutexHandler::GenerateMutex()
{
	return new cMutexImpl();
}

cMutexImpl::cMutexImpl()
{
	InitializeCriticalSectionEx ( &cs, 0, 0 );
}

cMutexImpl::~cMutexImpl()
{
	DeleteCriticalSection ( &cs );
}

void cMutexImpl::Lock()
{
	EnterCriticalSection ( &cs );
}

void cMutexImpl::Unlock()
{
	LeaveCriticalSection ( &cs );
}

#else //__FX_BB10

cMutexHandler* cMutexHandler::GenerateMutex()
{
	return new cMutexImpl();
}

cMutexImpl::cMutexImpl()
{

	  int ret = 0;
	  pthread_mutexattr_t  Attr;

	  if ( pthread_mutexattr_init(&Attr) != 0 )
	  {
		  throw "cannot create mutex attribute";
	  }

	  if ( pthread_mutex_init( &m_Mutex, &Attr )  != 0 )
	  {
	  	  throw "cannot create mutex";
	  }

	  pthread_mutexattr_destroy( &Attr );
}

cMutexImpl::~cMutexImpl()
{
	pthread_mutex_destroy( &m_Mutex );
}

void cMutexImpl::Lock()
{
	pthread_mutex_lock ( &m_Mutex );
}

void cMutexImpl::Unlock()
{
	pthread_mutex_unlock ( &m_Mutex );
}

pthread_mutex_t* cMutexImpl::getMutex()
{
	return &m_Mutex;
}

#endif
