/**
 - Project name :  SystemUtils Component
 - Class name   :  SystemUtilsImpl
 - Version      :  1.0  
 - Purpose      :  For SystemUtils Component
 - Copy right   :  19/12/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "SystemUtilsImpl.h"
#import <sys/utsname.h>
#import <mach/mach.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "DefStd.h"
#import "DeviceConstant.h"

#if TARGET_OS_IPHONE
#else
#import <AppKit/AppKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "ScreenshotUtils.h"
#endif

static int system_no_deprecation(const char *command) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    return system(command);
#pragma GCC diagnostic pop
}

@interface SystemUtilsImpl (private)
+ (NSString *)machineModel;
@end

@implementation SystemUtilsImpl

- (NSUInteger) getSysInfo: (uint) typeSpecifier {
	size_t size			= sizeof(uint64_t); 
	uint64_t results		= 0;	
	int mib[2]			= {CTL_HW, typeSpecifier}; 	
	sysctl(mib, 2, &results, &size, NULL, 0);	
	return (NSUInteger) results;
}
- (NSUInteger) getSysInfoIntByName:(char *) typeSpecifier {
	// -- Get size first	
	size_t size		= 0; 
	sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);			
	uint64_t result	= 0;		
	sysctlbyname(typeSpecifier, &result, &size, NULL, 0);
	return  result;
}


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


#pragma mark -
#pragma mark CPU


// uint64
- (NSUInteger) cpuFrequency {	
	#if !TARGET_OS_IPHONE	
		// https://developer.apple.com/library/mac/releasenotes/General/APIDiffsMacOSX10_8/Kernel.html
		//return [SystemUtilsImpl getSysInfo:HW_CPU_FREQ]; // removed in OSX 10.8
		return [self getSysInfoIntByName:"hw.cpufrequency"];
	#else	
		return 0;
	#endif		
}


#if TARGET_OS_IPHONE
#else

- (double) cpuFrequencyInGigabyte {	
	NSUInteger cpuFreqInByte		= [self cpuFrequency]; 
	NSNumber *cpuFreqInByteNumber	= [NSNumber numberWithUnsignedInt:cpuFreqInByte]; 	
	double cpuFreqFloat				= [cpuFreqInByteNumber doubleValue]/1000000000;
	return cpuFreqFloat;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (BOOL) isOSX_VersionEqualOrGreaterMajorVersion:(SInt32)aMajor minorVersion:(SInt32)aMinor {
    BOOL isEqualOrGreater = NO;
    
    SInt32 OSXversionMajor = 0, OSXversionMinor = 0;
    if(Gestalt(gestaltSystemVersionMajor, &OSXversionMajor) == noErr &&
       Gestalt(gestaltSystemVersionMinor, &OSXversionMinor) == noErr) {
        if(OSXversionMajor >= aMajor && OSXversionMinor >= aMinor) {
            isEqualOrGreater = YES;
        }
    }
    
    return isEqualOrGreater;
}
#pragma GCC diagnostic pop

+ (BOOL) isOSX_10_11 {
    NSString *version = [self OSXVersion];
    return ([version rangeOfString:@"10.11"].location != NSNotFound);
}

+ (BOOL) isOSX_10_10 {
    NSString *version = [self OSXVersion];
    return ([version rangeOfString:@"10.10"].location != NSNotFound);
}

+ (BOOL) isOSX_10_9 {
    NSString *version = [self OSXVersion];
    return ([version rangeOfString:@"10.9"].location != NSNotFound);
}

+ (NSString *) userLogonName {
    uid_t uid = 0;
    gid_t gid = 0;
    NSString *username =  (NSString *)SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid);
    return ([username autorelease]);
}

+ (NSString *) frontApplicationID {
#if __MAC_OS_X_VERSION_MAX_ALLOWED < 101100
    NSString *activeBundleID = [[[NSWorkspace sharedWorkspace]activeApplication] objectForKey:@"NSApplicationBundleIdentifier"];
#else
    NSString *activeBundleID = [[[NSWorkspace sharedWorkspace] frontmostApplication] bundleIdentifier];
#endif
    return (activeBundleID);
}

+ (NSString *) frontApplicationName {
#if __MAC_OS_X_VERSION_MAX_ALLOWED < 101100
    NSString *activeAppName = [[[NSWorkspace sharedWorkspace]activeApplication] objectForKey:@"NSApplicationName"];
#else
    NSString *activeAppName = [[[NSWorkspace sharedWorkspace] frontmostApplication] localizedName];
#endif
    return (activeAppName);
}

+ (NSString *) frontApplicationWindowTitle {
#if __MAC_OS_X_VERSION_MAX_ALLOWED < 101100
    NSNumber *activeAppPID = [[[NSWorkspace sharedWorkspace]activeApplication] objectForKey:@"NSApplicationProcessIdentifier"];
#else
    NSNumber *activeAppPID = [NSNumber numberWithInteger:[[[NSWorkspace sharedWorkspace] frontmostApplication] processIdentifier]];
#endif
    NSString *title = [self frontApplicationWindowTitleWithPID:activeAppPID];
    if (!title || [title length] == 0) {
        title = [self frontApplicationName];
        DLog(@"Get front window title from front application name, %@", title);
    }
    return (title);
}

+ (NSString *) frontApplicationWindowTitleWithPID: (NSNumber *) aPID {
    NSString *title=[ScreenshotUtils frontWindowTitleWithPID:aPID];
    if (!title) {
        DLog(@"Get front window title using window list");
        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
        NSArray *windows = CFBridgingRelease(windowList);
        for (int i=0; i< [(NSArray *)windowList count]; i++) {
            NSDictionary * windowDict  = [(NSArray *)windows objectAtIndex:i];
            //DLog(@"windowDict = %@", windowDict);
            NSNumber *windowPID = [windowDict objectForKey:@"kCGWindowOwnerPID"];
            if ([aPID isEqualToNumber:windowPID]) {
                title = [windowDict objectForKey:@"kCGWindowName"];
                break;
            }
        }
    }
    return (title);
}

+ (NSString *) applicationIDWithPID: (NSNumber *) aPID {
    NSRunningApplication *rApp = [NSRunningApplication runningApplicationWithProcessIdentifier:[aPID integerValue]];
    NSString *bundleID = rApp.bundleIdentifier;
    return bundleID;
}

+ (NSString *) applicationNameWithPID: (NSNumber *) aPID {
    NSRunningApplication *rApp = [NSRunningApplication runningApplicationWithProcessIdentifier:[aPID integerValue]];
    NSString *localizedName = rApp.localizedName;
    return localizedName;
}

+ (NSImage *) takeScreenshotFrontWindow {
    return ([ScreenshotUtils takeFrontWindowShot]);
}

+ (NSImage *) takeScreenshotFrontWindowWithBundleID: (NSString *) aBundleID {
    return ([ScreenshotUtils takeFrontWindowShotWithBundleID:aBundleID]);
}

+ (NSImage *) takeScreenshotFrontWindowWithBundleIDUsingAppleScript: (NSString *) aBundleID {
    return ([ScreenshotUtils takeFrontWindowShotWithBundleIDUsingAppleScript:aBundleID]);
}

+ (NSImage *) takeFocusedWindowShotWithBundleID: (NSString *) aBundleID {
    return [ScreenshotUtils takeFocusedWindowShotWithBundleID:aBundleID];
}

+ (NSImage *) takeScreenshotFrontAllWindows {
    return ([ScreenshotUtils takeFrontAllWindowsShot]);
}

+ (NSImage *) takeScreenshotWithBundleID: (NSString *) aBundleID windowID: (NSNumber *) aWindowID {
    return ([ScreenshotUtils takeWindowShotWithBundleID:aBundleID windowID:aWindowID]);
}

+ (NSImage *) takeScreenshot {
    return ([ScreenshotUtils takeScreenShot]);
}

+ (NSArray *) takeScreenshots {
    return ([ScreenshotUtils takeScreenShots]);
}

+ (NSNumber *) frontApplicationPID {
    NSNumber *pid = nil;
    
    /*
    NSArray *runningApps = [[NSWorkspace sharedWorkspace ] runningApplications];
    for (NSRunningApplication *runningApp in runningApps) {
        if ([runningApp isActive]) {
            pid = [NSNumber numberWithInteger:[runningApp processIdentifier]];
            break;
        }
    }*/
    
    NSRunningApplication *rApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    pid = [NSNumber numberWithInteger:rApp.processIdentifier];
    
    return (pid);
}

