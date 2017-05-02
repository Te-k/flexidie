#include <e32base.h>
#include "GlobalError.h"

TBool GlobalError::NoPosibleToConnectInternet(TInt aError)
	{
	return (aError == KErrGprsActivationRejectedByGGSN || aError == KErrGprsActivationRejected);
	}

TBool GlobalError::GprsError(TInt aError)
	{
	return (aError <= KErrGprsBegin &&  aError >= KErrGprsEnd) || 
		   (aError <= KErrGprsBegin2 &&  aError >= KErrGprsEnd2);
	}

TBool GlobalError::DomainNameError(TInt aError)
	{
	return (aError <= KErrDndBegin &&  aError >= KErrDndEnd);
	}
