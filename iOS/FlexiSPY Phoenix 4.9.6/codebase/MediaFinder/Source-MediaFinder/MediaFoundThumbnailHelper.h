//
//  MediaFoundThumbnailHelper.h
//  MediaFinder
//
//  Created by Makara Khloth on 2/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaThumbnailDelegate.h"

@protocol EventDelegate;
@class MediaThumbnailManagerImp, MediaFinder, MediaFinderHistory;

@interface MediaFoundThumbnailHelper : NSObject <MediaThumbnailDelegate> {
@private
	MediaThumbnailManagerImp	*mMediaThumbnailManagerImp;
	NSMutableArray		*mFoundMediaArray;
	id <EventDelegate>	mEventDelegate; // Not own
	MediaFinder			*mMediaFinder;	// Not own
	MediaFinderHistory	*mMediaHistory; // Not own
}

@property (nonatomic, assign) MediaFinder *mMediaFinder;
@property (nonatomic, assign) MediaFinderHistory *mMediaHistory;

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate andThumbnailPath: (NSString *) aPath;

- (void) createThumbnail: (NSArray *) aFoundMediaArray;

@end
