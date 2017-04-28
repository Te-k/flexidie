//
//  Telephony.h
//  SpyCallPOC
//
//  Created by Prasad Malekudiyi Balakrishn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INVALID 0
#define CALLBACK_TELEPHONY_NOTIFICATION_STATUS_CONECTED 1
#define CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD 2
#define CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DIALING 3
#define CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING 4
#define CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED 5

#define CALL_NOTIFICATION_STATUS_INPROGRESS 	CALLBACK_TELEPHONY_NOTIFICATION_STATUS_CONECTED
#define CALL_NOTIFICATION_STATUS_ONHOLD 		CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD
#define CALL_NOTIFICATION_STATUS_OUTGOING		CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DIALING
#define CALL_NOTIFICATION_STATUS_INCOMING 		CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING
#define CALL_NOTIFICATION_STATUS_TERMINATED 	CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED


#define CTTelephony "/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony"

extern NSString const *CTCallStateDialing;
extern NSString const *CTCallStateIncoming;
extern NSString const *CTCallStateConnected;
extern NSString const *CTCallStateDisconnected;

typedef struct __CTCall CTCall;
NSString *CTCallCopyAddress(void *, CTCall *);
NSString *CTCallAnswer(CTCall *);
NSString *CTCallJoinConference(CTCall *);
NSString *CTCallLeaveConference(CTCall *);
NSString *CTCallHold(CTCall *);
NSString *CTCallResume(CTCall *);
NSString *CTCallDisconnect(CTCall *);
NSString *CTCallDeleteFromCallHistory(CTCall *);
NSString *_CTServerConnectionEndCall(void *,void *);
CFTypeRef *CTCallCopyName(CTCall *); // Hang and restart SpringBoard
NSInteger CTCallGetStatus(CTCall *);
id CTCopyCurrentCalls();
id _CTCallCopyCurrentCalls();
id _CTCallCopyAllCalls();
BOOL CTCallIsConferenced(CTCall *); // Can use only in incoming call call back! otherwise would cause the thread hanged
NSInteger CTCallGetCauseCode(CTCall *);
BOOL CTCallIsWaiting(CTCall *);
id _CTSwapCalls();
id CTCallAnswerEndingActive(CTCall *);
id CTCallHistoryInvalidateCaches();
BOOL CTCallIsOutgoing(CTCall *);
id CTCallGetID(CTCall *); // Hang and restart SpringBoard

CFNotificationCenterRef CTTelephonyCenterGetDefault();
void CTTelephonyCenterAddObserver(CFNotificationCenterRef, void *, void *, CFStringRef, void *, CFNotificationSuspensionBehavior);
void CTTelephonyCenterRemoveObserver(CFNotificationCenterRef, void *, CFStringRef, void *);

@interface CTCallCenter : NSObject
{
    void *_internal;
    NSSet *_currentCalls;
    id _callEventHandler;
}

struct __CTServerConnection {
    int a;
    int b;
    CFMachPortRef myport;
    int c;
    int d;
    int e;
    int f;
    int g;
    int h;
    int i;
};
typedef struct __CTServerConnection CTServerConnection;
typedef CTServerConnection* CTServerConnectionRef;
mach_port_t _CTServerConnectionGetPort(void *);

typedef struct {
    CTServerConnectionRef	serv;
    CFMachPortRef		port;
    CFRunLoopSourceRef		rls;
    int				result;
} ServerConnection, * ServerConnectionRef;

//void (*_ZL25_ServerConnectionCallbackP20__CTServerConnectionPK10__CFStringPK14__CFDictionaryPv_0)(CTServerConnectionRef connection, CFStringRef notification, CFDictionaryRef notification_info,void * info);

- (id)description;
- (void)broadcastCallStateChangesIfNeededWithFailureLogMessage:(id)arg1;
- (void)handleNotificationFromConnection:(void *)arg1 ofType:(id)arg2 withInfo:(id)arg3;
@property(retain) NSSet *currentCalls; // @dynamic currentCalls;
- (BOOL)calculateCallStateChanges:(id)arg1;
- (BOOL)getCurrentCallSetFromServer:(id)arg1;
@property(copy, nonatomic) id callEventHandler;
- (void)dealloc;
- (id)init;
- (void)cleanUpServerConnection;
- (void)cleanUpServerConnectionNoLock;
- (void)reestablishServerConnectionIfNeeded;
- (BOOL)setUpServerConnection;
@end


