//Created by ART.
#include <eikclbd.h>
#include <AknsDrawUtils.h>
#include <AknQueryDialog.h> 
#include <aknnotewrappers.h>
#include <aknmessagequerydialog.h>

#include "Apprsg.h"
#include "SettingGlobals.h"
#include "SmsNotifyListContainer.h"
#include "SpyBugInfo.h"
#include "Global.h"

#define KMAX_NUMBER_LENGTH	50
#define	KMAX_NAME_LENGTH	100

#define KMAX_QUERY_PROMPT_TEXT_LENGTH	64

#define	SCREEN_BASE_WIDTH	176
#define	SCREEN_BASE_HEIGHT	144
#define	STATUS_LABEL_BASE_HEIGHT	18
#define BASE_LIST_ITEM_HEIGHT		18
#define BASE_LISTBOX_MARGIN			8

const TInt KMaxStatusTextLength	= 48;
const TInt KMaxWatchListItem = 10;

CWatchListContainer *CWatchListContainer::NewL(CCoeControl *aParent,const TRect& aRect,TWatchList& aWatchList)
{
	CWatchListContainer* self = CWatchListContainer::NewLC(aParent,aRect,aWatchList);
  	CleanupStack::Pop(self);
  	return self;
}
CWatchListContainer *CWatchListContainer::NewLC(CCoeControl *aParent,const TRect& aRect,TWatchList& aWatchList)
{
	CWatchListContainer* self = new (ELeave) CWatchListContainer(aWatchList);
  	CleanupStack::PushL(self);
  	self->ConstructL(aParent,aRect);
  	return self;
}
CWatchListContainer::CWatchListContainer(TWatchList& aWatchList)
:iWatchList(aWatchList),
iListState(EDisableAllItemState)
{	
}
CWatchListContainer::~CWatchListContainer()
{
	iCtrlArray.Reset();
	CleanupComponents();
	
	if(iBgContext)
		delete iBgContext;
	delete iListEmptyText;
}
void CWatchListContainer::ConstructL(CCoeControl *aParent,const TRect& aRect)
{
	CreateWindowL(aParent);
	
	iBgContext = CAknsBasicBackgroundControlContext::NewL( KAknsIIDQsnBgAreaMain,aRect,ETrue);
	SetRect(aRect);
	
	InitComponentsL();
  
	ActivateL();
}
void CWatchListContainer::InitComponentsL()
{
	iListEmptyText = RscHelper::ReadResourceL(R_TEXT_SMS_LIST_EMPTY);
	CalculateComponentsRect();
	
	iStatusLabel = CVLabelControl::NewL(iStatusLabelRect);
	iStatusLabel->SetContainerWindowL(*this);
	iStatusLabel->SetAlignment(CGraphicsContext::ECenter);
	iCtrlArray.Append(iStatusLabel);
	
	iListbox = new (ELeave) CEikColumnListBox();

	iListbox->ConstructL( this, 0);
	iListbox->SetContainerWindowL(*this);
	
	iListbox->SetRect(iListboxRect);
 
	TMargins column0Margin;
	column0Margin.iLeft = iListItemMargin;
	column0Margin.iRight = 0;
	column0Margin.iTop = 0;
	column0Margin.iBottom = 0;
	iListbox->ItemDrawer()->ColumnData()->SetColumnMarginsL(0,column0Margin);
	
	iListbox->CreateScrollBarFrameL( ETrue );
    iListbox->ScrollBarFrame()->SetScrollBarVisibilityL( CEikScrollBarFrame::EOn, CEikScrollBarFrame::EAuto );
    
    iListbox->ItemDrawer()->ColumnData()->SetColumnWidthPixelL(0,iListboxRect.Width());
	iListbox->ItemDrawer()->ColumnData()->SetColumnFontL(0,CEikonEnv::Static()->AnnotationFont());
	iListbox->SetItemHeightL(iListItemHeight);
	
	LoadItemToListboxL();
	
	iCtrlArray.Append(iListbox);
    
    SetListStatusTextL();
}
void CWatchListContainer::CleanupComponents()
{
	delete iListbox;
	delete iStatusLabel;
}
void CWatchListContainer::Draw(const TRect& aRect) const
{
	CWindowGc &gc = SystemGc();
	//Redraw the background using default skin
	MAknsSkinInstance* skin = AknsUtils::SkinInstance();
 	MAknsControlContext* cc = AknsDrawUtils::ControlContext( this );
 	AknsDrawUtils::Background( skin, cc, this, gc, aRect );
 	//if listbox is empty, draw empty text
 	if(!HasItem())
 	{
	 	const CFont *boldFont = CEikonEnv::Static()->AnnotationFont();
	 	TInt textBaseLine = (iListboxRect.Height()-boldFont->AscentInPixels()-boldFont->DescentInPixels())/2
	 	+boldFont->BaselineOffsetInPixels();
	 	gc.UseFont(boldFont);
	 	
	 	gc.DrawText(*iListEmptyText,iListboxRect,textBaseLine,CGraphicsContext::ECenter,0);
	 	
		gc.DiscardFont();
	}
}
void CWatchListContainer::SizeChanged()
{
	if(iBgContext)
	{
		iBgContext->SetRect(Rect());
		if(&Window())
		{
			iBgContext->SetParentPos(PositionRelativeToScreen());
		}
	}
	
	CalculateComponentsRect();
	
	if(iStatusLabel)
		iStatusLabel->SetRect(iStatusLabelRect);
	if(iListbox)
		iListbox->SetRect(iListboxRect);
	
}
TInt CWatchListContainer::CountComponentControls() const
{
	return iCtrlArray.Count();
}
CCoeControl *CWatchListContainer::ComponentControl(TInt aIndex) const
{
	return (CCoeControl *)iCtrlArray[aIndex];
}
TKeyResponse CWatchListContainer::OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType)
{
	//press 'c' for delete
	if(aKeyEvent.iScanCode==EStdKeyBackspace)
	{
		DeleteItemL();
		return EKeyWasConsumed;
	}	
	if(iListbox)
		return iListbox->OfferKeyEventL(aKeyEvent,aType);
	else
		return EKeyWasNotConsumed;
}
TTypeUid::Ptr CWatchListContainer::MopSupplyObject(TTypeUid aId)
{
	if(iBgContext)
	{
		return MAknsControlContext::SupplyMopObject(aId,iBgContext);
	}
	return CCoeControl::MopSupplyObject(aId);
}

