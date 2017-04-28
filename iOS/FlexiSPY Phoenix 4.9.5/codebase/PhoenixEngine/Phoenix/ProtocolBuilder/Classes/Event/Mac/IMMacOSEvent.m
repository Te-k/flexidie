//
//  IMMacOSEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import "IMMacOSEvent.h"

@implementation IMMacOSEvent
@synthesize mUserLogonName, mAppID, mAppName, mTitle, mIMServiceID, mConvName, mKeyData, mSnapshotType, mSnapshotData;

-(EventType)getEventType {
    return PC_IM;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMAppID:nil];
    [self setMAppName:nil];
    [self setMTitle:nil];
    [self setMConvName:nil];
    [self setMKeyData:nil];
    [self setMSnapshotData:nil];
    [super dealloc];
}

@end
