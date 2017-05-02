#ifndef __SettingSecurityInfo_H__
#define __SettingSecurityInfo_H__

#include <aknsettingitemlist.h>
class TMiscellaneousSetting;

class CSettingSecurityInfo : public CAknSettingItemList
{
public:
	CSettingSecurityInfo(TMiscellaneousSetting& aMiscSetting);
	~CSettingSecurityInfo();	
	void ChangeSelectedItemL();
	TInt CurrentIndex();
	void SizeChanged();	
private:
	void EditItemL (TInt aIndex, TBool aCalledFromMenu);	
	CAknSettingItem* CreateSettingItemL(TInt identifier);
private:
	TMiscellaneousSetting& iMiscSetting;
};

#endif
