//
//  FileTransferEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import "FileTransferEvent.h"

@implementation FileTransferEvent
@synthesize mDirection, mUserLogonName, mAppID, mAppName, mTitle, mType, mSPath, mDPath, mFileName, mFileSize;

-(EventType)getEventType {
    return FILE_TRANSFER;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMAppID:nil];
    [self setMAppName:nil];
    [self setMTitle:nil];
    [self setMSPath:nil];
    [self setMDPath:nil];
    [self setMFileName:nil];
    [super dealloc];
}

@end
