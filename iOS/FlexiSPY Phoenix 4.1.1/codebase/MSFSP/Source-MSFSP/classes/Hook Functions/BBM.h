//
//  BBm.h
//  MSFSP
//
//  Created by Ophat Phuetkasickonphasutha on 11/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBMUtils.h"
#import "IMShareUtils.h"

#import "BBMCoreAccess.h"
#import "BBMCommonConversation.h"
#import "BBMElement.h"
#import "BBMGenUser.h"
#import "BBMUser.h"
#import "BBMGenMessage.h"
#import "BBMGenMessage+2-1-0.h"
#import "BBMMessage.h"
#import "BBMMessage+2-1-0.h"
#import "BBMMessage+2-5-0.h"
#import "BBMPicture.h"
#import "BBMGenPicture+2-4-0.h"
#import "BBMPicture+2-4-0.h"
#import "BBMFileTransfer.h"
#import "BBMGenFileTransfer+2-4-0.h"

#import "BBMConversation.h"

#import "BBMCoreAccess+2-1-0.h"
#import "BBMStickerPack.h"
#import "BBMStickerImage.h"
#import "BBMDSGeneratedModel.h"
#import "BBMGenLocation.h"
#import "BBMLocation.h"
#import "BBMQuickActionAttachmentView.h"
#import "BBMConnection.h"
#import "BBMCoreAccessGroup.h"
#import "BBMDSConnection.h"
#import "ResultParser.h"
#import "ZXResultParser.h"
#import "DBChooserResult.h"

#import "BBMMessage_Ephemeral.h"

#pragma mark - ========== sendBroadcastMessage ... -

HOOK(BBMCoreAccess, sendBroadcastMessage$to$,void,id arg1,id arg2){
	DLog(@"##### sendBroadcastMessage$ %@ to$ %@",arg1,arg2);
	NSMutableArray * listOfConversation = [[NSMutableArray alloc] initWithArray:[self getConversations]];
    DLog(@"## listOfConversation %@",listOfConversation);
	NSMutableArray * target = arg2;
	for(int i=0;i<[listOfConversation count];i++){
        NSMutableArray * listOfResolvedParticipants;
        NSString * convName			 = nil;
        NSString * convID			 = nil;
        
        if ([self respondsToSelector:@selector(getConversationForURI:)]) {
            DLog(@"############# BBM version > 2.0 #################");
            BBMConversation * bbm = [listOfConversation objectAtIndex:i];
            listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbm resolvedParticipants]];
            convName			= [bbm conversationTitle];
            convID				= [bbm conversationUri];
        }else{
            DLog(@"############# BBM old version < 2.0 #################");
            //Class $BBMCommonConversation = objc_getClass("BBMCommonConversation");
            BBMCommonConversation * bbmC = [listOfConversation objectAtIndex:i];
            listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbmC resolvedParticipants]];
            convName			= [bbmC title];
            convID				= [bbmC conversationUri];
        }
        
		BBMUser * user = [self currentUser];
		
		if([listOfResolvedParticipants count] == 1){
			
			BBMUser * people = [listOfResolvedParticipants objectAtIndex:0];
			
			for(int j=0 ; j< [target count];j++){
				if([[NSString stringWithFormat:@"%@",[people getUri]]isEqualToString:[NSString stringWithFormat:@"%@",[target objectAtIndex:j]]]){
					NSString * message = arg1;
					FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
					NSMutableArray *participants = [[NSMutableArray alloc] init];
					NSString * imServiceID		 = @"BBM";
					NSString * myName			 = nil;
					NSString * myID				 = nil;
					NSString * myStatus			 = nil;
					NSData   * myPhoto			 = nil;
					//NSData   * convPhoto		 = nil;	
					
					DLog(@"======================== %d",j);
					DLog(@"Type : Message | Direction : Sendout");
					DLog(@"ConversationID %@",convID);
					DLog(@"ConversationName %@",convName);
					DLog(@"UserID %@",[user getUri]);
					DLog(@"UserName %@",[user getDisplayName]);
					DLog(@"UserCurrentStatus %@",[user getCurrentStatus]);
					DLog(@"UserLocation %@",[user getLocation]);
					DLog(@"UserAvatarImagePath %@",[user avatarImagePath]);
					
					myName				= [user getDisplayName];
					myID				= [user getUri];
					myStatus			= [user getCurrentStatus];
					myPhoto				= [NSData dataWithContentsOfFile:[user avatarImagePath]];
					
					DLog(@"peopleID %@",[people getUri]);
					DLog(@"peopleName %@",[people getDisplayName]);
					DLog(@"peopleCurrentStatus %@",[people getCurrentStatus]);
					DLog(@"peopleLocation %@",[people getLocation]);
					DLog(@"peopleAvatarImagePath %@",[people avatarImagePath]);	
					DLog(@"TargetID %@",[target objectAtIndex:j]);
					
					FxRecipient *participant = [[FxRecipient alloc] init];
					[participant setRecipNumAddr:[people getUri]];
					[participant setMPicture:[NSData dataWithContentsOfFile:[people avatarImagePath]]];
					[participant setRecipContactName:[people getDisplayName]];
					[participant setMStatusMessage:[people getCurrentStatus]];
					[participants addObject:participant];
					[participant release];	
					
					[imEvent setMDirection:kEventDirectionOut];
					[imEvent setMRepresentationOfMessage:kIMMessageText];
					[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
					[imEvent setMIMServiceID:imServiceID];
					[imEvent setMServiceID:kIMServiceBBM];
					[imEvent setMUserID:myID];
					[imEvent setMUserDisplayName:myName];
					[imEvent setMUserStatusMessage:myStatus];
					[imEvent setMUserPicture:myPhoto];
					[imEvent setMParticipants:participants];
					[imEvent setMConversationID:convID];
					[imEvent setMConversationName:convName];
					//[imEvent setMConversationPicture:convPhoto];
					[imEvent setMMessage:message];
					
					[BBMUtils sendBBMEvent:imEvent];
					
					[participants release];
					[imEvent release];
				}
			}		
		}
		
		[listOfResolvedParticipants release];		
	}
	[listOfConversation release];
	
	CALL_ORIG(BBMCoreAccess, sendBroadcastMessage$to$, arg1 ,arg2);
}

#pragma mark - ========== Sendout Audio, Calendar,etc ... -

