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

// INCLUDES
#include <e32property.h>
#include <e32err.h>

const TUid KPSUidCoreApplicationUIs = { 0x101F8767 };

// =============================================================================
// System Application Notification API
// =============================================================================
// Use TUid KPSUidCoreApplicationUIs = { 0x101F8767 } 

/**
* SysAp notifies Alarm UI to hide alarm when powerkey pressed.
* Old Shared Data constant name: KSysApHideAlarm
*/
const TUint32 KCoreAppUIsHideAlarm = 0x00000101;
enum TCoreAppUIsHideAlarm
    {
    ECoreAppUIsHideAlarmUninitialized = 0,
    ECoreAppUIsDoNotHideAlarm,
    ECoreAppUIsHideAlarm
    };

/**
* Alarm UI notifies SysAp to disable keyguard when an alarm occurs.
* Old Shared Data constant name: KSysApKeyGuardInactive
*/
const TUint32 KCoreAppUIsDisableKeyguard = 0x00000102;
enum TCoreAppUIsDisableKeyguard
    {
    ECoreAppUIsDisableKeyguardUninitialized = 0,
    ECoreAppUIsEnableKeyguard,
    ECoreAppUIsDisableKeyguard
    };

/**
* Phone notifies SysAp not to enable keylock after Soft Reject
* Old Shared Data constant name: KSysApSoftReject
*/
const TUint32 KCoreAppUIsSoftReject = 0x00000103;
enum TCoreAppUIsSoftReject
    {
    ECoreAppUIsSoftRejectUninitialized = 0,
    ECoreAppUIsReactivateKeyguard,  
    ECoreAppUIsSoftReject   // do not re-activate keyguard after the call
    };

/**
* Used for notifying SysAp of the Instant Messaging indicator status
* Old Shared Data constant name: KSysApUipInd
*/
const TUint32 KCoreAppUIsUipInd = 0x00000104;
enum TCoreAppUIsUipInd
    {
    ECoreAppUIsUipIndUninitialized = 0,
    ECoreAppUIsDoNotShow,
    ECoreAppUIsShow
    };

/**
* Used by SysAp for getting raw key events from NspsWsPlugin and
* disabling playing message tone
* Old Shared Data constant name: KSysApMessageToneQuit
*/
const TUint32 KCoreAppUIsMessageToneQuit = 0x00000106;
enum TCoreAppUIsMessageToneQuit
    {
    ECoreAppUIsTonePlayingUninitialized = 0,
    ECoreAppUIsStopTonePlaying, // both notification and state
    ECoreAppUIsTonePlaying
    };

/**
* Used by SysAp for getting raw key events from NspsWsPlugin in order to launch
* network scan when NSPS is active
* Old Shared Data constant name: KSysApNspsRawKeyEvent
*/
const TUint32 KCoreAppUIsNspsRawKeyEvent = 0x00000107;

/**
* Used by SysAp for getting raw key events from NspsWsPlugin in order to switch lights on
* Old Shared Data constant name: KSysApLightsControl
*/
const TUint32 KCoreAppUIsLightsRawKeyEvent = 0x00000108;

enum TCoreAppUIsRawKeyEvent
    {
    ECoreAppUIsKeyEventUninitialized = 0, 
    ECoreAppUIsNoKeyEvent,
    ECoreAppUIsKeyEvent        // this launches network scan or switches lights on
    };

/**
* Memory Card App notifies SysAp that the user has selected "Eject memory card"
* Old Shared Data constant name: KSysApMmcRemovedWithoutEject
*/
const TUint32 KCoreAppUIsMmcRemovedWithoutEject = 0x00000109;
enum TCoreAppUIsMmcRemovedWithoutEject
    {
    ECoreAppUIsEjectCommandUsedUninitialized = 0,
    ECoreAppUIsEjectCommandNotUsed,
    ECoreAppUIsEjectCommandUsed
    };

/**
* Used for notifying SysAp of the PoC indicator state.
*/
const TUint32 KCoreAppUIsPoCIndicator = 0x00000110;
enum TCoreAppUIsPocIndicator
    {
    ECoreAppUIsPocIndicatorUninitialized = 0,
    ECoreAppUIsPocIndicatorOff,
    ECoreAppUIsPocIndicatorDoNotDisturb,
    ECoreAppUIsPocIndicatorConnectionOn 
    };

/**
* Used for notifying SysAp of the USB File Transfer status.
* Sysap closes all applications when USB file transfer status
* changes to ECoreAppUIsUSBFileTransferTryingToActivate and
* sets value ECoreAppUIsUSBFileTransferOkToActivate
* when applications are closed.
* SysAp also disables all Powerkey Menu items during
* USB File Transfer except for "Switch Off".
*/
const TUint32 KCoreAppUIsUSBFileTransfer = 0x00000111;
enum TCoreAppUIsUSBFileTransfer
    {
    ECoreAppUIsUSBFileTransferUninitialized = 0,
    ECoreAppUIsUSBFileTransferNotActive,
    ECoreAppUIsUSBFileTransferActive,
    ECoreAppUIsUSBFileTransferTryingToActivate,
    ECoreAppUIsUSBFileTransferOkToActivate
    };

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

/**
* Used for notifying SysAp about TARM indicator state.
*/
const TUint32 KCoreAppUIsTarmIndicator = 0x00000113;
enum TCoreAppUIsTarmIndicator
    {
    ECoreAppUIsTarmIndicatorUninitialized = 0,
    ECoreAppUIsTarmTerminalSecurityOnIndicatorOn,
    ECoreAppUIsTarmMngActiveIndicatorOn,
    ECoreAppUIsTarmIndicatorsOff
    };

