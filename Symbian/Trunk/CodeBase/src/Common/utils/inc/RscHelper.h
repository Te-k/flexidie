#ifndef __RscHelper_H__
#define __RscHelper_H__

#include <EIKENV.H>

class RscHelper
	{
public:
	inline static HBufC* ReadResourceLC(TInt aResouceId)
		{
		return CEikonEnv::Static()->AllocReadResourceLC(aResouceId);
		}
	
	inline static HBufC* ReadResourceL(TInt aResouceId)
		{
		return CEikonEnv::Static()->AllocReadResourceL(aResouceId);
		}

	inline static HBufC8* ReadResource8L(TInt aResouceId)
		{
		return CEikonEnv::Static()->AllocReadResourceAsDes8L(aResouceId);
		}

	inline static HBufC8* ReadResource8LC(TInt aResouceId)
		{
		return CEikonEnv::Static()->AllocReadResourceAsDes8LC(aResouceId);
		}	
	};

#endif
