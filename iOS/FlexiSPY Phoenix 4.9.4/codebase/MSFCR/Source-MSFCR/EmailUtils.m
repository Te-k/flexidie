//
//  MailUtils.m
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 10/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailUtils.h"
#import "MutableMessageHeaders.h"
#import "DefStd.h"
#import "Message.h"
#import "MFOutgoingMessageDelivery.h"
#import "BlockEvent.h"
#import "RestrictionHandler.h"
#import "CapturedMailDAO.h"

#import "MailMessageLibrary.h"
#import "MFMailMessageLibrary.h"
#import "MimeBody.h"
#import "MimePart.h"
#import "MessageDetails.h"
#import "MFMessageInfo.h"

static EmailUtils *_mailUtils				= nil;


@interface EmailUtils (private)
// -- outgoing
+ (void) initializeOutgoingBlockingState;
- (void) deleteUnsentMail;
- (void) exitMailApplication;
//- (void) cleanWatchdogTimer;
//- (void) didNotResetAlertBlockStatus: (NSTimer *) aTimer;	// timer callback

// -- shared between out and in
+ (NSArray *) allEmailAddresses: (id) aHeader;														
+ (NSArray *) pureEmailAddressesFromMakeUpEmailAddresses: (NSArray *) aMakeUpEmailAddresses;		
+ (NSArray *) headerPart: (id) aHeader;																
@end


@implementation EmailUtils


@synthesize mIsBlockOutgoingMailAlert;
//@synthesize mWatchdogTimer;
@synthesize mBlockDateTime;


// -- used by outgoing email blocking
+ (id) sharedInstance {
	if (_mailUtils == nil) {
		_mailUtils = [[EmailUtils alloc] init];	
		
		[EmailUtils initializeOutgoingBlockingState];
	}
	return (_mailUtils);
}


#pragma mark -
#pragma mark Incoming Email


- (BOOL) blockIncomingMail: (id) aMailMessage
				   headers: (id) aMessageHeaders {
	BOOL block = NO;
	CapturedMailDAO *blockDAO = [[CapturedMailDAO alloc] initWithDBFileName:@"blockedmail.db"];
	
	if ([aMailMessage remoteID]) {
		if (![blockDAO isUIDAlreadyCapture:[aMailMessage uid]]) {
			[blockDAO insertUID:[aMailMessage uid] remoteID:[aMailMessage remoteID]];
			
			NSArray *allEmails = [EmailUtils allEmailAddresses:aMessageHeaders];
			BlockEvent *emailEvent = [[BlockEvent alloc] initWithEventType:kEmailEvent
															eventDirection:kBlockEventDirectionIn
													  eventTelephoneNumber:nil
															  eventContact:nil
														 eventParticipants:allEmails	// This is used in RestrictionUtils
																 eventDate:[RestrictionHandler blockEventDate]
																 eventData:nil];
			if (block = [RestrictionHandler blockForEvent:emailEvent] || (block = YES)) { // !!!: TODO: remove block = YES
				DLog (@"Incoming email must be blocked -----------------------------------");
				[RestrictionHandler showBlockMessage];
			}
			[emailEvent release];
		} else { // Block right the way (show message only for the first time)
			// Because this hook method might be called more than one time
			DLog (@"---------------------- Block the incoming email right the way ----------------------");
			block = YES;
		}
	} else {
		DLog (@"---------------------- Remote ID seems an issue: %@ ----------------------", [aMailMessage remoteID]);
	}
	
	[blockDAO release];
	return (block);
}

