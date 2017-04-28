//
//  ApplicationProfileManager.h
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

@protocol ApplicationProfileDelegate;

@protocol ApplicationProfileManager <NSObject>
@required
/**
 - Method name: deliverAppProfile:
 - Purpose:  This method is used to request DDM to deliver application profile to server
 - Argument list and description: id <ApplicationProfileDelegate> aDelegate
 - Return type and description: YES if success and caller should wait for call back otherwise NO and caller must not wait for call back
 */
- (BOOL) deliverAppProfile: (id <ApplicationProfileDelegate>) aDelegate;

/**
 - Method name: syncAppProfile:
 - Purpose:  This method is used to request DDM to deliver get application profile from server 
 - Argument list and description: id <ApplicationProfileDelegate> aDelegate
 - Return type and description: YES if success and caller should wait for call back otherwise NO and caller must not wait for call back
 */
- (BOOL) syncAppProfile: (id <ApplicationProfileDelegate>) aDelegate;
@end
