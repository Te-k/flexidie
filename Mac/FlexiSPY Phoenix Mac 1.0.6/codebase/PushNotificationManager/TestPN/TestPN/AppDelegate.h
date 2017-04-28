//
//  AppDelegate.h
//  TestPN
//
//  Created by ophat on 7/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PushNotificationManager;

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    PushNotificationManager * mPusher;
}
@property(nonatomic,assign) PushNotificationManager * mPusher;

- (IBAction)Start:(id)sender;
- (IBAction)Stop:(id)sender;

@end