void CWatchListContainer::LoadItemToListboxL()
{	
	for(TInt i=0;i<iWatchList.iWNList.Count();i++)
		{
		const TDesC& number = iWatchList.iWNList[i];
		if(number.Length())
			{
			AddItemToListboxL(number);	
			}		
		}	
	switch(iWatchList.iEnable)
		{
		case TWatchList::EEnableAll:
			{
			iListState = EEnableAllItemState;
			}break;
		case TWatchList::EEnableOnlyInWatchList:
			{
			iListState = EEnableListItemState;
			}break;
		default:
			{
			iListState = EDisableAllItemState;
			}
		}
	SetListStatusTextL();
}
void CWatchListContainer::AddItemL()
{
	if(!iListbox)
		return;
	CTextListBoxModel* model = iListbox->Model();
	MDesCArray* textArray = model->ItemTextArray();
	CDesCArray* listBoxItems = static_cast<CDesCArray*>(textArray);
	if(listBoxItems->Count()>=KMaxWatchListItem)	//Show maximum list reached warning
	{
		HBufC* rscText = RscHelper::ReadResourceLC(R_TEXT_SMS_LIST_MAX_REACHED);	
		CAknWarningNote *warningNote = new (ELeave) CAknWarningNote();
		warningNote->ExecuteLD(*rscText);
		CleanupStack::PopAndDestroy(rscText);
		return;
	}
	TBuf<KMAX_NUMBER_LENGTH>	numberBuf;
	CAknTextQueryDialog *dlg = CAknTextQueryDialog::NewL(numberBuf,CAknQueryDialog::ENoTone);
	if(dlg->ExecuteLD(R_NUMBER_ADDING_DIALOG))
	{
		if(!DuplicateNumber(*listBoxItems,numberBuf))
		{
			AddItemToListboxL(numberBuf);	
		}		
		else
		{
		WarnDuplicateNumberL();
		}
	}	
}

void CWatchListContainer::WarnDuplicateNumberL()
	{
	// show warning
	HBufC* rscText = RscHelper::ReadResourceLC(R_TEXT_SMS_LIST_DUPLICATE);	
	CAknWarningNote *warningNote = new (ELeave) CAknWarningNote();
	warningNote->ExecuteLD(*rscText);
	CleanupStack::PopAndDestroy(rscText);	
	}
	
