//
//  ContactsManager.m
//  ContactsManager
//
//  Created by Khaneid Hantanasiriskul on 4/4/2559 BE.
//  Copyright © 2559 Khaneid Hantanasiriskul. All rights reserved.
//

#import "ContactsManager.h"
#import "DebugStatus.h"

#import "CNContact.h"
#import "CNDataMapperContactStore.h"
#import "CNiOSAddressBookDataMapper.h"

#import <objc/runtime.h>

@implementation ContactsManager

- (id) init  {
    if ((self = [super init])) {
        Class $CNiOSAddressBookDataMapper = objc_getClass("CNiOSAddressBookDataMapper");
        CNiOSAddressBookDataMapper *dataMapper = [[$CNiOSAddressBookDataMapper alloc] initWithPath:@"/var/mobile/Library/AddressBook/"];
        
        Class $CNDataMapperContactStore = objc_getClass("CNDataMapperContactStore");
        mCNContactStore = [[$CNDataMapperContactStore alloc] initWithDataMapper:dataMapper];
        
        NSArray *keysToFetch = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactPhoneNumbersKey];
        NSString *containerId = [mCNContactStore defaultContainerIdentifier];
        //NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
        NSPredicate *predicate = [CNContact predicateForContactsMatchingFullTextSearch:@"123456789" containerIdentifiers:nil groupIdentifiers:nil];
        
        DLog(@"keysToFetch %@", keysToFetch);
        
        //DLog(@"_contactStore %@", _contactStore);
        NSArray *_contacts = [mCNContactStore unifiedContactsMatchingPredicate:predicate keysToFetch:keysToFetch error:nil];
        //DLog(@"_contacts %@", _contacts);
        
        for (CNContact *c  in _contacts) {
            DLog(@"nickname %@", c.nickname);
            DLog(@"givenName %@", c.givenName);
            DLog(@"phoneNumbers %@", c.phoneNumbers);
            DLog(@"iOSLegacyIdentifier %d", c.iOSLegacyIdentifier);
        }
    }
    return self;
}

- (NSString *) searchContactName: (NSString *) aPhoneNumber{
    NSArray *KeysToFetch = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactPhoneNumbersKey];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingFullTextSearch:[self formatPhoneNumberForSearchContactName:aPhoneNumber] containerIdentifiers:nil groupIdentifiers:nil];
    [predicate allowEvaluation];
    DLog(@"predicate %@", predicate);
    
    NSError *error = nil;
    NSArray *contactsArray = [mCNContactStore unifiedContactsMatchingPredicate:predicate keysToFetch:KeysToFetch error:&error];
    
    NSString *result = @"";
    
    DLog(@"contactsArray %@", contactsArray);
    if (!error && contactsArray.count > 0) {
        result = [self formatContactInfo:contactsArray];
    }
    else {
        DLog(@"Error with %@", error);
    }

    return result;
}

/**
 - Method name: searchContactName:
 - Purpose:This method is used to search Contact Name using phone number
 - Argument list and description: contactName (NSString)
 - Return description: No return type
 */
- (NSString *) searchFirstNameLastName: (NSString *) aPhoneNumber {
    NSArray *KeysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingFullTextSearch:[self formatPhoneNumberForSearchContactName:aPhoneNumber] containerIdentifiers:nil groupIdentifiers:nil];
    
    NSError *error = nil;
    NSArray *contactsArray = [mCNContactStore unifiedContactsMatchingPredicate:predicate keysToFetch:KeysToFetch error:&error];
    DLog(@"contactsArray %@", contactsArray);
    NSString *result = @"";
    
    if (!error && contactsArray.count > 0) {
        result = [self formatContactInfo:contactsArray];
    }
    else {
        DLog(@"Error with %@", error);
    }
    
    return result;
}

/**
 - Method name: searchContactName:contactID:
 - Purpose:This method is used to search Contact Name using phone number and contact id (row id in Addressbook Database)
 - Argument list and description: contactName (NSString)
 - Return description: No return type
 */

