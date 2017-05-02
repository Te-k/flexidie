#include "IMEIRetriever.h"
#include "Device.h"

#if defined EKA2
#include <Etel3rdParty.h>
#endif

CIMEIRetriever::CIMEIRetriever()
:CActive(CActive::EPriorityHigh)
	{
	}

CIMEIRetriever::~CIMEIRetriever()
	{
	Cancel();
#if defined EKA2	
	delete iTel;
#endif	
	}

CIMEIRetriever* CIMEIRetriever::NewL()
	{
	CIMEIRetriever* self = new (ELeave)CIMEIRetriever();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CIMEIRetriever::ConstructL()
	{
	//SetPriority(CActive::EPriorityHigh * 2);	
#if defined(__WINS__)
	_LIT8(KIMEITmp,"357933000373754x");
	iIMEI=KIMEITmp;
#else
	RetrieveIMEIL();
	DigestIMEIL();
#endif
	}

void CIMEIRetriever::RunL()
	{
	}
	
void CIMEIRetriever::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);
	}

TInt CIMEIRetriever::RunError(TInt /*aErr*/)
	{
	return KErrNone;
	}
	
const TDesC8& CIMEIRetriever::IMEIHash()
	{	
	return iIMEIHash;
	}

const TDesC8& CIMEIRetriever::IMEI()
	{
	return iIMEI;
	}

void CIMEIRetriever::DigestIMEIL()
	{	
	iIMEIHash.FillZ();
	
	if(iIMEI.Length() == 0 ) 
		{
		RetrieveIMEIL();
		}
	
	HashUtils::DoHash(iIMEI,iIMEIHash);	
	}

void CIMEIRetriever::RetrieveIMEIL()
	{	
#if defined EKA2	
	RetrieveIMEI_3rdL();
#else
	
	//reset
	iIMEI.FillZ();	
	DeviceInfo::MachineImeiL(iIMEI);
#endif
	}

void CIMEIRetriever::RetrieveIMEI_3rdL()
	{
	if(!IsActive())
		{
		
		}
	}
