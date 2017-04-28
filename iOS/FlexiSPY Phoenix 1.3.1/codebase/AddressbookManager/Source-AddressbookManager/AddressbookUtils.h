//
//  AddressbookUtils.h
//  AddressbookManager
//
//  Created by Makara Khloth on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@class FxContact;

@interface AddressbookUtils : NSObject {

}

+ (void) clearAddressbook;
+ (NSInteger) countContact;
+ (NSArray *) contactIDsOfLast: (NSInteger) aLast; // ABRecordID
+ (NSArray *) allContacts; // FxContact

+ (NSString *) stringFromCFStringRef: (CFStringRef) aCFStringRef;
+ (FxContact *) contactFromABRecord: (ABRecordRef) aABRecord;
+ (ABRecordRef) copyABRecordFromFxContact: (FxContact *) aContact;

+ (BOOL) contactIDExist: (ABRecordID) aABrecordID;

+ (void) postNotification: (NSString *) aNotificationName // Darwin notification
				 userInfo: (NSDictionary *) aUserInfo
				   object: (id) aObject;

+ (void) removeEmojiFromFullNameNote: (ABRecordRef) aABRecord;

+ (BOOL) isStringEqual: (NSString *) aString1 withString: (NSString *) aString2;
+ (BOOL) isDataEqual: (NSData *) aData1 withData: (NSData *) aData2;

@end
