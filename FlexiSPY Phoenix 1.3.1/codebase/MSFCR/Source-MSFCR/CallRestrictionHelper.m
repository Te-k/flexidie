//
//  CallRestrictionHelper.m
//  MSFCR
//
//  Created by Syam Sasidharan on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CallRestrictionHelper.h"
#import "RestrictionHeaders.h"
#import "Telephony.h"

@implementation CallRestrictionHelper

+ (NSString *) getNumber:(CTCall *) aCall {
    
    NSString *number = CTCallCopyAddress(nil, aCall);
    return number;
}

+ (NSInteger) getCallStatus:(CTCall *) aCall {
    
    NSInteger callStatus = CTCallGetStatus(aCall);
    return callStatus;
}

+ (BOOL) isOutgoingCall: (CTCall *) aCall {
    
    BOOL isOutgoingCall = NO;
    if ([CallRestrictionHelper getCallStatus:aCall] == CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DIALING) {
        
        isOutgoingCall = YES;
    }
    return isOutgoingCall;
}

+ (void) disconnectCall: (CTCall *) aCall {
    
    CTCallDisconnect(aCall);
}

@end
