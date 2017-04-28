//
//  FileActivityEvent.m
//  ProtocolBuilder
//
//  Created by ophat on 9/29/15.
//
//

#import "FileActivityEvent.h"

@implementation FileActivityEvent
@synthesize  mUserLogonName, mApplicationID, mApplicationName,mTitle;
@synthesize  mActivityType, mActivityFileType;
@synthesize  mActivityOwner, mDateCreated ,mDateModified, mDateAccessed;
@synthesize  mOriginalFile, mModifiedFile;

-(EventType)getEventType {
    return FILE_ACTIVITY;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMActivityOwner:nil];
    [self setMActivityType:nil];
    [self setMActivityFileType:nil];
    [self setMDateCreated:nil];
    [self setMDateModified:nil];
    [self setMDateAccessed:nil];
    [self setMOriginalFile:nil];
    [self setMModifiedFile:nil];
    [super dealloc];
}

@end
