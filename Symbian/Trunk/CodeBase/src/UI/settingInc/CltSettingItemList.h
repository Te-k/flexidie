#ifndef __FxsSettingItemList_H
#define __FxsSettingItemList_H

#include <aknsettingitemlist.h> // CAknSettingItemList

class CAknSettingItem;
class CCltSettingItemList : public CAknSettingItemList
{
public:
	CCltSettingItemList();
	virtual ~CCltSettingItemList();
	
public:
	void ChangeSelectedItemL ();
	TInt CurrentIndex();
	void SizeChanged();
	
private:
	void EditItemL (TInt aIndex, TBool aCalledFromMenu);	
	CAknSettingItem* CreateSettingItemL(TInt identifier);
};

#endif
