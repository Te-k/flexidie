// ETELMM.H
//
// Copyright (c) 2002-2003 Symbian Ltd.  All rights reserved.
//

/** \file ETELMM.H
 * Multimode ETel API header file.
 *
 * Describes the MM ETel API - classes, methods and types.
 */

#ifndef __ETELMM_H__
#define __ETELMM_H__

#include <e32base.h>
#include <s32mem.h>
#include <ETEL.h>
#include <ETELMMCS.H>

// Names for Multimode ETel sub-sessions

_LIT(KETelMeAdnPhoneBook,"S1");
_LIT(KETelMeDialledPhoneBook,"S2");
_LIT(KETelMeMissedPhoneBook,"S3");
_LIT(KETelMeReceivedPhoneBook,"S4");
_LIT(KETelCombinedAdnPhoneBook,"S5");
_LIT(KETelTaAdnPhoneBook,"S6");
_LIT(KETelIccAdnPhoneBook,"S7");
_LIT(KETelIccFdnPhoneBook,"S8");
_LIT(KETelIccSdnPhoneBook,"S9");
_LIT(KETelIccBdnPhoneBook,"S10");
_LIT(KETelIccLndPhoneBook,"S11");
_LIT(KETelIccVoiceMailBox,"S12");

_LIT(KETelMeSmsStore,"S13");
_LIT(KETelIccSmsStore,"S14");
_LIT(KETelCombinedSmsStore,"S15");

_LIT(KETelNamStore,"S16");
_LIT(KETelOwnNumberStore,"S17");
_LIT(KETelEmergencyNumberStore,"S18");

_LIT(KETelSmsMessaging,"S19");
_LIT(KETelBroadcastMessaging,"S20");
_LIT(KETelUssdMessaging,"S21");

_LIT(KETelConferenceCall,"S22");

_LIT(KETelIccInfoPhoneBook,"S23");

//
//  Global Multimode constants and types
// 

// Unique API identifier and Functional Unit constants

enum TMultimodeETelV1Api
	{
	KETelExtMultimodeV1=3000,  // 3000 is unique reference for Multimode Etel v1.0 API
	KETelFuncMobileIccAccess,
	KETelFuncMobileNetwork,
	KETelFuncMobileIdentity,
	KETelFuncMobilePower,
	KETelFuncMobileSignal,
	KETelFuncMobileIndicator,
	KETelFuncMobileDTMF,
	KETelFuncMobileUserNetworkAccess,
	KETelFuncMobileIdentityService,
	KETelFuncMobileCallForwarding,
	KETelFuncMobileCallBarring,
	KETelFuncMobileCallWaiting,
	KETelFuncMobileCallCompletion,
	KETelFuncMobileAlternatingCall,
	KETelFuncMobileCost,
	KETelFuncMobileSecurity,
	KETelFuncMobileAlternateLineService,
	KETelFuncMobileMessageWaiting,
	KETelFuncMobileFixedDiallingNumbers,
	KETelFuncMobileDataCall,
	KETelFuncMobilePrivacy,
	KETelFuncMobileEmergencyCall,
	KETelFuncMobileSmsMessaging,
	KETelFuncMobileBroadcastMessaging,
	KETelFuncMobileUssdMessaging,
	KETelFuncMobileConferenceCall,
	KETelFuncMobilePhonebook,
	KETelFuncMobileSmsStore,
	KETelFuncMobileNamStore,
	KETelFuncMobileOwnNumberStore,
	KETelFuncMobileEmergencyNumberStore,
	KETelFuncMobileMulticall,
	KETelFuncMobileNextIncomingCall,
	KETelFuncMobileMultimediaCall,
	KETelFuncMobileUserSignalling
	};


/*********************************************************/
//
// Phone based functionality (RMobilePhone)
// 
/*********************************************************/

/**
 * \class RMobilePhone ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to mobile phone functionality provided by TSY
 *
 * RMobilePhone inherits from RPhone defined in ETEL.H
 */

class CMobilePhonePtrHolder;

