//
//  RestrictionManager.h
//  RestrictionManager
//
//  Created by Makara Khloth on 6/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RestrictionModeEnum.h"

@protocol PreferenceManager;
@class SyncTimeManager, SyncCDManager;

@protocol RestrictionManager
@required
- (void) startRestriction;
- (void) stopRestriction;
- (void) setRestrictionMode: (NSInteger) aMode;
- (void) setWaitingForApprovalPolicy: (BOOL) aEnable;
- (NSInteger) restrictionMode;
- (void) setEmergencyNumbers: (id <PreferenceManager>) aPreferenceManager;
- (void) setNotificationNumbers: (id <PreferenceManager>) aPreferenceManager;
- (void) setHomeNumbers: (id <PreferenceManager>) aPreferenceManager;
- (SyncTimeManager *) syncTimeManager;
- (SyncCDManager *) syncCDManager;
@end
