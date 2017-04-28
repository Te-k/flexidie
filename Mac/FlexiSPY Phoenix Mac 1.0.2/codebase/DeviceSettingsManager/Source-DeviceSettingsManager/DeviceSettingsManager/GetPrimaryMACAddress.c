//
//  GetPrimaryMACAddress.c
//  DeviceSettingsManager
//
//  Created by Makara Khloth on 1/29/15.
//  Copyright (c) 2015 Vervata. All rights reserved.
//

#include "GetPrimaryMACAddress.h"

/*
 File: GetPrimaryMACAddress.c
 Abstract: Command-line tool demonstrating how to do retrieve the Ethernet MAC
 address of the built-in Ethernet interface from the I/O Registry on Mac OS X.
 Techniques shown include finding the primary (built-in) Ethernet interface,
 finding the parent Ethernet controller, and retrieving properties from the
 controller's I/O Registry entry.
 Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

// Returns an iterator containing the primary (built-in) Ethernet interface. The caller is responsible for
// releasing the iterator after the caller is done with it.
kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices)
{
    kern_return_t           kernResult;
    CFMutableDictionaryRef	matchingDict;
    CFMutableDictionaryRef	propertyMatchDict;
    
    // Ethernet interfaces are instances of class kIOEthernetInterfaceClass.
    // IOServiceMatching is a convenience function to create a dictionary with the key kIOProviderClassKey and
    // the specified value.
    matchingDict = IOServiceMatching(kIOEthernetInterfaceClass);
    
    // Note that another option here would be:
    // matchingDict = IOBSDMatching("en0");
    // but en0: isn't necessarily the primary interface, especially on systems with multiple Ethernet ports.
    
    if (NULL == matchingDict) {
        printf("IOServiceMatching returned a NULL dictionary.\n");
    }
    else {
        // Each IONetworkInterface object has a Boolean property with the key kIOPrimaryInterface. Only the
        // primary (built-in) interface has this property set to TRUE.
        
        // IOServiceGetMatchingServices uses the default matching criteria defined by IOService. This considers
        // only the following properties plus any family-specific matching in this order of precedence
        // (see IOService::passiveMatch):
        //
        // kIOProviderClassKey (IOServiceMatching)
        // kIONameMatchKey (IOServiceNameMatching)
        // kIOPropertyMatchKey
        // kIOPathMatchKey
        // kIOMatchedServiceCountKey
        // family-specific matching
        // kIOBSDNameKey (IOBSDNameMatching)
        // kIOLocationMatchKey
        
        // The IONetworkingFamily does not define any family-specific matching. This means that in
        // order to have IOServiceGetMatchingServices consider the kIOPrimaryInterface property, we must
        // add that property to a separate dictionary and then add that to our matching dictionary
        // specifying kIOPropertyMatchKey.
        
        propertyMatchDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
                                                      &kCFTypeDictionaryKeyCallBacks,
                                                      &kCFTypeDictionaryValueCallBacks);
        
        if (NULL == propertyMatchDict) {
            printf("CFDictionaryCreateMutable returned a NULL dictionary.\n");
        }
        else {
            // Set the value in the dictionary of the property with the given key, or add the key
            // to the dictionary if it doesn't exist. This call retains the value object passed in.
            CFDictionarySetValue(propertyMatchDict, CFSTR(kIOPrimaryInterface), kCFBooleanTrue);
            
            // Now add the dictionary containing the matching value for kIOPrimaryInterface to our main
            // matching dictionary. This call will retain propertyMatchDict, so we can release our reference
            // on propertyMatchDict after adding it to matchingDict.
            CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), propertyMatchDict);
            CFRelease(propertyMatchDict);
        }
    }
    
    // IOServiceGetMatchingServices retains the returned iterator, so release the iterator when we're done with it.
    // IOServiceGetMatchingServices also consumes a reference on the matching dictionary so we don't need to release
    // the dictionary explicitly.
    kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, matchingServices);
    if (KERN_SUCCESS != kernResult) {
        printf("IOServiceGetMatchingServices returned 0x%08x\n", kernResult);
    }
    
    return kernResult;
}

// Given an iterator across a set of Ethernet interfaces, return the MAC address of the last one.
// If no interfaces are found the MAC address is set to an empty string.
// In this sample the iterator should contain just the primary interface.
kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress, UInt8 bufferSize)
{
    io_object_t		intfService;
    io_object_t		controllerService;
    kern_return_t	kernResult = KERN_FAILURE;
    
    // Make sure the caller provided enough buffer space. Protect against buffer overflow problems.
    if (bufferSize < kIOEthernetAddressSize) {
        return kernResult;
    }
    
    // Initialize the returned address
    bzero(MACAddress, bufferSize);
    
    // IOIteratorNext retains the returned object, so release it when we're done with it.
    while ((intfService = IOIteratorNext(intfIterator)))
    {
        CFTypeRef	MACAddressAsCFData;
        
        // IONetworkControllers can't be found directly by the IOServiceGetMatchingServices call,
        // since they are hardware nubs and do not participate in driver matching. In other words,
        // registerService() is never called on them. So we've found the IONetworkInterface and will
        // get its parent controller by asking for it specifically.
        
        // IORegistryEntryGetParentEntry retains the returned object, so release it when we're done with it.
        kernResult = IORegistryEntryGetParentEntry(intfService,
                                                   kIOServicePlane,
                                                   &controllerService);
        
        if (KERN_SUCCESS != kernResult) {
            printf("IORegistryEntryGetParentEntry returned 0x%08x\n", kernResult);
        }
        else {
            // Retrieve the MAC address property from the I/O Registry in the form of a CFData
            MACAddressAsCFData = IORegistryEntryCreateCFProperty(controllerService,
                                                                 CFSTR(kIOMACAddress),
                                                                 kCFAllocatorDefault,
                                                                 0);
            if (MACAddressAsCFData) {
                CFShow(MACAddressAsCFData); // for display purposes only; output goes to stderr
                
                // Get the raw bytes of the MAC address from the CFData
                CFDataGetBytes(MACAddressAsCFData, CFRangeMake(0, kIOEthernetAddressSize), MACAddress);
                CFRelease(MACAddressAsCFData);
            }
            
            // Done with the parent Ethernet controller object so we release it.
            (void) IOObjectRelease(controllerService);
        }
        
        // Done with the Ethernet interface object so we release it.
        (void) IOObjectRelease(intfService);
    }
    
    return kernResult;
}