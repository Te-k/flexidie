//
//  ApplicationLifeCycleDelegate.h
//  KeyboardLoggerManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MacTypes.h>

@class ApplicationInfo, EmbeddedApplicationInfo;

@protocol ApplicationLifeCycleDelegate <NSObject>

-(void) applicationDidEnterBackground:(ApplicationInfo *)aApplicationInfo;
-(void) applicationDidEnterForeground:(ApplicationInfo *)aApplicationInfo;

- (void) spotlightBeginTracking;
- (void) spotlightEndTracking;

- (void) launchpadDidAppear;
- (void) launchpadDidDisappear;

- (void) embeddedApplicationLaunched: (EmbeddedApplicationInfo *) aEmbededApplicationInfo;
- (void) embeddedApplicationTerminated: (EmbeddedApplicationInfo *) aEmbededApplicationInfo;
- (void) clearAllEmbeddedApplicationInfo;

- (void) carbonApplicationTerminated: (ProcessSerialNumber) aPSN; // 10.11

@end
