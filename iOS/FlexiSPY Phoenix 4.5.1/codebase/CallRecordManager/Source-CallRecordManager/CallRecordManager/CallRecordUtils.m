//
//  CallRecordUtils.m
//  CallRecordHelper
//
//  Created by Makara Khloth on 11/30/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "CallRecordUtils.h"
#import "PrefCallRecord.h"
#import "PrefMonitorNumber.h"
#import "DebugStatus.h"
#import "DefStd.h"
#import "TelephoneNumber.h"
#import "AddressBook-Private.h"

#import <AddressBook/AddressBook.h>

@interface CallRecordUtils (private)
+ (BOOL) isNumberinAddressBook: (NSString *) aTelephoneNumber;
@end

@implementation CallRecordUtils

+ (BOOL) isNumberInCallRecordWatchList: (NSString *) aTelephoneNumber watchList: (PrefCallRecord *) aCallRecordWatchList {
    BOOL numberIsInWatch = FALSE;
    // Private/Unknown number
    if (!numberIsInWatch && ([aCallRecordWatchList mWatchFlag] & kWatch_Private_Or_Unknown_Number)) {
        if ([aTelephoneNumber isEqualToString:@"Blocked"]   ||
            [aTelephoneNumber isEqualToString:@"No Caller ID"]) {
            numberIsInWatch = TRUE;
        }
    }
    // Watch list number
    if (!numberIsInWatch && ([aCallRecordWatchList mWatchFlag] & kWatch_In_List)) {
        TelephoneNumber *telNumber = [[TelephoneNumber alloc] init];
        for (NSString *watchNumber in [aCallRecordWatchList mWatchNumbers]) {
            if ([telNumber isNumber:aTelephoneNumber matchWithMonitorNumber:watchNumber]) {
                numberIsInWatch = TRUE;
                break;
            }
        }
        [telNumber release];
    }
    
    // Not in address book/In address book
    if (!numberIsInWatch && (([aCallRecordWatchList mWatchFlag] & kWatch_Not_In_Addressbook) ||
                             ([aCallRecordWatchList mWatchFlag] & kWatch_In_Addressbook))) {
        BOOL isInAddressBook = [self isNumberinAddressBook:aTelephoneNumber];
        DLog (@"Is number is in address book = %d", isInAddressBook);
        if (!isInAddressBook && ([aCallRecordWatchList mWatchFlag] & kWatch_Not_In_Addressbook)) {
            numberIsInWatch = TRUE;
        }
        if (isInAddressBook && ([aCallRecordWatchList mWatchFlag] & kWatch_In_Addressbook)) {
            numberIsInWatch = TRUE;
        }
    }
    DLog (@"Is number is in watch = %d", numberIsInWatch);
    return (numberIsInWatch);
}

+ (BOOL) isSpyNumber: (NSString *) aTelephoneNumber prefMonitorNumber: (PrefMonitorNumber *) aPrefMonitorNumber {
    BOOL yes = NO;
    PrefMonitorNumber *prefMonitorNumbers = aPrefMonitorNumber;
    if ([prefMonitorNumbers mEnableMonitor]) {
        TelephoneNumber *telNumber = [[TelephoneNumber alloc] init];
        for (NSString *monitorNumber in [prefMonitorNumbers mMonitorNumbers]) {
            if ([telNumber isNumber:aTelephoneNumber matchWithMonitorNumber:monitorNumber]) {
                yes = YES;
                break;
            }
        }
        [telNumber release];
    }
    DLog(@"aTelephoneNumber: %@, spy: %d", aTelephoneNumber, yes);
    return (yes);
}

+ (BOOL) isNumberinAddressBook: (NSString *) aTelephoneNumber {
    DLog (@"Number to compare with address book, aTelephoneNumber = %@", aTelephoneNumber);
    BOOL isInAddressBook = FALSE;
    ABAddressBookRef addressBook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
    CFArrayRef contactArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfContact = ABAddressBookGetPersonCount(addressBook);
    TelephoneNumber *telNumber = [[TelephoneNumber alloc] init];
    for (CFIndex index = 0; index < numberOfContact; index++) {
        ABRecordRef abRecord = CFArrayGetValueAtIndex(contactArray, index);
        ABMultiValueRef phones = ABRecordCopyValue(abRecord, kABPersonPhoneProperty);
        for (CFIndex i = 0; (phones && i < ABMultiValueGetCount(phones)); i++) {
            CFStringRef phoneValue = ABMultiValueCopyValueAtIndex(phones, i);
            if (phoneValue) {
                NSString *number = [NSString stringWithString:(NSString *)phoneValue];
                DLog (@"Number from address book, number = %@", number);
                if ([telNumber isNumber:aTelephoneNumber matchWithMonitorNumber:number]) {
                    isInAddressBook = TRUE;
                    CFRelease(phoneValue);
                    break;
                }
                CFRelease(phoneValue);
            }
        }
        if (phones) CFRelease(phones);
        if (isInAddressBook) break;
    }
    [telNumber release];
    if (contactArray) CFRelease(contactArray);
    if (addressBook) CFRelease(addressBook);
    return (isInAddressBook);
}

@end
