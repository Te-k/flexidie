#include "ServConnectMan.h"
#include "Logger.h"

#include <Es_sock.h>
#include <rconnmon.h>
#include <es_enum.h>

CConnEstablisher::CConnEstablisher(MConnStateObserver& aObserver)
:CActiveBase(CActive::EPriorityHigh*2),
iObserver(aObserver),
iArrayOfCallback(2)
	{
	}
	
CConnEstablisher::~CConnEstablisher()
	{
	LOG0(_L("[CConnEstablisher::~CConnEstablisher]"))
	delete iConnMonitor;
	delete iProgNotifier;
	Cancel();
	iArrayOfCallback.Close();
	delete iTimeout;
	iConnection.Close();
	iSockServ.Close();
	LOG0(_L("[CConnEstablisher::~CConnEstablisher] End"))
	}

void CConnEstablisher::Destruct()
	{
	if(IsActive())
		{
		iDestroyOnAsyncComplete = ETrue;
		delete iConnMonitor;
		iConnMonitor = NULL;
		delete iProgNotifier;
		iProgNotifier = NULL;
		iArrayOfCallback.Close();
		iConMonObserver = NULL;
		//the complete destruction will be done after async method is completed
		}
	else
		{
		//delete self
		delete this;
		}
	}

CConnEstablisher* CConnEstablisher::NewL(MConnStateObserver& aObserver)
	{	
	CConnEstablisher* self = new (ELeave) CConnEstablisher(aObserver);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
void CConnEstablisher::ConstructL()
	{
	iTimeout = CTimeOut::NewL(*this);	
	ConnectToSocketServerL();
	OpenRConnectionL();
	CreateProgressNonifierL();
	iConnMonitor = new (ELeave)CConnMonitor(iConnection,this);	
	CActiveScheduler::Add(this);
	}

void CConnEstablisher::ConnectToSocketServerL()
	{
	User::LeaveIfError(iSockServ.Connect());	
	}
	
void CConnEstablisher::OpenRConnectionL()
	{
	User::LeaveIfError(iConnection.Open(iSockServ));
	}
	
void CConnEstablisher::CreateProgressNonifierL()
	{
	if(!iProgNotifier)
		{		
		iProgNotifier = CConnProgressNonifier::NewL(iConnection,*this);	
		}	
	}

void CConnEstablisher::AddProgressObserver(MConnProgressCallback* aCallback)
	{
	if(aCallback)
		{
		iArrayOfCallback.Append(aCallback);
		}
	}
	
void CConnEstablisher::RemoveProgressObserver(MConnProgressCallback* aCallback)
	{
	//LOG2(_L("[CConnEstablisher::RemoveProgressObserver] aCallback: %d, Count: %d"), aCallback, iArrayOfCallback.Count())
	
	for(TInt i=0;i<iArrayOfCallback.Count();i++)
		{
		MConnProgressCallback* callbackElement = ((MConnProgressCallback*)iArrayOfCallback[i]);
		if(callbackElement == aCallback)
			{
			iArrayOfCallback.Remove(i);
			break;
			}
		}
	}
	
void CConnEstablisher::SetApnInfo(const TApInfo& aApn)
	{
	iApnInfo = aApn;
	iConnPref.SetIapId(aApn.iIapId);
	iConnPref.SetDialogPreference(ECommDbDialogPrefDoNotPrompt);
	}

void CConnEstablisher::SetTimeoutInterval(TTimeIntervalMicroSeconds32 aTimeoutInterval)
	{
	iTimeoutInterval = aTimeoutInterval;
	iTimeout->SetInterval(iTimeoutInterval);	
	}

void CConnEstablisher::SetObserver(MConnMonitorObserver* aConMonObserver)
	{
	iConMonObserver = aConMonObserver;
	}
	
TBool CConnEstablisher::OpenConnection()
//Opening operation takes about 5 secs up	
//So do it in RunL()
	{
	if(!IsActive())
		{
		iCancelConnection = EFalse;
		TRequestStatus* status = &iStatus;
		User::RequestComplete(status, KErrNone);
		SetActive();		
		iOptCode = EOptIssueOpenConnection;	
		return ETrue;
		}
	return EFalse;
	}

TBool CConnEstablisher::IsConnectionActive()
	{
#if defined(__WINS__)
	return EFalse;
#endif
	LOG0(_L("[CConnEstablisher::IsConnectionActive]"))
	TUint connectionCount;
	User::LeaveIfError(iConnection.EnumerateConnections(connectionCount));
	TPckgBuf<TConnectionInfoV2> connectionInfo; 
	for (TUint i = 1; i <= connectionCount; i++)
		{
		User::LeaveIfError(iConnection.GetConnectionInfo(i, connectionInfo));
		if (connectionInfo().iIapId == iConnPref.IapId())
			{ 
			LOG0(_L("[CConnEstablisher::IsConnectionActive] End"))
			return ETrue;
			}
		}
		LOG0(_L("[CConnEstablisher::IsConnectionActive] end"))
	return EFalse;
	}

const RConnection& CConnEstablisher::Connection() const
	{
	return iConnection;
	}
	
const RSocketServ& CConnEstablisher::SocketServ() const
	{
	return iSockServ;
	}

void CConnEstablisher::CancelConnection()
//it is not posible to cancel the async pending of RConnection::Start() method
//set a flag
	{
	if(IsActive())
		{
		iCancelConnection = ETrue;	
		}
	}
	
void CConnEstablisher::RunL()
//KErrNotFound
//KErrDisconnected there is an exact cause by many reason
	{
	LOG0(_L("[CConnEstablisher::RunL]"))
	LOG3(_L("[CConnEstablisher::RunL] iStatus: %d, IsConnectionActive(): %d, iStarted: %d"), iStatus.Int(), IsConnectionActive(), iStarted)
	
	if(iDestroyOnAsyncComplete)
		{
		//Because there is no API to cancel RConnection::Start() async method
		delete this;
		}
	else
		{
		if(iCancelConnection)
			{
			iCancelConnection = EFalse;
			iObserver.HandleConnStatusL(EConnStateError, KErrCancel);			
			}
		else
			{
			switch(iOptCode)
				{
				case EOptIssueOpenConnection:
					{
					if(iStarted && IsConnectionActive())
						{
						LOG1(_L("[CConnEstablisher::RunL] iConnection.Handle: %d"),iConnection.SubSessionHandle())
						iObserver.HandleConnStatusL(EConnStateOpened, KErrNone);
						//iObserver.HandleConnStatusL(EConnStateError,-36);
						}
					else
						{
						IssueStartConnection();
						StartTimer();				
						}
					}break;
				case EOptOpenConnection:
				//Open connection result
					{
					StopTimer();
					TInt error = iStatus.Int();
					TRConnectionState state = (error == KErrNone || error == KErrAlreadyExists) ? EConnStateOpened: EConnStateError;			
					if(state == EConnStateOpened)
						{
						iStarted = ETrue;
						iProgNotifier->Start();
						}
					iOptCode = EOptNone;
					LOG1(_L("[CConnEstablisher::RunL] iConnection.Handle: %d"),iConnection.SubSessionHandle())
					iObserver.HandleConnStatusL(state,error);			
					//iObserver.HandleConnStatusL(EConnStateError,-36);
					}break;
				default:
					;
				}
			}
		}
	}

void CConnEstablisher::IssueStartConnection()
	{
	LOG1(_L("[CConnEstablisher::IssueStartConnection]IapId: %d"),iConnPref.IapId())
	
	if(!IsActive())
		{
		iConnection.Start(iConnPref, iStatus);
		SetActive();
		iOptCode = EOptOpenConnection;
		}
	}
	
void CConnEstablisher::DoCancel()
	{
//
//This causes to panic E32USER-CBase 46 if is not called when exit the application
//that's why the caller must call Destruct() method to destroy this object instead of using delete operator
//
	iStarted = EFalse;
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);
	}
	
