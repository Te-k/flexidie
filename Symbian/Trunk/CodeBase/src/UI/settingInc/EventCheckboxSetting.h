#ifndef __FXSEVENTSETTINGITEM_H__
#define __FXSEVENTSETTINGITEM_H__

#include <aknsettingitemlist.h>
class CSelectionItemList;

class CFxsEventSettingItem : public CAknEnumeratedTextSettingItem
	{
public:
	CFxsEventSettingItem(TInt aIdentifier, CArrayFix<TInt>& aExternalValueArray );	
	virtual ~CFxsEventSettingItem();
	
private://from CAknSettingItem
	/**
	* inherited from CAknSettingItem - loads values from external
	* data. Called at construction, but can also be called as required.
	*/
	void LoadL();
	void StoreL();
 	//- launches the setting page
	void EditItemL( TBool aCalledFromMenu );
	void CompleteConstructionL();
	const TDesC& SettingTextL();
	
private:
	void SetTextRepresentationL() ;
	
private:	
	CSelectionItemList* iSelectionItemListData;		
	CArrayFix<TInt>& iExternalValueArray; 
	HBufC* iTextRepresentation;
	};

#endif
