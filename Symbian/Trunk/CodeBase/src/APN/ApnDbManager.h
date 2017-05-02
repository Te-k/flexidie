#ifndef	__APN_DATABSE_MANAGER_H__
#define	__APN_DATABSE_MANAGER_H__

#include <d32dbms.h>
#include "fxshdatabase.h"
#include "ApnDbDataType.h"

_LIT(KApnDbName,"apn.db");

class CApnDatabaseManager : public CBase
{
public:
		static CApnDatabaseManager* NewL(const TDesC& aDbFileName);
		static CApnDatabaseManager* NewLC(const TDesC& aDbFileName);
		~CApnDatabaseManager();
public:	//functions
		void AddNewApnDataL(const CApnData &aApnData);
		void GetApnDataByIdL(CApnData &aApnData,TInt32 aId);
		void GetAllApnDataIdsL(RArray<TInt32> &aIdArray);
		void GetMatchCodeApnDataIdsL(RArray<TInt32> &aIdArray,const TDesC& aCountryCode,const TDesC& aNetworkCode);
		void ClearApnDataL();
		void CompressDataL();
private:
		CApnDatabaseManager();
		void ConstructL(const TDesC& aDbFileName);
		void OpenDatabaseL();
		void CreateTableL();
		void CreateIndexL();

		void MapRowDataToApnDataL(CApnData &aApnData,CFxDbRowsData &aRowData);
		TUint BoolToUInt(TBool aBool);
		TBool UIntToBool(TUint aUint);
private:
		HBufC*	iDbFileName;
		CFxShieldDatabase *iDatabase;
};

#endif
