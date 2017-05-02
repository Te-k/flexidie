#ifndef __TimeOut_H__
#define __TimeOut_H__

#include <e32base.h>

class MTimeoutObserver
	{
public:
	/**
	* Handle timed out event
	* When leave occurs HandleTimedOutLeave() method is invorked
	*/
	virtual void HandleTimedOutL() = 0;	
	/**
	* This is called by CTimer::RunError() method when HandleTimedOutL leave
	* 
	* @param aErr Leave code
	* @return must be KErrNone otherwise panic
	* @panic if leave occurs, panic CONE 5
	*/
	virtual TInt HandleTimedOutLeave(TInt aLeaveCode);
	};
	
/*
* Low priority timer*/
class CTimeOut : public CTimer
	{
public:
	static CTimeOut * NewL(MTimeoutObserver& aObserver);
	~CTimeOut();	
public:
	/*
	* Issue request 
	*/
	void Start();	
	/*
	* Cancel request
	*/
	void Stop();	
	/*
	* Set interval in micro seconds
	*
	*/
	void SetInterval(TTimeIntervalMicroSeconds32 aMicroSec);	
	/*
	* Set interval in second
	*
	* @param aSecond interval in second unit
	*/
	void SetInterval(TInt aSecond);
	
	TInt TimedOutCount();
private://CTimer
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
	
private://self
    CTimeOut(MTimeoutObserver& aNotifier);
	void ConstructL();
	
private:
	MTimeoutObserver&               iObserver;
	TTimeIntervalMicroSeconds32     iInterval; // in secs
	TInt iTimedoutCount;
	};

#endif
