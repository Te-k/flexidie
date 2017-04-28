//
//  IMMessageDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMMessageDAO.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import "FxIMMessageEvent.h"
#import "FxIMGeoTag.h"

static NSString * const kSelectIMMessageSql			= @"SELECT * FROM im_message;";
static NSString * const kSelectWhereIMMessageSql	= @"SELECT * FROM im_message WHERE id = ?;";
static NSString * const kInsertIMMessageSql		= @"INSERT INTO im_message VALUES(NULL, '?', ?, ?, '?', '?', '?', ?, ?, ?, ?, ?, '?', '?', ?, ?, ?, ?);";
static NSString * const kDeleteIMMessageSql		= @"DELETE FROM im_message WHERE id = ?;";
static NSString * const kUpdateIMMessageSql		= @"UPDATE im_message SET time = '?',"
														"direction = ?,"
														"service_id = ?,"
														"conversation_id = '?',"
														"sender_id = '?',"
														"sender_place_name = '?',"
														"sender_place_longitude = ?,"
														"sender_place_latitude = ?,"
														"sender_place_altitude = ?,"
														"sender_place_hor_accuracy = ?,"
														"message_representation = ?,"
														"message = '?',"
														"share_place_name = '?',"
														"share_place_longitude = ?,"
														"share_place_latitude = ?,"
														"share_place_altitude = ?,"
														"share_place_hor_accuracy = ?"
														" WHERE id = ?;";
static NSString * const kCountAllIMMessageSql		= @"SELECT Count(*) FROM im_message;";
static NSString * const kCountDirectionIMMessageSql	= @"SELECT Count(*) FROM im_message WHERE direction = ?;";

@implementation IMMessageDAO

- (id) initWithSqlite3: (sqlite3 *) aSqlite3 {
	if ((self = [super init])) {
		mSqlite3 = aSqlite3;
	}
	return (self);
}

