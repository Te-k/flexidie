//
//  SendAddressbookForApprovalDataProvider.m
//  AddressbookManager
//
//  Created by Makara Khloth on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SendAddressbookForApprovalDataProvider.h"
#import "SendAddressBookForApproval.h"
#import "AddressbookRepository.h"
#import "AddressBook.h"
#import "FxVCard.h"
#import "AddressbookUtils.h"
#import "FxContact.h"
#import "Base64.h"

#import "DaemonPrivateHome.h"
#import "DefStd.h"
#import "ABVCardExporter.h"
#import "ABVCardRecord.h"
#import "AddressBook-Private.h"
#import "ABVCardParser.h"

#import <AddressBook/AddressBook.h>

@interface SendAddressbookForApprovalDataProvider (private)
- (NSString *) deliveredContactIDsPath;
- (void) saveDeliveredContactIDs: (NSArray *) aContactIDs;
- (NSArray *) loadDeliveredContactIDs;
- (NSArray *) associateClientIDs;
@end

@implementation SendAddressbookForApprovalDataProvider

@synthesize mContactIDs;
@synthesize mAssociateClientIDs;
@synthesize mVCardIndex;
@synthesize mAddressbookRepository;

@synthesize mDeliverClientIDs;

- (id) init {
	if ((self = [super init])) {
		mDeliverClientIDs = [[NSMutableArray alloc] initWithArray:[self loadDeliveredContactIDs]];
	}
	return (self);
}

- (id) commandDataSomeContactsForApproval {
	DLog (@"Number of contacts need to get approval = %@", [self mContactIDs])
	id sendAddressbookForApproval = [[SendAddressBookForApproval alloc] init];
	[self setMVCardIndex:0];
	NSMutableArray *array = [NSMutableArray array];
	AddressBook *addressbook = [[AddressBook alloc] init];
	[addressbook setVCardCount:[[self mContactIDs] count]];
	[addressbook setAddressBookID:1];
	[addressbook setAddressBookName:@"iPhone-Address book"];
	[addressbook setVCardProvider:self];
	[array addObject:addressbook];
	[addressbook release];
	[sendAddressbookForApproval setAddressBookList:array];
	[sendAddressbookForApproval autorelease];
	
	// Delete all contact ids that were delivered previously
	[mDeliverClientIDs removeAllObjects];
	
	// For back up logic which Iphone contact is deleted from Iphone address book then we use the corresponding one
	// in Feelsecure address book by using its associate client id
	[self setMAssociateClientIDs:[self associateClientIDs]];
	
	return (sendAddressbookForApproval);
}

