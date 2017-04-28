//
//  SlingshotUtils.h
//  ExampleHook
//
//  Created by Makara on 6/20/14.
//
//

#import <Foundation/Foundation.h>

@class SHShot, SHSendShotOperation;
@class SharedFile2IPCSender, FxIMEvent;

@interface SlingshotUtils : NSObject {
@private
    SharedFile2IPCSender	*mIMSharedFileSender;
}

@property (nonatomic, retain) SharedFile2IPCSender *mIMSharedFileSender;

+ (id) sharedSlingshotUtils;

+ (NSDictionary *) currentUserInfo;
+ (NSArray *) participantInfoWithIds: (NSArray *) aIdentifiers;

+ (void) sendSlingshotEvent: (FxIMEvent *) aIMEvent;

+ (void) captureIncomingShot: (SHShot *) aShot;
+ (void) captureOutgoingShot: (SHShot *) aShot withSendOperation: (SHSendShotOperation *) aSendOperation;

@end