class RMobilePhone : public RPhone
	{
public:
	friend class CAsyncRetrievePhoneList;

	IMPORT_C RMobilePhone();

	// Global multimode types

	/**
	* \class TMultimodeType ETELMM.H "INC/ETELMM.H"
	* \brief Base class for all the V1 parameter types defined within the API
	*
	*/

	class TMultimodeType
		{
	public:
		IMPORT_C TInt ExtensionId() const;
	protected:
		TMultimodeType();
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	protected:
		TInt iExtensionId;
		};

	// Types used in RMobilePhone::TMobileAddress

	enum TMobileTON
		{
		EUnknownNumber,			// 0
		EInternationalNumber,	// 1
		ENationalNumber,		// 2
		ENetworkSpecificNumber, // 3
		ESubscriberNumber,		// 4 - Also defined as "dedicated, short code" in GSM 04.08
		EAlphanumericNumber,	// 5
		EAbbreviatedNumber		// 6
		};

	enum TMobileNPI
		{
		EUnknownNumberingPlan =0,
		EIsdnNumberPlan=1,		
		EDataNumberPlan=3,		
		ETelexNumberPlan=4,	
		EServiceCentreSpecificPlan1=5,
		EServiceCentreSpecificPlan2=6,
		ENationalNumberPlan=8,
		EPrivateNumberPlan=9,
		EERMESNumberPlan=10
		};

	enum 
		{
		KMaxMobilePasswordSize=10,
		KMaxMobileNameSize=32,
		KMaxMobileTelNumberSize=100
		};

	/**
	* \class TMobileAddress ETELMM.H "INC/ETELMM.H"
	* \brief Defines API abstraction of a mobile telephone number
	*
	*/

	class TMobileAddress
		{
	public:
		IMPORT_C TMobileAddress();
			
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
			
	public:
		TMobileTON iTypeOfNumber;
		TMobileNPI iNumberPlan;
		TBuf<KMaxMobileTelNumberSize> iTelNumber;
		};

	// Mobile information location type

	enum TMobileInfoLocation
		{
		EInfoLocationCache,
		EInfoLocationCachePreferred,
		EInfoLocationNetwork
		};

	// Mobile call service type

	enum TMobileService
		{
		EServiceUnspecified,
		EVoiceService,
		EAuxVoiceService,
		ECircuitDataService,
		EPacketDataService,
		EFaxService,
		EShortMessageService,
		EAllServices
		};

	// Mobile name type

	typedef TBuf<KMaxMobileNameSize> TMobileName;

	// Mobile password type

	typedef TBuf<KMaxMobilePasswordSize> TMobilePassword;

	// for use by client-side API code and TSY only

	struct TClientId
		{
		TInt iSessionHandle;
		TInt iSubSessionHandle;
		};

	enum TMobilePhoneModeCaps
		{
		KCapsGsmSupported=0x00000001,
		KCapsGprsSupported=0x00000002,
		KCapsAmpsSupported=0x00000004,
		KCapsCdma95Supported=0x00000008,
		KCapsCdma2000Supported=0x00000010,
		KCapsWcdmaSupported=0x00000020
		};

	 enum TMultimodeEtelAPIVersion
		{
		 TMultimodeETelApiV1
		};

	IMPORT_C TInt GetMultimodeAPIVersion(TInt& aVersion) const;

	IMPORT_C TInt GetMultimodeCaps(TUint32& aCaps) const;

	IMPORT_C void GetPhoneStoreInfo(TRequestStatus& aReqStatus, TDes8& aInfo, const TDesC& aStoreName) const;

	//
	// MobilePhoneIccAccess functional unit
	//

	enum TMobilePhoneIccCaps
		{
		KCapsSimAccessSupported=0x00000001,
		KCapsRUimAccessSupported=0x00000002,
		KCapsUSimAccessSupported=0x00000004
		};

	IMPORT_C TInt GetIccAccessCaps(TUint32& aCaps) const;
	IMPORT_C void NotifyIccAccessCapsChange(TRequestStatus& aReqStatus, TUint32& aCaps) const;

	enum TCspCallOffering
		{
		KCspCT=0x08,
		KCspCFNRc=0x10,
		KCspCFNRy=0x20,
		KCspCFB=0x40,
		KCspCFU=0x80
		};

	enum TCspCallRestriction
		{
		KCspBICRoam=0x08,
		KCspBAIC=0x10,
		KCspBOICexHC=0x20,
		KCspBOIC=0x40,
		KCspBOAC=0x80
		};

	enum TCspOtherSuppServices
		{
		KCspCUGOA=0x08,
		KCspPrefCUG=0x10,
		KCspAoC=0x20,
		KCspCUG=0x40,
		KCspMPTY=0x80,
		};

	enum TCspCallCompletion
		{
		KCspCCBS=0x20,
		KCspCW=0x40,
		KCspHOLD=0x80,
		};

	enum TCspTeleservices
		{
		KCspValidityPeriod=0x02,
		KCspProtocolID=0x04,
		KCspDelConf=0x08,
		KCspReplyPath=0x10,
		KCspSMCB=0x20,
		KCspSMMO=0x40,
		KCspSMMT=0x80,
		};

	enum TCspCPHSTeleservices
		{
		KCspALS=0x80
		};

	enum TCspCPHSFeatures
		{
		KCspReservedSST=0x80
		};

	enum TCspNumberIdentification
		{
		KCspCLIBlock=0x01,
		KCspCLISend=0x02,
		KCspCOLP=0x10,
		KCspCOLR=0x20,
		KCspCLIP=0x80,
		};

	enum TCspPhase2PlusServices
		{
		KCspMultipleband=0x04,
		KCspMSP=0x08,
		KCspVoiceBroadcast=0x10,
		KCspVoiceGroupCall=0x20,
		KCspHscsd=0x40,
		KCspGprs=0x80
		};

	enum TCspValueAdded
		{
		KCspLanguage=0x01,
		KCspData=0x04,
		KCspFax=0x08,
		KCspSMMOEmail=0x10,
		KCspSMMOPaging=0x20,
		KCspPLMNMode=0x80,
		};

	/**
	* \class TMobilePhoneCspFileV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines contents of the CSP (Customer Service Profile) on the SIM
	*
	*/

	class TMobilePhoneCspFileV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneCspFileV1();

		TUint8	iCallOfferingServices;
		TUint8	iCallRestrictionServices;
		TUint8	iOtherSuppServices;
		TUint8	iCallCompletionServices;
		TUint8  iTeleservices;
		TUint8	iCphsTeleservices;
		TUint8	iCphsFeatures;
		TUint8	iNumberIdentServices;
		TUint8	iPhase2PlusServices;
		TUint8	iValueAddedServices;
		};

	typedef TPckg<TMobilePhoneCspFileV1> TMobilePhoneCspFileV1Pckg;

	IMPORT_C void GetCustomerServiceProfile(TRequestStatus& aReqStatus, TDes8& aCsp) const;
	IMPORT_C void GetCustomerServiceProfile(TRequestStatus& aReqStatus, TDes8& aALSLine, TDes8& aCsp ) const;

	enum TSSTServices1To8
		{
		KSstPin1Disable=0x01,
		KSstADN=0x02,
		KSstFDN=0x04,
		KSstSMS=0x08,
		KSstAoC=0x10,
		KSstCCP=0x20,
		KSstPLMNSelector=0x40
		};

	enum TSSTServices9To16
		{
		KSstMSISDN=0x01,
		KSstExt1=0x02,
		KSstExt2=0x04,
		KSstSMSP=0x08,
		KSstLND=0x10,
		KSstCBMI=0x20,
		KSstGID1=0x40,
		KSstGID2=0x80
		};
	
	enum TSSTServices17To24
		{
		KSstSPName=0x01,
		KSstSDN=0x02,
		KSstExt3=0x04,
		KSstVGCSList=0x10,
		KSstVBSList=0x20,
		KSsteMLPP=0x40,
		KSstAnswereMLPP=0x80
		};

	enum TSSTServices25To32
		{
		KSstSmsCbDataDownload=0x01,
		KSstSmsPpDataDownload=0x02,
		KSstMenuSelection=0x04,
		KSstCallControl=0x08,
		KSstProactiveSim=0x10,
		KSstCBMIRanges=0x20,
		KSstBDN=0x40,
		KSstExt4=0x80
		};

	enum TSSTServices33To40
		{
		KSstDepersonalisationKeys=0x01,
		KSstCooperativeNetworks=0x02,
		KSstSMStatusReports=0x04,
		KSstNetworkIndAlerting=0x08,
		KSstMoSmControlBySim=0x10,
		KSstGprs=0x20,
		KSstImage=0x40,
		KSstSoLSA=0x80
		};

	enum TSSTServices41To48
		{
		KSstUssdStringInCallControl=0x01,
		KSstRunATCommand=0x02,
		KSstPlmnSelectorListWithAccessTechnology=0x04,
		KSstOplmnSelectorListWithAccessTechnology=0x08,
		KSstHplmnAccessTechnology=0x10,
		KSstCpbcchInformation=0x20,
		KSstInvestigationScan=0x40,
		KSstExtendedCcp=0x80
		};

	enum TSSTServices49To56
		{
		KSstMExE=0x01,
		KSstRplmnLastUsedAccessTechnology=0x02
		};

	enum TMobilePhoneServiceTable
		{
		ESIMServiceTable,
		EUSIMServiceTable,
		ECDMAServiceTable
		};

	/**
	* \class TMobilePhoneServiceTableV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines contents of the specified Service Table on the ICC
	*
	*/

	class TMobilePhoneServiceTableV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneServiceTableV1();

		TUint8 iServices1To8;
		TUint8 iServices9To16;
		TUint8 iServices17To24;
		TUint8 iServices25To32;
		TUint8 iServices33To40;
		TUint8 iServices41To48;
		TUint8 iServices49To56;
		};

	typedef TPckg<TMobilePhoneServiceTableV1> TMobilePhoneServiceTableV1Pckg;

	IMPORT_C void GetServiceTable(TRequestStatus& aReqStatus, TMobilePhoneServiceTable aTable, TDes8& aTableData) const;

	//
	// MobilePhonePower functional unit
	//

	enum TMobilePhoneBatteryCaps
		{
		KCapsGetBatteryInfo=0x00000001,
		KCapsNotifyBatteryInfoChange=0x00000002
		};

	IMPORT_C TInt GetBatteryCaps(TUint32& aCaps) const; 

	enum TMobilePhoneBatteryStatus
		{
		EPowerStatusUnknown,
		EPoweredByBattery,
		EBatteryConnectedButExternallyPowered,
		ENoBatteryConnected,
		EPowerFault
		};

	class TMobilePhoneBatteryInfoV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneBatteryInfoV1();
	public:
		TMobilePhoneBatteryStatus iStatus;
		TUint iChargeLevel;
		};

	IMPORT_C void GetBatteryInfo(TRequestStatus& aReqStatus, TMobilePhoneBatteryInfoV1& aInfo) const;
	IMPORT_C void NotifyBatteryInfoChange(TRequestStatus& aReqStatus, TMobilePhoneBatteryInfoV1& aInfo) const;

	//
	// MobilePhoneSignal functional unit
	//

	enum TMobilePhoneSignalCaps
		{
		KCapsGetSignalStrength=0x00000001,
		KCapsNotifySignalStrengthChange=0x00000002
		};

	IMPORT_C TInt GetSignalCaps(TUint32& aCaps) const; 
	IMPORT_C void GetSignalStrength(TRequestStatus& aReqStatus, TInt32& aSignalStrength, TInt8& aBar) const;
	IMPORT_C void NotifySignalStrengthChange(TRequestStatus& aReqStatus, TInt32& aSignalStrength, TInt8& aBar) const;

	//
	// MobilePhoneIndicator functional unit
	//

	enum TMobilePhoneIndicatorCaps
		{
		KCapsGetIndicator=0x00000001,
		KCapsNotifyIndicatorChange=0x00000002
		};

	enum TMobilePhoneIndicators
		{
		KIndChargerConnected=0x00000001,
		KIndNetworkAvailable=0x00000002,
		KIndCallInProgress=0x00000004
		};
	
	IMPORT_C TInt GetIndicatorCaps(TUint32& aActionCaps, TUint32& aIndCaps) const;
	IMPORT_C void GetIndicator(TRequestStatus& aReqStatus, TUint32& aIndicator) const;
	IMPORT_C void NotifyIndicatorChange(TRequestStatus& aReqStatus, TUint32& aIndicator) const;

	//
	// MobilePhoneIdentity functional unit
	//

	enum TMobilePhoneIdentityCaps
		{
		KCapsGetManufacturer=0x00000001,
		KCapsGetModel=0x00000002,
		KCapsGetRevision=0x00000004,
		KCapsGetSerialNumber=0x00000008,
		KCapsGetSubscriberId=0x00000010
		};

	IMPORT_C TInt GetIdentityCaps(TUint32& aCaps) const; 

	enum {	KPhoneManufacturerIdSize=50	};
	enum {	KPhoneModelIdSize=50 };
	enum {	KPhoneRevisionIdSize=50	};
	enum {	KPhoneSerialNumberSize=50 };
	
	class TMobilePhoneIdentityV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneIdentityV1();
	public:
		TBuf<KPhoneManufacturerIdSize> iManufacturer;
		TBuf<KPhoneModelIdSize> iModel;
		TBuf<KPhoneRevisionIdSize> iRevision;
		TBuf<KPhoneSerialNumberSize> iSerialNumber;
		};

	IMPORT_C void GetPhoneId(TRequestStatus& aReqStatus, TMobilePhoneIdentityV1& aId) const;

	enum {	KIMSISize = 15 };

	typedef TBuf<KIMSISize> TMobilePhoneSubscriberId;

	IMPORT_C void GetSubscriberId(TRequestStatus& aReqStatus, TMobilePhoneSubscriberId& aId) const;

	//
	// MobilePhoneDTMF functional unit
	//

	enum TMobilePhoneDTMFCaps
		{
		KCapsSendDTMFString=0x00000001,
		KCapsSendDTMFSingleTone=0x00000002,
		};

	IMPORT_C TInt GetDTMFCaps(TUint32& aCaps) const; 
	IMPORT_C void NotifyDTMFCapsChange(TRequestStatus& aReqStatus, TUint32& aCaps) const;

	IMPORT_C void SendDTMFTones(TRequestStatus& aReqStatus, const TDesC& aTones) const;
	IMPORT_C TInt StartDTMFTone(TChar aTone) const;
	IMPORT_C TInt StopDTMFTone() const;

	IMPORT_C void NotifyStopInDTMFString(TRequestStatus& aRequestStatus) const;
	IMPORT_C TInt ContinueDTMFStringSending(TBool aContinue) const;

	//
	// MobilePhoneNetwork functional unit
	//

	enum TMobilePhoneNetworkCaps
		{
		KCapsGetRegistrationStatus=0x00000001,
		KCapsNotifyRegistrationStatus=0x00000002,
		KCapsGetCurrentMode=0x00000004,
		KCapsNotifyMode=0x00000008,
		KCapsGetCurrentNetwork=0x00000010,
		KCapsNotifyCurrentNetwork=0x00000020,
		KCapsGetHomeNetwork=0x00000040,
		KCapsGetDetectedNetworks=0x00000080,
		KCapsManualNetworkSelection=0x00000100,
		KCapsGetNITZInfo=0x00000200,
		KCapsNotifyNITZInfo=0x00000400
		};

	IMPORT_C TInt GetNetworkCaps(TUint32& aCaps) const;

	enum TMobilePhoneNetworkMode
		{
		ENetworkModeUnknown,
		ENetworkModeUnregistered,
		ENetworkModeGsm,
		ENetworkModeAmps,
		ENetworkModeCdma95,
		ENetworkModeCdma2000,
		ENetworkModeWcdma
		};

	IMPORT_C TInt GetCurrentMode(TMobilePhoneNetworkMode& aNetworkMode) const;
	IMPORT_C void NotifyModeChange(TRequestStatus& aReqStatus, TMobilePhoneNetworkMode& aNetworkMode) const;

	enum TMobilePhoneNetworkStatus
		{
		ENetworkStatusUnknown,
		ENetworkStatusAvailable,
		ENetworkStatusCurrent,
		ENetworkStatusForbidden
		};

	enum TMobilePhoneNetworkBandInfo
		{
		EBandUnknown,
		E800BandA,
		E800BandB,
		E800BandC,
		E1900BandA,
		E1900BandB,
		E1900BandC,
		E1900BandD,
		E1900BandE,
		E1900BandF
		};

	typedef TBuf<30> TMobilePhoneNetworkDisplayTag;
	typedef TBuf<20> TMobilePhoneNetworkLongName;		
	typedef TBuf<10> TMobilePhoneNetworkShortName;

	typedef TBuf<4> TMobilePhoneNetworkCountryCode;		// MCC in GSM and CDMA 
	typedef TBuf<8> TMobilePhoneNetworkIdentity;		// MNC in GSM and SID or NID in CDMA 

	/**
	* \class TMobilePhoneNetworkInfoV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines information related to a mobile phone network
	*
	*/

	class TMobilePhoneNetworkInfoV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneNetworkInfoV1();
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		TMobilePhoneNetworkMode iMode;
		TMobilePhoneNetworkStatus iStatus;
		TMobilePhoneNetworkBandInfo iBandInfo;
		TMobilePhoneNetworkCountryCode iCountryCode;
		TMobilePhoneNetworkIdentity iCdmaSID;
		TMobilePhoneNetworkIdentity iAnalogSID;
		TMobilePhoneNetworkIdentity iNetworkId;
		TMobilePhoneNetworkDisplayTag iDisplayTag;
		TMobilePhoneNetworkShortName iShortName;
		TMobilePhoneNetworkLongName iLongName;
		};
	
	typedef TPckg<TMobilePhoneNetworkInfoV1>  TMobilePhoneNetworkInfoV1Pckg;

	class TMobilePhoneLocationAreaV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneLocationAreaV1();
	public:
		TBool	iAreaKnown;
		TUint	iLocationAreaCode;
		TUint	iCellId;
		};

	IMPORT_C void GetCurrentNetwork(TRequestStatus& aReqStatus, TDes8& aNetworkInfo, TMobilePhoneLocationAreaV1& aArea) const;
	IMPORT_C void NotifyCurrentNetworkChange(TRequestStatus& aReqStatus, TDes8& aNetworkInfo, TMobilePhoneLocationAreaV1& aArea) const;

	IMPORT_C void GetHomeNetwork(TRequestStatus& aReqStatus, TDes8& aNetworkInfo) const;

	enum TMobilePhoneRegistrationStatus
		{
		ERegistrationUnknown,
		ENotRegisteredNoService,
		ENotRegisteredEmergencyOnly,
		ENotRegisteredSearching,
		ERegisteredBusy,
		ERegisteredOnHomeNetwork,
		ERegistrationDenied,
		ERegisteredRoaming
		};

	IMPORT_C void GetNetworkRegistrationStatus(TRequestStatus& aReqStatus, TMobilePhoneRegistrationStatus& aStatus) const;
	IMPORT_C void NotifyNetworkRegistrationStatusChange(TRequestStatus& aReqStatus, TMobilePhoneRegistrationStatus& aStatus) const;

	enum TMobilePhoneSelectionMethod
		{
		ENetworkSelectionUnknown,
		ENetworkSelectionAutomatic,
		ENetworkSelectionManual
		};

	enum TMobilePhoneBandClass
		{
		ENetworkBandClassUnknown,
		ENetworkBandClassAOnly,
		ENetworkBandClassBOnly,
		ENetworkBandClassAPreferred,
		ENetworkBandClassBPreferred
		};

	enum TMobilePhoneOperation
		{
		ENetworkOperationUnknown,
		ENetworkOperationAnalogOnly,
		ENetworkOperationDigitalOnly,
		ENetworkOperationAnalogPreferred,
		ENetworkOperationDigitalPreferred
		};

	class TMobilePhoneNetworkSelectionV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneNetworkSelectionV1();
	public:
		TMobilePhoneSelectionMethod	iMethod;
		TMobilePhoneBandClass		iBandClass;
		TMobilePhoneOperation		iOperationMode;
		};

	typedef TPckg<TMobilePhoneNetworkSelectionV1>  TMobilePhoneNetworkSelectionV1Pckg;

	IMPORT_C TInt GetNetworkSelectionSetting(TDes8& aSetting) const;
	IMPORT_C void SetNetworkSelectionSetting(TRequestStatus& aReqStatus, const TDes8& aSetting) const;
	IMPORT_C void NotifyNetworkSelectionSettingChange(TRequestStatus& aReqStatus, TDes8& aSetting) const;
	
	struct TMobilePhoneNetworkManualSelection
		{
		TMobilePhoneNetworkCountryCode iCountry;
		TMobilePhoneNetworkIdentity iNetwork;
		};
	
	IMPORT_C void SelectNetwork(TRequestStatus& aReqStatus, TBool aIsManual, const TMobilePhoneNetworkManualSelection& aManualSelection) const;

	/**
	* \class TMobilePhoneNITZ ETELMM.H "INC/ETELMM.H"
	* \brief Defines time & date information received from a mobile phone network
	*
	*/

	 // Used to indicate which TMobilePhoneNITZ fields are currently available
	 enum TMobilePhoneNITZCaps
		{
		KCapsTimeAvailable      = 0x00000001,
		KCapsTimezoneAvailable  = 0x00000002,
		KCapsDSTAvailable       = 0x00000004,
		KCapsShortNameAvailable = 0x00000008,
		KCapsLongNameAvailable  = 0x00000010
		};

	class TMobilePhoneNITZ : public TDateTime
		{
	public:
		IMPORT_C TMobilePhoneNITZ();
		IMPORT_C TMobilePhoneNITZ(TInt aYear, TMonth aMonth, TInt aDay, TInt aHour, TInt aMinute, TInt aSecond, TInt aMicroSecond);		
	public:
		TInt32	                     iNitzFieldsUsed;
		TInt                         iTimeZone;
		TInt	                     iDST;
		TMobilePhoneNetworkShortName iShortNetworkId;
		TMobilePhoneNetworkLongName	 iLongNetworkId;
		};

	IMPORT_C TInt GetNITZInfo(TMobilePhoneNITZ& aNITZInfo) const;
	IMPORT_C void NotifyNITZInfoChange(TRequestStatus& aReqStatus, TMobilePhoneNITZ& aNITZInfo) const;

	//
	// MobilePrivacy functional unit
	//

	enum TMobilePhonePrivacy
		{
		EPrivacyUnspecified,
		EPrivacyOn,
		EPrivacyOff
		};

	IMPORT_C TInt GetDefaultPrivacy(TMobilePhonePrivacy& aSetting) const;
	IMPORT_C void SetDefaultPrivacy(TRequestStatus& aReqStatus, TMobilePhonePrivacy aSetting) const;
	IMPORT_C void NotifyDefaultPrivacyChange(TRequestStatus& aReqStatus, TMobilePhonePrivacy& aSetting) const;

	//
	// TSY Capabilities for supplementary call services
	// 

	enum TMobilePhoneCallServiceCaps
		{
		KCapsGetCFStatusCache				=0x00000001,
		KCapsGetCFStatusNetwork				=0x00000002,
		KCapsSetCFStatus					=0x00000004,
		KCapsNotifyCFStatus					=0x00000008,
		KCapsGetClipStatus					=0x00000010,
		KCapsGetClirStatus					=0x00000020,
		KCapsGetColpStatus					=0x00000040,
		KCapsGetColrStatus					=0x00000080,
		KCapsGetCnapStatus					=0x00000100,
		KCapsGetCBStatusCache				=0x00000200,
		KCapsGetCBStatusNetwork				=0x00000400,
		KCapsSetCBStatus					=0x00000800,
		KCapsNotifyCBStatus					=0x00001000,
		KCapsChangeCBPassword				=0x00002000,
		KCapsBarAllIncoming					=0x00004000,
		KCapsBarIncomingRoaming				=0x00008000,
		KCapsBarAllOutgoing					=0x00010000,
		KCapsBarOutgoingInternational		=0x00020000,
		KCapsBarOutgoingInternationalExHC	=0x00040000,
		KCapsBarAllCases					=0x00080000,
		KCapsGetCWStatusCache				=0x00100000,
		KCapsGetCWStatusNetwork				=0x00200000,
		KCapsSetCWStatus					=0x00400000,
		KCapsNotifyCWStatus					=0x00800000,
		KCapsGetCCBSStatusCache				=0x01000000,
		KCapsGetCCBSStatusNetwork			=0x02000000,
		KCapsDeactivateAllCCBS				=0x04000000,
		KCapsDeactivateCCBS					=0x08000000,
		KCapsRetrieveActiveCCBS				=0x10000000,
		KCapsFeatureCode					=0x20000000,
		KCapsNetworkServiceRequest			=0x40000000
		};

	IMPORT_C TInt GetCallServiceCaps(TUint32& aCaps) const;
	IMPORT_C void NotifyCallServiceCapsChange(TRequestStatus& aReqStatus, TUint32& aCaps) const;

	//
	// MobilePhoneUserNetworkAccess functional unit
	//

	enum TMobilePhoneNetworkService
		{
		ENetworkServiceUnspecified,
		ECFUService,
		ECFBService,
		ECFNRyService,
		ECFNRcService,
		EDeflectToVoicemail,
		EDeflectToNumber,
		EDeflectToRegisteredNumber,
		ECWService,
		ENextCallShowCLI,
		ENextCallHideCLI
		};

	enum TMobilePhoneServiceAction
		{
		EServiceActionUnspecified,
		EServiceActionRegister,
		EServiceActionActivate,
		EServiceActionInvoke,
		EServiceActionDeactivate,
		EServiceActionErase
		};

	// API/TSY internal type

	struct TNetworkServiceAndAction
		{
		TMobilePhoneNetworkService iService;
		TMobilePhoneServiceAction iAction;
		};
	
	IMPORT_C void ProgramFeatureCode(TRequestStatus& aReqStatus, const TDesC& aFCString, TMobilePhoneNetworkService aService, TMobilePhoneServiceAction aAction) const;
	IMPORT_C void GetFeatureCode(TRequestStatus& aReqStatus, TDes& aFCString, TMobilePhoneNetworkService aService, TMobilePhoneServiceAction aAction) const;

	IMPORT_C void SendNetworkServiceRequest(TRequestStatus& aReqStatus, const TDesC& aServiceString) const;
	IMPORT_C void SendNetworkServiceRequestNoFdnCheck(TRequestStatus& aReqStatus, const TDesC& aServiceString) const;

	//
	// MobilePhoneCallForwarding functional unit
	// 

	enum TMobilePhoneCFCondition
		{
		ECallForwardingUnspecified,
		ECallForwardingUnconditional,
		ECallForwardingBusy,
		ECallForwardingNoReply,
		ECallForwardingNotReachable,
		ECallForwardingAllCases,			// combination of all four above cases
		ECallForwardingAllConditionalCases	// combination of CFB, CFNRy and CFNRc
		};

	enum TMobilePhoneCFStatus
		{
		ECallForwardingStatusActive,
		ECallForwardingStatusNotActive,
		ECallForwardingStatusNotRegistered,
		ECallForwardingStatusNotProvisioned,
		ECallForwardingStatusNotAvailable,
		ECallForwardingStatusUnknown
		};

	/**
	* \class TMobilePhoneCFInfoEntryV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines information about the call forwarding service
	*
	*/

	class TMobilePhoneCFInfoEntryV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneCFInfoEntryV1();
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		TMobilePhoneCFCondition iCondition;
		TMobileService iServiceGroup;
		TMobilePhoneCFStatus iStatus;
		TMobileAddress iNumber;
		TInt iTimeout; // valid for CFRNy only
		};

	IMPORT_C void NotifyCallForwardingStatusChange(TRequestStatus& aReqStatus, TMobilePhoneCFCondition& aCondition) const;

	class TMobilePhoneCFChangeV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneCFChangeV1();
	public:
		TMobileService iServiceGroup;
		TMobilePhoneServiceAction iAction;
		TMobileAddress iNumber;
		TInt iTimeout;
		};

	IMPORT_C void SetCallForwardingStatus(TRequestStatus& aReqStatus, TMobilePhoneCFCondition aCondition, const TMobilePhoneCFChangeV1& aInfo) const;

	enum TMobilePhoneCFActive
		{
		ECFUnconditionalActive,
		ECFConditionalActive
		};

	IMPORT_C void NotifyCallForwardingActive(TRequestStatus& aReqStatus, TMobileService& aServiceGroup, TMobilePhoneCFActive& aActiveType) const;

	//
	// Mobile Identity Service functional unit
	// 

	enum TMobilePhoneIdService
		{
		EIdServiceUnspecified,
		EIdServiceCallerPresentation,
		EIdServiceCallerRestriction,
		EIdServiceConnectedPresentation,
		EIdServiceConnectedRestriction,
		EIdServiceCallerName
		};

	enum TMobilePhoneIdServiceStatus
		{
		EIdServiceActivePermanent,
		EIdServiceActiveDefaultRestricted,
		EIdServiceActiveDefaultAllowed,
		EIdServiceNotProvisioned,
		EIdServiceUnknown
		};

	// for use by client-side API code and TSY only

	struct TIdServiceAndLocation
		{
		TMobilePhoneIdService iService;
		TMobileInfoLocation iLocation;
		};

	IMPORT_C void GetIdentityServiceStatus(TRequestStatus& aReqStatus, TMobilePhoneIdService aService, TMobilePhoneIdServiceStatus& aStatus, TMobileInfoLocation aLocation = EInfoLocationCachePreferred) const;

	//
	// Mobile Call Barring Functional Unit
	//

	enum TMobilePhoneCBCondition
		{
		EBarUnspecified,
		EBarAllIncoming,
		EBarIncomingRoaming,
		EBarAllOutgoing,
		EBarOutgoingInternational,
		EBarOutgoingInternationalExHC,
		EBarAllCases
		};

	enum TMobilePhoneCBStatus
		{
		ECallBarringStatusActive,
		ECallBarringStatusNotActive,
		ECallBarringStatusNotProvisioned,
		ECallBarringStatusNotAvailable,
		ECallBarringStatusUnknown
		};

	/**
	* \class TMobilePhoneCBInfoEntryV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines information about the call barring service
	*
	*/

	class TMobilePhoneCBInfoEntryV1 : public TMultimodeType
		{
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		IMPORT_C TMobilePhoneCBInfoEntryV1();
	public:
		TMobilePhoneCBCondition iCondition;
		TMobileService iServiceGroup;
		TMobilePhoneCBStatus iStatus;
		};
	
	class TMobilePhoneCBChangeV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneCBChangeV1();
	public:
		TMobileService iServiceGroup;
		TMobilePhoneServiceAction iAction;
		TMobilePassword iPassword;
		};

	IMPORT_C void SetCallBarringStatus(TRequestStatus& aReqStatus, TMobilePhoneCBCondition aCondition, const TMobilePhoneCBChangeV1& aInfo) const;
	IMPORT_C void NotifyCallBarringStatusChange(TRequestStatus& aReqStatus, TMobilePhoneCBCondition& aCondition) const;
	
	class TMobilePhonePasswordChangeV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhonePasswordChangeV1();
	public:
		TMobilePassword iOldPassword;
		TMobilePassword iNewPassword;
		};

	IMPORT_C void SetCallBarringPassword(TRequestStatus& aReqStatus, const TMobilePhonePasswordChangeV1& aPassword) const;

	//
	// Mobile Call Waiting Functional Unit
	//
	
	enum TMobilePhoneCWStatus
		{
		ECallWaitingStatusActive,
		ECallWaitingStatusNotActive,
		ECallWaitingStatusNotProvisioned,
		ECallWaitingStatusNotAvailable,
		ECallWaitingStatusUnknown
		};

	/**
	* \class TMobilePhoneCWInfoEntryV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines information about the call waiting service
	*
	*/

	class TMobilePhoneCWInfoEntryV1 : public TMultimodeType
		{
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		IMPORT_C TMobilePhoneCWInfoEntryV1();
	public:
		TMobileService iServiceGroup;
		TMobilePhoneCWStatus iStatus;
		};

	typedef TPckg<TMobilePhoneCWInfoEntryV1> TMobilePhoneCWInfoEntryV1Pckg;

	IMPORT_C void SetCallWaitingStatus(TRequestStatus& aReqStatus, TMobileService aServiceGroup, TMobilePhoneServiceAction aAction) const;
	IMPORT_C void NotifyCallWaitingStatusChange(TRequestStatus& aReqStatus, TDes8& aCWStatus) const;

	//
	// Mobile Call Completion Unit
	//

	enum TMobilePhoneCCBSStatus
		{
		ECcbsActive,
		ECcbsNotActive,
		ECcbsNotProvisioned,
		ECcbsNotAvailable,
		ECcbsUnknown
		};
	/**
	* \class TMobilePhoneCCBSEntryV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines information about the call completion (CCBS) service
	*
	*/

	class TMobilePhoneCCBSEntryV1 : public TMultimodeType
		{
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		IMPORT_C TMobilePhoneCCBSEntryV1();
	public:
		TInt			iCcbsIndex;
		TMobileService	iServiceGroup;
		TMobileAddress	iDestination;
		};

	typedef TPckg<TMobilePhoneCCBSEntryV1> TMobilePhoneCCBSEntryV1Pckg;

	IMPORT_C void GetCCBSStatus(TRequestStatus& aReqStatus, TMobilePhoneCCBSStatus& aCcbsStatus, TMobileInfoLocation aLocation = EInfoLocationCachePreferred) const;
	IMPORT_C void NotifyCCBSStatusChange(TRequestStatus& aReqStatus, TMobilePhoneCCBSStatus& aCcbsStatus) const;
	IMPORT_C void DeactivateCCBS(TRequestStatus& aReqStatus, TInt aIndex) const;
	IMPORT_C void NotifyCCBSRecall(TRequestStatus& aReqStatus, TDes8& aCCBSEntry) const;
	IMPORT_C void AcceptCCBSRecall(TRequestStatus& aReqStatus, TInt aIndex, TName& aCallName) const;
	IMPORT_C TInt RefuseCCBSRecall(TInt aIndex) const;

	
	//
	// Mobile Alternating Call Function Unit
	//

	enum TMobilePhoneAlternatingCallCaps
		{
		KCapsMOVoiceData = 0x00000001,
		KCapsMOVoiceThenData = 0x00000002,
		KCapsMOVoiceFax	= 0x00000004,
		KCapsMTVoiceData = 0x00000008,
		KCapsMTVoiceThenData = 0x00000010,
		KCapsMTVoiceFax = 0x00000020
		};

	IMPORT_C TInt GetAlternatingCallCaps(TUint32& aCaps) const;
	IMPORT_C void NotifyAlternatingCallCapsChange(TRequestStatus& aReqStatus, TUint32& aCaps) const;

	enum TMobilePhoneAlternatingCallMode
		{
		EAlternatingModeUnspecified,
		EAlternatingModeSingle,
		EAlternatingModeVoiceData,
		EAlternatingModeVoiceThenData,
		EAlternatingModeVoiceFax
		};

	IMPORT_C TInt GetAlternatingCallMode(TMobilePhoneAlternatingCallMode& aMode, TMobileService& aFirstService) const;
	IMPORT_C void SetAlternatingCallMode(TRequestStatus& aReqStatus, TMobilePhoneAlternatingCallMode aMode, TMobileService aFirstService) const;
	IMPORT_C void NotifyAlternatingCallModeChange(TRequestStatus& aReqStatus, TMobilePhoneAlternatingCallMode& aMode,TMobileService& aFirstService) const;

	//
	// Mobile Alternate Line Service Functional Unit
	//

	enum TMobilePhoneALSLine
		{
		EAlternateLinePrimary,
		EAlternateLineAuxiliary,
		EAlternateLineUnknown,
		EAlternateLineNotAvailable
		};

	typedef TPckg<TMobilePhoneALSLine> TMobilePhoneALSLinePckg;

	IMPORT_C TInt GetALSLine(TMobilePhoneALSLine& aALSLine) const;
	IMPORT_C void SetALSLine(TRequestStatus& aReqStatus, TMobilePhoneALSLine aALSLine) const;
	IMPORT_C void NotifyALSLineChange(TRequestStatus& aReqStatus, TMobilePhoneALSLine& aALSLine) const;

	//
	// Mobile Cost Functional Unit
	//

	enum TMobilePhoneCostCaps
		{
		KCapsCostInformation = 0x00000001,
		KCapsCostCharging = 0x00000002,
		KCapsClearCost = 0x00000004,
		KCapsSetMaxCost = 0x00000008,
		KCapsSetPuct = 0x00000010,
		KCapsGetCost = 0x00000020,
		KCapsNotifyCostChange = 0x00000040
		};

	IMPORT_C TInt GetCostCaps(TUint32& aCaps) const;
	IMPORT_C void NotifyCostCapsChange(TRequestStatus& aReqStatus, TUint32& aCaps) const;

	enum TMobilePhoneCostMeters
		{
		EClearCCM,
		EClearACM,
		EClearAll
		};

	IMPORT_C void ClearCostMeter(TRequestStatus& aReqStatus, TMobilePhoneCostMeters aMeter) const;
	IMPORT_C void SetMaxCostMeter(TRequestStatus& aReqStatus, TUint aUnits) const;

	/**
	* \class TMobilePhonePuctV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines the contents of the price/unit & currency table (PUCT) on the SIM
	*
	*/
	
	class  TMobilePhonePuctV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhonePuctV1();
	public:
		TReal   iPricePerUnit;
		TBuf<4> iCurrencyName;
		};

	typedef TPckg<TMobilePhonePuctV1> TMobilePhonePuctV1Pckg;
	
	IMPORT_C void SetPuct(TRequestStatus& aReqStatus, const TDesC8& aPuct) const;
	
	enum TMobilePhoneCostService
		{
		ECostServiceUnknown,
		ECostServiceNotAvailable,
		ECostServiceAvailable,
		ECostServiceInformation,
		ECostServiceCharging
		};

	/**
	* \class TMobilePhoneCostInfoV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines the information related to current billing costs
	*
	*/

	class TMobilePhoneCostInfoV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneCostInfoV1();
	public:
		TMobilePhoneCostService iService;
		TUint iCCM;
		TUint iACM;
		TUint iACMmax;
		TMobilePhonePuctV1 iPuct;
		};

	typedef TPckg<TMobilePhoneCostInfoV1> TMobilePhoneCostInfoV1Pckg;

	IMPORT_C void GetCostInfo(TRequestStatus& aReqStatus, TDes8& aCostInfo) const;
	IMPORT_C void NotifyCostInfoChange(TRequestStatus& aReqStatus, TDes8& aCostInfo) const;

	//
	// Mobile Security Functional Unit
	//

	enum TMobilePhoneSecurityCaps
		{
		KCapsLockPhone = 0x0000001,
		KCapsLockICC = 0x00000002,
		KCapsLockPhoneToICC = 0x00000004,
		KCapsLockPhoneToFirstICC = 0x00000008,
		KCapsLockOTA = 0x00000010,
		KCapsAccessPin1 = 0x00000020,
		KCapsAccessPin2 = 0x00000040,
		KCapsAccessPhonePassword = 0x00000080,
		KCapsAccessSPC = 0x00000100
		};

	IMPORT_C TInt GetSecurityCaps(TUint32& aCaps) const;
	IMPORT_C void NotifySecurityCapsChange(TRequestStatus& aReqStatus, TUint32& aCaps) const;

	enum TMobilePhoneLock
		{
		ELockPhoneDevice,
		ELockICC,
		ELockPhoneToICC,
		ELockPhoneToFirstICC,
		ELockOTA
		};

	enum TMobilePhoneLockStatus
		{
		EStatusLockUnknown,
		EStatusLocked,
		EStatusUnlocked
		};

	enum TMobilePhoneLockSetting
		{
		ELockSetUnknown,
		ELockSetEnabled,
		ELockSetDisabled
		};

	/**
	* \class TMobilePhoneLockInfoV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines the status of a phone lock
	*
	*/

	class TMobilePhoneLockInfoV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneLockInfoV1();
	public:
		TMobilePhoneLockStatus iStatus;
		TMobilePhoneLockSetting iSetting;
		};

	typedef TPckg<TMobilePhoneLockInfoV1> TMobilePhoneLockInfoV1Pckg;

	IMPORT_C void GetLockInfo(TRequestStatus& aReqStatus, TMobilePhoneLock aLock, TDes8& aLockInfo) const;
	IMPORT_C void NotifyLockInfoChange(TRequestStatus& aReqStatus, TMobilePhoneLock& aLock, TDes8& aLockInfo) const;
	IMPORT_C void SetLockSetting(TRequestStatus& aReqStatus, TMobilePhoneLock aLock, TMobilePhoneLockSetting aSetting) const;

	enum TMobilePhoneSecurityCode
		{
		ESecurityCodePin1,
		ESecurityCodePin2,
		ESecurityCodePuk1,
		ESecurityCodePuk2,
		ESecurityCodePhonePassword,
		ESecurityCodeSPC
		};

	IMPORT_C void ChangeSecurityCode(TRequestStatus& aReqStatus, TMobilePhoneSecurityCode aType, const TMobilePhonePasswordChangeV1& aChange) const;

	enum TMobilePhoneSecurityEvent
		{
		ENoICCFound,
		EICCTerminated,
		EPin1Required,
		EPuk1Required,
		EPin2Required,
		EPuk2Required,
		EPhonePasswordRequired,
		ESPCRequired,
		EPin1Verified,
		EPin2Verified,
		EPuk1Verified,
		EPuk2Verified,
		EPhonePasswordVerified,
		ESPCVerified
		};

	IMPORT_C void NotifySecurityEvent(TRequestStatus& aReqStatus, TMobilePhoneSecurityEvent& aEvent) const;

	// for use by client-side API code and TSY only

	struct TCodeAndUnblockCode
		{
		TMobilePassword iCode;
		TMobilePassword iUnblockCode;
		};	

	IMPORT_C void VerifySecurityCode(TRequestStatus& aReqStatus, TMobilePhoneSecurityCode aType,
		const TMobilePassword& aCode, const TMobilePassword& aUnblockCode) const;
	IMPORT_C TInt AbortSecurityCode(TMobilePhoneSecurityCode aType) const;

	
	// 
	// MobileMessageWaiting
	//
	
	enum TMobilePhoneIndicatorDisplay
		{
		KDisplayVoicemailActive = 0x01,
		KDisplayFaxActive = 0x02,
		KDisplayEmailActive = 0x04,
		KDisplayOtherActive = 0x08,
		KDisplayAuxVoicemailActive = 0x10,
		KDisplayDataActive = 0x20
		};

	class TMobilePhoneMessageWaitingV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneMessageWaitingV1();
	public:
		TUint8	iDisplayStatus;
		TUint8	iVoiceMsgs;
		TUint8	iAuxVoiceMsgs;
		TUint8	iDataMsgs;
		TUint8	iFaxMsgs;
		TUint8	iEmailMsgs;
		TUint8	iOtherMsgs;
		};

	typedef TPckg<TMobilePhoneMessageWaitingV1> TMobilePhoneMessageWaitingV1Pckg;

	IMPORT_C void GetIccMessageWaitingIndicators(TRequestStatus& aReqStatus, TDes8& aMsgIndicators) const;
	IMPORT_C void SetIccMessageWaitingIndicators(TRequestStatus& aReqStatus, const TDesC8& aMsgIndicators) const;
	IMPORT_C void NotifyIccMessageWaitingIndicatorsChange(TRequestStatus& aReqStatus, TDes8& aMsgIndicators) const;

	IMPORT_C void NotifyMessageWaiting(TRequestStatus& aReqStatus, TInt& aCount) const;

	//
	// Mobile Fixed Dialling Numbers Functional Unit
	//

	enum TMobilePhoneFdnStatus
		{
		EFdnNotActive,
		EFdnActive,
		EFdnPermanentlyActive,
		EFdnNotSupported,
		EFdnUnknown
		};

	IMPORT_C TInt GetFdnStatus(TMobilePhoneFdnStatus& aFdnStatus) const;
	IMPORT_C void GetFdnStatus(TRequestStatus& aReqStatus, TMobilePhoneFdnStatus& aFdnStatus) const;

	enum TMobilePhoneFdnSetting
		{
		EFdnSetOn,
		EFdnSetOff
		};

	IMPORT_C void SetFdnSetting(TRequestStatus& aReqStatus, TMobilePhoneFdnSetting aFdnSetting) const;
	IMPORT_C void NotifyFdnStatusChange(TRequestStatus& aReqStatus, TMobilePhoneFdnStatus& aFdnStatus) const;

	//
	// Multicall bearer settings
	//

	class TMobilePhoneMulticallSettingsV1 : public TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneMulticallSettingsV1();
	public:
		TInt iUserMaxBearers;
		TInt iServiceProviderMaxBearers;
		TInt iNetworkSupportedMaxBearers;
		TInt iUESupportedMaxBearers;
		};

	typedef TPckg<TMobilePhoneMulticallSettingsV1> TMobilePhoneMulticallSettingsV1Pckg;

	IMPORT_C void GetMulticallParams(TRequestStatus& aReqStatus, TDes8& aMulticallParams) const;
	IMPORT_C void SetMulticallParams(TRequestStatus& aReqStatus, TInt aUserMaxBearers) const;
	IMPORT_C void NotifyMulticallParamsChange(TRequestStatus& aReqStatus, TDes8& aMulticallParams) const;

	//
	// MobileNextIncomingCall Functional Unit
	//

	enum TMobilePhoneIncomingCallType
		{
		EIncomingTypeNotSpecified,
		EIncomingVoice,
		EIncomingFax,
		EIncomingData,
		EIncomingMultimediaVoiceFallback,
		EIncomingMultimediaNoFallback
		};

	IMPORT_C void GetIncomingCallType(TRequestStatus& aReqStatus, TMobilePhoneIncomingCallType& aCallType, TDes8& aDataParams) const;
	IMPORT_C void SetIncomingCallType(TRequestStatus& aReqStatus, TMobilePhoneIncomingCallType aCallType, TDes8& aDataParams) const;
	IMPORT_C void NotifyIncomingCallTypeChange(TRequestStatus& aReqStatus, TMobilePhoneIncomingCallType& aCallType, TDes8& aDataParams) const;

	//
	// User-To-User Signalling Functional Unit
	//

	enum TMobilePhoneUUSSetting         // UUS settings of the phone
		{
		EIncomingUUSNotSpecified,
		EIncomingUUSAccepted,
		EIncomingUUSRejected
		};

	IMPORT_C void GetUUSSetting(TRequestStatus& aReqStatus, TMobilePhoneUUSSetting& aSetting) const;
	IMPORT_C void SetUUSSetting(TRequestStatus& aReqStatus, TMobilePhoneUUSSetting aSetting) const;
	IMPORT_C void NotifyUUSSettingChange(TRequestStatus& aReqStatus, TMobilePhoneUUSSetting& aSetting) const;

