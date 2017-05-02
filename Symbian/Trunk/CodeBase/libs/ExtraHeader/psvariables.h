/*
* ==============================================================================
*  Name        : PSVariables.h
*  Part of     :
*  Interface   :
*  Description :
*   Event enumerations and uid:s of Publish And Subscribe. PubSub clients
*   can include this file and listen to these events. These events will be
*   routed through Publish And Subscribe.
*  Version     :
*
*  Copyright (c) 2004 Nokia Corporation.
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

#ifndef __PSVARIABLES_H__
#define __PSVARIABLES_H__

// INCLUDES
#include <CoreApplicationUIsInternalPSKeys.h>
#include <TelephonyInternalPSKeys.h>

// Global subkey to be used with SAE variables.
// To be used with RProperty::Get() and Set() etc. interface calls.
const TInt KPropertySubKey                  = 0;

const TInt KEnumerationFirstValue           = 0;

const TInt KPSUidProfileValue               = 0x100052D2;
const TUid KPSUidProfile                    = {KPSUidProfileValue};

#ifndef RD_STARTUP_CHANGE
const TInt KPSUidSIMStatusValue             = 0x100052C6;
const TUid KPSUidSIMStatus                  = {KPSUidSIMStatusValue};
enum EPSSIMStatus
    {
    EPSSIMStatusUninitialized               = KEnumerationFirstValue,
    EPSSimOk,
    EPSSimNotPresent,
    EPSSimRejected
    };
#endif // RD_STARTUP_CHANGE

const TInt KPSUidNetworkStatusValue         = 0x100052C7;
const TUid KPSUidNetworkStatus              = {KPSUidNetworkStatusValue};
enum EPSNetworkStatus
    {
    EPSNetworkStatusUninitialized           = KEnumerationFirstValue,
    EPSNetworkAvailable,
    EPSNetworkUnAvailable
    };

const TInt KPSUidNetworkStrengthValue       = 0x100052C8;
const TUid KPSUidNetworkStrength            = {KPSUidNetworkStrengthValue};
enum EPSNetworkStrength
    {
    EPSNetworkStrengthUninitialized         = KEnumerationFirstValue,
    EPSNetworkStrengthNone,
    EPSNetworkStrengthLow,
    EPSNetworkStrengthMedium,
    EPSNetworkStrengthHigh,
    EPSNetworkStrengthUnknown
    };

const TInt KPSUidInboxStatusValue           = 0x100052CD;
const TUid KPSUidInboxStatus                = {KPSUidInboxStatusValue};
enum EPSInboxStatus
    {
    EPSInboxStatusUninitialized             = KEnumerationFirstValue,
    EPSInboxEmpty,
    EPSDocumentsInInbox
    };

// KPSUidOutboxStatusValue have to match with
// same const in ncnlistsdkpskeys.h
const TInt KPSUidOutboxStatusValue          = 0x100052CE;
const TUid KPSUidOutboxStatus               = {KPSUidOutboxStatusValue};

// EPSOutboxStatus have to match with
// same enum in ncnlistsdkpskeys.h
enum EPSOutboxStatus
    {
    EPSOutboxStatusUninitialized            = KEnumerationFirstValue,
    EPSOutboxEmpty,
    EPSDocumentsInOutbox
    };

const TInt KPSUidIrdaStatusValue            = 0x100052D1;
const TUid KPSUidIrdaStatus                 = {KPSUidIrdaStatusValue};
enum EPSIrdaStatus
    {
    EPSIrdaStatusUninitialized              = KEnumerationFirstValue,
    EPSIrLoaded,                            // IRDA Irlap layer loaded
    EPSIrDiscoveredPeer,                    // Discovery begin
    EPSIrLostPeer,                          // Discovery end
    EPSIrConnected,                         // IRDA Irlap layer connected
    EPSIrBlocked,                           // IRDA Irlap layer blocked
    EPSIrDisConnected,                      // IRDA Irlap layer disconnected
    EPSIrUnloaded                           // IRDA Irlap layer unloaded
    };

// The amount of network bars
const TInt KPSUidNetworkBarsValue           = 0x100052D4;
const TUid KPSUidNetworkBars                = {KPSUidNetworkBarsValue};
enum EPSNetworkBars
    {
    EPSNetworkBarsBarsUninitialized         = KEnumerationFirstValue,
    EPSNBars_0,
    EPSNBars_1,
    EPSNBars_2,
    EPSNBars_3,
    EPSNBars_4,
    EPSNBars_5,
    EPSNBars_6,
    EPSNBars_7
    };

// GPRS availability status
const TInt KPSUidGprsAvailabilityValue      = 0x100052DA;
const TUid KPSUidGprsAvailability           = {KPSUidGprsAvailabilityValue};
enum EPSGprsAvailability
    {
    EPSGprsAvailabilityUninitialized        = KEnumerationFirstValue,
    EPSGprsAvailable,
    EPSGprsNotAvailable,
    EPSGprsAvailabilityUnknown
    };

// The current GPRS connection status
const TInt KPSUidGprsStatusValue            = 0x100052DB;
const TUid KPSUidGprsStatus                 = {KPSUidGprsStatusValue};
enum EPSGprsStatus
    {
    EPSGprsStatusUninitialized              = KEnumerationFirstValue,
    EPSGprsUnattached,
    EPSGprsAttach,
    EPSGprsContextActive,
    EPSGprsSuspend,
    EPSGprsContextActivating,
    EPSGprsMultibleContextActive
    };

// Indicates if the device is in silent mode
const TInt KPSUidSilentModeStatusValue      = 0x100052DF;
const TUid KPSUidSilentModeStatus           = {KPSUidSilentModeStatusValue};
enum EPSSilentModeStatus
    {
    EPSSilentModeStatusUninitialized        = KEnumerationFirstValue,
    EPSSilentModeOff,
    EPSSilentModeOn
    };

#ifndef RD_STARTUP_CHANGE
// Current calls forwarding information
const TInt KPSUidCallsForwardingStatusValue = 0x100052E0;
const TUid KPSUidCallsForwardingStatus      = {KPSUidCallsForwardingStatusValue};
enum EPSCallsForwardingStatus
    {
    EPSCallsForwardingStatusUninitialized   = KEnumerationFirstValue,
    EPSNoCallsForwarded,
    EPSAllForwarded,                        // In this case, ALS is not supported
    EPSForwardedOnLine1,
    EPSForwardedOnLine2,
    EPSForwardedOnBothLines,
    EPSCallsForwardedToVoiceMailbox,
    };

// Voice mail status
// KPSUidVoiceMailStatusValue have to match with
// same const in ncnlistsdkpskeys.h
const TInt KPSUidVoiceMailStatusValue       = 0x100052E3;
const TUid KPSUidVoiceMailStatus            = {KPSUidVoiceMailStatusValue};

// EPSVoiceMailStatus have to match with
// same enum in ncnlistsdkpskeys.h
enum EPSVoiceMailStatus
    {
    EPSVoiceMailStatusStatusUninitialized   = KEnumerationFirstValue,
    EPSNoVoiceMails,
    EPSWaiting,                             // If ALS is not supported
    EPSWaitingOnLine1,
    EPSWaitingOnLine2,
    EPSWaitingOnBothLines,
    };
#endif // RD_STARTUP_CHANGE

// Indicates if the SMS memory is full
const TInt KPSUidSimSmsMemoryStatusValue    = 0x100052E5;
const TUid KPSUidSimSmsMemoryStatus         = {KPSUidSimSmsMemoryStatusValue};
enum EPSSimSmsMemoryStatus
    {
    EPSSimSmsMemoryStatusUninitialized      = KEnumerationFirstValue,
    EPSSimSmsMemoryNotFull,
    EPSSimSmsMemoryFull
    };

#ifndef RD_STARTUP_CHANGE
// Indicates if the SIM card is ready to send SIM card contacts information
const TInt KPSSimReadyStatusValue           = 0x100052E8;
const TUid KPSUidSimReadyStatus             = {KPSSimReadyStatusValue};
enum EPSSimReadyStatus
    {
    EPSSimReadyStatusUninitialized          = KEnumerationFirstValue,
    EPSSimNotReady,
    EPSSimReady
    };

//SIM card status
const TInt KPSUidSimCStatusValue            = 0x100052E9;
const TUid KPSUidSimCStatus                 = {KPSUidSimCStatusValue};
enum EPSSimCStatus
    {
    EPSSimCStatusUninitialized              = KEnumerationFirstValue,
    EPSCSimInitWait,
    EPSCSimLockOperative,
    EPSCSimPinVerifyRequired,
    EPSCSimPermanentlyBlocked,
    EPSCSimRemoved,
    EPSCSimRejected,
    EPSCSimBlocked,
    EPSCSimOk,
    EPSCSimUPinVerifyRequired,
    EPSCSimUPinBlocked,
    EPSCSimNotSupported
    };

// Indicates if the current SIM card is the same as the previous one.
const TInt KPSUidSimChangedValue            = 0x100052EA;
const TUid KPSUidSimChanged                 = {KPSUidSimChangedValue};
enum EPSSimChanged
    {
    EPSSimChangedUninitialized              = KEnumerationFirstValue,
    EPSSimNotChanged,
    EPSSimChanged
    };
#endif // RD_STARTUP_CHANGE

// The current home zone status
const TInt KPSUidHomeZoneStatusValue        = 0x100052EB;
const TUid KPSUidHomeZoneStatus             = {KPSUidHomeZoneStatusValue};
enum EPSHomeZoneStatus
    {
    EPSHomeZoneStatusUninitialized          = KEnumerationFirstValue,
    EPSNone,
    EPSViagCityZone,
    EPSViagHomeZone,
    EPSOrangeHomeZone,
    EPSMO2OHomeZone
    };

#ifndef RD_STARTUP_CHANGE
// Indicates if there is a fax message waiting
const TInt KPSUidFaxMessageStatusValue      = 0x100052EC;
const TUid KPSUidFaxMessageStatus           = {KPSUidFaxMessageStatusValue};
enum EPSFaxMessageStatus
    {
    EPSFaxMessageStatusUninitialized        = KEnumerationFirstValue,
    EPSNoFaxMessages,
    EPSFaxMessageWaiting
    };

// Indicates if there is an email message waiting
const TInt KPSUidEmailMessageStatusValue    = 0x100052ED;
const TUid KPSUidEmailMessageStatus         = {KPSUidEmailMessageStatusValue};
enum EPSEmailMessageStatus
    {
    EPSEmailMessageStatusUninitialized      = KEnumerationFirstValue,
    EPSNoEmailMessages,
    EPSEmailMessageWaiting
    };

// Indicates if there are other type message waiting
const TInt KPSUidOtherMessageStatusValue    = 0x100052EE;
const TUid KPSUidOtherMessageStatus         = {KPSUidOtherMessageStatusValue};
enum EPSOtherMessageStatus
    {
    EPSOtherMessageStatusUninitialized      = KEnumerationFirstValue,
    EPSNoOtherMessages,
    EPSOtherMessageWaiting
    };
#endif // RD_STARTUP_CHANGE

// Indicates that a class 0 sms message is received and being handled
const TInt KPSUidClass0SmsReceivedValue     = 0x100052EF;
const TUid KPSUidClass0SmsReceived          = {KPSUidClass0SmsReceivedValue};

#ifndef RD_STARTUP_CHANGE
// Indicates if the security code is required by the Nos Security server
const TInt KPSUidSecurityCodeStatusValue    = 0x100052F0;
const TUid KPSUidSecurityCodeStatus         = {KPSUidSecurityCodeStatusValue};
enum EPSSecurityCodeStatus
    {
    EPSSecurityCodeStatusUninitialized      = KEnumerationFirstValue,
    EPSSecurityCodeNotRequired,
    EPSSecurityCodeRequired,
    EPSSecurityCodeInitWait
    };

// Indicates if the security code is required by the Nos Security server
const TInt KPSUidAutolockStatusValue        = 0x100052F2;
const TUid KPSUidAutolockStatus             = {KPSUidAutolockStatusValue};
enum EPSAutolockStatus
    {
    EPSAutolockStatusUninitialized          = KEnumerationFirstValue,
    EPSAutolockOff,
    EPSAutolockOn
    };

// The SIM lock status
const TInt KPSUidSimLockStatusValue         = 0x100052F4;
const TUid KPSUidSimLockStatus              = {KPSUidSimLockStatusValue};
enum EPSSimLockStatus
    {
    EPSSimLockStatusUninitialized           = KEnumerationFirstValue,
    EPSSimLockActive,
    EPSSimLockRestrictionPending,
    EPSSimLockRestrictionOn
    };
#endif // RD_STARTUP_CHANGE

const TInt KPSUidFirstBootStatusValue       = 0x100052F5;
const TUid KPSUidFirstBootStatus            = {KPSUidFirstBootStatusValue};
enum EPSFirstBootStatus
    {
    EPSFirstBootStatusUninitialized         = KEnumerationFirstValue,
    EPSNotInFirstBoot,
    EPSFirstBootOngoing
    };

#ifndef RD_STARTUP_CHANGE
const TInt KPSUidCurrentSimOwnedSimStatusValue  = 0x100052F6;
const TUid KPSUidCurrentSimOwnedSimStatus       = {KPSUidCurrentSimOwnedSimStatusValue};
enum EPSCurrentSimOwnedSimStatus
    {
    EPSCurrentSimOwnedSimStatusUninitialized    = KEnumerationFirstValue,
    EPSCurrentSimNotOwned,
    EPSCurrentSimOwned
    };
#endif // RD_STARTUP_CHANGE

const TInt KPSUidNewEmailStatusValue        = 0x100052F8;
const TUid KPSUidNewEmailStatus             = {KPSUidNewEmailStatusValue};
enum EPSNewEmailStatus
    {
    EPSNewEmailStatusUninitialized          = KEnumerationFirstValue,
    EPSNoNewEmail,
    EPSNewEmail
    };

/*****************************************
*   The current WCDMA connection status
******************************************/
const TInt KPSUidWcdmaStatusValue           = 0x100052FF;
const TUid KPSUidWcdmaStatus                = {KPSUidWcdmaStatusValue};
enum EPSWcdmaStatus
    {
    EPSWcdmaStatusUninitialized             = KEnumerationFirstValue,
    EPSWcdmaUnattached,
    EPSWcdmaAttach,
    EPSWcdmaContextActive,
    EPSWcdmaSuspend,
    EPSWcdmaContextActivating,
    EPSWcdmaMultipleContextActive
    };