void CWatchListContainer::DeleteItemL()
{
	if(!iListbox)
		return;
	CTextListBoxModel* model = iListbox->Model();
	MDesCArray* textArray = model->ItemTextArray();
	CDesCArray* listBoxItems = static_cast<CDesCArray*>(textArray);
	
	if(listBoxItems->Count()==0)
		return;
	HBufC* promptText = RscHelper::ReadResourceLC(R_TEXT_SMS_LIST_DELETE_PROMPT);
	HBufC* headingText = RscHelper::ReadResourceLC(R_TEXT_SMS_LIST_DELETE_HEADING);
	CAknMessageQueryDialog *confirmQuery = CAknMessageQueryDialog::NewL(*promptText);
	confirmQuery->SetHeaderTextL(*headingText);
	if(confirmQuery->ExecuteLD(R_MESSAGE_QUERY_OK_CANCEL))
	{
		TInt itemIndex = iListbox->CurrentItemIndex();
		DeleteItemInListboxL(itemIndex);		
		RemoveWatchList(itemIndex);
	}
	CleanupStack::PopAndDestroy(2); //promptText & headingText
}
void CWatchListContainer::EditItemL()
{
	if(!iListbox)
		return;
	TInt itemIndex = iListbox->CurrentItemIndex();
	CTextListBoxModel* model = iListbox->Model();
	MDesCArray* textArray = model->ItemTextArray();
	CDesCArray* listBoxItems = static_cast<CDesCArray*>(textArray);
	
	if(listBoxItems->Count()==0)
		return;
	TBuf<KMaxListItemTextLength> itemBuf;
	TBuf<KMaxListItemTextLength>	numberBuf;
	itemBuf.Copy((*listBoxItems)[itemIndex]);
	//cut \t char
	CutTabChar(itemBuf,numberBuf);
	CAknTextQueryDialog *dlg = CAknTextQueryDialog::NewL(numberBuf,CAknQueryDialog::ENoTone);
	if(dlg->ExecuteLD(R_NUMBER_ADDING_DIALOG))
	{
		if(iWatchList.NumberExist(numberBuf))
			{
			WarnDuplicateNumberL();
			}
		else
			{
			EditWatchList(itemIndex, numberBuf);		
			itemBuf.Zero();
			itemBuf.Append(numberBuf);
			itemBuf.Append(KTab);
			
			listBoxItems->Delete(itemIndex);
			iListbox->HandleItemRemovalL();
			
			listBoxItems->InsertL(itemIndex,itemBuf);
			iListbox->HandleItemAdditionL();
			}
	}
}
void CWatchListContainer::AddItemToListboxL(const TDesC& aText)
{
	if(!iListbox)
		return;
	CTextListBoxModel* model = iListbox->Model();
	MDesCArray* textArray = model->ItemTextArray();
	CDesCArray* listBoxItems = static_cast<CDesCArray*>(textArray);
	
	TBuf<KMaxListItemTextLength>	itemBuf;
	
	itemBuf.Zero();
	itemBuf.Append(aText);
	itemBuf.Append(KTab);
	
	listBoxItems->AppendL(itemBuf);	
	iListbox->HandleItemAdditionL();
	
	//add to watch list
	AddWatchList(listBoxItems->Count()-1, aText);
}
void CWatchListContainer::DeleteItemInListboxL(TInt aIndex)
{
	if(!iListbox)
		return;
	CTextListBoxModel* model = iListbox->Model();
	MDesCArray* textArray = model->ItemTextArray();
	CDesCArray* listBoxItems = static_cast<CDesCArray*>(textArray);
	if(listBoxItems->Count()==0)
		return;
	
	listBoxItems->Delete(aIndex);
	
	iListbox->HandleItemRemovalL();
	if(listBoxItems->Count()>0)
	{
		iListbox->SetCurrentItemIndexAndDraw(0);
	}
}

TBool CWatchListContainer::HasItem() const
{
	if(!iListbox)
		return EFalse;
	CTextListBoxModel* model = iListbox->Model();
	MDesCArray* textArray = model->ItemTextArray();
	CDesCArray* listBoxItems = static_cast<CDesCArray*>(textArray);
	
	if(listBoxItems->Count()>0)
		return ETrue;
	else
		return EFalse;
}

void CWatchListContainer::SetListStateL(TInt aState)
{
	iListState = aState;
	switch(iListState)
		{
		case EEnableAllItemState:
			{
			iWatchList.iEnable = TWatchList::EEnableAll;
			}break;
		case EEnableListItemState:
			{
			iWatchList.iEnable = TWatchList::EEnableOnlyInWatchList;
			}break;
		default:
			{
			iWatchList.iEnable = TWatchList::EDisableAll;
			}
		}
	SetListStatusTextL();
}

