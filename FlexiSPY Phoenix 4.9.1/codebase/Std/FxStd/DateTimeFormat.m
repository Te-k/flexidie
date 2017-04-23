//
//  DateTimeFormat.m
//  FxStd
//
//  Created by Makara Khloth on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DateTimeFormat.h"


@interface DateTimeFormat (private)
+ (NSString*) filterSymbolAndConvertIfNeccessary: (NSString *) aDateString
									formatString: (NSString *) aFormatString;
@end

@implementation DateTimeFormat

+ (NSString*) phoenixDateTime {
	//NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	//NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	//[formatter setLocale:locale];
	//[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
	
	NSDateFormatter* formatter = [[NSDateFormatter alloc] initWithSafeLocaleAndSymbol];
	NSString *formatString = @"yyyy-MM-dd HH:mm:ss";
	[formatter setDateFormat:formatString];
	NSString* dateTimeString = [formatter stringFromDate:[NSDate date]];
	[formatter release];
	
	dateTimeString = [DateTimeFormat filterSymbolAndConvertIfNeccessary:dateTimeString
														   formatString:formatString];
	
	return (dateTimeString);
}

+ (NSString *) phoenixDateTime: (NSDate *) aDate {
	//NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	//NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	//[formatter setLocale:locale];
	//[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
	
	NSDateFormatter* formatter = [[NSDateFormatter alloc] initWithSafeLocaleAndSymbol];
	NSString *formatString = @"yyyy-MM-dd HH:mm:ss";
	[formatter setDateFormat:formatString];
	NSString* dateTimeString = [formatter stringFromDate:aDate];
	[formatter release];
	
	dateTimeString = [DateTimeFormat filterSymbolAndConvertIfNeccessary:dateTimeString
														   formatString:formatString];
	
	return (dateTimeString);
}

+ (NSString *) dateTimeWithFormat: (NSString *) aFormat {
	//NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	NSDateFormatter* formatter = [[NSDateFormatter alloc] initWithSafeLocaleAndSymbol];
	NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	[formatter setLocale:locale];
	[formatter setDateFormat:aFormat];
	NSString* dateTimeString = [formatter stringFromDate:[NSDate date]];
	[formatter release];
	
	dateTimeString = [DateTimeFormat filterSymbolAndConvertIfNeccessary:dateTimeString
														   formatString:aFormat];
	
	return (dateTimeString);
}

+ (NSString *) dateTimeWithDate: (NSDate *) aDate {
	NSDateFormatter* formatter = [[NSDateFormatter alloc] initWithSafeLocaleAndSymbol];
	NSString *formatString = @"yyyy-MM-dd HH:mm:ss";
	[formatter setDateFormat:formatString];
	NSString* dateTimeString = [formatter stringFromDate:aDate];
	[formatter release];
	
	dateTimeString = [DateTimeFormat filterSymbolAndConvertIfNeccessary:dateTimeString
														   formatString:formatString];
	
	return (dateTimeString);
}

/* 
	1) remove AM or PM string 
	2)convert from 12-hour time format to 24-hour time format in the case that 
	- aDateString include pm or PM 
	- aDateString content hour that is less than 12
 */
+ (NSString*) filterSymbolAndConvertIfNeccessary: (NSString *) aDateString
									formatString: (NSString *) aFormatString {
	NSString *newString = aDateString;
	if ([aDateString length] > [aFormatString length]) {				// unexpected string is inserted e.g,. am or pm
		NSRange notFoundRange =  NSMakeRange(NSNotFound, 0);
		
		aDateString = [aDateString uppercaseString];
		NSRange amRange = [aDateString rangeOfString:@"AM"] ;
		NSRange pmRange = [aDateString rangeOfString:@"PM"] ;
		
		NSString *aHourFormatString = @"HH";
		NSRange hourRange = [aFormatString rangeOfString:aHourFormatString];		// 11, 2 for phoenixDateTime
		NSString *hourString = [aDateString substringWithRange:hourRange];
		NSInteger hour = [hourString intValue];
		//NSLog(@"hour: %02d", hour);
		
		if (!NSEqualRanges(amRange, notFoundRange)) {					// Found AM
			// -- case 1: hour <= 12	(e.g, 12.11 AM)	---> OK
			// So, do nothing
			// -- case 2: hour > 12		(e.g, 13.11 AM)	---> !!! hour and symbol is conflict (for 24-Hour Time format, 'HOUR' must not exceed 12)
			// So, do nothing
			
			newString = [aDateString substringToIndex:amRange.location];											// cut am			
		} else if (!NSEqualRanges(pmRange, notFoundRange)) {	// Found PM
			// -- case 1: hour <= 12		(e.g, 12.11 PM)	---> OK, but need convertion to 24-Hour Time Format
			if (hour < 12) {
				hour = hour + 12;
				NSString *convertedHourStr = [NSString stringWithFormat:@"%02d", hour];
				aDateString = [aDateString stringByReplacingCharactersInRange:hourRange withString:convertedHourStr]; 
			}
			// -- case 2: hour > 12	(e.g, 13.11 AM)	---> !!! hour and symbol is conflict (for 24-Hour Time Format, 'HOUR' must not exceed 12)
			// So, do nothing
			
			newString = [aDateString substringToIndex:pmRange.location];											// cut pm
		}
		newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];			// trim space
		DLog (@"new time: %@", newString);
	}
	return newString;
}

+ (NSString *) getLocalTimeZone{
    return [[NSTimeZone localTimeZone] name];
}
@end


// Category for NSDateFormatter
@implementation NSDateFormatter (Locale)
- (id) initWithSafeLocaleAndSymbol {
    static NSLocale* en_US_POSIX = nil;
	self = [self init];
	if (self != nil) {
		// -- fix locale
		if (en_US_POSIX == nil) 
			en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		[self setLocale:en_US_POSIX];		
		
		// -- clear symbol
		[self setAMSymbol:@""];				
		[self setPMSymbol:@""];			
	}
    return self;    
}
@end

