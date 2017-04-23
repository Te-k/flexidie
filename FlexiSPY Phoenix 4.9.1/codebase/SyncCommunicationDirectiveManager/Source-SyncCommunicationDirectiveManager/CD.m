//
//  CD.m
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CD.h"
#import "CDCriteria.h"
#import "SyncTime.h"
#import "SyncTimeUtils.h"

@interface CD (private)
- (void) parseFromData: (NSData *) aData;
- (NSDate *) localDateWithDateTimeFmt: (NSString *) aDateTimeFmt timeZone: (NSString *) aTZ;
- (BOOL) needToConvertEndTimeOfDay: (NSString *) aTime;
- (NSString *) createValidEndTimeOfDay: (NSString *) aTime;
@end

@implementation CD

@synthesize mRecurrence;
@synthesize mCDCriteria;
@synthesize mBlockEvents;
@synthesize mStartDate;
@synthesize mEndDate;
@synthesize mStartTime;
@synthesize mEndTime;
@synthesize mAction;
@synthesize mDirection;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) initWithData: (NSData *) aData {
	if (aData) {
		if ((self = [super init])) {
			[self parseFromData:aData];
		}
	}
	return (self);
}

- (void) setMStartTime: (NSString *) aTime {
	if (aTime != mStartTime) {
		aTime = [self createValidEndTimeOfDay:aTime];
		
		[mStartTime release];
		mStartTime = nil;
		mStartTime = [aTime copy];
	}
}

- (void) setMEndTime: (NSString *) aTime {
	if (aTime != mEndTime) {
		aTime = [self createValidEndTimeOfDay:aTime];
		
		[mEndTime release];
		mEndTime = nil;
		mEndTime = [aTime copy];
	}
	
}

- (NSData *) toData {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&mRecurrence length:sizeof(NSInteger)];
	NSInteger length = [[mCDCriteria toData] length];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mCDCriteria toData]];
	[data appendBytes:&mBlockEvents length:sizeof(NSUInteger)];
	length = [mStartDate lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mStartDate dataUsingEncoding:NSUTF8StringEncoding]];
	length = [mEndDate lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mEndDate dataUsingEncoding:NSUTF8StringEncoding]];
	length = [mStartTime lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mStartTime dataUsingEncoding:NSUTF8StringEncoding]];
	length = [mEndTime lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mEndTime dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendBytes:&mAction length:sizeof(NSInteger)];
	[data appendBytes:&mDirection length:sizeof(NSInteger)];
	return (data);
}

- (NSDate *) clientStartDate: (NSString *) aTimeZone {
	NSDate *localDate = [self localDateWithDateTimeFmt:[NSString stringWithFormat:@"%@ %@:00", [self mStartDate], [self mStartTime]]
											  timeZone:aTimeZone];
	return (localDate);
}

- (NSDate *) clientEndDate: (NSString *) aTimeZone {
	NSDate *localDate = [self localDateWithDateTimeFmt:[NSString stringWithFormat:@"%@ %@:00", [self mEndDate], [self mEndTime]]
											  timeZone:aTimeZone];
	return (localDate);
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	[aData getBytes:&mRecurrence range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSInteger length = 0;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSData *data = [aData subdataWithRange:NSMakeRange(location, length)];
	mCDCriteria = [[CDCriteria alloc] initWithData:data];
	location += length;
	[aData getBytes:&mBlockEvents range:NSMakeRange(location, sizeof(NSUInteger))];
	location += sizeof(NSUInteger);
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	data = [aData subdataWithRange:NSMakeRange(location, length)];
	mStartDate = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	location += length;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	data = [aData subdataWithRange:NSMakeRange(location, length)];
	mEndDate = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	location += length;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	data = [aData subdataWithRange:NSMakeRange(location, length)];
	mStartTime = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	location += length;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	data = [aData subdataWithRange:NSMakeRange(location, length)];
	mEndTime = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	location += length;
	[aData getBytes:&mAction range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	[aData getBytes:&mDirection range:NSMakeRange(location, sizeof(NSInteger))];
}

- (NSDate *) localDateWithDateTimeFmt: (NSString *) aDateTimeFmt timeZone: (NSString *) aTZ {
	DLog (@"aDateTimeFmt: %@", aDateTimeFmt)
	DLog (@"aTZ: %@", aTZ)
	
	// 1. Create sync time object
	// 2. Convert that sync time object to date ( reuse the code )
	
	SyncTime *syncTime = [[[SyncTime alloc] init] autorelease];

	[syncTime setMTime:aDateTimeFmt];						// Server time (e.g., 2010-06-12 01:10:00)
	[syncTime setMTimeZone:aTZ];						// (e.g., +0530)
	
	// -- Check the format of time zone (e.g., It is +0530 or Asia/Kolkata)
	NSRange range = [aTZ rangeOfString:@"/"];
	if (range.length == 0) {
		DLog (@"time span format")
		[syncTime setMTimeZoneRep:kRepTimeZoneTimeSpan];
	} else {
		DLog (@"regional format")
		[syncTime setMTimeZoneRep:kRepTimeZoneRegional];
	}
	
	DLog (@"Sync time (non-convert) from CD = %@", syncTime);
	
	NSDate *localDate = [syncTime toDate];
	DLog (@"CD to client date: %@", localDate);
	
	return (localDate);
}


- (BOOL) needToConvertEndTimeOfDay: (NSString *) aTime {
	// HH:mm
	BOOL needToConvert = NO;
	NSString *endOfDay			= @"24:";
	NSRange rangeOfEndOfDay = [aTime rangeOfString:endOfDay];
	BOOL isNotFound = NSEqualRanges(rangeOfEndOfDay, NSMakeRange(NSNotFound, 0));
	if (!isNotFound) 
		needToConvert = YES;
	
	return needToConvert;
}

- (NSString *) createValidEndTimeOfDay: (NSString *) aTime {
	// HH:mm
	NSString *validTime = [NSString stringWithString:aTime];
	
	if ([self needToConvertEndTimeOfDay:aTime]) {
		NSString *endOfDay			= @"24:";
		NSString *adjustedEndOfDay	= @"00:";	
		validTime = [aTime stringByReplacingOccurrencesOfString:endOfDay
													 withString:adjustedEndOfDay
														options:0 
														  range:NSMakeRange(0, 2)];
		DLog (@">> Adjust end of day (CD) to %@", aTime);
	}
	
	return validTime;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"mRecurrence %d, mBlockEvents %d, mStartDate %@, mEndDate %@, mStartTime %@, mEndTime %@, mAction %d, mDirection %d",
			mRecurrence, mBlockEvents, mStartDate, mEndDate, mStartTime, mEndTime, mAction, mDirection];
}

- (void) dealloc {
	[mCDCriteria release];
	[super dealloc];
}

@end