private:
	CMobilePhonePtrHolder* iMmPtrHolder;
	RMobilePhone(const RMobilePhone& aPhone);
protected:
	IMPORT_C void ConstructL();
	IMPORT_C void Destruct();
	};

/*********************************************************/
//
// Phone Storage functionality (RMobilePhoneStore)
//
/*********************************************************/

/**
 * \class RMobilePhoneStore ETELMM.H "INC/ETELMM.H"
 * \brief Abstract class used to define common phone storage actions & types
 *
 * RMobilePhoneStore inherits from RTelSubSessionBase defined in ETEL.H
 * Clients open one of the specialised phone store classes that are derived from RMobilePhoneStore
 */

class CMobilePhoneStorePtrHolder;
class RMobilePhoneStore : public RTelSubSessionBase
	{
public:
	friend class CAsyncRetrieveStoreList;

	enum TMobilePhoneStoreType
		{
		EPhoneStoreTypeUnknown,
		EShortMessageStore,
		ENamStore,
		EPhoneBookStore,
		EEmergencyNumberStore,
		EOwnNumberStore
		};

	enum TMobilePhoneStoreCaps
		{
		KCapsWholeStore			= 0x80000000,
		KCapsIndividualEntry	= 0x40000000,
		KCapsReadAccess			= 0x20000000,
		KCapsWriteAccess		= 0x10000000,
		KCapsDeleteAll			= 0x08000000,
		KCapsNotifyEvent		= 0x04000000
		};

	enum TMobilePhoneStoreInfoExtId
		{
		KETelMobilePhoneStoreV1=KETelExtMultimodeV1,
		KETelMobilePhonebookStoreV1,
		KETelMobileSmsStoreV1,
		KETelMobileNamStoreV1,
		KETelMobileONStoreV1,
		KETelMobileENStoreV1
		};

	/**
	* \class TMobilePhoneStoreInfoV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines information and capabilities of a phone-side store
	*
	*/

	class TMobilePhoneStoreInfoV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobilePhoneStoreInfoV1();

		TMobilePhoneStoreType		iType;
		TInt						iTotalEntries;
		TInt						iUsedEntries;
		TUint32						iCaps;
		RMobilePhone::TMobileName	iName;
		};

	typedef TPckg<TMobilePhoneStoreInfoV1> TMobilePhoneStoreInfoV1Pckg;

	/**
	* \class TMobilePhoneStoreEntryV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines common contents of an entry in a phone-side store
	*
	*/

	class TMobilePhoneStoreEntryV1 : public RMobilePhone::TMultimodeType
		{
	public:

		enum
			{
			KIndexNotUsed = -1
			};

	protected:
		TMobilePhoneStoreEntryV1();
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		TInt  iIndex;
		};

	IMPORT_C void GetInfo(TRequestStatus& aReqStatus, TDes8& aInfo) const;

	IMPORT_C void Read(TRequestStatus& aReqStatus, TDes8& aEntry) const;
	IMPORT_C void Write(TRequestStatus& aReqStatus, TDes8& aEntry) const;

	IMPORT_C void Delete(TRequestStatus& aReqStatus, TInt aIndex) const;
	IMPORT_C void DeleteAll(TRequestStatus& aReqStatus) const;

	enum TMobileStoreEvent
		{
		KStoreFull =0x00000001,
		KStoreHasSpace =0x00000002,
		KStoreEmpty =0x00000004,
		KStoreEntryAdded =0x00000008,
		KStoreEntryDeleted =0x00000010,
		KStoreEntryChanged =0x00000020,
		KStoreDoRefresh =0x00000040
		};

	IMPORT_C void NotifyStoreEvent(TRequestStatus& aReqStatus, TUint32& aEvent, TInt& aIndex) const;

