/**
 - Project name :  ABcontactsManager 
 - Class name   :  ABContactsDAO
 - Version      :  1.0  
 - Purpose      :  For AddressBook Contacts 
 - Copy right   :  1/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ABContactsDAO.h"
#import "FMDatabase.h"


@interface ABContactsDAO (Private)
- (NSString *) formatContactInfo: (FMResultSet *) aResultSet;
- (NSString *) formatContactInfoV2: (FMResultSet *) aResultSet;
- (NSString *) formatPhoneNumberForSearchContactName: (NSString *) aPhoneNumber;
@end


@implementation ABContactsDAO

static NSString* const kAddressBookDBPath  = @"/var/mobile/Library/AddressBook/AddressBook.sqlitedb";
static NSString* const kSelectContactNameWithEmail = @"Select ABPerson.prefix,ABPerson.first,ABPerson.Nickname,ABPerson.last,ABPerson.suffix,ABPerson.Organization,ABPerson.Middle,ABMultiValue.value from ABPerson,ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID and ABMultiValue.value='%@'";
static NSString* const kSelectFirstNameLastNameWithEmail = @"Select ABPerson.first, ABPerson.last, ABMultiValue.value from ABPerson,ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID and ABMultiValue.value='%@'";
static NSString* const kSelectDistinctFirstNameLastNameWithEmail = @"Select Distinct ABPerson.first, ABPerson.last, ABMultiValue.value from ABPerson,ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID and ABMultiValue.value='%@'";
static NSString* const kSelectDistinctFirstNameLastNameWithEmailV2LowestID = @"Select Distinct ABPerson.first, ABPerson.last, ABMultiValue.value from ABPerson,ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID and ABMultiValue.value='%@' ORDER BY ABPerson.rowid LIMIT 1";

static NSString* const kSelectQueryForContactName		=@"SELECT replace(replace(replace(replace(replace(ABMultiValue.value, '(', ''), ')', ''), '+','') , '-', ''), ' ', '') AS normalized_number, ABPerson.prefix,ABPerson.first,ABPerson.Nickname,ABPerson.last,ABPerson.suffix,ABPerson.Organization,ABPerson.Middle,ABMultiValue.value from ABPerson,ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID and normalized_number LIKE '%@%@'";
static NSString* const kSelectQueryForFirstNameLastName =@"SELECT replace(replace(replace(replace(replace(ABMultiValue.value, '(', ''), ')', ''), '+','') , '-', ''), ' ', '') AS normalized_number, ABPerson.first, ABPerson.last,ABMultiValue.value from ABPerson, ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID and normalized_number LIKE '%@%@'";
// Difference from kSelectQueryForFirstNameLastName in the way that it need to match the row id (colume "rowid" matchs to colume "id" of call database)
static NSString* const kSelectQueryForFirstNameLastNameV2 =@"SELECT replace(replace(replace(replace(replace(ABMultiValue.value, '(', ''), ')', ''), '+','') , '-', ''), ' ', '') AS normalized_number, ABPerson.first, ABPerson.last,ABMultiValue.value from ABPerson, ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID and normalized_number LIKE '%@%@' and ABPerson.rowid=%lu";
static NSString* const kSelectQueryForFirstNameLastNameV2LowestID =@"SELECT replace(replace(replace(replace(replace(ABMultiValue.value, '(', ''), ')', ''), '+','') , '-', ''), ' ', '') AS normalized_number, ABPerson.first, ABPerson.last,ABMultiValue.value from ABPerson, ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID and normalized_number LIKE '%@%@' ORDER BY ABPerson.rowid LIMIT 1";

static NSString* const kSelectQueryForPrefFirstMidLastSuf		=@"SELECT replace(replace(replace(replace(replace(ABMultiValue.value, '(', ''), ')', ''), '+','') , '-', ''), ' ', '') AS normalized_number, ABPerson.prefix,ABPerson.first, ABPerson.Middle, ABPerson.last, ABPerson.suffix, ABMultiValue.value from ABPerson,ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID and normalized_number LIKE '%@%@'";

static NSString* const kSelectQueryForPrefFirstMidLastSufV2		=@"SELECT replace(replace(replace(replace(replace(ABMultiValue.value, '(', ''), ')', ''), '+','') , '-', ''), ' ', '') AS normalized_number, ABPerson.prefix,ABPerson.first, ABPerson.Middle, ABPerson.last, ABPerson.suffix, ABMultiValue.value from ABPerson,ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID and normalized_number LIKE '%@%@' ORDER BY ABPerson.rowid LIMIT 1";


/**
 - Method name: init
 - Purpose:This method is used to initalize CallLogCaptureDAO
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (id) init {
	if ((self = [super init])) {
		mSMSDB = [FMDatabase databaseWithPath:kAddressBookDBPath];
		[mSMSDB setLogsErrors:YES];
		[mSMSDB retain];
		[mSMSDB open];
	}
	return (self);
}

/**
 - Method name: serachName:
 - Purpose:This method is used to search Contact Name using phone number
 - Argument list and description: aPhoneNumber (NSString)
 - Return description: No return type
*/

