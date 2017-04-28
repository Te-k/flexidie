#ifndef _STRING_EXCEPTION_H
#define _STRING_EXCEPTION_H

#include <genericexception.h>
#include <string>

class StringException: public cGenericException
{
protected:

	std::string m_sWhat;
public:

	StringException () throw() {};
    ~StringException() throw () {};
	StringException (std::string sMsg) { m_sWhat = sMsg; }

	virtual const char* what() const throw()
	{
		return m_sWhat.c_str();
	}
};



#endif
