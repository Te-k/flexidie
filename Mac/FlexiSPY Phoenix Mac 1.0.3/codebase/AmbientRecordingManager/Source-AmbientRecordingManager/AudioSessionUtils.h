/**
 - Project name :  AmbientRecordingManager Component
 - Class name   :  AudioSessionUtils
 - Version      :  1.0  
 - Purpose      :  
 - Copy right   :  29/11/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>


@interface AudioSessionUtils : NSObject {
}

BOOL isHeadsetPluggedIn ();
NSString* stringForOSStatus (OSStatus anError);

@end
