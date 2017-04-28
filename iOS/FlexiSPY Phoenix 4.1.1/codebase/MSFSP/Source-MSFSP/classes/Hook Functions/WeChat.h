//
//  WeChat.h
//  MSFSP
//
//  Created by Ophat Phuetkasickonphasutha on 6/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "MSFSP.h"
#import "WeChatUtils.h"
#import "IMShareUtils.h"

#import "CMessageWrap.h"
#import "CMessageMgr.h"
#import "CContactMgr.h"
#import "CContact.h"
#import "CMessageDB.h"
#import "CEmoticonMgr.h"
#import "OpenDownloadMgr.h"
#import "OpenInfo.h"
#import "IMShareUtils.h"
#import "VOIPMgr.h"

#import "CDownloadVideoInfo.h"
#import "CDownloadVideoMgr.h"
#import "CMessageMgr+5-2-0-19.h"
#import "CMessageWrap+5-2-0-19.h"
#import "CMessageWrap+5-3-0-16.h"
#import "CMessageWrap+5-4-0-16.h"

#import "MMAsset.h"

#import "AMRAudioRecorder.h"
#import "WeChatAudioUtils.h"


void logCMessageWrap(CMessageWrap *arg2);

//#import "AudioSender.h"
//#import "AudioReceiver.h"

//HOOK(AudioSender, init, id ) {
//	id cAudioSender = CALL_ORIG(AudioSender,init);
//	DLog (@"-------------------------------AudioSender init$ -----------------------------------");
//	DLog (@"cAudioSender = %@", cAudioSender);	
//	
//	WeChatUtils * weChatUtils = [WeChatUtils sharedWeChatUtils];
//	[weChatUtils setMAudioSender:cAudioSender];
//	return cAudioSender;
//}
//
//HOOK(AudioReceiver, init, id ) {
//	id cAudioReceiver = CALL_ORIG(AudioReceiver,init);
//	DLog (@"-------------------------------AudioReceiver init$ -----------------------------------");
//	DLog (@"cAudioReceiver = %@", cAudioReceiver);	
//	
//	WeChatUtils * weChatUtils = [WeChatUtils sharedWeChatUtils];
//	[weChatUtils setMAudioReceiver:cAudioReceiver];
//	return cAudioReceiver;
//}

#pragma mark -
#pragma mark CContactMgr Capture ContactInfo  
#pragma mark -

HOOK(CContactMgr, init, id ) {
	id cContactMgr = CALL_ORIG(CContactMgr,init);
	DLog (@"-------------------------------CContactMgr init$ -----------------------------------");
	DLog (@"cContactMgr = %@", cContactMgr);	
	
	WeChatUtils * weChatUtils = [WeChatUtils sharedWeChatUtils];
	[weChatUtils setMCContactMgr:cContactMgr];
	
	return cContactMgr;
}

#pragma mark -
#pragma mark CDownloadVideoMgr (NOT USED)
#pragma mark -

HOOK(CDownloadVideoMgr, StartDownload$MsgWrap$, void, id arg1, id arg2) {
    DLog (@"-------------------------------CDownloadVideoMgr StartDownload$MsgWrap$ -----------------------------------");
	DLog (@"arg1 = %@, arg2 = %@", arg1, arg2);
    CALL_ORIG(CDownloadVideoMgr, StartDownload$MsgWrap$, arg1, arg2);
}

#pragma mark -
#pragma mark OpenDownloadMgr Capture FileTransfer  
#pragma mark -

