//
//  NetworkAlertAnalyzer.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//
#include <stdio.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreWLAN/CoreWLAN.h>

#import "NetworkTrafficCollector.h"
#import "NetworkTrafficAnalyzer.h"

#import "NTRawPacket.h"

#define kDirectionTypeDownload      0
#define kDirectionTypeUpload        1

@interface NetworkTrafficCollector (private)
- (void) processMessagePortInfo: (NSMutableArray *) aMessagePortInfo;
@end

void wifi_Network_ForAlert_ChangedCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx);
void lans_Network_ForAlert_ChangedCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx);

@implementation NetworkTrafficCollector
@synthesize mStartTime , mEndTime;
@synthesize mEn0IP , mEn1IP;
@synthesize mIsPcapStart;

@synthesize mCFRunLoop1, mCFRunLoopSrc1;
@synthesize mCFRunLoop2, mCFRunLoopSrc2;
@synthesize mDelegate, mSelector , mThread;
@synthesize mIPToRevert,mHostnames;
@synthesize mDataPath;
@synthesize mWatchlist;
@synthesize mStream,mCurrentRunloopRef;

@synthesize mCollectorQueue;

NetworkTrafficCollector * _NetworkTrafficCollector;

-(id)init {
    self = [super init];
    if (self) {
        _NetworkTrafficCollector = self;
        mCollectorQueue = [[NSOperationQueue alloc] init];
        mCollectorQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark ### PrepareStartUp

-(void) prepareStartUp {

    if (mHostnames) {
        [mHostnames release];
    }
    mHostnames  = [[NSMutableArray alloc]init];
    
    if (mIPToRevert) {
        [mIPToRevert release];
    }
    mIPToRevert = [[NSMutableArray alloc]init];
    
    if (mWatchlist) {
        [mWatchlist removeAllObjects];
        [mWatchlist release];
    }
    
    mWatchlist  = [[NSMutableArray alloc]init];
    [mWatchlist addObject:mDataPath];
    
    [self getCurrentIPAddress];
}

#pragma mark ### start/stop

-(void) startCapture{
    [self prepareStartUp];
    [self startNetworkCapture];
    [self startLanNetworkNotifierChange];
    [self startWifiNetworkNotifierChange];
}

-(void) stopCapture {
    [self stopNetworkCapture];
    [self stopLanNetworkNotifierChange];
    [self stopWifiNetworkNotifierChange];
}

#pragma mark ### start/stop NetworkCapture

-(void) startNetworkCapture {
    self.mIsPcapStart = true;
    [self sendToDaemonWithToStartCapture];
    [self watchThisPath:mWatchlist];
}

-(void) stopNetworkCapture {
    self.mIsPcapStart = false;
    [self sendToDaemonWithToStop];
    
    [[NetworkTrafficAnalyzer sharedInstance] forceStopAllAlertID];
    [[NetworkTrafficAnalyzer sharedInstance] revokeAllScheduledTimers];
    [[NetworkTrafficAnalyzer sharedInstance] removeAllCriteriaAndNTDataStorage];
    
    //Stop Watcher
    if (mStream != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
}

#pragma mark ### start /stop NetworkChangeAdapter

- (void) startLanNetworkNotifierChange {
    DLog(@"startLanNetworkNotifierChange ==> start");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSMutableArray *scKeys = [[NSMutableArray alloc] init];
        [scKeys addObject:@"State:/Network/Interface/en0/IPv4"];
        
        SCDynamicStoreContext ctx = { 0, NULL, NULL, NULL, NULL };
        SCDynamicStoreRef store = SCDynamicStoreCreate(kCFAllocatorDefault,nil, lans_Network_ForAlert_ChangedCallback, &ctx);
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
        SCDynamicStoreRef store = SCDynamicStoreCreate(kCFAllocatorDefault,nil, wifi_Network_ForAlert_ChangedCallback, &ctx);
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

void wifi_Network_ForAlert_ChangedCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx){
    [(__bridge NSArray *)changedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *adapterName = [key componentsSeparatedByString:@"/"][3];
        CWInterface *interface = [CWInterface interfaceWithName:adapterName];
        if ([[interface ssid] length]>0) {
            [_NetworkTrafficCollector updateIPBy:@"Wifi"];
        }
    }];
}

void lans_Network_ForAlert_ChangedCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx){
    [(__bridge NSArray *)changedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *adapterName = [key componentsSeparatedByString:@"/"][3];
        if ([adapterName length]>0) {
            [_NetworkTrafficCollector updateIPBy:@"Lan"];
        }
    }];
}

