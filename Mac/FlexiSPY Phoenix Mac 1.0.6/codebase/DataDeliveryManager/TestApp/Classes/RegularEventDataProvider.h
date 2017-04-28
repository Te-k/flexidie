//
//  RegularEventDataProvider.h
//  TestApp
//
//  Created by Makara Khloth on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataProvider.h"

@interface RegularEventDataProvider : NSObject <DataProvider> {
@private
	NSInteger	mEventLeft;
}

- (id) commandData;

@end
