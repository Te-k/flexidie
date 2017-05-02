#ifndef __SettingItemConnectionInfo_H__
#define __SettingItemConnectionInfo_H__

#include <aknsettingitemlist.h>

class CSettingItemConnectionInfo : public CAknSettingItemList
{
public:
	CSettingItemConnectionInfo();
	virtual ~CSettingItemConnectionInfo();
	
public:
	void ChangeSelectedItemL ();
	TInt CurrentIndex();
	void SizeChanged();
	
	//TKeyResponse OfferKeyEventL(const TKeyEvent& aKeyEvent,TEventCode aType);
private:
	void EditItemL (TInt aIndex, TBool aCalledFromMenu);	
	CAknSettingItem* CreateSettingItemL(TInt identifier);
};

#endif
