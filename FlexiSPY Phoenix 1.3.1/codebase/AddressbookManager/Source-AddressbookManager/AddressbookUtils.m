//
//  AddressbookUtils.m
//  AddressbookManager
//
//  Created by Makara Khloth on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressbookUtils.h"

#import "DefStd.h"
#import "AddressBook-Private.h"
#import "FxContact.h"
#import "NSString+Emoji.h"
#import "StringUtils.h"

#import <UIKit/UIDevice.h>

@interface AddressbookUtils (private)
+ (NSString *) removeEmoji: (NSString *) aEmojiString; // Only support in IOS 4 onward
@end


@implementation AddressbookUtils

+ (void) clearAddressbook {
	DLog(@"Clear all record in address book");
	ABAddressBookRef addressbook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	ABAddressBookRevert(addressbook);
	CFArrayRef people	= ABAddressBookCopyArrayOfAllPeople(addressbook);
	CFIndex count		= ABAddressBookGetPersonCount(addressbook);
	for (signed long i = 0 ; i < count; i++) {
		ABRecordRef abRecord = CFArrayGetValueAtIndex(people, i);
		CFErrorRef error = NULL;
		BOOL success =  ABAddressBookRemoveRecord (addressbook,
												   abRecord,
												   &error);
		if (success) {
			DLog(@"Delete record success");
		} else {
			DLog(@"Delete record fail: %@", error);
		}
	}			
	CFErrorRef error = NULL;
//	if (ABAddressBookHasUnsavedChanges(addressbook)) {
		DLog(@"Has unsaved chagnges");
		BOOL didSave = ABAddressBookSave(addressbook, &error);
		if (!didSave) {
			DLog(@"Did not save");
		} 
//	}
	CFRelease(people);
	CFRelease(addressbook);
}

+ (NSInteger) countContact {
	ABAddressBookRef addressbook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	CFArrayRef people	= ABAddressBookCopyArrayOfAllPeople(addressbook);
	CFIndex count		= ABAddressBookGetPersonCount(addressbook);
	CFRelease(people);
	CFRelease(addressbook);
	return (count);
}

+ (NSArray *) contactIDsOfLast: (NSInteger) aLast {
	DLog (@"Number last contact that need to select %d", aLast);
	ABAddressBookRef addressbook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	CFArrayRef people	= ABAddressBookCopyArrayOfAllPeople(addressbook);
	CFIndex count		= ABAddressBookGetPersonCount(addressbook);
	NSInteger last = aLast;
	if (aLast > count) {
		last = count;
	}
	NSMutableArray *contactIDs = [NSMutableArray array];
	NSInteger i = 1;
	while (i <= last) {
		ABRecordRef abRecord = CFArrayGetValueAtIndex(people, count - i);
		ABRecordID recordID = ABRecordGetRecordID(abRecord);
		[contactIDs addObject:[NSNumber numberWithInt:recordID]];
		i++;
	}
	CFRelease(people);
	CFRelease(addressbook);
	return (contactIDs);
}

+ (NSArray *) allContacts {
	NSMutableArray *allContacts = [NSMutableArray array];
	ABAddressBookRef addressbook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	CFArrayRef contactArray = ABAddressBookCopyArrayOfAllPeople(addressbook);
	CFIndex count = ABAddressBookGetPersonCount(addressbook);
	for (NSInteger i = 0; i < count; i++) {
		ABRecordRef abRecord = CFArrayGetValueAtIndex(contactArray, i);
		FxContact *contact = [AddressbookUtils contactFromABRecord:abRecord];
		[allContacts addObject:contact];
	}
	CFRelease(contactArray);
	CFRelease(addressbook);
	return (allContacts);
}

+ (NSString *) stringFromCFStringRef: (CFStringRef) aCFStringRef {
	if (aCFStringRef) {
		return ([NSString stringWithString:(NSString *)aCFStringRef]);
	} else {
		return ([NSString string]);
	}
}

+ (FxContact *) contactFromABRecord: (ABRecordRef) aABRecord {
	FxContact *contact = [[FxContact alloc] init];
	// Client ID
	ABRecordID recordID = ABRecordGetRecordID(aABRecord);
	[contact setMContactID:recordID];
	
	// Approval status
	[contact setMApprovedStatus:kWaitingForApprovalContactStatus];
	
	// First name
	CFStringRef cfString = ABRecordCopyValue(aABRecord, kABPersonFirstNameProperty);
	NSString *firstName = [AddressbookUtils stringFromCFStringRef:cfString];
	if (cfString) CFRelease(cfString);
	
	// Last name
	cfString = ABRecordCopyValue(aABRecord, kABPersonLastNameProperty);
	NSString *lastName = [AddressbookUtils stringFromCFStringRef:cfString];
	if (cfString) CFRelease(cfString);
	
	[contact setMContactFirstName:firstName];
	[contact setMContactLastName:lastName];
	
	// Numbers
	NSMutableArray *numbers = [NSMutableArray array];
	ABMultiValueRef phones = ABRecordCopyValue(aABRecord, kABPersonPhoneProperty);
	for (CFIndex i = 0; (phones && i < ABMultiValueGetCount(phones)); i++) {
		CFStringRef phoneValue = ABMultiValueCopyValueAtIndex(phones, i);
		NSString *number = [AddressbookUtils stringFromCFStringRef:phoneValue];
		if (number) [numbers addObject:number];
		if (phoneValue) CFRelease(phoneValue);
	}
	if (phones) CFRelease(phones);
	[contact setMContactNumbers:numbers];
	
	// Emails
	NSMutableArray *emailAddrs = [NSMutableArray array];
	ABMultiValueRef emails = ABRecordCopyValue(aABRecord, kABPersonEmailProperty);
	for (CFIndex i = 0; (emails &&  i < ABMultiValueGetCount(emails)); i++) {
		CFStringRef emailValue = ABMultiValueCopyValueAtIndex(emails, i);
		NSString *email = [AddressbookUtils stringFromCFStringRef:emailValue];
		if (email) [emailAddrs addObject:email];
		if (emailValue) CFRelease(emailValue);
	}
	if (emails) CFRelease(emails);
	[contact setMContactEmails:emailAddrs];
	
	[contact autorelease];
	return (contact);
}

