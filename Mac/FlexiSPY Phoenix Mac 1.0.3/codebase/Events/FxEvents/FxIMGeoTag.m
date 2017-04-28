//
//  FxIMGeoTag.m
//  FxEvents
//
//  Created by Makara Khloth on 1/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FxIMGeoTag.h"

@implementation FxIMGeoTag

@synthesize mLongitude, mLatitude, mAltitude, mHorAccuracy, mPlaceName;

- (void)encodeWithCoder:(NSCoder *)aCoder { 
	[aCoder encodeObject:[NSNumber numberWithFloat:[self mLongitude]]];
	[aCoder encodeObject:[NSNumber numberWithFloat:[self mLatitude]]];
	[aCoder encodeObject:[NSNumber numberWithFloat:[self mAltitude]]];
	[aCoder encodeObject:[NSNumber numberWithFloat:[self mHorAccuracy]]];
	[aCoder encodeObject:[self mPlaceName]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		[self setMLongitude:[[aDecoder decodeObject] floatValue]];
		[self setMLatitude:[[aDecoder decodeObject] floatValue]];
		[self setMAltitude:[[aDecoder decodeObject] floatValue]];
		[self setMHorAccuracy:[[aDecoder decodeObject] floatValue]];
		[self setMPlaceName:[aDecoder decodeObject]];
	}
	return (self);
}

- (id)copyWithZone:(NSZone *)zone {
	FxIMGeoTag *me = [[[self class] allocWithZone:zone] init];
	if (me) {
		[me setMLongitude:[self mLongitude]];
		[me setMLatitude:[self mLatitude]];
		[me setMAltitude:[self mAltitude]];
		[me setMHorAccuracy:[self mHorAccuracy]];
		
		NSString *placeName = [[self mPlaceName] copyWithZone:zone];
		[me setMPlaceName:placeName];
		[placeName release];
	}
	return (me);
}

- (NSString *) description {
	NSString *description = [NSString stringWithFormat:@"mLogitude = %f, mLatitude = %f, mAltitude = %f, mHorAccuracy = %f,"
							 "mPlaceName = %@", [self mLongitude], [self mLatitude], [self mAltitude], [self mHorAccuracy],
							 [self mPlaceName]];
	return (description);
}

- (void) dealloc {
	[mPlaceName release];
	[super dealloc];
}

@end
