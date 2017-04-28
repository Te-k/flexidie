//
//  ThumbnailEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEvent.h"

@class FxCallTag;
@class FxGPSTag;

@interface ThumbnailEvent : FxEvent <NSCoding> {
@protected
	NSString*	fullPath;
	NSUInteger	actualSize;
	NSUInteger	actualDuration;
	NSUInteger	pairId;
    
    FxCallTag*  mCallTag;
    FxGPSTag*   mGPSTag;
}

@property (nonatomic, copy) NSString* fullPath;
@property (nonatomic, assign) NSUInteger actualSize;
@property (nonatomic, assign) NSUInteger actualDuration;
@property (nonatomic, assign) NSUInteger pairId;
@property (nonatomic, retain) FxCallTag* mCallTag;
@property (nonatomic, retain) FxGPSTag* mGPSTag;

@end
