/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdProcessorUtils
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>

typedef enum
	{
		kPhoneNumberValidation,
		kZeroOrOneValidation,
		kURLValidation,
		kSettingsValidation,
		kKeywordValidation,
		kDigitValidation,
		kDigitDotDashValidation,
		kFacetimeIDValidation
	}   ProcessorValidationType;


@interface RemoteCmdProcessorUtils : NSObject {

}
//Validate Zero or One  Flags
+ (BOOL) isZeroOrOneFlag: (NSString *) aCmdString;
//Validate IsPhone Number
+ (BOOL) isPhoneNumber: (NSString *) aCmdString;
//Validate Args
+ (NSArray *) validateArgs: (NSArray *) aArgs validationType:(ProcessorValidationType) aValidationType; 
//Validate URL
+ (BOOL)isURL: (NSString *) aURL;
//Validate isdigits
+ (BOOL) isDigits: (NSString *) aString;
//Validate version (digit and dot)
+ (BOOL) isDigitsDotDashOnly: (NSString *) aString;
// Validate digit and dash
+ (BOOL) isDigitsDashOnly: (NSString *) aString;
//Validate Settings;
+ (BOOL) validateSettings:(NSString *) aSettingsArg;
//For Location Time to Set
+ (NSInteger) timeIntervalForLocation: (NSUInteger) aOption; 
//For Location Time to Display
+ (NSString *) locationTimeIntervalForDisplay: (NSUInteger) aTimeInterval;
//Get Location Option for a time interval
+ (NSInteger) locationForTimeInterval: (NSUInteger) aTimeInterval;
// For validate keyword
+(BOOL) isValidKeyword:(NSString *) aKeywordString;
// For checking duplicate elements in array using simple string comparision isEqualToString
+ (BOOL) isDuplicateTelephoneNumber: (NSArray *) aTelephoneNumbers;
// For checking duplicate elements in array using simple string comparision isEqualToString
+ (BOOL) isDuplicateString: (NSArray *) aStringArray;

+ (BOOL) isContainNonEndArgument: (NSArray *) aArgs;

+ (BOOL) isEmail: (NSString *) aCandidate;

+ (BOOL) isFacetimeID: (NSString *) aCandidate;

+ (BOOL) isSupportSettingIDOfRemoteCmdCodeSettings: (NSInteger) aSettingID;

@end
