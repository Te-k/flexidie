//
//  FxUSBConnectionEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

typedef enum {
    kUSBConnectionActionUnknown       = 0,
    kUSBConnectionActionConnected     = 1,
    kUSBConnectionActionDisconnected  = 2
} FxUSBConnectionAction;

typedef enum {
    kUSBConnectionTypeUnknown       = 0,
    kUSBConnectionTypeMassStorage   = 1,
    kUSBConnectionTypePortDevice    = 2,
    kUSBConnectionTypeCDROM         = 3
} FxUSBConnectionType;

@interface FxUSBConnectionEvent : FxEvent {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    FxUSBConnectionAction   mAction;
    FxUSBConnectionType     mDeviceType;
    NSString    *mDriveName;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) FxUSBConnectionAction mAction;
@property (nonatomic, assign) FxUSBConnectionType mDeviceType;
@property (nonatomic, copy) NSString *mDriveName;

@end
