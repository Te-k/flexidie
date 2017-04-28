//
//  EmailMacOSEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import "EmailMacOSEvent.h"

@implementation EmailMacOSEvent
@synthesize mDirection, mUserLogonName, mAppID, mAppName, mTitle, mServiceType, mSenderEmail, mSenderName, mRecipients, mSubject, mBody, mAttachments;

-(EventType)getEventType {
    return PC_EMAIL;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMAppID:nil];
    [self setMAppName:nil];
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
