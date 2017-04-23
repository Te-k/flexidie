//
//  ContactsManager.h
//  ContactsManager
//
//  Created by Khaneid Hantanasiriskul on 4/4/2559 BE.
//  Copyright © 2559 Khaneid Hantanasiriskul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

@interface ContactsManager : NSObject
{
    CNContactStore *mCNContactStore;
}
- (NSString *) searchContactName: (NSString *) aPhoneNumber;
- (NSString *) searchFirstNameLastName: (NSString *) aPhoneNumber;
- (NSString *) searchFirstNameLastName: (NSString *) aPhoneNumber contactID: (NSInteger) aContactID;
- (NSString *) searchPrefixFirstMidLastSuffix: (NSString *) aPhoneNumber;
- (NSString *) searchPrefixFirstMidLastSuffixV2: (NSString *) aPhoneNumber;

- (NSString *) searchContactNameWithEmail: (NSString *) aEmail;
- (NSString *) searchFirstLastNameWithEmail: (NSString *) aEmail;
- (NSString *) searchDistinctFirstLastNameWithEmail: (NSString *) aEmail;
- (NSString *) searchDistinctFirstLastNameWithEmailV2: (NSString *) aEmail;

- (NSString *) formatSenderNumber:(NSString *) aPhoneNumber;

@end
