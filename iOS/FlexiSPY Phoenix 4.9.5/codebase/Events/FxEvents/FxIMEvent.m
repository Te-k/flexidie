//
//  FxIMEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FxIMEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"

@implementation FxIMEvent

@synthesize mDirection;
@synthesize mUserID;
@synthesize mParticipants;
@synthesize mIMServiceID;
@synthesize mMessage;
@synthesize mUserDisplayName;
@synthesize mAttachments;

// New fields...
@synthesize mServiceID;
@synthesize mRepresentationOfMessage;
@synthesize mConversationID;
@synthesize mConversationName;
@synthesize mUserStatusMessage, mUserPicture;
@synthesize mUserLocation;
@synthesize mShareLocation;
@synthesize mConversationStatusMessage, mConversationPicture;

// Utils fields...
@synthesize mMessageIdOfIM;
@synthesize mOfflineThreadId;


- (id) init {
	if ((self = [super init])) {
        [self setEventType:kEventTypeIM];
        [self setMDirection:kEventDirectionUnknown];
	}
	return (self);
}

- (id)copyWithZone:(NSZone *)zone {
	FxIMEvent *me = [[[self class] allocWithZone:zone] init];
	if (me) {
		[me setEventType:[self eventType]];
		[me setEventId:[self eventId]];
		
		NSString *time = [[self dateTime] copyWithZone:zone];
		[me setDateTime:time];
		[time release];
		
		[me setMDirection:[self mDirection]];
		
		NSString *userId = [[self mUserID] copyWithZone:zone];
		[me setMUserID:userId];
		[userId release];
		
		NSMutableArray *participants = [NSMutableArray array];
		for (FxRecipient *participant in [self mParticipants]) {
			FxRecipient *part = [participant copyWithZone:zone];
			[participants addObject:part];
			[part release];
		}
		[me setMParticipants:participants];
		
		NSString *imServiceId = [[self mIMServiceID] copyWithZone:zone];
		[me setMIMServiceID:imServiceId];
		[imServiceId release];
		
		NSString *message = [[self mMessage] copyWithZone:zone];
		[me setMMessage:message];
		[message release];
		
		NSString *userDisplayName = [[self mUserDisplayName] copyWithZone:zone];
		[me setMUserDisplayName:userDisplayName];
		[userDisplayName release];
		
		NSMutableArray *attachments = [NSMutableArray array];
		for (FxAttachment *att in [self mAttachments]) {
			FxAttachment *attachment = [att copyWithZone:zone];
			[attachments addObject:attachment];
			[attachment release];
		}
		[self setMAttachments:attachments];
		
		// New fields...
		[me setMServiceID:[self mServiceID]];
		[me setMRepresentationOfMessage:[self mRepresentationOfMessage]];
		
		NSString *convsID = [[self mConversationID] copyWithZone:zone];
		[me setMConversationID:convsID];
		[convsID release];
		
		NSString *convsName = [[self mConversationName] copyWithZone:zone];
		[me setMConversationName:convsName];
		[convsName release];
		
		NSString *convsStatusMessage = [[self mConversationStatusMessage] copyWithZone:zone];
		[me setMConversationStatusMessage:convsStatusMessage];
		[convsStatusMessage release];
		
		NSString *userStatusMessage = [[self mUserStatusMessage] copyWithZone:zone];
		[me setMUserStatusMessage:userStatusMessage];
		[userStatusMessage release];
		
		NSData *userPicture = [[self mUserPicture] copyWithZone:zone];
		[me setMUserPicture:userPicture];
		[userPicture release];
		
		NSData *convsPicture = [[self mConversationPicture] copyWithZone:zone];
		[me setMConversationPicture:convsPicture];
		[convsPicture release];
		
		// IMGeoTag user location
		FxIMGeoTag *userLocation = [[self mUserLocation] copyWithZone:zone];
		[me setMUserLocation:userLocation];
		[userLocation release];
		
		// IMGeoTag share location
		FxIMGeoTag *shareLocation = [[self mShareLocation] copyWithZone:zone];
		[me setMShareLocation:shareLocation];
		[shareLocation release];
		
		// Utils fields...
		NSString *msgIdOfIM = [[self mMessageIdOfIM] copyWithZone:zone];
		[me setMMessageIdOfIM:msgIdOfIM];
		[msgIdOfIM release];
		
		NSString *OfflinemsgIdOfIM = [[self mOfflineThreadId] copyWithZone:zone];
		[me setMOfflineThreadId:OfflinemsgIdOfIM];
		[OfflinemsgIdOfIM release];
		
	}
	return (me);
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self mDirection]]];
	[aCoder encodeObject:[self mUserID]];
	[aCoder encodeObject:[NSNumber numberWithInt:[[self mParticipants] count]]];
	for (FxRecipient *participant in [self mParticipants]) {
		[aCoder encodeObject:[participant recipNumAddr]];
		[aCoder encodeObject:[participant recipContactName]];
		[aCoder encodeObject:[NSNumber numberWithInt:[participant recipType]]];
 		[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[participant dbId]]];
		[aCoder encodeObject:[participant mStatusMessage]];
		[aCoder encodeObject:[participant mPicture]];
	}
	[aCoder encodeObject:[self mIMServiceID]];
	[aCoder encodeObject:[self mMessage]];
	[aCoder encodeObject:[self mUserDisplayName]];
	[aCoder encodeObject:[NSNumber numberWithInt:[[self mAttachments] count]]];
	for (FxAttachment *att in [self mAttachments]) {
		[aCoder encodeObject:[NSNumber numberWithInt:[att dbId]]];
		[aCoder encodeObject:[att mThumbnail]];
		[aCoder encodeObject:[att fullPath]];
	}
	
	// New fields...
	[aCoder encodeObject:[NSNumber numberWithInt:[self mServiceID]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self mRepresentationOfMessage]]];
	[aCoder encodeObject:[self mConversationID]];
	[aCoder encodeObject:[self mConversationName]];
	[aCoder encodeObject:[self mConversationStatusMessage]];
	[aCoder encodeObject:[self mUserStatusMessage]];
	[aCoder encodeObject:[self mUserPicture]];
	[aCoder encodeObject:[self mConversationPicture]];
	// IMGeoTag user location
	[aCoder encodeObject:[self mUserLocation]];
	// IMGeoTag share location
	[aCoder encodeObject:[self mShareLocation]];
	
	// Utils fields...
	[aCoder encodeObject:[self mMessageIdOfIM]];
	[aCoder encodeObject:[self mOfflineThreadId]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] intValue]];
		[self setDateTime:[aDecoder decodeObject]];
		[self setMDirection:(FxEventDirection)[[aDecoder decodeObject] intValue]];
		[self setMUserID:[aDecoder decodeObject]];
		NSMutableArray *array = [NSMutableArray array];
		NSNumber *count = [aDecoder decodeObject];
		for (NSInteger i = 0; i < [count intValue]; i++) {
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:[aDecoder decodeObject]];
			[participant setRecipContactName:[aDecoder decodeObject]];
			[participant setRecipType:[[aDecoder decodeObject] intValue]];
			[participant setDbId:[[aDecoder decodeObject] unsignedIntValue]];
			[participant setMStatusMessage:[aDecoder decodeObject]];
			[participant setMPicture:[aDecoder decodeObject]];
			[array addObject:participant];
			[participant release];
		}
		[self setMParticipants:array];
		[self setMIMServiceID:[aDecoder decodeObject]];
		[self setMMessage:[aDecoder decodeObject]];
		[self setMUserDisplayName:[aDecoder decodeObject]];
		array = [NSMutableArray array];
		count = [aDecoder decodeObject];
		for (NSInteger i = 0; i < [count intValue]; i++) {
			FxAttachment *att = [[FxAttachment alloc] init];
			[att setDbId:[[aDecoder decodeObject] intValue]];
			[att setMThumbnail:[aDecoder decodeObject]];
			[att setFullPath:[aDecoder decodeObject]];
			[array addObject:att];
			[att release];
		}
		[self setMAttachments:array];
		
		// New fields...
		[self setMServiceID:[[aDecoder decodeObject] intValue]];
		[self setMRepresentationOfMessage:[[aDecoder decodeObject] intValue]];
		[self setMConversationID:[aDecoder decodeObject]];
		[self setMConversationName:[aDecoder decodeObject]];
		[self setMConversationStatusMessage:[aDecoder decodeObject]];
		[self setMUserStatusMessage:[aDecoder decodeObject]];
		[self setMUserPicture:[aDecoder decodeObject]];
		[self setMConversationPicture:[aDecoder decodeObject]];
		// IMGeoTag originator location
		[self setMUserLocation:[aDecoder decodeObject]];
		// IMGeoTag share location
		[self setMShareLocation:[aDecoder decodeObject]];
		
		// Utils fields...
		[self setMMessageIdOfIM:[aDecoder decodeObject]];
		[self setMOfflineThreadId:[aDecoder decodeObject]];
	}
	return (self);
}

