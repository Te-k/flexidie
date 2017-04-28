//
//  FxIMEventUtils.h
//  FxEvents
//
//  Created by Makara Khloth on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxIMEvent;

@interface FxIMEventUtils : NSObject {
@private
    NSUInteger mAudioAttMaxSize;
    NSUInteger mVideoAttMaxSize;
    NSUInteger mImageAttMaxSize;
    NSUInteger mOtherAttMaxSize;
}

@property (nonatomic, assign) NSUInteger mAudioAttMaxSize;
@property (nonatomic, assign) NSUInteger mVideoAttMaxSize;
@property (nonatomic, assign) NSUInteger mImageAttMaxSize;
@property (nonatomic, assign) NSUInteger mOtherAttMaxSize;

+ (id) sharedFxIMEventUtils;

+ (NSArray *) digestIMEvent: (FxIMEvent *) aIMEvent;

@end
