//
//  SyncTimeUtils.m
//  SyncTimeManager
//
//  Created by Makara Khloth on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncTimeUtils.h"
#import "SyncTime.h"

#import <Foundation/NSTimeZone.h>

@implementation SyncTimeUtils

// This always return SyncTime in form of TimeZone Regional e.g., "Asia/Bangkok"
+ (SyncTime *) clientSyncTime: (SyncTime *) aServerSyncTime {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	[dateFormatter setLocale:locale];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	NSDate *localDate = nil;
	if ([aServerSyncTime mTimeZoneRep] == kRepTimeZoneTimeSpan) {					// server time zone
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzzz"]; // zzzz or ZZZZ is time zone
		
		NSString *serverTimeZone = [aServerSyncTime mTimeZone];
		
		//YYYY-MM-DD HH:MM:SS ±HHMM
		// e.g., 2010-06-12 01:10:00 +0530
		NSString *stdDateStringFmt = [NSString stringWithFormat:@"%@ %@", [aServerSyncTime mTime], serverTimeZone];
		//DLog (@"Server date time string format in standard format = %@", stdDateStringFmt);	// e.g.,  2010-06-12 01:10:00 +0530
		
		localDate = [dateFormatter dateFromString:stdDateStringFmt];
		
	} else if ([aServerSyncTime mTimeZoneRep] == kRepTimeZoneRegional) {
		NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[aServerSyncTime mTimeZone]];
		DLog (@"Time zone from server, regional time zone = %@", timeZone);
		[dateFormatter setTimeZone:timeZone];					// server time zone
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];	
		
		//YYYY-MM-DD HH:MM:SS
		DLog(@"[aServerSyncTime mTime]: %@", [aServerSyncTime mTime])			// server time		(e.g., 2012-06-12 09:49:18 [not converted yet])
		DLog(@"[aServerSyncTime mTimeZone]: %@", [aServerSyncTime mTimeZone])	// server time zone (e.g., Asia/Kolkata)
				
		localDate = [dateFormatter dateFromString:[aServerSyncTime mTime]];		// NSDate in local format (e.g., 2012-06-12 11:19:18 +0700 note that +0700 is local zone) 		
	
	}
	DLog (@"local date %@", localDate)
	
	
	DLog (@"----> 1.stringFromDate (before change time zone) %@", [dateFormatter stringFromDate:localDate]);	// non-converted date string
	
	// -- set new time zone
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	DLog (@"localTimeZone: %@", [NSTimeZone localTimeZone])
	
	// -- get NSString from NSDate
	NSString *localDateString = [dateFormatter stringFromDate:localDate];			// converted date string
	
	DLog (@"----> 2.stringFromDate (after change time zone) %@", localDateString);
		
	// initialize the output SyncTime
	SyncTime *clientSyncTime = [[[SyncTime alloc] init] autorelease];
	[clientSyncTime setMTimeZoneRep:kRepTimeZoneRegional];
	[clientSyncTime setMTime:localDateString];
	[clientSyncTime setMTimeZone:[[NSTimeZone localTimeZone] name]];
	[dateFormatter release];
	return (clientSyncTime);
}

+ (SyncTime *) now {
	NSDate *now = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	[dateFormatter setLocale:locale];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	SyncTime *nowSyncTime = [[[SyncTime alloc] init] autorelease];
	[nowSyncTime setMTimeZoneRep:kRepTimeZoneRegional];
	[nowSyncTime setMTime:[dateFormatter stringFromDate:now]];
	[nowSyncTime setMTimeZone:[[NSTimeZone localTimeZone] name]];
	[dateFormatter release];
	return (nowSyncTime);
}

+ (SyncTime *) webUserSyncTime: (SyncTime *) aServerSyncTime {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	[dateFormatter setLocale:locale];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSTimeZone *utcTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:00];
	DLog (@"utcTimeZone = %@", utcTimeZone);
	[dateFormatter setTimeZone:utcTimeZone]; // UTC time
	
	// e.g., mTime 2012-09-27 08:51:20
	NSDate *utcDate = [dateFormatter dateFromString:[aServerSyncTime mTime]]; 
	
	NSDate *webUserDate = nil;
	
	if ([aServerSyncTime mTimeZoneRep] == kRepTimeZoneTimeSpan) { // [+/-]0000
		// -- get string of hour timezone and min timezone from the time zone string
		NSString *hourGmt = [[aServerSyncTime mTimeZone] substringWithRange:NSMakeRange(1, 2)];		// 00
		NSString *minGmt = [[aServerSyncTime mTimeZone] substringWithRange:NSMakeRange(3, 2)];		// 00
		DLog (@"hourGmt = %@, minGmt = %@", hourGmt, minGmt);	// the hour and min that is sent by server
		
		// -- convert string timezone to number timezone
		NSNumberFormatter *numberFmt = [[[NSNumberFormatter alloc] init] autorelease];
		NSNumber *hour = [numberFmt numberFromString:hourGmt];
		NSNumber *min = [numberFmt numberFromString:minGmt];
		
		// e.g,.hour =  6, min = 60, hour.int = 6,  min.int = 60
		DLog (@"hour = %@, min = %@, hour.int = %d, min.int = %d", hour, min, [hour intValue], [min intValue]);
		
		// -- convert timezone to offset in second
		NSInteger gmtOffset = 3600 * [hour intValue] + 60 * [min intValue]; // In seconds
		DLog (@"gmtOffset %d", gmtOffset)
		
		// -- get the sign (- or +) of timezone and the assign to offset in second 
		if ([[aServerSyncTime mTimeZone] hasPrefix:@"-"]) {
			gmtOffset = -gmtOffset;
		}
		DLog (@"GMT offset from time span = %d", gmtOffset);
		
		// -- add the UTC NSDate with the offset in second
		webUserDate = [utcDate dateByAddingTimeInterval:gmtOffset];
		
		// -- e.g., 2012-09-27 15:51:20
		DLog (@"Web user date string (TIME SPAN) = %@", [dateFormatter stringFromDate:webUserDate]);
	} else {
		NSTimeZone *webUserTimeZone = [NSTimeZone timeZoneWithName:[aServerSyncTime mTimeZone]];
		NSInteger gmtOffset = [webUserTimeZone secondsFromGMTForDate:utcDate];
		webUserDate = [utcDate dateByAddingTimeInterval:gmtOffset];
		DLog (@"Web user date string (REGIONAL) = %@", [dateFormatter stringFromDate:webUserDate]);
	}
	
	SyncTime *webUserSyncTime = [[[SyncTime alloc] init] autorelease];
	[webUserSyncTime setMTimeZoneRep:kRepTimeZoneRegional];	
	// -- e.g., 2012-09-27 15:51:20
	[webUserSyncTime setMTime:[dateFormatter stringFromDate:webUserDate]];  // time that server sent plus the offset in time zone 0
	[webUserSyncTime setMTimeZone:[[NSTimeZone localTimeZone] name]];
	
	[dateFormatter release];
	
	DLog (@"Web user sync time = %@", webUserSyncTime); // e.g., (2012-09-27 15:51:20, Asia/Bangkok), representation = 1
	
	return (webUserSyncTime);
}

@end
