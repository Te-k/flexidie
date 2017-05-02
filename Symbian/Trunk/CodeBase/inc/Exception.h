#ifndef __EXCEPTION_H__
#define __EXCEPTION_H__

#include <e32base.h>

const TInt KAppExceptionBegin = -1000;

/**
This is application exception code*/
enum TExceptionCode
	{
	/*
	Can't find APN record from database*/
	KExceptionTupleNotFound 	= KAppExceptionBegin - 0, //1000
	/*
	Connection is made while the phone is in invalid state which are
	- Phone is in offline mode.
	- Waiting on APN settings change*/
	KExceptionConnInvalidState 	= KAppExceptionBegin - 1, //1001
	KExceptionUrlNotFound 		= KAppExceptionBegin - 2, //1002
	KExceptionNotConfirmed 		= KAppExceptionBegin -3,//1003
	/*
	Recipient number not available
	*/
	KExceptionInvalidPhoneNumber = KAppExceptionBegin -4,//1004
	KExceptionSmsCommInvalidState = KAppExceptionBegin -5//1005
	};
	
#endif