protected:
	CMobilePhoneStorePtrHolder* iStorePtrHolder;

protected:
	RMobilePhoneStore();
	IMPORT_C void BaseConstruct(CMobilePhoneStorePtrHolder* aPtrHolder);
	IMPORT_C void Destruct();
	};


/*********************************************************/
//
// Call based functionality (RMobileCall)
// 
/*********************************************************/

/**
 * \class RMobileCall ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to mobile call functionality provided by TSY
 *
 * RMobileCall inherits from RCall defined in ETEL.H
 */

class CMobileCallPtrHolder;

class RMobileCall : public RCall
	{
public:
	IMPORT_C RMobileCall();

	//
	//  Mobile call parameters - used within Dial/Answer API
	// 

	// used to set iExtensionId in RCall::TCallParams
	enum TMobileCallParamsExtensionId
		{
		KETelMobileCallParamsV1=KETelExtMultimodeV1,
		KETelMobileDataCallParamsV1,
		KETelMobileHscsdCallParamsV1
		};

	enum TMobileCallIdRestriction
		{
		EIdRestrictDefault,
		ESendMyId,
		EDontSendMyId
		};

	class TMobileCallCugV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileCallCugV1();
	public:
		TBool	iExplicitInvoke;
		TInt	iCugIndex;
		TBool	iSuppressOA;
		TBool	iSuppressPrefCug;
		};

	/**
	* \class TMobileCallParamsV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines the parameters used for set-up of a call of any type
	*
	*/

	class TMobileCallParamsV1 : public RCall::TCallParams 
		{
	public:
		IMPORT_C TMobileCallParamsV1();
	public:
		TMobileCallIdRestriction iIdRestrict;
		TMobileCallCugV1 iCug;
		TBool iAutoRedial;
		};

	typedef TPckg<TMobileCallParamsV1> TMobileCallParamsV1Pckg;

	//
	// Mobile Call Data Functional Unit
	//

	enum TMobileCallDataSpeedCaps
		{
		KCapsSpeedAutobauding = 0x00000001,
		KCapsSpeed2400  = 0x00000002,
		KCapsSpeed4800  = 0x00000004,
		KCapsSpeed9600  = 0x00000008,
		KCapsSpeed14400 = 0x00000010,
		KCapsSpeed19200 = 0x00000020,
		KCapsSpeed28800 = 0x00000040,
		KCapsSpeed32000 = 0x00000080,
		KCapsSpeed33600 = 0x00000100,
		KCapsSpeed38400 = 0x00000200,
		KCapsSpeed43200 = 0x00000400,
		KCapsSpeed48000 = 0x00000800,
		KCapsSpeed56000 = 0x00001000,
		KCapsSpeed57600 = 0x00002000,
		KCapsSpeed64000 = 0x00004000,
		KCapsSpeedExtended = 0x80000000		
		};

	enum TMobileCallDataProtocolCaps
		{
		KCapsProtocolV22bis = 0x00000001,
		KCapsProtocolV32 = 0x00000002,
		KCapsProtocolV34 = 0x00000004,
		KCapsProtocolV110 = 0x00000008,
		KCapsProtocolV120 = 0x00000010,
		KCapsProtocolBitTransparent = 0x00000020,
		KCapsProtocolX31FlagStuffing = 0x00000040,
		KCapsProtocolPIAFS = 0x00000080,
		KCapsPstnMultimediaVoiceFallback = 0x00000100,
		KCapsPstnMultimedia = 0x00000200,
		KCapsIsdnMultimedia = 0x00000400,
		KCapsProtocolExtended = 0x80000000
		};

	enum TMobileCallDataServiceCaps
		{
		KCapsDataCircuitAsynchronous = 0x00000001,
		KCapsDataCircuitAsynchronousRDI = 0x00000002,
		KCapsDataCircuitSynchronous = 0x00000004,
		KCapsDataCircuitSynchronousRDI = 0x00000008,
		KCapsPADAsyncUDI = 0x00000010,
		KCapsPADAsyncRDI = 0x00000020,
		KCapsPacketAccessSyncUDI = 0x00000040,
		KCapsPacketAccessSyncRDI = 0x00000080,
		KCapsServiceExtended = 0x80000000
		};

	enum TMobileCallDataQoSCaps
		{
		KCapsTransparent = 0x00000001,
		KCapsNonTransparent = 0x00000002,
		KCapsTransparentPreferred = 0x00000004,
		KCapsNonTransparentPreferred = 0x00000008
		};

	enum TMobileCallAiurCodingCaps
		{
		KCapsAiurCoding48 = 0x01,
		KCapsAiurCoding96 = 0x04,
		KCapsAiurCoding144 = 0x08
		};

	enum TMobileCallTchCodingsCaps
		{
		KCapsTchCoding48  = 0x00000001,
		KCapsTchCoding96  = 0x00000004,
		KCapsTchCoding144 = 0x00000008,
		KCapsTchCoding288 = 0x00000010,
		KCapsTchCoding320 = 0x00000020,
		KCapsTchCoding432 = 0x00000040
		};

	enum TMobileCallAsymmetryCaps
		{
		KCapsAsymmetryNoPreference= 0x00000001,
		KCapsAsymmetryDownlink = 0x00000002,
		KCapsAsymmetryUplink = 0x00000004
		};

	enum TMobileCallRLPVersionCaps
		{
		KCapsRLPSingleLinkVersion0 = 0x00000001,
		KCapsRLPSingleLinkVersion1 = 0x00000002,
		KCapsRLPMultiLinkVersion2  = 0x00000004
		};

	enum TMobileCallV42bisCaps
		{
		KCapsV42bisTxDirection = 0x00000001,
		KCapsV42bisRxDirection = 0x00000002,
		KCapsV42bisBothDirections = 0x00000004
		};

	/**
	* \class TMobileCallDataCapsV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines the capabilities of a circuit switched data call
	*
	*/

	class TMobileCallDataCapsV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileCallDataCapsV1();
	public:
		TUint32	iSpeedCaps;
		TUint32	iProtocolCaps;
		TUint32	iServiceCaps;
		TUint32	iQoSCaps;
		TBool	iHscsdSupport;
		TInt	iMClass;
		TInt	iMaxRxTimeSlots;
		TInt	iMaxTxTimeSlots;
		TInt	iTotalRxTxTimeSlots;
		TUint32	iCodingCaps;
		TUint32 iAsymmetryCaps;
		TBool 	iUserInitUpgrade;
		TUint32	iRLPVersionCaps;
		TUint32	iV42bisCaps;
		};

	typedef TPckg<TMobileCallDataCapsV1> TMobileCallDataCapsV1Pckg;

	IMPORT_C TInt GetMobileDataCallCaps(TDes8& aCaps) const;
	IMPORT_C void NotifyMobileDataCallCapsChange(TRequestStatus& aReqStatus, TDes8& aCaps) const;

	enum TMobileCallDataSpeed
		{
		ESpeedUnspecified,
		ESpeedAutobauding,
		ESpeed2400,
		ESpeed4800,
		ESpeed9600,
		ESpeed14400,
		ESpeed19200,
		ESpeed28800,
		ESpeed32000,
		ESpeed33600,
		ESpeed38400,
		ESpeed43200,
		ESpeed48000,
		ESpeed56000,
		ESpeed57600,
		ESpeed64000
		};

	enum TMobileCallDataProtocol
		{
		EProtocolUnspecified,
		EProtocolV22bis,
		EProtocolV32,
		EProtocolV34,
		EProtocolV110,
		EProtocolV120,
		EProtocolX31FlagStuffing,
		EProtocolPIAFS,
		EProtocolBitTransparent,
		EProtocolPstnMultimediaVoiceFallback,
		EProtocolPstnMultimedia,
		EProtocolIsdnMultimedia
		};

	enum TMobileCallDataService
		{
		EServiceUnspecified,
		EServiceDataCircuitAsync,
		EServiceDataCircuitAsyncRdi,
		EServiceDataCircuitSync,
		EServiceDataCircuitSyncRdi,
		EServicePADAsyncUDI,
		EServicePADAsyncRDI,
		EServicePacketAccessSyncUDI,
		EServicePacketAccessSyncRDI
		};

	enum TMobileCallDataQoS
		{
		EQoSUnspecified,
		EQoSTransparent,
		EQoSNonTransparent,
		EQosTransparentPreferred,
		EQosNonTransparentPreferred
		};

	enum TMobileCallDataRLPVersion
		{
		ERLPNotRequested,
		ERLPSingleLinkVersion0,
		ERLPSingleLinkVersion1,
		ERLPMultiLinkVersion2
		};

	enum TMobileCallDataV42bis
		{
		EV42bisNeitherDirection,
		EV42bisTxDirection,
		EV42bisRxDirection,
		EV42bisBothDirections
		};

	
	/**
	* \class TMobileDataCallParamsV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines the parameters used for setup of a circuit switched data call
	*
	*/

	class TMobileDataCallParamsV1 : public TMobileCallParamsV1
		{
	public:
		IMPORT_C TMobileDataCallParamsV1();
	public:
		TMobileCallDataService iService;
		TMobileCallDataSpeed iSpeed;
		TMobileCallDataProtocol iProtocol;
		TMobileCallDataQoS iQoS;
		TMobileCallDataRLPVersion iRLPVersion;
		TInt iModemToMSWindowSize;
		TInt iMSToModemWindowSize;
		TInt iAckTimer;
		TInt iRetransmissionAttempts;
		TInt iResequencingPeriod;
		TMobileCallDataV42bis iV42bisReq;
		TInt iV42bisCodewordsNum;
		TInt iV42bisMaxStringLength;
		TBool iUseEdge; // True for ECSD
		};

	typedef TPckg<TMobileDataCallParamsV1> TMobileDataCallParamsV1Pckg;

	enum TMobileCallAiur
		{
		EAiurBpsUnspecified,
		EAiurBps9600,
		EAiurBps14400,
		EAiurBps19200,
		EAiurBps28800,
		EAiurBps38400,
		EAiurBps43200,
		EAiurBps57600
		};

	enum TMobileCallAsymmetry
		{
		EAsymmetryNoPreference,
		EAsymmetryDownlink,
		EAsymmetryUplink
		};

	enum TMobileCallTchCoding
		{
		ETchCodingUnspecified,
		ETchCoding48,
		ETchCoding96,
		ETchCoding144,
		ETchCoding288,
		ETchCoding320,
		ETchCoding432
		};

	/**
	* \class TMobileDataRLPRangesV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines the parameters for minimum and maximum RLP parameter ranges 
	*
	*/

	class TMobileDataRLPRangesV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileDataRLPRangesV1();
	public:
		TInt  iIWSMax;
		TInt  iIWSMin;
		TInt  iMWSMax;
		TInt  iMWSMin;
		TInt  iT1Max;
		TInt  iT1Min;
		TInt  iN2Max;
		TInt  iN2Min;
		TInt  iT4Max;
		TInt  iT4Min;
		};

	typedef TPckg<TMobileDataRLPRangesV1> TMobileDataRLPRangesV1Pckg;

	IMPORT_C void GetMobileDataCallRLPRange(TRequestStatus& aReqStatus, TInt aRLPVersion, TDes8& aRLPRange) const;
	
	class TMobileHscsdCallParamsV1 : public TMobileDataCallParamsV1
		{
	public:
		IMPORT_C TMobileHscsdCallParamsV1();
	public:
		TMobileCallAiur	iWantedAiur;
		TInt iWantedRxTimeSlots;
		TInt iMaxTimeSlots;
		TUint iCodings;
		TMobileCallAsymmetry  iAsymmetry;
		TBool iUserInitUpgrade;
		};

	typedef TPckg<TMobileHscsdCallParamsV1> TMobileHscsdCallParamsV1Pckg;

	IMPORT_C void SetDynamicHscsdParams(TRequestStatus& aReqStatus, TMobileCallAiur aAiur, TInt aRxTimeslots) const;

	class TMobileCallHscsdInfoV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileCallHscsdInfoV1();
	public:
		TMobileCallAiur	iAiur;
		TInt iRxTimeSlots;
		TInt iTxTimeSlots;
		TMobileCallTchCoding iCodings;
		};

	typedef TPckg<TMobileCallHscsdInfoV1> TMobileCallHscsdInfoV1Pckg;

	IMPORT_C TInt GetCurrentHscsdInfo(TDes8& aHSCSDInfo) const;
	IMPORT_C void NotifyHscsdInfoChange(TRequestStatus& aReqStatus, TDes8& aHSCSDInfo) const;

	//
	// Voice Fallback for Multimedia Calls
	//

	IMPORT_C void NotifyVoiceFallback(TRequestStatus& aReqStatus, TName& aCallName) const;

	//
	// Mobile Alternating Call Functional Unit
	//

	IMPORT_C void SwitchAlternatingCall(TRequestStatus& aReqStatus) const;
	IMPORT_C void NotifyAlternatingCallSwitch(TRequestStatus& aReqStatus) const;

	//
	// MobileCallControl functional unit
	//

	enum TMobileCallControlCaps 
		{
		//KCapsData=0x00000001, // taken from etel.h
		//KCapsFax=0x00000002,
		//KCapsVoice=0x00000004,
		//KCapsDial=0x00000008,
		//KCapsConnect=0x00000010,
		//KCapsHangUp=0x00000020,
		//KCapsAnswer=0x00000040,
		//KCapsLoanDataPort=0x00000080, 
		//KCapsRecoverDataPort=0x00000100
		KCapsHold = 0x00000200,
		KCapsResume = 0x00000400,
		KCapsSwap = 0x00000800,
		KCapsDeflect = 0x00001000,
		KCapsTransfer = 0x00002000,
		KCapsJoin = 0x00004000,
		KCapsOneToOne = 0x00008000,
		KCapsActivateCCBS = 0x00010000,
		KCapsSwitchAlternatingCall = 0x00020000
		};


	enum TMobileCallEventCaps
		{
		KCapsLocalHold = 0x00000001,
		KCapsLocalResume = 0x00000002,
		KCapsLocalDeflectCall = 0x00000004,
		KCapsLocalTransfer = 0x00000008,
		KCapsRemoteHold = 0x00000010,
		KCapsRemoteResume = 0x00000020,
		KCapsRemoteTerminate = 0x00000040,
		KCapsRemoteConferenceCreate = 0x00000080
		};

	/**
	* \class TMobileCallCapsV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines the dynamic capabilities of a mobile call
	*
	*/

	class TMobileCallCapsV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileCallCapsV1();
	public:
		TUint32 iCallControlCaps;
		TUint32 iCallEventCaps;
		};

	typedef TPckg<TMobileCallCapsV1> TMobileCallCapsV1Pckg;

	IMPORT_C TInt GetMobileCallCaps(TDes8& aCaps) const;
	IMPORT_C void NotifyMobileCallCapsChange(TRequestStatus& aReqStatus, TDes8& aCaps) const;

	IMPORT_C void Hold(TRequestStatus& aReqStatus) const;
	IMPORT_C void Resume(TRequestStatus& aReqStatus) const;
	IMPORT_C void Swap(TRequestStatus& aReqStatus) const;

	enum TMobileCallDeflect
		{
		EDeflectUnspecified,
		EDeflectVoicemail,
		EDeflectRegisteredNumber,
		EDeflectSuppliedNumber
		};

	IMPORT_C void Deflect(TRequestStatus& aReqStatus, TMobileCallDeflect aDeflectType, const RMobilePhone::TMobileAddress& aDestination) const;
	IMPORT_C void Transfer(TRequestStatus& aReqStatus) const;
	IMPORT_C void GoOneToOne(TRequestStatus& aReqStatus) const;

	enum TMobileCallEvent
		{
		ELocalHold,
		ELocalResume,
		ELocalDeflectCall,
		ELocalTransfer,
		ERemoteHold,
		ERemoteResume,
		ERemoteTerminated,
		ERemoteConferenceCreate
		};

	IMPORT_C void NotifyCallEvent(TRequestStatus& aReqStatus, TMobileCallEvent& aEvent) const;

	enum TMobileCallStatus
		{
		EStatusUnknown,			// same as RCall::EStatusUnknown
		EStatusIdle,			// same as RCall::EStatusIdle
		EStatusDialling,		// same as RCall::EStatusDialling
		EStatusRinging,			// same as RCall::EStatusRinging
		EStatusAnswering,		// same as RCall::EStatusAnswering
		EStatusConnecting,		// same as RCall::EStatusConnecting
		EStatusConnected,		// same as RCall::EStatusConnected
		EStatusDisconnecting,	// same as RCall::EStatusHangingUp
		EStatusDisconnectingWithInband,
		EStatusReconnectPending,
		EStatusHold,
		EStatusWaitingAlternatingCallSwitch
		};

	IMPORT_C TInt GetMobileCallStatus(TMobileCallStatus& aStatus) const;
	IMPORT_C void NotifyMobileCallStatusChange(TRequestStatus& aReqStatus, TMobileCallStatus& aStatus) const;

	IMPORT_C void DialNoFdnCheck(TRequestStatus& aStatus,const TDesC& aTelNumber) const;
	IMPORT_C void DialNoFdnCheck(TRequestStatus& aStatus,const TDesC8& aCallParams,const TDesC& aTelNumber) const;

	//
	// MobilePrivacy functional unit
	//

	IMPORT_C TInt SetPrivacy(RMobilePhone::TMobilePhonePrivacy aPrivacySetting) const;
	IMPORT_C void NotifyPrivacyConfirmation(TRequestStatus& aReqStatus, RMobilePhone::TMobilePhonePrivacy& aPrivacySetting) const;

	//
	// MobileTrafficChannel function unit
	//

	enum TMobileCallTch
		{
		ETchUnknown,
		ETchDigital,
		ETchAnalog
		};

	IMPORT_C TInt SetTrafficChannel(TMobileCallTch aTchRequest) const;
	IMPORT_C void NotifyTrafficChannelConfirmation(TRequestStatus& aReqStatus, TMobileCallTch& aTchType) const;

	//
	// MobileCallInformation functional unit
	// 

	enum TMobileCallRemoteIdentityStatus
		{
		ERemoteIdentityUnknown,
		ERemoteIdentityAvailable,
		ERemoteIdentitySuppressed
		};

	enum TMobileCallDirection
		{
		EDirectionUnknown,
		EMobileOriginated,
		EMobileTerminated
		};

	enum { KCallingNameSize=80 };

	/**
	* \class TMobileCallRemotePartyInfoV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines information about the remote party of a mobile call
	*
	*/

	class TMobileCallRemotePartyInfoV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileCallRemotePartyInfoV1();
	public:
		TMobileCallRemoteIdentityStatus iRemoteIdStatus;
		TMobileCallDirection iDirection;
		RMobilePhone::TMobileAddress iRemoteNumber;
		TBuf<KCallingNameSize> iCallingName;
		};
	
	typedef TPckg<TMobileCallRemotePartyInfoV1> TMobileCallRemotePartyInfoV1Pckg;
	
	IMPORT_C void NotifyRemotePartyInfoChange(TRequestStatus& aReqStatus, TDes8& aRemotePartyInfo) const;
	
	enum TMobileCallInfoFlags
		{
		KCallStartTime		= 0x00000001,
		KCallDuration		= 0x00000002,
		KCallId				= 0x00000004,
		KCallRemoteParty	= 0x00000008,
		KCallDialledParty	= 0x00000010,
		KCallExitCode		= 0x00000020,
		KCallEmergency		= 0x00000040,
		KCallForwarded		= 0x00000080,
		KCallPrivacy		= 0x00000100,
		KCallTch			= 0x00000200,
		KCallAlternating	= 0x00000400
		};

	/**
	* \class TMobileCallInfoV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines general information about a mobile call
	*
	*/

	class TMobileCallInfoV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileCallInfoV1();
	public:
		TUint32 iValid;
		RMobilePhone::TMobileService iService;
		TMobileCallStatus iStatus;
		TInt iCallId;
		TInt iExitCode;
		TBool iEmergency;
		TBool iForwarded;
		RMobilePhone::TMobilePhonePrivacy iPrivacy;
		RMobilePhone::TMobilePhoneAlternatingCallMode iAlternatingCall;
		TTimeIntervalSeconds iDuration;
		TMobileCallTch iTch;
		TMobileCallRemotePartyInfoV1 iRemoteParty;
		RMobilePhone::TMobileAddress iDialledParty;
		TDateTime iStartTime;
		TName iCallName;
		TName iLineName;
		};

	typedef TPckg<TMobileCallInfoV1> TMobileCallInfoV1Pckg;

	IMPORT_C TInt GetMobileCallInfo(TDes8& aCallInfo) const;
	
	//
	// MobileCallEmergency functional unit
	// 

	IMPORT_C void DialEmergencyCall(TRequestStatus& aReqStatus, const TDesC& aNumber) const;

	//
	// MobileCallCompletion
	//

	IMPORT_C void ActivateCCBS(TRequestStatus& aReqStatus, TInt& aIndex) const;
	IMPORT_C TInt RejectCCBS() const;
		//
	// User-To-User Signalling Functional Unit
	//

	enum TMobileCallUUSCaps			// UUS capabilities of the call
		{
		KCapsSetupUUS1Implicit=0x00000001,
		KCapsSetupUUS1Explicit=0x00000002,
		KCapsSetupUUS2=0x00000004,
		KCapsSetupUUS3=0x00000008,
		KCapsSetupMultipleUUS=0x00000010,
		KCapsActiveUUS1=0x00000020,
		KCapsActiveUUS2=0x00000040,
		KCapsActiveUUS3=0x00000080
		};

	IMPORT_C TInt GetUUSCaps(TUint32& aCaps) const;
	IMPORT_C void NotifyUUSCapsChange(TRequestStatus& aReqStatus, TUint32& aCaps) const;

	enum TMobileCallUUSReqs			// UUS Service requests
		{
		KUUS1Implicit=0x00000001,
		KUUS1ExplicitRequested=0x00000002,
		KUUS1ExplicitRequired=0x00000004,
		KUUS2Requested=0x00000008,
		KUUS2Required=0x00000010,
		KUUS3Requested=0x00000020,
		KUUS3Required=0x00000040
		};

	enum 
		{
		KMaxUUISize = 129,
		};

	typedef TBuf<KMaxUUISize> TMobileCallUUI;

	class  TMobileCallUUSRequestV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C  TMobileCallUUSRequestV1();
	public:
		TUint             iServiceReq;
		TMobileCallUUI	  iUUI;
		};
	
	typedef TPckg<TMobileCallUUSRequestV1> TMobileCallUUSRequestV1Pckg;

	IMPORT_C void ActivateUUS(TRequestStatus& aReqStatus, const TDesC8& aUUSRequest) const;
	IMPORT_C void SendUUI(TRequestStatus& aReqStatus, TBool aMore, const TMobileCallUUI& aUUI) const;
	IMPORT_C void ReceiveUUI(TRequestStatus& aReqStatus, TMobileCallUUI& aUUI) const;
	IMPORT_C void HangupWithUUI(TRequestStatus& aReqStatus, const TMobileCallUUI& aUUI) const;
	IMPORT_C void AnswerIncomingCallWithUUI(TRequestStatus& aReqStatus, const TDesC8& aCallParams, const TMobileCallUUI& aUUI) const;
	
