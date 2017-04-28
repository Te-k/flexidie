//
//  RequestScheduler.h
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DeliveryRequest;

@interface RequestScheduler : NSObject {
@private
	NSArray*	mRequestQueue;
}

+ (DeliveryRequest*) scheduleRequest: (NSArray*) aRequestQueue;

@end
