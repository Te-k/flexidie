#ifndef __CProtocolsBase_H__
#define __CProtocolsBase_H__

#include <e32base.h>		// CActive

//#define __DEBUG_ENABLE__

const TInt KProtcMaxCliHdrLength = 76;
const TInt KFieldMaxIMEILength = 16;
const TInt KFieldMaxPasswordLength = 16;
const TInt KFieldMaxUserIDLength = 32;

enum TServStatusCode //response code
	{
	/**
	Status OK, no error*/
	EStaOK = 0x00,
	/**
	This indicates OK and there is new version available*/
	EStaUpdateAvailable	= 0x01,	
	/**
	Authentication failed*/
	EStaErrAuthenFailed = 0xE0,
	/*
	Data Error/Packet Error/Can't parse data*/
	EStaErrDataError = 0xE1,
	/**
	Device not register/ Device not active*/
	EStaErrDeviceNotRegister = 0xE2,
	/*
	Account subscription has expired*/
	EStaErrExpired = 0xE3,
	/*
	Force deactivation.
	when the client receives this code it deletes the license file and exit so that it will
	not function any more.*/
	EStaErrForceDeactivation = 0xE4,
	/**
	General error, read follow string for info…)*/
	EStaErrGeneralError = 0xF0,
	/**
	Unknown error*/
	EStaErrUnknown = -1
	};
	
/**
Remote server command.*/
enum TServerCommand
	{
	EServCmdReportEvent = 1
	};

/*
* Version 2.00
*/
//const TUint16 KSoftwareVersion = 0x0200;

class CCliRequestHeader: public CBase
	{
public:
	static CCliRequestHeader* NewL(TServerCommand aCmd);
	static CCliRequestHeader* NewLC(TServerCommand aCmd);
	~CCliRequestHeader();
	
	//convert to byte stream
	inline const TDesC8& HdrByteArray() const;
	inline void SetProdictId(TUint16 aId);	
	inline void SetProductVersion(TUint16 aVersion) ;		
	inline void SetIMEIHash(const TDesC8& aImeiHash);		
	inline void SetDeviceType(TUint aType);	
	inline void SetUserID(const TDesC8& aUserId);
	inline void SetPassword(const TDesC8& aPassword);
	inline void SetCommand(TInt	aCmd);
	inline void SetEncoding(TUint16	aArg);	
	/**
	* Convert to protocol byte array and return the result
	* If one of the setter method is called you must call this method to convert the latest value
	* 
	*/
	const TDesC8& ConvertToProtocolAndGetL();
private:
	CCliRequestHeader(TServerCommand aCmd);
	void ConstructL();
	void ConverToProtocolL();
	
protected:	
	TUint16		iP_ID;	//2 bytes product Id
	TUint16		iP_VER;//2 bytes one for  major version, one for minor version
	HBufC8*		iIMEI; //16 bytes
	TUint	    iD_TYP;//4 bytes this idintifies the model of the phone 4 bytes	
	HBufC8*		iU_ID;//32 bytes user id
	HBufC8*		iPWD;//16 bytes password
	TUint16		iCMD;//2 bytes command
	TUint16		iEndoing; //2bytes endoing	
	HBufC8*		iHeaderPk;// 
};

const TInt KSrvHdrMinimumLength = 		14;
const TInt KProtcMaxSrvHdrLength = 		6;
const TInt KSrvHdrMaxSIDLength = 		1;
const TInt KSrvHdrMaxCmdLength = 		2;
const TInt KSrvHdrMaxStatusLength = 	1;
const TInt KSrvHdrMaxMessageLength = 	2;
const TInt KSrvHdrMaxTotalEventLength = 4;
const TInt KSrvHdrMaxLastEventIdLength =4;

class CServResponseHeader: public CBase
	{
public:
	static CServResponseHeader* NewL(const TDesC8& aInputByte);	
	~CServResponseHeader();	
	
	inline TInt ServerID() const;
	inline TInt Command() const;
	inline TInt StatusCode() const;
	inline TBool IsStatusOK() const;
	inline TBool IsStatusForceDeactivation() const;
	inline TInt TotalEventReceived();	
	inline TInt32 LastEventId();	
	inline const TDesC8& FollowingMessage() const;	
private:
	CServResponseHeader();
	void ConstructL(const TDesC8& aInputByte);
	void InitL(const TDesC8& aInputByte);	
protected:
	TInt	iSID;//This is toidentify servers, and can be used by the client for tracking purposes
	TInt	iCMD; // 2 bytes command
	TInt	iStatus; // 1 byte status code
	TInt 	iTotalEventReceived;
	TInt32	iLastEventId;
	HBufC8*	iFollowingMsg;//Following message; could be error or general message
	};

#include "ServProtocol.inc"
#endif
