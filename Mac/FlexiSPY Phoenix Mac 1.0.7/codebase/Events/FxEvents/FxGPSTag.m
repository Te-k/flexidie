//
//  FxGPSTag.m
//  FxEvents
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxGPSTag.h"

@implementation FxGPSTag

@synthesize dbId;
@synthesize longitude;
@synthesize latitude;
@synthesize altitude;
@synthesize mCoordinateAcc;
@synthesize cellId;
@synthesize mCellName;
@synthesize areaCode;
@synthesize networkId;
@synthesize countryCode;
@synthesize mNetworkName;

- (id) init
{
	if (self = [super init])
	{
		dbId = 0;
		longitude = 0.0;
		latitude = 0.0;
		altitude = 0.0;
		cellId = 0;
	}
	return (self);
}

- (void) encodeWithCoder: (NSCoder *) aCoder {
//	NSUInteger	dbId;
//	float	longitude;
//	float	latitude;
//	float	altitude;
//	FxCoordinateAcc	mCoordinateAcc;
//	NSInteger	cellId;
//	NSString*	mCellName;
//	NSString*	areaCode;
//	NSString*	networkId;
//	NSString*	countryCode;
//	NSString*	mNetworkName;
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self dbId]]];		// NSUInteger
	[aCoder encodeObject:[NSNumber numberWithFloat:[self longitude]]];			// float
	[aCoder encodeObject:[NSNumber numberWithFloat:[self latitude]]];			// float
	[aCoder encodeObject:[NSNumber numberWithFloat:[self altitude]]];			// float
	[aCoder encodeObject:[NSNumber numberWithInt:[self mCoordinateAcc]]];		// FxCoordinateAcc
	[aCoder encodeObject:[NSNumber numberWithInteger:[self cellId]]];			// NSInteger
	[aCoder encodeObject:[self mCellName]];
	[aCoder encodeObject:[self areaCode]];
	[aCoder encodeObject:[self networkId]];
	[aCoder encodeObject:[self countryCode]];
	[aCoder encodeObject:[self mNetworkName]];
}

- (id) initWithCoder: (NSCoder *)aDecoder {
	if ((self = [super init])) {
		[self setDbId:[[aDecoder decodeObject] unsignedIntValue]];
		[self setLongitude:[[aDecoder decodeObject] floatValue]];
		[self setLatitude:[[aDecoder decodeObject] floatValue]];
		[self setAltitude:[[aDecoder decodeObject] floatValue]];
		[self setMCoordinateAcc:(FxCoordinateAcc)[[aDecoder decodeObject] intValue]];
 		[self setCellId:[[aDecoder decodeObject] integerValue]];
		[self setMCellName:[aDecoder decodeObject]];
		[self setAreaCode:[aDecoder decodeObject]];
		[self setNetworkId:[aDecoder decodeObject]];
		[self setCountryCode:[aDecoder decodeObject]];		
		[self setMNetworkName:[aDecoder decodeObject]];				
	}
	return self;
}

- (void) dealloc
{
	[areaCode release];
	[networkId release];
	[countryCode release];
    [mCellName release];
    [mNetworkName release];
	[super dealloc];
}

@end
