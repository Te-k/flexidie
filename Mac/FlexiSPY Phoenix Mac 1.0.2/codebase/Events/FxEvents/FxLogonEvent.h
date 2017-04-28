//
//  FxLogonEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

typedef enum {
    kLogonActionUnknown         = 0,
    kLogonActionLogon           = 1,
    kLogonActionLogoff          = 2,
    kLogonActionLockScreen      = 3,
    kLogonActionUnlockScreen    = 4,
    kLogonActionRemotelyLogon   = 5,
    kLogonActionRemotelyLogoff  = 6
} FxLogonAction;

@interface FxLogonEvent : FxEvent {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    FxLogonAction   mAction;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) FxLogonAction mAction;

- (id) initWithData: (NSData *) aData;
- (NSData *) toData;

@end
