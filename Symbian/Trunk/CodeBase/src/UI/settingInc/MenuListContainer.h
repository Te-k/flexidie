#ifndef	__MENU_LIST_CONTAINER_H__
#define	__MENU_LIST_CONTAINER_H__

#include <coecntrl.h>
#include <akntitle.h> 
#include <aknlists.h>
#ifdef	EKA2
#include "Iconprovider.h"
#endif

class CFxsAppUi;

/*
//required bitmap
//	event_icon.bmp event_icon_mask.bmp 
//	call_icon.bmp call_icon_mask.bmp
//	proxy_icon.bmp proxy_icon_mask.bmp
//	sms_icon.bmp sms_icon_mask.bmp
*/
class CMenuListContainer : public CCoeControl
{
public:
	static CMenuListContainer *NewL(const TRect &aRect,CFxsAppUi& aAppUi);
	static CMenuListContainer *NewLC(const TRect &aRect,CFxsAppUi& aAppUi);
	~CMenuListContainer();

	TInt CountComponentControls() const;
    CCoeControl * ComponentControl(TInt aIndex) const;

	TKeyResponse OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType);
	void Draw(const TRect& aRect) const;

	void OpenItemL();
private:
#ifdef	EKA2
	void HandleResourceChange(TInt aType);
#endif
	void SizeChanged();
	
private:
	CMenuListContainer(CFxsAppUi& aAppUi);
	void ConstructL(const TRect &aRect);
	void InitComponentsL();
	void CleanupComponents();	
	void LoadItemToListbox();
	void AppendListboxItem(CDesCArray& listItemArray,TInt aBitmapId,TInt aResourceId);
	TBool IsTSM();
private:
	enum TBitmapIconId
	{
		EEventBitmapId,
	#if (defined __APP_FXS_PROX || defined(__APP_FXS_PRO))
		ECallBitmapId,//monitor number
	#endif
		EPromptBitmapId,
	#ifdef __APP_FXS_PROX
		EWatchListBitmapId,
		EGPSBitmapId,
	#endif
		ESecurityBitmapId,
	#if !defined(EKA2) //2nd
		EProxyBitmapId,
	#endif
		EIconBitmapNumber
	};
	CFxsAppUi& iAppUi;
	RFs& iFsSession;
	RPointerArray<CCoeControl> iCtrlArray;
#ifdef	EKA2	//for icon loading   
  	CIconFileProvider *iIconProvider;
#endif	
	CAknTitlePane	*iTitlePane;
	CAknSingleLargeStyleListBox	*iListbox;
};

#endif	 //__MENU_LIST_CONTAINER_H__
