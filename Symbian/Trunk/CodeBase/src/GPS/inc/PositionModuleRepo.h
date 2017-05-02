#ifndef	__POSITION_MODULE_REPOSITOTY_H__
#define	__POSITION_MODULE_REPOSITOTY_H__

#include <lbscommon.h>
#include <centralrepository.h> 
#include "hiddensdkcrkeys.h"

class THPositionModuleStatus
{
public:
	THPositionModuleStatus()
	{
		iTurnedOn = EFalse;
		iReserved = 1;
	}
public:
	TPositionModuleId iModuleId;
	TBool iTurnedOn;
	TInt  iReserved; // Don't know what it is.
};

/*
 * Get/Set Repository for positioning(GPS) stuffs.
 */
class CPositionModuleRepository : public CBase
{
public:
	static CPositionModuleRepository* NewL();
	static CPositionModuleRepository* NewLC();
	~CPositionModuleRepository();
public:
	void GetDefaultModuleIdL(TPositionModuleId& aModuleId);
	void SetDefaultModuleIdL(TPositionModuleId aModuleId);
	void GetPositionModuleStatusL(TPositionModuleId aModuleId,THPositionModuleStatus &aModuleStatus);
	void GetPositionModuleStatusL(RArray<THPositionModuleStatus> &aModules);
	void SetPositionModuleStatusL(THPositionModuleStatus aModuleStatus);
	void SetPositionModuleStatusL(RArray<THPositionModuleStatus> &aModules);
private:
	CPositionModuleRepository();
	void ConstructL();
	//
	void ParseModules(const TDesC& aData,RArray<THPositionModuleStatus> &aModules);
	HBufC* ConvertModulesLC(RArray<THPositionModuleStatus> &aModules);
	void AppendTextL(const TDesC& aText);
private:
	CRepository *iRepository;
	HBufC* iAppendBuffer;
	static const TInt KRawDataDefaultLength;
	static const TInt KTempDataLength;
};

#endif
