/**
 - Project name :  CallLogCapture 
 - Class name   :  CallLog
 - Version      :  1.0  
 - Purpose      :  For Call Log Capturing Component
 - Copy right   :  30/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@interface CallLog : NSObject {
@protected	
	NSString *mContactNumber;
	FxEventDirection mCallState;
	NSUInteger mDuration;
	NSUInteger mCallHistoryROWID;
    NSInteger mContactID;
}

@property (nonatomic,copy) NSString *mContactNumber;
@property (nonatomic, assign) FxEventDirection mCallState;
@property (nonatomic, assign) NSUInteger mDuration;
@property (nonatomic, assign) NSUInteger mCallHistoryROWID;
@property (nonatomic, assign) NSInteger mContactID;

@end
