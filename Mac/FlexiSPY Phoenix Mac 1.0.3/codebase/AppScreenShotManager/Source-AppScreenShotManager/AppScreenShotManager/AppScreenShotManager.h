//
//  AppScreenShotDelegate.h
//  AppScreenShotManager
//
//  Created by ophat on 4/4/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

@protocol AppScreenShotDelegate <NSObject>
@optional
- (void) requestAppScreenShotRuleCompleted: (NSError *) aError;
@end

@protocol AppScreenShotManager <NSObject>
@optional
- (BOOL) requestAppScreenShotRule: (id <AppScreenShotDelegate>) aDelegate;
@end

