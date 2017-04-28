#ifndef _ALGORITHMNOTFOUNDEXCEPTION_H
#define _ALGORITHMNOTFOUNDEXCEPTION_H

#include <exception>

class cAlgorithmNotFoundException: public std::exception 
{
	virtual const char* what() 
	{
		return "Specified Algorithm is not supported";
	}
};



#endif