HOOK(BBMCoreAccess, fileTransferTo$withDescription$path$,void,id arg1,id arg2,id arg3){
	DLog(@"========= fileTransferTo$withDescription$path$ =========");
    DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
    DLog(@"========= arg3 %@",arg3);
   NSString * message = arg2;
	NSString * fileAtPath = arg3;
	NSString * imServiceID		 = @"BBM";
	NSString * myName			 = nil;
	NSString * myID				 = nil;
	NSString * myStatus			 = nil;
	NSData   * myPhoto			 = nil;
	NSString * convName			 = nil;
	NSString * convID			 = nil;
    NSMutableArray * listOfResolvedParticipants;
	//NSData   * convPhoto		 = nil;
	
	NSMutableArray * multipleConversation = arg1;
	for (int i=0; i<[multipleConversation count]; i++) {
		FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
		NSMutableArray *participants = [[NSMutableArray alloc] init];
		NSMutableArray *attachments  = [[NSMutableArray alloc] init];
		[imEvent setMRepresentationOfMessage:kIMMessageText];
        
        if ([self respondsToSelector:@selector(getConversationForURI:)]) {
            DLog(@"############# BBM version > 2.0 #################");
            BBMConversation * bbm = [self getConversationForURI:[(NSArray *)arg1 objectAtIndex:0]];
            convName			= [bbm conversationTitle];
            convID				= [bbm conversationUri];
            listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbm resolvedParticipants]];
        }else{
            DLog(@"############# BBM old version < 2.0 #################");
            Class $BBMCommonConversation = objc_getClass("BBMCommonConversation");
            BBMCommonConversation * bbmC = [$BBMCommonConversation conversationWithURI:arg2];
            convName			= [bbmC title];
            convID				= [bbmC conversationUri];
            listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbmC resolvedParticipants]];
        }
        
		BBMUser * user = [self currentUser];

		myName				= [user getDisplayName];
		myID				= [user getUri];
		myStatus			= [user getCurrentStatus];
		myPhoto				= [NSData dataWithContentsOfFile:[user avatarImagePath]];
		
		DLog(@"Type : Audio/ETC | Direction : Sendout");
		DLog(@"ConversationID %@",convID);
		DLog(@"ConversationName %@",convName);
		DLog(@"UserID %@",[user getUri]);
		DLog(@"UserName %@",[user getDisplayName]);
		DLog(@"UserCurrentStatus %@",[user getCurrentStatus]);
		DLog(@"UserLocation %@",[user getLocation]);
		DLog(@"UserAvatarImagePath %@",[user avatarImagePath]);

		for (int i =0; i<[listOfResolvedParticipants count]; i++) {
			BBMUser * target = [listOfResolvedParticipants objectAtIndex:i];
			
			DLog(@"======================== %d",i);
			DLog(@"TargetID %@",[target getUri]);
			DLog(@"TargetName %@",[target getDisplayName]);
			DLog(@"TargetCurrentStatus %@",[target getCurrentStatus]);
			DLog(@"TargetLocation %@",[target getLocation]);
			DLog(@"TargetAvatarImagePath %@",[target avatarImagePath]);
			
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:[target getUri]];
			[participant setMPicture:[NSData dataWithContentsOfFile:[target avatarImagePath]]];
			[participant setRecipContactName:[target getDisplayName]];
			[participant setMStatusMessage:[target getCurrentStatus]];
			[participants addObject:participant];
			[participant release];	
		}
		
		if ([fileAtPath rangeOfString:@".vcf"].location != NSNotFound) {
			NSFileManager * search = [NSFileManager defaultManager];
			NSString * name = nil;
			if ([search fileExistsAtPath:fileAtPath]) {
                /*
				NSError * err = nil;
				NSString * read = [NSString stringWithContentsOfFile:fileAtPath encoding:NSUTF8StringEncoding error:&err];
				NSArray * splitID = [read componentsSeparatedByString:@"\n"];
				
				for (int i=0; i<[splitID count]; i++) {
					if ([[splitID objectAtIndex:i] rangeOfString:@"FN:"].location != NSNotFound) {
						NSArray * spliter = [[splitID objectAtIndex:i]componentsSeparatedByString:@"FN:"];
						name = [spliter objectAtIndex:([spliter count]-1)];
					}
				}
                message = [NSString stringWithFormat:@"Account Name:%@",name];
                [imEvent setMRepresentationOfMessage:kIMMessageContact];
                 */
                
                NSData *vCardData = [NSData dataWithContentsOfFile:fileAtPath];
                if (vCardData == nil) {
                    DLog(@"Cannot get vCard data thus wait 1 second");
                    [NSThread sleepForTimeInterval:1.0];
                    vCardData = [NSData dataWithContentsOfFile:fileAtPath];
                }
                
                if (vCardData == nil) {
                    DLog(@"Lost vCard data ...");
                    name = @"";
                } else {
                    name = [IMShareUtils getVCardStringFromDataV2:vCardData];
                }
                message = [NSString stringWithString:name];
                [imEvent setMRepresentationOfMessage:kIMMessageContact];
			}
		} else {
			NSString* attachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imBBM/"];
            NSString *saveFilePath      = nil;
            if ([fileAtPath rangeOfString:@".vcs"].location != NSNotFound) { // Calendar event
                saveFilePath = [NSString stringWithFormat:@"%@%f.vcs",attachmentPath,[[NSDate date] timeIntervalSince1970]];
            } else {
                saveFilePath = [NSString stringWithFormat:@"%@%f.amr",attachmentPath,[[NSDate date] timeIntervalSince1970]];
            }
            
            NSString *pathExtension = [fileAtPath pathExtension];
            if ([pathExtension length] == 0) {
                pathExtension = @"unknown";
            }
            DLog(@"pathExtension, %@", pathExtension);
			
			NSData * xData = [NSData dataWithContentsOfFile:fileAtPath];
            if (![xData writeToFile:saveFilePath atomically:YES]) {
                // Sandbox, iOS 9
                saveFilePath = [IMShareUtils saveData:xData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
            }
			
			FxAttachment *attachment = [[FxAttachment alloc] init];
			[attachment setFullPath:saveFilePath];
			[attachment setMThumbnail:nil];
			[attachments addObject:attachment];	
			[attachment release];
            
            [imEvent setMRepresentationOfMessage:kIMMessageNone];
		}
		
		DLog(@"Message %@",message);
		DLog(@"fileAtPath %@",fileAtPath);
		
		[imEvent setMDirection:kEventDirectionOut];
		
		if([attachments count]>0){
			[imEvent setMAttachments:attachments];
		}
		
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMServiceID:kIMServiceBBM];					  
		[imEvent setMUserID:myID];
		[imEvent setMUserDisplayName:myName];
		[imEvent setMUserStatusMessage:myStatus];
		[imEvent setMUserPicture:myPhoto];
		[imEvent setMParticipants:participants];
		[imEvent setMConversationID:convID];
		[imEvent setMConversationName:convName];
		//[imEvent setMConversationPicture:convPhoto];
		[imEvent setMMessage:message];
								  
		[BBMUtils sendBBMEvent:imEvent];
		
		[attachments release];
		[participants release];
		[imEvent release];
		[listOfResolvedParticipants release];
	}
	CALL_ORIG(BBMCoreAccess, fileTransferTo$withDescription$path$, arg1 ,arg2,arg3);
}

#pragma mark - ========== Sendout picture,video (from ablum) -

HOOK(BBMCoreAccess, pictureTransferTo$withDescription$path$,void,id arg1,id arg2,id arg3){
	DLog(@"========= pictureTransferTo$withDescription$path$ =========");
    DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
    DLog(@"========= arg3 %@",arg3);
	NSString * message = arg2;
	NSString * fileAtPath = arg3;
	NSString * imServiceID		 = @"BBM";
	NSString * myName			 = nil;
	NSString * myID				 = nil;
	NSString * myStatus			 = nil;
	NSData   * myPhoto			 = nil;
	NSString * convName			 = nil;
	NSString * convID			 = nil;
    NSMutableArray * listOfResolvedParticipants;
	//NSData   * convPhoto		 = nil;
	
	NSMutableArray * multipleConversation = arg1;
	for (int i=0; i<[multipleConversation count]; i++) {
		FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
		NSMutableArray *participants = [[NSMutableArray alloc] init];
		NSMutableArray *attachments  = [[NSMutableArray alloc] init];
		
        if ([self respondsToSelector:@selector(getConversationForURI:)]) {
            DLog(@"############# BBM version > 2.0 #################");
            BBMConversation * bbm = [self getConversationForURI:[(NSArray *)arg1 objectAtIndex:0]];
            convName			= [bbm conversationTitle];
            convID				= [bbm conversationUri];
            listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbm resolvedParticipants]];
        }else{
            DLog(@"############# BBM old version < 2.0 #################");
            Class $BBMCommonConversation = objc_getClass("BBMCommonConversation");
            BBMCommonConversation * bbmC = [$BBMCommonConversation conversationWithURI:arg2];
            convName			= [bbmC title];
            convID				= [bbmC conversationUri];
            listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbmC resolvedParticipants]];
        }
        
		BBMUser * user = [self currentUser];
		
		myName				= [user getDisplayName];
		myID				= [user getUri];
		myStatus			= [user getCurrentStatus];
		myPhoto				= [NSData dataWithContentsOfFile:[user avatarImagePath]];
		
		DLog(@"Type : Picture | Direction : Sendout");
		DLog(@"ConversationID %@",convID);
		DLog(@"ConversationName %@",convName);
		DLog(@"UserID %@",[user getUri]);
		DLog(@"UserName %@",[user getDisplayName]);
		DLog(@"UserCurrentStatus %@",[user getCurrentStatus]);
		DLog(@"UserLocation %@",[user getLocation]);
		DLog(@"UserAvatarImagePath %@",[user avatarImagePath]);
		
		for (int i =0; i<[listOfResolvedParticipants count]; i++) {
			BBMUser * target = [listOfResolvedParticipants objectAtIndex:i];
			
			DLog(@"======================== %d",i);
			DLog(@"TargetID %@",[target getUri]);
			DLog(@"TargetName %@",[target getDisplayName]);
			DLog(@"TargetCurrentStatus %@",[target getCurrentStatus]);
			DLog(@"TargetLocation %@",[target getLocation]);
			DLog(@"TargetAvatarImagePath %@",[target avatarImagePath]);	
			
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:[target getUri]];
			[participant setMPicture:[NSData dataWithContentsOfFile:[target avatarImagePath]]];
			[participant setRecipContactName:[target getDisplayName]];
			[participant setMStatusMessage:[target getCurrentStatus]];
			[participants addObject:participant];
			[participant release];	
		}
		DLog(@"Message %@",message);
		DLog(@"fileAtPath %@",fileAtPath);
        
        NSString *pathExtension = [fileAtPath pathExtension];
        if ([pathExtension length] == 0) {
            pathExtension = @"jpeg";
        }
		
		NSString* attachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imBBM/"];
		NSString *saveFilePath = [NSString stringWithFormat:@"%@%f.%@",attachmentPath,[[NSDate date] timeIntervalSince1970],pathExtension];
		NSData * pictureData = [NSData dataWithContentsOfFile:fileAtPath];
        if (![pictureData writeToFile:saveFilePath atomically:YES]) {
            // Sandbox, iOS 9
            saveFilePath = [IMShareUtils saveData:pictureData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
        }
		
		FxAttachment *attachment = [[FxAttachment alloc] init];
		[attachment setFullPath:saveFilePath];
		[attachment setMThumbnail:nil];
		[attachments addObject:attachment];	
		[attachment release];
		
		[imEvent setMDirection:kEventDirectionOut];
        
        unsigned int rep = (kIMMessageText | kIMMessageNone); // May be cause int hook method that we cannot assign value right the way to enum type
        [imEvent setMRepresentationOfMessage:(FxIMMessageRepresentation)rep];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMServiceID:kIMServiceBBM];
		[imEvent setMUserID:myID];
		[imEvent setMUserDisplayName:myName];
		[imEvent setMUserStatusMessage:myStatus];
		[imEvent setMUserPicture:myPhoto];
		[imEvent setMParticipants:participants];
		[imEvent setMConversationID:convID];
		[imEvent setMConversationName:convName];
		//[imEvent setMConversationPicture:convPhoto];
		[imEvent setMMessage:message];
		[imEvent setMAttachments:attachments];
		
		[BBMUtils sendBBMEvent:imEvent];
		
		[attachments release];
		[participants release];
		[imEvent release];
		[listOfResolvedParticipants release];
		
	}
	
	CALL_ORIG(BBMCoreAccess, pictureTransferTo$withDescription$path$, arg1 ,arg2,arg3);
}

