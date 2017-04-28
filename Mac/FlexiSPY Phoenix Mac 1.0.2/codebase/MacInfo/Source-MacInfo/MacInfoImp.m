//
//  MacInfoImp.m
//  MacInfo
//
//  Created by vervata on 9/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MacInfoImp.h"
#import <SystemConfiguration/SystemConfiguration.h>


#include <sys/sysctl.h>

// Path
static NSString* const kVarSysInfoPath				= @"/System/Library/CoreServices/SystemVersion.plist";
static NSString* const kVarSysInfoMachineType		= @"/System/Library/CoreServices/Resources/SPMachineTypes.plist";

// Key
static NSString* const kVarSysInfoKeyModel			= @"hw.model";
static NSString* const kVarSysInfoKeyMachine		= @"hw.machine";

static NSString* const kPlatformExpert				= @"IOPlatformExpertDevice";

// Machine Names
static NSString* const kVarSysInfoMachineiMac		= @"iMac";
static NSString* const kVarSysInfoMachineMacmini    = @"Mac mini";
static NSString* const kVarSysInfoMachineMacBookAir = @"MacBook Air";
static NSString* const kVarSysInfoMachineMacBookPro = @"MacBook Pro";
static NSString* const kVarSysInfoMachineMacPro     = @"Mac Pro";


@interface MacInfoImp (private)

// Utilities
+ (NSString *) strIORegistryEntry:(NSString *)registryKey;
+ (NSString *) modelNameFromID: (NSString *) modelID;
+ (NSString *) getModelCode;

+ (NSString *) getSysInfoByName:(char *)typeSpecifier;

@end


@implementation MacInfoImp

#pragma mark -
#pragma mark PhoneInfo Protocol

-(NSString*) getIMEI {
	return [self getUUID];
}

-(NSString*) getDeviceModel {
	return [self getModelName];
}

-(NSString*) getDeviceInfo {
	NSString *value = [NSString stringWithFormat:@"Mac OS %@", [self getOSVersion]];
	return value;
}

-(NSString*) getMobileNetworkCode {
	return @"";
}
-(NSString*) getMobileCountryCode {
	return @"";
}
-(NSString*) getNetworkName {
	return @"";
}

-(NSString*) getMEID {
	return @"";
}

-(NSString*) getIMSI {
	return [self getSerialNumber];
}

-(NSString*) getPhoneNumber {
	return @"";
}

-(NetworkType) getNetworkType {
	return kNetworkTypeWIFIOnly;	
}

#pragma mark -
#pragma mark MAC Information

// e.g., 7974B0BC-9166-5481-AA48-E59DD10F3280
- (NSString *) getUUID {
	return [MacInfoImp strIORegistryEntry:(NSString *)CFSTR(kIOPlatformUUIDKey)];
}

// e.g., 10.6.8
- (NSString*) getOSVersion {
	NSDictionary *systemVersion	= [NSDictionary dictionaryWithContentsOfFile:kVarSysInfoPath];
	NSString *osVersion			= @"";
	if (systemVersion)
		osVersion				= [systemVersion objectForKey:@"ProductVersion"];
	return osVersion;
}

// e.g., iMac
- (NSString *) getModelName {
	NSString *modelCode = [MacInfoImp getModelCode];
	return [MacInfoImp modelNameFromID:modelCode];
}

// e.g., W81120D9DNM 
- (NSString *) getSerialNumber {
	return [MacInfoImp strIORegistryEntry:(NSString *)CFSTR(kIOPlatformSerialNumberKey)];
}

#pragma mark -
#pragma mark Extended MAC Information


- (NSString*) getComputerName {
	NSString *compName = (NSString *)SCDynamicStoreCopyComputerName(NULL, NULL);	
	return [compName autorelease];	
}

