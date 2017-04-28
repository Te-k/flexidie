/**
 - Project name :  SMSCapture Maanager 
 - Class name   :  SMSCaptureManager
 - Version      :  1.0  
 - Purpose      :  For SMS Capturing Component
 - Copy right   :  28/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/


#import <Foundation/Foundation.h>
#import "EventDelegate.h"
#import "AppContext.h"

@class SMSNotifier;
@class SMSCaptureUtils;

@interface SMSCaptureManager : NSObject {
@private
	// For creating an instance of SocketIPCReader
	id <EventDelegate>      mEventDelegate;
	id <AppContext>			mAppContext;
	
	NSMutableArray		*mSMSEventPool;
}

@property (nonatomic, assign) id <AppContext> mAppContext;

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate;
- (void)captureSMS;

// -- Historical SMS

+ (NSArray *) allSMSs;
+ (NSArray *) allSMSsWithMax: (NSInteger) aMaxNumber;
+ (void)clearCapturedData;

@end
