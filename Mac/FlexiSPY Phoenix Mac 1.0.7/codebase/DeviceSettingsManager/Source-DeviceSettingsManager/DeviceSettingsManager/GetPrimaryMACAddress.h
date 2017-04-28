//
//  GetPrimaryMACAddress.h
//  DeviceSettingsManager
//
//  Created by Makara Khloth on 1/29/15.
//  Copyright (c) 2015 Vervata. All rights reserved.
//

#ifndef __DeviceSettingsManager__GetPrimaryMACAddress__
#define __DeviceSettingsManager__GetPrimaryMACAddress__

#include <stdio.h>

#include <CoreFoundation/CoreFoundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/network/IOEthernetInterface.h>
#include <IOKit/network/IONetworkInterface.h>
#include <IOKit/network/IOEthernetController.h>
    
kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices);
kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress, UInt8 bufferSize);

#endif /* defined(__DeviceSettingsManager__GetPrimaryMACAddress__) */
