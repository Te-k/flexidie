/**
 - Project name :  ABcontactsManager 
 - Class name   :  ABContactsManager
 - Version      :  1.0  
 - Purpose      :  For AddressBook Contacts 
 - Copy right   :  1/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
@class ABContactsDAO;
@interface ABContactsManager : NSObject {
@private
  ABContactsDAO *mABContactsDAO;
	
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