HOOK(OpenDownloadMgr,Pop, void ) {
	CALL_ORIG(OpenDownloadMgr,Pop);
	DLog (@"-------------------------------OpenDownloadMgr pop -----------------------------------");
	
	OpenInfo * info = [self m_oCurDownloadInfo];
	CMessageWrap * cMessageWrap = [info m_wrapMsg];
	
	DLog (@"+++++++++++++++++++++ CMessageWrap ++++++++++++++++++++++");	
	DLog (@"m_nsImgHDUrl = %@", [cMessageWrap m_nsImgHDUrl]);	
	DLog (@"m_nsImgMidUrl = %@", [cMessageWrap m_nsImgMidUrl]);	
	DLog (@"m_nsImgAesKey = %@", [cMessageWrap m_nsImgAesKey]);
	DLog (@"m_uiDes = %d", [cMessageWrap m_uiDes]);	
	DLog (@"m_nsMsgSource = %@", [cMessageWrap m_nsMsgSource]);
	DLog (@"m_arrCustomWrap = %@", [cMessageWrap m_arrCustomWrap]);
	DLog (@"m_arrReaderWaps = %@", [cMessageWrap m_arrReaderWaps]);
	DLog (@"m_oQAMsg = %@", [cMessageWrap m_oQAMsg]);
	DLog (@"m_oPushMailWrap = %@", [cMessageWrap m_oPushMailWrap]);
	DLog (@"m_nsBtnList = %@", [cMessageWrap m_nsBtnList]);
	DLog (@"m_uiOriginMsgSvrId = %d", [cMessageWrap m_uiOriginMsgSvrId]);
	DLog (@"m_uiOriginFormat = %d",[cMessageWrap m_uiOriginFormat]);
	DLog (@"m_uiRemindFormat = %d",[cMessageWrap m_uiRemindFormat]);
	DLog (@"m_uiRemindAttachTotalLen = %d",[cMessageWrap m_uiRemindAttachTotalLen]);
	DLog (@"m_nsRemindAttachId = %@",[cMessageWrap m_nsRemindAttachId]);
	DLog (@"m_uiRemindId = %d",[cMessageWrap m_uiRemindId]);
	DLog (@"m_uiRemindTime = %d",[cMessageWrap m_uiRemindTime]);
	DLog (@"m_nsThumbUrl = %@",[cMessageWrap m_nsThumbUrl]);
	DLog (@"m_nsCommentUrl = %@",[cMessageWrap m_nsCommentUrl]);
	DLog (@"m_nsSourceDisplayname = %@",[cMessageWrap m_nsSourceDisplayname]);
	DLog (@"m_nsSourceUsername = %@",[cMessageWrap m_nsSourceUsername]);
	DLog (@"m_oShakeResult = %@",[cMessageWrap m_oShakeResult]);
	DLog (@"m_nsPushContent = %@",[cMessageWrap m_nsPushContent]);
	DLog (@"m_oImageInfo = %@",[cMessageWrap m_oImageInfo]);
	DLog (@"m_nsPattern = %@",[cMessageWrap m_nsPattern]);
	DLog (@"m_i64VoipKey = %lld",[cMessageWrap m_i64VoipKey]);
	DLog (@"m_iVoipRoomid = %d",[cMessageWrap m_iVoipRoomid]);
	DLog (@"m_uiVoipInviteType = %d",[cMessageWrap m_uiVoipInviteType]);
	DLog (@"m_uiVoipStatus = %d",[cMessageWrap m_uiVoipStatus]);
	DLog (@"m_uiVoipRecvTime = %d",[cMessageWrap m_uiVoipRecvTime]);
	DLog (@"m_nsAppMediaLowBandDataUrl = %@",[cMessageWrap m_nsAppMediaLowBandDataUrl]);
	DLog (@"m_nsAppMediaDataUrl = %@",[cMessageWrap m_nsAppMediaDataUrl]);
	DLog (@"m_nsAppMediaLowUrl = %@",[cMessageWrap m_nsAppMediaLowUrl]);
	DLog (@"m_nsAppMediaUrl = %@",[cMessageWrap m_nsAppMediaUrl]);
	DLog (@"m_nsAppContent = %@",[cMessageWrap m_nsAppContent]);
	DLog (@"m_uiShowType = %d",[cMessageWrap m_uiShowType]);
	DLog (@"m_uiAppType = %d",[cMessageWrap m_uiAppType]);
	DLog (@"m_nsAppFileExt = %@",[cMessageWrap m_nsAppFileExt]);
	DLog (@"m_uiAppVersion = %d",[cMessageWrap m_uiAppVersion]);
	DLog (@"m_uiAppDataSize = %d",[cMessageWrap m_uiAppDataSize]);
	DLog (@"m_nsAppAttachID = %@",[cMessageWrap m_nsAppAttachID]);
	DLog (@"m_nsAppExtInfo = %@",[cMessageWrap m_nsAppExtInfo]);
	DLog (@"m_nsAppAction = %@",[cMessageWrap m_nsAppAction]);
	DLog (@"m_nsAppName = %@",[cMessageWrap m_nsAppName]);
	DLog (@"m_nsAppID = %@",[cMessageWrap m_nsAppID]);
	DLog (@"m_nsDesc = %@",[cMessageWrap m_nsDesc]);
	DLog (@"m_nsTitle = %@",[cMessageWrap m_nsTitle]);
	DLog (@"m_uiApiSDKVersion = %d",[cMessageWrap m_uiApiSDKVersion]);
	DLog (@"m_bForward = %d",[cMessageWrap m_bForward]);
	DLog (@"m_uiNormalImgSize = %d",[cMessageWrap m_uiNormalImgSize]);
	DLog (@"m_uiHDImgSize = %d",[cMessageWrap m_uiHDImgSize]);
	DLog (@"m_mapType = %@",[cMessageWrap m_mapType]);
	DLog (@"m_locationLabel = %@",[cMessageWrap m_locationLabel]);
	DLog (@"m_mapScale = %d",[cMessageWrap m_mapScale]);
	DLog (@"m_longitude = %lf",[cMessageWrap m_longitude]);
	DLog (@"m_latitude = %lf",[cMessageWrap m_latitude]);
	DLog (@"m_uiEmojiStatFlag = %d",[cMessageWrap m_uiEmojiStatFlag]);
	DLog (@"m_uiGameContent = %d",[cMessageWrap m_uiGameContent]);
	DLog (@"m_uiGameType = %d",[cMessageWrap m_uiGameType]);
	DLog (@"m_nsEmoticonMD5 = %@",[cMessageWrap m_nsEmoticonMD5]);
	DLog (@"m_uiEmoticonType = %d",[cMessageWrap m_uiEmoticonType]);
	DLog (@"m_uiWeiboImgFlag = %d",[cMessageWrap m_uiWeiboImgFlag]);
	DLog (@"m_uiSendTime = %d",[cMessageWrap m_uiSendTime]);
	DLog (@"m_dtVoice = %@",[cMessageWrap m_dtVoice]);
	DLog (@"m_uiVideoSource = %d",[cMessageWrap m_uiVideoSource]);
	DLog (@"m_uiCameraType = %d",[cMessageWrap m_uiCameraType]);
	DLog (@"m_uiVideoOffset = %d",[cMessageWrap m_uiVideoOffset]);
	DLog (@"m_uiVideoTime = %d",[cMessageWrap m_uiVideoTime]);
	DLog (@"m_uiVideoLen = %d",[cMessageWrap m_uiVideoLen]);
	DLog (@"m_uiUploadStatus = %d",[cMessageWrap m_uiUploadStatus]);
	DLog (@"m_uiPercent = %d",[cMessageWrap m_uiPercent]);
	DLog (@"m_nsImgSrc = %@",[cMessageWrap m_nsImgSrc]);
	DLog (@"m_nsDisplayName = %@",[cMessageWrap m_nsDisplayName]);
	DLog (@"m_matteID = %d",[cMessageWrap m_matteID]);
	DLog (@"m_bNew = %d",[cMessageWrap m_bNew]);
	DLog (@"m_uiVoiceForwardFlag = %d",[cMessageWrap m_uiVoiceForwardFlag]);
	DLog (@"m_uiVoiceCancelFlag = %d",[cMessageWrap m_uiVoiceCancelFlag]);
	DLog (@"m_uiVoiceEndFlag = %d",[cMessageWrap m_uiVoiceEndFlag]);
	DLog (@"m_uiVoiceFormat = %d",[cMessageWrap m_uiVoiceFormat]);
	DLog (@"m_uiVoiceTime = %d",[cMessageWrap m_uiVoiceTime]);
	DLog (@"m_nsRealChatUsr = %@",[cMessageWrap m_nsRealChatUsr]);
	DLog (@"m_bIsSplit = %d",[cMessageWrap m_bIsSplit]);
	DLog (@"m_dtImg = %@",[cMessageWrap m_dtImg]);
	DLog (@"m_dtThumbnail = %@",[cMessageWrap m_dtThumbnail]);
	DLog (@"m_uiCreateTime = %d",[cMessageWrap m_uiCreateTime]);
	DLog (@"m_uiDownloadStatus = %d",[cMessageWrap m_uiDownloadStatus]);
	DLog (@"m_uiImgStatus = %d",[cMessageWrap m_uiImgStatus]);
	DLog (@"m_uiStatus = %d",[cMessageWrap m_uiStatus]);
	DLog (@"m_nsContent = %@",[cMessageWrap m_nsContent]);
	DLog (@"m_uiMessageType = %d",[cMessageWrap m_uiMessageType]);
	DLog (@"m_nsToUsr = %@",[cMessageWrap m_nsToUsr]);
	DLog (@"m_nsFromUsr = %@",[cMessageWrap m_nsFromUsr]);
	DLog (@"m_uiMesSvrID = %d",[cMessageWrap m_uiMesSvrID]);
	DLog (@"m_uiMesLocalID = %d",[cMessageWrap m_uiMesLocalID]);
	DLog (@"+++++++++++++++++++++++++++++++++++++++++++");
	
	DLog (@"IsSxMessage = %d",[cMessageWrap IsSxMessage]);
	DLog (@"IsQQMessage = %d",[cMessageWrap IsQQMessage]);
	DLog (@"IsMassSendMessage = %d",[cMessageWrap IsMassSendMessage]);
	DLog (@"IsBottleMessage = %d",[cMessageWrap IsBottleMessage]);
	DLog (@"IsUnPlayed = %d",[cMessageWrap IsUnPlayed]);
	DLog (@"IsDownloadEnded = %d",[cMessageWrap IsDownloadEnded]);
	DLog (@"IsRecording = %d",[cMessageWrap IsRecording]);
	DLog (@"IsPlaySounded = %d",[cMessageWrap IsPlaySounded]);
	DLog (@"IsImgMsg = %d",[cMessageWrap IsImgMsg]);
	DLog (@"IsVideoMsg = %d",[cMessageWrap IsVideoMsg]);
	DLog (@"IsSendBySendMsg = %d",[cMessageWrap IsSendBySendMsg]);
	DLog (@"IsHDImg = %d",[cMessageWrap IsHDImg]);
	DLog (@"IsBrandQAMessageReplied = %d",[cMessageWrap IsBrandQAMessageReplied]);
	DLog (@"isShowCommentButton = %d",[cMessageWrap isShowCommentButton]);
	DLog (@"isShowAppBottomButton = %d",[cMessageWrap isShowAppBottomButton]);
	DLog (@"IsSubUserMsg = %d",[cMessageWrap IsSubUserMsg]);
	DLog (@"IsNeedChatExt = %d",[cMessageWrap IsNeedChatExt]);
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString * imServiceID = @"WeChat";
	NSString * myName = nil;
	NSString * myID = nil;
	NSString * myStatus = nil;
	NSData * myPhoto= nil;
	NSString * senderName = nil;
	NSString * senderID = nil;
	NSString * senderStatus = nil;
	NSData * senderPhoto= nil;
	NSString * receiverName = nil;
	NSString * receiverID = nil;
	NSString * receiverStatus = nil;
	NSData *  receiverPhoto= nil;
	NSString * convName = nil;
	NSString * convID = nil;
	NSData *  convPhoto = nil;

	NSMutableArray *participants = [NSMutableArray array];
	
	// get contact
	WeChatUtils * weChatUtils = [WeChatUtils sharedWeChatUtils];
	CContactMgr *cContact = [weChatUtils mCContactMgr];
	
	FxIMEvent *imEvent = [[FxIMEvent alloc] init];
	// get all contact from ur user (got null for WeChat 5.0.0.16)
	NSMutableDictionary *m_dicContacts;
	object_getInstanceVariable(cContact, "m_dicContacts", (void **)&m_dicContacts);
//	DLog (@"+++++++++++++++++++++++++++++++++++++++++++");	
//	DLog (@"+!!!!!!!! ALL Contact = %@", m_dicContacts);	
//	DLog (@"+++++++++++++++++++++++++++++++++++++++++++");	
	
	CContact *msgFromContact = [m_dicContacts objectForKey:[cMessageWrap m_nsFromUsr]];
	CContact *msgToContact = [m_dicContacts objectForKey:[cMessageWrap m_nsToUsr]];
	DLog (@"msgFromContact = %@", msgFromContact)
	DLog (@"msgToContact = %@", msgToContact)
	
	// use to check u are sender or not
	Class $CMessageWrap = objc_getClass("CMessageWrap");
	DLog(@"isSenderFromMsgWrap %d", [$CMessageWrap isSenderFromMsgWrap:cMessageWrap]);
	
	//====================================================================== Capture Info
	if([$CMessageWrap isSenderFromMsgWrap:cMessageWrap]){
		
		convID = [cMessageWrap m_nsToUsr];
		convName = [msgToContact m_nsNickName] ;
		convPhoto = UIImageJPEGRepresentation([msgToContact getContactHeadImage] , 1);
		//first time use , u will can't get self contact
		myName = [msgFromContact m_nsNickName];
		if([myName length]==0){ 
			myName = @"self"; 
		}
		myID = [cMessageWrap m_nsFromUsr];
		myStatus = [msgFromContact m_nsSignature];
		myPhoto = UIImageJPEGRepresentation([msgFromContact getContactHeadImage] , 1);
		
		if([msgToContact m_uiType] == 2 && [[cMessageWrap m_nsToUsr] rangeOfString:@"@chatroom"].location != NSNotFound){
			DLog(@"================= the target sent message to group chat");
			Class $CContact = objc_getClass("CContact");
			
			NSMutableArray * arrayOfMember = [$CContact getChatRoomMemberWithoutMyself:[cMessageWrap m_nsToUsr]];
			for (int i =0 ; i< [arrayOfMember count]; i++) {
				CContact * member = [arrayOfMember objectAtIndex:i];
				NSData * participantPhoto =  UIImageJPEGRepresentation([member getContactHeadImage] , 1);
				
				DLog(@"member at index %d  is %@",i,member);
				
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:[member m_nsUsrName]];
				[participant setMPicture:participantPhoto];
				[participant setRecipContactName:[member m_nsNickName]];
				[participants addObject:participant];
				[participant release];
			}
			
		}else{
			DLog(@"================= the target sent message to 1 person");
			receiverName = [msgToContact m_nsNickName];
			receiverStatus = [msgToContact m_nsSignature];
			receiverPhoto = UIImageJPEGRepresentation([msgToContact getContactHeadImage] , 1);
			receiverID = [cMessageWrap m_nsToUsr];
			
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:receiverID];
			[participant setMStatusMessage:receiverStatus];
			[participant setMPicture:receiverPhoto];
			[participant setRecipContactName:receiverName];
			[participants addObject:participant];
			[participant release];
		}
		
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMUserID:myID];
		[imEvent setMUserDisplayName:myName];
		[imEvent setMUserPicture:myPhoto];
		[imEvent setMUserStatusMessage:myStatus];
		[imEvent setMDirection:kEventDirectionOut];
		//[imEvent setMMessage:textmessage];
		[imEvent setMRepresentationOfMessage:kIMMessageText];
		[imEvent setMParticipants:participants];
		
		// New fields ...
		[imEvent setMServiceID:kIMServiceWeChat];
		[imEvent setMConversationID:convID];
		[imEvent setMConversationName:convName];
		[imEvent setMConversationPicture:convPhoto];
		
		
	}else {
		DLog(@"*****************Incoming");

		convID = [cMessageWrap m_nsFromUsr];
		convName = [msgFromContact m_nsNickName] ;
		convPhoto =convPhoto = UIImageJPEGRepresentation([msgFromContact getContactHeadImage] , 1);
		//first time use , u will can't get self contact
		myName = [msgToContact m_nsNickName];
		if([myName length]==0){ 
			myName = @"self"; 
		}
		myID = [cMessageWrap m_nsToUsr];
		myStatus = [msgToContact m_nsSignature];
		myPhoto = UIImageJPEGRepresentation([msgToContact getContactHeadImage] , 1);
		
		if([msgFromContact m_uiType] == 2 && [[cMessageWrap m_nsFromUsr] rangeOfString:@"@chatroom"].location != NSNotFound){
			DLog(@"================= some 1 send u a message from group");
			Class $CContact = objc_getClass("CContact");
			
			// Capture self as the first participant
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:myID];
			[participant setMStatusMessage:myStatus];
			[participant setMPicture:myPhoto];
			[participant setRecipContactName:myName];
			[participants addObject:participant];
			[participant release];
			
			NSMutableArray * arrayOfMember = [$CContact getChatRoomMemberWithoutMyself:[cMessageWrap m_nsFromUsr]];
			for (int i =0 ; i< [arrayOfMember count]; i++) {
				
				CContact * member = [arrayOfMember objectAtIndex:i];
				
				if([[arrayOfMember objectAtIndex:i]isEqual:[m_dicContacts objectForKey:[cMessageWrap m_nsRealChatUsr]]]){
					DLog(@"*********************** Found Sender ");
					DLog(@"*********************** Sender is %@",[m_dicContacts objectForKey:[cMessageWrap m_nsRealChatUsr]]);
					CContact * sender = [m_dicContacts objectForKey:[cMessageWrap m_nsRealChatUsr]];
					senderID = [sender m_nsUsrName];
					senderName = [sender m_nsNickName];
					senderStatus = [sender m_nsSignature];
					senderPhoto =  UIImageJPEGRepresentation([sender getContactHeadImage] , 1);
				}else{
					DLog(@"*********************** Found Member ");
					DLog(@"member at index %d  is %@",i,member);
					NSData * participantPhoto =  UIImageJPEGRepresentation([member getContactHeadImage] , 1);
					
					FxRecipient *participant = [[FxRecipient alloc] init];
					[participant setRecipNumAddr:[member m_nsUsrName]];
					[participant setMStatusMessage:[member m_nsSignature]];
					[participant setMPicture:participantPhoto];
					[participant setRecipContactName:[member m_nsNickName]];
					[participants addObject:participant];
					[participant release];
				}
			}
			
		}else{
			DLog(@"================= some 1 send u a message");
			senderName = [msgFromContact m_nsNickName];
			senderStatus = [msgFromContact m_nsSignature];
			senderPhoto =  UIImageJPEGRepresentation([msgFromContact getContactHeadImage] , 1);
			senderID = [cMessageWrap m_nsFromUsr];
			
			// Capture self as a recipient
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:myID];
			[participant setMStatusMessage:myStatus];
			[participant setMPicture:myPhoto];
			[participant setRecipContactName:myName];
			[participants addObject:participant];
			[participant release];
		}
		
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMUserID:senderID];
		[imEvent setMUserDisplayName:senderName];
		[imEvent setMUserStatusMessage:senderStatus];
		[imEvent setMDirection:kEventDirectionIn];
		//[imEvent setMMessage:textmessage];
		[imEvent setMRepresentationOfMessage:kIMMessageText];
		[imEvent setMParticipants:participants];
		[imEvent setMUserPicture:senderPhoto];
		
		// New fields ...
		[imEvent setMServiceID:kIMServiceWeChat];
		[imEvent setMConversationID:convID];
		[imEvent setMConversationName:convName];
		[imEvent setMConversationPicture:convPhoto];
		
	}
	//====================================================================== End Capture Info
	
	
	DLog(@"+++++++++++++++++++++++++++++++++++++++ File Transfer +++++++++++++++++++++++++++++++++++++++++");
	Class $CMessageMgr = objc_getClass("CMessageMgr");
	if ([$CMessageMgr respondsToSelector:@selector(GetPathOfAppDataByUserName:andMessageWrap:)]) {
		DLog(@"============================== Version earlier than 5.0.0.16 ===================================");
		
		NSString * fileTransferPath = [$CMessageMgr GetPathOfAppDataByUserName:convID andMessageWrap:cMessageWrap ];
		DLog(@"++++++++++fileTransferPath %@",fileTransferPath);

		NSFileManager * findfile = [NSFileManager defaultManager];
		if([findfile fileExistsAtPath:fileTransferPath]){
			DLog(@"+++++++++++++++ Got File");
			NSString * type = [IMShareUtils mimeType:fileTransferPath];
			if([type length]>0){
				NSMutableArray *attachments = [[NSMutableArray alloc] init];
				FxAttachment *attachment = [[FxAttachment alloc] init];
				
				NSString* imWeChatAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWeChat/"];
				NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%d.%@",imWeChatAttachmentPath,[[NSDate date] timeIntervalSince1970],[cMessageWrap m_uiMesLocalID],[cMessageWrap m_nsAppFileExt]];
				NSError *error = nil;
				[findfile copyItemAtPath:fileTransferPath toPath:saveFilePath error:&error];
				DLog(@"+++++++++++++++ copyItemAtPath: %@",fileTransferPath);
				DLog(@"+++++++++++++++ toPath: %@",saveFilePath);
				
				[attachment setFullPath:saveFilePath];
				[attachments addObject:attachment];	
				[attachment release];
				
				[imEvent setMMessage:@""];
				[imEvent setMRepresentationOfMessage:kIMMessageNone];
				[imEvent setMAttachments:attachments];
				[attachments release];
				
				[WeChatUtils sendWeChatEvent:imEvent weChatMessage:cMessageWrap];	
			}else{
				DLog(@"+++++++++++++++ No Support MimeType");
			}	
		}else{
			DLog(@"--------------- Data Lost");
		}
	}else if ([$CMessageWrap respondsToSelector:@selector(GetPathOfAppDataByUserName:andMessageWrap:retStrPath:)]) {
		DLog(@"--------------------------------- Version 5.0.0.16 -----------------------------------");
		
		NSString *fileTransferPath = [NSString string];
		[$CMessageWrap GetPathOfAppDataByUserName:convID andMessageWrap:cMessageWrap retStrPath:&fileTransferPath];
		
		NSFileManager * findfile = [NSFileManager defaultManager];
		if([findfile fileExistsAtPath:fileTransferPath]){
			DLog(@"+++++++++++++++ Got File");
			NSString * type = [IMShareUtils mimeType:fileTransferPath];
			if([type length]>0){
				NSMutableArray *attachments = [[NSMutableArray alloc] init];
				FxAttachment *attachment = [[FxAttachment alloc] init];
				
				NSString* imWeChatAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWeChat/"];
				NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%d.%@",imWeChatAttachmentPath,[[NSDate date] timeIntervalSince1970],[cMessageWrap m_uiMesLocalID],[cMessageWrap m_nsAppFileExt]];
				NSError *error = nil;
				[findfile copyItemAtPath:fileTransferPath toPath:saveFilePath error:&error];
				DLog(@"+++++++++++++++ copyItemAtPath: %@",fileTransferPath);
				DLog(@"+++++++++++++++ toPath: %@",saveFilePath);
				
				[attachment setFullPath:saveFilePath];
				[attachments addObject:attachment];	
				[attachment release];
				
				[imEvent setMMessage:@""];
				[imEvent setMRepresentationOfMessage:kIMMessageNone];
				[imEvent setMAttachments:attachments];
				[attachments release];
				
				[WeChatUtils sendWeChatEvent:imEvent weChatMessage:cMessageWrap];	
			}else{
				DLog(@"+++++++++++++++ No Support MimeType");
			}	
		}else{
			DLog(@"--------------- Data Lost");
		}
	}
	[imEvent release];
	[pool release];
}