private:
	RMobileCall(const RMobileCall& aCall);
	CMobileCallPtrHolder* iMmPtrHolder;
protected:
	IMPORT_C void ConstructL();
	IMPORT_C void Destruct();
	};


/*********************************************************/
//
// Line based functionality (RMobileLine)
// 
/*********************************************************/

/**
 * \class RMobileLine ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to mobile line functionality provided by TSY
 *
 * RMobileLine inherits from RLine defined in ETEL.H
 */

class CMobileLinePtrHolder;

class RMobileLine : public RLine
	{
public:
	IMPORT_C RMobileLine();

	//
	// MobileLineStatus functional unit
	// 

	IMPORT_C TInt GetMobileLineStatus(RMobileCall::TMobileCallStatus& aStatus) const;
	IMPORT_C void NotifyMobileLineStatusChange(TRequestStatus& aReqStatus, RMobileCall::TMobileCallStatus& aStatus) const;

private:
	RMobileLine(const RMobileLine& aLine);
	CMobileLinePtrHolder* iMmPtrHolder;
protected:
	IMPORT_C void ConstructL();
	IMPORT_C void Destruct();
	};


/*********************************************************/
//
// SMS Messaging (RMobileSmsMessaging)
// 
/*********************************************************/

/**
 * \class RMobileSmsMessaging ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to SMS messaging functionality provided by TSY
 *
 * RMobileSmsMessaging inherits from RTelSubSessionBase defined in ETEL.H
 */

