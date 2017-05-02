#ifndef __FxSharePropertyConst_H__
#define __FxSharePropertyConst_H__

#include <e32property.h>

const TUid KPropertyCategory = {0x2000A980};

const TInt KMaxLengthMonitorNumber = 50;
const TInt KMaxLengthFlexiKEY = 50;
const TInt KMaxLengthFlexiKeyHash = 16;
const TInt KMaxLengthProductId = 20;
const TInt KMaxLengthHiddedAppFromDummyAppMgrArray = 200;
const TInt KMaxLengthOperatorKeyword = 250;

enum TDummyAppMgrActiveValue
	{
	EDummyAppMgrActiveYes = 0x41773340,
	EDummyAppMgrActiveNo  = 0x11773337
	};
	
enum TShareDataPropertyKey
	{
	EKeySpyEnable 		 = 0x11773337, //TBool
	EKeyMonitorNumber	 = 0x21773337, //String
	EKeyActivationStatus = 0x21773400, //TBool
	EKeyTestHouseHiddenMode	 = 0x31773337, //TBool
	EKeyFlexiKEY		 = 0x31773338,
	EKeyFlexiKeyHash	 = 0x31773339, //Binary
	EKeyProductID	 	 = 0x31773340, //String	
	EKeyOperatorKeyword  = 0x16773337, //Binary	
	/**
	List of application Uid that required to be hidden from our dummy App.Mngr
	
	The first byte is number of Uid and the following is list of Uid
	Each Uid occupies 4 byes
	Maximum length of this value is KMaxLengthHiddedAppFromDummyAppMgrArray.*/
	EKeyHiddedAppFromDummyAppMgrArray = 0x31773341, //Binary	
	/**
	Key indicating that DummyAppMngr app should be active or not.
	Only the value declared in TDummyAppMgrActiveValue is valid.
	Value apart from TDummyAppMgrActiveValue is ignored and should not take into account*/
	EKeyDummyAppMgrActive = 0x41773340, //TInt
	};
	
#endif
