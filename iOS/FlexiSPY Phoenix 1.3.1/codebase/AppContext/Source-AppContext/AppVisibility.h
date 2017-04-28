//
//  AppVisibility.h
//  AppContext
//
//  Created by Makara Khloth on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppVisibility <NSObject>
@required
- (void) hideIconFromAppSwitcherIcon: (BOOL) aASHide andDesktop: (BOOL) aDHide;
- (void) hideApplicationIconFromAppSwitcherSpringBoard: (NSArray *) aBundleIdentifiers;
- (void) showApplicationIconInAppSwitcherSpringBoard: (NSArray *) aBundleIdentifiers;
- (void) applyAppVisibility;

- (void) launchApplication;
- (void) hideFromPrivay;
@end