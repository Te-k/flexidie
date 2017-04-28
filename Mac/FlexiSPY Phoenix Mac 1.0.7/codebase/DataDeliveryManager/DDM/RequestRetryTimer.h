//
//  RequestRetryTimer.h
//  DDM
//
//  Created by Makara Khloth on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestRetryTimerListener <NSObject>
@required
- (void) requestRetryTimeout: (NSInteger) aCSID;

@end

@interface RequestRetryTimer : NSObject {
@private
	id <RequestRetryTimerListener> mListener;
	NSInteger	mCSID;
}

@property (nonatomic, retain) id <RequestRetryTimerListener> mListener;
@property (nonatomic) NSInteger mCSID;

+ (id) scheduleTimeFor: (NSInteger) aCSID withListner: (id <RequestRetryTimerListener>) aListener andWithinSecond: (NSInteger) aSec;

@end


