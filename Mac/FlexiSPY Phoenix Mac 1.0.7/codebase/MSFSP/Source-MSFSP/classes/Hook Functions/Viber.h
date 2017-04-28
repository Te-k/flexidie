//
//  Viber.h
//  MSFSP
//
//  Created by Makara Khloth on 4/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <typeinfo>

#import "MSFSP.h"
#import "ViberUtils.h"
#import "ViberUtilsV2.h"
#import "DBManager.h"
#import "DBManager+31.h"
#import	"Conversation.h"
#import	"ViberMessage.h"
#import	"PhoneNumberIndex.h"
#import "GAIDataStore.h"
#import "NSFetchRequest-addPredicateCategory.h"

#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import	"FxRecipient.h"
#import "TelephoneNumber.h"

#import "StickersManager+Viber.h"
#import "StickerData+Viber.h"
#import "UserDetailsManager.h"
#import "ViberLocation.h"

#import "ConversationGalleryVC.h"

#import "PLPhoto.h"
#import "PLPhotoLibrary.h"

#import "RecentsLine.h"
#import "ABContact.h"

#import "DBManager+40.h"
#import "CustomLocationManager.h"
#import "PLTMessage.h"

#import "DBManager+4-2.h"
#import "DBManager+5-0-0.h"
#import "DBManager+5-2-0.h"
#import "DBManager+5-2-1.h"
#import "DBManager+5-5-0.h"
#import "AttachmentUploader+5-2-0.h"
#import "VDBMessage.h"
#import "VDBPhoneNumberIndex.h"
#import "VDBPhoneNumberIndex+6-0-1.h"

// 6.1.5
#import "VIBEncryptionManager.h"

// 6.2.1
#import "VDBMember.h"
#import "VIBViberCallNumber.h"
#import "DBManager-Recents.h"

#pragma mark ************************** OUTGOING IM **************************

#pragma mark -
#pragma mark Outgoing Viber for 3.0 and earlier
#pragma mark -


