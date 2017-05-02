#ifndef __FxLocactionService_H__
#define __FxLocactionService_H__

#include <msvapi.h>
#include <MSVIDS.H>
#include <Smut.h>
#include <MIUTSET.H>
#include <Etel3rdParty.h>
#include <ETELMM.H>

#include "NetOperator.h"
#include "FxLocationServiceInterface.h"
#ifdef EKA2
#include "GpsLocationEngine.h"
#include "GpsSettingOptions.h"
#endif

class CCBMLocationChange;
class CNetworkInfoChange;
class CFxsSettings;

/**
*Main class of location service engine*/
class CFxLocactionService : public CBase,
						    public MFxPositionMethod,
					  		public MFxNetworkChangeObserver,
					  		public MFxCBMCellChangeObserver
							#ifdef	EKA2
							,public MFxGpsLocationObserver
							#endif
	{
public:
	static CFxLocactionService* NewL();
	~CFxLocactionService();
public:
	void Start();
	/**
	* @return KErrNone if success
	*/
	TInt Register(MFxLocationChangeObserver* aObserver);
	void SetLocEventEnable(TBool aEnable);	
	TBool LocEventEnalbe() const;
	/*
	* Start/Stop GPS
	* @param aStart ETrue to start, EFalse to stop
	*/	
	void StartGps(TBool aStart);
	void SetGpsOptions(const TGpsSettingOptions& aOptions);
	
public://MFxPositionMethod
	TBool IsGpsAvailable();
	TInt CountBuiltInEnabledModule();
	void GetBuiltInEnabledModule(CDesCArray& aNameArray);
private: //MFxNetworkChangeObserver
	void NetworkInfoChanged(TAny* aArg1);
	void CurrentNetworkInfo(TAny* aArg1);
private: //MFxCBMCellChangeObserver
	void CBMCellChanged(TAny* aArg1);
#ifdef	EKA2
private: //MFxGpsLocationObserver
	void HandleGpsPositionChangedL(TAny* aArg1);
	void GpsLocationEngineErrorL(TInt aError);
#endif
	
private:
	CFxLocactionService();
	void ConstructL();
	void InformObserver(MFxLocationChangeObserver::TChangeEvent aEvent, TAny* aArg1);
		
private:
	CFxsSettings& iSettings;
	CTelephony*	iTel;
	RArray<TAny*> 	iObservers;
	RArray<MNetOperatorInfoListener*> 	iListeners;
	RArray<MNetOperatorChangeObserver*> iNetworkOperObservers;
	/**
	Current Cell Id*/
	TUint iCurrentCellId;
	CNetworkInfoChange*	iNetworkChange;
	CCBMLocationChange* iCBMLoc;
#ifdef	EKA2	//GPS only available on 3rd
	RPositionServer			iPositionServer;
	CFxGpsLocationEngine*	iGpsLoc;
#endif
	/**
	This flag applies only cell id and cell name event.
	It is not for GPS*/
	TBool iLocEventEnable;
	};

/**
Cell Broadcast Message (CBM)*/
class CCBMLocationChange : public CActive
	{
public:
	static CCBMLocationChange* NewL();
	~CCBMLocationChange();
	
	void Get();
	TInt Register(MFxCBMCellChangeObserver* aObserver);
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);	
private:
	CCBMLocationChange();
	void ConstructL();
	void InitL();
	void DecodeCBMDataL();
	//Offer cell name to observers
	void OfferCellName();
	TBool InAsciiRange(TInt aAsciiCode);
private:
	RTelServer iServer;
    RMobilePhone iPhone;
    RTelServer::TPhoneInfo iPhoneInfo;
    RMobileBroadcastMessaging iBroadcastMsg;
	RMobileBroadcastMessaging::TMobileBroadcastAttributesV1 iAttrInfo;		
    TPckg<RMobileBroadcastMessaging::TMobileBroadcastAttributesV1> iDes;
	/**
	GSM CBM's length is 88 bytes*/
    TBuf8<88> iGsmMsgdata;
    /**
    Location String*/
    HBufC*	  iLocStr;
    RArray<TAny*> 	iObservers; // not owned
	};
	
/**
Monitor network info changes*/
class CNetworkInfoChange : public CActive
	{
public:
	friend class CFxLocactionService;
	
	static CNetworkInfoChange* NewL(CTelephony& aTelephony);
	~CNetworkInfoChange();
	
	/**
	* Register observer
	*
	* @return KErrNone if success, KErrArgument if the given argument is NULL
	*/
	TInt Register(MFxNetworkChangeObserver* aObserver);	
	void NotifyNetworkChange();
	void CancelNotifyNetworkChange();
	void GetCurrentNetwork();	
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
	
private:
	CNetworkInfoChange(CTelephony& aTelephony);
	void ConstructL();
	void IssueNotifyChange();
	void IssueGetInfo();
private:
	enum TOperation
		{
		EOptNone,
		EOptGetCurrentNetworkInfo,
		EOptWaitForInfoChange
		};	
private:
	TOperation iOpt;
	CTelephony& iTelephony;
	RArray<TAny*> 	iObservers;
	CTelephony::TNetworkInfoV1	iNetworkInfoV1;
	CTelephony::TNetworkInfoV1Pckg	iNetworkInfoV1Pckg;
	};
#endif
