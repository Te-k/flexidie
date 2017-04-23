//
//  PolicyAppsProfileContainer.h
//  RestrictionManagerUtils
//
//  Created by Makara Khloth on 7/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppPolicyProfile;
@class AppProfile;

@interface PolicyAppsProfileContainer : NSObject {
@private
	AppPolicyProfile	*mAppPolicy;
	NSArray				*mProfiles; // AppProfile
}

@property (nonatomic, retain) AppPolicyProfile *mAppPolicy;
@property (nonatomic, retain) NSArray *mProfiles;

@end
