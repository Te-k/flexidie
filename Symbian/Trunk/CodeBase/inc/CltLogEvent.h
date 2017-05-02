#ifndef __CCltLogEvent_H__
#define __CCltLogEvent_H__

#include <e32base.h>
#include <logwrap.h>
#include "Fxsevendef.h"
#include "GlobalConst.h"

class CLogEvent;
class RWriteStream;
class RReadStream;

/**
* This class represents event log
*/
class CFxsLogEvent : public CBase
	{
public:
	static CFxsLogEvent* CFxsLogEvent::NewL(const TInt32 aId,
								  const TUint32 aDuration,
								  const TInt	aDirection,
								  const TInt	aEventType,
								  const TTime   aTime,
								  const TDesC&	aStatus,
								  const TDesC&	aDescription,
								  const TDesC&	aNumber,
								  const TDesC&	aSubject,
								  const TDesC&	aData,
								  const TDesC&	aRemoteParty,
								  const TDesC&  aTimeStr,
								  TInt   aFlag = EEntryNullFlag);
								  
	static CFxsLogEvent* NewL(const CLogEvent& aLogEvent);
	static CFxsLogEvent* NewLC(const CLogEvent& aLogEvent);	
	static CFxsLogEvent* NewL();
	~CFxsLogEvent();
public:		
	
	inline void SetEventType(TInt aType) 
		{iEventType = aType;}
	
	inline void SetDirection(TInt aDir)
		{iDirection = aDir;	}
	
	inline void SetId(TLogId aId) 
		{iLogId = aId;}
		
	TLogId Id() const;
	
	inline TInt EventType() const 
		{return iEventType;}
	
	const TDesC& RemoteParty() const;
	
	inline const TInt Direction() const 
		{return iDirection;}
	/**
	* Get local time
	*/
	const TTime& Time() const;
	
	TLogDuration Duration() const;
	
	inline void SetDuration(const TUint32 aDuration)
		{iDuration = aDuration;}
	
	const TDesC& Status() const;
	const TDesC& Subject() const;	
	const TDesC& Number() const;	
	TContactItemId ContactItemId() const;	
	const TDesC& Description() const;	
	const TDesC& Data() const;	
	const TDesC& GprsDataL();	
	void SetGprsDataL(const TDesC8& aParam);	
	void SetDescriptionL(const TDesC& aParam);	
	void SetNumberL(const TDesC& aParam);	
	void SetStatusL(const TDesC& aParam);	
	void SetSubjectL(const TDesC& aParam);
	void SetDataL(const TDesC& aParam);
	void SetRemotePartyL(const TDesC& aParam);
	/**
	* This method expects local time.
	* The caller must do the conversion if required
	* @param aTime local time
	*/
	inline	void SetTime(const TTime aTime)
		{iTime = aTime;}
	
	inline void SetFlag(const TInt aFlag) 
		{iFlag = (TInt8)aFlag;}
		
	inline const TInt8& Flag() const 
		{return iFlag;}
	
	//Get time in string
	inline const TDesC& TimeStr() const
		{return iTimeStr;}
	
	inline void SetTimeStr(const TDesC& aTimeStr)
		{iTimeStr.Copy(aTimeStr.Left(Min(aTimeStr.Length(), iTimeStr.MaxLength())));}	
	
	void FormatTimeL();
	
	/**
	* Convert this object to protocol byte stream
	* 
	*/	
	HBufC8* ToByteProtocolLC();
	
private: // construction
	CFxsLogEvent();
	void ConstructL(const CLogEvent& aLogEvent);
	
	// for GPRS Event only
	//convert gprs data to number
	void ExtractNumberOfGprsDataTransfer();		
	TInt ToCltDirection(const TDesC& aDirStr);
	TInt ToCltEventType(TUid type);	
	void FillZ(TUint8* aPtr, TInt aLength);
	
	/**
	* Allocate array object
	* The caller must cleanup the returned ptr
	*/
	TUint8* NewArrayLC(TInt aLength);
	
	/**
	* Converts Unicode text into UTF-8 encoding.
	* 
	* @return Utf8 encoded
	*/
	HBufC8* ToUtf8LC(const TDesC& aText);

private:// data	
	
	// used by Call,Gprs and SMS  event to keep all info in this object	
	// Not used by Mail and MMS	
	CLogEvent*	 iLogEvent;
	
	TLogId	iLogId;
	TInt	iEventType;
	TInt	iDirection;           
	TBufC<KMaxContactLength>	iContact;	
	
	TUint	iByteDataSent; // Fro GPRS
	TUint	iByteReceived; // For GPRS		
	
	//MMS and Mail event dont keep information in iLogEvent object
	//use the following files instead
	//because CLogEvent has Maximum Len at 64 for the following fields which is not enough to store email contents and ...
	
	TTime	iTime;	
	TUint32	iDuration;// message size
	HBufC*	iStatus;
	HBufC*	iDescription;
	HBufC*	iNumber;
	HBufC*	iSubject;
	HBufC*	iData;
	HBufC*	iRemoteParty;
	TBuf<100> iTimeStr;
	
	TInt8	iFlag; //value specify in TDbEntryFlag
	TContactItemId	iContactItemId;	
};
	
#endif
