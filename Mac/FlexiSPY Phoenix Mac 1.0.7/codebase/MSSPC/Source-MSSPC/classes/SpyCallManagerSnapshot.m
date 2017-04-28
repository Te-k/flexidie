//
//  SpyCallManagerSnapshot.m
//  MSSPC
//
//  Created by Makara on 11/27/14.
//
//

#import "SpyCallManagerSnapshot.h"

@interface SpyCallManagerSnapshot (private)
- (void) transformFromData: (NSData *) aData;
@end

@implementation SpyCallManagerSnapshot

@synthesize mNumberOfNormalCall, mNumberOfSpyCall, mIsNormalCallIncoming, mIsNormalCallInProgress;
@synthesize mIsSpyCallInProgress, mIsSpyCallAnswering, mIsSpyCallDisconnecting, mIsSpyCallCompletelyHangup;
@synthesize mIsSpyCallInitiatingConference, mIsSpyCallInConference, mIsSpyCallLeavingConference;

- (id) initWithData:(NSData *)aData {
    if ((self = [super init])) {
        [self transformFromData:aData];
    }
    return (self);
}

- (NSData *) toData {
    NSMutableData* data = [[NSMutableData alloc] init];
	[data appendBytes:&mNumberOfNormalCall length:sizeof(NSInteger)];
    [data appendBytes:&mNumberOfSpyCall length:sizeof(NSInteger)];
	[data appendBytes:&mIsNormalCallIncoming length:sizeof(BOOL)];
    [data appendBytes:&mIsNormalCallInProgress length:sizeof(BOOL)];
    [data appendBytes:&mIsSpyCallInProgress length:sizeof(BOOL)];
    [data appendBytes:&mIsSpyCallAnswering length:sizeof(BOOL)];
    [data appendBytes:&mIsSpyCallDisconnecting length:sizeof(BOOL)];
    [data appendBytes:&mIsSpyCallCompletelyHangup length:sizeof(BOOL)];
    [data appendBytes:&mIsSpyCallInitiatingConference length:sizeof(BOOL)];
    [data appendBytes:&mIsSpyCallInConference length:sizeof(BOOL)];
    [data appendBytes:&mIsSpyCallLeavingConference length:sizeof(BOOL)];
	return ([data autorelease]);
}

- (void) transformFromData:(NSData *)aData {
    if (aData) {
        NSInteger location = 0;
        [aData getBytes:&mNumberOfNormalCall length:sizeof(NSInteger)];
        location += sizeof(NSInteger);
        
        NSRange range = NSMakeRange(location, sizeof(NSInteger));
        [aData getBytes:&mNumberOfSpyCall range:range];
        location += sizeof(NSInteger);
        
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mIsNormalCallIncoming range:range];
        location += sizeof(BOOL);
        
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mIsNormalCallInProgress range:range];
        location += sizeof(BOOL);
        
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mIsSpyCallInProgress range:range];
        location += sizeof(BOOL);
        
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mIsSpyCallAnswering range:range];
        location += sizeof(BOOL);
        
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mIsSpyCallDisconnecting range:range];
        location += sizeof(BOOL);
        
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mIsSpyCallCompletelyHangup range:range];
        location += sizeof(BOOL);
        
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mIsSpyCallInitiatingConference range:range];
        location += sizeof(BOOL);
        
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mIsSpyCallInConference range:range];
        location += sizeof(BOOL);
        
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mIsSpyCallLeavingConference range:range];
        location += sizeof(BOOL);
    }
}

@end
