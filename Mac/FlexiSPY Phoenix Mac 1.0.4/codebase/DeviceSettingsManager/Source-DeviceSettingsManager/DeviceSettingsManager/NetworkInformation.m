//
//  NetworkInformation.m
//
//  Created by akisute on 10/10/07.
//  Copyright 2010 株式会社ビープラウド. All rights reserved.
//

#import "NetworkInformation.h"
#import <sys/ioctl.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/sockio.h>
#import <unistd.h>		// for close(), etc etc... perhaps ioctl() is included in this header
#import <net/if.h>		// for struct ifconf, struct ifreq
#import <net/if_dl.h>	// for struct sockaddr_dl, LLADDR
#import <netinet/in.h>	// for some reason... I have no idea. Without this inet_ntoa call causes compile error
#import <net/ethernet.h>// for either_ntoa()
#import <arpa/inet.h>	// for inet_ntoa()


#define NetworkInformation_IFCONF_MAX_INTERFACE_COUNT   20
const int NetworkInformationInterfaceTypeIPv4 = AF_INET;
const int NetworkInformationInterfaceTypeMAC = AF_LINK;
const NSString *NetworkInformationInterfaceAddressKey = @"address";


@interface NetworkInformation ()

@property (nonatomic, retain) NSDictionary *allInterfaces;

@end


@implementation NetworkInformation
@synthesize allInterfaces = allInterfaces;

#pragma mark Properties


- (NSArray *)allInterfaceNames {
	if (!allInterfaces) {
		[self refresh];
	}
	
	return [allInterfaces allKeys];
}

- (NSString *)primaryIPv4Address {
	if (!allInterfaces) {
		[self refresh];
	}
	
	// Select primary IPv4 Address by following formula:
	// - Consider "en0" as primary Ethernet and "en1"/"en2" as secondary Ethernet
	// - In iPhone, "pdp_ip0" ~ "pdp_ip3" are Cellphone network IP thus we should take them into account
	// - If primary Ethernet has IPv4 address, return it
	//   Else, return secondary Ethernet IPv4 address
	// - Return nil if no Ethernet/Cellphone network have address
    NSString *result;
	if ((result = [self IPv4AddressForInterfaceName:@"en0"])) {
		return result;
	} else if ((result = [self IPv4AddressForInterfaceName:@"en1"])) {
		return result;
	} else if ((result = [self IPv4AddressForInterfaceName:@"en2"])) {
		return result;
	} else if ((result = [self IPv4AddressForInterfaceName:@"pdp_ip0"])) {
		return result;
	} else if ((result = [self IPv4AddressForInterfaceName:@"pdp_ip1"])) {
		return result;
	} else if ((result = [self IPv4AddressForInterfaceName:@"pdp_ip2"])) {
		return result;
	} else if ((result = [self IPv4AddressForInterfaceName:@"pdp_ip3"])) {
		return result;
	} else {
		return nil;
	}
}

- (NSString *)primaryMACAddress {
	if (!allInterfaces) {
		[self refresh];
	}
	
	// Select primary MAC Address by following formula:
	// - Consider "en0" as primary Ethernet and "en1"/"en2" as secondary Ethernet
	// - Always return the address of "en0" Ethernet because:
	//   * en0 should always have MAC address
	//   * en0 should always be on any device
	//   * en0 should be used when Wi-Fi is available
	//   * pdp_ip0, which is used as Cellphone network, doesn't have a valid MAC address to use so we have to use en0 even if Wi-Fi is not active
	return [self MACAddressForInterfaceName:@"en0"];
}


#pragma mark Init/dealloc


- (void)dealloc {
    self.allInterfaces = nil;
	[super dealloc];
}

#pragma mark Shared

