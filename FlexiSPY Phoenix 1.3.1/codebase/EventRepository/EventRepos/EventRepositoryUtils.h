//
//  EventRepositoryUtils.h
//  EventRepos
//
//  Created by Makara Khloth on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@interface EventRepositoryUtils : NSObject {

}

// It's used in thumbnail fetcher to interpolate between actual media and thumbnail type
+ (FxEventType) mapMediaToThumbnailEventType: (FxEventType) aMediaEventType;
+ (FxEventType) mapThumbnailToMediaEventType: (FxEventType) aThumbnailEventType;

@end
