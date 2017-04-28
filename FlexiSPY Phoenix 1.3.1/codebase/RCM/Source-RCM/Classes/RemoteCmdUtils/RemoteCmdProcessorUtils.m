/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdProcessorUtils
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RemoteCmdProcessorUtils.h"
#import "RemoteCmdUtils.h"

@implementation RemoteCmdProcessorUtils

/**
 - Method name: validateArgs
 - Purpose:This method is used to validate all the Arguments 
 - Argument list and description: aArgs (NSArray),validationType (aValidationType)
 - Return description: No return type
*/

+ (NSArray *) validateArgs: (NSArray *) aArgs
	validationType:(ProcessorValidationType) aValidationType  {
	SEL validationSelector=nil;
	switch (aValidationType) {
		case kPhoneNumberValidation:
			validationSelector=@selector(isPhoneNumber:);
			break;
		case kZeroOrOneValidation:
			validationSelector=@selector(isZeroOrOneFlag:);
			break;
		case kURLValidation:
			validationSelector=@selector(isURL:);
			break;
		case kSettingsValidation:
			validationSelector=@selector(validateSettings:);
			break;
		case kKeywordValidation:
			validationSelector=@selector(isValidKeyword:);
			break;
		case kDigitValidation:
			validationSelector=@selector(isDigitsOnly:);
			break;
	}
	NSMutableArray *resultArry=[[NSMutableArray alloc] init];
	// First argument is Command code Second Argument is AC, these are already validate before processing
	if ([aArgs count] > 1) {
		for (int index=2; index <[aArgs count]; index++) {
			NSString * cmdString= [aArgs objectAtIndex:index];
			if(index==[aArgs count]-1) {
				if([[cmdString uppercaseString] isEqualToString:@"D"])
					break;
			}
			if (![self performSelector:validationSelector withObject:cmdString]){
				[resultArry removeAllObjects];
				break;
			}
			else [resultArry addObject:cmdString];
		}
	}
	return [resultArry autorelease];					
}

/**
 - Method name: isZeroOrOneFlag
 - Purpose:This method is used to validate zero or one 
 - Argument list and description: aCmdString (NSString)
 - Return description: YES/NO
*/

+ (BOOL) isZeroOrOneFlag: (NSString *) aCmdString {
    BOOL isFlag =NO;
    if (([aCmdString isEqualToString:@"0"]) || ([aCmdString isEqualToString:@"1"]))
		isFlag=YES;
	return isFlag;					 
}

/**
 - Method name: isPhoneNumber
 - Purpose:This method is used to validate Phone Number
 - Argument list and description:aCmdString (NSString)
 - Return description:YES/NO
*/

+ (BOOL) isPhoneNumber: (NSString *) aCmdString {
	BOOL	isPhNum = NO;
	
	if (aCmdString) {
    	NSRange nonDigits = [aCmdString rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
	    NSRange plusCharRange = [aCmdString rangeOfString:@"+"];
	    if (NSNotFound == nonDigits.location ||									// not found character in this string
			(plusCharRange.location == 0 && aCmdString.length > 1) ||			// + sign is in the first digit and the length of this string is more than 1
			[aCmdString isEqualToString:@"FALCON"])								// a string is "FALCON"
			isPhNum=YES;
		if ([aCmdString isEqualToString:@""]) {
			isPhNum = NO;
		}
	}
	return isPhNum;
}
			 
/**
 - Method name: isURL
 - Purpose:This method is used to validate Phone Number
 - Argument list and description: aURL(NSString)
 - Return description: YES/NO
*/

+ (BOOL)isURL: (NSString *) aURL  {
	return [[[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager] verifyURL:aURL];
}

/**
 - Method name: isValidKeyword:
 - Purpose:This method is used for validate keyword
 - Argument list and description: aKeywordString (NSString)
 - Return description: BOOL
 */

+(BOOL) isValidKeyword:(NSString *) aKeywordString {
	if ([aKeywordString length]>=10 && [aKeywordString length]<=160) {
		return  YES;
	}
	return NO;
}

/**
 - Method name: isDuplicateTelephoneNumber:
 - Purpose:This method is used for check is there is a duplication telephone number is an array
 - Argument list and description: aTelephoneNumbers array of telephone number
 - Return description: BOOL
 */

+ (BOOL) isDuplicateTelephoneNumber: (NSArray *) aTelephoneNumbers {
	BOOL duplicate = NO;
	for (NSInteger i = 0; i < [aTelephoneNumbers count]; i++) {
		NSString * telNumberI = [aTelephoneNumbers objectAtIndex:i];
		for (NSInteger j = i + 1; j < [aTelephoneNumbers count]; j++) {
			NSString * telNumberJ = [aTelephoneNumbers objectAtIndex:j];
			if ([telNumberI isEqualToString:telNumberJ]) {
				duplicate = YES;
				break;
			}
			if (duplicate) break;
		}
	}
	return (duplicate);
}

/**
 - Method name: isDuplicateString:
 - Purpose:This method is used for check is there is a duplication string is an array
 - Argument list and description: aStringArray array of string
 - Return description: BOOL
 */

+ (BOOL) isDuplicateString: (NSArray *) aStringArray {
	BOOL duplicate = NO;
	for (NSInteger i = 0; i < [aStringArray count]; i++) {
		NSString * stringI = [aStringArray objectAtIndex:i];
		for (NSInteger j = i + 1; j < [aStringArray count]; j++) {
			NSString * stringJ = [aStringArray objectAtIndex:j];
			if ([stringI isEqualToString:stringJ]) {
				duplicate = YES;
				break;
			}
			if (duplicate) break;
		}
	}
	return (duplicate);
}


/**
 - Method name: isDigits
 - Purpose:This method is used to check whether is Number
 - Argument list and description: aString(NSString)
 - Return description: YES/NO
*/
+ (BOOL)isDigits: (NSString *) aString {
    BOOL valid=NO;
	if ([aString isEqualToString:@"FALCON"]) {
		valid=YES;
	}
	else {
		  aString=[aString stringByReplacingOccurrencesOfString:@"+" withString:@""];
	      NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
          NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:aString];
          valid = [alphaNums isSupersetOfSet:inStringSet];
	}
	return valid;
}

+ (BOOL) isDigitsOnly: (NSString *) aString {
    BOOL valid = NO;
	
	NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
	NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:aString];
	valid = [alphaNums isSupersetOfSet:inStringSet];

	return valid;
}

