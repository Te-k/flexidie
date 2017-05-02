#ifndef __CCltEmailLogEntry_H__
#define __CCltEmailLogEntry_H__

#include <msvapi.h>
#include <BADESCA.H> //CDesCArray
#include "Cltlogeventdb.h"
#include "CltMessageMonitor.h"


class CMsvSession;
class CClientMtmRegistry;

class CSmtpClientMtm;
class CPop3ClientMtm;
class CLogClient;
class CLogViewEvent;
class CLogFilter;
class CLogView;
class CLogEventType;

class CCltDatabase;
class CCltEmailMonitor;



class  CCltEmailLogEntry :	 public CActive,
							 public MDbLockObserver
{	
	public:
		~CCltEmailLogEntry();
		static CCltEmailLogEntry* NewL(CMsvSession& aMsvSession, CClientMtmRegistry& aMtmReq, CLogClient& aLogCli, CCltDatabase& aLogEventDb);
		static CCltEmailLogEntry* NewLC(CMsvSession& aMsvSession, CClientMtmRegistry& aMtmReq, CLogClient& aLogCli, CCltDatabase& aLogEventDb);
		
	private:
		CCltEmailLogEntry(CMsvSession& aMsvSession, CClientMtmRegistry& aMtmReq, CLogClient& aLogCli, CCltDatabase& aLogEventDb);
		void ConstructL();
		
	public: // from CActive	
		void DoCancel();	
		void RunL();	
		TInt RunError(TInt aError);
		
	public: //Members Fn
//		void ProcessEMail(const TMsvId entryId, TMsgDirection aDir);
		void ProcessSmtpL(const TMsvId aEntryId);
		void ProcessPop3L(const TMsvId aEntryId);
		void ProcessImap4(const TMsvId entryId);
		void GetAttachementNameL(const TMsvId aMessageId, HBufC** aResult);
		
	private:
		//MDbLockObserver
		void OnDbUnlock();
		void AppendToDatabase();
		
	private: //Members Fn		
		void GetRecipientsEmailAddr(const CDesCArray& emailAddrArr, HBufC** aResult);
		
		void AddEventToLogEngine(CLogEvent* aLogEvent);
		
		//to register MailEvent to logengine 
		void RegisterEventType();
		
		enum TState	{
			EIdle,
			EAddingEvent,
			ERegisteringEventType
		};		
		
	private:
		
		CMsvSession&			iMsvSession;
		CClientMtmRegistry&		iMTMReg;
		
		TState			iState;		
		CLogClient&		iLogClient;
		CCltDatabase&	iDb;	
		CLogEventType*	iEventTypeMail;
		
		CCltEmailMonitor*	iEmailMonitor;		
		
		//it owns object whose pointers are contained by the array
		//so ResetAndDestroy must be called to delete object
		RLogEventArray	iEventArray;
		
		RArray<TMsvId>	iUniqueMsgIdArr;// unique service for each email message
		
		CLogEvent*		iCurrAddingEvent;
		TBool           iEventTypeRegistered;
		TBool	iDbWait;
};

#endif