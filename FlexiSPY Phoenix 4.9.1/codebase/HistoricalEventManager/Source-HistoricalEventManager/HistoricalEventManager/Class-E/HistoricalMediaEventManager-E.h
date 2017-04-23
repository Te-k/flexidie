//
//  HistoricalMediaEventManager.h
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 1/6/2558 BE.
//
//

#import <Foundation/Foundation.h>

#import "MediaThumbnailDelegate.h"


@class MediaThumbnailManagerImp;


@interface HistoricalMediaEventManager : NSObject  <MediaThumbnailDelegate> {
    id                      mDelegate;				// not own
    SEL                     mOPCompletedSelector;	// not own
    
    NSMutableArray          *mMediaThumbnailArray;
    NSInteger               mAllMediaCount;
    NSInteger               mProcessedMediaCount;
}

@property (retain) MediaThumbnailManagerImp  *mMediaThumbnailManagerImp;

@property (retain) NSMutableArray            *mMediaThumbnailArray;
@property (assign) NSInteger                 mAllMediaCount;
@property (assign) NSInteger                 mProcessedMediaCount;

- (id) initWithDelegate: (id) aDelegate
               selector: (SEL) aSelector;

// This function will be call by subclasses of HistoricalEventMediaOP
- (void) searchOperationCompleted: (NSDictionary *) aData;

@end
