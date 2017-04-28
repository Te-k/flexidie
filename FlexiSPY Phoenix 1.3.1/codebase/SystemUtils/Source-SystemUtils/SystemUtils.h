/**
 - Project name :  SystemUtils Component
 - Class name   :  SystemUtils
 - Version      :  1.0  
 - Purpose      :  For SystemUtils Component
 - Copy right   :  19/12/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>

@protocol SystemUtils <NSObject>
@optional
//Get All Running Process
- (NSArray *) getRunnigProcess;
//Kill Current sRunning Process
- (void) killProcessWithProcessName:(NSString *) aProcessName;
//To Resatart Device
- (void)  restartDevice;
- (NSUInteger) cpuFrequency;
- (NSUInteger) busFrequency;
- (NSUInteger) totalMemory;
- (NSUInteger) userMemory;
- (NSUInteger) maxSocketBufferSize;
- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpace;
- (float) cpuUsage;
+ (NSString *) deviceModel;
+ (NSString *) deviceModelVersion;
+ (NSString *) deviceIOSVersion;

+ (BOOL) isIphone;
+ (BOOL) isIpodTouch;
+ (BOOL) isIpad;


@end
