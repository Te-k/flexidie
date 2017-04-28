//
//  DMCenterIPCSender.h
//  IPC
//
//  Created by Makara Khloth on 1/6/14.
//  Copyright 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPDistributedMessagingCenter;

@interface DMCenterIPCSender : NSObject {
@private
	CPDistributedMessagingCenter	*mCenter;
	NSString	*mCenterName;
}

@property (nonatomic, retain) CPDistributedMessagingCenter *mCenter;

- (id) initWithCenterName: (NSString*) aCenterName;
- (BOOL) writeDataToCenter: (NSData*) aRawData;

@end
