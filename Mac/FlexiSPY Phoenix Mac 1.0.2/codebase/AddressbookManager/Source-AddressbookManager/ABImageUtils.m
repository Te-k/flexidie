//
//  ABImageUtils.m
//  AddressbookManager
//
//  Created by Makara Khloth on 10/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ABImageUtils.h"
#import "FxContact.h"
#import "FMDatabase.h"

static NSString * const kAddressBookImageDatabasePath	= @"/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb";

@implementation ABImageUtils

+ (ContactPhoto *) contactPhotoFillLargePhoto: (NSInteger) aContactID {
	DLog (@"Contact photo for contact id = %d", aContactID)
	ContactPhoto *photo = [[[ContactPhoto alloc] init] autorelease];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:kAddressBookImageDatabasePath]) {
		DLog(@"File database for enlarge photo is exist");
		FMDatabase *db = [FMDatabase databaseWithPath:kAddressBookImageDatabasePath];
		[db open];
		NSString *sql = [NSString stringWithFormat:@"select * from ABFullSizeImage where record_id = %d", aContactID];
		FMResultSet *rs = [db executeQuery:sql];
		if ([rs next]) {
			[photo setMCropX:[rs intForColumnIndex:2]];
			[photo setMCropY:[rs intForColumnIndex:3]];
			[photo setMCropWidth:[rs intForColumnIndex:4]];
			[photo setMPhoto:[rs dataForColumnIndex:5]];
		}
		DLog (@"Database error = %d, err.string = %@", [db lastErrorCode], [db lastErrorMessage])
		[db close];
	}
	//DLog(@"Contact photo from database, large photo = %@", [photo mPhoto])
	return (photo);
}

+ (void) saveContactLargePhotoIfNotExist: (ContactPhoto *) aPhoto contactID: (NSInteger) aContactID {
	DLog(@"Save contact photo to database = %@, id = %d", aPhoto, aContactID)
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:kAddressBookImageDatabasePath]) {
		DLog(@"File database for enlarge photo is exist");
		FMDatabase *db = [FMDatabase databaseWithPath:kAddressBookImageDatabasePath];
		[db open];
		NSString *sql = [NSString stringWithFormat:@"select * from ABFullSizeImage where record_id = %d", aContactID];
		FMResultSet *rs = [db executeQuery:sql];
		if ([rs next]) { // Already exist thus just make update
			DLog (@"Update existing large photo with fs photo");
			sql = [NSString stringWithFormat:@"update ABFullSizeImage set crop_x = ?, crop_y = ?, crop_width = ?, "
				   "data = ? where record_id = %d", aContactID];
			[db executeUpdate:sql, [NSNumber numberWithInt:[aPhoto mCropX]],
							 [NSNumber numberWithInt:[aPhoto mCropY]],
							 [NSNumber numberWithInt:[aPhoto mCropWidth]],
							 [aPhoto mPhoto]];
		} else { // Not yet exist thus create new one
			DLog (@"Add new large photo from fs photo");
			sql = [NSString stringWithFormat:@"insert into ABFullSizeImage values(NULL, ?, ?, ?, ?)"];
			[db executeUpdate:sql, [NSNumber numberWithInt:aContactID],
							 [NSNumber numberWithInt:[aPhoto mCropX]],
							 [NSNumber numberWithInt:[aPhoto mCropY]],
							 [NSNumber numberWithInt:[aPhoto mCropWidth]],
							 [aPhoto mPhoto]];
		}
		DLog (@"Database error = %d, err.string = %@", [db lastErrorCode], [db lastErrorMessage])
		[db close];
	}
}

@end
