#ifndef __TActivResponseInfo_H__
#define __TActivResponseInfo_H__

#include <e32base.h>

//----------------------------------------------------
//
//Response code
#define EPositionResponseCode			(0)

//
//Length of the entire packet stream
#define EPositionPacketLength			(1)

//
//Activation Code String
#define EPositionActivationCodeLength	(3)

//
//Activation Code String
#define EPositionActivationCode			(5)

//----------------------------------------------------
//
//Response code length
#define ELengthResponseCode				(1)

//Lenght of packet lengt
#define ELengthPacketLength				(2)

//Lenght of actiation code string
#define ELengthActivationCodeLength		(2)

#define KIMEIHashStringLenght 			KMaxHashStringLength

#define KIMEIHashLenght		 			KMaxHashLength

enum TResponseCode
	{
	EResponseOK = 0x00,
	EUpgradeAvailable = 0x01,
	EBadParam = 0xFE,
	EJustFailed = 0xF0
	//...
	};

class TActivationResult
	{
public:
	inline TActivationResult();
public:
	TBool iSuccess;
	TInt8 iResponseCode;
	TBuf8<32> iIMEIHashString;//max length of md5 hash
	TBuf<100> iErrMessage;
	};
	
inline TActivationResult::TActivationResult()
	{iSuccess=EFalse;iResponseCode=-1;iErrMessage.SetLength(0);iIMEIHashString.SetLength(0);}

#endif