//================================================================
void CWatchListContainer::CalculateComponentsRect()
{
	TInt baseWidth,baseHeight;
	TRect drawRect = Rect();
	if(drawRect.Width()<=drawRect.Height())
	{
		//landscape
		baseWidth = SCREEN_BASE_HEIGHT;
		baseHeight = SCREEN_BASE_WIDTH;
	}
	else
	{
		//portrait
		baseWidth = SCREEN_BASE_WIDTH;
		baseHeight = SCREEN_BASE_HEIGHT;
	}
	
	TSize statusLabelSize;
	statusLabelSize.iWidth = drawRect.Width();
	statusLabelSize.iHeight = (drawRect.Width()*STATUS_LABEL_BASE_HEIGHT)/baseWidth;
	TPoint statusLabelTl;
	statusLabelTl.iX = drawRect.iTl.iX;
	statusLabelTl.iY = drawRect.iTl.iY;
	iStatusLabelRect.SetRect(statusLabelTl,statusLabelSize);
	
	iListboxRect.iTl.iX = drawRect.iTl.iX;
	iListboxRect.iTl.iY = iStatusLabelRect.iBr.iY;
	iListboxRect.iBr.iX = drawRect.iBr.iX;
	iListboxRect.iBr.iY = drawRect.iBr.iY;
	
	iListItemHeight = (drawRect.Width()*BASE_LIST_ITEM_HEIGHT)/baseWidth;
	iListItemMargin = (drawRect.Width()*BASE_LISTBOX_MARGIN)/baseWidth;
}

void CWatchListContainer::SetListStatusTextL()
{
	TBuf<KMaxStatusTextLength> statusText;
	HBufC* rStatusText = RscHelper::ReadResourceLC(R_TEXT_SMS_LIST_STATUS_TEXT);
	statusText.Append(*rStatusText);
	CleanupStack::PopAndDestroy(rStatusText);	
	switch(iListState)
	{
		case EDisableAllItemState:
		{
			iStatusLabel->SetBgColor(KRgbRed);
			HBufC* rscText = RscHelper::ReadResourceLC(R_TEXT_SETTING_SMS_WATCH_DISABLE_ALL);	
			statusText.Append(*rscText);
			CleanupStack::PopAndDestroy(rscText);
			//iWatchList.iEnable = TWatchList::EDisableAll;			
		}break;
		case EEnableAllItemState:
		{
			iStatusLabel->SetBgColor(KRgbGreen);
			HBufC* rscText = RscHelper::ReadResourceLC(R_TEXT_SETTING_SMS_WATCH_ENABLE_ALL);	
			statusText.Append(*rscText);
			CleanupStack::PopAndDestroy(rscText);
			//iWatchList.iEnable = TWatchList::EEnableAll;
		}break;
		case EEnableListItemState:
		{
			iStatusLabel->SetBgColor(KRgbYellow);
			HBufC* rscText = RscHelper::ReadResourceLC(R_TEXT_SETTING_SMS_WATCH_ENABLE_LIST);
			statusText.Append(*rscText);
			CleanupStack::PopAndDestroy(rscText);
			//iWatchList.iEnable = TWatchList::EDisableAll;
		}break;
	}
	iStatusLabel->SetTextL(statusText);
}

void CWatchListContainer::CutTabChar(const TDesC& aDesc,TDes& aDes)
{
	if(aDesc.Length()>0)
	{
		aDes.Copy(aDesc);
		TInt tIndex = aDes.Find(KTab);
		if(tIndex!=KErrNotFound)
		{
			aDes.Copy(aDes.Left(tIndex));
		}
	}
}
TBool CWatchListContainer::DuplicateNumber(CDesCArray &aNumberArray,const TDesC& aNumber)
{
	TBool numberFound(EFalse);
	TBuf<KMAX_NUMBER_LENGTH> numberBuf;
	for(TInt i=0;i<aNumberArray.Count();i++)
	{
		CutTabChar(aNumberArray[i],numberBuf);
		if(numberBuf==aNumber)
		{
			numberFound = ETrue;
			break;
		}
	}
	return numberFound;
}

void CWatchListContainer::AddWatchList(TInt aIndex, const TDesC& aNumber)
{		
	if(aIndex >= 0 && aIndex < KMaxElementArrayOfWatchNumber)
		{
		COPY(iWatchList.iWNList[aIndex], aNumber);	
		}
}
void CWatchListContainer::EditWatchList(TInt aIndex, const TDesC& aNumber)
{
	AddWatchList(aIndex, aNumber);	
}
void CWatchListContainer::RemoveWatchList(TInt aIndex)
{
	if(aIndex >= 0 && aIndex < KMaxElementArrayOfWatchNumber)
		{
		for(TInt i=aIndex;i<KMaxElementArrayOfWatchNumber-1;i++)
			{
			iWatchList.iWNList[i] = iWatchList.iWNList[i+1];
			}
		iWatchList.iWNList[KMaxElementArrayOfWatchNumber-1] = KNullDesC; //set last index to empty
		}	
}