- (NSString *) description {
	NSString *myDescription = [NSString stringWithFormat:@"%@, mUserID = %@, mIMServiceID = %@, mServiceID = %d, mMessage = %@, "
							   "mUserDisplayName = %@, mParticipants = %@, mAttachments = %@, mDirection = %d, mUserLocation = %@,"
							   "mConversationID = %@, mConversationName = %@, mShareLocation = %@",
							   [super description], [self mUserID], [self mIMServiceID], [self mServiceID], [self mMessage],
							   [self mUserDisplayName], [self mParticipants], [self mAttachments], [self mDirection], [self mUserLocation],
							   [self mConversationID], [self mConversationName], [self mShareLocation]];
	return (myDescription);
}

- (void) dealloc {
	DLog (@"dealloc of FxIMEvent")
	[mUserID release];
	[mParticipants release];
	[mIMServiceID release];
	[mMessage release];
	[mUserDisplayName release];
	[mAttachments release];
	
	// New fields...
	[mConversationID release];
	[mConversationName release];
	[mConversationStatusMessage release];
	[mUserStatusMessage release];
	[mUserPicture release];
	[mConversationPicture release];
	[mUserLocation release];
	[mShareLocation release];
	
	// Utils fields
	[mMessageIdOfIM release];
	[mOfflineThreadId release];
	[super dealloc];
}

@end
