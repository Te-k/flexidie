#ifndef __CCltMmsMonitor_H__
#define __CCltMmsMonitor_H__

#include <msvapi.h>
#include <logwrap.h> //TLogId
#include "CltMessageMonitor.h"

class CLogClient;
class CClientMtmRegistry;
class CMsvSession;
class CLogViewEvent;
class CLogFilter;
class CLogView;

class CCltDatabase;
class CFxsLogEvent;
class MLogEventObserver;
class CMmsClientMtm;
class CCltMmsInfo;

class  CCltMmsMonitor :	 public CActive,
						 public MDbLockObserver
{
	
public: 
	virtual ~CCltMmsMonitor();
	static CCltMmsMonitor* NewL(CMsvSession& aMsvSession, CClientMtmRegistry& aMtmReq, CLogClient& aLogCli, CCltDatabase& aLogEventDb);
	static CCltMmsMonitor* NewLC(CMsvSession& aMsvSession, CClientMtmRegistry& aMtmReq,CLogClient& aLogCli, CCltDatabase& aLogEventDb);

private:	
	enum TEntryType
	{
		EParentEntry = 1,
		EChildEntry
	};	

public: // from CActive	
	void DoCancel();	
	void RunL();	
	TInt RunError(TInt aError);
	void ProcessMMSL(const TMsvId entryId, TMsgDirection aDir);	
	
private:		
	CCltMmsMonitor(CMsvSession& aMsvSession,CClientMtmRegistry& aMtmReq, CLogClient& aLogCli, CCltDatabase& aLogEventDb);
	void ConstructL();	
	
	void GetAttachementFileName(const TMsvId aEntryId,  HBufC** aResult);
	//from MDbLockObserver
	void OnDbUnlock();
	void ResetCActiveStatus();
	void AppendToDatabase();
	
	void AppendStringL(HBufC* aResult, const TDesC& aString);
	
	CLogEvent* CreateCLogEvent(const TDesC& aSubject,
												   const TDesC& aContents, 
												   const TDesC& aFromEmailAddr,
												   const TDesC& aToEmailAddr, 
												   const TTime& aTime,
												   const TUint32  aSize,
												   const TDesC& aDirection);
	
	TBool IsDuplicateId(const TMsvId anEntryId);	
		
private:
	
	CMsvSession&			iMsvSession;
	CClientMtmRegistry& 	iMtmReg;
	CLogClient&				iLogClient; // not own by this object
	TLogId                  iLastLogId; // remember the last id	
	CLogViewEvent*			iLogView;
	CLogFilter*				iLogFilter;	
		
	//RArray<TMsvId>			iMsvIdList;
	CCltDatabase&           iDb;
	
	//it owns object whose pointers are contained by the array
	//so ResetAndDestroy must be called to delete object	
	RLogEventArray	iEventArray;
	
	TBool	iDbWait;
	RArray<TMsvId>	iUniqueMsgIdArr;// unique service for each email message
	
};

/*class CCltMmsInfo : public CBase
{	
	public:
		virtual ~CCltMmsInfo();
		CCltMmsInfo();
		
		void SetSenderL(const TDesC& aName);
		void AddAttachmentNameL(const TDesC& aName);
		void AddAddrToL(const TDesC& aAddr);
		void AddAddrBccL(const TDesC& aAddr);
		void AddAddrCcL(const TDesC& aAddr);			
		void AddContactNameL(const TDesC& aName);
		void SetSubjectL(const TDesC& aSubject);
		void SetSize(const TInt aSize);
		void SetTime(const TTime aTime);
		void SetMessageId(const TMsvId aId);
		
		const TDesC& RecipientTo() const;
		const TDesC& RecipientCc() const;
		const TDesC& RecipientBcc() const;
		const TDesC& Subject() const;
		const TDesC& Sender() const;		
		const TDesC& Contacts() const;
		const TDesC& Attachments() const;
		
	private:
		void ReAllocL(HBufC* aBuf);
		
	public:
		TMsvId  iMessageId;
		TTime	iTime;
		TInt32	iSize;
		
	private:		
		HBufC*	iSubject;		
		//sender
		HBufC*	iSender; // John<+6616684485>
		HBufC*	iAddrTo; //7722;abcd@hotmail.com
		HBufC*	iAddrCc;
		HBufC*	iAddrBcc;
		
		HBufC*	iContactName;// is delimited by semi-colon(;)		
		HBufC*	iAttachmentName; // is delimited by semi-colon(;)
		
};*/	

// End of File
#endif