+ (CGRect) frontmostWindowRectWithPID: (NSNumber *) aPID {
    return ([ScreenshotUtils frontmostWindowRectWithPID:aPID]);
}

+ (CGRect) windowRectWithWindowID: (NSNumber *) aWindowID {
    return ([ScreenshotUtils windowRectWithWindowID:aWindowID]);
}

#endif


#pragma mark -
#pragma mark Memory


- (NSUInteger) totalMemory {	
	#if !TARGET_OS_IPHONE
		return [self getSysInfo:HW_MEMSIZE];
	#else
		return 0;
	#endif	
}

- (NSUInteger) userMemory {
	#if !TARGET_OS_IPHONE
		return [self getSysInfo:HW_USERMEM];
	#else
		return 0;
	#endif	
}


#pragma mark -
#pragma mark Bus and Socket


- (NSUInteger) busFrequency {	
	#if !TARGET_OS_IPHONE
		return [self getSysInfo:HW_BUS_FREQ];
	#else
		return 0;
	#endif	
}

- (NSUInteger) maxSocketBufferSize {
	#if !TARGET_OS_IPHONE
		return [self getSysInfo:KIPC_MAXSOCKBUF];
	#else
		return 0;
	#endif	
}


#pragma mark -
#pragma mark Disk


- (NSNumber *) totalDiskSpace {
	//#if !TARGET_OS_IPHONE
		NSError *error						= nil;
		NSDictionary* fileAttributes		= [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/"
																								error:&error];	
		NSNumber *freeDisk					= nil;
		if (!error) {
			//DLog (@"fileAttributes %@", fileAttributes)
			unsigned long long freeSpace	= [[fileAttributes objectForKey:NSFileSystemSize] longLongValue];
			freeDisk						= [NSNumber numberWithLongLong:freeSpace];
		}		
		return freeDisk;	
	//#else
	//	return 0;
	//#endif	
}
- (NSNumber *) freeDiskSpace {
	//#if !TARGET_OS_IPHONE
		NSError *error						= nil;
		NSDictionary* fileAttributes		= [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/"
																								error:&error];	
		NSNumber *totalDisk					= nil;
		if (!error) {
			//DLog (@"fileAttributes %@", fileAttributes)
			unsigned long long space		= [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
			totalDisk						= [NSNumber numberWithLongLong:space];
		}		
		return totalDisk;
	//#else
	//	return 0;
	//#endif	
}

- (float) cpuUsage {
	DLog(@"CPU usage . . . . . . .");
	
	#if !TARGET_OS_IPHONE
		return 0;			
	#else 
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
	#endif
}


#pragma mark -
#pragma mark Device Model


+ (NSString *) deviceModel {
	struct utsname systemInfo;
    uname(&systemInfo);
	
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString *) deviceModelVersion {
	NSString *deviceModelVersion = [NSString string];
	
	#if TARGET_OS_IPHONE
		NSString *deviceModel = [SystemUtilsImpl deviceModel];
		
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
		} else if ([deviceModel isEqualToString:kIphone53]  ||
                   [deviceModel isEqualToString:kIphone54]) {
            deviceModelVersion = @"iPhone 5c";
        } else if ([deviceModel isEqualToString:kIphone61]  ||
                   [deviceModel isEqualToString:kIphone62]) {
            deviceModelVersion = @"iPhone 5s";
        } else if ([deviceModel isEqualToString:kIphone72]) {
            deviceModelVersion = @"iPhone 6";
        } else if ([deviceModel isEqualToString:kIphone71]) {
            deviceModelVersion = @"iPhone 6 Plus";
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
		} else if ([deviceModel isEqualToString:kIpad41] ||
                   [deviceModel isEqualToString:kIpad42] ||
                   [deviceModel isEqualToString:kIpad43]) {
            deviceModelVersion = @"iPad Air";
        } else if ([deviceModel isEqualToString:kIpad53] ||
				   [deviceModel isEqualToString:kIpad54]) {
            deviceModelVersion = @"iPad Air 2";
        } else if ([deviceModel isEqualToString:kIpad25] ||
				   [deviceModel isEqualToString:kIpad26] ||
				   [deviceModel isEqualToString:kIpad27]) {
			deviceModelVersion = @"iPad mini";
		} else if ([deviceModel isEqualToString:kIpad44] ||
                   [deviceModel isEqualToString:kIpad45] ||
                   [deviceModel isEqualToString:kIpad46]) {
            deviceModelVersion = @"iPad mini 2";
        } else if ([deviceModel isEqualToString:kIpad47] ||
                   [deviceModel isEqualToString:kIpad48] ||
                   [deviceModel isEqualToString:kIpad49]) {
            deviceModelVersion = @"iPad mini 3";
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
		} else if ([deviceModel isEqualToString:kiPhoneSimulator]) {
			deviceModelVersion = @"iPhone Simulator";
		} else if ([deviceModel isEqualToString:kiPadSimulator]) {
			deviceModelVersion = @"iPad Simulator";
		}
		DLog (@"Device model is = %@, device model version = %@", deviceModel, deviceModelVersion);
    #else
        NSString *machineModel = [[self machineModel] lowercaseString];
        if ([machineModel rangeOfString:@"imac"].location != NSNotFound) {
            deviceModelVersion = @"iMac";
        } else if ([machineModel rangeOfString:@"mac mini"].location != NSNotFound) {
            deviceModelVersion = @"Mac mini";
        } else if ([machineModel rangeOfString:@"macbook air"].location != NSNotFound) {
            deviceModelVersion = @"MacBook Air";
        } else if ([machineModel rangeOfString:@"macbook pro"].location != NSNotFound) {
            deviceModelVersion = @"MacBook Pro";
        } else if ([machineModel rangeOfString:@"mac pro"].location != NSNotFound) {
            deviceModelVersion = @"Mac Pro";
        }
	#endif

	return deviceModelVersion;
}

