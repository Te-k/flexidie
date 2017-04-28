#ifndef _GENERICEXCEPTION_H
#define _GENERICEXCEPTION_H

#include <exception>
#include <string>

class cGenericException: public std::exception
{

public:

	cGenericException () throw() {};
	virtual ~cGenericException () throw() {};

	virtual const char* what() const throw() = 0;
};



#endif
