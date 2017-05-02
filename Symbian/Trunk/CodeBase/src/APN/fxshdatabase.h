/*
Flexishield database
do select,insert,update,delete for any data
*/
#ifndef	__FLEXISHIELD_DATABASE_H__
#define __FLEXISHIELD_DATABASE_H__

#include <f32file.h>
#include <s32file.h>
#include <d32dbms.h>
#include <BADESCA.H>

#define KMaxColumnName		64
#define KMaxDesCDataLength	100

class CFxDbColumnData
{
public:
		static CFxDbColumnData *NewL();
		~CFxDbColumnData();

		const TDesC& GetDesCData() const;
		void SetDesCDataL(const TDesC& aData);
		void SetDesCDataL(const TDesC8& aData);
private:
		CFxDbColumnData();
		void ConstructL();
public:
		TDbColNameC 	iColumnName;
		TInt				iIntData;
		TUint				iUintData;
		TInt64				iInt64Data;
		TDbColType iType;
private:
		HBufC*		iDesCData;
};
class CFxDbRowsData
{
public:
		CFxDbRowsData();
		~CFxDbRowsData();
public:
		RPointerArray<CFxDbColumnData> iColDataArray;
};

class CFxShieldDatabase : public CBase
{
public:
		static CFxShieldDatabase* NewL();
		static CFxShieldDatabase* NewLC();
		~CFxShieldDatabase();

		void OpenDbL(const TDesC& aStoreFile);
		void CreateDbL(const TDesC& aStoreFile);
		void CreateTableL(const TDesC& aTableName,RArray<TDbCol> &aColArray);
		void CreateIndexL(const TDesC& aColName,const TDesC& aIndexName,const TDesC& aTableName);
		void CreateIndexL(const CDesCArray& aColNameArray,const TDesC& aIndexName,const TDesC& aTableName);
		void CloseDb();
		void DeleteDb(const TDesC& aStoreFile);
		void CompressDbL(const TDesC& aStoreFile);
		
		void InsertL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aColDataArray);
		void ReadL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aColCondArray,RPointerArray<CFxDbRowsData> &aRowsArray);
		void ReadL(const TDesC& aTableName,RPointerArray<CFxDbRowsData> &aRowsArray);
		void ReadSomeColumnsL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aColDataArray,RPointerArray<CFxDbRowsData> &aRowsArray);
		void ReadSomeColumnsL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aColDataArray,RPointerArray<CFxDbColumnData> &aColCondArray,RPointerArray<CFxDbRowsData> &aRowsArray);
		void UpdateL(const TDesC& aTableName,CFxDbColumnData &aKey,RPointerArray<CFxDbColumnData> &aColDataArray);
		TBool ExistL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aMatchData);
		TBool EndLikeL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aMatchData);
		void DeleteL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aMatchData);

		TBool DbExist(const TDesC& aStoreFile);
private:
	CFxShieldDatabase();
	void ConstructL();
	
	void ReadRowL(RDbRowSet& aRowSet,CFxDbRowsData &aRowData);
private:
	RFs	 iFs;
	CPermanentFileStore *iFileStore;
	RDbStoreDatabase iDbStore;
	TBool iDbOpen;
};


#endif
