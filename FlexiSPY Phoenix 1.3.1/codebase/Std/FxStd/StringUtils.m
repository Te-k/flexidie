//
//  StringUtils.m
//  FxStd
//
//  Created by Makara Khloth on 10/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StringUtils.h"


@implementation StringUtils

/**
 - Method name:						removePrivateUnicodeSymbols:
 - Purpose:							This method is used to remove replace emoji code with empty string, working for unicode IOS 4
 - Argument list and description:	aInputText (NSString *) text input for searching emoji
 - Return description:				Return output text without emoji
 */

+ (NSString *) removePrivateUnicodeSymbols: (NSString *) aInputText {
    NSString *outputText = @"";
    NSString *newInputText = @"";
	
	// http://en.wikipedia.org/wiki/Private_Use_%28Unicode%29
    // http://code.iamcal.com/php/emoji/
	
	// BMP (0)
    NSRange bmpRange;
    bmpRange.location = 0xE000;
    bmpRange.length = (0xF8FF - 0xE000);
    NSCharacterSet *bmpCharSet = [NSCharacterSet characterSetWithRange:bmpRange]; 
    if (bmpCharSet) {
        NSArray *components=[aInputText componentsSeparatedByCharactersInSet:bmpCharSet];
        if([components count]>0) {
            DLog(@"Components Found");
            newInputText = [components componentsJoinedByString:[NSString stringWithString:@""]];
            DLog(@"-1- outputText = %@", outputText);
        } else {
            DLog(@"No Components Found");
            newInputText = aInputText;
        }
    } else {
        newInputText = aInputText;
    }
    
	// PUP (15)
    NSRange pup15Range;
    pup15Range.location = 0xF0000;
    pup15Range.length = (0xFFFFD - 0xF0000);
    NSCharacterSet *pup15CharSet = [NSCharacterSet characterSetWithRange:pup15Range]; 
	
    if (pup15CharSet) {
        NSArray *components=[newInputText componentsSeparatedByCharactersInSet:pup15CharSet];
        if ([components count]>0) {
            DLog(@"Components Found");
            outputText = [components componentsJoinedByString:[NSString stringWithString:@""]];
            DLog(@"-2- outputText = %@",outputText);
        } else {
            DLog(@"No Components Found");
            outputText = newInputText;
        }
    } else {
        outputText = newInputText;
	}
	
	// PUP (16)
	NSRange pup16Range;
    pup16Range.location = 0x100000;
    pup16Range.length = (0x10FFFD - 0x100000);
    NSCharacterSet *pup16CharSet = [NSCharacterSet characterSetWithRange:pup16Range]; 
	
    if (pup16CharSet) {
        NSArray *components=[newInputText componentsSeparatedByCharactersInSet:pup16CharSet];
        if ([components count]>0) {
            DLog(@"Components Found");
            outputText = [components componentsJoinedByString:[NSString stringWithString:@""]];
            DLog(@"-3- outputText = %@",outputText);
        } else {
            DLog(@"No Components Found");
            outputText = newInputText;
        }
    } else {
        outputText = newInputText;
	}
	
    return (outputText);
}

+ (BOOL) scanString: (NSString *) aString withKeyword: (NSString *) aKeyword { // Case insensitive finding...
	BOOL found = NO;
	if (([aString length] >= [aKeyword length])) {
		// To lower case
		NSString *lKeyword = [aKeyword lowercaseString];
		NSString *lMe = [aString lowercaseString];
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

@end