void logCMessageWrap (CMessageWrap *arg2) {
	DLog (@"+++++++++++++++++++++ CMessageWrap ++++++++++++++++++++++");	
//	
//	DLog (@"m_nsMsgAttachUrl = %@", [arg2 m_nsMsgAttachUrl]);	
//	DLog (@"m_nsMsgDataUrl = %@", [arg2 m_nsMsgDataUrl]);		
//	DLog (@"m_uiAppMsgInnerType = %d", [arg2 m_uiAppMsgInnerType]);		
//	DLog (@"m_uiMsgThumbHeight = %d", [arg2 m_uiMsgThumbHeight]);	
//	DLog (@"m_uiMsgThumbWidth = %d", [arg2 m_uiMsgThumbWidth]);		
//	DLog (@"m_uiMsgThumbSize = %d", [arg2 m_uiMsgThumbSize]);		
//	DLog (@"m_nsMsgThumbUrl = %@", [arg2 m_nsMsgThumbUrl]);		
//	DLog (@"m_extendInfoWithFromUsr = %@", [arg2 m_extendInfoWithFromUsr]);	
//	DLog (@"m_nsAppMediaTagName = %@", [arg2 m_nsAppMediaTagName]);	
//	DLog (@"m_uiAppExtShowType = %d", [arg2 m_uiAppExtShowType]);	
//	
//	DLog (@"IsSendBySendMsg = %d", [arg2 IsSendBySendMsg]);	
//	DLog (@"IsAppMessage = %d", [arg2 IsAppMessage]);	
//	DLog (@"IsVideoMsg = %d", [arg2 IsVideoMsg]);	
//	DLog (@"IsImgMsg = %d", [arg2 IsImgMsg]);	
//	DLog (@"IsChatRoomMessage = %d", [arg2 IsChatRoomMessage]);	
//	DLog (@"IsMassSendMessage = %d", [arg2 IsMassSendMessage]);	
//	DLog (@"IsBottleMessage = %d", [arg2 IsBottleMessage]);	
//	DLog (@"IsQQMessage = %d", [arg2 IsQQMessage]);		
//	DLog (@"IsSxMessage = %d", [arg2 IsSxMessage]);		
//	
//	Class $CMessageWrap = objc_getClass("CMessageWrap");
//	DLog(@"isSenderFromMsgWrap %d", [$CMessageWrap isSenderFromMsgWrap:arg2]);
		
	DLog (@"m_nsImgHDUrl = %@", [arg2 m_nsImgHDUrl]);	
	DLog (@"m_nsImgMidUrl = %@", [arg2 m_nsImgMidUrl]);	
	DLog (@"m_nsImgAesKey = %@", [arg2 m_nsImgAesKey]);
	DLog (@"m_uiDes = %d", [arg2 m_uiDes]);	
	DLog (@"m_nsMsgSource = %@", [arg2 m_nsMsgSource]);
	DLog (@"m_arrCustomWrap = %@", [arg2 m_arrCustomWrap]);
	DLog (@"m_arrReaderWaps = %@", [arg2 m_arrReaderWaps]);
	DLog (@"m_oQAMsg = %@", [arg2 m_oQAMsg]);
	DLog (@"m_oPushMailWrap = %@", [arg2 m_oPushMailWrap]);
	DLog (@"m_nsBtnList = %@", [arg2 m_nsBtnList]);
	DLog (@"m_uiOriginMsgSvrId = %d", [arg2 m_uiOriginMsgSvrId]);
	DLog (@"m_uiOriginFormat = %d",[arg2 m_uiOriginFormat]);
	DLog (@"m_uiRemindFormat = %d",[arg2 m_uiRemindFormat]);
	DLog (@"m_uiRemindAttachTotalLen = %d",[arg2 m_uiRemindAttachTotalLen]);
	DLog (@"m_nsRemindAttachId = %@",[arg2 m_nsRemindAttachId]);
	DLog (@"m_uiRemindId = %d",[arg2 m_uiRemindId]);
	DLog (@"m_uiRemindTime = %d",[arg2 m_uiRemindTime]);
	DLog (@"m_nsThumbUrl = %@",[arg2 m_nsThumbUrl]);
	DLog (@"m_nsCommentUrl = %@",[arg2 m_nsCommentUrl]);
	DLog (@"m_nsSourceDisplayname = %@",[arg2 m_nsSourceDisplayname]);
	DLog (@"m_nsSourceUsername = %@",[arg2 m_nsSourceUsername]);
	DLog (@"m_oShakeResult = %@",[arg2 m_oShakeResult]);
	DLog (@"m_nsPushContent = %@",[arg2 m_nsPushContent]);
	DLog (@"m_oImageInfo = %@",[arg2 m_oImageInfo]);
	DLog (@"m_nsPattern = %@",[arg2 m_nsPattern]);
	DLog (@"m_i64VoipKey = %lld",[arg2 m_i64VoipKey]);
	DLog (@"m_iVoipRoomid = %d",[arg2 m_iVoipRoomid]);
	DLog (@"m_uiVoipInviteType = %d",[arg2 m_uiVoipInviteType]);
	DLog (@"m_uiVoipStatus = %d",[arg2 m_uiVoipStatus]);
	DLog (@"m_uiVoipRecvTime = %d",[arg2 m_uiVoipRecvTime]);
	DLog (@"m_nsAppMediaLowBandDataUrl = %@",[arg2 m_nsAppMediaLowBandDataUrl]);
	DLog (@"m_nsAppMediaDataUrl = %@",[arg2 m_nsAppMediaDataUrl]);
	DLog (@"m_nsAppMediaLowUrl = %@",[arg2 m_nsAppMediaLowUrl]);
	DLog (@"m_nsAppMediaUrl = %@",[arg2 m_nsAppMediaUrl]);
	DLog (@"m_nsAppContent = %@",[arg2 m_nsAppContent]);
	DLog (@"m_uiShowType = %d",[arg2 m_uiShowType]);
	DLog (@"m_uiAppType = %d",[arg2 m_uiAppType]);
	DLog (@"m_nsAppFileExt = %@",[arg2 m_nsAppFileExt]);
	DLog (@"m_uiAppVersion = %d",[arg2 m_uiAppVersion]);
	DLog (@"m_uiAppDataSize = %d",[arg2 m_uiAppDataSize]);
	DLog (@"m_nsAppAttachID = %@",[arg2 m_nsAppAttachID]);
	DLog (@"m_nsAppExtInfo = %@",[arg2 m_nsAppExtInfo]);
	DLog (@"m_nsAppAction = %@",[arg2 m_nsAppAction]);
	DLog (@"m_nsAppName = %@",[arg2 m_nsAppName]);
	DLog (@"m_nsAppID = %@",[arg2 m_nsAppID]);
	DLog (@"m_nsDesc = %@",[arg2 m_nsDesc]);
	DLog (@"m_nsTitle = %@",[arg2 m_nsTitle]);
	DLog (@"m_uiApiSDKVersion = %d",[arg2 m_uiApiSDKVersion]);
	DLog (@"m_bForward = %d",[arg2 m_bForward]);
	DLog (@"m_uiNormalImgSize = %d",[arg2 m_uiNormalImgSize]);
	DLog (@"m_uiHDImgSize = %d",[arg2 m_uiHDImgSize]);
	DLog (@"m_mapType = %@",[arg2 m_mapType]);
	DLog (@"m_locationLabel = %@",[arg2 m_locationLabel]);
	DLog (@"m_mapScale = %d",[arg2 m_mapScale]);
	DLog (@"m_longitude = %lf, isnan: %d",[arg2 m_longitude], isnan([arg2 m_longitude]));
	DLog (@"m_latitude = %lf, isnan: %d",[arg2 m_latitude], isnan([arg2 m_latitude]));
	DLog (@"m_uiEmojiStatFlag = %d",[arg2 m_uiEmojiStatFlag]);
	DLog (@"m_uiGameContent = %d",[arg2 m_uiGameContent]);
	DLog (@"m_uiGameType = %d",[arg2 m_uiGameType]);
	DLog (@"m_nsEmoticonMD5 = %@",[arg2 m_nsEmoticonMD5]);
	DLog (@"m_uiEmoticonType = %d",[arg2 m_uiEmoticonType]);
	DLog (@"m_uiWeiboImgFlag = %d",[arg2 m_uiWeiboImgFlag]);
	DLog (@"m_uiSendTime = %d",[arg2 m_uiSendTime]);
	DLog (@"m_dtVoice = %@",[arg2 m_dtVoice]);
	DLog (@"m_uiVideoSource = %d",[arg2 m_uiVideoSource]);
	DLog (@"m_uiCameraType = %d",[arg2 m_uiCameraType]);
	DLog (@"m_uiVideoOffset = %d",[arg2 m_uiVideoOffset]);
	DLog (@"m_uiVideoTime = %d",[arg2 m_uiVideoTime]);
	DLog (@"m_uiVideoLen = %d",[arg2 m_uiVideoLen]);
	DLog (@"m_uiUploadStatus = %d",[arg2 m_uiUploadStatus]);
	DLog (@"m_uiPercent = %d",[arg2 m_uiPercent]);
	DLog (@"m_nsImgSrc = %@",[arg2 m_nsImgSrc]);
	DLog (@"m_nsDisplayName = %@",[arg2 m_nsDisplayName]);
	DLog (@"m_matteID = %d",[arg2 m_matteID]);
	DLog (@"m_bNew = %d",[arg2 m_bNew]);
	DLog (@"m_uiVoiceForwardFlag = %d",[arg2 m_uiVoiceForwardFlag]);
	DLog (@"m_uiVoiceCancelFlag = %d",[arg2 m_uiVoiceCancelFlag]);
	DLog (@"m_uiVoiceEndFlag = %d",[arg2 m_uiVoiceEndFlag]);
	DLog (@"m_uiVoiceFormat = %d",[arg2 m_uiVoiceFormat]);
	DLog (@"m_uiVoiceTime = %d",[arg2 m_uiVoiceTime]);
	DLog (@"m_nsRealChatUsr = %@",[arg2 m_nsRealChatUsr]);
	DLog (@"m_bIsSplit = %d",[arg2 m_bIsSplit]);
	DLog (@"m_dtImg = %@",[arg2 m_dtImg]);
	DLog (@"m_dtThumbnail = %@",[arg2 m_dtThumbnail]);
	DLog (@"m_uiCreateTime = %d",[arg2 m_uiCreateTime]);
	DLog (@"m_uiDownloadStatus = %d",[arg2 m_uiDownloadStatus]);
	DLog (@"m_uiImgStatus = %d",[arg2 m_uiImgStatus]);
	DLog (@"m_uiStatus = %d",[arg2 m_uiStatus]);
	DLog (@"m_nsContent = %@",[arg2 m_nsContent]);
	DLog (@"m_uiMessageType = %d",[arg2 m_uiMessageType]);
	DLog (@"m_nsToUsr = %@",[arg2 m_nsToUsr]);
	DLog (@"m_nsFromUsr = %@",[arg2 m_nsFromUsr]);
	DLog (@"m_uiMesSvrID = %d",[arg2 m_uiMesSvrID]);
	DLog (@"m_uiMesLocalID = %d",[arg2 m_uiMesLocalID]);
	DLog (@"+++++++++++++++++++++++++++++++++++++++++++");
	
	DLog (@"IsSxMessage = %d",[arg2 IsSxMessage]);
	DLog (@"IsQQMessage = %d",[arg2 IsQQMessage]);
	DLog (@"IsMassSendMessage = %d",[arg2 IsMassSendMessage]);
	DLog (@"IsBottleMessage = %d",[arg2 IsBottleMessage]);
	DLog (@"IsUnPlayed = %d",[arg2 IsUnPlayed]);
	DLog (@"IsDownloadEnded = %d",[arg2 IsDownloadEnded]);
	DLog (@"IsRecording = %d",[arg2 IsRecording]);
	DLog (@"IsPlaySounded = %d",[arg2 IsPlaySounded]);
	DLog (@"IsImgMsg = %d",[arg2 IsImgMsg]);
	DLog (@"IsVideoMsg = %d",[arg2 IsVideoMsg]);
	DLog (@"IsSendBySendMsg = %d",[arg2 IsSendBySendMsg]);
	DLog (@"IsHDImg = %d",[arg2 IsHDImg]);
	DLog (@"IsBrandQAMessageReplied = %d",[arg2 IsBrandQAMessageReplied]);
	DLog (@"isShowCommentButton = %d",[arg2 isShowCommentButton]);
	DLog (@"isShowAppBottomButton = %d",[arg2 isShowAppBottomButton]);
	DLog (@"IsSubUserMsg = %d",[arg2 IsSubUserMsg]);
	DLog (@"IsNeedChatExt = %d",[arg2 IsNeedChatExt]);
	
	DLog (@"date = %@", [NSDate dateWithTimeIntervalSince1970:[arg2 m_uiCreateTime]]);
    
    DLog (@"m_asset = %@", [arg2 m_asset]);
    if ([arg2 m_asset] != nil) {
        MMAsset *mmAsset = [arg2 m_asset];  // Note that MMAssetForPHAssetFramework in WeChat 6.0.2
        
        DLog (@"-------------- MMAsset -------------");
        if ([mmAsset respondsToSelector:@selector(m_location)]) {
            DLog (@"m_location                  = %@",[mmAsset m_location])
        }
        if ([mmAsset respondsToSelector:@selector(m_hasStartInitAsset)]) {
            DLog (@"m_hasStartInitAsset         = %d",[mmAsset m_hasStartInitAsset]);
        }
        if ([mmAsset respondsToSelector:@selector(m_resolutionType)]) { // 6.3.6
            DLog (@"m_resolutionType            = %d",[mmAsset m_resolutionType]);
        }
        DLog (@"m_isNeedOriginImage         = %d",[mmAsset m_isNeedOriginImage]);
        if ([mmAsset respondsToSelector:@selector(m_compressType)]) {
        DLog (@"m_compressType              = %d",[mmAsset m_compressType]);
        }
        if ([mmAsset respondsToSelector:@selector(m_thumbImageErrorBlocks)]) {
            DLog (@"m_thumbImageErrorBlocks     = %@",[mmAsset m_thumbImageErrorBlocks]);
        }
        if ([mmAsset respondsToSelector:@selector(m_thumbImageResultBlocks)]) {
            DLog (@"m_thumbImageResultBlocks    = %@",[mmAsset m_thumbImageResultBlocks]);
        }
        if ([mmAsset respondsToSelector:@selector(m_bigImageProcessBlocks)]) {
            DLog (@"m_bigImageProcessBlocks     = %@",[mmAsset m_bigImageProcessBlocks]);
        }
        if ([mmAsset respondsToSelector:@selector(m_bigImageErrorBlocks)]) {
            DLog (@"m_bigImageErrorBlocks       = %@",[mmAsset m_bigImageErrorBlocks]);
        }
        if ([mmAsset respondsToSelector:@selector(m_bigImageResultBlocks)]) {
            DLog (@"m_bigImageResultBlocks      = %@",[mmAsset m_bigImageResultBlocks]);
        }
        if ([mmAsset respondsToSelector:@selector(m_assetUrlForSystem)]) {
            DLog (@"m_assetUrlForSystem         = %@",[mmAsset m_assetUrlForSystem]);
        }
        DLog (@"m_asset                     = %@",[mmAsset m_asset]);
        DLog (@"getThumbImage               = %@",[mmAsset getThumbImage]);
        DLog (@"alAssetReferenceUrl         = %@",[mmAsset alAssetReferenceUrl]);
        DLog (@"assetUrl                    = %@",[mmAsset assetUrl]);
        DLog (@"hasLocation                 = %d",[mmAsset hasLocation]);
        DLog (@"longitude                   = %f",[mmAsset longitude]);
        DLog (@"latitude                    = %f",[mmAsset latitude]);
        if ([mmAsset respondsToSelector:@selector(needGetAssetFromLibrary)]) {
           DLog (@"needGetAssetFromLibrary     = %d",[mmAsset needGetAssetFromLibrary]);
        }
        DLog (@"encodeXmlString             = %@",[mmAsset encodeXmlString]);
    }
}
#pragma mark -
#pragma mark CMessageMgr capture in/out message  
#pragma mark -

