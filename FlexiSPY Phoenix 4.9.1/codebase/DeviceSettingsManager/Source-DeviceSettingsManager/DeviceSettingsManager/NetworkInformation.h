//
//  NetworkInformation.h
//
//  Created by akisute on 10/10/07.
//  Copyright 2010 株式会社ビープラウド. All rights reserved.
//

#import <Foundation/Foundation.h>


//UIKIT_EXTERN const int NetworkInformationInterfaceTypeIPv4;
//UIKIT_EXTERN const int NetworkInformationInterfaceTypeMAC;
//UIKIT_EXTERN const NSString *NetworkInformationInterfaceAddressKey;


/*!
 @class			NetworkInformation
 @abstract		A singleton class to retrieve network (especially Ethernet) information such as IP address or MAC address.
 @discussion	This class internally uses <sys/ioctl.h> to retrieve network information.
 */
@interface NetworkInformation : NSObject {
	/*
	 This dictionary should be like this:
	 
	 allInterfaces = {
        en0 = {
            18 = {
                address = "AA:AA:AA:AA:AA:AA";
            };
        };
        en1 = {
            18 = {
                address = "BB:BB:BB:BB:BB:BB";
            };
            2 = {
                address = "192.168.100.20";
            };
        };
        fw0 = {
            18 = {
                address = "CC:CC:CC:CC:CC:CC";
            };
        };
        gif0 = {
            18 = {
                address = "00:00:00:00:00:00";
            };
        };
        lo0 = {
            18 = {
                address = "00:00:00:00:00:00";
            };
            2 = {
                address = "127.0.0.1";
            };
        };
        stf0 = {
            18 = {
                address = "00:00:00:00:00:00";
            };
        };
        vboxnet0 = {
            18 = {
                address = "DD:DD:DD:DD:DD:DD";
            };
        };
	 }
	 
	 */
	NSDictionary *allInterfaces;
}

/*!
 @property		allInterfaceNames
 @abstract		All existing network interface names.
 @discussion	Returns NSArray instance which contains NSString objects that represents all exsiting network interface names.
 refresh is called if the shared instance have not retrieved network information yet.
 */
@property (nonatomic, readonly) NSArray *allInterfaceNames;

/*!
 @property		primaryIPv4Address
 @abstract		IPv4 address of the primary network interface.
 @discussion	This property automatically determines which interface is the primary interface and returns its IPv4 address.
 refresh is called if the shared instance have not retrieved network information yet.
 */
@property (nonatomic, readonly) NSString *primaryIPv4Address;

/*!
 @property		primaryMACAddress
 @abstract		MAC address of the primary network interface.
 @discussion	This property automatically determines which interface is the primary interface and returns its MAC address.
 refresh is called if the shared instance have not retrieved network information yet.
 */
@property (nonatomic, readonly) NSString *primaryMACAddress;


+ (NetworkInformation *)sharedInformation;
+ (void)unshare;


- (void)refresh;
- (NSString *)IPv4AddressForInterfaceName:(NSString *)interfaceName;
- (NSString *)MACAddressForInterfaceName:(NSString *)interfaceName;

@end
