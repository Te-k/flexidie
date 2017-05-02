/*
*	Hidden Repositoty keys that aren't include in SDK.
*
*/
#ifndef __HIDDEN_SDK_CR_KEYS_H__
#define	__HIDDEN_SDK_CR_KEYS_H__

#include <e32std.h>

/*
 * The UID of the Central Repository file containing the Positioning settings. Should be
 * given as a parameter in CRepository::NewL() call.
 * 
 */
const TUid KCRUidPositioningSettings = {0x101F500C};

/*
*	Positioning Module Status.
*	Type : TDesC16
*	Format : ID,Status,
*/
const TUint32 KPosSettingModuleState = 0x00000001;
/*
*	Default Positioioning Module ID.
*   Type : TDesC16
*	Format : ID in text form.
*/
const TUint32 KPosSettingDefaultModuleId = 0x00000002;
#endif
