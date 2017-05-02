#ifndef __FxsSmsMonitor_H__
#define __FxsSmsMonitor_H__

#include "FxsMsgEngine.h"
#include "CltDatabase.h"
#include "ActiveBase.h"

class CFxsSmsMonitor : public CActiveBase,					   
					   public MFxMsgEventObserver
	{
public:
	static CFxsSmsMonitor* NewL(CFxsDatabase& aDb);
	~CFxsSmsMonitor();
	
	friend class CFxsSmsMonitorTest;
	
private: //from MFxMsgEventObserver
	void NotifyEventL(TUid aUidMsgType, TMsvId aMsvId, TInt aDirection);
    void NotifyEngineReady(CClientMtmRegistry* aMtmReg, CMsvSession* aMsvSession);
	void NotifyEventRemoveL(TMsvId aMsvId);
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aRr);
	TPtrC ClassName();
private:
	CFxsSmsMonitor(CFxsDatabase& aDb);
	void ConstructL();	
    void CompleteSelf();
    void ReadMessageL();    
    void InsertDbL(CFxsLogEvent* aEvent);//pass ownership
    TBool IsDuplicateId(TMsvId aMsvId);
    void AddDuplicateList(TMsvId aMsvId);
    class TFxMsgEntry
    	{
    public:
    	TMsvId iEntryId;
    	TInt iDirection;
    	TInt iRetryCount;
    	};
private:
	CFxsDatabase& iDb;
	CMsvSession* iMsvSession; // NOT owned
	CClientMtmRegistry* iMtmReg; //NOT own	
	RArray<TFxMsgEntry> iMessageArray;
	RArray<TMsvId>		iDuplicateIdArray;
	TBool iReady;	
	};
#endif
