/*
 * File:   Thread.hpp
 * Author: Panik Tesniyom
 *
 * Created on July 13, 2009
 */

#ifndef _CTHREAD_H
#define	_CTHREAD_H

#include <cstdlib>
#include "functor.h"
#include <condition_variable.h>

namespace Thread
{
    class cThreadFactory;

    /**
        * Platform independent thread class. To create an implementation for
        * a new platform you need to:
        *
        * 1. Create a seperate file for the implementation
        *
        * 2. Implement the virtual methods
        *      - start method
        *      - join method
        *      - sleep method
        *
        * 3. Include that implementation when compiled for the new platform
        *    either by using the build system ( prefered ) or the preprocessor
        *
        */
    class cThread
    {
    protected:            
        cFunctor*        m_functor;
        cThreadFactory*  m_factInstance;
            
        /**
        * Constructor
        *
        * @param ftFactory    Pointer to the factory
        */
		cThread ( cThreadFactory *ftFactory =   NULL ); 

	
    public:

        /**
        * Destructor
        *
        */
		virtual ~cThread ( void );

        /**
        * Starts the thread
        *
        * @param f     Pointer to the functor to invoke in
        *              the thread.
        */
        virtual void start ( cFunctor *f ) = 0;


        /**
        * Joins the thread, virtual
        *
        */
        virtual int join ( void ) = 0;


        /**
        * Puts the thread to sleep, virtual
        *
        * @param ms    The number of miliseconds to put the
        *              thread to sleep.
        */
        static void sleep ( unsigned int ms );

		/**
		* Creating a new Thread;
		*/
		static cThread* createThread();

    };
}


#endif	