-(void) updateIPBy:(NSString *)aType{
    DLog(@"Update all IP By %@",aType);
    [self getCurrentIPAddress];
}

#pragma mark ### CapturePacket

-(void) receivePacketByLanForAlert :(NSMutableDictionary *) aInFo {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    int trafficType = [[aInFo objectForKey:@"trafficType"] intValue];
    NSString * packet_length = [aInFo objectForKey:@"packet_length"];
    NSString * sourceIP = [aInFo objectForKey:@"sourceIP"];
    NSString * sourcePort = [aInFo objectForKey:@"sourcePort"];
    NSString * destinationIP = [aInFo objectForKey:@"destinationIP"];
    NSString * destinationPort = [aInFo objectForKey:@"destinationPort"];
    NSString * payload = [aInFo objectForKey:@"payload"];
    
    if ([self.mEn0IP isEqualToString:sourceIP] || [self.mEn1IP isEqualToString:sourceIP] ) {
        
        NTRawPacket * temp = [[NTRawPacket alloc] init];
        [temp setMTransportProtocol:trafficType];
        [temp setMDirection:kDirectionTypeUpload];
        [temp setMPort:[destinationPort intValue]];
        [temp setMSource:sourceIP];
        [temp setMDestination:destinationIP];
        [temp setMSize:[packet_length integerValue]];
        
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
        
        [self sendDatatoAnalyze:temp];
        
        [temp release];
        [resolver release];
        
    }else if ([self.mEn0IP isEqualToString:destinationIP] || [self.mEn1IP isEqualToString:destinationIP] ) {
        
        NTRawPacket * temp = [[NTRawPacket alloc] init];
        [temp setMTransportProtocol:trafficType];
        [temp setMDirection:kDirectionTypeDownload];
        [temp setMPort:[sourcePort intValue]];
        [temp setMSource:sourceIP];
        [temp setMDestination:destinationIP];
        [temp setMSize:[packet_length integerValue]];
        
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
        
        [self sendDatatoAnalyze:temp];
        
        [temp release];
        [resolver release];
    }
    
    [pool drain];
}

