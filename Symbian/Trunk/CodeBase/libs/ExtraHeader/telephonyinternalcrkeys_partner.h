/*
* ==============================================================================
*  Name        : TelephonyInternalCRKeys.h
*  Part of     : Telephony
*  Interface   : 
*  Description : Telephony internal Central Repository keys
*  Version     : 
*
*  Copyright (c) 2004-2005 Nokia Corporation.
*  This material, including documentation and any related 
*  computer programs, is protected by copyright controlled by 
*  Nokia Corporation. All rights are reserved. Copying, 
*  including reproducing, storing, adapting or translating, any 
*  or all of this material requires the prior written consent of 
*  Nokia Corporation. This material also contains confidential 
*  information which may not be disclosed to others without the 
*  prior written consent of Nokia Corporation.
* ==============================================================================
*/

#ifndef TELEPHONYINTERNALCRKEYS_PARTNER_H
#define TELEPHONYINTERNALCRKEYS_PARTNER_H

#include <e32std.h>

/**
* Telephony Call Handling Persistent Info API.
* This API provides information related to call handling.
*/
const TUid KCRUidCallHandling = {0x101F8784};

/**
* Used by phone application. Don't try to use it.
* Volume for non-IHF (loudspeaker) mode. Integer, between 1 and 10.
*/
const TUint32 KTelephonyIncallEarVolume                           = 0x00000001;

/**
* Used by phone application. Don't try to use them.
* Volume for IHF mode. Integer, between 1 and 10.
* Default value is 4.
*/
const TUint32 KTelephonyIncallLoudspeakerVolume                   = 0x00000002;


#endif      // TELEPHONYINTERNALCRKEYS_PARTNER_H

// End of file
