/**
 - Project name :  ABcontactsManager 
 - Class name   :  ABContactsDAO
 - Version      :  1.0  
 - Purpose      :  For AddressBook Contacts 
 - Copy right   :  1/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
@class FMDatabase;
@interface ABContactsDAO : NSObject {
@private
	FMDatabase*	mSMSDB;
}
- (NSString *) searchName: (NSString *) aPhoneNumber;
- (NSString *) searchFirstNameLastName: (NSString *) aPhoneNumber;
- (NSString *) searchPrefixFirstMidLastSuffix: (NSString *) aPhoneNumber;
- (NSString *)  searchNameWithEmail: (NSString *) aEmail;
- (NSString *)  searchFirstNameLastNameWithEmail: (NSString *) aEmail;
- (NSString *)formatPhoneNumber:(NSString *) aPhoneNumber; 
@end
