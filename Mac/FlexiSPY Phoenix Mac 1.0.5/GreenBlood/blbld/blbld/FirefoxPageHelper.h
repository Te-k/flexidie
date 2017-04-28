//
//  FirefoxPageHelper.h
//  blbld
//
//  Created by Makara Khloth on 11/15/16.
//
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@interface FirefoxPageHelper : NSObject <MessagePortIPCDelegate> {
    NSString *mCurrentTitle;
    NSString *mCurrentUrl;
    pid_t mPID;
    
    MessagePortIPCReader *mMessagePort;
}

@property (copy) NSString *mCurrentTitle;
@property (copy) NSString *mCurrentUrl;
@property (assign) pid_t mPID;

@property (retain) MessagePortIPCReader *mMessagePort;

+ (instancetype) sharedHelper;

@end
