//
//  FxThumbnailEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEvent.h"

/*
 Design note: Media event contains thumbnail events, always access thumbnail events via media event
 */

@interface FxThumbnailEvent : FxEvent <NSCoding> {
@protected
	NSString    *fullPath;
	NSUInteger	actualSize;
	NSUInteger	actualDuration;
	NSUInteger	pairId;
}

@property (nonatomic, copy) NSString *fullPath;
@property (nonatomic, assign) NSUInteger actualSize;
@property (nonatomic, assign) NSUInteger actualDuration;
@property (nonatomic, assign) NSUInteger pairId;

@end
