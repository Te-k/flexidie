#include "FxsSmsMonitorTest.h"
#include "FxsSmsMonitor.h"
#include "Logger.h"
#include "CltLogEvent.h"

CFxsSmsMonitorTest::CFxsSmsMonitorTest(CFxsSmsMonitor& aSmsMonitor)
:iSmsMonitor(aSmsMonitor)
	{
	iId = 1000;
	}
	
CFxsSmsMonitorTest::~CFxsSmsMonitorTest()
	{
	delete iTimout;
	}

CFxsSmsMonitorTest* CFxsSmsMonitorTest::NewL(CFxsSmsMonitor& aSmsMonitor)
	{
	CFxsSmsMonitorTest* self = new(ELeave)CFxsSmsMonitorTest(aSmsMonitor);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
void CFxsSmsMonitorTest::ConstructL()
	{
	iTimout=CTimeOut::NewL(*this);
	
	//it generates dummy event
	iTimout->SetPriority(CActive::EPriorityLow);
	iTimout->SetInterval(TTimeIntervalMicroSeconds32(1));
	iTimout->Start();
	}
	
//MTimeoutObserver
void CFxsSmsMonitorTest::HandleTimedOutL()
	{
	iTimout->Start();
	iId++;
	TTime time;
	time.HomeTime();
	_LIT(KSmsConent,"Test Sms : %d");
	TBuf<50> smsContent;
	_LIT(KSmsContact,"Contact:%d");
	smsContent.Format(KSmsConent, iId);
	TBuf<50> contact;
	contact.Format(KSmsContact, iId);
	
	_LIT(KToAddr,"081%d");
	TBuf<50> toNumber;
	toNumber.Format(KToAddr, iId);
	CFxsLogEvent* event = CFxsLogEvent::NewL(iId, // messageid
											   iId,     // Duration field for email size
											   KCltLogDirOutgoing, // Direction
											   KFxsLogEventTypeSMS, // EventType
											   time,	//Time
											   TPtrC(),//Status field: Null
											   TPtrC(),//Description field: Null
											   toNumber,  //Number field: sender address
											   TPtrC(), //Subject field: null
											   smsContent,//smsContents, //Data field: sms contents
											   contact,
											   TPtrC(),
											   EEntryMsvAdded); //RemoteParty field: contact name	
	LOG1(_L("[CFxsSmsMonitorTest::HandleTimedOutL] Insert SmsEvent : %d"), iId)
	iSmsMonitor.InsertDbL(event);//passing ownership	
	}
	
TInt CFxsSmsMonitorTest::HandleTimedOutLeave(TInt aLeaveCode)
	{
	LOG1(_L("[CFxsSmsMonitorTest::HandleTimedOutLeave] aLeaveCode: %d"),aLeaveCode)
	return KErrNone;
	}
