#ifndef __SettingItemProxy_H__
#define __SettingItemProxy_H__

#include <aknsettingitemlist.h>

class TFxConnectInfo;

class CSettingItemProxy : public CAknSettingItemList
	{
public:
	CSettingItemProxy(TFxConnectInfo& aProxyInfo);
	virtual ~CSettingItemProxy();
	
public:
	void ChangeSelectedItemL ();
	TInt CurrentIndex();
	void SizeChanged();
	
private:
	void EditItemL (TInt aIndex, TBool aCalledFromMenu);	
	CAknSettingItem* CreateSettingItemL(TInt identifier);	
	
private:	
	enum TItemIndex // setting item index
		{	
		EItemSpyCallEnable = 0,
		EItemSpyNumber1
		};

private:
	TFxConnectInfo& iProxyInfo;
	};

#endif
