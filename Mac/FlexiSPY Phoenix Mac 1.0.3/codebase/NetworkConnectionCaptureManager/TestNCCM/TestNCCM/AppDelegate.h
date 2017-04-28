//
//  AppDelegate.h
//  TestNCCM
//
//  Created by ophat on 7/10/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NetworkConnectionCaptureManager.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>{
NetworkConnectionCaptureManager * mNCM;
}

@property (nonatomic,retain) NetworkConnectionCaptureManager * mNCM;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@end