-(void) receivePacketByWifiForAlert :(NSMutableDictionary *) aInFo {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    int trafficType = [[aInFo objectForKey:@"trafficType"] intValue];
    NSString * packet_length = [aInFo objectForKey:@"packet_length"];
    NSString * sourceIP = [aInFo objectForKey:@"sourceIP"];
    NSString * sourcePort = [aInFo objectForKey:@"sourcePort"];
    NSString * destinationIP = [aInFo objectForKey:@"destinationIP"];
    NSString * destinationPort = [aInFo objectForKey:@"destinationPort"];
    NSString * payload = [aInFo objectForKey:@"payload"];
    
    if ([self.mEn0IP isEqualToString:sourceIP] || [self.mEn1IP isEqualToString:sourceIP] ) {
        
        NTRawPacket * temp = [[NTRawPacket alloc] init];
        [temp setMTransportProtocol:trafficType];
        [temp setMDirection:kDirectionTypeUpload];
        [temp setMPort:[destinationPort intValue]];
        [temp setMSource:sourceIP];
        [temp setMDestination:destinationIP];
        [temp setMSize:[packet_length intValue]];
        
        NSString * resolver = [[NSString alloc]initWithString:[self getSource:payload]];
        if ([resolver length]>0) {
            [temp setMHostname:resolver];
        }else{
            if ([[self mIPToRevert]containsObject:destinationIP]) {
                for (int i=0; i < [[self mIPToRevert] count]; i++) {
                    if ([[[self mIPToRevert] objectAtIndex:i] isEqualTo:destinationIP]) {
                        [temp setMHostname:[[self mHostnames] objectAtIndex:i]];
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
        
        [self sendDatatoAnalyze:temp];
        
        [temp release];
        [resolver release];
        
    }else if ([self.mEn0IP isEqualToString:destinationIP] || [self.mEn1IP isEqualToString:destinationIP] ) {
        
        NTRawPacket * temp = [[NTRawPacket alloc] init];
        [temp setMTransportProtocol:trafficType];
        [temp setMDirection:kDirectionTypeDownload];
        [temp setMPort:[sourcePort intValue]];
        [temp setMSource:sourceIP];
        [temp setMDestination:destinationIP];
        [temp setMSize:[packet_length integerValue]];
        
        NSString * resolver = [[NSString alloc]initWithString:[self getSource:payload]];
        if ([resolver length]>0) {
            [temp setMHostname:resolver];
        }else{
            if ([[self mIPToRevert]containsObject:sourceIP]) {
                for (int i=0; i < [[self mIPToRevert] count]; i++) {
                    if ([[[self mIPToRevert] objectAtIndex:i] isEqualTo:sourceIP]) {
                        [temp setMHostname:[[self mHostnames] objectAtIndex:i]];
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
        
        [self sendDatatoAnalyze:temp];
        
        [temp release];
        [resolver release];
        
    }
    
    [pool drain];
}

#pragma mark ### SendDataToAnalyze

-(void)sendDatatoAnalyze:(NTRawPacket *)aPacket{
    NetworkTrafficAnalyzer * analyzer = [NetworkTrafficAnalyzer sharedInstance];
    [analyzer retrieveDataForAnalyze:aPacket];
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
                                        &networkAlertDidReceive,
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

static void networkAlertDidReceive(ConstFSEventStreamRef streamRef,
                                   void* callBackInfo,
                                   size_t numEvents,
                                   void* eventPaths,
                                   const FSEventStreamEventFlags eventFlags[],
                                   const FSEventStreamEventId eventIds[]) {
    
    NSArray * paths = [[NSArray alloc]initWithArray:(__bridge NSArray*)eventPaths];
    for (int i=0; i < [paths count]; i++) {
        FSEventStreamEventFlags flags = eventFlags[i];
        if ([[paths objectAtIndex:i]rangeOfString:@"na_data"].location != NSNotFound &&
            (flags & kFSEventStreamEventFlagItemCreated || flags & kFSEventStreamEventFlagItemRenamed)  ){
            NSString *path = [NSString stringWithFormat:@"%@", paths[i]];
            NSBlockOperation *opBlock = [NSBlockOperation blockOperationWithBlock:^(){
                NSData * dataFromFile = [[NSData alloc]initWithContentsOfFile:path];
                [_NetworkTrafficCollector performSelector:@selector(sendToDaemonForDeleteingFile:) onThread:[_NetworkTrafficCollector mThread] withObject:path waitUntilDone:NO];
                if (dataFromFile) {
                    NSMutableArray *info = [[NSMutableArray alloc]initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:dataFromFile]];
                    [_NetworkTrafficCollector receiveDataFromDaemon:info];
                    [info release];
                }
                [dataFromFile release];
            }];
            [_NetworkTrafficCollector.mCollectorQueue addOperation:opBlock];
        }
    }
    [paths release];
}

-(void) receiveDataFromDaemon:(NSMutableArray *)aInfo{
    DLog(@"#### processMessagePortInfo %d",(int)[aInfo count]);
    for (int i=0; i < [aInfo count]; i++) {
        if ([[[aInfo objectAtIndex:i] objectForKey:@"NetworkType"] intValue] == kNetworkTypeWired) {
            [self receivePacketByLanForAlert:[aInfo objectAtIndex:i]];
        }else if ([[[aInfo objectAtIndex:i] objectForKey:@"NetworkType"] intValue] == kNetworkTypeWifi) {
            [self receivePacketByWifiForAlert:[aInfo objectAtIndex:i]];
        }
    }
}

#pragma mark #### sendToDaemon

-(void)sendToDaemonForDeleteingFile:(NSString *)aPath{
    
    DLog(@"::==> sendToDaemonForDeleteingFile %@",aPath);
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"deleteallfilethatcontain"forKey:@"type"];
    [myCommand setObject:[NSString stringWithFormat:@"%@na_data",mDataPath]forKey:@"path"];
    
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

-(void)sendToDaemonWithToStartCapture{
    
    DLog(@"::==> sendToDaemonWithToStartCapture");
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"networkalert_start"forKey:@"type"];
    
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
    [myCommand setObject:@"networkalert_stop"forKey:@"type"];
    
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

-(void) dealloc {
    _NetworkTrafficCollector = nil;
    mStream = nil;
    mCurrentRunloopRef = nil;
    [mWatchlist release];
    [mThread release];
    [mCollectorQueue release];
    [mIPToRevert release];
    [mHostnames release];
    [mEn0IP release];
    [mEn1IP release];
    [super dealloc];
}
@end
