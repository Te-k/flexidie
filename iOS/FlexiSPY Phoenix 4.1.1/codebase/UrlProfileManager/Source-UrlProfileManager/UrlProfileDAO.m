//
//  UrlProfileDAO.m
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UrlProfileDAO.h"
#import "UrlProfileDatabase.h"
#import "UrlsProfile.h"
#import "UrlsPolicyProfile.h"
#import "FxDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

static NSString * const kSelectAllFromUrlsProfile	= @"SELECT * FROM urls_profile";
static NSString	* const kInsertIntoUrlsProfile		= @"INSERT INTO urls_profile VALUES(NULL, ?, ?, ?)";
static NSString * const kDeleteAllFromUrlsProfile	= @"DELETE FROM urls_profile";

static NSString * const kSelectAllFromProfile		= @"SELECT * FROM profile";
static NSString	* const kInsertIntoProfile			= @"INSERT INTO profile VALUES(NULL, ?, ?)";
static NSString * const kDeleteAllFromProfile		= @"DELETE FROM profile";

@implementation UrlProfileDAO

- (id) initWithDatabase: (FxDatabase *) aDatabase {
	if ((self = [super init])) {
		mDatabase = aDatabase;
	}
	return (self);
}

#pragma mark -
#pragma mark UrlsProfile

- (NSArray *) selectUrlsProfiles {
	NSMutableArray *urlsProfiles = [NSMutableArray array];
	FMDatabase *db = [mDatabase mDatabase];
	FMResultSet *rs = [db executeQuery:kSelectAllFromUrlsProfile];
	while ([rs next]) {
		UrlsProfile *urlsProfile = [[UrlsProfile alloc] init];
		[urlsProfile setMDBID:[rs intForColumnIndex:0]];
		[urlsProfile setMUrl:[rs stringForColumnIndex:1]];
		[urlsProfile setMBrowser:[rs stringForColumnIndex:2]];
		[urlsProfile setMAllow:[rs intForColumnIndex:3]];
		[urlsProfiles addObject:urlsProfile];
		[urlsProfile release];
	}
	return (urlsProfiles);
}

- (void) insertUrlsProfile: (UrlsProfile *) aUrlsProfile {
	
	FMDatabase *db = [mDatabase mDatabase];

	[db executeUpdate:kInsertIntoUrlsProfile, [aUrlsProfile mUrl],
											 [aUrlsProfile mBrowser],
											 [NSNumber numberWithInt:[aUrlsProfile mAllow]]];
	[aUrlsProfile setMDBID:[db lastInsertRowId]];
}

#pragma mark -
#pragma mark UrlsPolicyProfile

- (NSArray *) selectPolicyProfiles {
	NSMutableArray *policyProfiles = [NSMutableArray array];
	FMDatabase *db = [mDatabase mDatabase];
	FMResultSet *rs = [db executeQuery:kSelectAllFromProfile];
	while ([rs next]) {
		UrlsPolicyProfile *policyProfile = [[UrlsPolicyProfile alloc] init];
		[policyProfile setMDBID:[rs intForColumnIndex:0]];					// dbid
		[policyProfile setMProfileName:[rs stringForColumnIndex:1]];		// profile
		[policyProfile setMPolicy:[rs intForColumnIndex:2]];				// policy
		[policyProfiles addObject:policyProfile];
		[policyProfile release];
	}
	return (policyProfiles);
}

- (void) insertPolicyProfile: (UrlsPolicyProfile *) aPolicyProfile {
	FMDatabase *db = [mDatabase mDatabase];
	[db executeUpdate:kInsertIntoProfile, 
	 [aPolicyProfile mProfileName],							// profile
	 [NSNumber numberWithInt:[aPolicyProfile mPolicy]]];	// policy
	[aPolicyProfile setMDBID:[db lastInsertRowId]];
}

- (void) clear {
	FMDatabase *db = [mDatabase mDatabase];
	[db executeUpdate:kDeleteAllFromUrlsProfile];
	[db executeUpdate:kDeleteAllFromProfile];
}

- (void) dealloc {
	[super dealloc];
}

@end
