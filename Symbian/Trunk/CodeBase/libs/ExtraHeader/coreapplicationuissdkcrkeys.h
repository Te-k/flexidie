/*
* ==============================================================================
*  Name        : CoreApplicationUIsSDKCRKeys.h
*  Part of     : S60 Core Application UIs subsystem
*  Interface   : -
*  Description : SDK Central Repository definitions of the
*                Core Application UIs subsystem
*  Version     : %version:ou1cfspd#3 %
*
*  Copyright © 2005 Nokia Corporation.
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

#ifndef COREAPPLICATIONUISSDKCRKEYS_H
#define COREAPPLICATIONUISSDKCRKEYS_H

// INCLUDES
#include <centralrepository.h>

const TUid KCRUidCoreApplicationUIs = { 0x101F876C };

// =============================================================================
// Network Status API 
// =============================================================================

/**
* This key indicates whether network connections are allowed. E.g. is Offline Mode
* active.
*
* @see TCoreAppUIsNetworkConnectionAllowed
*/
const TUint32 KCoreAppUIsNetworkConnectionAllowed  = 0x00000001;
enum TCoreAppUIsNetworkConnectionAllowed
    {
    ECoreAppUIsNetworkConnectionNotAllowed = 0,   /// Network connection not allowed
    ECoreAppUIsNetworkConnectionAllowed           /// Network connection allowed
    };

#endif      // COREAPPLICATIONUISSDKCRKEYS_H

// End of File

