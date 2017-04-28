//
//  FxMediaEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEvent.h"

@class FxCallTag,FxVoIPCallTag;
@class FxGPSTag;

@class FxThumbnailEvent;

/*
 Design note: Media event contains thumbnail events, always access thumbnail events via media event
 */

@interface FxMediaEvent : FxEvent <NSCoding> {
@protected
	NSString        *fullPath;
	NSInteger		mDuration;			// New field
	NSMutableArray  *thumbnailEventArray;
    
    FxCallTag       *mCallTag;
    FxVoIPCallTag   *mVoIPCallTag;
    FxGPSTag        *mGPSTag;
}

@property (nonatomic, copy) NSString *fullPath;
@property (nonatomic, assign) NSInteger mDuration;
@property (nonatomic, retain) FxCallTag *mCallTag;
@property (nonatomic, retain) FxVoIPCallTag *mVoIPCallTag;
@property (nonatomic, retain) FxGPSTag *mGPSTag;

- (BOOL) hasThumbnails;
- (NSArray *) thumbnailEvents;
- (void) addThumbnailEvent: (FxThumbnailEvent *) thumbnail;

@end