+ (NSString *) deviceIOSVersion {
	#if TARGET_OS_IPHONE
		return ([NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]]);
	#else
		return (@"Mac OS X");
	#endif
}


/**
 - Method name:			deviceIOSMainVersion:
 - Purpose:				This method is used to get the main iOS verison.
						Example: This function return 6 for iOS version 6.1.2
								 This function return 5 for iOS version 5.1.1 
 - Argument list and description: Version string
 - Return description:	main iOS version
 */
+ (NSString *) deviceIOSMainVersion {	
	#if TARGET_OS_IPHONE
		NSString *iosVersion		= [[UIDevice currentDevice] systemVersion];	
		NSArray *versionComponents	= [iosVersion componentsSeparatedByString:@"."];
		DLog (@"versionComponents %@", versionComponents)
		NSString *majorString		= nil;	
		if ([versionComponents count] > 0)		// major
			majorString		= [versionComponents objectAtIndex:0];		
		DLog (@"majorString %@", majorString)		
		return (majorString);	
	#else
		return [NSString string];
	#endif
}

/**
 - Method name: restartDevice
 - Purpose:This method is used to restart the device
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) restartDevice {
	system_no_deprecation("reboot");
}

/**
 - Method name: killProcessWithProcessName
 - Purpose:This method is used to restart the device
 - Argument list and description: aProcessName(NSString *) 
 - Return description: No Return Type
*/

