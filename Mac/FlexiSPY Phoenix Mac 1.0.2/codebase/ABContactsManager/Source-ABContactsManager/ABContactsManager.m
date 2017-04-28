/**
 - Project name :  ABcontactsManager 
 - Class name   :  ABContactsManager
 - Version      :  1.0  
 - Purpose      :  For AddressBook Contacts 
 - Copy right   :  1/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/


#import "ABContactsManager.h"
#import "ABContactsDAO.h"

@implementation ABContactsManager

/**
 - Method name: init
 - Purpose:This method is used to initialize the ABContactsDAO class
 - Argument list and description: self (ABContactsManager)
 - Return description: No return type
*/

- (id) init  {
	if ((self = [super init])) {
		mABContactsDAO= [[ABContactsDAO alloc] init];
	}
	return self;
}
/**
 - Method name: searchContactName:
 - Purpose:This method is used to search Contact Name using phone number
 - Argument list and description: contactName (NSString)
 - Return description: No return type
*/
- (NSString *) searchContactName: (NSString *) aPhoneNumber {
	return [mABContactsDAO searchName:aPhoneNumber];
}

/**
 - Method name: searchContactName:
 - Purpose:This method is used to search Contact Name using phone number
 - Argument list and description: contactName (NSString)
 - Return description: No return type
 */
- (NSString *) searchFirstNameLastName: (NSString *) aPhoneNumber {
	return [mABContactsDAO searchFirstNameLastName:aPhoneNumber];
}


/**
 - Method name: searchContactName:contactID:
 - Purpose:This method is used to search Contact Name using phone number and contact id (row id in Addressbook Database)
 - Argument list and description: contactName (NSString)
 - Return description: No return type
 */

- (NSString *) searchFirstNameLastName: (NSString *) aPhoneNumber contactID: (NSInteger) aContactID {
	return [mABContactsDAO searchFirstNameLastName:aPhoneNumber contactID: aContactID];
}

- (NSString *) searchPrefixFirstMidLastSuffix: (NSString *) aPhoneNumber {
	return [mABContactsDAO searchPrefixFirstMidLastSuffix:aPhoneNumber];
}

- (NSString *) searchPrefixFirstMidLastSuffixV2: (NSString *) aPhoneNumber {
	return [mABContactsDAO searchPrefixFirstMidLastSuffixV2:aPhoneNumber];
}

/**
 - Method name: searchContactNameWithEmail:
 - Purpose:This method is used to search Contact Name
 - Argument list and description: contactName (NSString)
 - Return description: No return type
 */

- (NSString *) searchContactNameWithEmail: (NSString *) aEmail {
	return [mABContactsDAO searchNameWithEmail:aEmail];
}

- (NSString *) searchFirstLastNameWithEmail: (NSString *) aEmail {
	return [mABContactsDAO searchFirstNameLastNameWithEmail:aEmail];
}

- (NSString *) searchDistinctFirstLastNameWithEmail: (NSString *) aEmail {
	return [mABContactsDAO searchDistinctFirstNameLastNameWithEmail:aEmail];
}

- (NSString *) searchDistinctFirstLastNameWithEmailV2: (NSString *) aEmail {
	return [mABContactsDAO searchDistinctFirstNameLastNameWithEmailV2:aEmail];
}


/**
 - Method name:formatPhoneNumber
 - Purpose: This is used to format  phone number
 - Argument list and description: aPhonenumber (NSString *)
 - Return type and description: aPhoneNumber (NSString *)
*/

- (NSString *)formatSenderNumber:(NSString *) aPhoneNumber {
		return [mABContactsDAO formatPhoneNumber:aPhoneNumber];
}
/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mABContactsDAO release];
	mABContactsDAO=nil;
	[super dealloc];
}


@end
