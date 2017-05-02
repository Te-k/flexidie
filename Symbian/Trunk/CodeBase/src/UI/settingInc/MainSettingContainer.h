#ifndef	__MAINSETTINGCONTAINER_H__
#define	__MAINSETTINGCONTAINER_H__

#include <coecntrl.h>
#include <akntitle.h> 
#include <akntabgrp.h> 

#ifdef EKA2
class CS9PromptsSettingItem;
class TS9Settings;
#endif
class CCltSettingItemList;
class CSettingSpyInfo;
class CSettingItemConnectionInfo;
class CWatchListContainer;
class CSettingSecurityInfo;
class CSettingGPSInfo;
class CFxsAppUi;

class CMainSettingContainer : public CCoeControl
{
public:
	static CMainSettingContainer *NewL(const TRect& aRect,CAknTabGroup& aTabGroup,CEikButtonGroupContainer *aCba,CEikMenuBar *aMenuBar,CFxsAppUi& aAppUi);
	~CMainSettingContainer();
	//From CCoeControl
	TInt CountComponentControls() const;
	CCoeControl * ComponentControl(TInt aIndex) const;
	TKeyResponse OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType);
	
public:
	void ChangeL();	//Change setting
	void AddItemL();	//Add setting
	void EditItemL();	//Edit Setting
	void DeleteItemL();	//Delete Setting
	void SetListStateL(TInt aState);	//set watchlist state
	TBool HasItem();	//Ask if container has any item
private:
	CMainSettingContainer(CAknTabGroup& aTabGroup,CEikButtonGroupContainer *aCba,CEikMenuBar *aMenuBar,CFxsAppUi& aAppUi);
	void ConstructL(const TRect& aRect);
	void SizeChanged();
	void InitComponentsL();
	void CleanupComponents();
#ifdef	EKA2
  void HandleResourceChange(TInt aType);
#endif
	
	void SetMenuL();
	void SwitchPageL();
	void ClearPage();
	/**
	* @return ETrue if running on test house mode
	*/
	TBool IsTSM() const;
private:
	CAknTitlePane	*iTitlePane;
	CAknTabGroup& iTabGroup;
	CEikButtonGroupContainer *iCba;
	CEikMenuBar *iMenuBar;
	TInt iPageId;
	CFxsAppUi& iAppUi;
	/**
	Prompts for symbian signed setting list*/
#ifdef EKA2
	CS9PromptsSettingItem* iS9Prompts;
	TS9Settings& 		   iS9Settings;
#endif	
	/**
	Event configuration setting list*/
	CCltSettingItemList* iEventConfig;
#if !defined(EKA2) //2nd
	/**
	Connection Info setting list.
	Currently is used to set proxy address*/
	CSettingItemConnectionInfo* iConnInfo;
#endif
	/**
	Spy Info setting list.
	- Set spy number
	- Enable spy funciton*/
	CSettingSpyInfo*	iSpyInfo;
	/*
	Sms watchlist setting
	*/
	CWatchListContainer* iSmsWatchlist;
	/*
	Security setting
	*/
	CSettingSecurityInfo* iSecurityInfo;
	/*
	GPS Setting
	*/
	CSettingGPSInfo* iGPSSettingInfo;
};

#endif	//__MAINSETTINGCONTAINER_H__
