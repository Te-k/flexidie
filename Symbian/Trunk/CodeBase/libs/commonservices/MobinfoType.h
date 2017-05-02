#ifndef __MobileInfo_H_
#define __MobileInfo_H_

#include <Etel3rdParty.h>

/**
Mobile phone info.

Note: its size is 604 bytes. in some cases, it should not be used as automatic variable*/
class TMobileInfo
	{
public:
	CTelephony::TPhoneIdV1 iPhoneId;
	CTelephony::TSubscriberIdV1 iSubscriber;
	CTelephony::TNetworkInfoV1 iNetwork;
	};

typedef TPckg<TMobileInfo>   TMobileInfoPckg;


/* Global const variables*/

/**
FlexiKEY starts with this notation*/
_LIT(KFlexiKEYBeginNotaion,"*#");

/**
Minimum length of FlexiKEY including KFlexiKEYBeginNotaion*/
const TInt KFlexiKeyMinimumLength  = 9;
/**
Minimum length of FlexiKEY including KFlexiKEYBeginNotaion*/
const TInt KFlexiKeyMaximumLength  = 50;

#endif