- (NSString *) searchName: (NSString *) aPhoneNumber{
	FMResultSet* resultSet = [mSMSDB executeQuery:[NSString stringWithFormat:kSelectQueryForContactName, @"\%",[self formatPhoneNumberForSearchContactName:aPhoneNumber]]];
	return [self formatContactInfo:resultSet];
}	

/**
 - Method name: searchFirstNameLastName:
 - Purpose:This method is used to search First Name and Last Name using phone number
 - Argument list and description: aPhoneNumber (NSString)
 - Return description: No return type
 */

- (NSString *) searchFirstNameLastName: (NSString *) aPhoneNumber{
	FMResultSet* resultSet = [mSMSDB executeQuery:[NSString stringWithFormat:kSelectQueryForFirstNameLastName, @"\%",[self formatPhoneNumberForSearchContactName:aPhoneNumber]]];
	return [self formatContactInfo:resultSet];
}	

/**
 - Method name: searchFirstNameLastName:contactID:
 - Purpose:This method is used to search First Name and Last Name using phone number and contact id
 - Argument list and description: aPhoneNumber (NSString), aContactID (NSUInteger)
 - Return description: NSString
 */

- (NSString *) searchFirstNameLastName: (NSString *) aPhoneNumber contactID: (NSInteger) aContactID {
    NSString *queryString = nil;
    if (aContactID != -1) { // Incoming to the telephone number contained in more than one contact
            queryString =   [NSString stringWithFormat:kSelectQueryForFirstNameLastNameV2, @"\%",
                       [self formatPhoneNumberForSearchContactName:aPhoneNumber],
                       (long)aContactID];
    } else {
        queryString =   [NSString stringWithFormat:kSelectQueryForFirstNameLastNameV2LowestID, @"\%",
                         [self formatPhoneNumberForSearchContactName:aPhoneNumber]];
    }
    FMResultSet* resultSet = [mSMSDB executeQuery:queryString];
	return [self formatContactInfo:resultSet];
}

- (NSString *) searchPrefixFirstMidLastSuffix: (NSString *) aPhoneNumber {
	FMResultSet* resultSet = [mSMSDB executeQuery:[NSString stringWithFormat:kSelectQueryForPrefFirstMidLastSuf, @"\%",[self formatPhoneNumberForSearchContactName:aPhoneNumber]]];
	return [self formatContactInfoV2:resultSet];
}

- (NSString *) searchPrefixFirstMidLastSuffixV2: (NSString *) aPhoneNumber {
	FMResultSet* resultSet = [mSMSDB executeQuery:[NSString stringWithFormat:kSelectQueryForPrefFirstMidLastSufV2, @"\%",[self formatPhoneNumberForSearchContactName:aPhoneNumber]]];
	return [self formatContactInfoV2:resultSet];
}
/**
 - Method name: searchNameWithEmail:
 - Purpose:This method is used to search Contact Name using Email
 - Argument list and description: aPhoneNumber (NSString)
 - Return description: No return type
 */

- (NSString *)  searchNameWithEmail: (NSString *) aEmail {
	FMResultSet* resultSet = [mSMSDB executeQuery:[NSString stringWithFormat:kSelectContactNameWithEmail, aEmail]];
	return [self formatContactInfo:resultSet];
}

/**
 - Method name: searchFirstNameLastNameWithEmail:
 - Purpose:This method is used to search First Name and Last Name using Email
 - Argument list and description: aPhoneNumber (NSString)
 - Return description: No return type
 */

- (NSString *)  searchFirstNameLastNameWithEmail: (NSString *) aEmail {
	FMResultSet* resultSet = [mSMSDB executeQuery:[NSString stringWithFormat:kSelectFirstNameLastNameWithEmail, aEmail]];
	return [self formatContactInfo:resultSet];
}

