#include "FxsMaxEventSettingItem.h"
#include <avkon.rsg>
#include "Global.h"

//@todo move to rsc
_LIT(KMaxEventNone,"Not Set");

CFxsMaxEventSettingItem::CFxsMaxEventSettingItem(TInt aIdentifier, TInt& aValue )
:CAknIntegerEdwinSettingItem(aIdentifier,aValue),iValue(aValue)
{	
	InternalValueRef() = aValue; 	
}

CFxsMaxEventSettingItem::~CFxsMaxEventSettingItem()
{
}

void CFxsMaxEventSettingItem::LoadL()
{
}

const TDesC& CFxsMaxEventSettingItem::SettingTextL()
{			
	iValue = InternalValueRef();
	if(iValue < EMinimumSettingMaxNumberOfEventValue)
		{
		iValue = EMinimumSettingMaxNumberOfEventValue;
		}
	if(iValue == 0 )
		{
		return KMaxEventNone;
		}	
	iText.Num(iValue);	
	return iText;
}