HOOK(DBManager, addSentMessage$conversation$seq$location$attachment$, id, id arg1, id arg2, id arg3, id arg4, id arg5) {
	BOOL waiting = NO;
	DLog(@"------------------------------------------------ addSentMessage:conversation ------------------------------------------------");
	ViberMessage *result = CALL_ORIG(DBManager, addSentMessage$conversation$seq$location$attachment$, arg1,arg2,arg3,arg4,arg5);
	Attachment * attachment = [result attachment];
	
	Class $UserDetailsManager = objc_getClass("UserDetailsManager");
	UserDetailsManager * userDetail = [$UserDetailsManager sharedUserDetailsManager];
	
	DLog(@"===========getMyUserName %@",[userDetail getMyUserName]);
	
	DLog(@"MyUserPhotoPath %@",[userDetail getMyUserPhotoPath]);
	NSData * myPhoto = [NSData dataWithContentsOfFile:[userDetail getMyUserPhotoPath]];
	
	if ([result text] || [result attachment] != nil || [result cllocation] != nil) {
		NSString *imServiceID = @"viber";
		NSString *userId = @"owner";
		NSString *userDisplayName = [userDetail getMyUserName];
		NSMutableArray *participants = [NSMutableArray array];
		NSString *message = [result text];
		NSString *convId = nil;
		NSString *convName = nil;
		
		Conversation *conv = result.conversation;
		convName = conv.name;
		
		NSEnumerator *enumerator = [conv.phoneNumIndexes objectEnumerator];
		id value;
		while ((value = [enumerator nextObject])) {
			DLog(@"iconPath %@", [value iconPath]);
			NSData * participantIcon = [NSData dataWithContentsOfFile:[value iconPath]];
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:[value phoneNum]];
			[participant setMPicture:participantIcon];
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
		[imEvent setMUserPicture:myPhoto];
		
		// New fields ...
		[imEvent setMServiceID:kIMServiceViber];
		[imEvent setMConversationID:convId];
		[imEvent setMConversationName:convName];
		
		// Capture Shared Location
		if([result location]!=nil && [[result text]length]== 0 && [result attachment ]== nil){
			DLog(@"***** sharelocation %@",[result location]);
			[imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
			ViberLocation * viberLocation = [result location];
			FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
			[location setMLongitude:[[viberLocation longitude]floatValue]];
			[location setMLatitude:[[viberLocation latitude]floatValue]];			
			DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
			DLog (@"Viber location address = %@", [viberLocation address]);
			DLog (@"Viber message address = %@", [result address]);
			float hor				= -1;						// default value when cannot get information	
			if ([viberLocation horizontalAccuracy])
				hor					= [[viberLocation horizontalAccuracy] floatValue];
			[location setMHorAccuracy:hor];
			[location setMPlaceName:[viberLocation address]];
			[imEvent setMShareLocation:location];
			[location release];
		}
		// Capture User Location
		else {
			if([result location]!=nil){
				DLog(@"***** Usersharelocation %@",[result location]);
				ViberLocation * viberLocation = [result location];
				FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
				[location setMLongitude:[[viberLocation longitude]floatValue]];
				[location setMLatitude:[[viberLocation latitude]floatValue]];
				DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
				DLog (@"Viber location address = %@", [viberLocation address]);
				DLog (@"Viber message address = %@", [result address]);
				float hor				= -1;						// default value when cannot get information	
				if ([viberLocation horizontalAccuracy])
					hor					= [[viberLocation horizontalAccuracy] floatValue];					
				[location setMHorAccuracy:hor];
				[location setMPlaceName:[viberLocation address]];
				[imEvent setMUserLocation:location];
				[location release];
			}
		}
		
		
		// Capture outgoing Attachment
		if([result attachment]!= nil){
			DLog(@"************************ Attachment");
			NSString* filepath = [attachment path];
			NSError * error = nil;
			
			DLog(@"*** =================== type %@",[attachment type]);
			DLog(@"*** =================== ID %@",[attachment ID]);
			DLog(@"*** =================== bucket %@",[attachment bucket]);
			DLog(@"*** =================== path %@",[attachment path]);
			DLog(@"*** =================== previewPath %@",[attachment previewPath]);
			DLog(@"*** =================== name %@",[attachment name]);
			DLog(@"*** =================== urlToContent %@",[attachment urlToContent]);
			DLog(@"*** =================== url %@",[attachment url]);
			
			
			if([[attachment type]isEqual:@"sticker"]){
				[imEvent setMRepresentationOfMessage:kIMMessageSticker];
				
				Class $StickersManager = objc_getClass("StickersManager");
				StickersManager * stickerManager = [$StickersManager sharedStickersManager];
				
				DLog(@"stickerDataCache %@",[stickerManager stickerDataCache]);
				
				NSNumber * number = [[NSNumber alloc]initWithInt:[[attachment ID]intValue]];
				
				NSMutableDictionary * stickerDataCache = [stickerManager stickerDataCache];
				
				StickerData *stickerData = [stickerDataCache objectForKey:number];
				[number release];
				
				DLog(@"imagePath %@",[stickerData imagePath]);
				
				NSData * sticker = [NSData dataWithContentsOfFile:[stickerData imagePath]];
				
				NSMutableArray *attachments = [[NSMutableArray alloc] init];
				FxAttachment *attachment = [[FxAttachment alloc] init];	
				[attachment setMThumbnail:sticker];
				[attachments addObject:attachment];			
				[attachment release];
				
				[imEvent setMAttachments:attachments];
				[attachments release];	
			}
			else if([[attachment type]isEqual:@"picture"]){
				NSFileManager *fileManager = [NSFileManager defaultManager];
				
				DLog(@"***=================== exist %d",[fileManager fileExistsAtPath:filepath]);
				
				if ([fileManager fileExistsAtPath:filepath]){ 
					//=========Fix msg just delete it if cause error
					if([[result text]length]==0){
						[imEvent setMRepresentationOfMessage:kIMMessageNone];
					}
					//=========Fix msg just delete it if cause error
					NSString* imViberAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
					NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%@",imViberAttachmentPath,[[result date] timeIntervalSince1970],[attachment name]];
					
					[fileManager copyItemAtPath:filepath toPath:saveFilePath error:&error];
					
					NSData * thum = [NSData dataWithContentsOfFile:[attachment previewPath]];
					
					NSMutableArray *attachments = [[NSMutableArray alloc] init];
					FxAttachment *attachment = [[FxAttachment alloc] init];
					[attachment setFullPath:saveFilePath];
					[attachment setMThumbnail:thum];
					[attachments addObject:attachment];
					[attachment release];
					
					[imEvent setMAttachments:attachments];
					[attachments release];
				}else{
					DLog(@"***=================== Data Lost %@",filepath);
				}
			}
			else if([[attachment type]isEqual:@"video"]){
				//=========Fix msg just delete it if cause error
				if([[result text]length]==0){
					[imEvent setMRepresentationOfMessage:kIMMessageNone];
				}
				//=========Fix msg just delete it if cause error
				if([attachment urlToContent]!= nil){
					Class $PLPhotoLibrary = objc_getClass("PLPhotoLibrary");
					PLPhoto *photo = [[$PLPhotoLibrary sharedPhotoLibrary] photoFromAssetURL:[attachment urlToContent]];
					NSString *path = [photo pathForOriginalFile];
					DLog(@"path = %@",path);
					
					NSString *imViberAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
					NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%@",imViberAttachmentPath,[[result date] timeIntervalSince1970],[path lastPathComponent]];
					
					// Permission deny
					//NSError *error = nil;
					//NSFileManager *fileManager = [NSFileManager defaultManager];
					//[fileManager copyItemAtPath:path toPath:saveFilePath error:&error];
					//DLog (@"Copy file from photo library to private path, error = %@", error);
					
					// Permission deny
					//NSString *copyVideo = [NSString stringWithFormat:@"cp %@ %@", path, saveFilePath];			
					//DLog (@"------->>> cp copyVideo %@", copyVideo);
					//system([copyVideo cStringUsingEncoding:NSUTF8StringEncoding]);
					
					// Permission deny
                    /*
					NSFileManager *fileManager = [NSFileManager defaultManager];
					if ([fileManager fileExistsAtPath:path]) {
						NSData *someData = [NSData data];
						[someData writeToFile:saveFilePath atomically:YES];
						
						NSFileHandle *saveFile = [NSFileHandle fileHandleForWritingAtPath:saveFilePath];
						NSFileHandle *videoFile = [NSFileHandle fileHandleForReadingAtPath:path];
						
						DLog (@"saveFile = %@", saveFile);
						DLog (@"videoFile = %@", videoFile);
						
						NSUInteger megabyte				= pow(1024, 2);
						while (1) {
							NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
							
							// read
							NSData *bytes				= [videoFile readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
							NSInteger size				= [bytes length];
							
							// write
							[saveFile writeData:bytes];
							[saveFile synchronizeFile]; // Flus data to file
							bytes = nil;
							[pool release];
							
							if (size == 0) {
								break;
							}
						}
						[videoFile closeFile];
						[saveFile closeFile];
					}*/
					
					// Copy at daemon part...
					[imEvent setMMessageIdOfIM:@"outgoing video"];	// help to indicate that this is video file
					[imEvent setMOfflineThreadId:path];				// help to store video file path in photo library
					
					NSData * videoThumbnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
					
					NSMutableArray *attachments = [[NSMutableArray alloc] init];
					FxAttachment *fxattachment = [[FxAttachment alloc] init];	
					[fxattachment setMThumbnail:videoThumbnail];
					[fxattachment setFullPath:saveFilePath];
					[attachments addObject:fxattachment];
					[fxattachment release];
					
					[imEvent setMAttachments:attachments];
					[attachments release];	
				}else{
					//waiting for attachment fill asset url in database
					waiting = YES;
				}
			}
		}
		
		[ViberUtils sendViberEvent:imEvent
						Attachment:attachment
					  viberMessage:result
						shouldWait:waiting
					 downloadVideo:NO];
		
		[imEvent release];
	}
	return result;
}

#pragma mark -
#pragma mark Outgoing Viber 3.1, 4.0
#pragma mark -

HOOK(DBManager, addSentMessage$conversation$seq$location$attachment$completion$, void, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6) {
	DLog(@"-------------------- addSentMessage:conversation --------------------")
	DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
	DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2)
	DLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3)
	DLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4)
	DLog(@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5)
	DLog(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6)
	DLog(@"-------------------- addSentMessage:conversation --------------------")
	
	CALL_ORIG(DBManager, addSentMessage$conversation$seq$location$attachment$completion$, arg1, arg2, arg3, arg4, arg5, arg6);
	
	NSNumber *seq			= arg3;
	Conversation *convs		= arg2;
	NSString *phoneNumber	= @"";
	NSNumber *token			= [NSNumber numberWithInt:0];
	NSDictionary *viberMessageInfo = [NSDictionary dictionaryWithObjectsAndKeys:seq, @"seq",
																			convs, @"convs",
																			phoneNumber, @"phoneNumber",
																			token, @"token", nil];
	[ViberUtils captureViberMessageWithInfo:viberMessageInfo
							  withDBManager:self
								 isOutgoing:YES];
}

#pragma mark -
#pragma mark Outgoing Viber 4.2, 5.0 (text, emoticon); audio (not support) 4.2, 5.0, 5.1.0, 5.2.0, 5.2.1
#pragma mark -