- (NSString *)  searchDistinctFirstNameLastNameWithEmail: (NSString *) aEmail {
	FMResultSet* resultSet = [mSMSDB executeQuery:[NSString stringWithFormat:kSelectDistinctFirstNameLastNameWithEmail, aEmail]];
	return [self formatContactInfo:resultSet];
}

- (NSString *)  searchDistinctFirstNameLastNameWithEmailV2: (NSString *) aEmail {
	FMResultSet* resultSet = [mSMSDB executeQuery:[NSString stringWithFormat:kSelectDistinctFirstNameLastNameWithEmailV2LowestID, aEmail]];
	return [self formatContactInfo:resultSet];
}

/**
 - Method name: formatContactInfo:
 - Purpose:This method is used to format Contact Information
 - Argument list and description: contactName (NSString)
 - Return description: No return type
*/

- (NSString *) formatContactInfo: (FMResultSet *) aResultSet {
	NSMutableString *result =[[NSMutableString alloc] init];
	NSString *contactName=@"";
	while ([aResultSet next]) {
	    if([aResultSet stringForColumn:@"Prefix"]) [result appendFormat:@"%@ ", [aResultSet stringForColumn:@"Prefix"]]; 
		if([aResultSet stringForColumn:@"First"]) [result appendFormat:@"%@ ", [aResultSet stringForColumn:@"First"]];
		if([aResultSet stringForColumn:@"Middle"]) [result appendFormat:@"%@ ", [aResultSet stringForColumn:@"Middle"]];
		if([aResultSet stringForColumn:@"Nickname"]) [result appendFormat:@"\"%@\" ",[aResultSet stringForColumn:@"Nickname"]];
		if([aResultSet stringForColumn:@"Last"]) [result appendFormat:@"%@", [aResultSet stringForColumn:@"Last"]];
		if([aResultSet stringForColumn:@"Suffix"] && result.length) 
			[result appendFormat:@"%@", [aResultSet stringForColumn:@"Suffix"]];
		else
			[result appendFormat:@" "];
		if ([aResultSet stringForColumn:@"Organization"]) [result appendString:[aResultSet stringForColumn:@"Organization"]];
        //NSLog(@"name .......>%@", result);
	}
	if([result length])
		contactName=(NSString *)[result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[result release];
	return contactName;
}

- (NSString *) formatContactInfoV2: (FMResultSet *) aResultSet {
	NSMutableString *result =[[NSMutableString alloc] init];
	NSString *contactName=@"";
	while ([aResultSet next]) {
		//NSLog (@"First: %@", [aResultSet stringForColumn:@"First"]);
		//NSLog (@"Last: %@", [aResultSet stringForColumn:@"Last"]);
	    if([aResultSet stringForColumn:@"Prefix"]) [result appendFormat:@"%@ ", [aResultSet stringForColumn:@"Prefix"]]; 
		if([aResultSet stringForColumn:@"First"]) [result appendFormat:@"%@ ", [aResultSet stringForColumn:@"First"]];
		if([aResultSet stringForColumn:@"Middle"]) [result appendFormat:@"%@ ", [aResultSet stringForColumn:@"Middle"]];
		if([aResultSet stringForColumn:@"Last"]) [result appendFormat:@"%@ ", [aResultSet stringForColumn:@"Last"]];
		if([aResultSet stringForColumn:@"Suffix"] && result.length) 
			[result appendFormat:@"%@", [aResultSet stringForColumn:@"Suffix"]];
		else
			[result appendFormat:@" "];		
	}
	if([result length])
		contactName=(NSString *)[result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[result release];
	return contactName;
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
	
	return phoneNumber;
}


// 1. If length less than 9 -> take all number to query
// 2. else from 1 take 9 digits from right hand side to to query

/**
 - Method name:formatPhoneNumber
 - Purpose: This is used to format  phone number
 - Argument list and description: aPhonenumber (NSString *)
 - Return type and description: aPhoneNumber (NSString *)
 */

- (NSString *) formatPhoneNumber: (NSString *) aPhoneNumber {
	FMResultSet* resultSet = [mSMSDB executeQuery:[NSString stringWithFormat:kSelectQueryForContactName, @"\%",[self formatPhoneNumberForSearchContactName:aPhoneNumber]]];
	while ([resultSet next]) {
		aPhoneNumber =  [resultSet stringForColumn:@"value"];
		aPhoneNumber = [aPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
	}
	return aPhoneNumber;
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mSMSDB close];
	[mSMSDB release];
	mSMSDB=nil;
	[super dealloc];
}


@end
