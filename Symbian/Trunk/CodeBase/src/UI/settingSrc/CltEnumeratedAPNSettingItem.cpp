#include "CltEnumeratedAPNSettingItem.h"

#include <commdb.h>
#include <cdblen.h>	
#include "Logger.h"

CCltEnumeratedAPNSettingItem::CCltEnumeratedAPNSettingItem(TInt aIdentifier, TUint32& aIapId, TDes& aIapName)
:CAknEnumeratedTextPopupSettingItem(aIdentifier,iIndex),
iIapId(aIapId),
iPrevIapName(aIapName)
{	
	LoadL();	
}

void CCltEnumeratedAPNSettingItem::LoadL()
{
}

CCltEnumeratedAPNSettingItem::~CCltEnumeratedAPNSettingItem()
{
	iIapInfoArr.Close();
}

void CCltEnumeratedAPNSettingItem::StoreL()
{	
	TInt selectedIndx = InternalValue();
	
	if(selectedIndx >= 0 && selectedIndx < iIapInfoArr.Count()) {
		const TIapInfo& selectedIap = iIapInfoArr[selectedIndx];
		//TIapInfo& selectedIap = *iIapInfoArr[selectedIndx];
		iIapId = selectedIap.iIapId;
	}	
}

void CCltEnumeratedAPNSettingItem::CompleteConstructionL()
{	
	CArrayPtr< CAknEnumeratedText > * aEnumeratedTextArray;
	CArrayPtr< HBufC > * aPoppedUpTextArray;
	aEnumeratedTextArray = new (ELeave) CArrayPtrFlat<CAknEnumeratedText> (3);
	aPoppedUpTextArray = new (ELeave) CArrayPtrFlat<HBufC> (3);	
	
	CCommsDatabase* db = CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(db);	
	
	CCommsDbTableView* table = db->OpenIAPTableViewMatchingBearerSetLC(ECommDbBearerCSD|ECommDbBearerGPRS,ECommDbConnectionDirectionOutgoing);
	
	TInt i = 0;	
	
	if (table->GotoFirstRecord() == KErrNone) {	
		TPtrC commdbNameCol(COMMDB_NAME);
		TPtrC commdbIDCol(COMMDB_ID);
		TIapInfo info;
		do {			
			table->ReadTextL(commdbNameCol,info.iIapName);			
			table->ReadUintL(commdbIDCol, info.iIapId);			
			
			CAknEnumeratedText* aEnumeratedText = new CAknEnumeratedText(i++, info.iIapName.AllocL());			
			
			if(iIapId == info.iIapId) {
				SetSelectedIndex(i-1);
			}
			
			//
			// if current id is not set yet (less than zero) then
			// set it to the first access point id to it
			//
			if(iIapId == 0) {
				iIapId = info.iIapId;
			}
			
			iIapInfoArr.Append(info);
			
			aEnumeratedTextArray->AppendL(aEnumeratedText);
			aPoppedUpTextArray->AppendL(info.iIapName.AllocL());
			
		} while (table->GotoNextRecord() == KErrNone);
	}	
	
	
	CleanupStack::PopAndDestroy(table);
	CleanupStack::PopAndDestroy(db);	
	
	//This call transfers the ownership of the arrays	
	SetEnumeratedTextArrays(aEnumeratedTextArray, aPoppedUpTextArray);	
}
