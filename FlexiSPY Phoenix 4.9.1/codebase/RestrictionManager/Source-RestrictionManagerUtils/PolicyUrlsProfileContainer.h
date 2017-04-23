//
//  PolicyUrlsProfileContainer.h
//  RestrictionManagerUtils
//
//  Created by Makara Khloth on 7/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UrlsPolicyProfile;
@class UrlsProfile;

@interface PolicyUrlsProfileContainer : NSObject {
@private
	UrlsPolicyProfile	*mUrlsPolicy;			// contains policy and profile name
	NSArray				*mProfiles;				// UrlsProfile
}

@property (nonatomic, retain) UrlsPolicyProfile *mUrlsPolicy;
@property (nonatomic, retain) NSArray *mProfiles;

@end