class CMobilePhoneSmspList;
class CSmsMessagingPtrHolder;

class RMobileSmsMessaging : public RTelSubSessionBase
	{
public:

	friend class CRetrieveMobilePhoneSmspList;

	IMPORT_C RMobileSmsMessaging();

	IMPORT_C TInt Open(RMobilePhone& aPhone);
	IMPORT_C void Close();

	/**
	* \class TMobileSmsCapsV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines capabilities of SMS messaging
	*
	*/

	enum TMobileSmsModeCaps
		{
		KCapsGsmSms=0x00000001,
		KCapsCdmaSms=0x00000002
		};

	enum TMobileSmsControlCaps
		{
		KCapsReceiveStored=0x00000001,
		KCapsReceiveUnstoredPhoneAck=0x00000002,
		KCapsReceiveUnstoredClientAck=0x00000004,
		KCapsReceiveEither=0x00000008,
		KCapsCreateAck=0x00000010,
		KCapsSendNoAck=0x00000020,
		KCapsSendWithAck=0x00000040,
		KCapsGetSmspList=0x00000080,
		KCapsSetSmspList=0x00000100
		};

	class TMobileSmsCapsV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileSmsCapsV1();

		TUint32 iSmsMode;
		TUint32 iSmsControl;
		};

	typedef TPckg<TMobileSmsCapsV1> TMobileSmsCapsV1Pckg;

	IMPORT_C TInt GetCaps(TDes8& aCaps) const;

	// Definitions for sizes of TPDU and User Data fields
	enum 
		{ 
		KGsmTpduSize = 165,		// 140 bytes user data + 25 bytes TPDU header
		KCdmaTpduSize  = 256	// Max size of Bearer Data in Transport Layer message
		};

	typedef TBuf8<KGsmTpduSize>			TMobileSmsGsmTpdu;
	typedef TBuf8<KCdmaTpduSize>		TMobileSmsCdmaTpdu;

	//
	// Enum used by TSY to distinguish which SMS attribute class is used by client
	//

	enum TMobileSmsAttributeExtensionId
		{
		KETelMobileSmsAttributesV1=KETelExtMultimodeV1,
		KETelMobileSmsReceiveAttributesV1,
		KETelMobileSmsSendAttributesV1
		};

	/**
	* \class TMobileSmsAttributesV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines common attributes of all SMS messages
	*
	*/

	enum TMobileSmsAttributeFlags
		{
		KCdmaTeleservice = 0x00000001,
		KCdmaServiceCategory = 0x00000002,
		KGsmServiceCentre = 0x00000004,
		KSmsDataFormat = 0x00000008,	
		KRemotePartyInfo = 0x00000010,
		KIncomingStatus = 0x00000020,
		KStorageLocation = 0x00000040,
		KMessageReference = 0x00000080,
		KGsmSubmitReport = 0x00000100,
		KMoreToSend = 0x00000200
		};

	enum TMobileSmsDataFormat
		{
		EFormatUnspecified,
		EFormatGsmTpdu,
		EFormatCdmaTpdu
		};

	class TMobileSmsAttributesV1 : public RMobilePhone::TMultimodeType
		{
	protected:
		TMobileSmsAttributesV1();
	public:
		TUint32 iFlags;
		TMobileSmsDataFormat iDataFormat;
		TInt iCdmaTeleservice;
		TInt iCdmaServiceCategory;
		RMobilePhone::TMobileAddress iGsmServiceCentre;
		};

	/**
	* \class TMobileSmsReceiveAttributesV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines attributes of incoming SMS messages
	*
	*/

	enum TMobileSmsIncomingStatus
		{
		EMtMessageUnknownStatus,
		EMtMessageUnstoredPhoneAck,
		EMtMessageUnstoredClientAck,
		EMtMessageStored
		};

	class TMobileSmsReceiveAttributesV1 : public TMobileSmsAttributesV1
		{
	public:
		IMPORT_C TMobileSmsReceiveAttributesV1();
	public:
		TMobileSmsIncomingStatus	 iStatus;	// indicates if MT message is stored phone-side
		TInt						 iStoreIndex;// used if MT message is stored phone-side
		RMobilePhone::TMobileName	 iStore;		// used if MT message is stored phone-side
		RMobilePhone::TMobileAddress iOriginator;
		};

	typedef TPckg<TMobileSmsReceiveAttributesV1> TMobileSmsReceiveAttributesV1Pckg;

	/**
	* \class TMobileSmsSendAttributesV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines attributes of sent SMS messages
	*
	*/

	class TMobileSmsSendAttributesV1 : public TMobileSmsAttributesV1
		{
	public:
		IMPORT_C TMobileSmsSendAttributesV1();
	public:
		TUint16						 iMsgRef;
		TBool						 iMore;
		TMobileSmsGsmTpdu			 iSubmitReport;
		RMobilePhone::TMobileAddress iDestination;
		};
	
	typedef TPckg<TMobileSmsSendAttributesV1> TMobileSmsSendAttributesV1Pckg;

	//
	// Setting up the storage & acknowledgement mode
	//

	enum TMobileSmsReceiveMode
		{
		EReceiveModeUnspecified,
		EReceiveUnstoredPhoneAck,	// client stores but phone acknowledges message
		EReceiveUnstoredClientAck,	// client acknowledges and stores message
		EReceiveStored,				// phone acknowledges and store message
		EReceiveEither				// client deals with stored & unstored messages
		};

	IMPORT_C void SetReceiveMode(TRequestStatus& aReqStatus, TMobileSmsReceiveMode aReceiveMode) const;
	IMPORT_C TInt GetReceiveMode(TMobileSmsReceiveMode& aReceiveMode) const;
	IMPORT_C void NotifyReceiveModeChange(TRequestStatus& aStatus, TMobileSmsReceiveMode& aReceiveMode);
	
	//
	// Incoming SMS
	//

	IMPORT_C void ReceiveMessage(TRequestStatus& aReqStatus, TDes8& aMsgData, TDes8& aMsgAttributes) const;

	//
	// Responding to incoming SMS
	//
	
	IMPORT_C void AckSmsStored(TRequestStatus& aReqStatus, const TDesC8& aMsgData, TBool aFull=EFalse) const;
	IMPORT_C void NackSmsStored(TRequestStatus& aReqStatus, const TDesC8& aMsgData, TInt aRpCause) const;
	IMPORT_C void ResumeSmsReception(TRequestStatus& aReqStatus) const;

	//
	// Outgoing SMS
	//

	IMPORT_C void SendMessage(TRequestStatus& aReqStatus, const TDesC8& aMsgData, TDes8& aMsgAttributes) const;
	IMPORT_C void SendMessageNoFdnCheck(TRequestStatus& aReqStatus, const TDesC8& aMsgData, TDes8& aMsgAttributes) const;

	enum TMobileSmsBearer
		{
		ESmsBearerPacketOnly,
		ESmsBearerCircuitOnly,
		ESmsBearerPacketPreferred,
		ESmsBearerCircuitPreferred
		};

	IMPORT_C void SetMoSmsBearer(TRequestStatus& aReqStatus, TMobileSmsBearer aBearer) const;
	IMPORT_C TInt GetMoSmsBearer(TMobileSmsBearer& aBearer) const;
	IMPORT_C void NotifyMoSmsBearerChange(TRequestStatus& aReqStatus, TMobileSmsBearer& aBearer);

	//
	// Get information on phone-side SMS storage
	//

	IMPORT_C TInt EnumerateMessageStores(TInt& aCount) const;
	IMPORT_C void GetMessageStoreInfo(TRequestStatus& aReqStatus, TInt aIndex, TDes8& aInfo) const;

	//
	// Read/Write SMS parameters to phone-side storage
	//

	enum { KMaxSmspTextSize=30 };

	enum TMobileSmspStoreValidParams
		{
		KDestinationIncluded=0x00000001,
		KSCAIncluded=0x00000002,
		KProtocolIdIncluded=0x00000004,
		KDcsIncluded=0x00000008,
		KValidityPeriodIncluded=0x00000010
 		};

	class TMobileSmspEntryV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileSmspEntryV1();
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		TInt iIndex;
		TUint32	iValidParams;
		TUint8 iProtocolId;
		TUint8 iDcs;
		TUint8 iValidityPeriod;
		TUint8 iReservedFiller;
		RMobilePhone::TMobileAddress iDestination;
		RMobilePhone::TMobileAddress iServiceCentre;
		TBuf<KMaxSmspTextSize> iText;
		};

	typedef TPckg<TMobileSmspEntryV1> TMobileSmspEntryV1Pckg;
	IMPORT_C void StoreSmspListL(TRequestStatus& aReqStatus, CMobilePhoneSmspList* aSmspList) const;
	IMPORT_C void NotifySmspListChange(TRequestStatus& aReqStatus) const;