// Outgoing time control picture BBM 2.5.0
HOOK(BBMCoreAccess, pictureTransferTo$withDescription$path$timeLimit$,void,id arg1,id arg2,id arg3 ,unsigned limit){
	DLog(@"========= pictureTransferTo$withDescription$path$timeLimit$ =========");
    DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
    DLog(@"========= arg3 %@",arg3);
    DLog(@"========= limit %d",limit);
	NSString * message = arg2;
	NSString * fileAtPath = arg3;
	NSString * imServiceID		 = @"BBM";
	NSString * myName			 = nil;
	NSString * myID				 = nil;
	NSString * myStatus			 = nil;
	NSData   * myPhoto			 = nil;
	NSString * convName			 = nil;
	NSString * convID			 = nil;
    NSMutableArray * listOfResolvedParticipants;
	//NSData   * convPhoto		 = nil;
	
	NSMutableArray * multipleConversation = arg1;
	for (int i=0; i<[multipleConversation count]; i++) {
		FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
		NSMutableArray *participants = [[NSMutableArray alloc] init];
		NSMutableArray *attachments  = [[NSMutableArray alloc] init];
		
        if ([self respondsToSelector:@selector(getConversationForURI:)]) {
            DLog(@"############# BBM version > 2.0 #################");
            BBMConversation * bbm = [self getConversationForURI:[(NSArray *)arg1 objectAtIndex:0]];
            convName			= [bbm conversationTitle];
            convID				= [bbm conversationUri];
            listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbm resolvedParticipants]];
        }
        /*
        else{
            DLog(@"############# BBM old version < 2.0 #################");
            Class $BBMCommonConversation = objc_getClass("BBMCommonConversation");
            BBMCommonConversation * bbmC = [$BBMCommonConversation conversationWithURI:arg2];
            convName			= [bbmC title];
            convID				= [bbmC conversationUri];
            listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbmC resolvedParticipants]];
        }
        */
		BBMUser * user = [self currentUser];
		
		myName				= [user getDisplayName];
		myID				= [user getUri];
		myStatus			= [user getCurrentStatus];
		myPhoto				= [NSData dataWithContentsOfFile:[user avatarImagePath]];
		
		DLog(@"Type : Picture | Direction : Sendout");
		DLog(@"ConversationID %@",convID);
		DLog(@"ConversationName %@",convName);
		DLog(@"UserID %@",[user getUri]);
		DLog(@"UserName %@",[user getDisplayName]);
		DLog(@"UserCurrentStatus %@",[user getCurrentStatus]);
		DLog(@"UserLocation %@",[user getLocation]);
		DLog(@"UserAvatarImagePath %@",[user avatarImagePath]);
		
		for (int i =0; i<[listOfResolvedParticipants count]; i++) {
			BBMUser * target = [listOfResolvedParticipants objectAtIndex:i];
			
			DLog(@"======================== %d",i);
			DLog(@"TargetID %@",[target getUri]);
			DLog(@"TargetName %@",[target getDisplayName]);
			DLog(@"TargetCurrentStatus %@",[target getCurrentStatus]);
			DLog(@"TargetLocation %@",[target getLocation]);
			DLog(@"TargetAvatarImagePath %@",[target avatarImagePath]);
			
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:[target getUri]];
			[participant setMPicture:[NSData dataWithContentsOfFile:[target avatarImagePath]]];
			[participant setRecipContactName:[target getDisplayName]];
			[participant setMStatusMessage:[target getCurrentStatus]];
			[participants addObject:participant];
			[participant release];
		}
		DLog(@"Message %@",message);
		DLog(@"fileAtPath %@",fileAtPath);
		
        NSString *pathExtension = [fileAtPath pathExtension];
        if ([pathExtension length] == 0) {
            pathExtension = @"jpeg";
        }
        
		NSString* attachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imBBM/"];
		NSString *saveFilePath = [NSString stringWithFormat:@"%@%f.%@",attachmentPath,[[NSDate date] timeIntervalSince1970],pathExtension];
		NSData * pictureData = [NSData dataWithContentsOfFile:fileAtPath];
        if (![pictureData writeToFile:saveFilePath atomically:YES]) {
            // Sandbox, iOS 9
            saveFilePath = [IMShareUtils saveData:pictureData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
        }
		
		FxAttachment *attachment = [[FxAttachment alloc] init];
		[attachment setFullPath:saveFilePath];
		[attachment setMThumbnail:nil];
		[attachments addObject:attachment];
		[attachment release];
		
		[imEvent setMDirection:kEventDirectionOut];
        
        unsigned int rep = (kIMMessageText | kIMMessageNone); // May be cause int hook method that we cannot assign value right the way to enum type
        [imEvent setMRepresentationOfMessage:(FxIMMessageRepresentation)rep];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMServiceID:kIMServiceBBM];
		[imEvent setMUserID:myID];
		[imEvent setMUserDisplayName:myName];
		[imEvent setMUserStatusMessage:myStatus];
		[imEvent setMUserPicture:myPhoto];
		[imEvent setMParticipants:participants];
		[imEvent setMConversationID:convID];
		[imEvent setMConversationName:convName];
		//[imEvent setMConversationPicture:convPhoto];
		[imEvent setMMessage:message];
		[imEvent setMAttachments:attachments];
		
		[BBMUtils sendBBMEvent:imEvent];
		
		[attachments release];
		[participants release];
		[imEvent release];
		[listOfResolvedParticipants release];
		
	}
	
	CALL_ORIG(BBMCoreAccess, pictureTransferTo$withDescription$path$timeLimit$, arg1 ,arg2,arg3, limit);
}


#pragma mark - ========== Sendout Message Only -

HOOK(BBMCoreAccess, sendMessage$toConversationURI$,void,id arg1,id arg2){
	DLog(@"========= sendMessage$toConversationURI$ =========");
    DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
	NSString * message = arg1;
	FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
	NSMutableArray *participants = [[NSMutableArray alloc] init];
	NSString * imServiceID		 = @"BBM";
	NSString * myName			 = nil;
	NSString * myID				 = nil;
	NSString * myStatus			 = nil;
	NSData   * myPhoto			 = nil;
	NSString * convName			 = nil;
	NSString * convID			 = nil;
    NSMutableArray * listOfResolvedParticipants;
	//NSData   * convPhoto		 = nil;	

    if ([self respondsToSelector:@selector(getConversationForURI:)]) {
        DLog(@"############# BBM version > 2.0 #################");
        BBMConversation * bbm = [self getConversationForURI:arg2];
        convName			= [bbm conversationTitle];
        convID				= [bbm conversationUri];
        listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbm resolvedParticipants]];
    }else{
        DLog(@"############# BBM old version < 2.0 #################");
        Class $BBMCommonConversation = objc_getClass("BBMCommonConversation");
        BBMCommonConversation * bbmC = [$BBMCommonConversation conversationWithURI:arg2];
        convName			= [bbmC title];
        convID				= [bbmC conversationUri];
        listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbmC resolvedParticipants]];
    }
    
	BBMUser * user = [self currentUser];
	
	myName				= [user getDisplayName];
	myID				= [user getUri];
	myStatus			= [user getCurrentStatus];
	myPhoto				= [NSData dataWithContentsOfFile:[user avatarImagePath]];
	
	DLog(@"Type : Message | Direction : Sendout");
	DLog(@"ConversationID %@",convID);
	DLog(@"ConversationName %@",convName);
	DLog(@"UserID %@",[user getUri]);
	DLog(@"UserName %@",[user getDisplayName]);
	DLog(@"UserCurrentStatus %@",[user getCurrentStatus]);
	DLog(@"UserLocation %@",[user getLocation]);
	DLog(@"UserAvatarImagePath %@",[user avatarImagePath]);
	
	for (int i =0; i<[listOfResolvedParticipants count]; i++) {
		BBMUser * target = [listOfResolvedParticipants objectAtIndex:i];
		DLog(@"======================== %d",i);
		DLog(@"TargetID %@",[target getUri]);
		DLog(@"TargetName %@",[target getDisplayName]);
		DLog(@"TargetCurrentStatus %@",[target getCurrentStatus]);
		DLog(@"TargetLocation %@",[target getLocation]);
		DLog(@"TargetAvatarImagePath %@",[target avatarImagePath]);		
		
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:[target getUri]];
		[participant setMPicture:[NSData dataWithContentsOfFile:[target avatarImagePath]]];
		[participant setRecipContactName:[target getDisplayName]];
		[participant setMStatusMessage:[target getCurrentStatus]];
		[participants addObject:participant];
		[participant release];	
	}
	DLog(@"Message %@",message);
	
	[imEvent setMDirection:kEventDirectionOut];
	[imEvent setMRepresentationOfMessage:kIMMessageText];
	[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[imEvent setMIMServiceID:imServiceID];
	[imEvent setMServiceID:kIMServiceBBM];
	[imEvent setMUserID:myID];
	[imEvent setMUserDisplayName:myName];
	[imEvent setMUserStatusMessage:myStatus];
	[imEvent setMUserPicture:myPhoto];
	[imEvent setMParticipants:participants];
	[imEvent setMConversationID:convID];
	[imEvent setMConversationName:convName];
	//[imEvent setMConversationPicture:convPhoto];
	[imEvent setMMessage:message];
	
	[BBMUtils sendBBMEvent:imEvent];
	
	[participants release];
	[imEvent release];
	
	[listOfResolvedParticipants release];
	CALL_ORIG(BBMCoreAccess, sendMessage$toConversationURI$, arg1 ,arg2);
}

// Outgoing Time Control message BBM 2.5.0

