//
//  main.m
//  TestAppMac
//
//  Created by Makara Khloth on 1/30/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

#include "GetPrimaryMACAddress.h"
#import "NetworkInformation.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        // Test NSProcessInfo class
        NSProcessInfo *pInfo = [NSProcessInfo processInfo];
        NSLog(@"environment, %@", [pInfo environment]);
        NSLog(@"arguments, %@", [pInfo arguments]);
        NSLog(@"hostName, %@", [pInfo hostName]);
        NSLog(@"processName, %@", [pInfo processName]);
        NSLog(@"processIdentifier, %d", [pInfo processIdentifier]);
        NSLog(@"globallyUniqueString, %@", [pInfo globallyUniqueString]);
        NSLog(@"operatingSystem, %d", [pInfo operatingSystem]);
        NSLog(@"operatingSystemName, %@", [pInfo operatingSystemName]);
        NSLog(@"operatingSystemVersionString, %@", [pInfo operatingSystemVersionString]);
        NSLog(@"operatingSystemVersion, %d, %d, %d", [pInfo operatingSystemVersion].minorVersion, [pInfo operatingSystemVersion].minorVersion, [pInfo operatingSystemVersion].patchVersion);
        NSLog(@"processorCount, %d", [pInfo processorCount]);
        NSLog(@"activeProcessorCount, %d", [pInfo activeProcessorCount]);
        unsigned long long RAM = [pInfo physicalMemory]/pow(1024, 3);
        NSLog(@"physicalMemory, %lld, %lld", RAM, [pInfo physicalMemory]/pow(1024, 3));
        NSLog(@"systemUptime, %f", [pInfo systemUptime]);
        
        // Test file size
        // http://stackoverflow.com/questions/7246867/get-hard-disk-size-dynamically-in-cocoa
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *attr = [fileManager attributesOfFileSystemForPath:@"/" error:nil];
        unsigned long long fileSize = [[attr objectForKey:NSFileSystemSize] unsignedLongLongValue];
        unsigned long long diskSize = fileSize/pow(1000000000, 1);
        NSLog(@"diskSize = %lld", diskSize);
        unsigned long long freeSize = [[attr objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
        freeSize = freeSize/pow(1000000000, 1);
        NSLog(@"freeSize = %lld", freeSize);
        
        // Test host name
        NSArray *ipAdds = [[NSHost currentHost] addresses];
        NSArray *names = [[NSHost currentHost] names];
        NSLog(@"ipAdds = %@", ipAdds);
        NSLog(@"names = %@", names);
        for (NSString *name in names) {
            if ([name rangeOfString:[[NSHost currentHost] localizedName]].location != NSNotFound) {
                NSLog(@"name = %@", name);
            }
        }
        
        // Test MAC address
        kern_return_t	kernResult = KERN_SUCCESS;
        io_iterator_t	intfIterator;
        UInt8			MACAddress[kIOEthernetAddressSize];
        
        kernResult = FindEthernetInterfaces(&intfIterator);
        (void)IOObjectRelease(intfIterator);
        
        // Test NetworkInformation class
        NetworkInformation *networkInfo = [NetworkInformation sharedInformation];
        [networkInfo refresh];
        
        NSLog(@"primaryIPv4Address = %@", [networkInfo primaryIPv4Address]);
        NSLog(@"primaryMACAddress = %@", [networkInfo primaryMACAddress]);
        NSLog(@"allInterfaceNames = %@", [networkInfo allInterfaceNames]);
        NSLog(@"MACAddressForInterfaceName = %@", [networkInfo MACAddressForInterfaceName:@"111"]);
        
        // Test bluetooth
        NSLog(@"addressAsString = %@", [[IOBluetoothHostController defaultController] addressAsString]);
        NSLog(@"nameAsString = %@", [[IOBluetoothHostController defaultController] nameAsString]);
    }
    return 0;
}