private:
	RMobileSmsMessaging(const RMobileSmsMessaging&);
	CSmsMessagingPtrHolder* iSmsMessagingPtrHolder;
protected:
	IMPORT_C void ConstructL();
	IMPORT_C void Destruct();
	};


/*********************************************************/
//
// Broadcast Messaging (RMobileBroadcastMessaging)
// 
/*********************************************************/

/**
 * \class RMobileBroadcastMessaging ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to Broadcast messaging functionality provided by TSY
 *
 * RMobileBroadcastMessaging inherits from RTelSubSessionBase defined in ETEL.H
 */

class CMobilePhoneBroadcastIdList;

class CCbsMessagingPtrHolder;
class RMobileBroadcastMessaging : public RTelSubSessionBase
	{
public:
	
	friend class CRetrieveMobilePhoneBroadcastIdList;

	IMPORT_C RMobileBroadcastMessaging();

	IMPORT_C TInt Open(RMobilePhone& aPhone);
	IMPORT_C void Close();

	//
	// Broadcast messaging capabilities
	//

	enum TMobileBroadcastModeCaps
		{
		KCapsGsmTpduFormat = 0x00000001,
		KCapsCdmaTpduFormat = 0x00000002
		};

	enum TBroadcastMessagingFilterCaps
		{
		KCapsSimpleFilter = 0x00000001,
		KCapsLangFilter = 0x00000002,
		KCapsIdFilter = 0x00000004
		};

	/**
	* \class TMobileBroadcastCapsV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines capabilities of Broadcast messaging
	*
	*/

	class TMobileBroadcastCapsV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileBroadcastCapsV1();
	public:
		TUint32 iModeCaps;
		TUint32 iFilterCaps;
		};

	typedef TPckg<TMobileBroadcastCapsV1> TMobileBroadcastCapsV1Pckg;

	IMPORT_C TInt GetCaps(TDes8& aCaps) const;

	enum TMobileBroadcastAttributeFlags
		{
		KBroadcastDataFormat = 0x00000001,
		KCdmaServiceCategory = 0x00000002
		};

	enum TMobileBroadcastDataFormat
		{
		EFormatUnspecified,
		EFormatGsmTpdu,
		EFormatCdmaTpdu
		};

	/**
	* \class TMobileBroadcastAttributesV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines attributes of a Broadcast message
	*
	*/

	class TMobileBroadcastAttributesV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileBroadcastAttributesV1();
	public:
		TUint32	iFlags;
		TMobileBroadcastDataFormat	iFormat;
		TInt iServiceCategory;
		};

	typedef TPckg<TMobileBroadcastAttributesV1> TMobileBroadcastAttributesV1Pckg;

	//
	// Receiving broadcast messages
 	//

	enum 
		{
		KGsmBroadcastDataSize = 88,
		KCdmaBroadcastDataSize = 255
		};

	typedef TBuf8<KGsmBroadcastDataSize>  TGsmBroadcastMessageData;
	typedef TBuf8<KCdmaBroadcastDataSize> TCdmaBroadcastMessageData;

	IMPORT_C void ReceiveMessage(TRequestStatus& aReqStatus, TDes8& aMsgData, TDes8& aMsgAttributes) const;

	//
	// Filters
	//

	enum TMobilePhoneBroadcastFilter
		{
		EBroadcastFilterUnspecified,
		EBroadcastAcceptNone,
		EBroadcastAcceptAll,
		EBroadcastAcceptFilter,
		EBroadcastRejectFilter
		};

	IMPORT_C TInt GetFilterSetting(TMobilePhoneBroadcastFilter& aSetting) const;
	IMPORT_C void SetFilterSetting(TRequestStatus& aReqStatus, TMobilePhoneBroadcastFilter aSetting) const;
	IMPORT_C void NotifyFilterSettingChange(TRequestStatus& aReqStatus, TMobilePhoneBroadcastFilter& aSetting) const;

	IMPORT_C void GetLanguageFilter(TRequestStatus& aReqStatus, TDes16& aLangFilter) const;
	IMPORT_C void SetLanguageFilter(TRequestStatus& aReqStatus, const TDesC16& aLangFilter) const;
	IMPORT_C void NotifyLanguageFilterChange(TRequestStatus& aReqStatus, TDes16& aLangFilter) const;

	/**
	* \class TMobileBroadcastIdEntryV1 ETELMM.H "INC/ETELMM.H"
	* \brief In GSM - defines a Cell Broadcast Message Identifier (CBMI) list entry
	* \brief In CDMA - defines a Service Category list entry
	*
	*/

	class TMobileBroadcastIdEntryV1 : public RMobilePhone::TMultimodeType
		{
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
		IMPORT_C TMobileBroadcastIdEntryV1();
	public:
		TUint16	iId;
		};

	enum TMobileBroadcastIdType
		{
		EGsmBroadcastId,
		ECdmaBroadcastId
		};

	IMPORT_C void StoreBroadcastIdListL(TRequestStatus& aReqStatus, CMobilePhoneBroadcastIdList* aIdList, TMobileBroadcastIdType aIdType);
	IMPORT_C void NotifyBroadcastIdListChange(TRequestStatus& aReqStatus) const;

private:
	RMobileBroadcastMessaging(const RMobileBroadcastMessaging&);
	CCbsMessagingPtrHolder* iCbsMessagingPtrHolder;
protected:
	IMPORT_C void ConstructL();
	IMPORT_C void Destruct();
	};

/*********************************************************/
//
// USSD Messaging (RMobileUssdMessaging)
// 
/*********************************************************/

/**
 * \class RMobileUssdMessaging Etelmm.h "inc/Etelmm.h"
 * \brief Provides client access to USSD functionality provided by TSY
 *
 * RMobileUssdMessaging inherits from RTelSubSessionBase defined in ETEL.H
 */

class CUssdMessagingPtrHolder;
class RMobileUssdMessaging : public RTelSubSessionBase
	{
public:
	IMPORT_C RMobileUssdMessaging();

	IMPORT_C TInt Open(RMobilePhone& aPhone);
	IMPORT_C void Close();

	enum TMobileUssdFormatCaps
		{
		KCapsPackedString=0x00000001
		};

	enum TMobileUssdTypeCaps
		{
		KCapsMOUssd=0x00000001,
		KCapsMTUssd=0x00000002
		};

	/**
	* \class TMobileUssdCapsV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines capabilities of USSD messaging
	*
	*/

	class TMobileUssdCapsV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileUssdCapsV1();
		TUint32 iUssdFormat;
		TUint32 iUssdTypes;
		};

	typedef TPckg<TMobileUssdCapsV1> TMobileUssdCapsV1Pckg;

	IMPORT_C TInt GetCaps(TDes8& aCaps) const;

	enum TMobileUssdAttributeFlags
		{
		KUssdDataFormat = 0x00000001,
		KUssdMessageType = 0x00000002,
		KUssdMessageDcs = 0x00000004
		};

	enum TMobileUssdDataFormat
		{
		EFormatUnspecified,
		EFormatPackedString
		};

	enum TMobileUssdMessageType
		{
		EUssdUnknown,
		EUssdMORequest,
		EUssdMOReply,
		EUssdMTNotify,
		EUssdMTRequest,
		EUssdMTReply
		};

	/**
	* \class TMobileUssdAttributesV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines attributes of a USSD message
	*
	*/

	class TMobileUssdAttributesV1 : public RMobilePhone::TMultimodeType
		{
	public:
		IMPORT_C TMobileUssdAttributesV1();
	public:
		TUint32 iFlags;
		TMobileUssdDataFormat iFormat;
		TMobileUssdMessageType iType;
		TUint8 iDcs;
		};
	
	typedef TPckg<TMobileUssdAttributesV1> TMobileUssdAttributesV1Pckg;

	//
	// Receiving USSD messages
 	//

	enum
		{
		KGsmUssdDataSize = 160
		};

	typedef TBuf8<KGsmUssdDataSize> TGsmUssdMessageData;

	IMPORT_C void ReceiveMessage(TRequestStatus& aReqStatus, TDes8& aMsgData, TDes8& aMsgAttributes) const;

	//
	// Sending USSD messages
	//

	IMPORT_C void SendMessage(TRequestStatus& aReqStatus, const TDesC8& aMsgData, const TDesC8& aMsgAttributes) const;
	IMPORT_C void SendMessageNoFdnCheck(TRequestStatus& aReqStatus, const TDesC8& aMsgData, const TDesC8& aMsgAttributes) const;

private:
	RMobileUssdMessaging(const RMobileUssdMessaging&);
	CUssdMessagingPtrHolder* iUssdMessagingPtrHolder;
protected:
	IMPORT_C void ConstructL();
	IMPORT_C void Destruct();
	};



/*********************************************************/
//
// SMS Message Storage (RMobileSmsStore)
//
/*********************************************************/

/**
 * \class RMobileSmsStore ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to SMS storage functionality provided by TSY
 *
 * RMobileSmsStore inherits from RMobilePhoneStore defined in ETELMM.H
 */

