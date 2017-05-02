#ifndef __S9PromptsSettingContainer_H__
#define __S9PromptsSettingContainer_H__

#include <coecntrl.h> // CCoeControl
#include <akntabobserver.h>
#include <aknsettingitemlist.h>

class TS9Settings;
class CAknSettingItem;
class CAknsBasicBackgroundControlContext;

//
class CS9SettingItem : public CAknSettingItemList
	{
public:
	CS9SettingItem(TS9Settings& aS9Settings);
	~CS9SettingItem();
	
public:
	void ChangeSelectedItemL ();
	TInt CurrentIndex();
	void SizeChanged();
private:
	void EditItemL (TInt aIndex, TBool aCalledFromMenu);	
	CAknSettingItem* CreateSettingItemL(TInt aIdentifier);
private:
	TS9Settings& iS9Settings;
	};

//
class CS9PromptsSettingContainer : public CCoeControl
	{
public:
	static CS9PromptsSettingContainer* NewL(const TRect& aRect,TS9Settings& aS9Settings);
	~CS9PromptsSettingContainer();
	TTypeUid::Ptr MopSupplyObject(TTypeUid aId);
public:
	void ChangeSelectedItemL();
	
	void DisplayControl();	
private:
	CS9PromptsSettingContainer(TS9Settings& aS9Settings);
	void ConstructL(const TRect& aRect);	
	void CreateSettingListL();	
private:
	void SizeChanged();
	void HandleResourceChange(TInt aType);
	TInt CountComponentControls() const;	
	CCoeControl* ComponentControl(TInt aIndex) const;	
	TKeyResponse OfferKeyEventL(const TKeyEvent& aKeyEvent,TEventCode aType);	
	void Draw(const TRect& aRect) const;
	
private:
	enum TControlsNum
		{
		ENumberOfControls = 1
		};	
private:
	CS9SettingItem*	iS9SettingItem;	
	TS9Settings& iS9Setting;
	CAknsBasicBackgroundControlContext* iBgContext;	
	};

#endif
