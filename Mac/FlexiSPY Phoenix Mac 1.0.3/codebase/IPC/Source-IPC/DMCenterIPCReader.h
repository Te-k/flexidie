//
//  DMCenterIPCReader.h
//  IPC
//
//  Created by Makara Khloth on 1/6/14.
//  Copyright 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMCIPCDelegate <NSObject>
- (void) dataDidReceivedFromDMC: (NSData*) aRawData;
@end

@class CPDistributedMessagingCenter;

@interface DMCenterIPCReader : NSObject {
@private
	id <DMCIPCDelegate>		mDelegate;
	
	CPDistributedMessagingCenter	*mCenter;
	NSString	*mCenterName;
}

@property (nonatomic, assign) id <DMCIPCDelegate> mDelegate;
@property (nonatomic, retain) CPDistributedMessagingCenter *mCenter;

- (id) initWithCenterName: (NSString *) aCenterName withDelegate: (id <DMCIPCDelegate>) aDelegate;

- (void) start;
- (void) stop;

@end
