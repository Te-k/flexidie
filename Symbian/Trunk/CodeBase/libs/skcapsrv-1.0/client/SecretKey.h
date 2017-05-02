#ifndef __SecretCode_H_
#define __SecretCode_H_

#include <e32base.h>

const TInt KMaxSecretCodeLength = 30;

class TSecretCode
	{
public:
	/**
	* Secret key
	*
	*/
	TBuf8<KMaxSecretCodeLength> iCode;
	};

typedef TPckg<TSecretCode>  TSecretCodePkg;
	
#endif