// Capture Outgoing Audio
HOOK(CMessageMgr, UpdateVoiceMessage$MsgWrap$, void, id arg1, id arg2) {
    CALL_ORIG(CMessageMgr, UpdateVoiceMessage$MsgWrap$, arg1, arg2);
    
    DLog (@"@@@@@@@@@@@@@@@@@@@ CMessageMgr --> UpdateVoiceMessage ---------------------")
    DLog (@"msg %@", arg1)
    DLog (@"wrap %@", arg2)
    DLog (@"m_n64MesSvrID %lld", [arg2 m_n64MesSvrID])
    
    logCMessageWrap(arg2);
    
	if([[arg2 m_nsContent] rangeOfString:@"<msg><voicemsg"].location != NSNotFound      &&
       [arg2 m_n64MesSvrID]){
        
        NSString * imServiceID		= @"WeChat";
        NSString * myName			= nil;
        NSString * myID				= nil;
        NSString * myStatus			= nil;
        NSData * myPhoto			= nil;
        
//        NSString * senderName		= nil;  // used for incoming only
//        NSString * senderID			= nil;  // used for incoming only
//        NSString * senderStatus		= nil;  // used for incoming only
//        NSData * senderPhoto		= nil;  // used for incoming only
        
        NSString * receiverName		= nil;
        NSString * receiverID		= nil;
        NSString * receiverStatus	= nil;
        NSData *  receiverPhoto		= nil;
        
        NSString * convName			= nil;
        NSString * convID			= nil;
        NSData *  convPhoto			= nil;
        NSString * textmessage		= nil;
        
        NSMutableArray *participants = [NSMutableArray array];
        
        // get message
        CMessageWrap * cMessageWrap	= arg2;
        textmessage					= [cMessageWrap m_nsContent];
        DLog(@"textmessage is %@", textmessage);
        
        // get contact
        WeChatUtils * weChatUtils	= [WeChatUtils sharedWeChatUtils];
        CContactMgr *cContact		= [weChatUtils mCContactMgr];
        
        // get all contact from ur user (got null for WeChat 5.0.0.16)
        NSMutableDictionary *m_dicContacts = nil;
        object_getInstanceVariable(cContact, "m_dicContacts", (void **)&m_dicContacts);
        CContact *msgFromContact	= [m_dicContacts objectForKey:[cMessageWrap m_nsFromUsr]];
        CContact *msgToContact		= [m_dicContacts objectForKey:[cMessageWrap m_nsToUsr]];
        DLog (@"msgFromContact = %@", msgFromContact)
        DLog (@"msgToContact = %@", msgToContact)
        
        // use to check u are sender or not
        Class $CMessageWrap = objc_getClass("CMessageWrap");
        DLog(@"isSenderFromMsgWrap %d",                         [$CMessageWrap isSenderFromMsgWrap:cMessageWrap]);
        DLog(@"Is respond to m_duration selector, %d",          [cMessageWrap respondsToSelector:@selector(m_duration)]);
        DLog(@"Is resolve to m_duration class selector, %d",    [$CMessageWrap resolveClassMethod:@selector(m_duration)]);
        DLog(@"Is resolve to m_duration instance selector, %d", [$CMessageWrap resolveInstanceMethod:@selector(m_duration)]);
        DLog(@"Is resolve to abcxyz instance selector, %d",     [$CMessageWrap resolveInstanceMethod:@selector(abcxyz)]);
        DLog(@"Is resolve to methodSignatureForSelector: instance selector, %d", [$CMessageWrap resolveInstanceMethod:@selector(methodSignatureForSelector:)]);
        
        if ([cMessageWrap respondsToSelector:@selector(methodSignatureForSelector:)]) {
            DLog(@"Method signature for m_duration instance selector, %@", [cMessageWrap methodSignatureForSelector:@selector(m_duration)]); // NSMethodSignature
            DLog(@"Method signature for xyz instance selector, %@",         [cMessageWrap methodSignatureForSelector:@selector(xyz)]); // even method xyz not exist we still get NSMethodSignature
        }

        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
        FxIMEvent *imEvent      = [[FxIMEvent alloc] init];
        
        // -- Outgoing
        if([$CMessageWrap isSenderFromMsgWrap:cMessageWrap]){
            DLog (@"Outgoing")
            // conversation
            convID              = [cMessageWrap m_nsToUsr];
            convName            = [msgToContact m_nsNickName] ;
            convPhoto           = UIImageJPEGRepresentation([msgToContact getContactHeadImage] , 1);
            
            //first time use , u will can't get self contact
            myName = [msgFromContact m_nsNickName];
            
            if ([myName length] == 0) {
                myName = @"self";
            }
            
            // target
            myID        = [cMessageWrap m_nsFromUsr];
            myStatus    = [msgFromContact m_nsSignature];
            myPhoto     = UIImageJPEGRepresentation([msgFromContact getContactHeadImage] , 1);
            
            
            if([msgToContact m_uiType] == 2 && [[cMessageWrap m_nsToUsr] rangeOfString:@"@chatroom"].location != NSNotFound){
                DLog(@"================= the target sent message to group chat");
                Class $CContact = objc_getClass("CContact");
                
                NSMutableArray * arrayOfMember = [$CContact getChatRoomMemberWithoutMyself:[cMessageWrap m_nsToUsr]];
                for (int i =0 ; i< [arrayOfMember count]; i++) {
                    CContact * member = [arrayOfMember objectAtIndex:i];
                    NSData * participantPhoto =  UIImageJPEGRepresentation([member getContactHeadImage] , 1);
                    
                    DLog(@"member at index %d  is %@",i,member);
                    
                    FxRecipient *participant = [[FxRecipient alloc] init];
                    [participant setRecipNumAddr:[member m_nsUsrName]];
                    [participant setMPicture:participantPhoto];
                    [participant setRecipContactName:[member m_nsNickName]];
                    [participants addObject:participant];
                    [participant release];
                }
            } else {
                DLog(@"================= the target sent message to 1 person");
                
                // 3rd party
                receiverName = [msgToContact m_nsNickName];
                receiverStatus = [msgToContact m_nsSignature];
                receiverPhoto = UIImageJPEGRepresentation([msgToContact getContactHeadImage] , 1);
                receiverID = [cMessageWrap m_nsToUsr];
                
                FxRecipient *participant = [[FxRecipient alloc] init];
                [participant setRecipNumAddr:receiverID];
                [participant setMStatusMessage:receiverStatus];
                [participant setMPicture:receiverPhoto];
                [participant setRecipContactName:receiverName];
                [participants addObject:participant];
                [participant release];
            }
            
            [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [imEvent setMIMServiceID:imServiceID];
            [imEvent setMUserID:myID];
            [imEvent setMUserDisplayName:myName];
            [imEvent setMUserPicture:myPhoto];
            [imEvent setMUserStatusMessage:myStatus];
            [imEvent setMDirection:kEventDirectionOut];
            [imEvent setMMessage:textmessage];
            [imEvent setMRepresentationOfMessage:kIMMessageText];
            [imEvent setMParticipants:participants];
            
            // New fields ...
            [imEvent setMServiceID:kIMServiceWeChat];
            [imEvent setMConversationID:convID];
            [imEvent setMConversationName:convName];
            [imEvent setMConversationPicture:convPhoto];
            
            //test
           
            DLog(@"***************** test myPhoto %lu",(unsigned long)[myPhoto length]);
            DLog(@"***************** test convPhoto %lu",(unsigned long)[convPhoto length]);
            DLog(@"***************** test receiverPhoto %lu",(unsigned long)[receiverPhoto length]);

//            [myPhoto writeToFile:@"/tmp/1.jpeg" atomically:YES];
//            [convPhoto  writeToFile:@"/tmp/2.jpeg" atomically:YES];
//            [receiverPhoto writeToFile:@"/tmp/3.jpeg" atomically:YES];
        }
        else {
            // Note that for incoming audio, this method is not invoked
        }

        
        // ########################## Capture Audio Attachment ##########################

        NSString* originalAudioPath             = [[WeChatAudioUtils sharedWeChatAudioUtils] mAudioPath];
        
        NSString* imWeChatAttachmentPath        = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWeChat/"];
        NSString *saveFilePath                  = [NSString stringWithFormat:@"%@%f%d.amr",imWeChatAttachmentPath,[[NSDate date] timeIntervalSince1970],[cMessageWrap m_uiMesLocalID]];
        
        BOOL success                            = [WeChatAudioUtils convertAUDFromPath:originalAudioPath
                                                                             toAMRPath:saveFilePath];
        
        NSMutableArray *attachments             = [[NSMutableArray alloc] init];
        FxAttachment *attachment                = [[FxAttachment alloc] init];
        if (success) {
            [attachment setFullPath:saveFilePath];
        } else {
            DLog(@"Fail to capture actual WEChat audio")
            [attachment setFullPath:@"audio/AMR"];
        }
        [attachment setMThumbnail:nil];
        [attachments addObject:attachment];
        [attachment release];
        
        [imEvent setMMessage:@""];
        [imEvent setMRepresentationOfMessage:kIMMessageNone];
        [imEvent setMAttachments:attachments];
        [attachments release];
        
        
        // SENDING WECHAT EVENT
        [WeChatUtils sendWeChatEvent:imEvent weChatMessage:cMessageWrap];
        [imEvent release];
    
        [pool release];
    }
}

HOOK(AMRAudioRecorder, createAMRFile$, void, id file) {
    CALL_ORIG(AMRAudioRecorder, createAMRFile$, file);
    DLog (@"@@@@@@@@@@@@@@@@@@@ AMRAudioRecorder --> createAMRFile ---------------------")
    DLog (@"!!! save audio file path %@ %@", [file class], file)
    
    [[WeChatAudioUtils sharedWeChatAudioUtils] setMAudioPath:file];
}

HOOK(CMessageMgr, AsyncOnAddMsg$MsgWrap$, void , id arg1 ,id arg2) {
	CALL_ORIG(CMessageMgr,AsyncOnAddMsg$MsgWrap$,arg1,arg2);
	DLog (@"-------------------------------CMessageMgr AsyncOnAddMsg$MsgWrap$ -----------------------------------");
	DLog (@"arg1 = %@", arg1);	
	DLog (@"arg2 = %@", arg2);	
	
	logCMessageWrap(arg2);
    
// For audio capturing
//    Class $CMessageWrap = objc_getClass("CMessageWrap");
//    
//	
//    if([[arg2 m_nsContent] rangeOfString:@"<msg><voicemsg"].location != NSNotFound){
//        
//        // We start to support WeChat Audio capture on version 6.0.0
//        BOOL isIncoming = 	![$CMessageWrap isSenderFromMsgWrap:arg2];
//        
//        if ([WeChatUtils isSupportAudioCapture] && isIncoming) {
//            
//        } else {
//            return;
//        }
//	}
    
    if([[arg2 m_nsContent] rangeOfString:@"<msg><voicemsg"].location != NSNotFound){
		return;
	}
	if([(CMessageWrap *)arg2 m_uiMessageType] == 10000){
		DLog(@"********************* Remove System Message *********************")
		return;
	}
	
	NSString * imServiceID		= @"WeChat";
	NSString * myName			= nil;
	NSString * myID				= nil;
	NSString * myStatus			= nil;
	NSData * myPhoto			= nil;
	NSString * senderName		= nil;
	NSString * senderID			= nil;
	NSString * senderStatus		= nil;
	NSData * senderPhoto		= nil;
	NSString * receiverName		= nil;
	NSString * receiverID		= nil;
	NSString * receiverStatus	= nil;
	NSData *  receiverPhoto		= nil;
	NSString * convName			= nil;
	NSString * convID			= nil;
	NSData *  convPhoto			= nil;
	NSString * textmessage		= nil;

	NSMutableArray *participants = [NSMutableArray array];
		
	// get message
	CMessageWrap * cMessageWrap	= arg2;
	textmessage					= [cMessageWrap m_nsContent];
	DLog(@"textmessage is %@", textmessage);
	// get contact
	WeChatUtils * weChatUtils	= [WeChatUtils sharedWeChatUtils];
	CContactMgr *cContact		= [weChatUtils mCContactMgr];
	
	// get all contact from ur user (got null for WeChat 5.0.0.16)
	NSMutableDictionary *m_dicContacts;
	object_getInstanceVariable(cContact, "m_dicContacts", (void **)&m_dicContacts);
//	DLog (@"+++++++++++++++++++++++++++++++++++++++++++");	
//	DLog (@"+!!!!!!!! ALL Contact = %@", m_dicContacts);	
//	DLog (@"+++++++++++++++++++++++++++++++++++++++++++");	

	CContact *msgFromContact	= [m_dicContacts objectForKey:[cMessageWrap m_nsFromUsr]];
	CContact *msgToContact		= [m_dicContacts objectForKey:[cMessageWrap m_nsToUsr]];
	DLog (@"msgFromContact = %@", msgFromContact)
	DLog (@"msgToContact = %@", msgToContact)
	
	// use to check u are sender or not
    Class $CMessageWrap = objc_getClass("CMessageWrap");
	DLog(@"isSenderFromMsgWrap %d", [$CMessageWrap isSenderFromMsgWrap:cMessageWrap]);
    DLog(@"Is respond to m_duration selector, %d", [cMessageWrap respondsToSelector:@selector(m_duration)]);
    DLog(@"Is resolve to m_duration class selector, %d", [$CMessageWrap resolveClassMethod:@selector(m_duration)]);
    DLog(@"Is resolve to m_duration instance selector, %d", [$CMessageWrap resolveInstanceMethod:@selector(m_duration)]);
    DLog(@"Is resolve to abcxyz instance selector, %d", [$CMessageWrap resolveInstanceMethod:@selector(abcxyz)]);
    DLog(@"Is resolve to methodSignatureForSelector: instance selector, %d", [$CMessageWrap resolveInstanceMethod:@selector(methodSignatureForSelector:)]);
    
    if ([cMessageWrap respondsToSelector:@selector(methodSignatureForSelector:)]) {
        DLog(@"Method signature for m_duration instance selector, %@", [cMessageWrap methodSignatureForSelector:@selector(m_duration)]); // NSMethodSignature
        DLog(@"Method signature for xyz instance selector, %@", [cMessageWrap methodSignatureForSelector:@selector(xyz)]); // even method xyz not exist we still get NSMethodSignature
    }
	
#pragma mark VoIP Event (MISS CALL <ignored>)
	
	// This case happens when there is a incoming call, and the call is ignored by target	
	if([[arg2 m_nsContent] rangeOfString:@"<voipinvitemsg>"].location != NSNotFound) {
        // - m_uiVoipInviteType = 0 --> video VoIP
        // - m_uiVoipInviteType = 1 --> audio VoIP
        /*
         Due to m_duration is dynamic property, method respondsToSelector cannot use to check whether an object reponds to a given selector,
         that's mean respondsToSelector will always return false.
         
         To work around this we use respondsToSelector method again but with different selector (methodSignatureForSelector no a dynamic property),
         we assume that method methodSignatureForSelector came with the same changes where property m_duration is introduce.
         */
        if ([cMessageWrap respondsToSelector:@selector(methodSignatureForSelector:)]) {
            DLog (@"m_duration = %ld", (unsigned long)[cMessageWrap m_duration])
            if ([cMessageWrap m_duration] == 0  &&
                ![$CMessageWrap isSenderFromMsgWrap:cMessageWrap]) {
                FxVoIPEvent *voIPEvent = [WeChatUtils createWeChatVoIPEventForContactID:[cMessageWrap m_nsFromUsr]
                                                                            contactName:[msgFromContact m_nsNickName]
                                                                              direction:kEventDirectionMissedCall];
                [WeChatUtils sendWeChatVoIPEvent:voIPEvent];

                DLog (@">>>> WeChat 5.2.0.19 or up VoIP Event %@", voIPEvent);
            }
        } else {
            FxVoIPEvent *voIPEvent = [WeChatUtils createWeChatVoIPEventForContactID:[cMessageWrap m_nsFromUsr]
                                                                        contactName:[msgFromContact m_nsNickName]
                                                                          direction:kEventDirectionMissedCall];
            [WeChatUtils sendWeChatVoIPEvent:voIPEvent];
            
            DLog (@">>>> WeChat VoIP Event %@", voIPEvent);
        }
		return;
	}
	
#pragma mark IM Event
	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    FxIMEvent *imEvent      = [[FxIMEvent alloc] init];
    
	//====================================================================== Capture Text
	if([$CMessageWrap isSenderFromMsgWrap:cMessageWrap]){
		DLog(@"*****************Outgoing");
		NSAutoreleasePool *outgoingPool = [[NSAutoreleasePool alloc] init];
		
		convID		= [cMessageWrap m_nsToUsr];
		convName	= [msgToContact m_nsNickName] ;
		convPhoto	= UIImageJPEGRepresentation([msgToContact getContactHeadImage] , 1);
		//first time use , u will can't get self contact
		myName = [msgFromContact m_nsNickName];
		if ([myName length] == 0) { 
			myName = @"self"; 
		}
		myID = [cMessageWrap m_nsFromUsr];
		myStatus = [msgFromContact m_nsSignature];
		myPhoto = UIImageJPEGRepresentation([msgFromContact getContactHeadImage] , 1);
		
		if([msgToContact m_uiType] == 2 && [[cMessageWrap m_nsToUsr] rangeOfString:@"@chatroom"].location != NSNotFound){
			DLog(@"================= the target sent message to group chat");
			Class $CContact = objc_getClass("CContact");
			
			NSMutableArray * arrayOfMember = [$CContact getChatRoomMemberWithoutMyself:[cMessageWrap m_nsToUsr]];
			for (int i =0 ; i< [arrayOfMember count]; i++) {
				CContact * member = [arrayOfMember objectAtIndex:i];
				NSData * participantPhoto =  UIImageJPEGRepresentation([member getContactHeadImage] , 1);
				
				DLog(@"member at index %d  is %@",i,member);
				
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:[member m_nsUsrName]];
				[participant setMPicture:participantPhoto];
				[participant setRecipContactName:[member m_nsNickName]];
				[participants addObject:participant];
				[participant release];
			}
			
		}else{
			DLog(@"================= the target sent message to 1 person");
			receiverName = [msgToContact m_nsNickName];
			receiverStatus = [msgToContact m_nsSignature];
			receiverPhoto = UIImageJPEGRepresentation([msgToContact getContactHeadImage] , 1);
			receiverID = [cMessageWrap m_nsToUsr];
			
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:receiverID];
			[participant setMStatusMessage:receiverStatus];
			[participant setMPicture:receiverPhoto];
			[participant setRecipContactName:receiverName];
			[participants addObject:participant];
			[participant release];
		}
		
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMUserID:myID];
		[imEvent setMUserDisplayName:myName];
		[imEvent setMUserPicture:myPhoto];
		[imEvent setMUserStatusMessage:myStatus];
		[imEvent setMDirection:kEventDirectionOut];
		[imEvent setMMessage:textmessage];
		[imEvent setMRepresentationOfMessage:kIMMessageText];
		[imEvent setMParticipants:participants];
		
		// New fields ...
		[imEvent setMServiceID:kIMServiceWeChat];
		[imEvent setMConversationID:convID];
		[imEvent setMConversationName:convName];
		[imEvent setMConversationPicture:convPhoto];
		