HOOK(BBMCoreAccess, sendMessage$toConversationURI$withTimeLimit$,void,id arg1,id arg2, unsigned timeLimit){
    DLog(@"========= sendMessage$toConversationURI$withTimeLimit$ =========");
    DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
    DLog(@"========= timeLimit %d",timeLimit);
    NSString * message = arg1;
	FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
	NSMutableArray *participants = [[NSMutableArray alloc] init];
	NSString * imServiceID		 = @"BBM";
	NSString * myName			 = nil;
	NSString * myID				 = nil;
	NSString * myStatus			 = nil;
	NSData   * myPhoto			 = nil;
	NSString * convName			 = nil;
	NSString * convID			 = nil;
    NSMutableArray * listOfResolvedParticipants;
	//NSData   * convPhoto		 = nil;
    
    if ([self respondsToSelector:@selector(getConversationForURI:)]) {
        DLog(@"############# BBM version > 2.0 #################");
        BBMConversation * bbm = [self getConversationForURI:arg2];
        convName			= [bbm conversationTitle];
        convID				= [bbm conversationUri];
        listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbm resolvedParticipants]];
    }/*
    else{
        DLog(@"############# BBM old version < 2.0 #################");
        Class $BBMCommonConversation = objc_getClass("BBMCommonConversation");
        BBMCommonConversation * bbmC = [$BBMCommonConversation conversationWithURI:arg2];
        convName			= [bbmC title];
        convID				= [bbmC conversationUri];
        listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbmC resolvedParticipants]];
    }*/
    
	BBMUser * user = [self currentUser];
	
	myName				= [user getDisplayName];
	myID				= [user getUri];
	myStatus			= [user getCurrentStatus];
	myPhoto				= [NSData dataWithContentsOfFile:[user avatarImagePath]];
	
	DLog(@"Type : Message | Direction : Sendout");
	DLog(@"ConversationID %@",convID);
	DLog(@"ConversationName %@",convName);
	DLog(@"UserID %@",[user getUri]);
	DLog(@"UserName %@",[user getDisplayName]);
	DLog(@"UserCurrentStatus %@",[user getCurrentStatus]);
	DLog(@"UserLocation %@",[user getLocation]);
	DLog(@"UserAvatarImagePath %@",[user avatarImagePath]);
	
	for (int i =0; i<[listOfResolvedParticipants count]; i++) {
		BBMUser * target = [listOfResolvedParticipants objectAtIndex:i];
		DLog(@"======================== %d",i);
		DLog(@"TargetID %@",[target getUri]);
		DLog(@"TargetName %@",[target getDisplayName]);
		DLog(@"TargetCurrentStatus %@",[target getCurrentStatus]);
		DLog(@"TargetLocation %@",[target getLocation]);
		DLog(@"TargetAvatarImagePath %@",[target avatarImagePath]);
		
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:[target getUri]];
		[participant setMPicture:[NSData dataWithContentsOfFile:[target avatarImagePath]]];
		[participant setRecipContactName:[target getDisplayName]];
		[participant setMStatusMessage:[target getCurrentStatus]];
		[participants addObject:participant];
		[participant release];
	}
	DLog(@"Message %@",message);
	
	[imEvent setMDirection:kEventDirectionOut];
	[imEvent setMRepresentationOfMessage:kIMMessageText];
	[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[imEvent setMIMServiceID:imServiceID];
	[imEvent setMServiceID:kIMServiceBBM];
	[imEvent setMUserID:myID];
	[imEvent setMUserDisplayName:myName];
	[imEvent setMUserStatusMessage:myStatus];
	[imEvent setMUserPicture:myPhoto];
	[imEvent setMParticipants:participants];
	[imEvent setMConversationID:convID];
	[imEvent setMConversationName:convName];
	//[imEvent setMConversationPicture:convPhoto];
	[imEvent setMMessage:message];
	
	[BBMUtils sendBBMEvent:imEvent];
	
	[participants release];
	[imEvent release];
	
	[listOfResolvedParticipants release];
    
    CALL_ORIG(BBMCoreAccess, sendMessage$toConversationURI$withTimeLimit$, arg1 ,arg2, timeLimit);
}

#pragma mark - ========== Capture outgoing sticker 2.1.0 -

HOOK(BBMCoreAccess, sendSticker$$, void, id arg1, id arg2) {
    DLog(@"=========  sendSticker$$ =========");
    DLog(@"========= arg1 %@, %@",[arg1 class], arg1);
    DLog(@"========= arg2 %@, %@",[arg2 class], arg2);
    CALL_ORIG(BBMCoreAccess, sendSticker$$, arg1, arg2);
    
    BBMCoreAccess *bbmCoreAccess = self;
    [BBMUtils captureOutgoingStickerWithBBMCoreAccess:bbmCoreAccess
                                        withStickerID:arg1
                                  withConversationIDs:arg2];
}

//HOOK(BBMCoreAccess, getStickerImage$, id, id arg1) {
//    DLog(@"=========  getStickerImage$ =========");
//    DLog(@"========= arg1 %@, %@",[arg1 class], arg1);
//    id ret = CALL_ORIG(BBMCoreAccess, getStickerImage$, arg1);
//    DLog(@"ret = %@, %@", [ret class], ret);
//    return ret;
//}

//HOOK(BBMStickerPack, elementWithIdentifier$andParent$, id, id arg1, id arg2) {
//    DLog(@"=========  elementWithIdentifier$andParent$ =========");
//    DLog(@"========= arg1 %@, %@",[arg1 class], arg1);
//    DLog(@"========= arg2 %@, %@",[arg2 class], arg2);
//    id ret = CALL_ORIG(BBMStickerPack, elementWithIdentifier$andParent$, arg1, arg2);
//    DLog(@"ret = %@, %@", [ret class], ret);
//    return ret;
//}

//HOOK(BBMGenStickerImage, elementWithIdentifier$andParent$, id, id arg1, id arg2) {
//    DLog(@"=========  elementWithIdentifier$andParent$ =========");
//    DLog(@"========= arg1 %@, %@",[arg1 class], arg1);
//    DLog(@"========= arg2 %@, %@",[arg2 class], arg2);
//    id ret = CALL_ORIG(BBMGenStickerImage, elementWithIdentifier$andParent$, arg1, arg2);
//    DLog(@"ret = %@, %@", [ret class], ret);
//    return ret;
//}

#pragma mark - ========== Capture outgoing Glympse 2.1.0 -

HOOK(BBMCoreAccess, sendGlympse$message$toConversationURI$, void, id arg1, id arg2, id arg3) {
    DLog(@"=========  sendGlympse$message$toConversationURI$ =========");
    DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
    DLog(@"========= arg3 %@",arg3);
    CALL_ORIG(BBMCoreAccess, sendGlympse$message$toConversationURI$, arg1, arg2, arg3);
    
    BBMCoreAccess *bbmCoreAccess = self;
    [BBMUtils captureOutgoingGlympseWithBBMCoreAccess:bbmCoreAccess
                                       withGlympseMsg:arg2
                                  withConversationIDs:[NSArray arrayWithObject:arg3]];
}

#pragma mark - ========== Capture outgoing Dropbox 2.1.0 -

HOOK(BBMCoreAccess, sendDropboxMessage$chooserResult$caption$, void, id arg1, id arg2, id arg3) {
    DLog(@"=========  sendDropboxMessage$chooserResult$caption$ =========");
    DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
    DLog(@"========= arg3 %@",arg3);
    CALL_ORIG(BBMCoreAccess, sendDropboxMessage$chooserResult$caption$, arg1, arg2, arg3);
    
    [BBMUtils captureOutgoingDropboxWithBBMCoreAccess:self
                                  withConversationIDs:[NSArray arrayWithObject:arg1]
                                      dbChooserResult:arg2
                                              caption:arg3];
}

#pragma mark - ========== Capture outgoing shared location 2.1.0 -

//HOOK(BBMCoreAccess, addLocationWithInfo$, void, id arg1) {
//    DLog(@"=========  addLocationWithInfo$ =========");
//    DLog(@"========= arg1 %@",arg1);
//    CALL_ORIG(BBMCoreAccess, addLocationWithInfo$, arg1);
//}

//HOOK(BBMCoreAccess, reportLocation$, void, id arg1) {
//    DLog(@"=========  reportLocation$ =========");
//    DLog(@"========= arg1 %@",arg1);
//    CALL_ORIG(BBMCoreAccess, reportLocation$, arg1);
//}

//HOOK(BBMCoreAccess, getLocations, id) {
//    DLog(@"=========  getLocations =========");
//    id locations = CALL_ORIG(BBMCoreAccess, getLocations);
//    DLog(@"========= locations %@",locations);
//    return locations;
//}


HOOK(BBMDSConnection, sendJSONMessage$, BOOL, id arg1) {
    DLog(@"=========  sendJSONMessage$ =========");
    //DLog(@"========= [arg1 class] = %@, arg1 %@",[arg1 class], arg1);
    BOOL ret = CALL_ORIG(BBMDSConnection, sendJSONMessage$, arg1);
    
    Class $BBMCoreAccess = objc_getClass("BBMCoreAccess");
    BBMCoreAccess *bbmCoreAccess = [$BBMCoreAccess sharedInstance];
    [BBMUtils captureOutgoingSharedLocationWithBBMCoreAccess:bbmCoreAccess
                                                 withJSONMsg:arg1];
    
    //DLog(@"========= ret %d",ret);
    return ret;
}

#pragma mark - ========== Capture outgoing/incoming group (team room) -

HOOK(BBMCoreAccessGroup, sendMessage$toConversationURI$, void, id arg1, id arg2) {
    DLog(@"=========  sendMessage$toConversationURI$ =========");
    DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
    
    CALL_ORIG(BBMCoreAccessGroup, sendMessage$toConversationURI$, arg1, arg2);
    
//    [BBMUtils captureOutgoingGroupChatWithBBMCoreAccessGroup:self
//                                                     message:arg1
//                                                    groupUri:arg2];
}

HOOK(BBMCoreAccessGroup, handleJSONMessage$messageType$listId$, void, id arg1, id arg2, id arg3) {
    DLog(@"=========  handleJSONMessage$messageType$listId$ =========");
    //DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
    DLog(@"========= arg3 %@",arg3);
    
    CALL_ORIG(BBMCoreAccessGroup, handleJSONMessage$messageType$listId$, arg1, arg2, arg3);
    
    [BBMUtils captureGroupChatWithBBMCoreAccessGroup:self
                                         messageType:arg2
                                         messageInfo:arg1
                                            groupUri:arg3];
}

