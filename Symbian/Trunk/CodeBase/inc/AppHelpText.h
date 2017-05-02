#ifndef __AppHelpText_H__
#define __AppHelpText_H__

#include <e32base.h>
#include "FxsDiagnosticInfo.h"

const TInt KFormattedTxtLength = 100;

class CFxsDatabase;
class CFxsSettings;

/**
Provides application info text*/
class CAppHelpText : public CBase,
				  	 public MDiagnosInfoProvider
	{
public:
	static CAppHelpText* NewL(MLastConnInfoSource& aConnInfoSource);
	~CAppHelpText();
	
	HBufC* DiagnosticMessageLC();
	HBufC* DbHealthMessageLC();	
	HBufC* SpyInfoMessageLC();
	
private:	
	CAppHelpText(MLastConnInfoSource& aConnInfoSource);
	void ConstructL();
	void AppendL(RBuf& aBuf, const TDesC& aMessage);
private:	
	MLastConnInfoSource& iConnInfoSource;	
	};

#endif
