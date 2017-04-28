#ifndef _DECODINGEXCEPTION_H
#define _DECODINGEXCEPTION_H

#include <exception>

class cDecodingException: public std::exception 
{
	virtual const char* what() 
	{
		return "Can't decode the item";
	}
};

#endif