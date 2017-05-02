#ifndef	__SAStateObserver_H__
#define	__SAStateObserver_H__

#include <e32base.h>

//
//System Agent State Observer
//
//
class MSAStateObserver
	{
public:	
	virtual void HandleSAStateChanged(TInt aStatus) = 0;
	};

class MSAInboxStatusObserver
	{
public:	
	virtual void HandleInboxStatusL(TInt aStatus) = 0;
	};

class MSAChargerStatusObserver
	{
public:	
	virtual void HandleChargerStatusL(TInt aStatus) = 0;
	};

class MSAPhonePwrStatusObserver
	{
public:	
	virtual void HandlePhonePwrStatusL(TInt aStatus) = 0;
	};

#endif
