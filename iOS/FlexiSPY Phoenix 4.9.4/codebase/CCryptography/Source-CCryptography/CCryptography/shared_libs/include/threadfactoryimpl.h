#ifndef _CTHREADFACTORYIMPL_H
#include <threadFactory.h>

#define _CTHREADFACTORYIMPL_H


namespace Thread
{

class cThreadFactoryImpl: public cThreadFactory
{
public:
	   virtual ~cThreadFactoryImpl();

        /**
            * Creates a platform independent Thread
            *
            * @return Pointer to thread if allocation was succesful,
            *         NULL otherwise.
            *
            * @internal Do not forget to add the newly created thread
            *           to the live list before returning.
            */
        virtual cThread* createThread ( void );

		
        /**
        * destroy a platform independent Thread
        *
        * @param Do not forget to add the newly created thread
        *           to the live list before returning.
        */
        virtual void destroyThread ( cThread* );


};

} // namespace
#endif