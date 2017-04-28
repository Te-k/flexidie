//
//  MediaHistoryDAO.h
//  MediaFinder
//
//  Created by Makara Khloth on 9/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MediaFinderHistory;

@interface MediaHistoryDAO : NSObject {
@private
	MediaFinderHistory	*mMediaHistory; // Not own
}

- (id) initWithMediaHistory: (MediaFinderHistory *) aMediaHistory;

- (BOOL) isMediaInHistory: (NSString *) aMediaPath size: (NSUInteger) aMediaSize;
- (void) insertMediaIntoHistory: (NSString *) aMediaPath size: (NSUInteger) aMediaSize;
- (void) clearMediaHistory;

@end
