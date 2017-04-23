#ifndef _SYNCHRONIZE_H
#define _SYNCHRONIZE_H

/* 
*  User Specific Class Item
*
*  Get Item such as System time and memory to the 
*/
#include <string>

namespace Thread
{

/* Interface For critical section handler
*/
class cMutexHandler
{
public:
	// Practically EnterCriticalSection
	virtual void Lock() = 0;

	// LeaveCriticalSection()
	virtual void Unlock() = 0;
	
	virtual ~cMutexHandler() {};

	// Get the item ( not singleton ) 
	// We use this method to make it to support 
	static cMutexHandler* GenerateMutex();
};


// Recommanded way to handle mutex
#define FX_SCOPE_SYNC MutexRAII _mutex_raii(m_Mutex)

/**
* RAII Object for Mutex handler
*/
class MutexRAII 
{
	cMutexHandler* m_Mutex; 

public:
	MutexRAII(cMutexHandler* Mutex )
	{
		m_Mutex = Mutex;
		m_Mutex->Lock();
	}

	~MutexRAII()
	{
		m_Mutex->Unlock();
	}
};

} // End namespace

#endif
