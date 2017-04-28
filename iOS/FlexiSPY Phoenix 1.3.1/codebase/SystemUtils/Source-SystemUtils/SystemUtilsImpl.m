/**
 - Project name :  SystemUtils Component
 - Class name   :  SystemUtilsImpl
 - Version      :  1.0  
 - Purpose      :  For SystemUtils Component
 - Copy right   :  19/12/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "SystemUtilsImpl.h"
#import <sys/utsname.h>
#import <UIKit/UIDevice.h>
#import <mach/mach.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "DefStd.h"
#import "DeviceConstant.h"

@implementation SystemUtilsImpl

/**
 - Method name: getRunnigProcess
 - Purpose:This method is used to get getRunnigProcess
 - Argument list and description: No Argument
 - Return description: array (NSArray)
*/

- (NSArray *) getRunnigProcess {
	
	int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
	size_t miblen = 4;
	
	size_t size;
	int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
	
	struct kinfo_proc * process = NULL;
	struct kinfo_proc * newprocess = NULL;
	
    do {
		
        size += size / 10;
        newprocess = realloc(process, size);
		
        if (!newprocess){
			
            if (process){
                free(process);
            }
			
            return nil;
        }
		
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
		
    } while (st == -1 && errno == ENOMEM);
	
	if (st == 0){
		
		if (size % sizeof(struct kinfo_proc) == 0){
			int nprocess = size / sizeof(struct kinfo_proc);
			
			if (nprocess){
				
				NSMutableArray * array = [[NSMutableArray alloc] init];
				
				for (int i = nprocess - 1; i >= 0; i--){
					
					NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
					NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
					
					NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil] 
																		forKeys:[NSArray arrayWithObjects:kRunningProcessIDTag,kRunningProcessNameTag,nil]];
					[processID release];
					[processName release];
					[array addObject:dict];
					[dict release];
				}
				
				free(process);
				return [array autorelease];
			}
		}
	}
	
	return nil;
}

- (NSUInteger) cpuFrequency {
	return 0;
}
- (NSUInteger) busFrequency {	
	return 0;
}
- (NSUInteger) totalMemory {
	return 0;
}
- (NSUInteger) userMemory {
	return 0;
}
- (NSUInteger) maxSocketBufferSize {
	return 0;
}
- (NSNumber *) totalDiskSpace {
	return 0;
}
- (NSNumber *) freeDiskSpace {
	return 0;
}

- (float) cpuUsage {
	DLog(@"CPU usage . . . . . . .");
	
	// For CPU usage of current process
	/*
	kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
	
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
	
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
	
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
	
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
	
    basic_info = (task_basic_info_t)tinfo;
	
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
	
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
	
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
		
        basic_info_th = (thread_basic_info_t)thinfo;
		
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
		
    } // for each thread
	
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
	 */
	
	// For CPU usage of overall processes
	kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
	
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
	
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
	
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
	
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
	
    basic_info = (task_basic_info_t)tinfo;
	
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
	
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
	
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
		
        basic_info_th = (thread_basic_info_t)thinfo;
		
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
		
    } // for each thread
	
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    //assert(kr == KERN_SUCCESS);
	
	DLog(@"Total CPU usage recently = %f", tot_cpu);
    return tot_cpu;
}

+ (NSString *) deviceModel {
	struct utsname systemInfo;
    uname(&systemInfo);
	
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString *) deviceModelVersion {
	NSString *deviceModel = [SystemUtilsImpl deviceModel];
	NSString *deviceModelVersion = [NSString string];
	if ([deviceModel isEqualToString:kIphone3G]) {
		deviceModelVersion = @"iPhone 3G";
	} else if ([deviceModel isEqualToString:kIphone3GS]) {
		deviceModelVersion = @"iPhone 3GS";
	} else if ([deviceModel hasPrefix:@"iPhone3"]) {
		deviceModelVersion = @"iPhone 4";
	/*
	else if ([deviceModel isEqualToString:kIphone4]) {
		deviceModelVersion = @"iPhone 4";
	} else if ([deviceModel isEqualToString:kIphone4_1]) {
		deviceModelVersion = @"iPhone 4";
	} else if ([deviceModel isEqualToString:kIphone4_2]) {
		deviceModelVersion = @"iPhone 4";
	} 
	*/	
	} else if ([deviceModel hasPrefix:@"iPhone4"]) {
		deviceModelVersion = @"iPhone 4S";
	/*
	else if ([deviceModel isEqualToString:kIphone4S]) {
		deviceModelVersion = @"iPhone 4S";
	*/
	} else if ([deviceModel isEqualToString:kIphone51] ||
			   [deviceModel isEqualToString:kIphone52]) {
		deviceModelVersion = @"iPhone 5";
	} else if ([deviceModel isEqualToString:kIpad]) {
		deviceModelVersion = @"iPad 1";
	} else if ([deviceModel isEqualToString:kIpad21] ||
			   [deviceModel isEqualToString:kIpad22] ||
			   [deviceModel isEqualToString:kIpad23] ||
			   [deviceModel isEqualToString:kIpad24]) {
		deviceModelVersion = @"iPad 2";
	} else if ([deviceModel isEqualToString:kIpad31] ||
			   [deviceModel isEqualToString:kIpad32] ||
			   [deviceModel isEqualToString:kIpad33]) {
		deviceModelVersion = @"iPad 3G";
	} else if ([deviceModel isEqualToString:kIpad34] ||
			   [deviceModel isEqualToString:kIpad35] ||
			   [deviceModel isEqualToString:kIpad36]) {
		deviceModelVersion = @"iPad 4G";
	} else if ([deviceModel isEqualToString:kIpad25] ||
			   [deviceModel isEqualToString:kIpad26] ||
			   [deviceModel isEqualToString:kIpad27]) {
		deviceModelVersion = @"iPad Mini";
	} else if ([deviceModel isEqualToString:kIpodTouch]) {
		deviceModelVersion = @"iPod Touch 1G";
	} else if ([deviceModel isEqualToString:kIpodTouch2nd]) {
		deviceModelVersion = @"iPod Touch 2G";
	} else if ([deviceModel isEqualToString:kIpodTouch3rd]) {
		deviceModelVersion = @"iPod Touch 3G";
	} else if ([deviceModel isEqualToString:kIpodTouch4th]) {
		deviceModelVersion = @"iPod Touch 4G";
	} else if ([deviceModel isEqualToString:kIpodTouch5th]) {
		deviceModelVersion = @"iPod Touch 5G";
	}
	DLog (@"Device model is = %@, device model version = %@", deviceModel, deviceModelVersion);
	return deviceModelVersion;
}

+ (NSString *) deviceIOSVersion {
	return ([NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]]);
}

/**
 - Method name: restartDevice
 - Purpose:This method is used to restart the device
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) restartDevice {
	system("reboot");
}

/**
 - Method name: killProcessWithProcessName
 - Purpose:This method is used to restart the device
 - Argument list and description: aProcessName(NSString *) 
 - Return description: No Return Type
*/

-(void) killProcessWithProcessName:(NSString *) aProcessName {
	NSString *script=[NSString stringWithFormat:@"killall %@",aProcessName];
	system([script cStringUsingEncoding:NSUTF8StringEncoding]);
}

+ (BOOL) isIphone {
	return [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"];
}

+ (BOOL) isIpodTouch {
	return [[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"];
}

+ (BOOL) isIpad {
	return [[[UIDevice currentDevice] model] isEqualToString:@"iPad"];
}

@end
