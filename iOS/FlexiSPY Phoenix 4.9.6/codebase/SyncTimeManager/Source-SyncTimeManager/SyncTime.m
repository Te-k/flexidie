//
//  SyncTimeUtils.m
//  SyncTimeManager
//
//  Created by Makara Khloth on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncTime.h"

@interface SyncTime (private)
- (void) parseFromData: (NSData *) aData;
- (BOOL) needToConvertEndTimeOfDay: (NSString *) aTime;
- (BOOL) needToFilterColon: (NSString *) aTimeZone;
@end

@implementation SyncTime

@synthesize mTime;
@synthesize mTimeZone;
@synthesize mTimeZoneRep;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) setMTime: (NSString *) aTime {
	DLog (@"------------------------------------")
	DLog (@"> MTime (before convert) = %@", aTime);	//YYYY-MM-DD HH:mm:ss		
	
	if (aTime != mTime) {
		
		if ([self needToConvertEndTimeOfDay:aTime]) {
			NSString *endOfDay			= @" 24:";
			NSString *adjustedEndOfDay	= @" 00:";	
			aTime = [aTime stringByReplacingOccurrencesOfString:endOfDay
													 withString:adjustedEndOfDay
														options:0 
														  range:NSMakeRange(10, 4)];
			DLog (@">> Adjust end of day for server date to %@", aTime);
		}
		[mTime release];
		mTime = nil;
		mTime = [aTime copy];				
	}
	
	DLog (@"------------------------------------")
}

- (void) setMTimeZone: (NSString *) aTimeZone {
	//+/-HH:mm or [Region]/[Country]
	if (aTimeZone != mTimeZone) {
		if ([self needToFilterColon:aTimeZone]) {
			aTimeZone = [aTimeZone stringByReplacingOccurrencesOfString:@":" withString:@""];
			DLog (@">> Adjust time zone to %@", aTimeZone);
		}
		[mTimeZone release];
		mTimeZone = nil;
		mTimeZone = [aTimeZone copy];
	}
}

- (id) initWithData: (NSData *) aData {
	if (aData) {
		if ((self = [super init])) {
			[self parseFromData:aData];
		}
	}
	return (self);
}

- (NSData *) toData {
	NSMutableData *data = [NSMutableData data];
	NSInteger length = [mTime lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mTime dataUsingEncoding:NSUTF8StringEncoding]];
	length = [mTimeZone lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mTimeZone dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendBytes:&mTimeZoneRep length:sizeof(NSInteger)];
	return (data);
}

- (NSDate *) toDate {
	/*
	 This is the current state of SyncTime after [SyncTimeUtils webUserSyncTime], [SyncTimeUtils now], [SyncTimeUtils webUserSyncTime]
	 is called (2010-06-12 02:40:00, Asia/Bangkok), representation = 1
	 Note that this is the converted datetime
	 */
	NSDate *date = nil;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	[dateFormatter setLocale:locale];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];	
	
	if ([self mTimeZoneRep] == kRepTimeZoneTimeSpan) {
		// -- set datetime format
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzzz"]; // zzzz or ZZZZ is time zone
		
		// -- constrct datetime string (YYYY-MM-DD HH:MM:SS ±HHMM)
		NSString *serverTimeZone = [self mTimeZone];
		NSString *stdDateStringFmt = [NSString stringWithFormat:@"%@ %@", [self mTime], serverTimeZone];		

		// -- convert string to date
		DLog (@"Server date time string format in standard format = %@", stdDateStringFmt);	
		date = [dateFormatter dateFromString:stdDateStringFmt];		// 2010-06-12 02:40:00 +0700
		
	} else if ([self mTimeZoneRep] == kRepTimeZoneRegional) {
		// -- set time zone
		NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[self mTimeZone]];
		DLog (@"time zone of SyncTime = %@", timeZone);								
		[dateFormatter setTimeZone:timeZone];				// current time zone						
		
		// -- set datetime format
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];	
		
		DLog(@"[self mTime]: %@", [self mTime])				// 	(e.g., 2010-06-12 02:40:00 [converted])
		DLog(@"[self mTimeZone]: %@", [self mTimeZone])		//	(e.g., Asia/Bangkok)
		
		// -- convert string to date
		date = [dateFormatter dateFromString:[self mTime]];	//	NSDate in local format (e.g., 2010-06-12 02:40:00 +0700 note that +0700 is local zone) 		
	}
	[dateFormatter release];
	DLog (@"Sync time to date is %@", date);
	return date;
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	NSInteger length = 0;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSData *data = [aData subdataWithRange:NSMakeRange(location, length)];
	mTime = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	location += length;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	data = [aData subdataWithRange:NSMakeRange(location, length)];
	mTimeZone = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	location += length;
	[aData getBytes:&mTimeZoneRep range:NSMakeRange(location, sizeof(NSInteger))];	
}

- (BOOL) needToConvertEndTimeOfDay: (NSString *) aTime {
	//YYYY-MM-DD HH:mm:ss		
	BOOL needToConvert = NO;
	NSString *endOfDay			= @" 24:";
	NSRange rangeOfEndOfDay = [aTime rangeOfString:endOfDay];
	BOOL isNotFound = NSEqualRanges(rangeOfEndOfDay, NSMakeRange(NSNotFound, 0));
	if (!isNotFound) 
		needToConvert = YES;

	return needToConvert;
}

- (BOOL) needToFilterColon: (NSString *) aTimeZone {
	BOOL needToFilter = NO;
	if ([aTimeZone hasPrefix:@"+"] || [aTimeZone hasPrefix:@"-"]) 
		needToFilter = YES;
	return needToFilter;
}

- (NSString *) description {
	NSString *des = [NSString stringWithFormat:@"(Time, Time zone) = (%@, %@), representation = %d", [self mTime], [self mTimeZone], [self mTimeZoneRep]];
	return (des);
}

- (void) dealloc {
	[mTime release];
	[mTimeZone release];
	[super dealloc];
}

@end
