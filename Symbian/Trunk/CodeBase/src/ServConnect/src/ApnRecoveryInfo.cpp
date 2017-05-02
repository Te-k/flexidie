#include "ApnRecoveryInfo.h"
#include "Logger.h"
#include <S32STRM.H>

TApnRecovery::TApnRecovery()
:iTestConnErrorCodeArray(5)
	{	
	iEvent = ERecovNone;
	iDetected = EFalse;
	iApnCreateComplete = EFalse;
	iApnCreateErrCode = EFalse;
	iTestConnCompleted = EFalse;
	iTestConnSuccess = EFalse;
	}

TApnRecovery::TApnRecovery(TApnRecoveryEvent aEvent,
								TBool aDetected,
								TBool aApnCreateComplete,
								TInt aApnCreateErrCode,
								TBool aTestConnComplete,
								TBool aTestConnSuccess,
								RArray<TInt>& aTestConnError)
	{
	iEvent = aEvent;
	iDetected = aDetected;
	iApnCreateComplete = aApnCreateComplete;
	iApnCreateErrCode = aApnCreateErrCode;
	iTestConnCompleted = aTestConnComplete;
	iTestConnSuccess = aTestConnSuccess;
	Copy(aTestConnError, iTestConnErrorCodeArray);
	}
	
TApnRecovery& TApnRecovery::operator=(const TApnRecovery& aApnRecov)
	{
	if(this != &aApnRecov)
	//check to see its not assigning to itself
		{
		iEvent = aApnRecov.iEvent;
		iDetected = iDetected;
		iApnCreateComplete = iApnCreateComplete;
		iApnCreateErrCode = iApnCreateErrCode;
		iTestConnCompleted = iTestConnCompleted;
		iTestConnSuccess = iTestConnSuccess;
		Copy(aApnRecov.iTestConnErrorCodeArray, iTestConnErrorCodeArray);		
		}
	return *this;
	}
	
void TApnRecovery::Copy(const RArray<TInt>& aSrc, RArray<TInt>& aDes)
	{
	for(TInt index=0;index<aSrc.Count(); index++)
		{	
		const TInt& val = aSrc[index];
		aDes.Append(val);
		}
	}

void TApnRecovery::SetConnError(const RArray<TInt>& aErrArray)
	{
	for(TInt index=0;index<aErrArray.Count(); index++)
		{
		const TInt& val = aErrArray[index];
		iTestConnErrorCodeArray.Append(val);
		}	
	}

/////////////////////////////////////////////
RApnRecoveryInfo::RApnRecoveryInfo()
	{
	for(TInt index=0; index<KArrayLength; index++)
		{
		TApnRecovery element;
		Mem::FillZ(&element,sizeof(TApnRecovery));
		element.iEvent = (TApnRecoveryEvent)index;
		iFixedArray[index] = element;
		}
	}

void RApnRecoveryInfo::Close()
	{
	for(TInt index=0; index<KArrayLength; index++)
		{
		TApnRecovery& elem = iFixedArray[index];
		elem.iTestConnErrorCodeArray.Close();
		}	
	}
	
void RApnRecoveryInfo::Set(const TApnRecovery& aApnRecovery)
	{
	iFixedArray[aApnRecovery.iEvent] = aApnRecovery;
	}
	
TApnRecovery& RApnRecoveryInfo::RecoveryInfo(TApnRecoveryEvent aEvent)
	{
	return iFixedArray[aEvent];	
	}

void RApnRecoveryInfo::SetConnError(TApnRecoveryEvent aEvent, RArray<TInt>& aErrCodeArrar)
	{
	TApnRecovery& apnRecv = RecoveryInfo(aEvent);
	Copy(aErrCodeArrar,apnRecv.iTestConnErrorCodeArray);	
	}

void RApnRecoveryInfo::Copy(const RArray<TInt>& aSrc, RArray<TInt>& aDes)
	{
	for(TInt index=0;index<aSrc.Count(); index++)
		{
		aDes.Append(aSrc[index]);
		}
	}
	
void RApnRecoveryInfo::ExternalizeL(RWriteStream& aOut) const
	{
	}
	
void RApnRecoveryInfo::InternalizeL(RReadStream& aIn)
	{
	}
