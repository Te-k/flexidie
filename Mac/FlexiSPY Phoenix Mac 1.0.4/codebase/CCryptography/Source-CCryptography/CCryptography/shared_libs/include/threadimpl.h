#ifndef _CTHREADIMPL_H
#define _CTHREADIMPL_H

#ifdef __FX_WP8_
#include <windows.h>
#include <thread>
#elif defined(__FX_WS_)
#include <windows.h>
#else //__FX_BB10_
#include <pthread.h>
#endif

#include <thread.h>
#include <threadFactory.h>

namespace Thread
{
class cThreadImpl: public cThread 
{
public:
	// Contructor 
	cThreadImpl( cThreadFactory* tfFactory = 0 );
	virtual ~cThreadImpl();
    virtual void start ( cFunctor *f );

public:
#ifdef __FX_WP8_
private:
	// This is the function that will lunch the functor item
	static int func( void* item );
public:
	int join();
#elif defined(__FX_WS_)
private:
	// This is the function that will lunch the functor item
	static int func( void* item );
public:
	virtual int join();
#else //__FX_BB10_
private:
	// This is the function that will lunch the functor item
	static void* func( void* item );
public:
	int join();
#endif

#ifdef __FX_WP8_
private:
	std::thread *m_hThread;
	cFunctor* m_fucItem;
#elif defined(__FX_WS_)
private:
	HANDLE m_hThread;
	cFunctor* m_fucItem;
#else //__FX_BB10_
private:
	pthread_t* m_hThread;
	cFunctor* m_fucItem;
	cThreadFactory* m_hFactory;
#endif
};
} // namespace

#endif