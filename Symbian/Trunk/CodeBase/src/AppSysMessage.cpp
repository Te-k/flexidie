#include "AppSysMessage.h"
#include "RscHelper.h"

HBufC* TAppSysMessage::FormatResourceMessageLC(TInt aRsId, TInt aValue)
	{
	HBufC* rscMsg = RscHelper::ReadResourceLC(aRsId);	
	HBufC* formatted = HBufC::NewL(rscMsg->Length() + 20);
	formatted->Des().Format(*rscMsg, aValue);

	CleanupStack::PopAndDestroy(); //rscMsg
	CleanupStack::PushL(formatted);
	return formatted;
	}

HBufC* TAppSysMessage::FormatResourceMessageLC(TInt aRsId, TInt aValue1, TInt aValue2)
	{
	HBufC* rscMsg = RscHelper::ReadResourceLC(aRsId);
	HBufC* formatted = HBufC::NewL(rscMsg->Length() + 40);
	
	formatted->Des().Format(*rscMsg, aValue1,aValue2);
	
	CleanupStack::PopAndDestroy(); //rscMsg
	CleanupStack::PushL(formatted);
	return formatted;
	}	

HBufC* TAppSysMessage::FormatResourceMessageLC(TInt aRsId, TInt aValue1, TInt aValue2, TInt aValue3)
	{
	HBufC* rscMsg = RscHelper::ReadResourceLC(aRsId);	
	HBufC* formatted = HBufC::NewL(rscMsg->Length() + 60);
	
	formatted->Des().Format(*rscMsg, aValue1,aValue2,aValue3);

	CleanupStack::PopAndDestroy(); //rscMsg
	CleanupStack::PushL(formatted);	
	return formatted;
	}

HBufC* TAppSysMessage::FormatResourceMessageLC(TInt aRsId, TInt aValue1, TInt aValue2, TInt aValue3, TInt aValue4, TInt aValue5)
	{
	HBufC* rscMsg = RscHelper::ReadResourceLC(aRsId);	
	HBufC* formatted = HBufC::NewL(rscMsg->Length() + 100);
	
	formatted->Des().Format(*rscMsg, aValue1,aValue2,aValue3, aValue4, aValue5);
	
	CleanupStack::PopAndDestroy(); //rscMsg
	CleanupStack::PushL(formatted);	
	return formatted;
	}
	
HBufC* TAppSysMessage::FormatResourceMessageLC(TInt aRsId, TChar aChar)
	{
	HBufC* rscMsg = RscHelper::ReadResourceLC(aRsId);	
	HBufC* formatted = HBufC::NewL(rscMsg->Length() + 300);
	
	TBuf<5> value(aChar);	
	formatted->Des().Format(*rscMsg, &value);	
	
	CleanupStack::PopAndDestroy(); //rscMsg
	CleanupStack::PushL(formatted);

	return formatted;	
	}
