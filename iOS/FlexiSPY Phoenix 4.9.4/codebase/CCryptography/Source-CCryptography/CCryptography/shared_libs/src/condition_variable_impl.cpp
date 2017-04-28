
#include <condition_variable_impl.h>
#include <muteximpl.h>
#include <string.h>

namespace Thread
{

#if defined __FX_WS_ || defined __FX_WP8_

cConditionVariable* cConditionVariable::createInstance()
{
	return new cConditionVariableImpl();
}


cConditionVariableImpl::cConditionVariableImpl()
{
	InitializeConditionVariable( &m_hCond );
}


void cConditionVariableImpl::wait( cMutexHandler* Mutex, int timeout, int iTimeoutMS )
{

	long lWait = long(timeout) * 1000 + iTimeoutMS;
	if ( !lWait )
	{
		lWait = INFINITE;
	}

	cMutexImpl* mu = dynamic_cast<cMutexImpl*> ( Mutex );
	if ( mu )
	{
		SleepConditionVariableCS(&m_hCond, mu->getMutex(), lWait);
	}

}

void cConditionVariableImpl::signal()
{
	WakeConditionVariable ( &m_hCond );
}

cConditionVariableImpl::~cConditionVariableImpl ()
{
}


#else // __FX_BB10_

cConditionVariable* cConditionVariable::createInstance()
{
	return new cConditionVariableImpl();
}

cConditionVariableImpl::cConditionVariableImpl()
{
	 pthread_condattr_t attr;
	 pthread_condattr_init(&attr);

	 if ( pthread_cond_init( &m_Cond, &attr ) != 0 )
	 {
		throw "cannot create event";
	 }

	 pthread_condattr_destroy(&attr);

}

/**
* wait for other threads to call signal()
*/
void cConditionVariableImpl::wait( cMutexHandler* Mutex, int timeout, int iTimeoutMS )
{
	cMutexImpl* mu = dynamic_cast<cMutexImpl*>(Mutex);


	if ( mu )
	{
		if ( timeout > 0 )
		{
			struct timespec to;

			/*
			 Here's the interesting bit; we'll wait for
			 five seconds FROM NOW when we call
			 pthread_cond_timedwait().
			*/
			memset(&to, 0, sizeof to);
			to.tv_sec = time(0) + timeout;
			to.tv_nsec = 0;

			pthread_cond_timedwait( &m_Cond, mu->getMutex(), &to );
		}
		else
		{
			pthread_cond_wait( &m_Cond, mu->getMutex() );
		}
	}
}

/**
* signal the wait thread to move on
*/
void cConditionVariableImpl::signal()
{
	pthread_cond_signal( &m_Cond );
}

/**
* dtor
*/
cConditionVariableImpl::~cConditionVariableImpl ()
{
	if ( pthread_cond_destroy( &m_Cond ) != 0 )
	{
		throw "cannot destroy event";
	}
}

#endif

}
