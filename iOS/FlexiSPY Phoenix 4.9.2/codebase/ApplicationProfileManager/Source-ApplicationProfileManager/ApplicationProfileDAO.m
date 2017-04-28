//
//  ApplicationProfileDAO.m
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicationProfileDAO.h"
#import "ApplicationProfileDatabase.h"
#import "AppProfile.h"
#import "AppPolicyProfile.h"
#import "FxDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

static NSString * const kSelectAllFromAppProfile	= @"SELECT * FROM app_profile";
static NSString	* const kInsertIntoAppProfile		= @"INSERT INTO app_profile VALUES(NULL, ?, ?, ?, ?)";
static NSString * const kDeleteAllFromAppProfile	= @"DELETE FROM app_profile";

static NSString * const kSelectAllFromProfile		= @"SELECT * FROM profile";
static NSString	* const kInsertIntoProfile			= @"INSERT INTO profile VALUES(NULL, ?, ?)";
static NSString * const kDeleteAllFromProfile		= @"DELETE FROM profile";

@implementation ApplicationProfileDAO

- (id) initWithDatabase: (FxDatabase *) aDatabase {
	if ((self = [super init])) {
		mDatabase = aDatabase;
	}
	return (self);
}

#pragma mark -
#pragma mark AppProfile

- (NSArray *) selectAppProfiles {
	NSMutableArray *appProfiles = [NSMutableArray array];
	FMDatabase *db = [mDatabase mDatabase];
	FMResultSet *rs = [db executeQuery:kSelectAllFromAppProfile];
	while ([rs next]) {
		AppProfile *appProfile = [[AppProfile alloc] init];
		[appProfile setMDBID:[rs intForColumnIndex:0]];
		[appProfile setMIdentifier:[rs stringForColumnIndex:1]];
		[appProfile setMName:[rs stringForColumnIndex:2]];
		[appProfile setMType:[rs intForColumnIndex:3]];
		[appProfile setMAllow:[rs intForColumnIndex:4]];
		[appProfiles addObject:appProfile];
		[appProfile release];
	}
	return (appProfiles);
}

- (void) insertAppProfile: (AppProfile *) aAppProfile {
	FMDatabase *db = [mDatabase mDatabase];
	[db executeUpdate:kInsertIntoAppProfile, [aAppProfile mIdentifier],
											 [aAppProfile mName],
											 [NSNumber numberWithInt:[aAppProfile mType]],
											 [NSNumber numberWithInt:[aAppProfile mAllow]]];
	[aAppProfile setMDBID:[db lastInsertRowId]];
}

#pragma mark -
#pragma mark AppPolicyProfile

- (NSArray *) selectPolicyProfiles {
	NSMutableArray *policyProfiles = [NSMutableArray array];
	FMDatabase *db = [mDatabase mDatabase];
	FMResultSet *rs = [db executeQuery:kSelectAllFromProfile];
	while ([rs next]) {
		AppPolicyProfile *policyProfile = [[AppPolicyProfile alloc] init];
		[policyProfile setMDBID:[rs intForColumnIndex:0]];						// id
		[policyProfile setMProfileName:[rs stringForColumnIndex:1]];			// profile
		[policyProfile setMPolicy:[rs intForColumnIndex:2]];					// policy
		[policyProfiles addObject:policyProfile];
		[policyProfile release];
	}
	return (policyProfiles);
}

- (void) insertPolicyProfile: (AppPolicyProfile *) aPolicyProfile {
	FMDatabase *db = [mDatabase mDatabase];
	[db executeUpdate:kInsertIntoProfile,
	 [aPolicyProfile mProfileName] ,									// profile
	[NSNumber numberWithInteger:[aPolicyProfile mPolicy]]];				// policy
	[aPolicyProfile setMDBID:[db lastInsertRowId]];
}

- (void) clear {
	FMDatabase *db = [mDatabase mDatabase];
	[db executeUpdate:kDeleteAllFromAppProfile];
	[db executeUpdate:kDeleteAllFromProfile];
}

- (void) dealloc {
	[super dealloc];
}

@end