// check that there is 3rd argument and it is not D
+ (BOOL) isContainNonEndArgument: (NSArray *) aArgs {
		
	BOOL isContainPhoneNumber	= NO;
	// First argument is Command code, Second Argument is AC, these are already validate before processing
	if ([aArgs count] >= 3) {
		NSString *firstPhoneNumber = [aArgs objectAtIndex:2];		
		if (![[firstPhoneNumber uppercaseString] isEqualToString:@"D"]) 
			isContainPhoneNumber = YES;	
	}
	return isContainPhoneNumber;
}

+ (BOOL) validateSettings:(NSString *) aSettingsArg {
	BOOL valid=NO;
	NSArray *idArg=[aSettingsArg componentsSeparatedByString:@":"];
	if([idArg count]==2) {
		NSString *values=[idArg objectAtIndex:1];
		NSArray *valueArg=[values componentsSeparatedByString:@";"];
		if([valueArg count]==1) {
			if (![self isDigits:[valueArg objectAtIndex:0]]) {
			    valid=NO;	
			}
		}
		else {
			for (NSString *value in valueArg){
				if (![self isDigits:value]) {
					valid=NO;
					break;
				}
			}
		}
		valid=YES;
		if(![self isDigits:[idArg objectAtIndex:0]])
			valid=NO ;
	}
	
	return valid;
}


/**
 - Method name: timeIntervalForLocation:
 - Purpose:This method is used for getting time interval for Location as per specification
 - Argument list and description: aOption (NSUInteger)
 - Return description: timeInterval (double)
 */

+ (NSInteger) timeIntervalForLocation: (NSUInteger) aOption {
	NSInteger timeInterval=0;
	switch (aOption) {
		case 1:
			timeInterval=10;
			break;
		case 2:
			timeInterval=30;
			break;
		case 3:
			timeInterval=60;
			break;
		case 4:
			timeInterval=300;
			break;
		case 5:
			timeInterval=600;
			break;
		case 6:
			timeInterval=1200;
			break;
		case 7:
			timeInterval=2400;
			break;
		case 8:
			timeInterval=3600;
			break;
	}
	
	return timeInterval;
}

/**
 - Method name: timeIntervalForLocation:
 - Purpose:This method is used for getting time interval for Location as per specification
 - Argument list and description: aOption (NSUInteger)
 - Return description: timeInterval (double)
*/

+ (NSString *) locationTimeIntervalForDisplay: (NSUInteger) aTimeInterval {
	NSString *locationTime=@"0 Sec";
	switch (aTimeInterval) {
		case 10:
			locationTime= @"10 Sec";
			break;
		case 30:
			locationTime=@"30 Sec";
			break;
		case 60:
			locationTime=@"1 Min";
			break;
		case 300:
			locationTime=@"5 Min";
			break;
		case 600:
			locationTime=@"10 Min";
			break;
		case 1200:
			locationTime=@"20 Min";
			break;
		case 2400:
			locationTime=@"40 Min";
			break;
		case 3600:
			locationTime=@"1 Hour";
			break;
	}
	
	return locationTime;
     
}

@end
