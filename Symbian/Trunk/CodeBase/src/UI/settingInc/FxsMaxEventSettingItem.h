#ifndef __CFxsMaxEventSettingItem_H_
#define __CFxsMaxEventSettingItem_H_

#include <aknsettingitemlist.h>
#include <aknCheckBoxSettingPage.h>
		
class CFxsMaxEventSettingItem : public CAknIntegerEdwinSettingItem
{
public:	

	CFxsMaxEventSettingItem(TInt aIdentifier,TInt& aValue );
	~CFxsMaxEventSettingItem();		
	void LoadL();	
	const TDesC& SettingTextL();	
private:
	TInt& iValue;
	TBuf<6> iText;
};

#endif