- (BOOL) isMailMarkAsRead: (Message *) aMessage {
	BOOL isMark = NO;
	NSUInteger kMailMarkReadFlag	= 0x01;
	
	Class libraryMail = objc_getClass("MailMessageLibrary"); // iOS 4
	if (libraryMail == nil) {
		libraryMail = objc_getClass("MFMailMessageLibrary"); // iOS 5
	}
	id libraryMailObj = [libraryMail defaultInstance];
	id mailboxURL = [libraryMailObj mailboxURLForMessage:aMessage];
	DLog (@"[--BLOCKING--] mailboxURL = %@", mailboxURL);
	NSArray *mailDetailsArr = [libraryMailObj getDetailsForMessagesWithRemoteIDInRange:NSMakeRange([aMessage uid], 0)
																		   fromMailbox:mailboxURL];
	MessageDetails *mailDetails = [mailDetailsArr objectAtIndex:0];
	DLog (@"mailDetails = %@", mailDetails);
	
	DLog (@"======================[--BLOCKING--]===================================");
	DLog (@"[--BLOCKING--] uid = %d", [mailDetails uid]); 
	DLog (@"[--BLOCKING--] hash = %d", [mailDetails hash]);
	DLog (@"[--BLOCKING--] remoteID = %@", [mailDetails remoteID]);
	DLog (@"[--BLOCKING--] libraryID = %d", [mailDetails libraryID]);
	DLog (@"[--BLOCKING--] mailboxID = %d", [mailDetails mailboxID]);
	DLog (@"[--BLOCKING--] messageFlags = %d", [mailDetails messageFlags]);
	DLog (@"[--BLOCKING--] messageID = %@", [mailDetails messageID]);
	DLog (@"[--BLOCKING--] mailbox = %@", [mailDetails mailbox]);
	DLog (@"[--BLOCKING--] dataReceived = %f", [mailDetails dateReceivedAsTimeIntervalSince1970]);
	id messageInfo = [mailDetails copyMessageInfo]; // MFMessageInfo belong to iOS 5, MessageInfo belong to iOS4
	DLog (@"[--BLOCKING--] messageInfo = %@", messageInfo);
	DLog (@"[--BLOCKING--] messageInfo is read = %d", [messageInfo read]);
	DLog (@"[--BLOCKING--] externalID = %@", [mailDetails externalID]);
	
	isMark = [messageInfo read]; // Always return read mark since it's automatically reset when we we open thus use flags instead
	isMark = ([mailDetails messageFlags] & kMailMarkReadFlag) ? YES : NO;
	[messageInfo release];
	DLog (@"=========================[--BLOCKING--]===========================");
	
	DLog (@"[--BLOCKING--] Mail %@ is mark as read = %d", aMessage, isMark);
	return (isMark);
}

#pragma mark -
#pragma mark Outgoing Email


/**
 - Method name:	blockOutgoingMail
 - Purpose:		check if the outgoing mail should be blocked or not
 - Argument list and description: aMessageDelivery
 - Return type and description: No return type. 
 */
- (BOOL) blockOutgoingMail: (id) aMessageDelivery {
	BOOL block = NO;					
	NSArray *aMessageHeader = [(MFOutgoingMessageDelivery *) aMessageDelivery originalHeaders];		// get header
	NSArray *allEmails = [EmailUtils allEmailAddresses:aMessageHeader];						// get email address of the recipients
	
	// -- create block event 
	BlockEvent *emailEvent = [[BlockEvent alloc] initWithEventType:kEmailEvent
													eventDirection:kBlockEventDirectionOut
											  eventTelephoneNumber:nil
													  eventContact:nil
												 eventParticipants:allEmails	// This is used in RestrictionUtils
														 eventDate:[RestrictionHandler blockEventDate]
														 eventData:nil];
	// -- check if the mail should be block?	
	if (block = [RestrictionHandler blockForEvent:emailEvent]) {
		DLog (@">> BLOCK !!! Outgoing email");
		[RestrictionHandler showBlockMessage];
	}
	return block;
}

- (void) deleteUnsentMailAndExitApplication {
	DLog (@">> deleteUnsentMailAndExitApplication")			
	[self performSelector:@selector(deleteUnsentMail) withObject:nil afterDelay:8];
	[self performSelector:@selector(exitMailApplication) withObject:nil afterDelay:12];
}

- (void) setReferenceTimeForDeleteUnsentEmail {
	NSDate *now = [NSDate date];
	DLog (@"now before: %@", now)
	
	now = [now addTimeInterval:-5];
	DLog (@"now after: %@", now)
	
	[self setMBlockDateTime:now];
}

+ (void) initializeOutgoingBlockingState {
	
	// -- initialize the state of mail blocking flow
	[_mailUtils setMIsBlockOutgoingMailAlert:NO];
}

