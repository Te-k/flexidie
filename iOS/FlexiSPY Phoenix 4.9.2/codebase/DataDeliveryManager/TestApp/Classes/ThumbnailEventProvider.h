//
//  ThumbnailEventProvider.h
//  TestApp
//
//  Created by Makara Khloth on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataProvider.h"

@interface ThumbnailEventProvider : NSObject <DataProvider> {
@private
	NSInteger	mEventLeft;
}

- (id) commandData;

@end