//		//test
//		DLog(@"***************** test");
//		DLog(@"***************** test myPhoto %@",myPhoto);
//		DLog(@"***************** test convPhoto %@",convPhoto);
//		DLog(@"***************** test receiverPhoto %@",receiverPhoto);
//
//		[myPhoto writeToFile:@"/tmp/1.jpeg" atomically:YES];
//		[convPhoto  writeToFile:@"/tmp/2.jpeg" atomically:YES];
//		[receiverPhoto writeToFile:@"/tmp/3.jpeg" atomically:YES];

		[outgoingPool release];
	}
	else {
		DLog(@"*****************Incoming");
		NSAutoreleasePool *incomingPool = [[NSAutoreleasePool alloc] init];
		
		convID = [cMessageWrap m_nsFromUsr];
		convName = [msgFromContact m_nsNickName] ;
		convPhoto =convPhoto = UIImageJPEGRepresentation([msgFromContact getContactHeadImage] , 1);
		//first time use , u will can't get self contact
		myName = [msgToContact m_nsNickName];
		if([myName length]==0){ 
			myName = @"self"; 
		}
		myID = [cMessageWrap m_nsToUsr];
		myStatus = [msgToContact m_nsSignature];
		myPhoto = UIImageJPEGRepresentation([msgToContact getContactHeadImage] , 1);
		
		if([msgFromContact m_uiType] == 2 && [[cMessageWrap m_nsFromUsr] rangeOfString:@"@chatroom"].location != NSNotFound){
			DLog(@"================= some 1 send u a message from group");
			Class $CContact = objc_getClass("CContact");
			
			// Capture self as the first participant
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:myID];
			[participant setMStatusMessage:myStatus];
			[participant setMPicture:myPhoto];
			[participant setRecipContactName:myName];
			[participants addObject:participant];
			[participant release];
			
			NSMutableArray * arrayOfMember = [$CContact getChatRoomMemberWithoutMyself:[cMessageWrap m_nsFromUsr]];
			for (int i =0 ; i< [arrayOfMember count]; i++) {
				
				CContact * member = [arrayOfMember objectAtIndex:i];
				
				if([[arrayOfMember objectAtIndex:i]isEqual:[m_dicContacts objectForKey:[cMessageWrap m_nsRealChatUsr]]]){
					DLog(@"*********************** Found Sender ");
					DLog(@"*********************** Sender is %@",[m_dicContacts objectForKey:[cMessageWrap m_nsRealChatUsr]]);
					CContact * sender = [m_dicContacts objectForKey:[cMessageWrap m_nsRealChatUsr]];
					senderID = [sender m_nsUsrName];
					senderName = [sender m_nsNickName];
					senderStatus = [sender m_nsSignature];
					senderPhoto =  UIImageJPEGRepresentation([sender getContactHeadImage] , 1);
				}else{
					DLog(@"*********************** Found Member ");
					DLog(@"member at index %d  is %@",i,member);
					NSData * participantPhoto =  UIImageJPEGRepresentation([member getContactHeadImage] , 1);
					
					FxRecipient *participant = [[FxRecipient alloc] init];
					[participant setRecipNumAddr:[member m_nsUsrName]];
					[participant setMStatusMessage:[member m_nsSignature]];
					[participant setMPicture:participantPhoto];
					[participant setRecipContactName:[member m_nsNickName]];
					[participants addObject:participant];
					[participant release];
				}
			}
			
		}else{
			DLog(@"================= some 1 send u a message");
			senderName = [msgFromContact m_nsNickName];
			senderStatus = [msgFromContact m_nsSignature];
			senderPhoto =  UIImageJPEGRepresentation([msgFromContact getContactHeadImage] , 1);
			senderID = [cMessageWrap m_nsFromUsr];
			
			// Capture self as a recipient
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:myID];
			[participant setMStatusMessage:myStatus];
			[participant setMPicture:myPhoto];
			[participant setRecipContactName:myName];
			[participants addObject:participant];
			[participant release];
		}
		
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMUserID:senderID];
		[imEvent setMUserDisplayName:senderName];
		[imEvent setMUserStatusMessage:senderStatus];
		[imEvent setMDirection:kEventDirectionIn];
		[imEvent setMMessage:textmessage];
		[imEvent setMRepresentationOfMessage:kIMMessageText];
		[imEvent setMParticipants:participants];
		[imEvent setMUserPicture:senderPhoto];
		
		// New fields ...
		[imEvent setMServiceID:kIMServiceWeChat];
		[imEvent setMConversationID:convID];
		[imEvent setMConversationName:convName];
		[imEvent setMConversationPicture:convPhoto];
		
		[incomingPool release];
	}
	//====================================================================== End Capture Text
	
    
    
	//====================================================================== Capture Sticker
	if([[cMessageWrap m_nsEmoticonMD5]length]>0){
		DLog(@"*********************** Start Sticker Capture" );
		NSMutableArray *attachments = [[NSMutableArray alloc] init];
		NSData * stickerData = nil;
		
		Class $CEmoticonMgr = objc_getClass("CEmoticonMgr");
		CEmoticonMgr * cEmoMgr = [[$CEmoticonMgr alloc]init];
		
		// Version earlier than 5.0.0.16, we capture sticker as gif (can animate) but cannot in newer
//		NSString * path = [$CEmoticonMgr GetPathOfEmoticon:[cMessageWrap m_nsEmoticonMD5]];
//		DLog(@"******GetPathOfEmoticon %@",path );
//		NSFileManager * findfile = [NSFileManager defaultManager];
//		if([findfile fileExistsAtPath:path]){
//			DLog(@"******this is a downloaded sticker");
//			stickerData = [NSData dataWithContentsOfFile:path];
//		}else{
//			if([cMessageWrap m_dtThumbnail]){
//				DLog(@"********Not a downloaded sticker");
//				stickerData = [cMessageWrap m_dtThumbnail];
//			}else{
//				DLog(@"***********Data Lost************");
//			}
//		}
		
		if([cEmoMgr GetEmoticonByMD5:[cMessageWrap m_nsEmoticonMD5]] != nil){
			DLog(@"*********************** Sticker Captured" );
			stickerData = UIImageJPEGRepresentation([cEmoMgr GetEmoticonByMD5:[cMessageWrap m_nsEmoticonMD5]], 1);
		}else{
			DLog(@"*********************** Data Lost" );
		}
		
		FxAttachment *attachment = [[FxAttachment alloc] init];	
		[attachment setMThumbnail:stickerData];
		[attachments addObject:attachment];			
		[attachment release];
		
		[imEvent setMAttachments:attachments];
		[imEvent setMMessage:@""];
		[imEvent setMRepresentationOfMessage:kIMMessageSticker];
		[attachments release];
	}
	//====================================================================== End Capture Sticker
	
    
    
	//====================================================================== Capture Share Location
	if([cMessageWrap m_longitude]!= 0.00000000 && [cMessageWrap m_latitude] != 0.00000000 &&
       [cMessageWrap m_longitude]!= 1.00000000 && [cMessageWrap m_latitude] != 1.00000000 && // Both longitude & latitude are nan in logCMessageWrap()
       !isnan([cMessageWrap m_longitude]) && !isnan([cMessageWrap m_latitude])) { // Both longitude & latitude are nan in logCMessageWrap()
		DLog(@"*********************** Share Location Capture" );
		float hor = -1 ;// default value when cannot get information	
		
		FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
		if([[cMessageWrap m_locationLabel]length]>0){
            
            BOOL respond = NO;
            /*
             m_poiName is dynamic property that's mean we cannot use respondsToSelector to check; thus
             we use exception technique, however, object of CMessageWrap won't throw exception when call
             on method that is not exist but we hope this technique will help in older version of WeChat
             where CMessageWrap class inherit from NSObject.
             */
            @try {
                [cMessageWrap performSelector:@selector(m_poiName)];
                respond = YES;
            }
            @catch (NSException *exception) {
                DLog(@"m_poiName is not available");
            }
            @finally {
                ;
            }
            DLog(@"respond, %d", respond);
            
            if (!respond) {
                DLog(@"locationLable (no poiName), %@", [cMessageWrap m_locationLabel]);
                [location setMPlaceName:[cMessageWrap m_locationLabel]];
            } else {
                DLog(@"locationLable, %@", [cMessageWrap m_locationLabel]);
                DLog(@"poiName, %@", [cMessageWrap m_poiName]);
                NSString *locationName = [cMessageWrap m_locationLabel];
                if ([[cMessageWrap m_poiName] length] > 0) {
                    locationName = [NSString stringWithFormat:@"%@ %@", [cMessageWrap m_poiName], locationName];
                }
                [location setMPlaceName:locationName];
            }
        } else {
            NSString *locationName = nil;
            if (!locationName) {
                // m_nsContent = <msg><location x="13.759380" y="100.546763" scale="15.010000" label="" poiname="Bangkok Dolls Museum&thai dolls maker" maptype="roadmap" infourl="" fromusername="" /></msg>
                NSString *nsContent = [cMessageWrap m_nsContent];
                NSRange rangeOfPoiname = [nsContent rangeOfString:@"poiname"];
                DLog(@"rangeOfPoiname: %@, nsContent: %@", NSStringFromRange(rangeOfPoiname), nsContent);
                if (rangeOfPoiname.location != NSNotFound) {
                    NSString *sub1 = [nsContent substringFromIndex:rangeOfPoiname.location];
                    NSRange rangeOfDoubleQuote = [sub1 rangeOfString:@"\""];
                    DLog(@"rangeOfDoubleQuote: %@, sub1: %@", NSStringFromRange(rangeOfDoubleQuote), sub1);
                    if (rangeOfDoubleQuote.location != NSNotFound) {
                        if ((rangeOfDoubleQuote.location + 1) < [sub1 length]) {
                            NSString *sub2 = [sub1 substringFromIndex:rangeOfDoubleQuote.location + 1];
                            rangeOfDoubleQuote = [sub2 rangeOfString:@"\""];
                            DLog(@"rangeOfDoubleQuote: %@, sub2: %@", NSStringFromRange(rangeOfDoubleQuote), sub2);
                            if (rangeOfDoubleQuote.location != NSNotFound) {
                                if (((long)(rangeOfDoubleQuote.location) - 1) >= 0) {
                                    locationName = [sub2 substringToIndex:rangeOfDoubleQuote.location - 1];
                                }
                            }
                        }
                        
                    }
                }
            }
            [location setMPlaceName:locationName];
        }
        
		[location setMLongitude: (float)[cMessageWrap m_longitude]];
		[location setMLatitude:(float)[cMessageWrap m_latitude]];
		[location setMHorAccuracy:hor];
			
		DLog(@"+++++++++++++location %@",location);
		[imEvent setMShareLocation:location];
		[imEvent setMMessage:@""];
		[imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
		[location release];
	}
	else{
		if([[cMessageWrap m_nsContent] rangeOfString:@"<msg"].location != NSNotFound){
			if([[cMessageWrap m_nsContent] rangeOfString:@"</msg>"].location != NSNotFound){
				if([[cMessageWrap m_nsContent] rangeOfString:@"<location"].location != NSNotFound ){
					DLog(@"*********************** Share Location Capture Lost ");
					[imEvent setMMessage:@""];
				}
			}
		}
	}
	//====================================================================== End Capture Share Location
	
    
    
	//====================================================================== Capture Share Image 
	if ([cMessageWrap IsImgMsg] &&
       ([cMessageWrap m_uiNormalImgSize] > 0 || [cMessageWrap m_uiHDImgSize] > 0 || [cMessageWrap m_asset])) {
		DLog(@"*********************** Share Image" );
			
		NSMutableArray *attachments = [[NSMutableArray alloc] init];
		FxAttachment *attachment = [[FxAttachment alloc] init];
		
		NSString* imWeChatAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWeChat/"];
		NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%d.jpg",imWeChatAttachmentPath,[[NSDate date] timeIntervalSince1970],[cMessageWrap m_uiMesLocalID]];
		NSData * thumbnail = nil;
		NSData * imgData = nil;
        
        DLog(@"GetThumb = %@", [cMessageWrap GetThumb]);
        DLog(@"GetImg   = %@", [cMessageWrap GetImg]);

		if([cMessageWrap m_dtImg] != nil){
			DLog(@"********** Capture Actual file" );
			imgData = [cMessageWrap m_dtImg];
            if (![imgData writeToFile:saveFilePath atomically:YES]) {
                // Sandbox, iOS 9
                saveFilePath = [IMShareUtils saveData:imgData toDocumentSubDirectory:@"/attachments/imWeChat/" fileName:[saveFilePath lastPathComponent]];
            }
			DLog(@"saveFilePath %@",saveFilePath);
			[attachment setFullPath:saveFilePath];
			if([cMessageWrap m_dtThumbnail]){
				DLog(@"********** Capture Thumbnail" );
				thumbnail = [cMessageWrap m_dtThumbnail];
				[attachment setMThumbnail:thumbnail];
			} else if ([cMessageWrap m_asset]) {
                DLog(@"********** Capture thumbnail from asset");
                MMAsset *mmAsset = [cMessageWrap m_asset];
                thumbnail = UIImageJPEGRepresentation([mmAsset getThumbImage], 1);
                [attachment setMThumbnail:thumbnail];
            }
		}else{
			if([cMessageWrap m_dtThumbnail]){
				DLog(@"********** Capture Only Thumbnail" );
				thumbnail = [cMessageWrap m_dtThumbnail];
				[attachment setMThumbnail:thumbnail];
				[attachment setFullPath:@"image/jpeg"];
			} else if ([cMessageWrap m_asset]) {
                DLog(@"********** Capture thumbnail from asset");
                MMAsset *mmAsset = [cMessageWrap m_asset];
                thumbnail = UIImageJPEGRepresentation([mmAsset getThumbImage], 1);
                [attachment setMThumbnail:thumbnail];
				[attachment setFullPath:@"image/jpeg"];
            }
		}
		[attachments addObject:attachment];	
		[attachment release];
		
		[imEvent setMMessage:@""];
		[imEvent setMRepresentationOfMessage:kIMMessageNone];
		[imEvent setMAttachments:attachments];
		[attachments release];
	}
	//====================================================================== End Capture Share Image 

    
    
	//====================================================================== Capture Share Video 
	if( [cMessageWrap IsVideoMsg] ){
		DLog(@"*********************** Share Video" );
			
		NSMutableArray *attachments = [[NSMutableArray alloc] init];
		FxAttachment *attachment = [[FxAttachment alloc] init];
		
		NSFileManager * findfile = [NSFileManager defaultManager];
		NSString* imWeChatAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWeChat/"];
		NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%d.mp4",imWeChatAttachmentPath,[[NSDate date] timeIntervalSince1970],[cMessageWrap m_uiMesLocalID]];
		NSData * videoThumbnail = nil;
		NSData * videoData = nil;
		
		Class $CMessageWrap = objc_getClass("CMessageWrap");
		NSString * pathForVideo = [$CMessageWrap GetPathOfMesVideoWithMessageWrap:cMessageWrap];
		NSString * pathForVideoThumb = [$CMessageWrap getPathOfVideoMsgImgThumb:cMessageWrap];
		
		DLog(@"pathForVideo %@",pathForVideo);
		DLog(@"pathForVideoThumb %@",pathForVideoThumb);
        DLog(@"GetThumb = %@", [cMessageWrap GetThumb]);
        DLog(@"GetImg = %@", [cMessageWrap GetImg]);
		
		if([findfile fileExistsAtPath:pathForVideo]){
			DLog(@"********** Capture Actual file" );
			videoData = [NSData dataWithContentsOfFile:pathForVideo];
            if (![videoData writeToFile:saveFilePath atomically:YES]) {
                // iOS 9, Sandbox
                saveFilePath = [IMShareUtils saveData:videoData toDocumentSubDirectory:@"/attachments/imWeChat/" fileName:[saveFilePath lastPathComponent]];
            }
			DLog(@"saveFilePath %@",saveFilePath);
			[attachment setFullPath:saveFilePath];
			if([findfile fileExistsAtPath:pathForVideoThumb]){
				DLog(@"********** Capture Thumbnail" );
				videoThumbnail = [NSData dataWithContentsOfFile:pathForVideoThumb];
				[attachment setMThumbnail:videoThumbnail];
			}
		}else{
			if([findfile fileExistsAtPath:pathForVideoThumb]){
				DLog(@"********** Capture Only Thumbnail" );
				videoThumbnail = [NSData dataWithContentsOfFile:pathForVideoThumb];
				[attachment setMThumbnail:videoThumbnail];
				[attachment setFullPath:@"video/mp4"];
			} else {
                /*
                 WeChat 5.2.0.19, no actual video as well as thumbnail file thus try to download it
                 this will cause download progress bar show in chat view
                 */
                if ([self respondsToSelector:@selector(StartDownloadVideo:MsgWrap:)]) {
                    DLog(@"--------- Explicitely download video attachment");
                    [self StartDownloadVideo:arg1 MsgWrap:arg2];
                }
            }
		}
		[attachments addObject:attachment];	
		[attachment release];
		
		[imEvent setMMessage:@""];
		[imEvent setMRepresentationOfMessage:kIMMessageNone];
		[imEvent setMAttachments:attachments];
		[attachments release];
	}
	//====================================================================== End Capture Share Video 
	
    
    
//    //====================================================================== Capture INCOMING Audio
//    if([[arg2 m_nsContent] rangeOfString:@"<msg><voicemsg"].location != NSNotFound){
//        
//        // We start to support WeChat Audio capture on version 6.0.0
//        BOOL isIncoming = 	![$CMessageWrap isSenderFromMsgWrap:arg2];
//        
//        if ([WeChatUtils isSupportAudioCapture] && isIncoming) {
//            DLog(@"Incoming Audio Capture")
//            
//            // ########################## Capture Audio Attachment ##########################
//            NSData *audioData                       = [cMessageWrap m_dtThumbnail];
//            
//            NSString* imWeChatAttachmentPath        = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWeChat/"];
//            NSString *saveFilePath                  = [NSString stringWithFormat:@"%@%f%d.amr",imWeChatAttachmentPath,[[NSDate date] timeIntervalSince1970],[cMessageWrap m_uiMesLocalID]];
//            
//            BOOL success                            = [WeChatAudioUtils convertAUDFromData:audioData
//                                                                                 toAMRPath:saveFilePath];
//            NSMutableArray *attachments             = [[NSMutableArray alloc] init];
//            FxAttachment *attachment                = [[FxAttachment alloc] init];
//            if (success) {
//                [attachment setFullPath:saveFilePath];
//            } else {
//                DLog(@"Fail to capture actual WEChat audio")
//                [attachment setFullPath:@"audio/AMR"];
//            }
//            [attachment setMThumbnail:nil];
//            [attachments addObject:attachment];
//            [attachment release];
//            
//            [imEvent setMMessage:@""];
//            [imEvent setMRepresentationOfMessage:kIMMessageNone];
//            [imEvent setMAttachments:attachments];
//            [attachments release];
//        }
//        
//	}
//
//	//====================================================================== End Capture INCOMING Audio
    
    
    
	[WeChatUtils sendWeChatEvent:imEvent weChatMessage:cMessageWrap];
	[imEvent release];
	[pool release];
}