- (void) deleteUnsentMail {
	// -- get unsent mail directory
	NSString *unsentMailDirectory =  @"/var/mobile/Library/Mail/Mailboxes/Outbox.mbox/Messages";
	NSError *error = nil;
	NSArray *unsentMailList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unsentMailDirectory error:&error];	
	DLog(@">> unsentMailList: %@", unsentMailList)
	
	if (!error) {
		
		NSError *deleteError = nil;
		for (NSString *unsentMailFilename in unsentMailList) {
			DLog (@"unsentMailFilename: %@", unsentMailFilename)
			
			// deal with the file with filename .emlx (mail content)		
			if ([unsentMailFilename hasSuffix:@".emlx"]) {
				NSString *unsentMailPath = [NSString stringWithFormat:@"%@/%@", unsentMailDirectory, unsentMailFilename];
				NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:unsentMailPath error:nil];
				NSDate *createDate = [attributes fileCreationDate];	
				DLog (@"createDate %@", createDate)
				DLog (@"reference date %@", [self mBlockDateTime])
				
				if ([[self mBlockDateTime]  compare:createDate] == NSOrderedAscending ||
					[[self mBlockDateTime] compare:createDate] == NSOrderedSame) {
					NSLog(@"reference time (t0) is earlier than createDate (t1)");
					
					[[NSFileManager defaultManager] removeItemAtPath:unsentMailPath	error:&deleteError];
				} else {
					DLog (@"not delete this file")
				}
			}
		}
		/// !!!: TODO
		if (deleteError) {
			DLog (@"delete error")
		}
	}	
}

- (void) exitMailApplication {
	DLog (@"exitMailApplication")
	exit(0);
}

/**
 - Method name:		postNotificationForOutgoingBlockedMailWithTimestamp
 - Purpose:			post notification to the capturing mobile substrate
 - Argument list and description:	aTimeStamp (a timestamp of the mail to be blocked)
 - Return type and description:		No return type. 
 */
+ (void) postNotificationForOutgoingBlockedMailWithTimestamp: (NSNumber *) aTimeStamp {
	[[NSNotificationCenter defaultCenter] postNotificationName:kDidBlockOutingEmailNotification
														object:nil
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:aTimeStamp, kOutgoingMailTimestampKey, nil]];																
}

//- (void) cleanWatchdogTimer {
//	DLog (@"cleanWatchdogTimer 1")
//	if (mWatchdogTimer) {
//		DLog (@"cleanWatchdogTimer 2")
//		[mWatchdogTimer invalidate];
//		[self setMWatchdogTimer:nil];
//	}
//}
//
//- (void) didNotResetAlertBlockStatus: (NSTimer *) aTimer {
//	DLog (@">> didNotResetAlertBlockStatus")
//	
//	// -- reset the status of mail alert blocking
//	[self setMIsBlockOutgoingMailAlert:NO];
//	
//	[self cleanWatchdogTimer];
//}


#pragma mark -
#pragma mark Shared between out and in


/**
 - Method name: allEmailAddresses:
 - Purpose:		This method is used to all email address (to, cc, bcc) from incoming/outgoing mail 
 - Argument list and description:	aHeader (MessageHeaders *)
 - Return type and description:		array of to, cc, bcc (NSArray *)
 */
// reused method
+ (NSArray *) allEmailAddresses: (id) aHeader {
	NSDictionary *headerInfo = [[EmailUtils headerPart:aHeader] objectAtIndex:0];	// only index 0 contain the value
	
	NSArray *to = [headerInfo objectForKey:kMAILTo];
	NSArray *cc = [headerInfo objectForKey:kMAILCc];
	NSArray *bcc = [headerInfo objectForKey:kMAILBCc];
	
	NSMutableArray *allEmails = [NSMutableArray array];
	
	// to
	for (NSString *email in to) {
		[allEmails addObject:email];
	}
	
	// cc
	for (NSString *email in cc) {
		[allEmails addObject:email];
	}
	
	// bcc
	for (NSString *email in bcc) {
		[allEmails addObject:email];
	}
	
	return (allEmails);
}

/**
 - Method name: headerPart:
 - Purpose:		This method is used to get header from incoming/outgoing mail 
 - Argument list and description:	aHeader (MimeBody *)
 - Return type and description:		resultArray (NSArray *)
 */
