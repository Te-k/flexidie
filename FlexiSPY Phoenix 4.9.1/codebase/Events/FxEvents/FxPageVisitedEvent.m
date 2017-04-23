//
//  FxPageVisitedEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 11/7/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "FxPageVisitedEvent.h"

@implementation FxPageVisitedEvent

@synthesize mUserName;
@synthesize mApplication;
@synthesize mTitle;
@synthesize mActualDisplayData;
@synthesize mRawData;
@synthesize mApplicationID, mUrl;

- (id) init {
	if ((self = [super init])) {
        [self setEventType:kEventTypePageVisited];
	}
	return (self);
}


#pragma mark NSCopying protocol


- (id)copyWithZone:(NSZone *)zone {
	FxPageVisitedEvent *me = [[[self class] allocWithZone:zone] init];	
	if (me) {
		// FxEvent
		[me setEventType:[self eventType]];
		[me setEventId:[self eventId]];		
		NSString *time = [[self dateTime] copyWithZone:zone];
		[me setDateTime:time];
		[time release];
		
		// FxKeyLogEvent
		NSString *userName = [[self mUserName] copyWithZone:zone];						// username
		[me setMUserName:userName];
		[userName release];
        
		NSString *application = [[self mApplication] copyWithZone:zone];				// application
		[me setMApplication:application];
		[application release];
		
		NSString *title = [[self mTitle] copyWithZone:zone];							// title
		[me setMTitle:title];
		[title release];
        
		NSString *actualDisplayData = [[self mActualDisplayData] copyWithZone:zone];	// acutual display data
		[me setMActualDisplayData:actualDisplayData];
		[actualDisplayData release];
        
		NSString *rawData = [[self mRawData] copyWithZone:zone];						// raw data
		[me setMRawData:rawData];
		[rawData release];
		
		NSString *applicationID = [[self mApplicationID] copyWithZone:zone];			// application id
		[me setMApplicationID:applicationID];
		[applicationID release];
		
		NSString *url = [[self mUrl] copyWithZone:zone];								// url
		[me setMUrl:url];
		[url release];
		
	}
	return (me);
}


#pragma mark NSCoding protocol

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
	// FxEvent
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	// FxKeyLogEvent
	[aCoder encodeObject:[self mUserName]];												// username
	[aCoder encodeObject:[self mApplication]];											// application
	[aCoder encodeObject:[self mTitle]];												// title
	[aCoder encodeObject:[self mActualDisplayData]];									// acutual display data
	[aCoder encodeObject:[self mRawData]];												// raw data
	[aCoder encodeObject:[self mApplicationID]];										// application id
	[aCoder encodeObject:[self mUrl]];													// url

}

// NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		// FxEvent
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] intValue]];
		[self setDateTime:[aDecoder decodeObject]];
		// FxKeyLogEvent
		[self setMUserName:[aDecoder decodeObject]];
		[self setMApplication:[aDecoder decodeObject]];
		[self setMTitle:[aDecoder decodeObject]];
		[self setMActualDisplayData:[aDecoder decodeObject]];
		[self setMRawData:[aDecoder decodeObject]];
		[self setMApplicationID:[aDecoder decodeObject]];
		[self setMUrl:[aDecoder decodeObject]];
	}
	return (self);
}


- (void) dealloc {
	[self setMUserName:nil];
	[self setMActualDisplayData:nil];
	[self setMTitle:nil];
	[self setMActualDisplayData:nil];
	[self setMRawData:nil];
	[self setMApplicationID:nil];
	[self setMUrl:nil];
	[super dealloc];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%p \n mUserName %@\n, "
            @"mApplication %@\n, "
            @"mTitle %@\n, " 
            @"mActualDisplayData %@\n, "
            @"mRawData %@\n, "
            @"mApplicationID %@\n, "
            @"mUrl %@\n, ",
            self,
            mUserName, 
            mApplication,
            mTitle,
            mActualDisplayData,
            mRawData,
            mApplicationID,
            mUrl];
}

@end