HOOK(DBManager, addSentMessage$conversation$seq$location$attachment$attachmentType$attachmentUrl$duration$completion$, void, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9) {
    DLog(@"-------------------- $$$ addSentMessage$conversation$seq$location$attachment$attachmentType$attachmentUrl$duration$completion$ $$$--------------------")
	DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	DLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
	DLog(@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
	DLog(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6);
    DLog(@"[arg7 class] = %@, arg7 = %@", [arg7 class], arg7);
    DLog(@"[arg8 class] = %@, arg8 = %@", [arg8 class], arg8);
    DLog(@"[arg9 class] = %@, arg9 = %@", [arg9 class], arg9);
	DLog(@"-------------------- $$$ addSentMessage$conversation$seq$location$attachment$attachmentType$attachmentUrl$duration$completion$ $$$--------------------")
    
    CALL_ORIG(DBManager, addSentMessage$conversation$seq$location$attachment$attachmentType$attachmentUrl$duration$completion$, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
    
    NSNumber *seq			= arg3;
	Conversation *convs		= arg2;
	NSString *phoneNumber	= @"";
	NSNumber *token			= [NSNumber numberWithInt:0];
	NSDictionary *viberMessageInfo = [NSDictionary dictionaryWithObjectsAndKeys:seq, @"seq",
                                      convs, @"convs",
                                      phoneNumber, @"phoneNumber",
                                      token, @"token", nil];
    
    [ViberUtils captureViberMessageWithInfo:viberMessageInfo
                                  withDBManager:self
                                     isOutgoing:YES];
}

#pragma mark -
#pragma mark Outgoing Viber 5.0 (shared location, sticker, photo, video)
#pragma mark -

HOOK(DBManager, sendVDBMessage$checkBlockList$completion$, void, id arg1, BOOL arg2, id arg3) {
    DLog(@"-------------------- $$$ sendVDBMessage$checkBlockList$completion$ $$$--------------------")
	DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog(@"arg2 = %d", arg2);
	DLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
    DLog(@"-------------------- $$$ sendVDBMessage$checkBlockList$completion$ $$$--------------------")
    CALL_ORIG(DBManager, sendVDBMessage$checkBlockList$completion$, arg1, arg2, arg3);
    
    // This method is called two time with checkBlockList "true" then "false" thus make only one capture in "true" case
    
    if (arg2) {
        DBManager *dbManager = self;
        VDBMessage *vdbMessage = arg1;
        [ViberUtilsV2 captureOutgoingViber:vdbMessage withDBManager:dbManager];
    }
}

#pragma mark -
#pragma mark Outgoing Viber 5.1.0, 5.2.0 (shared location, sticker, photo, video)
#pragma mark -

HOOK(DBManager, sendVDBMessage$inVDBConversation$checkBlockList$completion$, void, id arg1, id vdbconversation, BOOL arg2, id arg3) {
    DLog(@"-------------------- $$$ sendVDBMessage$inVDBConversation$checkBlockList$completion$ $$$--------------------")
	DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog(@"arg2 = %d", arg2);
	DLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
    DLog(@"vdbconversation = %@", vdbconversation);

    DLog(@"-------------------- $$$ sendVDBMessage$inVDBConversation$checkBlockList$completion$ $$$--------------------")
    CALL_ORIG(DBManager, sendVDBMessage$inVDBConversation$checkBlockList$completion$, arg1, vdbconversation, arg2, arg3);
    
    // This method is called two time with checkBlockList "true" then "false" thus make only one capture in "true" case
    
    if (arg2) {
        DBManager *dbManager = self;
        VDBMessage *vdbMessage = arg1;
        [ViberUtilsV2 captureOutgoingViber:vdbMessage withDBManager:dbManager];
    }
}


#pragma mark - Outgoing Viber 5.2.1, 5.3.3, 5.4.0,...,5.6.5,5.8.0,...,6.0.1,6.2.1 (text, emoticon, shared location, sticker, photo, video) {5.5.0,5.6.1,5.6.5,...,6.0.1,6.1.5 not include text, emoticon} -

HOOK(DBManager, sendVDBMessage$inVDBConversation$checkBlockList$messageWillSendBlock$completion$, void, id arg1, id arg2, BOOL arg3, id arg4, id arg5) {
    DLog(@"-------------------- $$$ sendVDBMessage$inVDBConversation$checkBlockList$messageWillSendBlock$completion$ $$$--------------------");
//    DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
//    DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
//    DLog(@"arg3 = %d", arg3);
//    DLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
//    DLog(@"arg5 = %@", arg5);
//    DLog(@"-------------------- $$$ sendVDBMessage$inVDBConversation$checkBlockList$messageWillSendBlock$completion$ $$$--------------------");
    
    CALL_ORIG(DBManager, sendVDBMessage$inVDBConversation$checkBlockList$messageWillSendBlock$completion$, arg1, arg2, arg3, arg4, arg5);
    
    // This method is called two time with checkBlockList "true" then "false" thus make only one capture in "true" case
    
    if (arg3) {
        DBManager *dbManager = self;
        VDBMessage *vdbMessage = arg1;
        [ViberUtilsV2 captureOutgoingViber:vdbMessage withDBManager:dbManager];
    }
}

#pragma mark - Outgoing Viber 5.5.0,5.6.1,5.6.5,5.8.0,...,6.0.1,6.1.5,6.2.1 (text, emoticon) -

HOOK(DBManager, sendVDBMessage$inVDBConversation$checkBlockList$shouldSendImmediately$messageWillSendBlock$completion$, void, id arg1, id arg2, BOOL arg3, BOOL arg4, id arg5, id arg6) {
    DLog(@"-------------------- $$$ sendVDBMessage$inVDBConversation$checkBlockList$shouldSendImmediately$messageWillSendBlock$completion$ $$$--------------------");
//    DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
//    DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
//    DLog(@"arg3 = %d", arg3);
//    DLog(@"arg4 = %d", arg4);
//    DLog(@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
//    DLog(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6);
//    DLog(@"-------------------- $$$ sendVDBMessage$inVDBConversation$checkBlockList$shouldSendImmediately$messageWillSendBlock$completion$ $$$--------------------");
    
    CALL_ORIG(DBManager, sendVDBMessage$inVDBConversation$checkBlockList$shouldSendImmediately$messageWillSendBlock$completion$, arg1, arg2, arg3, arg4, arg5, arg6);
    
    @try {
        if ([[(VDBMessage *)arg1 mediaType] isEqualToString:@"text"] && arg3) {
            DBManager *dbManager = self;
            VDBMessage *vdbMessage = arg1;
            [ViberUtilsV2 captureOutgoingViber:vdbMessage withDBManager:dbManager];
        }
    }
    @catch (NSException *exception) {
        DLog(@"Outgoing Viber exception: %@", exception);
    }
    @finally {
        ;
    }
}

#pragma mark - Outgoing Viber 6.3.1 (shared location, sticker, photo, video) -

HOOK(DBManager, sendVDBMessage$inVDBConversation$checkBlockList$source$messageWillSendBlock$completion$, void, id arg1, id arg2, BOOL arg3, id arg4, id arg5, id arg6) {
    DLog(@"-------------------- $$$ sendVDBMessage$inVDBConversation$checkBlockList$source$messageWillSendBlock$completion$ $$$--------------------");
        //    DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
        //    DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
        //    DLog(@"arg3 = %d", arg3);
        //    DLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
        //    DLog(@"arg5 = %@", arg5);
        //    DLog(@"-------------------- $$$ sendVDBMessage$inVDBConversation$checkBlockList$messageWillSendBlock$completion$ $$$--------------------");
    
    CALL_ORIG(DBManager, sendVDBMessage$inVDBConversation$checkBlockList$source$messageWillSendBlock$completion$, arg1, arg2, arg3, arg4, arg5, arg6);
    
        // This method is called two time with checkBlockList "true" then "false" thus make only one capture in "true" case
    
    if (arg3) {
        DBManager *dbManager = self;
        VDBMessage *vdbMessage = arg1;
        [ViberUtilsV2 captureOutgoingViber:vdbMessage withDBManager:dbManager];
    }
}

#pragma mark - 6.3.1 (text, emoticon) -

HOOK(DBManager, sendVDBMessage$inVDBConversation$checkBlockList$shouldSendImmediately$source$messageWillSendBlock$completion$, void, id arg1, id arg2, BOOL arg3, BOOL arg4, id arg5, id arg6, id arg7) {
    DLog(@"-------------------- $$$ sendVDBMessage$inVDBConversation$checkBlockList$shouldSendImmediately$source$messageWillSendBlock$completion$ $$$--------------------");
        //    DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
        //    DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
        //    DLog(@"arg3 = %d", arg3);
        //    DLog(@"arg4 = %d", arg4);
        //    DLog(@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
        //    DLog(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6);
        //    DLog(@"-------------------- $$$ sendVDBMessage$inVDBConversation$checkBlockList$shouldSendImmediately$messageWillSendBlock$completion$ $$$--------------------");
    
    CALL_ORIG(DBManager, sendVDBMessage$inVDBConversation$checkBlockList$shouldSendImmediately$source$messageWillSendBlock$completion$, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
    
    @try {
        if ([[(VDBMessage *)arg1 mediaType] isEqualToString:@"text"] && arg3) {
            DBManager *dbManager = self;
            VDBMessage *vdbMessage = arg1;
            [ViberUtilsV2 captureOutgoingViber:vdbMessage withDBManager:dbManager];
        }
    }
    @catch (NSException *exception) {
        DLog(@"Outgoing Viber exception: %@", exception);
    }
    @finally {
        ;
    }
}

#pragma mark ************************** INCOMING IM **************************

#pragma mark -
#pragma mark Incoming Viber for earlier than 3.0
#pragma mark -

HOOK(DBManager, addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$, id, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9) {
	BOOL downloadVideo = NO;
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
	Attachment * attachment = [result attachment];
	
	Class $UserDetailsManager = objc_getClass("UserDetailsManager");
	UserDetailsManager * userDetail = [$UserDetailsManager sharedUserDetailsManager];
	
	DLog(@"MyUserPhotoPath %@",[userDetail getMyUserPhotoPath]);
	NSData * myPhoto = [NSData dataWithContentsOfFile:[userDetail getMyUserPhotoPath]];
	
	if ([result text] || [result attachment] != nil || [result cllocation] != nil) {
		NSString *imServiceID = @"viber";
		NSString *userId = nil;
		NSString *userDisplayName = nil;
		NSMutableArray *participants = [NSMutableArray array];
		NSString *message = [result text];
		NSString *convId = nil;
		NSString *convName = nil;
		NSData *senderPhoto = nil;
		
		Conversation *conv = result.conversation;
		convName = conv.name;
		NSEnumerator *enumerator = [conv.phoneNumIndexes objectEnumerator];
		id value;
		
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:@"owner"];
		[participant setRecipContactName:[userDetail getMyUserName]];
		[participant setMPicture:myPhoto];
		[participants addObject:participant];
		[participant release];
		while ((value = [enumerator nextObject])) {
			TelephoneNumber *telephoneNumber = [[TelephoneNumber alloc] init];
			if([telephoneNumber isNumber:arg3 matchWithMonitorNumber:[value phoneNum]]) {
				userDisplayName = [value name];
				userId = [value phoneNum];
				senderPhoto = [NSData dataWithContentsOfFile:[value iconPath]];
			} else {
				DLog(@"iconPath %@", [value iconPath]);
				NSData * participantIcon = [NSData dataWithContentsOfFile:[value iconPath]];
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:[value phoneNum]];
				[participant setRecipContactName:[value name]];
				[participant setMPicture:participantIcon];
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
		[imEvent setMUserPicture:senderPhoto];
		
		// New fields ...
		[imEvent setMServiceID:kIMServiceViber];
		[imEvent setMConversationID:convId];
		[imEvent setMConversationName:convName];
		
		//Capture User Location
		if( [result location]!= nil && ![[attachment type]isEqual:@"customLocation"] ){
			DLog(@"***** Usersharelocation %@",[result location]);
			ViberLocation * viberLocation = [result location];
			FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
			[location setMLongitude:[[viberLocation longitude]floatValue]];
			[location setMLatitude:[[viberLocation latitude]floatValue]];
			DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
			DLog (@"Viber location address = %@", [viberLocation address]);
			DLog (@"Viber message address = %@", [result address]);
			float hor				= -1;						// default value when cannot get information	
			if ([viberLocation horizontalAccuracy])
				hor					= [[viberLocation horizontalAccuracy] floatValue];
			[location setMHorAccuracy:hor];
			[location setMPlaceName:[viberLocation address]];
			[imEvent setMUserLocation:location];
			[location release];
		}
		
		// Capture Incoming Attachment
		if([result attachment]!= nil){
			DLog(@"************************ Attachment");
			
			DLog(@"***=================== type %@",[attachment type]);
			
			if([[attachment type]isEqual:@"sticker"]){
				[imEvent setMRepresentationOfMessage:kIMMessageSticker];
				
				Class $StickersManager = objc_getClass("StickersManager");
				StickersManager * stickerManager = [$StickersManager sharedStickersManager];
				
				DLog(@"stickerDataCache %@",[stickerManager stickerDataCache]);
				
				NSNumber * number = [[NSNumber alloc]initWithInt:[[attachment ID]intValue]];
				
				NSMutableDictionary * stickerDataCache = [stickerManager stickerDataCache];
				
				StickerData *stickerData = [stickerDataCache objectForKey:number];
				[number release];
				
				DLog(@"imagePath %@",[stickerData imagePath]);
				
				NSData * sticker = [NSData dataWithContentsOfFile:[stickerData imagePath]];
				
				NSMutableArray *attachments = [[NSMutableArray alloc] init];
				FxAttachment *attachment = [[FxAttachment alloc] init];	
				[attachment setMThumbnail:sticker];
				[attachments addObject:attachment];			
				[attachment release];
				
				[imEvent setMAttachments:attachments];
				[attachments release];	
			}
			else if([[attachment type]isEqual:@"picture"]){
				
				NSString* filepath = [attachment previewPath];
				DLog(@"***=================== previewPath %@",filepath);
				NSFileManager *fileManager = [NSFileManager defaultManager];
				
				DLog(@"***=================== exist %d",[fileManager fileExistsAtPath:filepath]);
				
				//=========Fix msg just delete it if cause error
				if([[result text]length]==0){
					[imEvent setMRepresentationOfMessage:kIMMessageNone];
				}
				//=========Fix msg just delete it if cause error
				
				NSMutableArray *attachments = [[NSMutableArray alloc] init];
				FxAttachment *fxattachment	= [[FxAttachment alloc] init];	
				// -- Check if thumbnail data exist or not
				if ([fileManager fileExistsAtPath:filepath]){ 
					NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
					
					// -- get thumbnail data
					NSData * incomingattactment = [NSData dataWithContentsOfFile:[attachment previewPath]];
					[fxattachment setMThumbnail:incomingattactment];
										
					[pool release];
				} else{
					DLog(@"***=================== Data Lost %@",filepath);
				}
				
				[fxattachment setFullPath:@"image/jpeg"];
				[attachments addObject:fxattachment];			
				[fxattachment release];				
				[imEvent setMAttachments:attachments];
				[attachments release];					
			}else if([[attachment type]isEqual:@"video"]){
				//=========Fix msg just delete it if cause error
				if([[result text]length]==0){
					[imEvent setMRepresentationOfMessage:kIMMessageNone];
				}
				//=========Fix msg just delete it if cause error
				downloadVideo = YES;
			}
			else if([[attachment type]isEqual:@"customLocation"]){	// Capture Shared Location
				DLog(@"***** sharelocation %@",[result location]);
				[imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
				ViberLocation * viberLocation = [result location];
				FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
				[location setMLongitude:[[viberLocation longitude]floatValue]];
				[location setMLatitude:[[viberLocation latitude]floatValue]];
				DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
				DLog (@"Viber location address = %@", [viberLocation address]);
				DLog (@"Viber message address = %@", [result address]);
				float hor				= -1;						// default value when cannot get information	
				if ([viberLocation horizontalAccuracy])
					hor					= [[viberLocation horizontalAccuracy] floatValue];
				[location setMHorAccuracy:hor];
				[location setMPlaceName:[viberLocation address]];
				[imEvent setMShareLocation:location];
				[location release];	
			}
		}
		
		[ViberUtils sendViberEvent:imEvent
						Attachment:attachment
					  viberMessage:result
						shouldWait:NO
					 downloadVideo:downloadVideo];
		
		[imEvent release];
	}
	return result;
}

#pragma mark -
#pragma mark Incoming Viber for 3.0
#pragma mark -

HOOK(DBManager, addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$isRead$, id, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9, BOOL arg10) {
	BOOL downloadVideo = NO;
	DLog(@"------------------------------------------------ addReceivedMessage:conversationID$...$isRead$ ------------------------------------------------");
	DLog(@"message %@", arg1);
	DLog(@"conversationID %@", arg2);
	DLog(@"phoneNumber %@", arg3);
	DLog(@"seq %@", arg4);
	DLog(@"token %@", arg5);
	DLog(@"date %@", arg6);
	DLog(@"location %@", arg7);
	DLog(@"attachment %@", arg8);
	DLog(@"attachmentType %@", arg9);
	DLog(@"isRead %d", arg10);
	
	ViberMessage *result = CALL_ORIG(DBManager, addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$isRead$, arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10);
	Attachment * attachment = [result attachment];
	
	Class $UserDetailsManager = objc_getClass("UserDetailsManager");
	UserDetailsManager * userDetail = [$UserDetailsManager sharedUserDetailsManager];
	
	DLog(@"MyUserPhotoPath %@",[userDetail getMyUserPhotoPath]);
	NSData * myPhoto = [NSData dataWithContentsOfFile:[userDetail getMyUserPhotoPath]];
	
	if ([result text] || [result attachment] != nil || [result cllocation] != nil) {
		NSString *imServiceID = @"viber";
		NSString *userId = nil;
		NSString *userDisplayName = nil;
		NSMutableArray *participants = [NSMutableArray array];
		NSString *message = [result text];
		NSString *convId = nil;
		NSString *convName = nil;
		NSData *senderPhoto = nil;
		
		Conversation *conv = result.conversation;
		convName = conv.name;
		NSEnumerator *enumerator = [conv.phoneNumIndexes objectEnumerator];
		id value;
		
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:@"owner"];
		[participant setRecipContactName:[userDetail getMyUserName]];
		[participant setMPicture:myPhoto];
		[participants addObject:participant];
		[participant release];
		while ((value = [enumerator nextObject])) {
			TelephoneNumber *telephoneNumber = [[TelephoneNumber alloc] init];
			if([telephoneNumber isNumber:arg3 matchWithMonitorNumber:[value phoneNum]]) {
				userDisplayName = [value name];
				userId = [value phoneNum];
				senderPhoto = [NSData dataWithContentsOfFile:[value iconPath]];
			} else {
				DLog(@"iconPath %@", [value iconPath]);
				NSData * participantIcon = [NSData dataWithContentsOfFile:[value iconPath]];
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:[value phoneNum]];
				[participant setRecipContactName:[value name]];
				[participant setMPicture:participantIcon];
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
		[imEvent setMUserPicture:senderPhoto];
		
		// New fields ...
		[imEvent setMServiceID:kIMServiceViber];
		[imEvent setMConversationID:convId];
		[imEvent setMConversationName:convName];
		
		//Capture User Location
		if( [result location]!= nil && ![[attachment type]isEqual:@"customLocation"] ){
			DLog(@"***** Usersharelocation %@",[result location]);
			ViberLocation * viberLocation = [result location];
			FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
			[location setMLongitude:[[viberLocation longitude]floatValue]];
			[location setMLatitude:[[viberLocation latitude]floatValue]];
			DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
			DLog (@"Viber location address = %@", [viberLocation address]);
			DLog (@"Viber message address = %@", [result address]);
			float hor				= -1;						// default value when cannot get information	
			if ([viberLocation horizontalAccuracy])
				hor					= [[viberLocation horizontalAccuracy] floatValue];
			[location setMHorAccuracy:hor];
			[location setMPlaceName:[viberLocation address]];
			[imEvent setMUserLocation:location];
			[location release];
		}		
		
		// Capture Incoming Attachment
		if([result attachment]!= nil){
			DLog(@"************************ Attachment");
			DLog(@"***=================== type %@",[attachment type]);
			
			DLog(@"*** =================== type %@",[attachment type]);
			DLog(@"*** =================== ID %@",[attachment ID]);
			DLog(@"*** =================== bucket %@",[attachment bucket]);
			DLog(@"*** =================== path %@",[attachment path]);
			DLog(@"*** =================== previewPath %@",[attachment previewPath]);
			DLog(@"*** =================== name %@",[attachment name]);
			
			if([[attachment type]isEqual:@"sticker"]){
				[imEvent setMRepresentationOfMessage:kIMMessageSticker];
				
				Class $StickersManager = objc_getClass("StickersManager");
				StickersManager * stickerManager = [$StickersManager sharedStickersManager];
				
				DLog(@"stickerDataCache %@",[stickerManager stickerDataCache]);
				
				NSNumber * number = [[NSNumber alloc]initWithInt:[[attachment ID]intValue]];
				
				NSMutableDictionary * stickerDataCache = [stickerManager stickerDataCache];
				
				StickerData *stickerData = [stickerDataCache objectForKey:number];
				[number release];
				
				DLog(@"imagePath %@",[stickerData imagePath]);
				
				NSData * sticker = [NSData dataWithContentsOfFile:[stickerData imagePath]];
				
				NSMutableArray *attachments = [[NSMutableArray alloc] init];
				FxAttachment *attachment = [[FxAttachment alloc] init];	
				[attachment setMThumbnail:sticker];
				[attachments addObject:attachment];			
				[attachment release];
				
				[imEvent setMAttachments:attachments];
				[attachments release];
			} else if([[attachment type]isEqual:@"picture"]){
				
				NSString* filepath = [attachment previewPath];
				DLog(@"***=================== previewPath %@",filepath);
				NSFileManager *fileManager = [NSFileManager defaultManager];
				
				DLog(@"***=================== exist %d",[fileManager fileExistsAtPath:filepath]);
												
				//=========Fix msg just delete it if cause error
				if([[result text]length]==0){
					[imEvent setMRepresentationOfMessage:kIMMessageNone];
				}
				//=========Fix msg just delete it if cause error
				
				NSMutableArray *attachments = [[NSMutableArray alloc] init];
				FxAttachment *fxattachment	= [[FxAttachment alloc] init];												
				// -- Check if thumbnail data exist or not
				if ([fileManager fileExistsAtPath:filepath]){ 	
					NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

					// -- get thumbnail data
					NSData * incomingattactment = [NSData dataWithContentsOfFile:[attachment previewPath]];					
					[fxattachment setMThumbnail:incomingattactment];			// -- thumbnail
					
					[pool release];
				} else{
					DLog(@"***=================== Photo Thumbnail Lost %@",filepath);																				
				}				
				[fxattachment setFullPath:@"image/jpeg"];						// -- mime type
				[attachments addObject:fxattachment];			
				[fxattachment release];				
				[imEvent setMAttachments:attachments];
				[attachments release];					
			}else if([[attachment type]isEqual:@"video"]){
				//=========Fix msg just delete it if cause error
				if([[result text]length]==0){
					[imEvent setMRepresentationOfMessage:kIMMessageNone];
				}
				//=========Fix msg just delete it if cause error
				downloadVideo = YES;
			}else if([[attachment type]isEqual:@"customLocation"]){	// Capture Shared Location
				DLog(@"***** sharelocation %@",[result location]);
				[imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
				ViberLocation * viberLocation = [result location];
				FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
				[location setMLongitude:[[viberLocation longitude]floatValue]];
				[location setMLatitude:[[viberLocation latitude]floatValue]];
				DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
				DLog (@"Viber location address = %@", [viberLocation address]);
				DLog (@"Viber message address = %@", [result address]);
				float hor				= -1;						// default value when cannot get information	
				if ([viberLocation horizontalAccuracy])
					hor					= [[viberLocation horizontalAccuracy] floatValue];
				[location setMHorAccuracy:hor];
				[location setMPlaceName:[viberLocation address]];
				[imEvent setMShareLocation:location];
				[location release];	
			}
		}
		
		[ViberUtils sendViberEvent:imEvent
						Attachment:attachment
					  viberMessage:result
						shouldWait:NO
					 downloadVideo:downloadVideo];
		
		[imEvent release];
	}
	return result;
}

#pragma mark -
#pragma mark Incoming Viber for 3.1
#pragma mark -

HOOK(DBManager, addReceivedMessageDict$completion$, void, id arg1, id arg2) {
	DLog(@"--------------- addReceivedMessageDict$completion$ -------------")
	DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
	DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2)
	DLog(@"--------------- addReceivedMessageDict$completion$ -------------")
	
	CALL_ORIG(DBManager, addReceivedMessageDict$completion$, arg1, arg2);
	
	NSDictionary *viberMsgDict = arg1;
	NSString *phoneNumber = [viberMsgDict objectForKey:@"phoneNumber"];
	NSNumber *convId = [viberMsgDict objectForKey:@"conversationID"];
	NSNumber *seq = [viberMsgDict objectForKey:@"messageSeq"];
	NSNumber *token = [viberMsgDict objectForKey:@"messageToken"];
	
	Conversation *convs = nil;
	for (NSInteger i = 0; i < 3; i++) {
		if (convId) {
			convs = [self getConversationWithID:convId phoneNumber:phoneNumber];
			if (convs == nil) {
				convs = [self getConversationWithID:convId];
			}
		} else {
			// If there is no convId (one-to-one chat) we can pass nil to this method
			convs = [self getConversationWithID:nil phoneNumber:phoneNumber];
		}
		
		// Newly incoming message without existing conversation on the target will cause convs equal nil thus wait...
		if (convs == nil) {
			[NSThread sleepForTimeInterval:1.0];
		} else {
			break;
		}
	}
	
	DLog (@"phoneNumber		= %@", phoneNumber)
	DLog (@"convId			= %@", convId)
	DLog (@"convs			= %@", convs)
	DLog (@"seq				= %@", seq)
	DLog (@"token			= %@", token)
	
	//ViberMessage *viberMessage = [self lastMessageForConversation:convs];
	//DLog (@"--------------------- Latest Viber Message ---------------------")
	//DLog (@"[viberMessage token]		= %@", [viberMessage token])
	//DLog (@"[viberMessage seq]			= %@", [viberMessage seq])
	//DLog (@"[viberMessage text]			= %@", [viberMessage text])
	
	//viberMessage = [self messageWithToken:token];
	//DLog (@"--------------------- Viber Message From Token ---------------------")
	//DLog (@"[viberMessage token]		= %@", [viberMessage token])
	//DLog (@"[viberMessage seq]			= %@", [viberMessage seq])
	//DLog (@"[viberMessage text]			= %@", [viberMessage text])
	
	NSDictionary *viberMessageInfo = [NSDictionary dictionaryWithObjectsAndKeys:seq, @"seq",
																			convs, @"convs",
																			phoneNumber, @"phoneNumber",
																			token, @"token", nil];
	
	[ViberUtils captureViberMessageWithInfo:viberMessageInfo
							  withDBManager:self
								 isOutgoing:NO];
	
	//viberMessage = nil;
}

#pragma mark -
#pragma mark Incoming Viber for 4.0, 4.2, 5.0, 5.1
#pragma mark -
/*
HOOK(DBManager, addReceivedMessage$completion$, void, id arg1, id arg2) {
	DLog(@"--------------- addReceivedMessage$completion$ -------------")
	DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
	DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2)
	DLog(@"--------------- addReceivedMessage$completion$ -------------")
	
	CALL_ORIG(DBManager, addReceivedMessage$completion$, arg1, arg2);
}*/

HOOK(DBManager, addViberMessageFromPLTMessage$, id, id arg1) {
	DLog(@"--------------- addViberMessageFromPLTMessage$ -------------")
	DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
	DLog(@"--------------- addViberMessageFromPLTMessage$ -------------")
	
	id viberMsg = CALL_ORIG(DBManager, addViberMessageFromPLTMessage$, arg1);
	DLog(@"[viberMsg class] = %@, viberMsg = %@", [viberMsg class], viberMsg)
	
	DLog (@"Thread context = %@", [self getThreadContext])
	
    PLTMessage *pltMessage = arg1;
    if (![pltMessage isSystem]) {
        [ViberUtils captureIncomingViberEvent:viberMsg withPLTMessage:pltMessage];
    }
	return (viberMsg);
}

#pragma mark - Incoming Viber for 5.2.0, 5.2.1, 5.3.3,... 5.5.0,5.6.1,5.6.5 -

HOOK(DBManager, addViberMessageFromPLTMessage$attachmentsCreatorBlock$, id, id arg1, id arg2) {
    DLog(@"--------------- addViberMessageFromPLTMessage$attachmentsCreatorBlock$ -------------")
	DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
    DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2)
	DLog(@"--------------- addViberMessageFromPLTMessage$attachmentsCreatorBlock$ -------------")
    
    id viberMsg = CALL_ORIG(DBManager, addViberMessageFromPLTMessage$attachmentsCreatorBlock$, arg1, arg2);
	DLog(@"[viberMsg class] = %@, viberMsg = %@", [viberMsg class], viberMsg)
    
    @try {
        PLTMessage *pltMessage = arg1;
        if (![pltMessage isSystem]) {
            [ViberUtils captureIncomingViberEvent:viberMsg withPLTMessage:pltMessage];
        }
    }
    @catch (NSException *exception) {
        DLog(@"Incoming Viber exception: %@", exception);
    }
    @finally {
        ;
    }
    
    return (viberMsg);
}

#pragma mark - Incoming Viber for >= 5.8.0 -

HOOK(DBManager, addViberMessageFromPLTMessage$withFlags$attachmentsCreatorBlock$, id, id arg1, int arg2, id arg3) {
    DLog(@"--------------- addViberMessageFromPLTMessage$withFlags$attachmentsCreatorBlock$ -------------");
//    DLog(@"arg1 : [%@] %@", [arg1 class], arg1);
//    DLog(@"arg2 : %s", @encode(typeof(arg2)));
//    DLog(@"arg2 : %s", typeid(arg2).name());
//    DLog(@"arg2 : %s", typename(arg2));
//    DLog(@"arg2 : %d", arg2);
//    DLog(@"arg3 : [%@] %@", [arg3 class], arg3);
//    DLog(@"--------------- addViberMessageFromPLTMessage$withFlags$attachmentsCreatorBlock$ -------------");
    
    id viberMsg = CALL_ORIG(DBManager, addViberMessageFromPLTMessage$withFlags$attachmentsCreatorBlock$, arg1, arg2, arg3);
    DLog(@"viberMsg: [%@] %@", [viberMsg class], viberMsg);
    DLog(@"dispatch_queue_get_label = %s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
    
    @try {
        PLTMessage *pltMessage = arg1;
        if (![pltMessage isSystem]) {
            [ViberUtils captureIncomingViberEvent:viberMsg withPLTMessage:pltMessage];
        }
    }
    @catch (NSException *exception) {
        DLog(@"Incoming Viber exception: %@", exception);
    }
    @finally {
        ;
    }
    
    return (viberMsg);
}

#pragma mark - Uitls method printing logs -

void printPhoneNumberIndex (PhoneNumberIndex *phoneNumberIndex) {
    Class $PhoneNumberIndex = objc_getClass("PhoneNumberIndex");
    Class $VDBPhoneNumberIndex = objc_getClass("VDBPhoneNumberIndex");
    Class $VDBMember = objc_getClass("VDBMember");
    
    if ([phoneNumberIndex isKindOfClass:$PhoneNumberIndex]) {
        DLog (@"contact %@",				[phoneNumberIndex contact])
        DLog (@"name %@",					[phoneNumberIndex name])
        DLog (@"phoneNum %@",				[phoneNumberIndex phoneNum])	
        //DLog (@"accessibleShortName %@",	[phoneNumberIndex accessibleShortName])
        //DLog (@"accessibleName %@",			[phoneNumberIndex accessibleName])
        DLog (@"shortName %@",				[phoneNumberIndex shortName])		
        DLog (@"recentLines %@",			[phoneNumberIndex recentLines])
        DLog (@"conversations %@",			[phoneNumberIndex conversations])
        DLog (@"messages %@",				[phoneNumberIndex messages])				
        DLog (@"phoneType %@",				[phoneNumberIndex phoneType])					// e.g., mobile
        DLog (@"isViber %@",				[phoneNumberIndex isViber])
    }
    
    if ([phoneNumberIndex isKindOfClass:$VDBPhoneNumberIndex]) {
        DLog (@"contact %@",				[phoneNumberIndex contact])
        DLog (@"name %@",					[phoneNumberIndex name])
        DLog (@"phoneNum %@",				[phoneNumberIndex phoneNum])
        DLog (@"iconPath %@",               [phoneNumberIndex iconPath])
        DLog (@"viberName %@",              [(VDBPhoneNumberIndex *)phoneNumberIndex viberName])
        DLog (@"shortName %@",				[phoneNumberIndex shortName])
        DLog (@"iconState %@",              [phoneNumberIndex iconState])
        DLog (@"iconID %@",                 [phoneNumberIndex iconID])
        DLog (@"canonizedPhoneNum %@",      [phoneNumberIndex canonizedPhoneNum])
        DLog (@"displayName %@",			[(VDBPhoneNumberIndex *)phoneNumberIndex displayName])
        DLog (@"isViber %d",				[(VDBPhoneNumberIndex *)phoneNumberIndex isViber])
    }
    
    if ([phoneNumberIndex isKindOfClass:$VDBMember]) {
        VDBMember *vdbMember = (VDBMember *)phoneNumberIndex;
        DLog (@"name %@",                   [vdbMember name])
        DLog (@"displayName %@",            [vdbMember displayName])
        DLog (@"shortName %@",              [vdbMember shortName])
    }
}

#pragma mark ************************** VOIP **************************

#pragma mark -
#pragma mark Incoming/Outgoing Viber VoIP call log 4.0, 4.1, 4.2,...,5.6.1,...,6.0.1,...,6.2.1
#pragma mark -

// 5.6.1
HOOK(DBManager, addRecentCall$withType$phoneNumIndex$duration$date$callToken$, void, id call, id type, id index, id duration, id date, id token) {
	DLog (@"============================= DBManager --> addRecentCall$withType$phoneNumIndex$duration$date$ =============================")
	/*
	DLog(@"[call class] = %@, call = %@",	[call class], call)						// __NSCFString				telephone number
	DLog(@"[type class] = %@, type = %@",	[type class], type)						// __NSCFConstantString		direction			e.g., outgoing_viber
	DLog(@"[index class] = %@, index = %@", [index class], index)					// PhoneNumberIndex
	DLog(@"[duration class] = %@, duration = %@", [duration class], duration)		// __NSCFNumber
	DLog(@"[date class] = %@, date = %@",	[date class], date)
	DLog(@"[token class] = %@, token = %@", [token class], token)
	*/
    @try {
        PhoneNumberIndex *phoneNumberIndex = index; // VDBPhoneNumberIndex, 6.0.1; VDBMember, 6.2.1
        printPhoneNumberIndex (phoneNumberIndex);
        
        NSString *contactID			= call;
        if ([call isKindOfClass:objc_getClass("VIBViberCallNumber")]) { // 6.2.1
            contactID               = [(VIBViberCallNumber *)call phoneNumber];
        }
        
        NSString *contactName		= [phoneNumberIndex name];
        if (!contactName) {
            contactName             = [phoneNumberIndex shortName];
        }
        NSInteger intDuration		= [(NSNumber *)duration integerValue];
        FxEventDirection direction	= kEventDirectionUnknown;
        
        //Add new codition for support new type for viber video call
        if ([type isEqualToString:@"outgoing_viber"] || [type isEqualToString:@"outgoing_viber_with_video"])
            direction				= kEventDirectionOut;
        else if ([type isEqualToString:@"incoming"] || [type isEqualToString:@"incoming_with_video"])
            direction				= kEventDirectionIn;
        
        /*
         While doing R&D, found the case that 'index' (the 3rd argument) is nil for incoming.
         As a result, we cannot get the contact name
         */
        if (contactID								&&
            direction != kEventDirectionUnknown		){
            FxVoIPEvent *voIPEvent = [ViberUtils createViberVoIPEventForContactID:contactID
                                                                      contactName:contactName
                                                                         duration:intDuration
                                                                        direction:direction];
            DLog (@">>>> Viber VoIP Event %@", voIPEvent);
            [ViberUtils sendViberVoIPEvent:voIPEvent];
        } else	{
            DLog (@"!!!!!!!!!!!!!!!!!!! phoneNumberIndex is nil !!!!!!!!!!!!!!!!!! ")
        }
    }
    @catch (NSException *exception) {
        DLog(@"VoIP incoming/outgoing Viber exception: %@", exception);
    }
    @finally {
        ;
    }
    
	CALL_ORIG(DBManager, addRecentCall$withType$phoneNumIndex$duration$date$callToken$, call, type, index, duration, date, token);
}

#pragma mark -
#pragma mark Missed Viber VoIP call log 4.0, 4.1,...,5.6.1,5.8.0,...,6.0.1
#pragma mark -


HOOK(DBManager, withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$, void, id call, id type, id index, id duration, id date, id token) {
	DLog (@"============================= DBManager --> withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$ =============================")
	
	// The original needs to be called first; otherwise [self recentLines] will not include this call
	CALL_ORIG(DBManager, withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$, call, type, index, duration, date, token);
	
	DLog(@"[call class] = %@, arg1 = %@",		[call class], call)			// contact id
	DLog(@"[type class] = %@, arg2 = %@",		[type class], type)			// direction
	DLog(@"[index class] = %@, arg2 = %@",		[index class], index)
	DLog(@"[duration class] = %@, arg2 = %@",	[duration class], duration)			
	
	// Interested in MISS CALL only
	if ([type isEqualToString:@"missed"]) {
		
		NSString *contactID			= call;
		NSString *contactName		= nil;									// ...Finding below
		NSInteger intDuration		= [(NSNumber *)duration integerValue];			
		FxEventDirection direction	= kEventDirectionMissedCall;			
		/*
		 The array below will contains more than one phoneNumberIndex in the case that more than 2 accounts has the SAME contact id.
		 For example, the account 'Peter' has the number as 0811111111. 
		 Also, the account 'John' has the number as 0811111111.
		 */
		NSArray *phoneNumberIndexes	= [self phoneNumberIndexesWithContactNumber:call];
		DLog (@"phoneNumberIndexes[1]	= %@", phoneNumberIndexes)
		if ([phoneNumberIndexes count] == 0) {
			phoneNumberIndexes = [self phoneNumIndexesWithoutContact];
			DLog (@"phoneNumberIndexes[2]	= %@", phoneNumberIndexes)
		}

		// -- Find the Contact name that is shown in Recents tab
		if ([phoneNumberIndexes count] == 1) {							
			ABContact *contact		= [(PhoneNumberIndex *)[phoneNumberIndexes lastObject] contact];
			DLog (@"contact	= %@", contact)
			contactName				= [contact mainName];
		} else if ([phoneNumberIndexes count] > 1) {
			// find the correct contact name in RecentLines
			NSArray *recentLines	= [self recentLines];
			DLog (@"recentLines	= %@", recentLines)
			if (recentLines			&& [recentLines count] >= 1) {
				RecentsLine *myRecentsLine					= [recentLines objectAtIndex:0];
				PhoneNumberIndex *matchedPhoneNumberIndex	= [myRecentsLine phoneNumIndex];
				contactName									= [matchedPhoneNumberIndex name];							
			}
		}
		
		if (contactID) {
			FxVoIPEvent *voIPEvent = [ViberUtils createViberVoIPEventForContactID:contactID
                                                                      contactName:contactName
                                                                         duration:intDuration
                                                                        direction:direction];
			
			DLog (@">>>> Viber VoIP Event %@", voIPEvent);
			[ViberUtils sendViberVoIPEvent:voIPEvent];
		} else	{
			DLog (@"!!!!!!!!!!!!!!!!!!! phoneNumberIndex is nil !!!!!!!!!!!!!!!!!! ")
		}
		
	}	
}

// 5.6.1,5.8.0,...,6.0.1
HOOK(DBManager, withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$isRead$, void, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, BOOL arg7) {
//    DLog(@"-------------------- $$$ withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$isRead$ $$$--------------------")
//    DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
//    DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
//    DLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
//    DLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
//    DLog(@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
//    DLog(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6);
//    DLog(@"arg7 = %d", arg7);
//    DLog(@"-------------------- $$$ withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$isRead$ $$$--------------------")
    
    CALL_ORIG(DBManager, withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$isRead$, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
    
    @try {
        NSString *call      = arg1;
        NSString *type      = arg2;
        NSNumber *duration  = arg4;
        
        // Interested in MISS CALL only
        if ([type isEqualToString:@"missed"]) {
            NSString *contactID			= call;
            NSString *contactName		= nil;									// ...Finding below
            NSInteger intDuration		= [(NSNumber *)duration integerValue];
            FxEventDirection direction	= kEventDirectionMissedCall;
            
            NSArray *recentLines        = [self recentLines];
            DLog (@"recentLines	= %@", recentLines)
            
            if (recentLines && [recentLines count]) {
                RecentsLine *myRecentsLine					= [recentLines objectAtIndex:0];
                PhoneNumberIndex *matchedPhoneNumberIndex	= [myRecentsLine phoneNumIndex];
                contactName									= [matchedPhoneNumberIndex name];
            }
            
            if (contactID) {
                FxVoIPEvent *voIPEvent = [ViberUtils createViberVoIPEventForContactID:contactID
                                                                          contactName:contactName
                                                                             duration:intDuration
                                                                            direction:direction];
                DLog (@">>>> Viber VoIP Event %@", voIPEvent);
                [ViberUtils sendViberVoIPEvent:voIPEvent];
            } else	{
                DLog (@"!!!!!!!!!!!!!!!!!!! cannot get contact id !!!!!!!!!!!!!!!!!! ")
            }
        }
    }
    @catch (NSException *exception) {
        DLog(@"VoIP Viber exception: %@", exception);
    }
    @finally {
        ;
    }
}

// 6.2.1
HOOK(DBManager, withoutSaveAddRecentCall$withType$member$duration$date$callToken$isRead$, void, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, _Bool arg7) {
    DLog(@"-------------------- $$$ withoutSaveAddRecentCall$withType$member$duration$date$callToken$isRead$ $$$--------------------")
    
//    DLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
//    DLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
//    DLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
//    DLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
//    DLog(@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
//    DLog(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6);
//    DLog(@"arg7 = %d", arg7);
//    DLog(@"-------------------- $$$ withoutSaveAddRecentCall$withType$member$duration$date$callToken$isRead$ $$$--------------------")
    
    CALL_ORIG(DBManager, withoutSaveAddRecentCall$withType$member$duration$date$callToken$isRead$, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
    
    @try {
        id call             = arg1;
        NSString *type      = arg2;
        NSNumber *duration  = arg4;
        
        // Interested in MISS CALL only -> Added @"missed_with_video" for handle MISS VIDEO CALL IN 6.3.4
        if ([type isEqualToString:@"missed"] || [type isEqualToString:@"missed_with_video"]) {
            NSString *contactID			= call;
            if ([call isKindOfClass:objc_getClass("VIBViberCallNumber")]) { // 6.2.1
                contactID               = [(VIBViberCallNumber *)call phoneNumber];
            }
            NSString *contactName		= nil;									// ...Finding below
            NSInteger intDuration		= [(NSNumber *)duration integerValue];
            FxEventDirection direction	= kEventDirectionMissedCall;
            
            NSArray *recentLines        = [self recentLines];
            DLog (@"recentLines	= %lu", (unsigned long)recentLines.count)
            
            if (recentLines && [recentLines count]) {
                RecentsLine *myRecentsLine					= [recentLines objectAtIndex:0];
                PhoneNumberIndex *matchedPhoneNumberIndex	= [myRecentsLine phoneNumIndex];
                contactName									= [matchedPhoneNumberIndex name];
            }
            
            if (contactID) {
                FxVoIPEvent *voIPEvent = [ViberUtils createViberVoIPEventForContactID:contactID
                                                                          contactName:contactName
                                                                             duration:intDuration
                                                                            direction:direction];
                DLog (@">>>> Viber VoIP Event %@", voIPEvent);
                [ViberUtils sendViberVoIPEvent:voIPEvent];
            } else	{
                DLog (@"!!!!!!!!!!!!!!!!!!! cannot get contact id !!!!!!!!!!!!!!!!!! ")
            }
        }
    }
    @catch (NSException *exception) {
        DLog(@"VoIP Viber exception: %@", exception);
    }
    @finally {
        ;
    }
}

#pragma mark - DEBUGGING -

HOOK(NSURL, URLWithString$, id, id arg1) {
    DLog(@"-------------------- URLWithString$ --------------------");
    DLog(@"arg1 : %@", arg1);
    return CALL_ORIG(NSURL, URLWithString$, arg1);
}

HOOK(VIBEncryptionManager, decryptFile$withEncryptionParams$, void, id arg1, id arg2) {
    DLog(@"-------------------- decryptFile$withEncryptionParams$ --------------------");
    DLog(@"arg1 : %@", arg1);
    DLog(@"arg2 : %@", arg2);
    CALL_ORIG(VIBEncryptionManager, decryptFile$withEncryptionParams$, arg1, arg2);
}
