//
//  UsbEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import "UsbEvent.h"

@implementation UsbEvent
@synthesize mUserLogonName, mAppID, mAppName, mTitle, mAction, mType, mName;

-(EventType)getEventType {
    return USB;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMAppID:nil];
    [self setMAppName:nil];
    [self setMTitle:nil];
    [self setMName:nil];
    [super dealloc];
}

@end