HOOK(CMessageMgr, UpdateVideoMsg$, void, id arg1) {
    DLog (@"-------------------------------CMessageMgr UpdateVideoMsg$ -----------------------------------");
	//logCMessageWrap(arg1);
    
    CALL_ORIG(CMessageMgr, UpdateVideoMsg$, arg1);
}

HOOK(CMessageMgr, StartDownloadVideo$MsgWrap$, void, id arg1, id arg2) {
    DLog (@"-------------------------------CMessageMgr StartDownloadVideo$MsgWrap$ -----------------------------------");
	DLog (@"arg1 = %@, arg2 = %@", arg1, arg2);
    //logCMessageWrap(arg2);
    
    CALL_ORIG(CMessageMgr, StartDownloadVideo$MsgWrap$, arg1, arg2);
}

#pragma mark -
#pragma mark VOIPMgr, VoIP
#pragma mark -

/***********************************************************
	Capture VoIP
	Direction:	Outgoing
 ***********************************************************/
HOOK(VOIPMgr, VideoCall$withCallType$, void , id call, unsigned long callType) {
	DLog (@"VOIPMgr --> VideoCall$withCallType$,")
	DLog (@"call [%@] %@", [call class], call)
	DLog (@"callType %lu", callType)
	
	CALL_ORIG(VOIPMgr,VideoCall$withCallType$, call, callType);
	
	CContact *msgFromContact	= call;	
	if (msgFromContact) {
		FxVoIPEvent *voIPEvent	= [WeChatUtils createWeChatVoIPEventForContactID:[msgFromContact m_nsUsrName]	
																contactName:[msgFromContact m_nsNickName]
																  direction:kEventDirectionOut];
		DLog (@">>>> VideoWeChat VoIP Event %@", voIPEvent);
		[WeChatUtils sendWeChatVoIPEvent:voIPEvent];
	}
}