TPtrC CConnEstablisher::ClassName()
	{
	return TPtrC(_L("CConnEstablisher"));
	}
	
TInt CConnEstablisher::RunError(TInt aError)
	{
	CActiveBase::Error(aError);
	iOptCode = EOptNone;	
	return iObserver.HandleConnStatusLeave(aError);	
	}

//MConnProgressCallback
void CConnEstablisher::ConnProgress(const TNifProgress& aProgress)
//
//	Sequence of events when success
//	KFinishedSelection
//	KFinishedSelection
//	KPsdStartingConfiguration
//	KPsdFinishedConfiguration
//	KCsdStartingConnect
//	KConnectionOpen
//	KLinkLayerOpen
//
	{
	iProgress = aProgress;	
	LOG1(_L("[CConnEstablisher::ConnProgress] aProgress.iError: %d"), aProgress.iError)
	
	//aProgress.iError = -17210 when it is manually closed
	//
    switch(aProgress.iStage)
    	{
    	case KConnectionClosed:
    	case KLinkLayerClosed:    	
    	case KConnectionUninitialised:
    	//
    	//this occurs when
    	//- the user terminated connection by pressing end(red) key
    	//- when the user change profile to offline mode while a connection is connected
    	//
    		{
    		//call to RConnection::Stop causes Panic EXEC-0
    		LOG1(_L("[CConnEstablisher::ConnProgress] Close itHandle: %d"), iConnection.SubSessionHandle())
    		iStarted = EFalse;
    		iProgNotifier->Stop();    		
    		}break;
    	default:
    		;
    	}
    
    switch(aProgress.iStage)
        {
        // Connection open
        case KConnectionOpen:
        LOG0(_L("[CConnProgressNonifier::ConnProgress] KConnectionOpen"))	
        	break;
        case KLinkLayerOpen:
        	{	     
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KLinkLayerOpen"))	
        	}break;
          // Connection blocked or suspended
        case KDataTransferTemporarilyBlocked:
        	{
        LOG0(_L("[CConnProgressNonifier::ConnProgress] KDataTransferTemporarilyBlocked"))	
        	}break;			
	      // Connection unitialised
        case KConnectionUninitialised:
        LOG0(_L("[CConnProgressNonifier::ConnProgress] KConnectionUninitialised"))
            break;
        // Starting connetion selection
        case KStartingSelection:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KFinishedSelection"))
            break;
        // Selection finished
        case KFinishedSelection:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KFinishedSelection"))
            break;
		
        // Connection failure
        case KConnectionFailure:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KConnectionFailure"))        
            break;

        // Prepearing connection (e.g. dialing)
        case KPsdStartingConfiguration:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KPsdStartingConfiguration"))
        	break;
        case KPsdFinishedConfiguration:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KPsdFinishedConfiguration"))
        	break;        
        case KCsdFinishedDialling:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KCsdFinishedDialling"))
        	break;                
        case KCsdScanningScript:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KCsdScanningScript"))
        	break;                
        case KCsdGettingLoginInfo:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KCsdGettingLoginInfo"))
        	break;               
        case KCsdGotLoginInfo:   
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KCsdGotLoginInfo"))
            break;
        
        // Creating connection (e.g. GPRS activation)
        case KCsdStartingConnect:
           	LOG0(_L("[CConnProgressNonifier::ConnProgress] KCsdStartingConnect"))
           	break;
        case KCsdFinishedConnect:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KCsdFinishedConnect"))
            break;
		
        // Starting log in
        case KCsdStartingLogIn:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KCsdStartingLogIn"))
            break;

        // Finished login
        case KCsdFinishedLogIn:    
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KCsdFinishedLogIn"))
            break;
	       // Hangup or GRPS deactivation
        case KConnectionStartingClose:       
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KConnectionStartingClose"))            
            break;

        // Connection closed
        case KConnectionClosed:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KConnectionClosed"))
            break;        
        case KLinkLayerClosed:
        	LOG0(_L("[CConnProgressNonifier::ConnProgress] KLinkLayerClosed"))
            break;
        // Unhandled state
        default:
        	LOG1(_L("[CConnProgressNonifier::ConnProgress] Defaut iStage: %d"),aProgress.iStage)
            break;
        }
	}

