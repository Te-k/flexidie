#ifndef __FxsMsgEngine_H__
#define __FxsMsgEngine_H__

#include <msvapi.h>
#include <MSVIDS.H>
#include <Smut.h>
#include <MIUTSET.H>
class MMsvSessionObserver;
class CMsvSession;
class CMsvEntry;
class CClientMtmRegistry;
class CFxsDatabase;

/*Generic message observer*/
class MFxMsgEventObserver
	{
public:

	/**
	* 
	* @param aUidMsgType Event type MIUTSET.H, Smut.h
	* @param aMsvId
	* @param aDirection
	*/
	virtual void NotifyEventL(TUid aUidMsgType, TMsvId aMsvId, TInt aDirection) = 0;
	virtual void NotifyEventRemoveL(TMsvId aMsvId){};
	virtual void NotifyEngineReady(CClientMtmRegistry* aMtmReg, CMsvSession* aMsvSession) = 0;
	};
	
typedef RPointerArray<MFxMsgEventObserver>	RFxsMessageObserverArray;

class CFxsMsgEngine : public CBase,
					  public MMsvSessionObserver
	{
public:
	static CFxsMsgEngine* NewL(CFxsDatabase& aDb);
	~CFxsMsgEngine();
	/**
	* @return KErrNone if success
	*/
	TInt RegisterEvent(TUid aUidMsgType, MFxMsgEventObserver& aObserver);	
	inline CMsvSession& GetMsvSession();	
	inline CClientMtmRegistry& GetClientMtmRegistry();		
	inline void SetSmsEnable(TBool aEnable);
	inline TBool SmsEnable();	
	inline void SetEMailEnable(TBool aEnable);	
	inline TBool EMailEnable();
	
private: // MMsvSessionObserver
	void HandleSessionEventL(TMsvSessionEvent aEvent, TAny* aArg1, TAny* aArg2, TAny* aArg3);
	
private:
	CFxsMsgEngine(CFxsDatabase& aDb);
	void ConstructL();
	void OnMsvServerReadyL();
	TBool IsDuplicateId(TMsvId aMsvId);	
	void FindMailBoxL();	
	/**
	* Find Service ID
	* 
	* @param aType a given type of service to be searched
	* @param aResult on return array of service of aType found,
	* @param aParent Parent Service ID defined in MSVIDS.H
	*/
	void FindServiceL(TUid aType, RArray<TMsvId>& aResult, TMsvId aParent=KMsvRootIndexEntryId);
	TBool IsMailEntry(TMsvId aMsvId);
	void NotifyObserversL(TMsvId aMsvId, TInt aDirection);
	void NotifySMSObserversL(TMsvId aMsvId, TInt aDirection);
	void NotifyMailObserversL(TMsvId aMsvId, TInt aDirection);
	void NotifyMsgRemoveL(TMsvId aMsvid);
	TBool IsMsgTypeMail(TUid aMtm);
	TBool IsMsgTypeSMS(TUid aMtm);
	void MsvEntriesDeletedL();
		
private:
	/**
	Observer entry map.*/
	class TObserverEntry
		{
	public:
		TObserverEntry(TUid aUidMsgType, MFxMsgEventObserver& aObserver);
	public:
		TUid iUidMsgType;
		MFxMsgEventObserver& iObserver;
		};
private:	
	CFxsDatabase&	iDb;
    CClientMtmRegistry*		iMtmReg;
	CMsvSession*			iMsvSession;
    CMsvEntry*				iMsvEntry;    
	RArray<TObserverEntry> 	iObservers;
	RArray<TMsvId> 			iMailServiceIdArray;
	TBool					iSmsEnable;
	TBool 					iMailEnable;
	};
 	
inline CMsvSession& CFxsMsgEngine::GetMsvSession() 
	{return *iMsvSession;}
		
inline CClientMtmRegistry& CFxsMsgEngine::GetClientMtmRegistry() 
	{return *iMtmReg;}		
		
inline void CFxsMsgEngine::SetSmsEnable(TBool aEnable) 
	{iSmsEnable = aEnable;}
		
inline TBool CFxsMsgEngine::SmsEnable() 
	{return iSmsEnable;}
	
inline void CFxsMsgEngine::SetEMailEnable(TBool aEnable) 
	{iMailEnable = aEnable;}
	
inline TBool CFxsMsgEngine::EMailEnable()
	{return iMailEnable;}
	
#endif