#ifndef RD_STARTUP_CHANGE
/*****************************************
*   Sim Present State
******************************************/
const TInt KPSUidSimPresentValue            = 0x10005301;
const TUid KPSUidSimPresent                 = {KPSUidSimPresentValue};
enum EPSSimPresent
    {
    EPSSimPresentInitWait,
    EPSSimPresentTrue,
    EPSSimPresentFalse
    };
#endif // RD_STARTUP_CHANGE

#ifndef __ACCESSORY_FW
/*******************************************
*   Loop Set mode states
********************************************/
enum EPSAccLpsMode
    {
    EPSAccLpsModeUninitialized              = KEnumerationFirstValue,
    EPSAccLpsOff,
    EPSAccLpsOn,
    EPSAccTty                               = 0x04
    };
#endif //__ACCESSORY_FW

enum EPSButtonState
    {
    EPSButtonStateUninitialized             = KEnumerationFirstValue,
    EPSButtonUp,
    EPSButtonDown,
    EPSButtonDownLongPress
    };

#ifndef __ACCESSORY_FW
/******************************************
*   Handsfree Mode settings
*******************************************/
enum EPSHandsFreeMode
    {
    EPSHandsFreeModeUninitialized           = KEnumerationFirstValue,
    EPSIhfOff,
    EPSIhfOn
    };
#endif //__ACCESSORY_FW

#endif  // __PSVARIABLES_H__
