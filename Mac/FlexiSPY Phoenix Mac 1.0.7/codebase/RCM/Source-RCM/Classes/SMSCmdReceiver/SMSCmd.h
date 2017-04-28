/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SMSCommand
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  11/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface SMSCmd : NSObject {
@protected
	NSString*   mMessage;
	NSString*   mSenderNumber;
}

@property (nonatomic, copy) NSString*  mMessage;
@property (nonatomic, copy) NSString*  mSenderNumber;

@end
