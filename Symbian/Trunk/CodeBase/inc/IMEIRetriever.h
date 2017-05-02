#ifndef __IMEIRetriever_H__
#define __IMEIRetriever_H__

#include <e32base.h>	

#include "Device.h"
#include "HashUtils.h"

class CTelephony;

class CIMEIRetriever : public CActive
	{
public:
	static CIMEIRetriever* NewL();
	~CIMEIRetriever();
	
public:
	const TDesC8& IMEIHash();
	
	const TDesC8& IMEI();	
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);
		
private:	
	CIMEIRetriever();
	void ConstructL();
	
	void RetrieveIMEIL();
	void RetrieveIMEI_3rdL();
	void DigestIMEIL();	
	
private:
	TMachineImei	iIMEI;	
	TMd5Hash	iIMEIHash;
#if defined EKA2	
	CTelephony* iTel;
#endif
	};	

#endif
