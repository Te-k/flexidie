#include "CltApplication.h"
#include "CltDocument.h"

#if defined EKA2
#include <eikstart.h>
#endif

TUid CCltApplication::AppDllUid() const
	{
	return KAppUid;
	}
	
CApaDocument* CCltApplication::CreateDocumentL()
	{
	//return (static_cast<CApaDocument*>
    //               ( CCltDocument::NewL( *this ) ) );
	return CCltDocument::NewL(*this);
	}

/*EXPORT_C*/ LOCAL_C CApaApplication* NewApplication()
	{
	return new CCltApplication;
	}
    
#if defined EKA2
// ---------------------------------------------------------
// E32Main 
// main function for Symbian OS v9 EXE application.
// ---------------------------------------------------------
//
GLDEF_C TInt E32Main()
    {
    return EikStart::RunApplication ( NewApplication );
    }

#else // 2rd edition

GLDEF_C TInt E32Dll(TDllReason)
	{
	return KErrNone;
	}

#endif


