//
//  PCMMixer.h
//
//  Created by Binh Nguyen (c) Killer Mobile Software
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioFile.h>


#define OSSTATUS_MIX_WOULD_CLIP 8888


@interface PCMMixer : NSObject {

}

+ (OSStatus) mixFiles:(NSArray*)files atTimes:(NSArray*)times toMixfile:(NSString*)mixfile duration:(long *)duration;

@end
