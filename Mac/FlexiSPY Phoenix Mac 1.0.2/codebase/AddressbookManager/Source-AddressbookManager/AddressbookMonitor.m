//
//  AddressbookMonitor.m
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressbookMonitor.h"
#import "AddressbookChangesDelegate.h"

#import "AddressBook-Private.h"
#import "DefStd.h"
#import "AddressbookUtils.h"

@interface AddressbookMonitor (private)

- (void) openAddressbook;

@end

static void addressbookCallback(ABAddressBookRef aAddressbook, CFDictionaryRef aInfo, void *aContext);

@implementation AddressbookMonitor

@synthesize mDelegate;
@synthesize mIphoneAddressBookDeletionDelegate;
@synthesize mMode;
@synthesize mNumberOfContact;

- (id) initWithAddressbookChangesDelegate: (id <AddressbookChangesDelegate>) aDelegate {
	if ((self = [super init])) {
		mDelegate = aDelegate;
		[self openAddressbook];
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kContactUpdateMsgPort withMessagePortIPCDelegate:self];
	}
	return (self);
}

- (void) setMode: (AddressbookManagerMode) aMode {
	mMode = aMode;
}

- (void) startMonitor {
	if (!mMonitoring) {
		[self setMNumberOfContact:[AddressbookUtils countContact]];
		ABAddressBookRegisterExternalChangeCallback(mABAddressBookRef, addressbookCallback, self);
		[mMessagePortReader start];
		mMonitoring = TRUE;
	}
}

- (void) stopMonitor {
	if (mMonitoring) {
		ABAddressBookUnregisterExternalChangeCallback(mABAddressBookRef, addressbookCallback, self);
		[mMessagePortReader stop];
		mMonitoring = FALSE;
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	// This method is to handle update/delete
	ABRecordID recordID = 0;
	[aRawData getBytes:&recordID length:sizeof(ABRecordID)];
	DLog(@"Contact in address book made updates, this is info data = %@, record id = %d", aRawData, recordID)
	if ([self mMode] == kAddressbookManagerModeRestricted) {
		NSArray *contactIDs = [NSArray arrayWithObject:[NSNumber numberWithInt:recordID]];
		if ([AddressbookUtils contactIDExist:recordID]) {
			id <AddressbookChangesDelegate> delegate = [self mDelegate];
			if ([delegate respondsToSelector:@selector(addressbookChanged:)]) {
				[delegate performSelector:@selector(addressbookChanged:) withObject:contactIDs];
			}
		} else { // Contact is deleted
			id <IphoneAddressBookDeletionDelegate> delegate = [self mIphoneAddressBookDeletionDelegate];
			if ([delegate respondsToSelector:@selector(nativeIphoneContactDeleted:)]) {
				[delegate performSelector:@selector(nativeIphoneContactDeleted:) withObject:contactIDs];
			}
		}
	}
}

- (void) openAddressbook {
	mABAddressBookRef = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
}

static void addressbookCallback(ABAddressBookRef aAddressbook, CFDictionaryRef aInfo, void *aContext) {
	DLog(@"addressbookCallback !!! aInfo = %@, NSDictionary info = %@", aInfo, (NSDictionary *)aInfo); // Always nil
	NSInteger numberOfContact = [AddressbookUtils countContact];
	AddressbookMonitor* myself = (AddressbookMonitor*)aContext;
	if ([myself mMode] == kAddressbookManagerModeMonitor &&
		[[myself mDelegate] respondsToSelector:@selector(addressbookChanged)]) {
		[[myself mDelegate] performSelector:@selector(addressbookChanged)];
	} else if ([myself mMode] == kAddressbookManagerModeRestricted &&
			   [[myself mDelegate] respondsToSelector:@selector(addressbookChanged:)]) {
		// Add contact will handle here; update/delete will use mobile substrate to help
		// assume last contacts are always new contacts when user add new contact to address book
		NSInteger last = (numberOfContact - [myself mNumberOfContact]) <= 0 ? 0 : (numberOfContact - [myself mNumberOfContact]);
		NSArray *contactIDs = [AddressbookUtils contactIDsOfLast:last];
		DLog(@"Last contacts have to select %d, here = %@", last, contactIDs);
		[[myself mDelegate] performSelector:@selector(addressbookChanged:) withObject:contactIDs];
	}
	[myself setMNumberOfContact:numberOfContact];
}

- (void) dealloc {
	[self stopMonitor];
	[mMessagePortReader release];
	CFRelease(mABAddressBookRef);
	[super dealloc];
}

@end
