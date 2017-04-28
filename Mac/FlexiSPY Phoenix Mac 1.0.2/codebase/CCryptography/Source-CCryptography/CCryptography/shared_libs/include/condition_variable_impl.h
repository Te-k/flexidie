#ifndef _CONDITION_VARIABLE_IMPL_H
#define _CONDITION_VARIABLE_IMPL_H

#include <condition_variable.h>
#include <synchronize.h>

#if defined __FX_WS_ || defined __FX_WP8_

#include <windows.h>

namespace Thread
{

class cConditionVariableImpl: public cConditionVariable
{
private:
	CONDITION_VARIABLE m_hCond;
	
public:
	
	cConditionVariableImpl() ;
	

	/**
	* wait for other threads to call signal()
	*/
	virtual void wait( cMutexHandler* Mutex, int iTimeout, int iTimeoutMS = 0 );

	/**
	* signal the wait thread to move on
	*/
	virtual void signal();

	/**
	* dtor
	*/
	virtual ~cConditionVariableImpl () ;
};

}




#else //__FX_BB10_


#include <condition_variable.h>
#include <pthread.h>
#include <synchronize.h>

namespace Thread
{

class cConditionVariableImpl: public cConditionVariable
{
private:
	  pthread_cond_t m_Cond;

public:
	
	cConditionVariableImpl();


	/**
	* wait for other threads to call signal()
	*/
	virtual void wait( cMutexHandler* Mutex, int timeout = 0, int iTimeoutMS = 0  );

	/**
	* signal the wait thread to move on
	*/
	virtual void signal();

	/**
	* dtor
	*/
	virtual ~cConditionVariableImpl ();
};

}

#endif

#endif