void CConnEstablisher::StartTimer()
	{	
	if(iTimeoutInterval.Int() > 0)
		{
		iTimeout->Start();	
		}
	}
	
void CConnEstablisher::StopTimer()
	{
	iTimeout->Stop();
	}

void CConnEstablisher::SetConnectionActivePeriod(TUint aSec)
	{
	iConnMonitor->SetActivePeriod(aSec);
	}

void CConnEstablisher::ConnectionActiveRequest()
	{
	iConnMonitor->Start();
	}

void CConnEstablisher::ConnectionActiveStatusL(TInt aError, TBool aActive)
//From MConnMonitorObserver
	{
	if(iConMonObserver)
		{
		iConMonObserver->ConnectionActiveStatusL(aError, aActive);
		}
	}

void CConnEstablisher::HandleConnMonLeave(TInt aError)
//From MConnMonitorObserver
	{
	if(iConMonObserver)
		{
		iConMonObserver->HandleConnMonLeave(aError);
		}	
	}
	
//From MTimeoutObserver
void CConnEstablisher::HandleTimedOutL()
	{
	LOG0(_L("[CConnEstablisher::HandleTimedOutL]"))
	iObserver.HandleConnStatusL(EConnStateTimedout, KErrTimedOut);	
	}

//From MTimeoutObserver
TInt CConnEstablisher::HandleTimedOutLeave(TInt /*aLeaveCode*/)
	{
	//iObserver.HandleConnStatusL leave, however do not do anything
	return KErrNone;
	}

////////////////////////////////////////////////////////////////////////////////////

CConnMonitor::CConnMonitor(RConnection& aConnection, MConnMonitorObserver* aObserver)
:CActiveBase(CActive::EPriorityStandard),
iConnection(aConnection),
iObserver(aObserver),
iStatePkg(iState)
	{
	CActiveScheduler::Add(this);
	}
	
CConnMonitor::~CConnMonitor()
	{
	Cancel();
	}

void CConnMonitor::SetObserver(MConnMonitorObserver* aObserver)
	{
	iObserver = aObserver;
	}

void CConnMonitor::SetActivePeriod(TUint aSec)
	{
	iInterval = aSec;	
	}
	
void CConnMonitor::Start()
	{
	if(!IsActive() && iInterval > 0)
		{
		iConnection.IsConnectionActiveRequest(iInterval, iStatePkg, iStatus);
		SetActive();		
		}
	}
	
void CConnMonitor::RunL()
	{
	if(iStatus != KErrCancel && iObserver)
		{
		iObserver->ConnectionActiveStatusL(iStatus.Int(), iStatePkg());	
		}	
	//
	//KErrCancel when the user presses red key to terminate active connection
	//this case do not inform observer
	}
	
void CConnMonitor::DoCancel()
	{
	iConnection.IsConnectionActiveCancel();
	}
	
TInt CConnMonitor::RunError(TInt aError)
	{
	CActiveBase::Error(aError);
	if(iObserver)
		{
		iObserver->HandleConnMonLeave(aError);
		}
	return KErrNone;
	}
	
TPtrC CConnMonitor::ClassName()
	{
	return TPtrC(_L("CConnMonitor"));
	}