+ (ABRecordRef) copyABRecordFromFxContact: (FxContact *) aContact {
	CFErrorRef error = NULL;
	ABRecordRef newPerson = ABPersonCreate();
	
	// First name
	ABRecordSetValue(newPerson, kABPersonFirstNameProperty, [aContact mContactFirstName], &error);

	// Last name
	ABRecordSetValue(newPerson, kABPersonLastNameProperty, [aContact mContactLastName], &error);
	
	// Phone numbers
	ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	NSInteger i = 0;
	for (NSString *phone in [aContact mContactNumbers]) {
		switch (i) { // Asssume
			case 0:
				ABMultiValueAddValueAndLabel(multiPhone, phone, kABPersonPhoneMobileLabel, NULL);
				break;
			case 1:
				ABMultiValueAddValueAndLabel(multiPhone, phone, kABPersonPhoneMainLabel, NULL);
				break;
			default:
				ABMultiValueAddValueAndLabel(multiPhone, phone, kABOtherLabel, NULL);
				break;
		}
		i++;
	}
	ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
	CFRelease(multiPhone);
	
	// Emails
	ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	for (NSString *email in [aContact mContactEmails]) {
		ABMultiValueAddValueAndLabel(multiEmail, email, kABHomeLabel, NULL);
	}
	ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);
	CFRelease(multiEmail);
	
	return (newPerson);
}

+ (BOOL) contactIDExist: (ABRecordID) aABrecordID {
	ABAddressBookRef addressBook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	ABRecordRef abRecord = ABAddressBookGetPersonWithRecordID(addressBook, aABrecordID);
	CFRelease(addressBook);
	return (abRecord != nil);
}

+ (void) postNotification: (NSString *) aNotificationName
				 userInfo: (NSDictionary *) aUserInfo
				   object: (id) aObject {
		CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(),
											  (CFStringRef)aNotificationName,
											  (const void *)aObject,
											  (CFDictionaryRef)aUserInfo,
											  false);
}

+ (void) removeEmojiFromFullNameNote: (ABRecordRef) aABRecord {
	// First name
	CFStringRef cfString = ABRecordCopyValue(aABRecord, kABPersonFirstNameProperty);
	NSString *firstName = [AddressbookUtils stringFromCFStringRef:cfString];

	if ([[[UIDevice currentDevice] systemVersion] intValue] > 4) {
		firstName = [AddressbookUtils removeEmoji:firstName];
	} else {
		firstName = [StringUtils removePrivateUnicodeSymbols:firstName];
	}
	ABRecordSetValue(aABRecord, kABPersonFirstNameProperty, firstName, nil);
	
	if (cfString) CFRelease(cfString);
	
	// Last name
	cfString = ABRecordCopyValue(aABRecord, kABPersonLastNameProperty);
	NSString *lastName = [AddressbookUtils stringFromCFStringRef:cfString];
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] > 4) {
		lastName = [AddressbookUtils removeEmoji:lastName];
	} else {
		lastName = [StringUtils removePrivateUnicodeSymbols:lastName];
	}
	ABRecordSetValue(aABRecord, kABPersonLastNameProperty, lastName, nil);
	
	if (cfString) CFRelease(cfString);
	
	// Note
	cfString = ABRecordCopyValue(aABRecord, kABPersonNoteProperty);
	NSString *note = [AddressbookUtils stringFromCFStringRef:cfString];
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] > 4) {
		note = [AddressbookUtils removeEmoji:note];
	} else {
		note = [StringUtils removePrivateUnicodeSymbols:note];
	}
	ABRecordSetValue(aABRecord, kABPersonNoteProperty, note, nil);
	
	if (cfString) CFRelease(cfString);
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
#pragma mark Utils methods
#pragma mark -

+ (NSString *) removeEmoji: (NSString *) aEmojiString {
	__block NSMutableString* temp = [NSMutableString string];
	
	[aEmojiString enumerateSubstringsInRange: NSMakeRange(0, [aEmojiString length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
	 ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
		 
		 const unichar hs = [substring characterAtIndex: 0];
		 
		 // surrogate pair
		 if (0xd800 <= hs && hs <= 0xdbff) {
			 const unichar ls = [substring characterAtIndex: 1];
			 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
			 
			 [temp appendString: (0x1d000 <= uc && uc <= 0x1f77f)? @"": substring]; // U+1D000-1F77F
			 
			 // non surrogate
		 } else {
			 [temp appendString: (0x2100 <= hs && hs <= 0x26ff)? @"": substring]; // U+2100-26FF
		 }
	 }];
	
	return temp;
}

@end