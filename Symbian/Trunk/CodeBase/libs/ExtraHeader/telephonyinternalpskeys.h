/*
* ==============================================================================
*  Name        : TelephonyInternalPSKeys.h
*  Part of     : Telephony
*  Interface   : 
*  Description : Telephony internal Publish and Subscribe keys.
*  Version     : 
*
*  Copyright (c) 2004, 2005 Nokia Corporation.
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

#ifndef TELEPHONYINTERNALPSKEYS_H
#define TELEPHONYINTERNALPSKEYS_H

#include <e32std.h>


// CONSTANTS

/**
* Telephony call handling PS Uid.
*/
const TUid KPSUidTelephonyCallHandling = {0x101F8787};

/**
* Information on remote party contact info.
* @see TTelephonyRemotePartyContactInfo in TelephonyInternalPSTypes.h
* @type RProperty::EByteArray
*/
const TUint32 KTelephonyRemotePartyContactInfo = 0x00000001;

/**
* Remote party name (from contacts)
* @type RProperty::EText
*/
const TUint32 KTelephonyCLIName = 0x00000002;

/**
* Remote party telephone number
* @type RProperty::EText
*/
const TUint32 KTelephonyCLINumber = 0x00000003;

/**
* State of ongoing call(s). The following table shows states if
* in different combinations of phone calls.
* 
* Call 1 state    Call 2 state    TPSTelephonyCallState
* =========================================================
* idle            idle            EPSTelephonyCallStateNone
* hold            idle            EPSTelephonyCallStateHold
* hold            dialling        EPSTelephonyCallStateDialling
* hold            ringing         EPSTelephonyCallStateRinging
* hold            answering       EPSTelephonyCallStateAnswering
* hold            connected       EPSTelephonyCallStateConnected
* connected       connected       EPSTelephonyCallStateConnected
* connected       ringing         EPSTelephonyCallStateRinging
* disconnecting   connected       EPSTelephonyCallStateConnected
* disconnecting   hold            EPSTelephonyCallStateHold
* disconnecting   idle            EPSTelephonyCallStateDisconnecting
* disconnecting   ringing         EPSTelephonyCallStateRinging
*
* @type: RProperty::EInt
*/
const TUint32 KTelephonyCallState = 0x00000004;
enum TPSTelephonyCallState
    {
    EPSTelephonyCallStateUninitialized,
    EPSTelephonyCallStateNone,
    EPSTelephonyCallStateAlerting,
    EPSTelephonyCallStateRinging,
    EPSTelephonyCallStateDialling,
    EPSTelephonyCallStateAnswering,
    EPSTelephonyCallStateDisconnecting,
    EPSTelephonyCallStateConnected,
    EPSTelephonyCallStateHold
    };

/**
* Type of ongoing call.
* Special case: simultanous CS voice and VoIP call is
* possible. In this case type is indicated as VoIP
*
* @type: RProperty::EInt
*/
const TUint32 KTelephonyCallType = 0x00000005;
enum TPSTelephonyCallType
    {
    EPSTelephonyCallTypeUninitialized,
    EPSTelephonyCallTypeNone,
    EPSTelephonyCallTypeCSVoice,
    EPSTelephonyCallTypeFax,
    EPSTelephonyCallTypeData,
    EPSTelephonyCallTypeHSCSD,
    EPSTelephonyCallTypeH324Multimedia,
    EPSTelephonyCallTypeVoIP
    };

/**
* State of 3G-324M video call.
* DEPRECATED - KTelephonyCallState and KTelephonyCallType should be used instead.
* (after appropriate call type is available).
* @type RProperty::EInt
*/
const TUint32 KTelephonyVideoCallActive = 0x0000000A;
enum TPSTelephonyVideoCallState
    {
    EPSTelephonyNoVideoCall,
    EPSTelephonyVideoCallOngoing
    };

/**
* Deprecated UID for compatibility only. 
* Telephony Network Info PS Uid.
* Cellular network related information.
*/
const TUid KPSUidTelephonyNetworkInfo = {0x101F8786};