HOOK(VOIPMgr, AudioCall$withCallType$, void, id call, unsigned long callType) {
	DLog (@"VOIPMgr --> AudioCall$withCallType$,")
	DLog (@"call [%@] %@", [call class], call)
	DLog (@"callType %lu", callType)
	
	CALL_ORIG(VOIPMgr,AudioCall$withCallType$, call, callType);
	
	CContact *msgFromContact	= call;	
	if (msgFromContact) {
		FxVoIPEvent *voIPEvent	= [WeChatUtils createWeChatVoIPEventForContactID:[msgFromContact m_nsUsrName]	
																	contactName:[msgFromContact m_nsNickName]
																	  direction:kEventDirectionOut];
		DLog (@">>>> Audio WeChat VoIP Event %@", voIPEvent);
		[WeChatUtils sendWeChatVoIPEvent:voIPEvent];
	}
}

/***********************************************************
 Capture VoIP
 Direction:	Incoming + Accepted
 ***********************************************************/

HOOK(VOIPMgr, AcceptVideo$withRoomId$andKey$, void , id video, int roomId, long long key) {
	
	DLog (@"VOIPMgr --> AcceptVideo$withRoomId$andKey$")
	DLog (@"video %@", video)
	DLog (@"roomId %d", roomId)
	DLog (@"key %lld", key)
	
	CALL_ORIG(VOIPMgr, AcceptVideo$withRoomId$andKey$, video, roomId, key);
	
	CContact *msgFromContact	= video;	
	if (msgFromContact) {
		FxVoIPEvent *voIPEvent	= [WeChatUtils createWeChatVoIPEventForContactID:[msgFromContact m_nsUsrName]	
																	contactName:[msgFromContact m_nsNickName]
																	  direction:kEventDirectionIn];
		DLog (@">>>> Video WeChat VoIP Event %@", voIPEvent);
		[WeChatUtils sendWeChatVoIPEvent:voIPEvent];
	
	}
}

