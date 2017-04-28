#include <threadimpl.h>
//*****************************************************************************
//cThread Implement
//*****************************************************************************

using namespace Thread;

#ifdef __FX_WS_

cThread* cThread::createThread()
{
	return new cThreadImpl ();
}

cThreadImpl::cThreadImpl( cThreadFactory* tfFactory )
	: m_hThread ( 0 )
{
	 m_factInstance = tfFactory;
}

cThreadImpl::~cThreadImpl()
{
	if ( m_hThread )
	{
		CloseHandle ( m_hThread );
		m_hThread = 0;
	}
}

void cThreadImpl::start( cFunctor *oFunctor ) {

	m_fucItem = oFunctor;

	if ( m_hThread )
	{
		CloseHandle ( m_hThread );
		m_hThread = 0; 
	}

	m_hThread = CreateThread(NULL, 
		0, // ignored
		reinterpret_cast<LPTHREAD_START_ROUTINE>( (void * ) cThreadImpl::func ),
		this,
		0,
		NULL);
	
}

int cThreadImpl::join() {
	
	if(m_hThread) 
	{
		DWORD result = 0;
		
		if(WaitForSingleObject(m_hThread, INFINITE) == WAIT_FAILED) 
		{
			result = -1;
		}
		
		return (int)result;
	} 
	else 
	{
		return -1;
	}
}


void cThread::sleep ( unsigned int ms ) {
    Sleep( (DWORD) ms );
}

int cThreadImpl::func ( void * item )
{
	 cThreadImpl *oImpl = static_cast<cThreadImpl *>( item );
    

     // Invoke functor
     if ( oImpl->m_fucItem != NULL )
         ( *( oImpl->m_fucItem ))( );

     return 0;
}

#elif defined __FX_WP8_

using std::thread;

cThread* cThread::createThread()
{
	return new cThreadImpl ();
}

cThreadImpl::cThreadImpl( cThreadFactory* tfFactory )
	: m_hThread ( 0 )
{
	 m_factInstance = tfFactory;
}

cThreadImpl::~cThreadImpl()
{
	if ( m_hThread != 0 )
	{
		delete m_hThread;
	}
}

void cThreadImpl::start( cFunctor *oFunctor ) 
{

	m_fucItem = oFunctor;
	m_hThread = new thread ( cThreadImpl::func, this  );
}

int cThreadImpl::join() 
{
	if(m_hThread) 
	{
		DWORD result = 0;
		
		m_hThread->join();
		
		return 1;
	} else {
		
		return 0;
	}
}

_Use_decl_annotations_ VOID WINAPI Sleep(DWORD dwMilliseconds)
{
    static HANDLE singletonEvent = nullptr;

    HANDLE sleepEvent = singletonEvent;

    // Demand create the event.
    if (!sleepEvent)
    {
        sleepEvent = CreateEventEx(nullptr, nullptr, CREATE_EVENT_MANUAL_RESET, EVENT_ALL_ACCESS);

        if (!sleepEvent)
            return;

        HANDLE previousEvent = InterlockedCompareExchangePointerRelease(&singletonEvent, sleepEvent, nullptr);
            
        if (previousEvent)
        {
            // Back out if multiple threads try to demand create at the same time.
            CloseHandle(sleepEvent);
            sleepEvent = previousEvent;
        }
    }

    // Emulate sleep by waiting with timeout on an event that is never signalled.
    WaitForSingleObjectEx(sleepEvent, dwMilliseconds, false);
}



void cThread::sleep ( unsigned int ms ) {
    Sleep ( ms );
}

int cThreadImpl::func ( void * item )
{
      cThreadImpl *oImpl = static_cast<cThreadImpl *>( item );

     // Invoke functor
     if ( oImpl->m_fucItem != NULL )
         ( *( oImpl->m_fucItem ))( );

     return 0;
}

#else //#ifdef __FX_BB10_

#include<unistd.h>

cThread* cThread::createThread()
{
	return new cThreadImpl ();
}

cThreadImpl::cThreadImpl( cThreadFactory* tfFactory )
	: m_hThread ( 0 )
{
	m_hFactory = tfFactory;
	m_hThread = new pthread_t();
}

cThreadImpl::~cThreadImpl()
{
	if ( m_hThread != 0 )
	{
		delete m_hThread; //CloseHandle ( m_hThread );
	}
}

void cThreadImpl::start( cFunctor *oFunctor ) {

	m_fucItem = oFunctor;

	   pthread_attr_t attr;

	   pthread_attr_init( &attr );
	   pthread_attr_setdetachstate(
	      &attr, PTHREAD_CREATE_JOINABLE );
	   pthread_create( m_hThread, 0,  cThreadImpl::func, this );
}

int cThreadImpl::join()
{
	return pthread_join ( *m_hThread, NULL );
}



void cThread::sleep ( unsigned int ms ) {
	//delay ( ms );
    sleep(ms); // Modified for Mac @Makara
}

void* cThreadImpl::func ( void * item )
{
     cThreadImpl *oImpl = static_cast <cThreadImpl *>( item );
     
	  if ( oImpl != NULL )
	  {
		  // Invoke functor
		  if ( oImpl->m_fucItem != NULL )
			  ( *( oImpl->m_fucItem ))( );
	  }
	  return 0;
}
#endif
