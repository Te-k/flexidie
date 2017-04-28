//
//  MediaEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEvent.h"

@class FxCallTag;
@class FxGPSTag;

@class ThumbnailEvent;

@interface MediaEvent : FxEvent <NSCoding> {
@protected
	NSString*		fullPath;
	NSInteger		mDuration;			// New field
	NSMutableArray*	thumbnailEventArray;
    
    FxCallTag*		mCallTag;
    FxGPSTag*		mGPSTag;
}

@property (nonatomic, copy) NSString* fullPath;
@property (nonatomic, assign) NSInteger mDuration;
@property (nonatomic, retain) FxCallTag* mCallTag;
@property (nonatomic, retain) FxGPSTag* mGPSTag;

- (BOOL) hasThumbnails;
- (NSArray*) thumbnailEvents;
- (void) addThumbnailEvent: (ThumbnailEvent*) thumbnail;

@end