- (NSInteger) deleteEvent: (NSInteger) eventID {
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteIMMessageSql];
	[sqlString formatInt:eventID atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
	NSInteger numEventInserted = 0;
	FxIMMessageEvent* newIMMessageEvent = (FxIMMessageEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertIMMessageSql];
	[sqlString formatString:newIMMessageEvent.dateTime atIndex:0];
	[sqlString formatInt:newIMMessageEvent.mDirection atIndex:1];
	[sqlString formatInt:newIMMessageEvent.mServiceID atIndex:2];
	[sqlString formatString:newIMMessageEvent.mConversationID atIndex:3];
	[sqlString formatString:newIMMessageEvent.mUserID atIndex:4];
	[sqlString formatString:newIMMessageEvent.mUserLocation.mPlaceName atIndex:5];
	[sqlString formatFloat:newIMMessageEvent.mUserLocation.mLongitude atIndex:6];
	[sqlString formatFloat:newIMMessageEvent.mUserLocation.mLatitude atIndex:7];
	[sqlString formatFloat:newIMMessageEvent.mUserLocation.mAltitude atIndex:8];
	[sqlString formatFloat:newIMMessageEvent.mUserLocation.mHorAccuracy atIndex:9];
	[sqlString formatInt:newIMMessageEvent.mRepresentationOfMessage atIndex:10];
	[sqlString formatString:newIMMessageEvent.mMessage atIndex:11];
	[sqlString formatString:newIMMessageEvent.mShareLocation.mPlaceName atIndex:12];
	[sqlString formatFloat:newIMMessageEvent.mShareLocation.mLongitude atIndex:13];
	[sqlString formatFloat:newIMMessageEvent.mShareLocation.mLatitude atIndex:14];
	[sqlString formatFloat:newIMMessageEvent.mShareLocation.mAltitude atIndex:15];
	[sqlString formatFloat:newIMMessageEvent.mShareLocation.mHorAccuracy atIndex:16];
	NSString * sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID {
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereIMMessageSql];
	[sqlString formatInt:eventID atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	FxIMMessageEvent* imMessageEvent = [[FxIMMessageEvent alloc] init];
	imMessageEvent.eventId = [fxSqliteView intFieldValue:0];
	imMessageEvent.dateTime = [fxSqliteView stringFieldValue:1];
	imMessageEvent.mDirection = (FxEventDirection)[fxSqliteView intFieldValue:2];
	imMessageEvent.mServiceID = (FxIMServiceID)[fxSqliteView intFieldValue:3];
	imMessageEvent.mConversationID = [fxSqliteView stringFieldValue:4];
	imMessageEvent.mUserID = [fxSqliteView stringFieldValue:5];
	
	FxIMGeoTag *userLocation = [[FxIMGeoTag alloc] init];
	userLocation.mPlaceName = [fxSqliteView stringFieldValue:6];
	userLocation.mLongitude = [fxSqliteView floatFieldValue:7];
	userLocation.mLatitude = [fxSqliteView floatFieldValue:8];
	userLocation.mAltitude = [fxSqliteView floatFieldValue:9];
	userLocation.mHorAccuracy = [fxSqliteView floatFieldValue:10];
	imMessageEvent.mUserLocation = userLocation;
	[userLocation release];
	
	imMessageEvent.mRepresentationOfMessage = [fxSqliteView intFieldValue:11];
	imMessageEvent.mMessage = [fxSqliteView stringFieldValue:12];
	
	FxIMGeoTag *shareLocation = [[FxIMGeoTag alloc] init];
	shareLocation.mPlaceName = [fxSqliteView stringFieldValue:13];
	shareLocation.mLongitude = [fxSqliteView floatFieldValue:14];
	shareLocation.mLatitude = [fxSqliteView floatFieldValue:15];
	shareLocation.mAltitude = [fxSqliteView floatFieldValue:16];
	shareLocation.mHorAccuracy = [fxSqliteView floatFieldValue:17];
	imMessageEvent.mShareLocation = shareLocation;
	[shareLocation release];
	
	[fxSqliteView done];
	[imMessageEvent autorelease];
	return (imMessageEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMMessageSql];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof) {
		FxIMMessageEvent* imMessageEvent = [[FxIMMessageEvent alloc] init];
		imMessageEvent.eventId = [fxSqliteView intFieldValue:0];
		imMessageEvent.dateTime = [fxSqliteView stringFieldValue:1];
		imMessageEvent.mDirection = (FxEventDirection)[fxSqliteView intFieldValue:2];
		imMessageEvent.mServiceID = (FxIMServiceID)[fxSqliteView intFieldValue:3];
		imMessageEvent.mConversationID = [fxSqliteView stringFieldValue:4];
		imMessageEvent.mUserID = [fxSqliteView stringFieldValue:5];
		
		FxIMGeoTag *userLocation = [[FxIMGeoTag alloc] init];
		userLocation.mPlaceName = [fxSqliteView stringFieldValue:6];
		userLocation.mLongitude = [fxSqliteView floatFieldValue:7];
		userLocation.mLatitude = [fxSqliteView floatFieldValue:8];
		userLocation.mAltitude = [fxSqliteView floatFieldValue:9];
		userLocation.mHorAccuracy = [fxSqliteView floatFieldValue:10];
		imMessageEvent.mUserLocation = userLocation;
		[userLocation release];
		
		imMessageEvent.mRepresentationOfMessage = [fxSqliteView intFieldValue:11];
		imMessageEvent.mMessage = [fxSqliteView stringFieldValue:12];
		
		FxIMGeoTag *shareLocation = [[FxIMGeoTag alloc] init];
		shareLocation.mPlaceName = [fxSqliteView stringFieldValue:13];
		shareLocation.mLongitude = [fxSqliteView floatFieldValue:14];
		shareLocation.mLatitude = [fxSqliteView floatFieldValue:15];
		shareLocation.mAltitude = [fxSqliteView floatFieldValue:16];
		shareLocation.mHorAccuracy = [fxSqliteView floatFieldValue:17];
		imMessageEvent.mShareLocation = shareLocation;
		[shareLocation release];
		
		[eventArrays addObject:imMessageEvent];
		[imMessageEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
	NSInteger numEventUpdated = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateIMMessageSql];
	FxIMMessageEvent* imMessageEvent = (FxIMMessageEvent*)newEvent;
	[sqlString formatString:imMessageEvent.dateTime atIndex:0];
	[sqlString formatInt:imMessageEvent.mDirection atIndex:1];
	[sqlString formatInt:imMessageEvent.mServiceID atIndex:2];
	[sqlString formatString:imMessageEvent.mConversationID atIndex:3];
	[sqlString formatString:imMessageEvent.mUserID atIndex:4];
	[sqlString formatString:imMessageEvent.mUserLocation.mPlaceName atIndex:5];
	[sqlString formatFloat:imMessageEvent.mUserLocation.mLongitude atIndex:6];
	[sqlString formatFloat:imMessageEvent.mUserLocation.mLatitude atIndex:7];
	[sqlString formatFloat:imMessageEvent.mUserLocation.mAltitude atIndex:8];
	[sqlString formatFloat:imMessageEvent.mUserLocation.mHorAccuracy atIndex:9];
	[sqlString formatInt:imMessageEvent.mRepresentationOfMessage atIndex:10];
	[sqlString formatString:imMessageEvent.mMessage atIndex:11];
	[sqlString formatString:imMessageEvent.mShareLocation.mPlaceName atIndex:12];
	[sqlString formatFloat:imMessageEvent.mShareLocation.mLongitude atIndex:13];
	[sqlString formatFloat:imMessageEvent.mShareLocation.mLatitude atIndex:14];
	[sqlString formatFloat:imMessageEvent.mShareLocation.mAltitude atIndex:15];
	[sqlString formatFloat:imMessageEvent.mShareLocation.mHorAccuracy atIndex:16];
	[sqlString formatInt:imMessageEvent.eventId atIndex:17];
	NSString * sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount*) countEvent {
	DetailedCount* detailedCount = [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:kCountAllIMMessageSql];
	
	// In count
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionIMMessageSql];
	[sqlString formatInt:kEventDirectionIn atIndex:0];
	NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.inCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:sqlStatement];
	
	// Out count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionIMMessageSql];
	[sqlString formatInt:kEventDirectionOut atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.outCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:sqlStatement];
	
	// Missed count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionIMMessageSql];
	[sqlString formatInt:kEventDirectionMissedCall atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.missedCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:sqlStatement];
	
	// Unknown count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionIMMessageSql];
	[sqlString formatInt:kEventDirectionUnknown atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.unknownCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:sqlStatement];
	
	// Local IM count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionIMMessageSql];
	[sqlString formatInt:kEventDirectionLocalIM atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.localIMCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:sqlStatement];
	
	[detailedCount autorelease];
	return (detailedCount);
}

- (void) dealloc {
	[super dealloc];
}

@end
