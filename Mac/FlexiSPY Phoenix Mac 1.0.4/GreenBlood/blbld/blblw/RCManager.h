//
//  RCManager.h
//  blbld
//
//  Created by Makara Khloth on 10/12/16.
//
//

#import <Foundation/Foundation.h>

#import "RemoteCommandPush.h"

@class PushNotificationManager;

@protocol PhoneInfo;

@interface RCManager : NSObject <RemoteCommandPush> {
    
}

@property (nonatomic, copy) NSString *pushServerUrl;
@property (nonatomic, assign) int pushServerPort;

@property (nonatomic, readonly) PushNotificationManager *pushNotificationManager;
@property (nonatomic, assign) id <PhoneInfo> macInfo;

- (void) start;
- (void) stop;

@end
