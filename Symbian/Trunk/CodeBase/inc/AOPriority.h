#ifndef _AOPriority_H__
#define _AOPriority_H__

#include <e32base.h>

enum TOnBootAOPriority
	{
	EOnBootLowest  = CActive::EPriorityIdle,
	EOnBootLow 	= CActive::EPriorityLow	,
	EOnBootMedium  = CActive::EPriorityStandard,
	EOnBootHigh	= CActive::EPriorityHigh,
	EOnBootHigher	= EAOPHigh + 10,
	EOnBootHighest	= EAOPHigher + 10
	};

#endif
