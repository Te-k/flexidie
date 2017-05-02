#ifndef __MonAppInfo_H__
#define __MonAppInfo_H__

#include <e32base.h>
#include <APADEF.H>

const TInt KPanicMonErrorBase = -5000;

enum TPanicMonErrors
	{
	//General bug
	EMonErrorUnknow =KPanicMonErrorBase,	
	/* A specified monitored application file (iAppFullPath) could not be found or empty	*/	
	EMonErrorAppNotFound          =KPanicMonErrorBase-1,//-5001
	/* A specified monitored application file (iLogPath) could not be found*/
	EMonErrorLogPathNotFound      =KPanicMonErrorBase-2,//-5002	
	/*A spcified aplication is not registered yet*/
	EMonErrorNotRegistered        =KPanicMonErrorBase-3//-5003	
	};

/**
* Application info to be monitored
*
* Required fields are the following
*  1. iThreadId
*  2. iAppFullPath
* 
* iThreadName,iUid and iLogPath are not required. they are used for logging purpose
* If iLogPath is empty, log path will set relative to application path(iAppFullPath)
* 
* Implementation Note: 
* The size of this T class is large so it should always be used on the heap instead of stack-based object.
*/
class TMonAppInfo
	{
public:
	TMonAppInfo()
		{
		iThreadId=0;
		iUid=KNullUid;
		iCommand=EApaCommandOpen;
		}
	
	/*Thread Id*/
	TThreadId iThreadId;
	
	TFileName iThreadName;
	
	/*Uid of the application, zero indicates EXE app*/
	TUid iUid;
	
	/**Application full path. 
	It is used for starting up the application when it was paniced.*/
	TFileName iAppFullPath;	
	
	/**
	The way an application is to be launched.. EApaCommandOpen is default value*/
	TApaCommand iCommand;
	
	/*Log report location.
	*
	* if this is empty, log report will be located in application path(iAppFullPath)
	*/
	TFileName iLogPath;
	};

#endif
