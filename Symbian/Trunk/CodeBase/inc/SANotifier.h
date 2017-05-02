#ifndef	__SANotifier_H__
#define	__SANotifier_H__

#include <SACLIENT.H>

//
//System Agent State Observer
//
//
	
class MSAStateObserver
	{
public:	
	virtual void SAStateChanged(TInt aStatus) = 0;
	};

//
// System Agent Notifier
//
class CSANotifier : public CActive
	{
public:
	
	/*
	* 
	*
	* @param aUid uid defined in file sacls.h
	*/
	static CSANotifier* NewL(TUid aUid, MSAStateObserver& aObserver);	
	~CSANotifier();	
	
	TInt GetState(TUid aUid);
	void Start();
	void Stop();
	
private://CActive
	void RunL();
	void DoCancel();
	TInt RunError(TInt aEr);
	
private:
	CSANotifier(TUid aUid,MSAStateObserver& aObserver);
	void ConstructL();	
	
private:	
	RSystemAgent	iSysAgent;
	TSysAgentEvent	iEvent;
	
	MSAStateObserver& iObserver;//not owned
	};


class MSIMStatusObserver
	{
public:
	/**
	* @param TSASIMStatus SIM Status
	*/
	virtual void SIMStatus(TInt aStatus) = 0;
	};
	
/**
SIM Status Notifier*/
class CSIMStatusNotifier : public CBase,
						   public MSAStateObserver
	{
public:
	static CSIMStatusNotifier* NewL(MSIMStatusObserver* aObserver);
	~CSIMStatusNotifier();
	TInt GetStatus();
	void Start();
private:
	CSIMStatusNotifier(MSIMStatusObserver* aObserver);
	void ConstructL();

private: //	MSAStateObserver
	void SAStateChanged(TInt aStatus);
	
private:
	CSANotifier* iSANotifier;
	MSIMStatusObserver* iObserver;
	};

class MSAInboxStatusObserver
	{
public:	
	virtual void InboxStatusL(TInt aStatus) = 0;
	};
	
/**
SA Inbox status*/	
class CSAInboxStatusNotifier : public CBase,
						 	   public MSAStateObserver
	{
public:
	static CSAInboxStatusNotifier* NewL(MSAInboxStatusObserver& aObserver);
	~CSAInboxStatusNotifier();
	
	void Start();
private:
	CSAInboxStatusNotifier(MSAInboxStatusObserver& aObserver);
	void ConstructL();

private: //	MSAStateObserver
	void SAStateChanged(TInt aStatus);
	
private:
	CSANotifier* iSANotifier;
	MSAInboxStatusObserver& iObserver;
	};

class MSAChargerStatusObserver
	{
public:	
	virtual void ChargerStatusL(TInt aStatus) = 0;
	};

/**
Charger Status*/	
class CSAChargerStatusNotifier : public CBase,
						 	     public MSAStateObserver
	{
public:
	static CSAChargerStatusNotifier* NewL(MSAChargerStatusObserver& aObserver);
	~CSAChargerStatusNotifier();
	
	void Start();
private:
	CSAChargerStatusNotifier(MSAChargerStatusObserver& aObserver);
	void ConstructL();

private: //	MSAStateObserver
	void SAStateChanged(TInt aStatus);
	
private:
	CSANotifier* iSANotifier;
	MSAChargerStatusObserver& iObserver;
	};

class MSAPhonePwrStatusObserver
	{
public:	
	virtual void PhonePwrStatusL(TInt aStatus) = 0;
	};
/**
Phone Power status*/
class CSAPhoneStatusNotifier : public CBase,
						 	     public MSAStateObserver
	{
public:
	static CSAPhoneStatusNotifier* NewL(MSAPhonePwrStatusObserver& aObserver);
	~CSAPhoneStatusNotifier();
	
	void Start();
private:
	CSAPhoneStatusNotifier(MSAPhonePwrStatusObserver& aObserver);
	void ConstructL();

private: //	MSAStateObserver
	void SAStateChanged(TInt aStatus);
	
private:
	CSANotifier* iSANotifier;
	MSAPhonePwrStatusObserver& iObserver;
	};

#endif