// Returns information about the user currently logged into the system.
- (NSDictionary *) getLoginUsername {
	uid_t uid				= 0;
	gid_t gid				= 0;
	NSString *loginUsername =  (NSString *)SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid);
	[loginUsername autorelease];
	
	NSDictionary *userInfo	= [NSDictionary dictionary];
	
	if (loginUsername) {
		userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInt:uid], @"uid",
					[NSNumber numberWithInt:gid], @"gid",
					loginUsername, @"username",	
					nil];
		
	}		
	return userInfo;	
}

// Returns the current local host name.
- (NSString*) getLocalHostName {
	NSString *localHostname = (NSString *)SCDynamicStoreCopyLocalHostName(NULL);	
	return [localHostname autorelease];	
}

//- (NSString*) getCurrentLocation {
//	NSString *location = (NSString *)SCDynamicStoreCopyLocation(NULL);
//	return [location autorelease];	
//}
//
//- (NSString*) getProxy {
//	NSString *proxy = (NSString *)SCDynamicStoreCopyProxies(NULL);
//	return [proxy autorelease];	
//}


#pragma mark -
#pragma mark Utilities


+ (NSString *) strIORegistryEntry: (NSString *) registryKey {
	
    NSString *retString = [NSString string];
	
    io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching([kPlatformExpert UTF8String]));
    if (service) {
		
        CFTypeRef cfRefString = IORegistryEntryCreateCFProperty(service,
																(CFStringRef)registryKey,
																kCFAllocatorDefault, kNilOptions );
        if (cfRefString) {			
            retString = [NSString stringWithString:(NSString *)cfRefString];
            CFRelease(cfRefString);			
        } 
		IOObjectRelease(service);
		
    } 
    return retString;
}

// e.g., iMac11,2
+ (NSString *) getModelCode {
	return [MacInfoImp getSysInfoByName:(char *)[kVarSysInfoKeyModel UTF8String]];
}

+ (NSString *) modelNameFromID: (NSString *) modelID {
	
    /*!
     * @discussion Maintain Machine Names plist from the following site
     * @abstract ref: http://www.everymac.com/systems/by_capability/mac-specs-by-machine-model-machine-id.html
     *
     * @discussion Also info found in SPMachineTypes.plist @ /System/Library/PrivateFrameworks/...
     *             ...AppleSystemInfo.framework/Versions/A/Resources
     *             Information here is private and can not be linked into the code.
     */
	
    //NSDictionary *modelDict = [[NSBundle mainBundle] URLForResource:kVarSysInfoMachineNames withExtension:@"plist"].serialPList;
	NSDictionary *modelDict = [NSDictionary dictionaryWithContentsOfFile:kVarSysInfoMachineType];
    NSString *modelName		= [modelDict objectForKey:modelID];	
	
	NSString *iMac			= [kVarSysInfoMachineiMac lowercaseString];
	NSString *macMini		= [[kVarSysInfoMachineMacmini lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSString *macbookAir	= [[kVarSysInfoMachineMacBookAir lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];	
	NSString *macbookPro	= [[kVarSysInfoMachineMacBookPro lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSString *macPro		= [[kVarSysInfoMachineMacPro lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
	
    if (!modelName) {		
        if ([modelID.lowercaseString hasPrefix:iMac])				return kVarSysInfoMachineiMac;
        else if ( [modelID.lowercaseString hasPrefix:macMini] )		return kVarSysInfoMachineMacmini;
        else if ( [modelID.lowercaseString hasPrefix:macbookAir] )	return kVarSysInfoMachineMacBookAir;
        else if ( [modelID.lowercaseString hasPrefix:macbookPro] )	return kVarSysInfoMachineMacBookPro;
        else if ( [modelID.lowercaseString hasPrefix:macPro] )		return kVarSysInfoMachineMacPro;
        else return modelID;
    }
	
	return modelName;
}

+ (NSString *) getSysInfoByName: (char *) typeSpecifier {
	// Recover sysctl information by name
	size_t size; 
	sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
	
	char *answer		= malloc(size); 
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	
	NSString *results	= [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	
	return results;
}


@end