- (id) getObject {
	DLog(@"getObject")
	ABAddressBookRef addressbook	= ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	ABRecordID recordID				= [[[self mContactIDs] objectAtIndex:mVCardIndex] intValue];
	ABRecordRef abRecord			= ABAddressBookGetPersonWithRecordID(addressbook, recordID);  // one record of address book
	
	//  Client id must exist, mean BEFORE send for approval contact must exist in fscontact.db
	FxContact *contact = [mAddressbookRepository selectAddressbookContactID:recordID];
	DLog (@"Contact from feel secure db, %@", contact);
	
	BOOL explicitlyCreateRecord = NO;
	if (!abRecord) {
		DLog (@"Contact cannot select from Iphone address book -1-")
		// Contact is deleted (after update/edit) or erase by synced address book command before this sending for approval command is executed
		
		
		// Obsolete flow
//		abRecord = ABPersonCreate(); // Create empty contact
//		explicitlyCreateRecord = YES;
		
		recordID = [[[self mAssociateClientIDs] objectAtIndex:mVCardIndex] intValue];
		abRecord = ABAddressBookGetPersonWithRecordID(addressbook, recordID);
		if (!abRecord) {
			DLog (@"Contact cannot select from feelsecure address book using associate client id")
			// Contact is delete (afer update/edit) by the user, thus create contact from feelsecure database
			
			abRecord = [AddressbookUtils copyABRecordFromFxContact:contact];
			explicitlyCreateRecord = YES;
		} else {
			DLog (@"Contact can select from feelsecure address book using associate client id")
			// Contact is erase by synced command thus abRecord is valid and synced with server, however sync this command need to proceed anyway
			// we have to update it status to waiting back
			
			if ([contact mApprovedStatus] == kApprovedContactStatus) {
				DLog (@"Contact synced is approved because synced command before it sent")
				/*
				 This could happen while waiting DDM for sending to server; but synced address book was execute first
				 cause the this contact may be approved by the server thus set back to waiting status...
				 */
				
				[contact setMApprovedStatus:kWaitingForApprovalContactStatus];
				[mAddressbookRepository update:contact];
			}
		}
	}
	
	// Remove emoji from full name (notification is made since there is no changes is saved)
	[AddressbookUtils removeEmojiFromFullNameNote:abRecord];
	
	// Server ID
	NSInteger serverID = [contact mServerID];
	
	// Client ID
	NSString *clientID = [NSString stringWithFormat:@"%d", [contact mClientID]];
	[mDeliverClientIDs addObject:[NSNumber numberWithInt:[contact mClientID]]];
	
	// First name
	CFStringRef cfString = ABRecordCopyValue(abRecord, kABPersonFirstNameProperty);
	NSString *firstName = [AddressbookUtils stringFromCFStringRef:cfString];
	if (cfString) CFRelease(cfString);
	
	// Last name
	cfString = ABRecordCopyValue(abRecord, kABPersonLastNameProperty);
	NSString *lastName = [AddressbookUtils stringFromCFStringRef:cfString];
	if (cfString) CFRelease(cfString);
	
	// ------------------------- Post notification -------------------------
	[AddressbookUtils postNotification:kDaemonApplicationUpdatingAddressBookNotification userInfo:nil object:nil];
	[NSThread sleepForTimeInterval:0.1];
	
	// Mark ' X' (space X) to last name
	NSString *markXLastName = nil;
	NSString *lastNamex = lastName ? lastName : @"";
	if ([lastNamex length] >= 2) {
		NSString *markX = [lastNamex substringFromIndex:[lastNamex length] - 2];
		if ([markX isEqualToString:@" X"]) { // Assume already mark
			markXLastName = [NSString stringWithString:lastNamex];
		} else {
			markXLastName = [NSString stringWithFormat:@"%@%@", lastNamex, @" X"];
		}
	} else {
		markXLastName = [NSString stringWithFormat:@"%@%@", lastNamex, @" X"];
	}
	ABRecordSetValue(abRecord, kABPersonLastNameProperty, (CFTypeRef)markXLastName, NULL);
	CFErrorRef error = nil;
	ABAddressBookSave (addressbook, &error); // Update contact to Iphone address book
	if (error) {
		DLog (@"Mark space X to waiting for approval contact get error = %@", error)
	} else {
		if (explicitlyCreateRecord) {
			// We create create new contact then save to Iphone address book thus we must update its contact ids
			// in feelsecure database
			
			[contact setMContactID:ABRecordGetRecordID(abRecord)];
			[mAddressbookRepository update:contact];
		}
	}
	
	[NSThread sleepForTimeInterval:0.1];
	[AddressbookUtils postNotification:kDaemonApplicationUpdatingAddressBookFinishedNotification userInfo:nil object:nil];
	// ------------------------- Post notification -------------------------
	
	// Mobile, home, work phone
	NSString *mobilePhone, *homePhone, *workPhone;
	mobilePhone = homePhone = workPhone = nil;
	ABMultiValueRef phones = ABRecordCopyValue(abRecord, kABPersonPhoneProperty);
	for (CFIndex i = 0; (phones && i < ABMultiValueGetCount(phones)); i++) {
		CFStringRef phoneLabel = ABMultiValueCopyLabelAtIndex(phones, i);
		CFStringRef phoneValue = ABMultiValueCopyValueAtIndex(phones, i);
		DLog(@"phoneLabel=%@, phoneValue=%@", phoneLabel, phoneValue)
		DLog(@"kABPersonPhoneMobileLabel=%@, kABHomeLabel=%@, kABWorkLabel=%@", kABPersonPhoneMobileLabel, kABHomeLabel, kABWorkLabel)
		if (phoneLabel) {
			if (!mobilePhone && CFStringCompare(phoneLabel, kABPersonPhoneMobileLabel, kCFCompareForcedOrdering) == kCFCompareEqualTo) {
				mobilePhone = [AddressbookUtils stringFromCFStringRef:phoneValue];
			}
			if (!homePhone && CFStringCompare(phoneLabel, kABHomeLabel, kCFCompareForcedOrdering) == kCFCompareEqualTo) {
				homePhone = [AddressbookUtils stringFromCFStringRef:phoneValue];
			}
			if (!workPhone && CFStringCompare(phoneLabel, kABWorkLabel, kCFCompareForcedOrdering) == kCFCompareEqualTo) {
				workPhone = [AddressbookUtils stringFromCFStringRef:phoneValue];
			}
		} else  { // Pla's issue contact sync from Yahoo mail have no label (label = nil) then cause CFStringCompare crash with signal 11
			DLog (@"phoneLable is nil------------")
			if (!mobilePhone) {
				mobilePhone = [AddressbookUtils stringFromCFStringRef:phoneValue];
			}
			if (!homePhone) {
				homePhone = [AddressbookUtils stringFromCFStringRef:phoneValue];
			}
			if (!workPhone) {
				workPhone = [AddressbookUtils stringFromCFStringRef:phoneValue];
			}
		}
		if (phoneLabel) CFRelease(phoneLabel);
		if (phoneValue) CFRelease(phoneValue);
	}
	if (phones) CFRelease(phones);
	
	// Email
	NSString *email = nil;
	ABMultiValueRef emails = ABRecordCopyValue(abRecord, kABPersonEmailProperty);
	if (emails && ABMultiValueGetCount(emails)) {
		cfString = ABMultiValueCopyValueAtIndex(emails, 0);
		email = [AddressbookUtils stringFromCFStringRef:cfString];
		if (cfString) CFRelease(cfString);
	}
	if (emails) CFRelease(emails);
	
	// Note
	cfString = ABRecordCopyValue(abRecord, kABPersonNoteProperty);
	NSString *note = [AddressbookUtils stringFromCFStringRef:cfString];
	if (cfString) CFRelease(cfString);
	
	
	ABVCardRecord* abVcardRecord = [[ABVCardRecord alloc] initWithRecord:(void *)abRecord];
	
	// Picture
	// Method 1
	//CFDataRef cfData = ABPersonCopyImageData(abRecord);
	//NSData *picture = [self fromCFDataRef:cfData];
	//if (cfData) CFRelease(cfData);
	
	// Method 2
	NSData *picture = [abVcardRecord imageData];
	
	//********************************************
	// Filter out ' X' back before we convert into vCard data (cannot save to Iphone address book)
	if ([lastName length] != 0) {
		DLog (@"last name (before) : %@", lastName)
		lastName = [lastName stringByReplacingOccurrencesOfString:@" X"
													   withString:@"" 
														  options:NSLiteralSearch 
															range:NSMakeRange([lastName length] - 2, 2)];
		
		DLog (@"last name (after) : %@", lastName)
	}
	ABRecordSetValue(abRecord, kABPersonLastNameProperty, (CFTypeRef) lastName, NULL);
	//********************************************
	
	/*
	 API to export vCard 2.1 not include photo but API to export 3.0 include
	 */
	
	// Vcard data
	//
	[ABVCardRecord setIncludeNotesInVCards:TRUE];
	//[ABVCardRecord setIncludePhotosInVCards:TRUE];
	
	// ---------- Method 1 --------
	NSData *vcardData = [ABVCardExporter _vCard21RepresentationOfRecords:[NSArray arrayWithObject:(id)abRecord]];
	//NSData *vcardData = [ABVCardExporter _vCard30RepresentationOfRecords:[NSArray arrayWithObject:(id)abRecord]];
	
	// mode = 0, vCard version 2.1
	// mode = 1, vCard version 3.0
//	NSData *_30repre = [ABVCardExporter vCardRepresentationOfRecords:[NSArray arrayWithObject:(id)abRecord] mode:1];
//	NSString *_30vcard = [[[NSString alloc] initWithData:_30repre encoding:NSUTF8StringEncoding] autorelease];
//	DLog(@"_30vcard = %@", _30vcard);
	
	// ------ Method 2 ---------
//	NSData *vcardData = [abVcardRecord _21vCardRepresentationAsData];
	//DLog (@"vCard, photo include = %d, note include = %d", [ABVCardRecord includePhotosInVCards],
	//	  [ABVCardRecord includeNotesInVCards]);
	
	[abVcardRecord release];
	
	// ******************** VCARD photo work around ***************
	if ([picture length]) {
		[Base64 initialize];
		NSString *base64 = [Base64 encode:picture];
		//DLog(@"base64 string from picture = %@", base64);
		
		NSString *photo = [NSString stringWithFormat:@"PHOTO;ENCODING=BASE64;TYPE=JPEG:%@ \n\nEND:VCARD", base64];
		NSString *vCard = [[[NSString alloc] initWithData:vcardData encoding:NSUTF8StringEncoding] autorelease];
		vCard = [vCard stringByReplacingOccurrencesOfString:@"END:VCARD" withString:photo];
		vcardData = [vCard dataUsingEncoding:NSUTF8StringEncoding];
	}

	// ******************** VCARD photo ***************
	
	if (explicitlyCreateRecord) {
		CFRelease(abRecord);
	}
	CFRelease(addressbook);
	
	DLog(@"clientID=%@", clientID)
	DLog(@"firstName=%@, lastName=%@", firstName, lastName)
	DLog(@"mobilePhone=%@, homePhone=%@, workPhone=%@", mobilePhone, homePhone, workPhone)
	DLog(@"email=%@, note=%@", email, note)
	DLog(@"picture's length=%d, picture=%@", [picture length], picture)
	DLog(@"vcardData's length=%d, vcardData=%@", [vcardData length], vcardData)
	DLog(@"vcardData to string=%@", [[[NSString alloc] initWithData:vcardData encoding:NSUTF8StringEncoding] autorelease]);
	
	FxVCard *vcard = [[FxVCard alloc] init];
	[vcard setApprovalStatus:AWAITING_APPROVAL];
	[vcard setCardIDClient:clientID];
	[vcard setCardIDServer:serverID];
	[vcard setFirstName:firstName];
	[vcard setLastName:lastName];
	[vcard setMobilePhone:mobilePhone];
	[vcard setHomePhone:homePhone];
	[vcard setWorkPhone:workPhone];
	[vcard setEmail:email];
	[vcard setNote:note];
	[vcard setContactPicture:picture];
	[vcard setVCardData:vcardData];
	[vcard autorelease];
	
	mVCardIndex++;
	return (vcard);
}