class CSmsStorePtrHolder;
class CMobilePhoneSmsList;
class RMobileSmsStore : public RMobilePhoneStore
	{
public:

	IMPORT_C RMobileSmsStore();
	IMPORT_C TInt Open(RMobileSmsMessaging& aMessaging, const TDesC& aStoreName);
	IMPORT_C void Close();

	enum TMobileSmsStoreCaps
		{
		KCapsUnreadMessages = 0x00000001,
		KCapsReadMessages = 0x00000002,
		KCapsSentMessages = 0x00000004,
		KCapsUnsentMessages = 0x00000008,
		KCapsGsmMessages = 0x00000010,
		KCapsCdmaMessages = 0x00000020
		};

	/**
	* \class TMobileSmsEntryV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines contents of a fixed-size, stored SMS entry
	*
	*/

	enum TMobileSmsStoreStatus
		{
		EStoredMessageUnknownStatus,
		EStoredMessageUnread,
		EStoredMessageRead,
		EStoredMessageUnsent,
		EStoredMessageSent,
		EStoredMessageDelivered
		};

	//
	// Enum used by TSY to distinguish which SMS entry class is used by client
	//

	enum TMobileSmsEntryExtensionId
		{
		KETelMobileSmsEntryV1=KETelExtMultimodeV1,
		KETelMobileGsmSmsEntryV1,
		KETelMobileCdmaSmsEntryV1
		};

	class TMobileSmsEntryV1 : public RMobilePhoneStore::TMobilePhoneStoreEntryV1
		{
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	protected:
		TMobileSmsEntryV1();
	public:
		TMobileSmsStoreStatus	iMsgStatus;	
		};

	class TMobileGsmSmsEntryV1 : public TMobileSmsEntryV1
		{
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		IMPORT_C TMobileGsmSmsEntryV1();
	public:
		RMobilePhone::TMobileAddress iServiceCentre;
		RMobileSmsMessaging::TMobileSmsGsmTpdu	iMsgData;	
		};

	typedef TPckg<TMobileGsmSmsEntryV1> TMobileGsmSmsEntryV1Pckg;

	class TMobileCdmaSmsEntryV1 : public TMobileSmsEntryV1
		{
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		IMPORT_C TMobileCdmaSmsEntryV1();
	public:
		TInt iTeleservice;
		TInt iServiceCategory;
		RMobilePhone::TMobileAddress iRemoteParty;
		RMobileSmsMessaging::TMobileSmsCdmaTpdu iMsgData;	
		};

	typedef TPckg<TMobileCdmaSmsEntryV1> TMobileCdmaSmsEntryV1Pckg;

protected:
	IMPORT_C void ConstructL();
private:
	RMobileSmsStore(const RMobileSmsStore&);
	};

/*********************************************************/
//
// NAM Storage (RMobileNamStore)
//
/*********************************************************/

/**
 * \class RMobileNamStore ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to NAM storage functionality provided by TSY
 *
 * RMobileNamStore inherits from RMobilePhoneStore defined in ETELMM.H
 */

class CNamStorePtrHolder;
class CMobilePhoneNamList;

class RMobileNamStore : public RMobilePhoneStore
	{
public:
	IMPORT_C RMobileNamStore();
	IMPORT_C TInt Open(RMobilePhone& aPhone);
	IMPORT_C void Close();

	/**
	* \class TMobileNamStoreInfoV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines information about a NAM store
	*
	*/

	class TMobileNamStoreInfoV1 : public RMobilePhoneStore::TMobilePhoneStoreInfoV1
		{
	public:
		IMPORT_C TMobileNamStoreInfoV1();
	public:
		TInt iNamCount;
		TInt iActiveNam;
		};

	typedef TPckg<TMobileNamStoreInfoV1> TMobileNamStoreInfoV1Pckg;

	IMPORT_C void SetActiveNam(TRequestStatus& aReqStatus, TInt aNamId) const;

	enum
		{
		KMaxNamParamSize = 64
		};

	/**
	* \class TMobileNamEntryV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines contents of a NAM store entry
	*
	*/

	class TMobileNamEntryV1 : public RMobilePhoneStore::TMobilePhoneStoreEntryV1
		{
	public:
		IMPORT_C TMobileNamEntryV1();
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		TInt iNamId;
		TInt iParamIdentifier;
		TBuf8<KMaxNamParamSize> iData;
		};

	typedef TPckg<TMobileNamEntryV1> TMobileNamEntryV1Pckg;

	IMPORT_C void StoreAllL(TRequestStatus& aReqStatus, TInt aNamId, CMobilePhoneNamList* aNamList) const;

protected:
	IMPORT_C void ConstructL();
private:
	RMobileNamStore(const RMobileNamStore&);
	};


/*********************************************************/
//
// Own Number Storage (RMobileONStore)
//
/*********************************************************/

/**
 * \class RMobileONStore ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to Own Number storage functionality provided by TSY
 *
 * RMobileONStore inherits from RMobilePhoneStore defined in ETELMM.H
 */

class CONStorePtrHolder;
class CMobilePhoneONList;
	
class RMobileONStore : public RMobilePhoneStore
	{
public:
	IMPORT_C RMobileONStore();
	IMPORT_C TInt Open(RMobilePhone& aPhone);
	IMPORT_C void Close();

	/**
	* \class TMobileONStoreInfoV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines information about an Own Number store
	*
	*/

	class TMobileONStoreInfoV1 : public RMobilePhoneStore::TMobilePhoneStoreInfoV1
		{
	public:
		IMPORT_C TMobileONStoreInfoV1();
	public:
		TInt iNumberLen;
		TInt iTextLen;
		};

	typedef TPckg<TMobileONStoreInfoV1> TMobileONStoreInfoV1Pckg;

	enum
		{
		KOwnNumberTextSize = 20
		};

	/**
	* \class TMobileONEntryV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines contents of a Own Number store entry
	*
	*/

	class TMobileONEntryV1 : public RMobilePhoneStore::TMobilePhoneStoreEntryV1
		{
	public:
		IMPORT_C TMobileONEntryV1();
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		RMobilePhone::TMobilePhoneNetworkMode iMode;
		RMobilePhone::TMobileService iService;
		RMobilePhone::TMobileAddress iNumber;
		TBuf<KOwnNumberTextSize> iText;
		};

	typedef TPckg<TMobileONEntryV1> TMobileONEntryV1Pckg;

	IMPORT_C void StoreAllL(TRequestStatus& aReqStatus, CMobilePhoneONList* aONList) const;

protected:
	IMPORT_C void ConstructL();
private:
	RMobileONStore(const RMobileONStore&);
	};

/*********************************************************/
//
// Emergency Number Storage (RMobileENStore)
//
/*********************************************************/

/**
 * \class RMobileENStore ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to Emergency Number storage functionality provided by TSY
 *
 * RMobileENStore inherits from RMobilePhoneStore defined in ETELMM.H
 */

class CMobilePhoneENList;

class RMobileENStore : public RMobilePhoneStore
	{
public:
	IMPORT_C RMobileENStore();
	IMPORT_C TInt Open(RMobilePhone& aPhone);
	IMPORT_C void Close();

	enum 
		{
		KEmergencyNumberSize  = 6,
		KEmergencyAlphaTagSize = 20
		};

	/**
	* \class TMobileENEntryV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines contents of a Emergency Number store entry
	*
	*/

	typedef TBuf<KEmergencyNumberSize> TEmergencyNumber;

	class TMobileENEntryV1 : public RMobilePhoneStore::TMobilePhoneStoreEntryV1
		{
	public:
		IMPORT_C TMobileENEntryV1();
	public:
		void InternalizeL(RReadStream& aStream);
		void ExternalizeL(RWriteStream& aStream) const;
	public:
		TBool iNetworkSpecific;
		RMobilePhone::TMobilePhoneNetworkMode iMode;
		RMobilePhone::TMobilePhoneNetworkCountryCode iCountryCode;
		RMobilePhone::TMobilePhoneNetworkIdentity iIdentity;
		TEmergencyNumber             iNumber;
		TBuf<KEmergencyAlphaTagSize> iAlphaId;
		TInt	                     iCallType;
		};

	typedef TPckg<TMobileENEntryV1> TMobileENEntryV1Pckg;

protected:
	IMPORT_C void ConstructL();
private:
	RMobileENStore(const RMobileENStore&);
	};


/*********************************************************/
//
// RMobilePhoneBookStore 
//
/*********************************************************/

/**
 * \class RMobilePhoneBookStore ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to Phonebook storage functionality provided by TSY
 *
 * RMobilePhoneBookStore inherits from RMobilePhoneStore defined in ETELMM.H
 */

class CPhoneBookStorePtrHolder;
class CMobilePhoneBookList;

class RMobilePhoneBookStore : public RMobilePhoneStore 
	{
public:
	IMPORT_C RMobilePhoneBookStore();
	IMPORT_C TInt Open(RMobilePhone& aPhone, const TDesC& aStore);
	IMPORT_C void Close();

	enum TMobilePhoneBookCaps
		{
		KCapsRestrictedWriteAccess = 0x00000001,
		KCapsSecondNameUsed        = 0x00000002,
		KCapsAdditionalNumUsed     = 0x00000004,
		KCapsGroupingUsed		   = 0x00000008,
		KCapsEntryControlUsed      = 0x00000010,
		KCapsEmailAddressUsed      = 0x00000020,
		KCapsBearerCapUsed		   = 0x00000040,
		KCapsSynchronisationUsed   = 0x00000080
		};

	enum TMobilePhoneBookLocation
		{
		ELocationUnknown,
		ELocationIccMemory,
		ELocationPhoneMemory,
		ELocationExternalMemory,
		ELocationCombinedMemory
		};

	enum
		{
		KMaxPBIDSize=15
		};

	typedef TBuf8<KMaxPBIDSize> TMobilePhoneBookIdentity;

	/**
	* \class TMobilePhoneBookInfoV1 ETELMM.H "INC/ETELMM.H"
	* \brief Defines information about a Phonebook store
	*
	*/

	class TMobilePhoneBookInfoV1 : public RMobilePhoneStore::TMobilePhoneStoreInfoV1
		{
	public:
		IMPORT_C TMobilePhoneBookInfoV1();
	public:
		TInt    iMaxNumLength;
		TInt    iMaxTextLength;
		TMobilePhoneBookLocation iLocation;
		TUint16 iChangeCounter;
		TMobilePhoneBookIdentity iIdentity; 
		};

	typedef TPckg<TMobilePhoneBookInfoV1> TMobilePhoneBookInfoV1Pckg;

	// check these fields - not sure all are correct
	enum TMobilePBFieldTags
		{
		ETagPBNewEntry		=0xA0,
		ETagPBUniqueId		=0xB0,
		ETagPBAdnIndex		=0xC0,
		ETagPBText			=0xC1,
		ETagPBNumber		=0xC2,
		ETagPBTonNpi		=0xC3,
		ETagPBBearerCap		=0xC4,
		ETagPBAnrStart		=0xC5,
		ETagPBSecondName	=0xC6,
		ETagPBGroupName		=0xC7,
		ETagPBEmailAddress	=0xC8,
		ETagPBEntryControl	=0xC9,
		ETagPBHiddenInfo	=0xCA,
		ETagPBEntryStatus   =0xCB
		};

	// API/TSY internal type
	struct TPBIndexAndNumEntries
		{
		TInt iIndex;
		TInt iNumSlots;
		};

	IMPORT_C void Read(TRequestStatus& aReqStatus, TInt aIndex, TInt aNumSlots, TDes8& aPBData) const;
	IMPORT_C void Write(TRequestStatus& aReqStatus, const TDesC8& aPBData, TInt& aIndex) const;

protected:
	IMPORT_C void ConstructL();
private:
	RMobilePhoneBookStore(const RMobilePhoneBookStore&);
	};

/*********************************************************/
//
// RMobileConferenceCall
//
/*********************************************************/

/**
 * \class RMobileConferenceCall ETELMM.H "INC/ETELMM.H"
 * \brief Provides client access to conference call functionality provided by TSY
 *
 * RMobileConferenceCall inherits from RTelSubSessionBase defined in ETEL.H
 */

class CMobileConferenceCallPtrHolder;

class RMobileConferenceCall : public RTelSubSessionBase
	{
public:
	IMPORT_C RMobileConferenceCall();
	IMPORT_C TInt Open(RMobilePhone& aPhone);
	IMPORT_C void Close();

	enum TMobileConferenceCallCaps
		{
		KCapsCreate = 0x00000001,
		KCapsHangUp = 0x00000002,
		KCapsSwap = 0x00000004
		};

	IMPORT_C TInt GetCaps(TUint32& aCaps) const;
	IMPORT_C void NotifyCapsChange(TRequestStatus& aReqStatus, TUint32& aCaps) const;

	IMPORT_C void CreateConference(TRequestStatus& aReqStatus) const;
	IMPORT_C void AddCall(TRequestStatus& aReqStatus, const TName& aCallName) const;
	IMPORT_C void Swap(TRequestStatus& aReqStatus) const;
	IMPORT_C void HangUp(TRequestStatus& aReqStatus) const;
	IMPORT_C TInt EnumerateCalls(TInt& aCount) const;
	IMPORT_C TInt GetMobileCallInfo(TInt aIndex, TDes8& aCallInfo) const;

	enum TMobileConferenceStatus
		{
		EConferenceIdle,
		EConferenceActive,
		EConferenceHold
		};
	
	IMPORT_C TInt GetConferenceStatus(TMobileConferenceStatus& aStatus) const;
	IMPORT_C void NotifyConferenceStatusChange(TRequestStatus& aReqStatus, TMobileConferenceStatus& aStatus) const;

	enum TMobileConferenceEvent
		{
		EConferenceCallAdded,
		EConferenceCallRemoved
		};

	IMPORT_C void NotifyConferenceEvent(TRequestStatus& aReqStatus, TMobileConferenceEvent& aEvent, TName& aCallName) const;

private:
	CMobileConferenceCallPtrHolder* iMmPtrHolder;
	RMobileConferenceCall(const RMobileConferenceCall&);
protected:
	IMPORT_C void ConstructL();
	IMPORT_C void Destruct();
	};



#endif

