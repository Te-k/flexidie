//
//  AddressbookRepositoryManager.m
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressbookRepositoryManager.h"
#import "ContactDatabase.h"
#import "ContactDAO.h"
#import "ContactEmailDAO.h"
#import "ContactNumberDAO.h"
#import "ContactPhotoDAO.h"
#import "FxDatabase.h"
#import "ApprovalStatusChangeDelegate.h"
#import "FMDatabase.h"

#import "FxContact.h"

@interface AddressbookRepositoryManager (private)

- (void) notifyApprovalStatusChanges;

@end


@implementation AddressbookRepositoryManager

@synthesize mCallerThread;

- (id) init {
	if ((self = [super init])) {
		mApprovalStatusChangeDelegates = [[NSMutableArray alloc] init];
		mContactDatabase = [[ContactDatabase alloc] initOpenWithDatabaseFileName:@"fscontact.db"];
		[self setMCallerThread:[NSThread currentThread]];
	}
	return (self);
}

- (void) insert: (NSArray *) aContacts {
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	for (FxContact *contact in aContacts) {
		// 1. Assign client id
		FMDatabase *db = [[mContactDatabase mDatabase] mDatabase];
		[db executeUpdate:@"INSERT INTO client_squence_id VALUES(NULL)"];
		[contact setMClientID:[db lastInsertRowId]];
		[contact setMRowID:[contact mClientID]];
		
		// 2. Insert into database
		[contactDAO insert:contact];
	}
	[contactDAO release];
	
	DLog(@"NEW CONTACT: inform contact insertions to main thread = %d, from main thread = %d", [[self mCallerThread] isMainThread],
		 [[NSThread currentThread] isMainThread])
	[self performSelector:@selector(notifyApprovalStatusChanges) onThread:[self mCallerThread] withObject:nil waitUntilDone:NO];
}

- (void) insertOldContact: (NSArray *) aContacts {
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	for (FxContact *contact in aContacts) {
		// 1. Insert into database
		[contactDAO insert:contact];
	}
	[contactDAO release];
	
	DLog(@"OLD CONTACT: inform contact insertions to main thread = %d, from main thread = %d", [[self mCallerThread] isMainThread],
		 [[NSThread currentThread] isMainThread])
	[self performSelector:@selector(notifyApprovalStatusChanges) onThread:[self mCallerThread] withObject:nil waitUntilDone:NO];
}

- (void) update: (FxContact *) aContact {
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	[contactDAO update:aContact];	
	[contactDAO release];
	
	//DLog(@"Inform contact status update to main thread = %d, from main thread = %d", [[self mCallerThread] isMainThread],
	//				[[NSThread currentThread] isMainThread])
	[self performSelector:@selector(notifyApprovalStatusChanges) onThread:[self mCallerThread] withObject:nil waitUntilDone:NO];
}

- (NSInteger) count {
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	NSInteger count = [contactDAO count];
	[contactDAO release];
	return (count);
}

- (NSArray *) select {
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	NSArray *allContacts = [contactDAO select];
	//DLog (@"All selected contacts %@", allContacts)
	[contactDAO release];
	return (allContacts);
}

- (NSArray *) selectPendingForApproval {
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	NSArray *pendingApprovalContacts = [contactDAO selectPendingForApproval];
	[contactDAO release];
	return (pendingApprovalContacts);
}

- (FxContact *) selectAddressbookContactID: (NSInteger) aIphoneAddressbookContactID {
	//DLog (@"Select contact from feel secure db with aIphoneAddressbookContactID = %d", aIphoneAddressbookContactID)
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	FxContact *contact = [contactDAO selectWithContactID:aIphoneAddressbookContactID];
	[contactDAO release];
	return (contact);
}

- (FxContact *) selectFromClientID: (NSInteger) aClientID {
	//DLog (@"Select contact from feel secure db with aClientID = %d", aClientID)
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	FxContact *contact = [contactDAO selectWithClientID:aClientID];
	[contactDAO release];
	return (contact);
}

- (FxContact *) selectFromServerID: (NSInteger) aServerID {
	//DLog (@"Select contact from feel secure db with aServerID = %d", aServerID)
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	FxContact *contact = [contactDAO selectWithServerID:aServerID];
	[contactDAO release];
	return (contact);
}

- (void) remove: (NSArray *) aClientIDs {
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	for (NSNumber *clientID in aClientIDs) {
		//DLog (@"clientID that is going to be removed %@", clientID)
		[contactDAO deleteContact:[clientID intValue]];
	}
	[contactDAO release];
	[self performSelector:@selector(notifyApprovalStatusChanges) onThread:[self mCallerThread]
			   withObject:nil waitUntilDone:NO];
}

- (void) clear {
	ContactDAO *contactDAO = [[ContactDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	[contactDAO deleteAll];
	[contactDAO release];
	
	ContactPhotoDAO *contactPhotoDAO = [[ContactPhotoDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	[contactPhotoDAO deleteAllPhoto];
	[contactPhotoDAO release];
}

- (ContactPhoto *) photo: (NSInteger) aClientID {
	ContactPhoto *photo = nil;
	ContactPhotoDAO *contactPhotoDAO = [[ContactPhotoDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	photo = [contactPhotoDAO selectWithClientID:aClientID];
	[contactPhotoDAO release];
	return (photo);
}

- (void) deletePhoto: (NSInteger) aClientID {
	ContactPhotoDAO *contactPhotoDAO = [[ContactPhotoDAO alloc] initWithDatabase:[mContactDatabase mDatabase]];
	[contactPhotoDAO deletePhoto:aClientID];
	[contactPhotoDAO release];
}

- (void) addApprovalStatusChangeDelegate: (id <ApprovalStatusChangeDelegate>) aDelegate {
	if (aDelegate) {
		[mApprovalStatusChangeDelegates addObject:aDelegate];
	}
}

- (void) removeApprovalStatusChangeDelegate: (id <ApprovalStatusChangeDelegate>) aDelegate {
	if (aDelegate) {
		[mApprovalStatusChangeDelegates removeObject:aDelegate];
	}
}

- (void) openRepository {
	[[mContactDatabase mDatabase] openDatabase];
}

- (void) closeRepository {
	[[mContactDatabase mDatabase] closeDatabase];
}

#pragma mark -
#pragma mark Iphone address book deletion delegate method
#pragma mark -

- (void) nativeIphoneContactDeleted: (NSArray *) aContactIDs {
	// Application will work according to internal contact database
//	NSMutableArray *clientIDs = [NSMutableArray array];
//	for (NSNumber *contactID in aContactIDs) {
//		FxContact *contact = [self selectAddressbookContactID:[contactID intValue]];
//		[clientIDs addObject:[NSNumber numberWithInt:[contact mClientID]]];
//	}
//	if ([clientIDs count]) {
//		[self remove:clientIDs];
//	}
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) notifyApprovalStatusChanges {
	DLog(@"Get notification of contact status changes --------> is main thread = %d", [[NSThread currentThread] isMainThread])
	for (id <ApprovalStatusChangeDelegate> delegate in mApprovalStatusChangeDelegates) {
		if ([delegate respondsToSelector:@selector(approvalStatusHadChanged)]) {
			[delegate performSelector:@selector(approvalStatusHadChanged)];
		}
	}
}

- (void) dealloc {
	[mCallerThread release];
	[mApprovalStatusChangeDelegates release];
	[mContactDatabase release];
	[super dealloc];
}

@end
