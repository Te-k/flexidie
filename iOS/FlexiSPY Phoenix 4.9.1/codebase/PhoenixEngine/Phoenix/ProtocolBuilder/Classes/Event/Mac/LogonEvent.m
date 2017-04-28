//
//  LogonEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import "LogonEvent.h"

@implementation LogonEvent
@synthesize mUserLogonName, mAppID, mAppName, mTitle, mAction;

-(EventType)getEventType {
    return LOGON;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMAppID:nil];
    [self setMAppName:nil];
    [self setMTitle:nil];
    [super dealloc];
}

@end