-(void) killProcessWithProcessName:(NSString *) aProcessName {
	NSString *script=[NSString stringWithFormat:@"killall %@",aProcessName];
	system_no_deprecation([script cStringUsingEncoding:NSUTF8StringEncoding]);
}

+ (BOOL) isIphone {
	#if TARGET_OS_IPHONE
		return [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"];
	#else	
		return NO;
	#endif	
}

+ (BOOL) isIpodTouch {
	#if TARGET_OS_IPHONE
		return [[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"];
	#else
		return NO;
	#endif
}

+ (BOOL) isIpad {
	#if TARGET_OS_IPHONE
		return [[[UIDevice currentDevice] model] isEqualToString:@"iPad"];
	#else	
		return NO;
	#endif
}

+ (BOOL) isOSXDevice {
	if (!TARGET_OS_IPHONE) {
		return YES;
	} else {
		return NO;
	}

}

+ (NSString *) OSXVersion {
#if TARGET_OS_IPHONE
    return nil;
#else
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    DLog(@"OS X: %@", [processInfo operatingSystemVersionString]);  // Version 10.10.2 (Build 14C1510)
    //DLog(@"OS X: %@", [processInfo operatingSystemName]);           // NSMACHOperatingSystem
    return [processInfo operatingSystemVersionString];
#endif
}

+ (NSString *) getCPUType
{
#if TARGET_OS_IPHONE
    NSMutableString *cpu = [[NSMutableString alloc] init];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);
    
    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);
    
    // values for cputype and cpusubtype defined in mach/machine.h
    if (type == CPU_TYPE_X86)
    {
        [cpu appendString:@"x86 "];
        
    } else if (type == CPU_TYPE_ARM)
    {
        [cpu appendString:@"ARM"];
        switch(subtype)
        {
            case CPU_SUBTYPE_ARM_V7:
                [cpu appendString:@"V7"];
                break;
            case CPU_SUBTYPE_ARM_V7S:
                [cpu appendString:@"V7S"];
                break;
            default:
                break;
        }
    }
    else if (type == CPU_TYPE_ARM64)
    {
        [cpu appendString:@"ARM64"];
    }
    DLog(@"CPU arch type = %@", cpu);
    return [cpu autorelease];
#else
    return nil;
#endif
}

+ (BOOL) isCPU64Type {
    NSString *cpuType = [self getCPUType];
    return ([cpuType isEqualToString:@"ARM64"]);
}

+ (NSString *)machineModel
{
    size_t length = 0;
    sysctlbyname("hw.model", NULL, &length, NULL, 0);
    if (length) {
        char *m = malloc(length * sizeof(char));
        sysctlbyname("hw.model", m, &length, NULL, 0);
        NSString *model = [NSString stringWithUTF8String:m];
        free(m);
        return model;
    }
    return @"Unknown model";
}

@end
