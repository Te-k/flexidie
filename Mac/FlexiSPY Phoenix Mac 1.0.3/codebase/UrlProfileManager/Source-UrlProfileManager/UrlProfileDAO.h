//
//  UrlProfileDAO.h
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase, UrlsProfile, UrlsPolicyProfile;

@interface UrlProfileDAO : NSObject {
@private
	FxDatabase	*mDatabase; // Not own
}

- (id) initWithDatabase: (FxDatabase *) aDatabase;

- (NSArray *) selectUrlsProfiles;
- (void) insertUrlsProfile: (UrlsProfile *) aUrlsProfile;

- (NSArray *) selectPolicyProfiles;
- (void) insertPolicyProfile: (UrlsPolicyProfile *) aPolicyProfile;

- (void) clear;

@end
