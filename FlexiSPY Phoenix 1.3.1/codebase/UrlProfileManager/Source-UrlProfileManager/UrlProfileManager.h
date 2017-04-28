//
//  UrlProfileManager.h
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UrlProfileDelegate;

@protocol UrlProfileManager <NSObject>
@required
/**
 - Method name: deliverUrlProfile:
 - Purpose:  This method is used to request DDM to deliver urls profile to server
 - Argument list and description: id <UrlProfileDelegate> aDelegate
 - Return type and description: YES if success and caller should wait for call back otherwise NO and caller must not wait for call back
 */
- (BOOL) deliverUrlProfile: (id <UrlProfileDelegate>) aDelegate;

/**
 - Method name: syncUrlProfile:
 - Purpose:  This method is used to request DDM to deliver get urls profile from server 
 - Argument list and description: id <UrlProfileDelegate> aDelegate
 - Return type and description: YES if success and caller should wait for call back otherwise NO and caller must not wait for call back
 */
- (BOOL) syncUrlProfile: (id <UrlProfileDelegate>) aDelegate;
@end