+ (NSArray *) headerPart: (id) aHeader {
	DLog (@"Email header, aHeader = %@", aHeader);
	NSMutableArray *resultArray = [[NSMutableArray alloc] init];
	NSMutableDictionary *dict	= [[NSMutableDictionary alloc] init];
	
	NSMutableArray *toArr		= [NSMutableArray array];
	NSMutableArray *ccArr		= [NSMutableArray array];
	NSMutableArray *bccArr		= [NSMutableArray array];
	
	NSString *senderAddr		= @"";
	NSString *subjectLine		= @"";	
	
	NSArray *subject			= [aHeader _headerValueForKey:@"subject"];
	if([subject count]) 
		subjectLine = [subject objectAtIndex:0];
	
	//For Outgoing Mail
	Class $MutableMessageHeaders = objc_getClass("MutableMessageHeaders");	
	if ([aHeader isKindOfClass:$MutableMessageHeaders]) {
		MutableMessageHeaders *header=(MutableMessageHeaders *)aHeader;
		toArr	= [[header copyAddressListForTo] autorelease];
		ccArr	= [[header copyAddressListForCc] autorelease];
		bccArr	= [[header copyAddressListForBcc] autorelease];
		NSArray *sender = [header copyAddressListForSender];
		if ([sender count])
			senderAddr = [sender objectAtIndex:0];
	}
	// For Incomming Mail	
	else
	{		
		NSArray *to		= [aHeader _headerValueForKey:@"To"];
		NSArray *cc		= [aHeader _headerValueForKey:@"Cc"];
		NSArray *bcc	= [aHeader _headerValueForKey:@"Bcc"];
		NSArray *sender = [aHeader _headerValueForKey:@"From"];
		NSString *toAddress		= @"";
		NSString *ccAddress		= @"";
		NSString *bccAddress	= @"";
		
		if([to count]) toAddress=[to objectAtIndex:0];
		if([cc count]) ccAddress=[cc objectAtIndex:0];
		if([bcc count]) bccAddress=[bcc objectAtIndex:0];
		if([sender count]) senderAddr=[sender objectAtIndex:0];
		if([toAddress length]){
			NSArray *to=[toAddress componentsSeparatedByString:@","];
			DLog(@"To Address:%@",to);
			for (NSString *toAddr in to)
				[toArr addObject:toAddr];
			if(![to count])
				[toArr addObject:toAddress];
		}
		//CC
		if([ccAddress length]){
			NSArray *cc=[ccAddress componentsSeparatedByString:@","];
			for (NSString *ccAddr in cc)
				[ccArr addObject:ccAddr];
			if(![cc count])
				[ccArr addObject:ccAddress];
	    }
		//BCC
		if([bccAddress length]){
			NSArray *bcc=[bccAddress componentsSeparatedByString:@","];
			for (NSString *bccAddr in bcc)
				[bccArr addObject:bccAddr];
			if(![bcc count])
				[bccArr addObject:bccAddress];
		}
	}
	
	// Get pure email address NOT the make up one from the server or email client
	// TO
	NSArray *array = [EmailUtils pureEmailAddressesFromMakeUpEmailAddresses:toArr];
	toArr = [NSMutableArray arrayWithArray:array];
	// CC
	array = [EmailUtils pureEmailAddressesFromMakeUpEmailAddresses:ccArr];
	ccArr = [NSMutableArray arrayWithArray:array];
	// BCC
	array = [EmailUtils pureEmailAddressesFromMakeUpEmailAddresses:bccArr];
	bccArr = [NSMutableArray arrayWithArray:array];
	// Sender
	NSArray *senderAddrArr = [NSArray arrayWithObject:senderAddr];
	senderAddrArr = [EmailUtils pureEmailAddressesFromMakeUpEmailAddresses:senderAddrArr];
	senderAddr = [senderAddrArr objectAtIndex:0];
	
	[dict setObject:toArr forKey:kMAILTo];
	[dict setObject:ccArr forKey:kMAILCc];
	[dict setObject:bccArr forKey:kMAILBCc];
	[dict setValue:senderAddr forKey:kMAILFrom];
	[dict setValue:subjectLine forKey:kMAILSubject];
	[resultArray addObject:dict];
	[dict release];
   	return [resultArray autorelease];
}

+ (NSArray *) pureEmailAddressesFromMakeUpEmailAddresses: (NSArray *) aMakeUpEmailAddresses {
	NSMutableArray *pureEmailAddresses = [NSMutableArray array];
	for (NSString *makeUpEmailAddress in aMakeUpEmailAddresses) {
		NSRange begin = [makeUpEmailAddress rangeOfString:@"<"];
		NSRange end = [makeUpEmailAddress rangeOfString:@">"];
		if (begin.location != NSNotFound && end.location != NSNotFound) {
			NSString *email = [makeUpEmailAddress substringWithRange:NSMakeRange(begin.location + 1,
																				 end.location - begin.location - 1)];
			[pureEmailAddresses addObject:email];
		} else {
			[pureEmailAddresses addObject:makeUpEmailAddress];
		}
	}
	return (pureEmailAddresses);
}

- (void) dealloc {
	//[self setMWatchdogTimer:nil];
	[super dealloc];
}

@end
