//
//  CTCall.h
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// Declarartions
#define CALL_NOTIFICATION_STATUS_INPROGRESS 1
#define CALL_NOTIFICATION_STATUS_ONHOLD 2
#define CALL_NOTIFICATION_STATUS_OUTGOING 3
#define CALL_NOTIFICATION_STATUS_INCOMING 4
#define CALL_NOTIFICATION_STATUS_TERMINATED 5


typedef struct __CTCall CTCall;
NSString *CTCallCopyAddress(void *, CTCall *);
NSString *CTCallAnswer(CTCall *);
NSString *CTCallJoinConference(CTCall *);
NSString *CTCallHold(CTCall *);
NSString *CTCallResume(CTCall *);
NSString *CTCallDisconnect(CTCall *);
BOOL CTCallIsOutgoing(CTCall *);