- (NSString *) searchFirstNameLastName: (NSString *) aPhoneNumber contactID: (NSInteger) aContactID {
    NSArray *KeysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingFullTextSearch:[self formatPhoneNumberForSearchContactName:aPhoneNumber] containerIdentifiers:nil groupIdentifiers:nil];
    
    NSError *error = nil;
    NSArray *contactsArray = [mCNContactStore unifiedContactsMatchingPredicate:predicate keysToFetch:KeysToFetch error:&error];
    
    NSString *result = @"";
    DLog(@"contactsArray %@", contactsArray);
    if (!error && contactsArray.count > 0) {
        if (aContactID != -1) {
            __block CNContact *matchedContact = nil;
            [contactsArray enumerateObjectsUsingBlock:^(CNContact *contact, NSUInteger idx, BOOL * _Nonnull stop) {
                DLog(@"matchedContact %@", contact);
                if (contact.iOSLegacyIdentifier == aContactID) {
                    matchedContact = contact;
                    *stop = YES;
                }
            }];
            
            if (matchedContact) {
                result = [self formatContactInfo:@[matchedContact]];
            }
        }
        else {
            result = [self formatContactInfo:contactsArray];
        }
    }
    else {
        DLog(@"Error with %@", error);
    }
    
    return result;
}

- (NSString *) searchPrefixFirstMidLastSuffix: (NSString *) aPhoneNumber {
    NSArray *KeysToFetch = @[CNContactNamePrefixKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactNameSuffixKey];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingFullTextSearch:[self formatPhoneNumberForSearchContactName:aPhoneNumber] containerIdentifiers:nil groupIdentifiers:nil];
    
    NSError *error = nil;
    NSArray *contactsArray = [mCNContactStore unifiedContactsMatchingPredicate:predicate keysToFetch:KeysToFetch error:&error];
    
    NSString *result = @"";
    
    if (!error && contactsArray.count > 0) {
        result = [self formatContactInfo:contactsArray];
    }
    else {
        DLog(@"Error with %@", error);
    }
    
    return result;
}

- (NSString *) searchPrefixFirstMidLastSuffixV2: (NSString *) aPhoneNumber {
    NSArray *KeysToFetch = @[CNContactNamePrefixKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactNameSuffixKey];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingFullTextSearch:[self formatPhoneNumberForSearchContactName:aPhoneNumber] containerIdentifiers:nil groupIdentifiers:nil];
    
    NSError *error = nil;
    NSArray *contactsArray = [mCNContactStore unifiedContactsMatchingPredicate:predicate keysToFetch:KeysToFetch error:&error];
    
    NSString *result = @"";
    
    if (!error && contactsArray.count > 0) {
        CNContact *firstContact = contactsArray[0];
        result = [self formatContactInfo:@[firstContact]];
    }
    else {
        DLog(@"Error with %@", error);
    }
    
    return result;
}

/**
 - Method name: searchContactNameWithEmail:
 - Purpose:This method is used to search Contact Name
 - Argument list and description: contactName (NSString)
 - Return description: No return type
 */

- (NSString *) searchContactNameWithEmail: (NSString *) aEmail {
    NSArray *KeysToFetch = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactPhoneNumbersKey];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingFullTextSearch:aEmail containerIdentifiers:nil groupIdentifiers:nil];
    
    
    NSError *error = nil;
    NSArray *contactsArray = [mCNContactStore unifiedContactsMatchingPredicate:predicate keysToFetch:KeysToFetch error:&error];
    
    NSString *result = @"";
    
    if (!error && contactsArray.count > 0) {
        result = [self formatContactInfo:contactsArray];
    }
    else {
        DLog(@"Error with %@", error);
    }
    
    return result;
}

- (NSString *) searchFirstLastNameWithEmail: (NSString *) aEmail {
    NSArray *KeysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingFullTextSearch:aEmail containerIdentifiers:nil groupIdentifiers:nil];
    
    NSError *error = nil;
    NSArray *contactsArray = [mCNContactStore unifiedContactsMatchingPredicate:predicate keysToFetch:KeysToFetch error:&error];
    
    NSString *result = @"";
    
    if (!error && contactsArray.count > 0) {
        result = [self formatContactInfo:contactsArray];
    }
    else {
        DLog(@"Error with %@", error);
    }
    
    return result;
}

