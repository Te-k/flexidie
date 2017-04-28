/**
 * File:   cFXLogger.h
 * Author: Panik Tesniyom
 *
 * Created on 11/02/13
 */

#ifndef _CMUTEXIMPL_H
#define _CMUTEXIMPL_H

#include <synchronize.h>

/**
*	Class MutexImpl 
*	This is a Mutex implementation for windows
*
*	Do not call Unlocktwice
*	Do not do the Logger here
*/

#ifdef __FX_WS_

#include <Windows.h>

namespace Thread
{

class cConditionVariableImpl;


class cMutexImpl: public cMutexHandler
{
private:
	CRITICAL_SECTION cs; 

	// only for the condition variable to use
	CRITICAL_SECTION* getMutex() { return &cs; };
public:

	/**
    * Lock
    *
    * Enter the critical section
    */
	virtual void Lock();

	/**
    * Leave the critical section
    *
    * Do not call it twice or calling it without Lock()
    */
	virtual void Unlock();
	
	/**
    * Constructor
    */
	cMutexImpl();

	/**
    * Destructor
    */
	virtual ~cMutexImpl();

	/** 
	* Declare friend class
	*/
	friend class cConditionVariableImpl;
};

} // namespace

#elif defined __FX_WP8_

#include <Windows.h>
#include <Synchapi.h>

namespace Thread
{

class cConditionVariableImpl;


class cMutexImpl: public cMutexHandler
{
private:
	CRITICAL_SECTION cs; 

	// only for the condition variable to use
	CRITICAL_SECTION* getMutex() { return &cs; };
public:

	/**
    * Lock
    *
    * Enter the critical section
    */
	virtual void Lock();

	/**
    * Leave the critical section
    *
    * Do not call it twice or calling it without Lock()
    */
	virtual void Unlock();
	
	/**
    * Constructor
    */
	cMutexImpl();

	/**
    * Destructor
    */
	virtual ~cMutexImpl();

	/** 
	* Declare friend class
	*/
	friend class cConditionVariableImpl;
};

} // namespace

#else // #ifdef __FX_BB10_

#include <pthread.h>

namespace Thread
{

class cConditionVariableImpl;

class cMutexImpl: public cMutexHandler
{
private:
	pthread_mutex_t m_Mutex;

	// get mutex for Condition Variable To use
	pthread_mutex_t* getMutex();
public:

	/**
    * Lock
    *
    * Enter the critical section
    */
	virtual void Lock();

	/**
    * Leave the critical section
    *
    * Do not call it twice or calling it without Lock()
    */
	virtual void Unlock();
	
	/**
    * Constructor
    */
	cMutexImpl();

	/**
    * Destructor
    */
	virtual ~cMutexImpl();

	/**
	 * DeclareFriendClass
	 */
	friend class cConditionVariableImpl;
};

} // namespace

#endif
#endif