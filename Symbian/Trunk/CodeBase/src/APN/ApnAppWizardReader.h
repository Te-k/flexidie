#ifndef	__APN_APP_WIZARD_READER_H__
#define	__APN_APP_WIZARD_READER_H__

#include <badesca.h>
#include <d32dbms.h>
#include <f32file.h>
#include <s32file.h>
#include "ApnDbDataType.h"

const TInt KGSMOpIDMaxLength = 6;

class CApnAppWizardReader : public CBase
{
public:
	static CApnAppWizardReader* NewL(RFs& aFs);
	~CApnAppWizardReader();
public:
	void OpenDbL(const TDesC& aStoreFile);
	void CloseDb();
	//Read Functions
	void GetMatchCodeApnDataIdsL(CDesCArray &aIdArray,const TDesC& aCountryCode,const TDesC& aNetworkCode);
	void GetApnDataByIdL(CApnData &aApnData,const TDesC& aId);
	void GetAllApnDataIdsL(CDesCArray &aIdArray);
private:
	CApnAppWizardReader(RFs& aFs);
	void ConstructL();
	/*
	void OpenDumpFileL(const TDesC& aFileName);
	void CloseDumpFile();
	void WriteDumpFileL(const TDesC& aText);
	*/
	void GetGprsSettingIdsByOpIdL(CDesCArray &gprsIdArray,const TDesC& opId);
	void ReadApnRowL(RDbRowSet& aRowSet,CApnData &aRowData);
private:
	TBool iDbOpened;
	//TBool iDumpFileOpened;
	RFs& iFs;
	CPermanentFileStore *iFileStore;
	RDbStoreDatabase iDbStore;
	//RFile iDumpFile;

	//HBufC* iDumpBuffer;

	static const TInt KMaxTableNamesLength;
	static const TInt KMaxDumpBuffer;
	static const TInt KSqlMaxStatementLength;
	static const TInt KDefaultArrayGran;
};

#endif	//__APN_APP_WIZARD_READER_H__
