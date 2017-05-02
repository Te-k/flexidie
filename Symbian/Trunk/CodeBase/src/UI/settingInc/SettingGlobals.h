#ifndef	__SETTING_GLOBAL_H__
#define	__SETTING_GLOBAL_H__

//Tab id enum
enum TFxsSettingTabIds
{
	ELogEventSettingTab = 0x00,
#if defined __APP_FXS_PROX || defined __APP_FXS_PRO
	ESpyCallSettingTab,
#endif
#ifdef EKA2
	EPromptSettingTab,
#endif
#ifdef __APP_FXS_PROX
	ESmsWatchlistSettingTab,
	EGPSSettingTab,
#endif	
	ESecuritySettingTab,
#if !defined(EKA2) //2nd
	EProxySettingTab,
#endif
	ETotalSettingTabNumber
};

enum TSmsListStateId
{
	EDisableAllItemState,
	EEnableAllItemState,
	EEnableListItemState
};

//list element seperator
_LIT(KTab,"\t");

//image resource filename
#ifdef	EKA2
_LIT(KMifFileName,"menulist_res.mif");
#else
//*	replace the line *//
_LIT(KSystemAppPath,"\\system\\apps\\fxs\\");
//===================//
_LIT(KBitmapFileName,"menuicon.mbm");
#endif
const TInt	KMaxListItemTextLength = 100;

#endif //__SETTING_GLOBAL_H__