static NetworkInformation *sharedInstance;
static dispatch_once_t onceToken;
+ (instancetype)sharedInformation {
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

+ (void)unshare {
    onceToken = 0;
    [sharedInstance release];
    sharedInstance = nil;
}

#pragma mark Other methods


- (void)refresh {
	// Release Obj-C ivar data first
    self.allInterfaces = nil;
	
	// Open socket
	int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd < 0) {
		//NSLog(@"NetworkInformation refresh failed: socket could not be opened");
		return;
	}
	
	// Use ioctl to gain information about the socket
	// - Set ifconf buffer before executing ioctl
	// - SIOCGIFCONF command retrieves ifnet list and put it into struct ifconf
	struct ifconf ifc;
	struct ifreq ifreq[NetworkInformation_IFCONF_MAX_INTERFACE_COUNT];
	ifc.ifc_len = sizeof ifreq;
	ifc.ifc_buf = (char *)ifreq;
	if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0) {
		//NSLog(@"NetworkInformation refresh failed: ioctl execution failed");
		close(sockfd);
		return;
	}
	
	// Prepare Obj-C dictionary here
    NSMutableDictionary *interfaces = [NSMutableDictionary dictionary];
    
	// Loop through ifc to access struct ifreq
	// - ifc.ifc_buf now contains multiple struct ifreq, but we don't have any clue of where those pointers are
	// - We have to calculate the next pointer location in order to loop...
	struct ifreq *p_ifr;
	for (char *p_index=ifc.ifc_buf; p_index < ifc.ifc_buf+ifc.ifc_len; ) {
		p_ifr = (struct ifreq *)p_index;
		
		if (p_ifr && p_ifr->ifr_addr.sa_family) {
			NSString *interfaceName = @(p_ifr->ifr_name);
			NSNumber *family = @(p_ifr->ifr_addr.sa_family);
			NSMutableDictionary *interfaceDict;
			NSMutableDictionary *interfaceTypeDetailDict;
			char temp[80];
			
			// Switch by sa_family
			// - Do nothing if sa_family is not one of supported types (like MAC or IPv4)
			switch (p_ifr->ifr_addr.sa_family) {
				case AF_LINK:
					// MAC address
					
					interfaceDict = interfaces[interfaceName];
					if (!interfaceDict) {
						interfaceDict = [NSMutableDictionary dictionary];
						interfaces[interfaceName] = interfaceDict;
					}
					
					interfaceTypeDetailDict = interfaceDict[family];
					if (!interfaceTypeDetailDict) {
						interfaceTypeDetailDict = [NSMutableDictionary dictionary];
						interfaceDict[family] = interfaceTypeDetailDict;
					}
					
					struct sockaddr_dl *sdl = (struct sockaddr_dl *) &(p_ifr->ifr_addr);
					int a,b,c,d,e,f;
					
					strlcpy(temp, ether_ntoa((const struct ether_addr *)LLADDR(sdl)), sizeof(temp));
					sscanf(temp, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
					sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X", a, b, c, d, e, f);
					
					interfaceTypeDetailDict[NetworkInformationInterfaceAddressKey] = @(temp);
					
					break;
					
				case AF_INET:
					// IPv4 address
					
					interfaceDict = interfaces[interfaceName];
					if (!interfaceDict) {
						interfaceDict = [NSMutableDictionary dictionary];
						interfaces[interfaceName] = interfaceDict;
					}
					
					interfaceTypeDetailDict = interfaceDict[family];
					if (!interfaceTypeDetailDict) {
						interfaceTypeDetailDict = [NSMutableDictionary dictionary];
						interfaceDict[family] = interfaceTypeDetailDict;
					}
					
					struct sockaddr_in *sin = (struct sockaddr_in *) &p_ifr->ifr_addr;
					
					strlcpy(temp, inet_ntoa(sin->sin_addr), sizeof(temp));
					
					interfaceTypeDetailDict[NetworkInformationInterfaceAddressKey] = @(temp);
					
					break;
					
				default:
					// Anything else
					break;
			}
		}
		
		// Don't forget to calculate loop pointer!
		p_index += sizeof(p_ifr->ifr_name) + MAX(sizeof(p_ifr->ifr_addr), p_ifr->ifr_addr.sa_len);
	}
	
	// Set Obj-C property here
    self.allInterfaces = interfaces;
	//NSLog(@"allInterfaces = %@", interfaces);
	
	// Don't forget to close socket!
	close(sockfd);
}

- (NSString *)IPv4AddressForInterfaceName:(NSString *)interfaceName {
	return allInterfaces[interfaceName][@(NetworkInformationInterfaceTypeIPv4)][NetworkInformationInterfaceAddressKey];
}

- (NSString *)MACAddressForInterfaceName:(NSString *)interfaceName {
	return allInterfaces[interfaceName][@(NetworkInformationInterfaceTypeMAC)][NetworkInformationInterfaceAddressKey];
}

@end