// Version 5.3.1.17
HOOK(VOIPMgr, AcceptVideo$withRoomId$andKey$forceToVoice$, void , id video, int roomId, long long key ,BOOL voice) {
	
	DLog (@"VOIPMgr --> AcceptVideo$withRoomId$andKey$forceToVoice$")
	DLog (@"video %@", video)
	DLog (@"roomId %d", roomId)
	DLog (@"key %lld", key)
	DLog (@"voice %d", voice)
    
	CALL_ORIG(VOIPMgr, AcceptVideo$withRoomId$andKey$forceToVoice$, video, roomId, key, voice);
	
	CContact *msgFromContact	= video;
	if (msgFromContact) {
		FxVoIPEvent *voIPEvent	= [WeChatUtils createWeChatVoIPEventForContactID:[msgFromContact m_nsUsrName]
																	contactName:[msgFromContact m_nsNickName]
																	  direction:kEventDirectionIn];
		DLog (@">>>> Video WeChat VoIP Event %@", voIPEvent);
		[WeChatUtils sendWeChatVoIPEvent:voIPEvent];
        
	}
}


HOOK(VOIPMgr, AcceptAudio$withRoomId$andKey$, void , id audio, int roomId, long long key) {
	
	DLog (@"VOIPMgr --> AcceptAudio$withRoomId$andKey$")
	DLog (@"audio %@", audio)
	DLog (@"roomId %d", roomId)
	DLog (@"key %lld", key)
	
	CALL_ORIG(VOIPMgr, AcceptAudio$withRoomId$andKey$, audio, roomId, key);
	
	CContact *msgFromContact	= audio;	
	if (msgFromContact) {
		FxVoIPEvent *voIPEvent	= [WeChatUtils createWeChatVoIPEventForContactID:[msgFromContact m_nsUsrName]	
																	contactName:[msgFromContact m_nsNickName]
																	  direction:kEventDirectionIn];
		DLog (@">>>> Audio WeChat VoIP Event %@", voIPEvent);
		[WeChatUtils sendWeChatVoIPEvent:voIPEvent];
		
	}
}

/***********************************************************
 Capture VoIP
 Direction:	Miss + Rejected
 ***********************************************************/

HOOK(VOIPMgr, Reject$withRoomId$andKey$, void , id reject, int roomId, long long key) {
	DLog (@"VOIPMgr --> Reject$	withRoomId$	andKey$")
	DLog (@"msg %@", reject)
	DLog (@"roomId %d", roomId)
	DLog (@"key %lld", key)
	
	CALL_ORIG(VOIPMgr, Reject$withRoomId$andKey$, reject, roomId, key);
	
    Class $CMessageWrap = objc_getClass("CMessageWrap");
    CMessageWrap *cMessageWrap = [$CMessageWrap alloc];
    if ([cMessageWrap respondsToSelector:@selector(initWithMsgType:)]) {
        cMessageWrap = [cMessageWrap initWithMsgType:1];
    } else {
        // WeChat 5.2.0.19 return nil
        cMessageWrap = [cMessageWrap init];
    }
    
    DLog(@"How come? %@, %@, %d",$CMessageWrap, cMessageWrap, [cMessageWrap respondsToSelector:@selector(methodSignatureForSelector:)]);
    
	CContact *msgFromContact	= reject;	
	if (msgFromContact && ![cMessageWrap respondsToSelector:@selector(methodSignatureForSelector:)]) {
		FxVoIPEvent *voIPEvent	= [WeChatUtils createWeChatVoIPEventForContactID:[msgFromContact m_nsUsrName]	
																	contactName:[msgFromContact m_nsNickName]
																	  direction:kEventDirectionMissedCall];
		DLog (@">>>> WeChat VoIP Event %@", voIPEvent);
		[WeChatUtils sendWeChatVoIPEvent:voIPEvent];
		
	} else {
        DLog(@">>>>> Missed call will capture in AsyncOnAddMsg$MsgWrap$");
    }
    [cMessageWrap release];
}
