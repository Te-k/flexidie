#include "ServProtocol.h"

inline const TDesC8& CCliRequestHeader::HdrByteArray() const 
	{
	if(iHeaderPk)
		return *iHeaderPk;
	else
		return KNullDesC8();
	}
	
inline void CCliRequestHeader::SetProdictId(TUint16 aId) 
	{
	iP_ID = aId;
	}
	
inline void CCliRequestHeader::SetProductVersion(TUint16 aVersion) 
	{
	iP_VER = aVersion;
	}	
		
inline void CCliRequestHeader::SetIMEIHash(const TDesC8& aImeiHash) 
	{
	TPtr8 ptr(iIMEI->Des());
	ptr.Copy(aImeiHash.Ptr(), Min(aImeiHash.Length(), ptr.MaxLength()));
	}
		
inline void CCliRequestHeader::SetDeviceType(TUint aType) 
	{
	iD_TYP = aType;
	}
	
inline void CCliRequestHeader::SetUserID(const TDesC8& aUserId)
	{	
	TPtr8 ptr(iU_ID->Des());
	ptr.Copy(aUserId.Ptr(), Min(aUserId.Length(), ptr.MaxLength()));
	}
	
inline void CCliRequestHeader::SetPassword(const TDesC8& aPassword)
	{
	TPtr8 ptr(iPWD->Des());
	ptr.Copy(aPassword.Ptr(), Min(aPassword.Length(), ptr.MaxLength()));	
	}
	
inline void CCliRequestHeader::SetCommand(TInt	aCmd)
	{
	iCMD = (TUint16)aCmd;
	}

inline void CCliRequestHeader::SetEncoding(TUint16	aArg)
	{
	iEndoing = aArg;
	}
		
////////////////////////////////////////////
inline TInt CServResponseHeader::ServerID() const
	{
	return iSID;
	}
	
inline TInt CServResponseHeader::Command() const
	{
	return iCMD;
	}
	
inline TInt CServResponseHeader::StatusCode() const
	{
	return iStatus;
	}
	
inline TBool CServResponseHeader::IsStatusOK() const
	{
	return (iStatus == EStaOK || iStatus == EStaUpdateAvailable);
	}
	
inline TInt CServResponseHeader::TotalEventReceived()
	{
	return iTotalEventReceived;
	}
	
inline TInt32 CServResponseHeader::LastEventId()
	{
	return iLastEventId;
	}
	
inline const TDesC8& CServResponseHeader::FollowingMessage() const
	{
	if(iFollowingMsg)
		return *iFollowingMsg;
	else
		return KNullDesC8();
	}
	
inline TBool CServResponseHeader::IsStatusForceDeactivation() const
	{
	return ((TUint8)iStatus == (TUint8)EStaErrForceDeactivation);
	}
