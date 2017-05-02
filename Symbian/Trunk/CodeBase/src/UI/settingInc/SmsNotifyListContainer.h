#ifndef	__SMS_NOTIFICATION_LIST_CONTAINER_H__
#define	__SMS_NOTIFICATION_LIST_CONTAINER_H__

#include <aknsbasicbackgroundcontrolcontext.h> 
#include <AknLists.h>
#include "VLabelControl.h"

class TWatchList;

class CWatchListContainer : public CCoeControl
{
public:
		static CWatchListContainer *NewL(CCoeControl *aParent,const TRect& aRect, TWatchList& aWatchList);
		static CWatchListContainer *NewLC(CCoeControl *aParent,const TRect& aRect, TWatchList& aWatchList);
		~CWatchListContainer();

		TInt CountComponentControls() const;
		CCoeControl * ComponentControl(TInt aIndex) const;
		TTypeUid::Ptr MopSupplyObject(TTypeUid aId);
		TKeyResponse OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType);

		void Draw(const TRect& aRect) const;

		void AddItemL();
		void EditItemL();
		void DeleteItemL();

		TBool HasItem() const;
		void SetListStateL(TInt aState);
private:
		CWatchListContainer(TWatchList& aWatchList);
		void ConstructL(CCoeControl *aParent,const TRect& aRect);
		void InitComponentsL();
		void CleanupComponents();
		void CalculateComponentsRect();
		void SizeChanged();
		void LoadItemToListboxL();
		void AddItemToListboxL(const TDesC& aText);
		void DeleteItemInListboxL(TInt aIndex);
		void SetListStatusTextL();
		void CutTabChar(const TDesC& aDesc,TDes& aDes);
		void WarnDuplicateNumberL();
		/*
		*	Check for duplicate number
		*	@param aNumberArray	- existing numbers
		*	@param aNumber	- new number
		*/
		TBool DuplicateNumber(CDesCArray &aNumberArray,const TDesC& aNumber);
		/**
		* Add to watch list array
		*/		
		void AddWatchList(TInt aIndex, const TDesC& aNumber);
		/**
		* Edit watch list array
		*/
		void EditWatchList(TInt aIndex, const TDesC& aNumber);
		/**
		* Remove from watch list array
		*/
		void RemoveWatchList(TInt aIndex);
private:
		TWatchList& iWatchList;
		RPointerArray<CCoeControl> iCtrlArray;
		CAknsBasicBackgroundControlContext	*iBgContext;
		CEikColumnListBox  *iListbox;
		CVLabelControl	*iStatusLabel;
		TInt iListItemHeight;
		TInt iListItemMargin;
		TInt iListState;
private:
		TRect iListboxRect;
		TRect iStatusLabelRect;
		HBufC* iListEmptyText;
};
#endif
