#ifndef _CONDITION_VARIABLE_H
#define _CONDITION_VARIABLE_H

namespace Thread
{

class cMutexHandler;

class cConditionVariable
{
public:
	static cConditionVariable* createInstance();

	/**
	* wait for other threads to call signal()
	*/
	virtual void wait( cMutexHandler* Mutex, int timeout, int iTimeoutMS = 0 ) = 0;

	/**
	* signal the wait thread to move on
	*/
	virtual void signal() = 0;

	/**
	* dtor
	*/
	virtual ~cConditionVariable () {};
};

}

#endif
