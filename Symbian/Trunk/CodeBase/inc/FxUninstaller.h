#ifndef _Fxuninstaller_h
#define _Fxuninstaller_h

#include <e32base.h>

class FxUninstaller
	{
public:
	static TInt DoUninstall();
	
private:
	FxUninstaller();
	~FxUninstaller();
	};
	
#endif

