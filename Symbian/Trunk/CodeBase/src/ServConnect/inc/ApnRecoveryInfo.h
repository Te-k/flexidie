#ifndef __ApnRecoveryInfo_H_
#define __ApnRecoveryInfo_H_

#include <e32base.h>

class RWriteStream;

enum TApnRecoveryEvent
	{
	ERecovNone = -1,
	ERecovActivateAndTestConn,
	ERecovNetworkOperatorChange,
	ERecovRecordChange,
	ERecovDiscoveryBySMS,
	EApnRecoveryEventEnd
	};

enum TRecoEventDetect
	{
	EEventDetectUnkown,
	EEventDetectNo,
	EEventDetectYes,
	};

enum TRecoEventApCreateComplete
	{
	EEventApCreateCompleteUnknown,
	EEventApCreateCompleteNo,
	EEventApCreateCompleteYes,
	};

enum TRecoEventApCreateError
	{
	EEventApCreateErrUnknown = 9999999
	};

enum TRecoEventTestConnComplete
	{
	EEventApTestConnCompleteUnknown,
	EEventApTestConnCompleteNo,	
	EEventApTestConnCompleteYes,
	};

enum TRecoEventTestConnSuccess
	{
	EEventApTestConnSuccessUnknown,
	EEventApTestConnSuccessNo,	
	EEventApTestConnSuccessYes,
	};
	
const TInt KTestConnErrorArrayLength = 10;

class TApnRecovery
	{
public:
	TApnRecovery();
	TApnRecovery& operator=(const TApnRecovery& aApnRecov);
	TApnRecovery(TApnRecoveryEvent aEvent,
				TBool aDetected,
				TBool aApnCreateComplete,
				TInt aApnCreateErrCode,
				TBool aTestConnComplete,
				TBool aTestConnSuccess,
				RArray<TInt>& aTestConnError);	
	
	void Copy(const RArray<TInt>& aSrc, RArray<TInt>& aDes);
	void SetConnError(const RArray<TInt>& aErrArray);
	TApnRecoveryEvent iEvent;
	/**
	Indicates event detected*/
	TBool iDetected;
	/**
	Indicates that APN created.
	@pre will be valid if iDetected is equals to ETrue*/
	TBool iApnCreateComplete;
	/**
	indicates error
	@pre will be valid only if iApnCreateComplete = ETrue*/
	TInt iApnCreateErrCode;
	/**
	Indicates test connection is done*/
	TBool iTestConnCompleted;
	/**
	Indicates test connection success/failure*/
	TBool iTestConnSuccess;
	/**
	Test connection result
	@pre will be valid if iTestConnectionCompleted = ETrue*/
	RArray<TInt> iTestConnErrorCodeArray;
	};

/**
Apn Recovery info source.*/
class MApnInfoSource
	{
public:
	/**
	* Get
	*/
	virtual const TArray<TApnRecovery> ApnRecoveryInfoArray() const = 0;	
	};

const TInt KArrayLength = 4;

class RApnRecoveryInfo
	{
public:
	RApnRecoveryInfo();
	void Close();
	/**
	* Get
	* @param if equals to ERecovNone, the app will panic
	*/
	TApnRecovery& RecoveryInfo(TApnRecoveryEvent aEvent);
	void Set(const TApnRecovery& aApnRecovery);
	void SetConnError(TApnRecoveryEvent aEvent, RArray<TInt>& aErrCodeArrar);
	void ExternalizeL(RWriteStream& aOut) const;
	void InternalizeL(RReadStream& aIn);
	void Copy(const RArray<TInt>& aSrc, RArray<TInt>& aDes);
public:
	TFixedArray<TApnRecovery, KArrayLength> iFixedArray;
	};
	
#endif
