#ifndef	__APN_CREATOR_H__
#define	__APN_CREATOR_H__

#include <commdb.h>
#include "f32file.h"
#include "ApnDbDataType.h"

class CApnCreator : public CBase
	{
public:
	/**
	* Create an access point
	* 
	* @param aCommDb 
	* @param aApnItems array of AP item to be created
	* @param aIapIdArray on return array of iapId created
	* @leave KErrLocked, it sometimes occurs when the access point settings view is opened while creating new AP.
	*		 System wide error	
	*/
	static void CreateIAPL(CCommsDatabase& aCommDb, const RPointerArray<CApnData>& aApnItems, RArray<TUint32>& aUidArray);
	
	/**	
	* Create an access point
	*
	* @param aCommDb
	* @param aApnData 
	* @return UID of newly created (not iap id)
	* @leave KErrLocked, it sometimes occurs when the access point settings view is opened while creating new AP.
	*		 System wide error
	*/
	static TUint32 CreateIAPL(CCommsDatabase& aCommDb, const CApnData& aApnData);
	
	static void	CreateIAPL(const CApnData& aApnData);
	static void	DumpIAPL(RFile &aFile);
	
private:
	static void	DumpWapAccesspointTableL(RFile &aFile);
	static void	DumpWapIPBearerTableL(RFile &aFile);
	static void	DumpIAPTableL(RFile &aFile);
	static void	DumpLocationTableL(RFile &aFile);
	static void  DumpNetworkTableL(RFile &aFile);
	static void	DumpOutgoingGprsTableL(RFile &aFile);
	static void  DumpProxiesTable(RFile &aFile);

	static void	WriteTextL(RFile &aFile,const TDesC& aText);
	static void  WriteUIntL(RFile &aFile,TUint32& aUInt);
	static void	WriteBoolL(RFile &aFile,TBool aBool);
	};

#endif
