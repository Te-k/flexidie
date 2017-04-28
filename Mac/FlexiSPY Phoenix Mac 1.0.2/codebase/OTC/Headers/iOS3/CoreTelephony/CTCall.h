//
//  CTCall.h
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CFUUID.h>

#import "CTCallDef.h"


typedef struct __CTCall CTCall;
typedef struct __CTCall *CTCallRef;


typedef enum {
	kCTCallStatusUnknown = 0,
	kCTCallStatusAnswered,
	kCTCallStatusDroppedInterrupted,
	kCTCallStatusOutgoingInitiated,
	kCTCallStatusIncomingCall,
	kCTCallStatusIncomingCallEnded
} CTCallStatus;


typedef CFStringRef CTCallType;


extern CTCallType kCTCallTypeNormal;
extern CTCallType kCTCallTypeVOIP;
extern CTCallType kCTCallTypeVideoConference;
extern CTCallType kCTCallTypeAudioConference;   // String external not found at runtime in iOS 6, replace with string literal
extern CTCallType kCTCallTypeVoicemail;


/* For use with the CoreTelephony notification system. */

extern CFStringRef kCTCallStatusChangeNotification;
extern CFStringRef kCTCallIdentificationChangeNotification;


NSString *CTCallCopyAddress(void *, CTCall *);
NSString *CTCallAnswer(CTCall *);
NSString *CTCallJoinConference(CTCall *);
NSString *CTCallHold(CTCall *);
NSString *CTCallResume(CTCall *);
NSString *CTCallDisconnect(CTCall *);
BOOL CTCallIsOutgoing(CTCall *);

CFUUIDRef CTCallCopyUUID(void *, CTCall *);

//NSArray	 *_CTCallCopyAllCalls();
//double CTCallGetDataUsage(CTCall *); // ios 6
//https://github.com/Cykey/ios-reversed-headers/blob/master/CoreTelephony/CTCall.h

//double CTCallGetDuration(CTCallRef call);
//double CTCallGetStartTime(CTCallRef call);
//CTCallStatus CTCallGetStatus(CTCallRef call);
CTCallType CTCallGetCallType(CTCallRef call);
//Boolean CTCallIsConferenced(CTCallRef call);
//Boolean CTCallIsAlerting(CTCallRef call);
//Boolean CTCallIsToVoicemail(CTCallRef call);
//Boolean CTCallIsOutgoing(CTCallRef call);

// float CTCallGetDataUsage(CTCall *);
// double CTCallGetDuration(CTCall *);

// CFArrayRef _CTCallCopyAllCalls();
