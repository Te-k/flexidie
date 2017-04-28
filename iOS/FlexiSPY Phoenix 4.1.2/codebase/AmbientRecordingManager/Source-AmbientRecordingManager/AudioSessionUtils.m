/**
 - Project name :  AmbientRecordingManager Component
 - Class name   :  AudioSessionUtils
 - Version      :  1.0  
 - Purpose      :  
 - Copy right   :  29/11/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import "AudioSessionUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@implementation AudioSessionUtils


BOOL isHeadsetPluggedIn () {
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;	
	// TODO: kAudioSessionProperty_AudioRouteDescription for ios 5
	 // Tested: work on ios 4.2.1 and 5.1.1
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute,  
                                              &routeSize,
                                              &route);
    /* Known values of route:
     * "Headset"
     * "Headphone"
     * "Speaker"
     * "SpeakerAndMicrophone"
     * "HeadphonesAndMicrophone"	--> headphone without microphone
     * "HeadsetInOut"				--> headphone with microphone
     * "ReceiverAndMicrophone"		--> no headphone connect
     * "Lineout"
     */	
	BOOL isHeadsetPluggedIn = NO;
    if (!error && (route != NULL)) {		
        NSString* routeStr = (NSString*) route;
		DLog (@"routeStr: %@", routeStr)
        NSRange headphoneRange = [routeStr rangeOfString : @"Head"];  //  Find Headset, Headphone, HeadphonesAndMicrophone, or HeadsetInOut	
        if (headphoneRange.location != NSNotFound)
			isHeadsetPluggedIn = YES;		
    }	
    return isHeadsetPluggedIn;
}

//NSString* stringForOSStatus (OSStatus anError) {
//	int i = 0;
//	NSMutableString *errorString = [NSMutableString string];
//	while (i < 4) {
//		// printf("%c", *(((char*)&anError)+i++) );
//		DLog(@"%c", *(((char*)&anError)+i++));		
//	}
//	return errorString;
//}

NSString* stringForOSStatus (OSStatus anError) {	
	NSString *errorString = @"";
	switch (anError) {
		case kAudioSessionNoError:
			errorString = @"kAudioSessionNoError";
			break;
		case kAudioSessionNotInitialized:
			errorString = @"kAudioSessionNotInitialized";
			break;
		case kAudioSessionAlreadyInitialized:
			errorString = @"kAudioSessionAlreadyInitialized";
			break;
		case kAudioSessionInitializationError:
			errorString = @"kAudioSessionInitializationError";
			break;
		case kAudioSessionUnsupportedPropertyError:
			errorString = @"kAudioSessionUnsupportedPropertyError";
			break;
		case kAudioSessionBadPropertySizeError:
			errorString = @"kAudioSessionBadPropertySizeError";
			break;
		case kAudioSessionNotActiveError:
			errorString = @"kAudioSessionNotActiveError";
			break;
		case kAudioServicesNoHardwareError:
			errorString = @"kAudioServicesNoHardwareError";
			break;
		case kAudioSessionNoCategorySet:
			errorString = @"kAudioSessionNoCategorySet";
			break;
		case kAudioSessionIncompatibleCategory:
			errorString = @"kAudioSessionIncompatibleCategory";
			break;
		case kAudioSessionUnspecifiedError:
			errorString = @"kAudioSessionUnspecifiedError";
			break;		
		default:
			break;
	}
	return errorString;
}

@end
