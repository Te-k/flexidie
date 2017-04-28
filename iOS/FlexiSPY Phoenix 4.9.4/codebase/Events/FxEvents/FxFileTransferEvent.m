//
//  FxFileTransferEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import "FxFileTransferEvent.h"

@implementation FxFileTransferEvent
@synthesize mDirection, mUserLogonName, mApplicationID, mApplicationName, mTitle;
@synthesize mTransferType, mSourcePath, mDestinationPath, mFileName, mFileSize;

- (id) init {
    self = [super init];
    if (self) {
        [self setEventType:kEventTypeFileTransfer];
    }
    return (self);
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    [self setMSourcePath:nil];
    [self setMDestinationPath:nil];
    [self setMFileName:nil];
    [super dealloc];
}

@end