/**
* Deprecated key for compatibility only. 
* Network mode (where terminal is currently registered to).
* @type: RProperty::EInt
*/
const TUint32 KTelephonyNetworkMode = 0x00000001;
enum EPSTelephonyNetworkMode
    {
    EPSTelephonyNetworkModeUnknown,
    EPSTelephonyNetworkModeGsm,
    EPSTelephonyNetworkModeWcdma
    };

/**
* Telephony Information API UID
*/
const TUid KPSUidTelephonyInformation = {0x101F8789};

/**
* Space separated list of supported emergency call codes.
* @type RProperty::EText
*/
const TUint32 KTelephonyEmergencyNumbers = 0x00000001;

/**
* Identifier of Idle application.
* @type RProperty::EInt
*/
const TUint32 KTelephonyIdleUid = 0x00000002;

/**
* Identifier of Phone application.
* @type RProperty::EInt
*/
const TUint32 KTelephonyPhoneUid = 0x00000003;

/**
* Identifier of Video Telephone application.
* This key has two special values, see TPSTelephonyVTAppState.
* 
* @type RProperty::EInt
*/
const TUint32 KTelephonyVideoCallUid = 0x00000004;
enum TPSTelephonyVTAppState
    {
    // Video Telephone was on background when call ended, no need
    // to set Phone/Idle on foreground.
    EPSTelephonyVTAppStateBackground = -1,
    // Video Telephone
    EPSTelephonyVTAppStateNone = 0
    };

/**
* Operator information display data.
* @see TTelephonyTitleDisplay in TelephonyInternalPSTypes.h
* @type RProperty::EByteArray
*/
const TUint32 KTelephonyDisplayInfo =  0x00000005;

/**
* Telephony Audio API UID
*/
const TUid KPSUidTelephonyAudio = {0x101F8788};

/**
* Audio status 
* @type RProperty::EInt
*/
const TUint32 KTelephonyAudioStatus = 0x00000001;
enum TPSTelephonyAudioStatus
    {
    EPSTelephonyAudioStatusNone,
    EPSTelephonyAudioStatusPlaying,
    EPSTelephonyAudioStatusRecording
    };

/**
* Integrated Handsfree (IHF) mode.
* @type RProperty::EInt
*/
const TUint32 KTelephonyIhfMode = 0x00000002;
enum TPSTelephonyIhfMode
    {
    EPSTelephonyIhfOff,
    EPSTelephonyIhfOn    
    };

/**
* Idle Information API UID
*/
const TUid KPSUidIdleInformation = {0x102071C0};

/**
* Indicates that phone is in idle state
* @type RProperty::EInt
*/
const TUint32 KTelephonyIdleStatus = 0x00000001;
enum TPSTelephonyIdleStatus
    {
    EPSTelephonyNotIdle,
    EPSTelephonyIdle
    };

/**
* Indication about operator logo change. 
* @see TTelephonyOTALogoUpdate in TelephonyInternalPSTypes.h
* @type RProperty::EByteArray
*/
const TUint32 KTelephonyOperatorLogoUpdated = 0x00000002;

/**
* Indication from IdlePlugin, that key events are coming to phone.
* Phone knows from this event that focus should remain in Phone.
* @type RProperty::EInt
*/
const TUint32 KTelephonyFocusInfo = 0x00000003;
enum EPSTelephonyFocusInfo 
    {
    EPSTelephonyFocusInfoNone = 0,
    EPSTelephonyIncomingKeyEvents    
    };

/**
* Indication to Idle that whether number entry
* is open in phone or not
*/
const TUint32 KTelephonyNumberEntryInfo = 0x00000004;
enum TPSTelephonyNumberEntryInfo 
    {
    EPSTelephonyNumberEntryClosed = 0,
    EPSTelephonyNumberEntryOpen    
    };
    
/**
* Telephony Comms Information API UID
*/
const TUid KPSUidTelephonyComms = {0x102071C2};

/**
* Dataport to be used for video calls.
* Data encoding: <dataport name><delimiter><port number>
* where <dataport name> = string literal
*       <delimiter> = double colon
*       <port number> = integer value
*
* @type RProperty::EText
*/
const TUint32 KTelephonyCommsDataport = 0x00000001;

