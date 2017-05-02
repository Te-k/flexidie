#ifndef __IMEIGetter_H__
#define __IMEIGetter_H__

#include <e32base.h>
#include "IMEIObserver.h"

#if defined(EKA2) // 3 rd
	#include "CommonServiceClient.h"
	#define BASE_CLASS	public CActive, public MMobileInfoNotifiable
#else
	#define BASE_CLASS	public CActive
#endif

/**
* It provides device IMEI data as async operation for both 2nd and 3rd
*/
class CIMEIGetter : BASE_CLASS
	{
public:
	static CIMEIGetter* NewL();
	~CIMEIGetter();	
	TInt AddObserver(MDeviceIMEIObserver& aObserver);
	/**
	* Issue getting IMEI data
	* Make sure all needed observers are added before calling this method
	*/
	void IssueGet();	
private:
	void DoCancel();
	void RunL();
	TInt RunError(TInt aErr);
	
#if defined(EKA2)
private:
	void OfferMobileInfoL(const TMobileInfo& aMobileInfo);
#endif

private:
	CIMEIGetter();
	void ConstructL();
	void RequestComplete();
	void NotifyObservers();
	
private:
	RArray<TAny*> iObservers; //not owned
	TDeviceIMEI	iIMEI;
	};

#endif
