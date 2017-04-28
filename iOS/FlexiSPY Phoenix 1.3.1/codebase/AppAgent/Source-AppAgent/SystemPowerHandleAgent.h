/** 
 - Project name: AppAgent
 - Class name: SystemPowerHandleAgent
 - Version: 1.0
 - Purpose: 
 - Copy right: 31/05/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>


@interface SystemPowerHandleAgent : NSObject {
@private
	NSThread	*mSystemPowerCallbackThread;
	NSRunLoop	*mSystemPowerCallbackRunLoop; // Not own
	BOOL		mIsListening;
}

@property (assign) BOOL mIsListening;

- (id) init;

- (void) start;
- (void) stop;

@end