/**
* Used for notifying SysAp about Mobile TV recording status.
*/
const TUint32 KCoreAppUIsMtvRecStatus = 0x00000114;
enum TCoreAppUIsMtvRecStatus
    {
    ECoreAppUIsMtvRecStatusUninitialized = 0,
    ECoreAppUIsMtvRecStatusOff, 
    ECoreAppUIsMtvRecStatusOn  
    };

/**
* Used for notifying SysAp about Mobile TV DVB-H status.
*/
const TUint32 KCoreAppUIsMtvDvbhStatus = 0x00000115;
enum TCoreAppUIsMtvDvbhStatus
    {
    ECoreAppUIsMtvDvbhStatusUninitialized = 0,
    ECoreAppUIsMtvDvbhStatusOff, 
    ECoreAppUIsMtvDvbhStatusOn  
    };

/**
* Used for notifying SysAp of the PoC missed indicator state
*/
const TUint32 KCoreAppUIsPoCMissedIndicator = 0x00000116;
enum TCoreAppUIsPocMissedIndicator
     {
     ECoreAppUIsPocMissedIndicatorUninitialized = 0,
     ECoreAppUIsPocMissedIndicatorOff,
     ECoreAppUIsPocMissedIndicatorOn
     };


// =============================================================================
// Contacts Database Recovery Status API
// =============================================================================

// Use TUid KPSUidCoreApplicationUIs = { 0x101F8767 } 
/**
* Used by DbRecovery to notify other applications about the Contacts DB status.
* Old Shared Data constant name: KSysDbRecoveryContacts
*/
const TUint32 KCoreAppUIsDbRecoveryContacts = 0x00000105;
enum TCoreAppUIs
    {
    ECoreAppUIsContactsDbCorrupted = KErrCorrupt, // -20
    ECoreAppUIsContactsDbOk = KErrNone            // 0
    };

// =============================================================================
// Light Control API
// =============================================================================

// Use TUid KPSUidCoreApplicationUIs = { 0x101F8767 } 

/**
* Used by Alarm UI to notify SysAp to 1) start/stop blinking lights and 2) change the SW state
* into Alarm if current SW state is Charging.
* Old Shared Data constant name: KSysApAlarmLightActive
*/
const TUint32 KLightsAlarmLightActive = 0x00000201;
enum TLightsAlarm
    {
    ELightsBlinkingUninitialized = 0,
    ELightsNotBlinking,
    ELightsBlinking
    };

/**
* SysAp lights API for Video Telephony. VT can request forced lights on until eternity.
* The lights are switched off only when requested explicitely.
* Old Shared Data constant names: KSysApForcedLightsOn
*/
const TUint32 KLightsVTForcedLightsOn = 0x00000202;
enum TLights
    {
    EForcedLightsUninitialized = 0,
    EForcedLightsOff, // normal state
    EForcedLightsOn
    };

/**
* SysAp lights API for ScreenSaver. SS can request forced lights on for the
* maximum of 30 secs. Possible values: an integer > 0 and <= 30 (secs).
* Old Shared Data constant name: KSysApForcedSSLightsOn
*/
const TUint32 KLightsSSForcedLightsOn = 0x00000203;

/**
* SysAp generic Lights API.
* Old Shared Data constant name: KSysApLightsControl
*/
const TUint32 KLightsControl = 0x00000204;
enum TLightsControl
    {
    ELightsUninitialized = 0,
    ELightsOff, // not supported by SysAp
    ELightsOn   // lights are switched on in a normal way
    };


// =============================================================================
// Autolock Status API
// =============================================================================

// Use TUid KPSUidCoreApplicationUIs = { 0x101F8767 } 

/**
* Indicates the status of Autolock.
*/
#ifdef RD_STARTUP_CHANGE
const TUint32 KCoreAppUIsAutolockStatus  = 0x00000301;
enum TPSAutolockStatus
    {
	EAutolockStatusUninitialized = 0,
    EAutolockOff,
    EAutolockOn
    };
#endif //RD_STARTUP_CHANGE

// =============================================================================
// Twist Status API
// =============================================================================

// Use TUid KPSUidCoreApplicationUIs = { 0x101F8767 } 

/**
* Indicates the status of twist.
*/
const TUint32 KCoreAppUIsTwistStatus  = 0x00000401;
enum TPSTwistStatus
    {
	EPSTwistStatusUninitialized = 0,
    EPSTwistClose,
    EPSTwistOpen
    };



// =============================================================================
// System category
// Temporary - Moved from psvariables.h to here.
// TODO: remove these keys or move them to other APIs
// =============================================================================

// Use TUid KUidSystemCategory = { 0x101f75b6 } 

// The current grip status
const TInt KPSUidGripStatusValue = 0x100052DD; 
const TUid KPSUidGripStatus = {KPSUidGripStatusValue};
enum EPSGripStatus
    {
	EPSGripStatusUninitialized = 0,
    EPSGripOpen,
    EPSGripClosed
    };

/*****************************************
*   Location Global Privacy Value
******************************************/
const TInt KPSUidLocationGlobalPrivacyValue = 0x100052FA;
const TUid KPSUidLocationGlobalPrivacy={KPSUidLocationGlobalPrivacyValue};
enum EPSLocationGlobalPrivacy
    {
	EPSLocationGlobalPrivacyUninitialized = 0,
    EPSLocPrivAcceptAll,  
    EPSLocPrivRejectAll,
    EPSLocPrivAlwaysAsk,
    EPSLocPrivIndividualPrivacy,
    EPSLocPrivAcceptAllTimed,
    EPSLocPrivRejectAllTimed
    };




#endif      // COREAPPLICATIONUISINTERNALPSKEYS_H

// End of File

