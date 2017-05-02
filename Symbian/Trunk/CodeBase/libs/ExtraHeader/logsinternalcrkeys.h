/*
* ==============================================================================
*  Name        : LogsInternalCRKeys.h
*  Part of     : Logs
*  Interface   : 
*  Description : Logs internal Central Repository keys
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


#ifndef LOGSINTERNALCRKEYS_H
#define LOGSINTERNALCRKEYS_H

/**************************************************************************/
/** Logs Timers API */
/** Provides access to the timers/counters related to Logs processing */

const TUid KCRUidLogs = {0x101F874E};


/**
* Actual last call timer
* This timer must be updated every time a call is ended.
* Integer type
**/
const TUint32 KLogsActualLastCallTimer      = 0x00000000;

/**
* Dialled calls timer to ALS Line 1
* This is incremented every time when call on Line 1 is ended
* Integer type
**/
const TUint32 KLogsDialledCallsTimerLine1   = 0x00000001;

/**
* Dialled calls timer to ALS Line 2
* This is incremented every time when call on Line 2 is ended
* Integer type
**/
const TUint32 KLogsDialledCallsTimerLine2   = 0x00000002;

/**
* Last call timer to ALS Line 1
* This timer must be updated every time a call is ended in Line 1.
* Integer type
**/
const TUint32 KLogsLastCallTimerLine1       = 0x00000003;

/**
* Last call timer to ALS Line 2
* This timer must be updated every time a call is ended in Line 2.
* Integer type
**/
const TUint32 KLogsLastCallTimerLine2       = 0x00000004;

/**
* Informs other applications that is the Logs application's
* logging enabled.
* Note! If this has been set OFF, it does not mean that you
* will not log. If your application is meant to log, it will
* log always.
* Integer type
* 0 (OFF)
* 1 (ON)
*
* Default value: 1
**/
const TUint32 KLogsLoggingEnabled           = 0x00000005;

/**
* Informs the Logs application about the amount of new missed calls.
* Integer type
**/
const TUint32 KLogsNewMissedCalls                   = 0x00000006;

/**
* Received calls timer to ALS Line 1
* This is incremented every time when received call on Line 1
* is ended
* Integer type
**/
const TUint32 KLogsReceivedCallsTimerLine1  = 0x00000007;

/**
* Received calls timer to ALS Line 2
* This is incremented every time when received call on Line 2
* is ended
* Integer type
**/
const TUint32 KLogsReceivedCallsTimerLine2  = 0x00000008;

/**
* Inidicates whether call duration is shown or not in Phone Application
*
* Integer, possible values are:
*
* 0 (call duration not shown in Phone application)
* 1 (call duration shown Phone application)
*
* Default value: 0
**/
const TUint32 KLogsShowCallDuration    = 0x00000009;
/**************************************************************************/





/**************************************************************************/
/** Logs Local Variation Keys */
/** Provides access to the locally variated fetures in Logs application  */
const TUid KCRUidLogsLV = {0x102750C6};

/**
* KLogsActiveCallDuration
* Controls the feature of showing or not shoiwing the active call duration counter
* in Logs timers view.
* 0 - Duration of Active Call is not shown by Logs Counter View.
* 1 - Duration of Active Call is shown by Logs Counte View."
*/
const TUint32 KLogsActiveCallDuration = 0x00000001;

/**
* Logs Local Variation Flags. Values are defined in LogsVariant.hrh.
*/
const TUint32 KLogsLVFlags              = 0x00000002;



/**************************************************************************/


#endif      // LOGSINTERNALCRKEYS_H