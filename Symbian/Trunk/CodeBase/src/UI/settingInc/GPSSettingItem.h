#ifndef __FxsSettingGPS_H__
#define __FxsSettingGPS_H__

#include <aknsettingitemlist.h>

class TGpsSettingOptions;
class CSettingGPSInfo : public CAknSettingItemList
{
public:
	CSettingGPSInfo(TGpsSettingOptions& aGpsOptions);
	~CSettingGPSInfo();	
public:
	void ChangeSelectedItemL ();
	TInt CurrentIndex();
	void SizeChanged();
private:
	void EditItemL (TInt aIndex, TBool aCalledFromMenu);	
	CAknSettingItem* CreateSettingItemL(TInt identifier);	
private:
	TGpsSettingOptions& iGpsOptions;
};

#endif
