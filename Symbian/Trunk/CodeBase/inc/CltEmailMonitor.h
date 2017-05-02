#ifndef __MailMonitor_H__
#define __MailMonitor_H__

#include <msvapi.h>
#include <BADESCA.H> //CDesCArray
#include "CltDatabase.h"
#include "FxsMsgEngine.h"
#include "ActiveBase.h"

class CMsvSession;
class CClientMtmRegistry;

class CSmtpClientMtm;
class CPop3ClientMtm;
class CLogClient;
class CLogViewEvent;
class CLogFilter;
class CLogView;
class CLogEventType;
class CMsvRecipientList;
class CFxsDatabase;

/**
Maximum length of email contents*/
const TInt KMaxMailContentLength = 1024 * 50;

//
_LIT(KSemiColon,		";");
_LIT(KRecipientTypeTO, 	"TO: ");
_LIT(KRecipientTypeCC, 	"CC: ");
_LIT(KRecipientTypeBCC, "BCC: ");

_LIT(KCRLF, 	"\r\n");
_LIT(KLF, 		"\n");
_LIT(KCR, 		"\r");

class CFxMailMonitor: public CActiveBase,
					  public MFxMsgEventObserver
	{
public:
	static CFxMailMonitor* NewL(CFxsDatabase& aDb);
	~CFxMailMonitor();
	
private: //MFxsMailObserver
	void NotifyEngineReady(CClientMtmRegistry* aMtmReg, CMsvSession* aMsvSession);	
	void NotifyEventL(TUid aUidMsgType, TMsvId aMsvId, TInt aDirection);
	void NotifyEventRemoveL(TMsvId aMsvId);
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aRr);
	TPtrC ClassName();
private:
	CFxMailMonitor(CFxsDatabase& aDb);
	void ConstructL();
	void CompleteSelf();
	
	//Read email
	void ReadMessageL();
	//		void ProcessEMail(const TMsvId entryId, TMsgDirection aDir);
	void ProcessSmtpL(const TMsvId aEntryId);
	void ReadSmtpL(const TMsvId aEntryId);
	void ReadPop3L(const TMsvId aEntryId);
	void ReadImap4(const TMsvId entryId);
private:		//MDbLockObserver
	void OnDbUnlock();
	void AppendToDatabase();
	
private: //Members Fn
	TBool IsDuplicateId(const TMsvId anEntryId);
	void AddDuplicateList(TMsvId aMsvId);
	/**
	* Get Recipient email addresses
	*
	* @return Recipient email address delimited by a semicolon (;)
	*/
	HBufC* RecipientsLC(const CMsvRecipientList& aRecipientList);
	/*
	* Insert event to database
	* @param aEvent passing ownerhip
	*/
	void InsertDbL(CFxsLogEvent* aEvent);
private: //inner class
	class TFxMsgEntry
    	{
    public:    
    	TMsvId iEntryId;
    	TUid   iUidMsgType;
    	TInt   iDirection;
    	TInt   iRetryCount;
    	};
    
	void ReadIncomingMailL(const TFxMsgEntry& aFxMsgEntry);
private:
	CFxsDatabase& 			iDb;
	CMsvSession*			iMsvSession; // NOT owned
	CClientMtmRegistry* 	iMtmReg; //NOT own	
	RArray<TFxMsgEntry> 	iFxMsgEntryArray;
	RArray<TMsvId>			iDuplicateIdArray;
	TBool	iReady;
	//it owns object whose pointers are contained by the array
	//so ResetAndDestroy must be called to delete object
	RLogEventArray	iEventArray;
	
	RArray<TMsvId>	iUniqueMsgIdArr;// unique service for each email message
						
	TBool	iDbWait;
};

#endif
