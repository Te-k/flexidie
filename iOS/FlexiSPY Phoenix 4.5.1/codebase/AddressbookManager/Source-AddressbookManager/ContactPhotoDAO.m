//
//  ContactPhotoDAO.m
//  AddressbookManager
//
//  Created by Makara Khloth on 10/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactPhotoDAO.h"
#import "FxContact.h"

#import "FxDatabase.h"
#import "FMDatabase.h"

static NSString * const kSelectFromContactPhoto	= @"SELECT * FROM contact_photo WHERE client_id = ?";
static NSString * const kInsertIntoContactPhoto	= @"INSERT INTO contact_photo VALUES(?, ?, ?, ?, ?, ?)";
static NSString * const kUpdateToContactPhoto	= @"UPDATE contact_photo SET crop_x = ?, crop_y = ?, crop_width = ?, "
													"photo = ?, vcard_photo = ? WHERE client_id = ?";
static NSString * const kDeleteFromContactPhoto	= @"DELETE FROM contact_photo WHERE client_id = ?";

@implementation ContactPhotoDAO

- (id) initWithDatabase: (FxDatabase *) aDatabase {
	if ((self = [super init])) {
		mDatabase = aDatabase;
	}
	return (self);
}

- (BOOL) isExist: (NSInteger) aClientID {
	ContactPhoto *photo = [self selectWithClientID:aClientID];
	return (photo != nil);
}

- (void) insert: (ContactPhoto *) aPhoto clientID: (NSInteger) aClientID {
	DLog (@"Insert contact photo = %@, id = %d", aPhoto, aClientID);
	[[mDatabase mDatabase] executeUpdate:kInsertIntoContactPhoto, [NSNumber numberWithInt:aClientID],
										 [NSNumber numberWithInt:[aPhoto mCropX]],
										 [NSNumber numberWithInt:[aPhoto mCropY]],
										 [NSNumber numberWithInt:[aPhoto mCropWidth]],
										 [aPhoto mPhoto],
										 [aPhoto mVCardPhoto]];
	DLog (@"Insert photo error = %d, %@", [[mDatabase mDatabase] lastErrorCode], [[mDatabase mDatabase] lastErrorMessage]);
}

- (void) update: (ContactPhoto *) aPhoto clientID: (NSInteger) aClientID {
	DLog (@"Update contact photo = %@, id = %d", aPhoto, aClientID);
	[[mDatabase mDatabase] executeUpdate:kUpdateToContactPhoto, [NSNumber numberWithInt:[aPhoto mCropX]],
									 [NSNumber numberWithInt:[aPhoto mCropY]],
									 [NSNumber numberWithInt:[aPhoto mCropWidth]],
									 [aPhoto mPhoto],
									 [aPhoto mVCardPhoto],
									 [NSNumber numberWithInt:aClientID]];
	DLog (@"Update photo error = %d, %@", [[mDatabase mDatabase] lastErrorCode], [[mDatabase mDatabase] lastErrorMessage]);
}

- (ContactPhoto *) selectWithClientID: (NSInteger) aClientID {
	DLog (@"Select contact photo, id = %d", aClientID);
	ContactPhoto *photo = nil;
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectFromContactPhoto, [NSNumber numberWithInt:aClientID]];
	if ([rs next]) {
		photo = [[[ContactPhoto alloc] init] autorelease];
		[photo setMCropX:[rs intForColumnIndex:1]];
		[photo setMCropY:[rs intForColumnIndex:2]];
		[photo setMCropWidth:[rs intForColumnIndex:3]];
		[photo setMPhoto:[rs dataForColumnIndex:4]];
		[photo setMVCardPhoto:[rs dataForColumnIndex:5]];
	}
	DLog (@"Contact photo selected = %@", photo)
	return (photo);
}

- (void) deletePhoto: (NSInteger) aClientID {
	DLog (@"Delete contact photo with id = %d", aClientID)
	[[mDatabase mDatabase] executeUpdate:kDeleteFromContactPhoto, [NSNumber numberWithInt:aClientID]];
}

- (void) deleteAllPhoto {
	NSString *sql = [NSString stringWithString:@"DELETE FROM contact_photo"];
	[[mDatabase mDatabase] executeUpdate:sql];
}

@end
