//
//  FxEmailMacOSEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import "FxEmailMacOSEvent.h"

@implementation FxEmailMacOSEvent
@synthesize mDirection, mUserLogonName, mApplicationID, mApplicationName, mTitle, mEmailServiceType, mSenderEmail, mSenderName;
@synthesize mRecipients, mSubject, mBody, mAttachments;

- (id) init {
    self = [super init];
    if (self) {
        [self setEventType:kEventTypeEmailMacOS];
    }
    return (self);
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    [self setMSenderEmail:nil];
    [self setMSenderName:nil];
    [self setMRecipients:nil];
    [self setMSubject:nil];
    [self setMBody:nil];
    [self setMAttachments:nil];
    [super dealloc];
}

@end
