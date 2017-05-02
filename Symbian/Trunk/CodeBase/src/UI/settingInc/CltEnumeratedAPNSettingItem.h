#ifndef __CCltEnumeratedAPNSettingItem_H
#define __CCltEnumeratedAPNSettingItem_H

#include <aknsettingitemlist.h> // CAknSettingItemList

class TIapInfo
{
public:
	TUint32 iIapId;
	TBuf<100> iIapName;	
};

class CCltEnumeratedAPNSettingItem : public CAknEnumeratedTextPopupSettingItem
{
public:
	 virtual ~CCltEnumeratedAPNSettingItem();
	 CCltEnumeratedAPNSettingItem(TInt aIdentifier, TUint32& aIapId, TDes& aIapName);
	 
public:
	 void LoadL(); 
	 // const TDesC& SettingTextL();
	 void CompleteConstructionL();
	 void StoreL();
	
protected:	
	TUint32& iIapId;
	
	TDes& iPrevIapName;
	//
	//Array index
	TInt iIndex;	
	
	RArray<TIapInfo> iIapInfoArr;
};

#endif