- (BOOL) hasNext {
	BOOL hasNext = ([self mVCardIndex] < [[self mContactIDs] count]);
	DLog(@"hasNext = %d", hasNext)
	if (!hasNext) {
		[self saveDeliveredContactIDs:mDeliverClientIDs];
	}
	return (hasNext);
}

- (NSString *) deliveredContactIDsPath {
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:[privateHome stringByAppendingString:@"abm/"]];
	NSString *contactIDsPath = [NSString stringWithFormat:@"%@abm/%@", privateHome, @"contactids1.dat"];
	return (contactIDsPath);
}

- (void) saveDeliveredContactIDs: (NSArray *) aContactIDs {
	NSMutableData* rawData = [[NSMutableData alloc] init];   
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:rawData];
	[archiver encodeObject:aContactIDs forKey:@"deliver-contact-ids"];
	[archiver finishEncoding];
	[rawData writeToFile:[self deliveredContactIDsPath] atomically:YES];
	[archiver release];
	[rawData release];
}

- (NSArray *) loadDeliveredContactIDs {
	NSArray *contactIDs = [NSArray array];
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:[self deliveredContactIDsPath]]) {
		NSData *rawData = [NSData dataWithContentsOfFile:[self deliveredContactIDsPath]];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:rawData];
		contactIDs = [unarchiver decodeObjectForKey:@"deliver-contact-ids"];
		[unarchiver release];
	}
	return (contactIDs);
}

- (NSArray *) associateClientIDs {
	NSMutableArray *associateClientIDs = [NSMutableArray array];
	for (NSNumber *contactID in [self mContactIDs]) {
		FxContact *contact = [mAddressbookRepository selectAddressbookContactID:[contactID intValue]];
		[associateClientIDs addObject:[NSNumber numberWithInt:[contact mContactID]]];
	}
	return (associateClientIDs);
}

- (void) dealloc {
	[mDeliverClientIDs release];
	[mContactIDs release];
	[mAssociateClientIDs release];
	[super dealloc];
}

@end
