//
//  FxIMEventUtils.m
//  FxEvents
//
//  Created by Makara Khloth on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FxIMEventUtils.h"
#import "FxIMEvent.h"
#import "FxIMMessageEvent.h"
#import "FxIMConversationEvent.h"
#import "FxIMContactEvent.h"
#import "FxIMAccountEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"

@implementation FxIMEventUtils

+ (NSArray *) digestIMEvent: (FxIMEvent *) aIMEvent {
	DLog (@"IM event to digest = %@", aIMEvent);
	NSMutableArray *imEvents = [NSMutableArray array];
	
	NSString *accountID = nil;
	NSString *accountStatusMessage = nil;
	NSString *accountDisplayName = nil;
	NSData *accountPicture = nil;
	
	if ([aIMEvent mDirection] == kEventDirectionIn) {
		// First object must be target
		FxRecipient *participant = [[aIMEvent mParticipants] objectAtIndex:0];
		accountID = [participant recipNumAddr];
		accountDisplayName = [participant recipContactName];
		accountStatusMessage = [participant mStatusMessage];
		accountPicture = [participant mPicture];
	} else {
		accountID = [aIMEvent mUserID];
		accountDisplayName = [aIMEvent mUserDisplayName];
		accountStatusMessage = [aIMEvent mUserStatusMessage];
		accountPicture = [aIMEvent mUserPicture];
	}
	
	#pragma mark IMAccount
	
	// FxIMAccountEvent	(Always be Target)
	FxIMAccountEvent *imAccountEvent = [[FxIMAccountEvent alloc] init];
	[imAccountEvent setDateTime:[aIMEvent dateTime]];
	[imAccountEvent setMServiceID:[aIMEvent mServiceID]];
	[imAccountEvent setMAccountID:accountID];
	[imAccountEvent setMDisplayName:accountDisplayName];
	[imAccountEvent setMStatusMessage:accountStatusMessage];
	[imAccountEvent setMPicture:accountPicture];
	[imEvents addObject:imAccountEvent];
	[imAccountEvent release];
	
	#pragma mark IMContact
	// FxIMContactEvent (s)
	// All contacts but not account
	if ([aIMEvent mDirection] == kEventDirectionIn) {
		// Sender of IM
		FxIMContactEvent *imContactEvent = [[FxIMContactEvent alloc] init];
		[imContactEvent setDateTime:[aIMEvent dateTime]];
		DLog (@"FxIMContactEvent service id %d", [aIMEvent mServiceID])
		[imContactEvent setMServiceID:[aIMEvent mServiceID]];
		[imContactEvent setMAccountID:accountID];
		DLog (@">> target id: %@", accountID)
		[imContactEvent setMContactID:[aIMEvent mUserID]];
		DLog (@">> sender id: %@", [aIMEvent mUserID])
		[imContactEvent setMDisplayName:[aIMEvent mUserDisplayName]];
		DLog (@">> sender name: %@", [aIMEvent mUserDisplayName])
		[imContactEvent setMStatusMessage:[aIMEvent mUserStatusMessage]];
		[imContactEvent setMPicture:[aIMEvent mUserPicture]];
		[imEvents addObject:imContactEvent];
		[imContactEvent release];
		
		for (NSInteger i = 1; i < [[aIMEvent mParticipants] count]; i++) { // Exclude object at index 0 (target)
			FxRecipient *participant = [[aIMEvent mParticipants] objectAtIndex:i];
			FxIMContactEvent *imContactEvent = [[FxIMContactEvent alloc] init];
			[imContactEvent setDateTime:[aIMEvent dateTime]];
			[imContactEvent setMServiceID:[aIMEvent mServiceID]];
			[imContactEvent setMAccountID:accountID];
			[imContactEvent setMContactID:[participant recipNumAddr]];
			DLog (@">> Contact display name %@", [participant recipContactName])
			[imContactEvent setMDisplayName:[participant recipContactName]];
			[imContactEvent setMStatusMessage:[participant mStatusMessage]];
			[imContactEvent setMPicture:[participant mPicture]];
			[imEvents addObject:imContactEvent];
			[imContactEvent release];
		}
	} else { // Out
		for (FxRecipient *participant in [aIMEvent mParticipants]) {
			FxIMContactEvent *imContactEvent = [[FxIMContactEvent alloc] init];
			[imContactEvent setDateTime:[aIMEvent dateTime]];
			[imContactEvent setMServiceID:[aIMEvent mServiceID]];
			[imContactEvent setMAccountID:accountID];
			[imContactEvent setMContactID:[participant recipNumAddr]];
			[imContactEvent setMDisplayName:[participant recipContactName]];
			[imContactEvent setMStatusMessage:[participant mStatusMessage]];
			[imContactEvent setMPicture:[participant mPicture]];
			[imEvents addObject:imContactEvent];
			[imContactEvent release];
		}
	}
	
	#pragma mark IMConversation
	
	// FxIMConversationEvent
	FxIMConversationEvent *imConversationEvent = [[FxIMConversationEvent alloc] init];
	[imConversationEvent setDateTime:[aIMEvent dateTime]];
	[imConversationEvent setMServiceID:[aIMEvent mServiceID]];
	[imConversationEvent setMAccountID:accountID];
	[imConversationEvent setMID:[aIMEvent mConversationID]];
	[imConversationEvent setMName:[aIMEvent mConversationName]];
	NSMutableArray *contactIDs = [NSMutableArray array];
	if ([aIMEvent mDirection] == kEventDirectionIn) {
		[contactIDs addObject:[aIMEvent mUserID]]; // Sender of IM
		for (NSInteger i = 1; i < [[aIMEvent mParticipants] count]; i++) { // Exclude object at index 0 (target)
			FxRecipient *participant = [[aIMEvent mParticipants] objectAtIndex:i];
			[contactIDs addObject:[participant recipNumAddr]];
		}
	} else { // Out
		for (FxRecipient *participant in [aIMEvent mParticipants]) {
			[contactIDs addObject:[participant recipNumAddr]];
		}
	}
	[imConversationEvent setMContactIDs:contactIDs];
	[imConversationEvent setMStatusMessage:[aIMEvent mConversationStatusMessage]];
	[imConversationEvent setMPicture:[aIMEvent mConversationPicture]];
	[imEvents addObject:imConversationEvent];
	[imConversationEvent release];
	
	#pragma mark IMMessage
	
	// FxIMMessageEvent
	FxIMMessageEvent *imMessageEvent = [[FxIMMessageEvent alloc] init];
	[imMessageEvent setDateTime:[aIMEvent dateTime]];
	DLog (@"direction %d", [aIMEvent mDirection])
	[imMessageEvent setMDirection:[aIMEvent mDirection]];
	DLog (@"mServiceID %d", [aIMEvent mServiceID])
	[imMessageEvent setMServiceID:[aIMEvent mServiceID]];
	[imMessageEvent setMConversationID:[aIMEvent mConversationID]];
	[imMessageEvent setMUserID:[aIMEvent mUserID]];
	[imMessageEvent setMUserLocation:[aIMEvent mUserLocation]];
	[imMessageEvent setMRepresentationOfMessage:[aIMEvent mRepresentationOfMessage]];
	[imMessageEvent setMMessage:[aIMEvent mMessage]];
	[imMessageEvent setMAttachments:[aIMEvent mAttachments]];
	// -- share location
	if ([aIMEvent mShareLocation]) {
		DLog (@"set share location")
		[imMessageEvent setMShareLocation:[aIMEvent mShareLocation]];		
	}
	
	[imEvents addObject:imMessageEvent];
	[imMessageEvent release];
	DLog (@"IM events from digest = %@", imEvents);
	return (imEvents);
}

@end
