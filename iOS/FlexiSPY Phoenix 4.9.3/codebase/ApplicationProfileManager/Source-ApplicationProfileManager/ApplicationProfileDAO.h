//
//  ApplicationProfileDAO.h
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase, AppProfile, AppPolicyProfile;

@interface ApplicationProfileDAO : NSObject {
@private
	FxDatabase	*mDatabase; // Not own
}

- (id) initWithDatabase: (FxDatabase *) aDatabase;

- (NSArray *) selectAppProfiles;
- (void) insertAppProfile: (AppProfile *) aAppProfile;

- (NSArray *) selectPolicyProfiles;
- (void) insertPolicyProfile: (AppPolicyProfile *) aPolicyProfile;

- (void) clear;

@end
