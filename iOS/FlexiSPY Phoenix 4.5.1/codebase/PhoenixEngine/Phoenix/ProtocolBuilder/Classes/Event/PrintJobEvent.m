//
//  PrintJobEvent.m
//  ProtocolBuilder
//
//  Created by ophat on 11/16/15.
//
//

#import "PrintJobEvent.h"

@implementation PrintJobEvent
@synthesize mUserLogonName, mApplicationID,mApplicationName,mTitle,mJobID;
@synthesize mOwnerName,mPrinter,mDocumentName,mSubmitTime;
@synthesize mTotalPage, mTotalByte;
@synthesize mMimeType,mData;

-(EventType)getEventType {
    return PRINT_JOB;
}

-(void)dealloc{
    [mUserLogonName release];
    [mApplicationID release];
    [mApplicationName release];
    [mTitle release];
    [mJobID release];
    [mOwnerName release];
    [mPrinter release];
    [mDocumentName release];
    [mSubmitTime release]; 
    [mMimeType release];
    [mData release];
    [super dealloc];
}

@end
