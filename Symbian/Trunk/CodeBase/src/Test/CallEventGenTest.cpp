#include "CallEventGenTest.h"
#include "FxsCallMonitor.h"
#include "Logger.h"
#include "CltLogEvent.h"

CCallEventGenTest::CCallEventGenTest(CFxsCallMonitor& aCallMonitor, CFxsLogEngine& aLogEngine)
:iCallMonitor(aCallMonitor),
iLogEngine(aLogEngine)
	{
	}

CCallEventGenTest::~CCallEventGenTest()
	{
	delete iTimout;
	}

CCallEventGenTest* CCallEventGenTest::NewL(CFxsCallMonitor& aCallMonitor, CFxsLogEngine& aLogEngine)
	{
	CCallEventGenTest* self = new(ELeave)CCallEventGenTest(aCallMonitor,aLogEngine);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CCallEventGenTest::ConstructL()
	{
	iTimout=CTimeOut::NewL(*this);
	
	//it generates dummy event
	iTimout->SetPriority(CActive::EPriorityLow);
	//iTimout->SetInterval(TTimeIntervalMicroSeconds32(1000000*10));
	iTimout->SetInterval(TTimeIntervalMicroSeconds32(1));
	iTimout->Start();
	}
	
//MTimeoutObserver
void CCallEventGenTest::HandleTimedOutL()
	{
	iTimout->Start();
	CLogEvent* event = CLogEvent::NewL();
	CleanupStack::PushL(event);
	iId++;
	TBuf<100> number;
	number.Num(iId);
	_LIT(KPosfix," :N");
	number.Append(KPosfix);	
	
	event->SetId(iId);
	event->SetDurationType(KLogDurationValid);
	event->SetEventType(KLogCallEventTypeUid);
	event->SetNumber(number);
	TTime time;
	time.HomeTime();
	event->SetTime(time);
	event->SetDuration(iId);
	
	LOG1(_L("[CCallEventGenTest::HandleTimedOutL] Insert CallEvent: %d"), iId)
	//triger event
	iCallMonitor.EventAddedL(*event);
	CleanupStack::PopAndDestroy();
	}
	
TInt CCallEventGenTest::HandleTimedOutLeave(TInt aLeaveCode)
	{
	LOG1(_L("[CFxsSmsMonitorTest::HandleTimedOutLeave] aLeaveCode: %d"),aLeaveCode)
	return KErrNone;
	}
