
/*
 * File:   cThreadFactory.cpp
 * Author: Panik Tesniyom
 *
 * Created on 11/02/2013
 */

#include <cstdlib>
#include <threadfactory.h>

using namespace Thread;

/**
 * Initialize singleton instance field
 */
cThreadFactory *cThreadFactory::m_instance = 0;


/**
 * Constructor
 *
 *
 */
cThreadFactory::cThreadFactory( void )
{

}


/**
 * Destructor
 *
 *
 */
cThreadFactory::~cThreadFactory( void )
{
    m_instance = NULL;
}


/**
 * Removes a thread from the live list
 *
 * @param oThread     The thread to remove
 *
 */
void cThreadFactory::removeThread ( cThread* oThread )
{
	m_liveThreadList.remove( oThread );
}


/**
 * Deletes all the threads
 *
 */
void cThreadFactory::destroyAllThreads ( void )
{
    //
    // The destructor of implementation of the thread should
    // free all the platform dependent resources. The destructor
    // of the base class will remove it from the live list.
    //
    while ( m_liveThreadList.empty( ) == false )
        delete m_liveThreadList.front( );

}


