//
//  TelephoneNumber.m
//  FxStd
//
//  Created by Makara Khloth on 4/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TelephoneNumber.h"

@implementation TelephoneNumber

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

/*
	The formatted number contains only digit and no 0 exists at the begining
 */
- (NSString *) formatMonitorNumber: (NSString *) aMonitorNumber {
	//APPLOGVERBOSE(@"formatMonitorNumber %@", aMonitorNumber);
	NSString *formattedNumber = @"";
	if (aMonitorNumber != nil && [aMonitorNumber length] > 4) {
		for (int i = 0; i < [aMonitorNumber length]; i++) {
			if (isdigit([aMonitorNumber characterAtIndex:i])) {
				formattedNumber = [formattedNumber stringByAppendingFormat:@"%c", [aMonitorNumber characterAtIndex:i]];
			}
		}
	}

	if ([formattedNumber hasPrefix:@"0"]) {
		formattedNumber = [formattedNumber substringFromIndex:1];
	}
	//APPLOGVERBOSE(@"formatted MonitorNumber %@", formattedNumber);
	return (formattedNumber);
}

- (BOOL) isNumber: (id) aNumber matchWithMonitorNumber: (id) aMonitorNumber {
	if (aNumber == nil || aNumber == @"" || aMonitorNumber == nil || aMonitorNumber == @"" ) {
		return NO;
	}
	
	NSString *number1 = (NSString *)aNumber;
	NSString *number2 = (NSString *)aMonitorNumber;
	
	//APPLOGVERBOSE(@"Comparing %@ with %@", number1, number2);
	NSString *formattedNumber = [self formatMonitorNumber:number1];
	NSString *numbertoCompare = [self formatMonitorNumber:number2];
	
	if (formattedNumber == nil || formattedNumber == @"" || numbertoCompare == nil || numbertoCompare == @"" ) {
		return NO;
	}
	
	BOOL numbersAreNotEqual = YES;
	if ([numbertoCompare length] > [formattedNumber length]) {
		int n1 = [formattedNumber length];
		int n2 = [numbertoCompare length];
		for (int i = 1; i <= n1; i++) {
			char cToComapre = [formattedNumber characterAtIndex:n1-i];
			char cTemp = [numbertoCompare characterAtIndex:n2-i];
			if (cTemp != cToComapre) {
				numbersAreNotEqual=NO;
				break;
			}
		}
	} else if([numbertoCompare length] <= [formattedNumber length]) {
		int n1 = [numbertoCompare length];
		int n2 = [formattedNumber length];
		for (int i = 1; i <= n1; i++) {
			char cToComapre = [formattedNumber characterAtIndex:(n2-i)];
			char cTemp=[numbertoCompare characterAtIndex:(n1-i)];
			if (cTemp != cToComapre) {
				numbersAreNotEqual=NO;
				break;
			}
		}
	}
	//APPLOGVERBOSE(@"Compared %@ with %@ result %d", number1, number2, numbersAreNotEqual);
	return (numbersAreNotEqual);
}

- (void) dealloc {
	[super dealloc];
}

@end
