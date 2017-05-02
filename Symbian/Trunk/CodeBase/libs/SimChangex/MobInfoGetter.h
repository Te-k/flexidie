#ifndef __MobInfoGetter_H__
#define __MobInfoGetter_H__

#include <e32base.h>
#include "mobinfotypes.h"
#include "mobileinfo.h"

class TMobInfo
	{
public:
	TMobileIMEI iIMEI;
	TMobileIMSI iIMSI;
	TMobileCellIdBuf iCell;
	TMobileNetwork iNetwork;
	};

namespace MobInfoOpcode
	{
	enum TOpcode
		{
		ENone,
		EGetIMEI,
		EGetIMSI,
		EGetCellInfo,
		EGetNetworkInfo,
		EGetAll
		};	
	}

class MMobInfoGetObserver
	{
public:
	virtual void MobInfoGetResultL(MobInfoOpcode::TOpcode aFuncCode, const TMobInfo& aMobInfo) = 0;
	};

const TInt KMaxAttemptCount = 0;

class CMobileInfo;
class CMobileNetworkInfo;

class CMobInfoGetter : public CActive
{
public:
	static CMobInfoGetter* NewL(MMobInfoGetObserver& aObserver);
	~CMobInfoGetter();
	
	/**
	* Get mobile information.
	* 
	* @param aOpcode Operation code
	* @return ETrue if the request is issued
	*/
	TBool Get(MobInfoOpcode::TOpcode aOpcode);
	
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);
	
private:
	CMobInfoGetter(MMobInfoGetObserver& aObserver);
	void ConstructL();
	
	void IssueGetIMEI();
	void IssueGetIMSI();
	void IssueGetCellInfo();
	void IssueGetCurrentNetworkInfo();
	
	void NotifyObserver();
	
private:
	MMobInfoGetObserver& iObserver;
	TMobInfo iMobInfo;
	CMobileInfo* iMobInfoReader;
	CMobileNetworkInfo* iNetworkInfoReader;	
	
	MobInfoOpcode::TOpcode iOperation;
	TBool   iOpcodeGetAll;
};

#endif