/**
* Telephony Generic Command API
* This can be used for requesting simple services from
* other process/application when it is inconvenient to implement
* client/server or similar complex pattern.
*/
const TUid KPSUidTelephonyGenericCommand = {0x102072C1};

/*
* Command operation values that should be used with keys in 
* Telephony Generic Command API. Client entity sets value
* to EPSTelephonyGenCmdPerform. Service provider sets value 
* back to EPSTelephonyGenCmdReset when command was succesfully 
* completed. In case of failure it may set it to EPSTelephonyGenCmdFail
* to indicate error to requester.
* 
*/
enum {
    // Values to be set by service provider.
    EPSTelephonyGenCmdFail = -1,
    EPSTelephonyGenCmdReset,    
    
    // Client uses this value to request a service.
    EPSTelephonyGenCmdPerform
    };

/**
* Command key for launching Log application.
* @type RProperty::EInt
*/
const TUint32 KTelephonyGenCmdLaunchLogApp = 0x00000001;

/**
* Deprecated key for compatibility only. Use KPSUidIdleInformation and
* KTelephonyIdleStatus.
*/
const TInt KPSUidPhoneIdleStatusValue = 0x100052E4;
const TUid KPSUidPhoneIdleStatus = {KPSUidPhoneIdleStatusValue};
enum EPSPhoneIdleStatus
    {
    EPSPhoneIdleStatusUninitialized = 0,
    EPSPhoneNotIdle,
    EPSPhoneIdle
    };

/**
* Deprecated key for compatibility only. 
* Use KPSUidTelephonyCallHandling UID and KPSUidTelephonyCallHandling and
* KTelephonyCallState keys instead.
*/
const TInt KPSUidCurrentCallValue   =0x100052CB;
const TUid KPSUidCurrentCall        ={KPSUidCurrentCallValue};
enum EPSCurrentCall
    {
    EPSCurrentCallUninitialized = 0,
    EPSCallNone,
    EPSCallVoice,
    EPSCallFax,
    EPSCallData,
    EPSCallAlerting,
    EPSCallRinging,
    EPSCallAlternating,
    EPSCallDialling,
    EPSCallAnswering,
    EPSCallDisconnecting
    };

/**
* Deprecated key for compatibility only. Value is not updated.
* Use KPSUidTelephonyCallHandling UID and KPSUidTelephonyCallHandling and
* KTelephonyCallState keys instead.
*/
const TInt KPSUidCallStateValue = 0x100052FD;
const TUid KPSUidCallState={KPSUidCallStateValue};
enum EPSCallState
    {
    EPSCallStateUninitialized = 0,
    EPSCallStateNone,
    EPSCallStateAlerting,
    EPSCallStateRinging,
    EPSCallStateAlternating,
    EPSCallStateDialling,
    EPSCallStateAnswering,
    EPSCallStateDisconnecting,
    EPSCallStateConnected
    };


/**
* Deprecated key for compatibility only. Value is not updated.
* Use KPSUidTelephonyCallHandling UID and KPSUidTelephonyCallHandling and
* KTelephonyCallState keys instead.
*/
const TInt KPSUidCallTypeValue = 0x100052FE;
const TUid KPSUidCallType={KPSUidCallTypeValue};
enum EPSCallType
    {
    EPSCallTypeUninitialized = 0,
    EPSCallTypeNone,
    EPSCallTypeVoice,
    EPSCallTypeFax,
    EPSCallTypeData,
    EPSCallTypeHSCSD,
    EPSCallTypeCircuitSwitchedCallsNotPossible
    };


// Indicates the in call audio routing preference to the phone (public/private)					
const TInt KTelephonyAudioOutputPreference = 0x1020299C;
const TUid KTelephonyAudioOutput = {KTelephonyAudioOutputPreference};
enum EPSTelephonyAudioOutput
    {
    EPSPrivate = 0,
    EPSPublic    
    };    



#endif      // TELEPHONYINTERNALPSKEYS_H

// End of file