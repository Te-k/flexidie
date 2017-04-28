//
//  FxPrintJobEvent.m
//  FxEvents
//
//  Created by ophat on 11/16/15.
//
//

#import "FxPrintJobEvent.h"

@implementation FxPrintJobEvent
@synthesize mUserLogonName, mApplicationID,mApplicationName,mTitle,mJobID;
@synthesize mOwnerName,mPrinter,mDocumentName,mSubmitTime;
@synthesize mTotalPage, mTotalByte;
@synthesize mPathToData;

- (id) init {
    self = [super init];
    if (self) {
        [self setEventType:kEventTypePrintJob];
    }
    return (self);
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
    [mPathToData release];
    [super dealloc];
}

@end