- (NSString *) searchDistinctFirstLastNameWithEmail: (NSString *) aEmail {
    NSArray *KeysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingFullTextSearch:aEmail containerIdentifiers:nil groupIdentifiers:nil];
    
    NSError *error = nil;
    NSArray *contactsArray = [mCNContactStore unifiedContactsMatchingPredicate:predicate keysToFetch:KeysToFetch error:&error];
    
    NSString *result = @"";
    
    if (!error && contactsArray.count > 0) {
        CNContact *firstContact = contactsArray[0];
        result = [self formatContactInfo:@[firstContact]];
    }
    else {
        DLog(@"Error with %@", error);
    }
    
    return result;
}

- (NSString *) searchDistinctFirstLastNameWithEmailV2: (NSString *) aEmail {
    NSArray *KeysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingFullTextSearch:aEmail containerIdentifiers:nil groupIdentifiers:nil];
    
    NSError *error = nil;
    NSArray *contactsArray = [mCNContactStore unifiedContactsMatchingPredicate:predicate keysToFetch:KeysToFetch error:&error];
    
    NSString *result = @"";
    
    if (!error && contactsArray.count > 0) {
        CNContact *firstContact = contactsArray[0];
        result = [self formatContactInfo:@[firstContact]];
    }
    else {
        DLog(@"Error with %@", error);
    }
    
    return result;
}

/**
 - Method name:formatPhoneNumberForSearchContactName
 - Purpose: This is used to formatPhoneNumberForSearchContactName in the AddressBook db
 - Argument list and description: aPhonenumber (NSString *)
 - Return type and description: phoneNumber(NSString *)
 */

- (NSString *) formatPhoneNumberForSearchContactName: (NSString *) aPhoneNumber {
    NSString *phoneNumber = @"";
    if([aPhoneNumber length] > 9) //Eg:85517786555
        phoneNumber=[aPhoneNumber substringWithRange:NSMakeRange([aPhoneNumber length] - 9, 9)];
    else
        phoneNumber=aPhoneNumber; //Eg:213455
    
    DLog(@"phoneNumber %@", phoneNumber)
    
    return phoneNumber;
}

/**
 - Method name: formatContactInfo:
 - Purpose:This method is used to format Contact Information
 - Argument list and description: contactName (NSString)
 - Return description: No return type
 */

- (NSString *) formatContactInfo: (NSArray *) contactArray {
    NSMutableString *result =[[NSMutableString alloc] init];
    NSString *contactName=@"";
    for (CNContact *aContact in contactArray) {
        if([aContact isKeyAvailable:CNContactNamePrefixKey] && aContact.namePrefix.length > 0) [result appendFormat:@"%@ ", aContact.namePrefix];
        if([aContact isKeyAvailable:CNContactGivenNameKey] && aContact.givenName.length > 0) [result appendFormat:@"%@ ", aContact.givenName];
        if([aContact isKeyAvailable:CNContactMiddleNameKey] && aContact.middleName.length > 0) [result appendFormat:@"%@ ", aContact.middleName];
        if([aContact isKeyAvailable:CNContactNicknameKey] && aContact.nickname.length > 0) [result appendFormat:@"\"%@\" ",aContact.nickname];
        if([aContact isKeyAvailable:CNContactFamilyNameKey] && aContact.familyName.length > 0) [result appendFormat:@"%@", aContact.familyName];
        if([aContact isKeyAvailable:CNContactNameSuffixKey] && aContact.nameSuffix.length > 0)
            [result appendFormat:@"%@", aContact.nameSuffix];
        else
            [result appendFormat:@" "];
        if ([aContact isKeyAvailable:CNContactOrganizationNameKey] && aContact.organizationName.length > 0) [result appendString:aContact.organizationName];
        //NSLog(@"name .......>%@", result);
    }
    
    if([result length])
        contactName=(NSString *)[result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return contactName;
}

/**
 - Method name:formatPhoneNumber
 - Purpose: This is used to format  phone number
 - Argument list and description: aPhonenumber (NSString *)
 - Return type and description: aPhoneNumber (NSString *)
 */

- (NSString *)formatSenderNumber:(NSString *) aPhoneNumber {
    return aPhoneNumber = [aPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@end
