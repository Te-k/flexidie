#include "EventCheckboxSetting.h"
#include "Global.h"
#include <aknCheckBoxSettingPage.h>

const TInt KCheckBoxItemListGranularity = 5;

// size allocated to internal representation of checkbox states
const TInt KInternalRepSize = 128;	

CFxsEventSettingItem::CFxsEventSettingItem(TInt aIdentifier, CArrayFix<TInt>& aValueList)
:CAknEnumeratedTextSettingItem(aIdentifier), iExternalValueArray(aValueList)
	{
	}

CFxsEventSettingItem::~CFxsEventSettingItem()
	{
	if (iSelectionItemListData)	
		{
		iSelectionItemListData->ResetAndDestroy();
		delete iSelectionItemListData;
		}
	delete iTextRepresentation;
	}

void CFxsEventSettingItem::CompleteConstructionL()
	{
	CAknEnumeratedTextSettingItem::CompleteConstructionL();
	iSelectionItemListData = new (ELeave) CSelectionItemList(KCheckBoxItemListGranularity );
	TInt count = EnumeratedTextArray()->Count();	
	TInt numExternals = iExternalValueArray.Count();	
	for (TInt index = 0; index < count; index++ )
		{
		CSelectableItem* selectionItem = new(ELeave)CSelectableItem( 
								*(EnumeratedTextArray()->At(index)->Value()),EFalse );

		CleanupStack::PushL(selectionItem);
		selectionItem->ConstructL();
		if (index < numExternals)
			{
			selectionItem->SetSelectionStatus(iExternalValueArray[index]);
			}
		iSelectionItemListData->AppendL(selectionItem); 
		CleanupStack::Pop(selectionItem);
		}
	}

void CFxsEventSettingItem::LoadL()
	{	
	TInt numExternals = iExternalValueArray.Count();	
	// copy all items from the external data representation into the internal
	for (TInt i=0;i<numExternals;i++)
		{
		(*iSelectionItemListData)[i]->SetSelectionStatus(iExternalValueArray[i]);
		}

	// make sure the text reflects what's actually stored
	SetTextRepresentationL();
	}

void CFxsEventSettingItem::StoreL()
	{
	// number of items in external data array
	TInt numExternals = iExternalValueArray.Count();

	// copy all items from the internal data representation to the external
	for (TInt i=0;i<numExternals;i++)
		{
		iExternalValueArray[i] = (*iSelectionItemListData)[i]->SelectionStatus();
		}
	}


void CFxsEventSettingItem::EditItemL( TBool  /*aCalledFromMenu */)
	{
	CAknCheckBoxSettingPage* dlg = //r_settinglist_capture_event_types_page
			new ( ELeave )CAknCheckBoxSettingPage(R_SETTINGLIST_CAPTURE_EVENT_TYPES_PAGE, 
												  iSelectionItemListData);

	if ( dlg->ExecuteLD(CAknSettingPage::EUpdateWhenChanged) )
		{ 
		// something changed - so update internal representation 
		// of display text
		SetTextRepresentationL();
		// and update the text being displayed
		UpdateListBoxTextL();
		}
	}

const TDesC& CFxsEventSettingItem::SettingTextL()
	{		
	StoreL();
	if ( (iExternalValueArray.Count() == 0) || !iTextRepresentation ) 
		{
		return EmptyItemText();
		}
	else
		{
		return *(iTextRepresentation);
		}
	}

void CFxsEventSettingItem::SetTextRepresentationL()
	{
	if (!iTextRepresentation)
		{
		iTextRepresentation = HBufC::NewL(KInternalRepSize);
		}
	TPtr text = iTextRepresentation->Des();
	text.Zero();	
	TBool addComma=EFalse;	
	TInt nItems = iSelectionItemListData->Count();	
	for (TInt i=0; i<nItems; i++) 
		{		
		if((*iSelectionItemListData)[i]->SelectionStatus())
			{
			if (addComma)text.Append(KSymbolCommaAndSpace);
			text.Append( *(EnumeratedTextArray()->At(i)->Value()));				
			addComma=ETrue;
			}
		}
		
	if(!addComma)
		{
		text.Append(KStringNone);
		}
	}