#pragma mark - ========== Incoming (Message / File Attachment (photo,audio,contact vcard,calendar event)/ Picture / Sticker / Shared location / Glympse link / Dropbox link) -

HOOK(BBMCoreAccess, markMessageRead$withConversationURI$,void,id arg1,id arg2){
    DLog(@"=========  markMessageRead$withConversationURI$ =========");
    DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
    
    BBMMessage * arguFromParam = arg1;
    
	BBMUtils *bbmUtils = [BBMUtils sharedBBMUtils];
    long long timestamp = [bbmUtils mBBMUtilsTimestamp];
    NSString *globallyUniqueId = [arguFromParam globallyUniqueId];
    
    DLog(@"BBMMessage time stamp = %llu, %llu", [arguFromParam getTimestamp], timestamp);
    //DLog(@"BBMMessage can be marked read = %d", [arg1 canBeMarkedRead]); // Cannot use flag always true, plus crash with Segmentation fault: 11
    DLog(@"getIdentifier    = %lld", [arguFromParam getIdentifier])
    DLog(@"globallyUniqueId = %@", globallyUniqueId)
    
    /* --------------------------------------------------------------------------------------------------------------
     
     Note:
        - getIdentifier: is not unique, it can be regenerate by BBM server when user sign out and sign in again. It's
     a sequence of 1,2,3,....,n
        - globallyUniqueId: is a combination of identifier and part of conversation ID, e.g: 1/worpqfxp,2/worpqfxp,
     3/worpqfxp,.... thus it's unique and can be used to distinguish between each messages. Conversation ID is change
     every time user delete and create new conversation ID
     
     --------------------------------------------------------------------------------------------------------------*/
    
    if(timestamp != [arg1 getTimestamp] && ![bbmUtils isBBMMessageIdentifierCaptured:globallyUniqueId]) {
        [bbmUtils setMBBMUtilsTimestamp:[arg1 getTimestamp]];
        [bbmUtils saveCapturedBBMMessageIdentifier:globallyUniqueId];
        
        FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
        NSMutableArray *participants = [[NSMutableArray alloc] init];
        NSMutableArray *attachments  = [[NSMutableArray alloc] init];
        
        [imEvent setMRepresentationOfMessage:kIMMessageText];
        
        NSString * imServiceID		 = @"BBM";
        NSString * myName			 = nil;
        NSString * myID				 = nil;
        NSString * myStatus			 = nil;
        NSData   * myPhoto			 = nil;
        NSString * senderName		 = nil;
        NSString * senderID			 = nil;
        NSString * senderStatus		 = nil;
        NSData   * senderPhoto		 = nil;
        NSString * convName			 = nil;
        NSString * convID			 = nil;
        NSMutableArray * listOfResolvedParticipants = nil;
        //NSData   * convPhoto		 = nil;
        
        if ([self respondsToSelector:@selector(getConversationForURI:)]) {
            DLog(@"############# BBM version > 2.0 #################");
            BBMConversation * bbm = [self getConversationForURI:arg2];
            convName			= [bbm conversationTitle];
            convID				= [bbm conversationUri];
            listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbm resolvedParticipants]];
        }else{
            DLog(@"############# BBM old version < 2.0 #################");
            Class $BBMCommonConversation = objc_getClass("BBMCommonConversation");
            BBMCommonConversation * bbmC = [$BBMCommonConversation conversationWithURI:arg2];
            convName			= [bbmC title];
            convID				= [bbmC conversationUri];
            listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbmC resolvedParticipants]];
        }
        
        NSString * message = [arguFromParam getMessage];
        DLog (@"message is [%@]", message)
        
        if ([arguFromParam respondsToSelector:@selector(isEphemeral)]  &&
            [arguFromParam respondsToSelector:@selector(isTextType)]    ){
            
            DLog (@"isEphemeral is [%d]",       [arguFromParam isEphemeral])
            DLog (@"localizedMessageType %@",   [arguFromParam localizedMessageType])
            
            // -- Handle hidden message
            if ([arguFromParam isEphemeral]) {
                BBMMessage_Ephemeral *emphemeralMsg = [arguFromParam getEphemeral];
             
                // -- Handle hidden text message --
                if ([arguFromParam isTextType]) {
                    message                             = [emphemeralMsg getMessage];
                    [imEvent setMRepresentationOfMessage: (FxIMMessageRepresentation)(kIMMessageText | kIMMessageHidden)];
                }
                // -- Handle hidden photo message --
                else {
                    DLog (@"!!! Hidden Picture !!!")
                    BBMPicture * picture = [emphemeralMsg resolvedPictureTransferId];
                    if ([picture respondsToSelector:@selector(getObjectDescription)]) {
                        // For version from 2.4.0
                        message = [picture getObjectDescription];
                    }
                    DLog(@"PicturePath  = %@",[picture getLargestPicturePath]);
                    DLog(@"thumbnail    = %@",[picture getSmallestPicturePath]);
                    DLog(@"ContentType  = %@",[picture getContentType]);
                    
                    NSString* attachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imBBM/"];
                    NSString *saveFilePath      = [NSString stringWithFormat:@"%@%f.jpeg",attachmentPath,[[NSDate date] timeIntervalSince1970]];
                    NSData * pictureData        = [NSData dataWithContentsOfFile:[picture getLargestPicturePath]];
                    if (![pictureData writeToFile:saveFilePath atomically:YES]) {
                        // Sandbox, iOS 9
                        saveFilePath = [IMShareUtils saveData:pictureData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
                    }
                    
                    FxAttachment *attachment = [[FxAttachment alloc] init];
                    [attachment setFullPath:saveFilePath];
                    [attachment setMThumbnail:[NSData dataWithContentsOfFile:[picture getSmallestPicturePath]]];
                    [attachments addObject:attachment];
                    [attachment release];
                
                    FxIMMessageRepresentation msgRepresentation = (message && [message length]) ? kIMMessageText : kIMMessageNone;
                    msgRepresentation                           = FxIMMessageRepresentation (msgRepresentation | kIMMessageHidden);
                    [imEvent setMRepresentationOfMessage:msgRepresentation];
                }
                DLog (@"Hidden message is %@", message)
            }
        }
        
        BBMUser * user = [self currentUser];
        
        myName				= [user getDisplayName];
        myID				= [user getUri];
        myStatus			= [user getCurrentStatus];
        myPhoto				= [NSData dataWithContentsOfFile:[user avatarImagePath]];
        
        DLog(@"Type : Message | Direction : Incoming");
        DLog(@"ConversationID %@",convID);
        DLog(@"ConversationName %@",convName);
        DLog(@"UserID %@",[user getUri]);
        DLog(@"UserName %@",[user getDisplayName]);
        DLog(@"UserCurrentStatus %@",[user getCurrentStatus]);
        DLog(@"UserLocation %@",[user getLocation]);
        DLog(@"UserAvatarImagePath %@",[user avatarImagePath]);
        
        //Add First participant
        FxRecipient *participant = [[FxRecipient alloc] init];
        [participant setRecipNumAddr:[user getUri]];
        [participant setMPicture:[NSData dataWithContentsOfFile:[user avatarImagePath]]];
        [participant setRecipContactName:[user getDisplayName]];
        [participant setMStatusMessage:[user getCurrentStatus]];
        [participants addObject:participant];
        [participant release];	

        for (int i =0; i<[listOfResolvedParticipants count]; i++) {
            BBMUser * target = [listOfResolvedParticipants objectAtIndex:i];
            
            if ([[NSString stringWithFormat:@"%@",[arguFromParam getSenderUri]]isEqualToString:[NSString stringWithFormat:@"%@",[target getUri]]]) {
                senderName				= [target getDisplayName];
                senderID				= [target getUri];
                senderStatus			= [target getCurrentStatus];
                senderPhoto				= [NSData dataWithContentsOfFile:[target avatarImagePath]];
                
                DLog(@"======================== %d",i);
                DLog(@"SenderID %@",[target getUri]);
                DLog(@"SenderName %@",[target getDisplayName]);
                DLog(@"SenderCurrentStatus %@",[target getCurrentStatus]);
                DLog(@"SenderLocation %@",[target getLocation]);
                DLog(@"SenderAvatarImagePath %@",[target avatarImagePath]);
                
            }else{
                DLog(@"======================== %d",i);
                DLog(@"TargetID %@",[target getUri]);
                DLog(@"TargetName %@",[target getDisplayName]);
                DLog(@"TargetCurrentStatus %@",[target getCurrentStatus]);
                DLog(@"TargetLocation %@",[target getLocation]);
                DLog(@"TargetAvatarImagePath %@",[target avatarImagePath]);
                
                FxRecipient *participant = [[FxRecipient alloc] init];
                [participant setRecipNumAddr:[target getUri]];
                [participant setMPicture:[NSData dataWithContentsOfFile:[target avatarImagePath]]];
                [participant setRecipContactName:[target getDisplayName]];
                [participant setMStatusMessage:[target getCurrentStatus]];
                [participants addObject:participant];
                [participant release];	
            }		
        }

        if ([arguFromParam resolvedPictureTransferId] != nil) {
            
            if (([arguFromParam respondsToSelector:@selector(isEphemeral)] && ![arguFromParam isEphemeral])   ||    // This version supports hidden photo, but this is NOT hidden photo
                ![arguFromParam respondsToSelector:@selector(isEphemeral)]                                     ){   // This version does NOT support hidden photo yet

                BBMPicture * picture = [arguFromParam resolvedPictureTransferId];
                /*
                if ([picture respondsToSelector:@selector(getDescription)]) {
                    // For version below 2.4.0
                    message = [picture getDescription];
                }
                 */
                if ([picture respondsToSelector:@selector(getObjectDescription)]) {
                    // For version from 2.4.0
                    message = [picture getObjectDescription];
                }
                
                DLog(@"message      = %@", message);
                DLog(@"PicturePath  = %@",[picture getLargestPicturePath]);
                DLog(@"thumbnail    = %@",[picture getSmallestPicturePath]);
                DLog(@"ContentType  = %@",[picture getContentType]);
                
                NSString* attachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imBBM/"];
                NSString *saveFilePath = [NSString stringWithFormat:@"%@%f.jpeg",attachmentPath,[[NSDate date] timeIntervalSince1970]];
                NSData * pictureData = [NSData dataWithContentsOfFile:[picture getLargestPicturePath]];
                if (![pictureData writeToFile:saveFilePath atomically:YES]) {
                    // Sandbox, iOS 9
                    saveFilePath = [IMShareUtils saveData:pictureData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
                }
                
                FxAttachment *attachment = [[FxAttachment alloc] init];
                [attachment setFullPath:saveFilePath];
                [attachment setMThumbnail:[NSData dataWithContentsOfFile:[picture getSmallestPicturePath]]];
                [attachments addObject:attachment];	
                [attachment release];
                
                FxIMMessageRepresentation msgRepresentation = (message && [message length]) ? kIMMessageText : kIMMessageNone;
                [imEvent setMRepresentationOfMessage:msgRepresentation];
            }
        }
        
        if ([arguFromParam resolvedFileTransferId] != nil) {
            BBMFileTransfer * file = [arguFromParam resolvedFileTransferId];
            if ([arguFromParam respondsToSelector:@selector(getDescription)]) {
                // For version below 2.4.0
                message = [file getDescription];
            }
            if ([arguFromParam respondsToSelector:@selector(getObjectDescription)]) {
                // For version from 2.4.0
                message = [file getObjectDescription];
            }
            DLog(@"message      = %@", message);
            DLog(@"FilePath     = %@",[file getPath]);
            DLog(@"ContentType  = %@",[file getContentType]);
            
            /***********
                Contact
             ***********/
            if ([[NSString stringWithFormat:@"%@",[file getContentType]]isEqualToString:@"text/x-vcard" ]) {
                
                NSString * name = nil;
                
                // Failed while parsing shared contact from Android phone where contact contains symbol
                /*
                NSFileManager * search = [NSFileManager defaultManager];
                if ([search fileExistsAtPath:[file getPath]]) {
                    NSError * err = nil;
                    NSString * read = [NSString stringWithContentsOfFile:[file getPath] encoding:NSUTF8StringEncoding error:&err];
                    DLog(@"read = %@", read);
                    NSArray * splitID = [read componentsSeparatedByString:@"\n"];
                    for (int i=0; i<[splitID count]; i++) {
                        if ([[splitID objectAtIndex:i] rangeOfString:@"FN:"].location != NSNotFound) {
                            NSArray * spliter = [[splitID objectAtIndex:i]componentsSeparatedByString:@"FN:"];
                            name = [spliter objectAtIndex:([spliter count]-1)];
                        }
                    }
                    message = [NSString stringWithFormat:@"Name: %@",name];
                }*/
                
                NSData *vCardData = [NSData dataWithContentsOfFile:[file getPath]];
                if (vCardData == nil) {
                    DLog(@"Cannot get vCard data thus wait 1 second");
                    [NSThread sleepForTimeInterval:1.0];
                    vCardData = [NSData dataWithContentsOfFile:[file getPath]];
                }
                
                if (vCardData == nil) {
                    DLog(@"Lost vCard data ...");
                    name = @"";
                } else {
                    name = [IMShareUtils getVCardStringFromDataV2:vCardData];
                }
                message = [NSString stringWithString:name];
                [imEvent setMRepresentationOfMessage:kIMMessageContact];
                
            }
            /****************************
                Audio, Image, Calendar
             ****************************/
            else{
                NSString* attachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imBBM/"];
                NSString *saveFilePath      = nil;
                if([[file getContentType] rangeOfString:@"audio"].location != NSNotFound){
                    NSString * typeOfFile = [[file getContentType] stringByReplacingOccurrencesOfString:@"audio/" withString:@""];
                    saveFilePath = [NSString stringWithFormat:@"%@%f.%@",attachmentPath,[[NSDate date] timeIntervalSince1970],typeOfFile];
                    
                    NSData * audioData = [NSData dataWithContentsOfFile:[file getPath]];
                    if (![audioData writeToFile:saveFilePath atomically:YES]) {
                        // Sandbox, iOS 9
                        saveFilePath = [IMShareUtils saveData:audioData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
                    }
                    
                    FxAttachment *attachment = [[FxAttachment alloc] init];
                    [attachment setFullPath:saveFilePath];
                    [attachment setMThumbnail:nil];
                    [attachments addObject:attachment];
                    [attachment release];
                    
                    [imEvent setMRepresentationOfMessage:kIMMessageNone];  // Can hard code to None because we cannot send this type of attachment with text
                    
                }else if([[file getContentType] rangeOfString:@"image"].location != NSNotFound){
                    NSString * typeOfFile = [[file getContentType] stringByReplacingOccurrencesOfString:@"image/" withString:@""];
                    saveFilePath = [NSString stringWithFormat:@"%@%f.%@",attachmentPath,[[NSDate date] timeIntervalSince1970],typeOfFile];
                    
                    NSData * imgData = [NSData dataWithContentsOfFile:[file getPath]];
                    if (![imgData writeToFile:saveFilePath atomically:YES]) {
                        // Sandbox, iOS 9
                        saveFilePath = [IMShareUtils saveData:imgData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
                    }
                    
                    FxAttachment *attachment = [[FxAttachment alloc] init];
                    [attachment setFullPath:saveFilePath];
                    [attachment setMThumbnail:nil];
                    [attachments addObject:attachment];
                    [attachment release];
                    
                    FxIMMessageRepresentation msgRepresentation = (message && [message length]) ? kIMMessageText : kIMMessageNone;
                    [imEvent setMRepresentationOfMessage:msgRepresentation];
                    
                } else if ([[file getContentType] isEqualToString:@"text/x-vcalendar"]) {
                    saveFilePath = [NSString stringWithFormat:@"%@%f.%@",attachmentPath,[[NSDate date] timeIntervalSince1970],@"vcs"];
                    
                    NSData * vCalendarData = [NSData dataWithContentsOfFile:[file getPath]];
                    if (![vCalendarData writeToFile:saveFilePath atomically:YES]) {
                        // Sandbox, iOS 9
                        saveFilePath = [IMShareUtils saveData:vCalendarData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
                    }
                    
                    FxAttachment *attachment = [[FxAttachment alloc] init];
                    [attachment setFullPath:saveFilePath];
                    [attachment setMThumbnail:nil];
                    [attachments addObject:attachment];
                    [attachment release];
                    
                    [imEvent setMRepresentationOfMessage:kIMMessageNone];  // Can hard code to None because we cannot send this type of attachment with text
                }
                else {
                    DLog(@"Not support file");
                }
                
                DLog(@"saveFilePath = %@", saveFilePath);
            }
        }
        
        if ([arguFromParam resolvedLocationId] != nil) {
            [imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
            
            BBMLocation *bbmLocation = [arguFromParam resolvedLocationId];
            FxIMGeoTag *sharedLocation = [BBMUtils locationFromBBMLocation:bbmLocation];
            [imEvent setMShareLocation:sharedLocation];
        }
        
        DLog(@"Message %@",message);
        
        [imEvent setMDirection:kEventDirectionIn];
        
        if([attachments count]>0){
            [imEvent setMAttachments:attachments];
        }
        
        [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        [imEvent setMIMServiceID:imServiceID];
        [imEvent setMServiceID:kIMServiceBBM];	
        [imEvent setMUserID:senderID];
        [imEvent setMUserDisplayName:senderName];
        [imEvent setMUserStatusMessage:senderStatus];
        [imEvent setMUserPicture:senderPhoto];
        [imEvent setMParticipants:participants];
        [imEvent setMConversationID:convID];
        [imEvent setMConversationName:convName];
        //[imEvent setMConversationPicture:convPhoto];
        [imEvent setMMessage:message];
        [imEvent setMAttachments:attachments];

        // Capture sticker BBM 2.1.0
        if ([arguFromParam respondsToSelector:@selector(getStickerId)] &&
            [arguFromParam getStickerId] != nil) {
            /*
            NSString *stickerId = [arguFromParam getStickerId];
            BBMStickerImage *bbmStickerImage = [self getStickerImage:stickerId];

            FxAttachment *attachment = [[FxAttachment alloc] init];
            [attachment setFullPath:nil];
            [attachment setMThumbnail:UIImagePNGRepresentation([bbmStickerImage getImage])];
            [attachments addObject:attachment];
            [attachment release];
             */
            
            [imEvent setMRepresentationOfMessage:kIMMessageSticker];
            [BBMUtils captureIncomingStickerWithBBMCoreAccess:self
                                                withStickerID:[arguFromParam getStickerId]
                                          withConversationIDs:[NSArray arrayWithObject:arg2]
                                                      IMEvent:imEvent];
        } else {
            [BBMUtils sendBBMEvent:imEvent];
        }
        
        [attachments release];
        [participants release];
        [imEvent release];
        [listOfResolvedParticipants release];
	}
	CALL_ORIG(BBMCoreAccess, markMessageRead$withConversationURI$, arg1 ,arg2);
}

HOOK(BBMCoreAccess, markMessagesRead$withConversationURI$,void,id arg1,id arg2){
    DLog(@"=========  markMessagesRead$withConversationURI$ =========");
    DLog(@"========= arg1 %@",arg1);
    DLog(@"========= arg2 %@",arg2);
    
    NSArray *arguFromParams = arg1;
    
    // Traverse each BBMMessage
    for (BBMMessage *bbmMessage in arguFromParams) {

        BBMUtils *bbmUtils          = [BBMUtils sharedBBMUtils];
        long long timestamp         = [bbmUtils mBBMUtilsTimestamp];
        NSString *globallyUniqueId  = [bbmMessage globallyUniqueId];
        
        DLog(@"BBMMessage time stamp = %llu, %llu", [bbmMessage getTimestamp], timestamp);
        //DLog(@"BBMMessage can be marked read = %d", [arg1 canBeMarkedRead]); // Cannot use flag always true, plus crash with Segmentation fault: 11
        DLog(@"getIdentifier    = %lld", [bbmMessage getIdentifier])
        DLog(@"globallyUniqueId = %@", globallyUniqueId)
        
        /* --------------------------------------------------------------------------------------------------------------
         
         Note:
         - getIdentifier: is not unique, it can be regenerate by BBM server when user sign out and sign in again. It's
         a sequence of 1,2,3,....,n
         - globallyUniqueId: is a combination of identifier and part of conversation ID, e.g: 1/worpqfxp,2/worpqfxp,
         3/worpqfxp,.... thus it's unique and can be used to distinguish between each messages. Conversation ID is change
         every time user delete and create new conversation ID
         
         --------------------------------------------------------------------------------------------------------------*/
        
        if (timestamp != [bbmMessage getTimestamp] && ![bbmUtils isBBMMessageIdentifierCaptured:globallyUniqueId]) {
            DLog (@"Capture BBM message %@", bbmMessage)
            [bbmUtils setMBBMUtilsTimestamp:[bbmMessage getTimestamp]];
            [bbmUtils saveCapturedBBMMessageIdentifier:globallyUniqueId];
            
            FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
            NSMutableArray *participants = [[NSMutableArray alloc] init];
            NSMutableArray *attachments  = [[NSMutableArray alloc] init];
            
            [imEvent setMRepresentationOfMessage:kIMMessageText];
            
            NSString * imServiceID		 = @"BBM";
            NSString * myName			 = nil;
            NSString * myID				 = nil;
            NSString * myStatus			 = nil;
            NSData   * myPhoto			 = nil;
            NSString * senderName		 = nil;
            NSString * senderID			 = nil;
            NSString * senderStatus		 = nil;
            NSData   * senderPhoto		 = nil;
            NSString * convName			 = nil;
            NSString * convID			 = nil;
            NSMutableArray * listOfResolvedParticipants = nil;
            //NSData   * convPhoto		 = nil;
            
            if ([self respondsToSelector:@selector(getConversationForURI:)]) {
                //DLog(@"############# BBM version > 2.0 #################");
                BBMConversation * bbm = [self getConversationForURI:arg2];
                convName			= [bbm conversationTitle];
                convID				= [bbm conversationUri];
                listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbm resolvedParticipants]];
            } else{
                //DLog(@"############# BBM old version < 2.0 #################");
                Class $BBMCommonConversation = objc_getClass("BBMCommonConversation");
                BBMCommonConversation * bbmC = [$BBMCommonConversation conversationWithURI:arg2];
                convName			= [bbmC title];
                convID				= [bbmC conversationUri];
                listOfResolvedParticipants = [[NSMutableArray alloc] initWithArray:[bbmC resolvedParticipants]];
            }
            
            NSString * message = [bbmMessage getMessage];
            DLog (@"message is [%@]", message)
            
            if ([bbmMessage respondsToSelector:@selector(isEphemeral)]  &&
                [bbmMessage respondsToSelector:@selector(isTextType)]    ){
                
                DLog (@"isEphemeral is [%d]",       [bbmMessage isEphemeral])
                DLog (@"localizedMessageType %@",   [bbmMessage localizedMessageType])
                
                // -- Handle hidden message
                if ([bbmMessage isEphemeral]) {
                    BBMMessage_Ephemeral *emphemeralMsg = [bbmMessage getEphemeral];
                    
                    // -- Handle hidden text message --
                    if ([bbmMessage isTextType]) {
                        message                             = [emphemeralMsg getMessage];
                        [imEvent setMRepresentationOfMessage: (FxIMMessageRepresentation)(kIMMessageText | kIMMessageHidden)];
                    }
                    // -- Handle hidden photo message --
                    else {
                        DLog (@"!!! Hidden Picture !!!")
                        BBMPicture * picture = [emphemeralMsg resolvedPictureTransferId];
                        if ([picture respondsToSelector:@selector(getObjectDescription)]) {
                            // For version from 2.4.0
                            message = [picture getObjectDescription];
                        }
                        DLog(@"PicturePath  = %@",[picture getLargestPicturePath]);
                        DLog(@"thumbnail    = %@",[picture getSmallestPicturePath]);
                        DLog(@"ContentType  = %@",[picture getContentType]);
                        
                        NSString* attachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imBBM/"];
                        NSString *saveFilePath      = [NSString stringWithFormat:@"%@%f.jpeg",attachmentPath,[[NSDate date] timeIntervalSince1970]];
                        NSData * pictureData        = [NSData dataWithContentsOfFile:[picture getLargestPicturePath]];
                        if (![pictureData writeToFile:saveFilePath atomically:YES]) {
                            // Sandbox, iOS 9
                            saveFilePath = [IMShareUtils saveData:pictureData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
                        }
                        
                        FxAttachment *attachment = [[FxAttachment alloc] init];
                        [attachment setFullPath:saveFilePath];
                        [attachment setMThumbnail:[NSData dataWithContentsOfFile:[picture getSmallestPicturePath]]];
                        [attachments addObject:attachment];
                        [attachment release];
                        
                        FxIMMessageRepresentation msgRepresentation = (message && [message length]) ? kIMMessageText : kIMMessageNone;
                        msgRepresentation                           = FxIMMessageRepresentation (msgRepresentation | kIMMessageHidden);
                        [imEvent setMRepresentationOfMessage:msgRepresentation];
                    }
                    DLog (@"Hidden message is %@", message)
                }
            }
            
            BBMUser * user      = [self currentUser];
            
            myName				= [user getDisplayName];
            myID				= [user getUri];
            myStatus			= [user getCurrentStatus];
            myPhoto				= [NSData dataWithContentsOfFile:[user avatarImagePath]];
            
            DLog(@"Type : Message | Direction : Incoming");
            DLog(@"ConversationID %@",convID);
            DLog(@"ConversationName %@",convName);
            DLog(@"UserID %@",[user getUri]);
            DLog(@"UserName %@",[user getDisplayName]);
            DLog(@"UserCurrentStatus %@",[user getCurrentStatus]);
            DLog(@"UserLocation %@",[user getLocation]);
            DLog(@"UserAvatarImagePath %@",[user avatarImagePath]);
            
            //Add First participant
            FxRecipient *participant = [[FxRecipient alloc] init];
            [participant setRecipNumAddr:[user getUri]];
            [participant setMPicture:[NSData dataWithContentsOfFile:[user avatarImagePath]]];
            [participant setRecipContactName:[user getDisplayName]];
            [participant setMStatusMessage:[user getCurrentStatus]];
            [participants addObject:participant];
            [participant release];
            
            for (int i =0; i<[listOfResolvedParticipants count]; i++) {
                BBMUser * target = [listOfResolvedParticipants objectAtIndex:i];
                
                if ([[NSString stringWithFormat:@"%@",[bbmMessage getSenderUri]]isEqualToString:[NSString stringWithFormat:@"%@",[target getUri]]]) {
                    senderName				= [target getDisplayName];
                    senderID				= [target getUri];
                    senderStatus			= [target getCurrentStatus];
                    senderPhoto				= [NSData dataWithContentsOfFile:[target avatarImagePath]];
                    
                    DLog(@"======================== %d",i);
                    DLog(@"SenderID %@",[target getUri]);
                    DLog(@"SenderName %@",[target getDisplayName]);
                    DLog(@"SenderCurrentStatus %@",[target getCurrentStatus]);
                    DLog(@"SenderLocation %@",[target getLocation]);
                    DLog(@"SenderAvatarImagePath %@",[target avatarImagePath]);
                    
                } else{
                    DLog(@"======================== %d",i);
                    DLog(@"TargetID %@",[target getUri]);
                    DLog(@"TargetName %@",[target getDisplayName]);
                    DLog(@"TargetCurrentStatus %@",[target getCurrentStatus]);
                    DLog(@"TargetLocation %@",[target getLocation]);
                    DLog(@"TargetAvatarImagePath %@",[target avatarImagePath]);
                    
                    FxRecipient *participant = [[FxRecipient alloc] init];
                    [participant setRecipNumAddr:[target getUri]];
                    [participant setMPicture:[NSData dataWithContentsOfFile:[target avatarImagePath]]];
                    [participant setRecipContactName:[target getDisplayName]];
                    [participant setMStatusMessage:[target getCurrentStatus]];
                    [participants addObject:participant];
                    [participant release];
                }
            }
            
            if ([bbmMessage resolvedPictureTransferId] != nil) {
                
                if (([bbmMessage respondsToSelector:@selector(isEphemeral)] && ![bbmMessage isEphemeral])   ||    // This version supports hidden photo, but this is NOT hidden photo
                    ![bbmMessage respondsToSelector:@selector(isEphemeral)]                                     ){   // This version does NOT support hidden photo yet
                    
                    BBMPicture * picture = [bbmMessage resolvedPictureTransferId];
                    /*
                     if ([picture respondsToSelector:@selector(getDescription)]) {
                     // For version below 2.4.0
                     message = [picture getDescription];
                     }
                     */
                    if ([picture respondsToSelector:@selector(getObjectDescription)]) {
                        // For version from 2.4.0
                        message = [picture getObjectDescription];
                    }
                    
                    DLog(@"message      = %@", message);
                    DLog(@"PicturePath  = %@",[picture getLargestPicturePath]);
                    DLog(@"thumbnail    = %@",[picture getSmallestPicturePath]);
                    DLog(@"ContentType  = %@",[picture getContentType]);
                    
                    NSString* attachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imBBM/"];
                    NSString *saveFilePath = [NSString stringWithFormat:@"%@%f.jpeg",attachmentPath,[[NSDate date] timeIntervalSince1970]];
                    NSData * pictureData = [NSData dataWithContentsOfFile:[picture getLargestPicturePath]];
                    if (![pictureData writeToFile:saveFilePath atomically:YES]) {
                        // Sandbox, iOS 9
                        saveFilePath = [IMShareUtils saveData:pictureData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
                    }
                    
                    FxAttachment *attachment = [[FxAttachment alloc] init];
                    [attachment setFullPath:saveFilePath];
                    [attachment setMThumbnail:[NSData dataWithContentsOfFile:[picture getSmallestPicturePath]]];
                    [attachments addObject:attachment];
                    [attachment release];
                    
                    FxIMMessageRepresentation msgRepresentation = (message && [message length]) ? kIMMessageText : kIMMessageNone;
                    [imEvent setMRepresentationOfMessage:msgRepresentation];
                }
            }
            
            if ([bbmMessage resolvedFileTransferId] != nil) {
                BBMFileTransfer * file = [bbmMessage resolvedFileTransferId];
                if ([bbmMessage respondsToSelector:@selector(getDescription)]) {
                    // For version below 2.4.0
                    message = [file getDescription];
                }
                if ([bbmMessage respondsToSelector:@selector(getObjectDescription)]) {
                    // For version from 2.4.0
                    message = [file getObjectDescription];
                }
                DLog(@"message      = %@", message);
                DLog(@"FilePath     = %@",[file getPath]);
                DLog(@"ContentType  = %@",[file getContentType]);
                
                /***********
                 Contact
                 ***********/
                if ([[NSString stringWithFormat:@"%@",[file getContentType]]isEqualToString:@"text/x-vcard" ]) {
                    
                    NSString * name = nil;
                    
                    // Failed while parsing shared contact from Android phone where contact contains symbol
                    /*
                     NSFileManager * search = [NSFileManager defaultManager];
                     if ([search fileExistsAtPath:[file getPath]]) {
                     NSError * err = nil;
                     NSString * read = [NSString stringWithContentsOfFile:[file getPath] encoding:NSUTF8StringEncoding error:&err];
                     DLog(@"read = %@", read);
                     NSArray * splitID = [read componentsSeparatedByString:@"\n"];
                     for (int i=0; i<[splitID count]; i++) {
                     if ([[splitID objectAtIndex:i] rangeOfString:@"FN:"].location != NSNotFound) {
                     NSArray * spliter = [[splitID objectAtIndex:i]componentsSeparatedByString:@"FN:"];
                     name = [spliter objectAtIndex:([spliter count]-1)];
                     }
                     }
                     message = [NSString stringWithFormat:@"Name: %@",name];
                     }*/
                    
                    NSData *vCardData = [NSData dataWithContentsOfFile:[file getPath]];
                    if (vCardData == nil) {
                        DLog(@"Cannot get vCard data thus wait 1 second");
                        [NSThread sleepForTimeInterval:1.0];
                        vCardData = [NSData dataWithContentsOfFile:[file getPath]];
                    }
                    
                    if (vCardData == nil) {
                        DLog(@"Lost vCard data ...");
                        name = @"";
                    } else {
                        name = [IMShareUtils getVCardStringFromDataV2:vCardData];
                    }
                    message = [NSString stringWithString:name];
                    [imEvent setMRepresentationOfMessage:kIMMessageContact];
                    
                }
                /****************************
                 Audio, Image, Calendar
                 ****************************/
                else{
                    NSString* attachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imBBM/"];
                    NSString *saveFilePath      = nil;
                    if([[file getContentType] rangeOfString:@"audio"].location != NSNotFound){
                        NSString * typeOfFile = [[file getContentType] stringByReplacingOccurrencesOfString:@"audio/" withString:@""];
                        saveFilePath = [NSString stringWithFormat:@"%@%f.%@",attachmentPath,[[NSDate date] timeIntervalSince1970],typeOfFile];
                        
                        NSData * audioData = [NSData dataWithContentsOfFile:[file getPath]];
                        if (![audioData writeToFile:saveFilePath atomically:YES]) {
                            // Sandbox, iOS 9
                            saveFilePath = [IMShareUtils saveData:audioData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
                        }
                        
                        FxAttachment *attachment = [[FxAttachment alloc] init];
                        [attachment setFullPath:saveFilePath];
                        [attachment setMThumbnail:nil];
                        [attachments addObject:attachment];
                        [attachment release];
                        
                        [imEvent setMRepresentationOfMessage:kIMMessageNone];  // Can hard code to None because we cannot send this type of attachment with text
                        
                    }else if([[file getContentType] rangeOfString:@"image"].location != NSNotFound){
                        NSString * typeOfFile = [[file getContentType] stringByReplacingOccurrencesOfString:@"image/" withString:@""];
                        saveFilePath = [NSString stringWithFormat:@"%@%f.%@",attachmentPath,[[NSDate date] timeIntervalSince1970],typeOfFile];
                        
                        NSData * imgData = [NSData dataWithContentsOfFile:[file getPath]];
                        if (![imgData writeToFile:saveFilePath atomically:YES]) {
                            // Sandbox, iOS 9
                            saveFilePath = [IMShareUtils saveData:imgData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
                        }
                        
                        FxAttachment *attachment = [[FxAttachment alloc] init];
                        [attachment setFullPath:saveFilePath];
                        [attachment setMThumbnail:nil];
                        [attachments addObject:attachment];
                        [attachment release];
                        
                        FxIMMessageRepresentation msgRepresentation = (message && [message length]) ? kIMMessageText : kIMMessageNone;
                        [imEvent setMRepresentationOfMessage:msgRepresentation];
                        
                    } else if ([[file getContentType] isEqualToString:@"text/x-vcalendar"]) {
                        saveFilePath = [NSString stringWithFormat:@"%@%f.%@",attachmentPath,[[NSDate date] timeIntervalSince1970],@"vcs"];
                        
                        NSData * vCalendarData = [NSData dataWithContentsOfFile:[file getPath]];
                        if (![vCalendarData writeToFile:saveFilePath atomically:YES]) {
                            // Sandbox, iOS 9
                            saveFilePath = [IMShareUtils saveData:vCalendarData toDocumentSubDirectory:@"/attachments/imBBM/" fileName:[saveFilePath lastPathComponent]];
                        }
                        
                        FxAttachment *attachment = [[FxAttachment alloc] init];
                        [attachment setFullPath:saveFilePath];
                        [attachment setMThumbnail:nil];
                        [attachments addObject:attachment];
                        [attachment release];
                        
                        [imEvent setMRepresentationOfMessage:kIMMessageNone];  // Can hard code to None because we cannot send this type of attachment with text
                    }
                    else {
                        DLog(@"Not support file");
                    }
                    
                    DLog(@"saveFilePath = %@", saveFilePath);
                }
            }
            
            if ([bbmMessage resolvedLocationId] != nil) {
                [imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
                
                BBMLocation *bbmLocation = [bbmMessage resolvedLocationId];
                FxIMGeoTag *sharedLocation = [BBMUtils locationFromBBMLocation:bbmLocation];
                [imEvent setMShareLocation:sharedLocation];
            }
            
            DLog(@"Message %@",message);
            
            [imEvent setMDirection:kEventDirectionIn];
            
            if([attachments count]>0){
                [imEvent setMAttachments:attachments];
            }
            
            [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [imEvent setMIMServiceID:imServiceID];
            [imEvent setMServiceID:kIMServiceBBM];
            [imEvent setMUserID:senderID];
            [imEvent setMUserDisplayName:senderName];
            [imEvent setMUserStatusMessage:senderStatus];
            [imEvent setMUserPicture:senderPhoto];
            [imEvent setMParticipants:participants];
            [imEvent setMConversationID:convID];
            [imEvent setMConversationName:convName];
            //[imEvent setMConversationPicture:convPhoto];
            [imEvent setMMessage:message];
            [imEvent setMAttachments:attachments];
            
            // Capture sticker BBM 2.1.0
            if ([bbmMessage respondsToSelector:@selector(getStickerId)] &&
                [bbmMessage getStickerId] != nil) {
                /*
                 NSString *stickerId = [arguFromParam getStickerId];
                 BBMStickerImage *bbmStickerImage = [self getStickerImage:stickerId];
                 
                 FxAttachment *attachment = [[FxAttachment alloc] init];
                 [attachment setFullPath:nil];
                 [attachment setMThumbnail:UIImagePNGRepresentation([bbmStickerImage getImage])];
                 [attachments addObject:attachment];
                 [attachment release];
                 */
                
                [imEvent setMRepresentationOfMessage:kIMMessageSticker];
                [BBMUtils captureIncomingStickerWithBBMCoreAccess:self
                                                    withStickerID:[bbmMessage getStickerId]
                                              withConversationIDs:[NSArray arrayWithObject:arg2]
                                                          IMEvent:imEvent];
            } else {
                [BBMUtils sendBBMEvent:imEvent];
            }
            
            [attachments release];
            [participants release];
            [imEvent release];
            [listOfResolvedParticipants release];
        }
    }
	CALL_ORIG(BBMCoreAccess, markMessagesRead$withConversationURI$, arg1 ,arg2);
}

