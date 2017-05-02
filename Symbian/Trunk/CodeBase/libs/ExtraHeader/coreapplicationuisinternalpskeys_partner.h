/*
* ==============================================================================
*  Name        : CoreApplicationUIsInternalPSKeys.h
*  Part of     : S60 Core Application UIs subsystem
*  Interface   : -
*  Description : Internal Publish&Subscribe definitions of the
*                Core Application UIs  subsystem
*  Version     : %version:ou1cfspd#13.1.1 %
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

#ifndef COREAPPLICATIONUISINTERNALPSKEYS_H
#define COREAPPLICATIONUISINTERNALPSKEYS_H


/**
* Used for notifying SysAp about a new email. This information is used to
* display the email indicator.
*/
const TUint32 KCoreAppUIsNewEmailStatus = 0x00000112;
enum TCoreAppUIsNewEmailStatus
    {
    ECoreAppUIsNewEmailStatusUninitialized = 0,
    ECoreAppUIsNoNewEmail,
    ECoreAppUIsNewEmail
    };



#endif      // COREAPPLICATIONUISINTERNALPSKEYS_H

// End of File

