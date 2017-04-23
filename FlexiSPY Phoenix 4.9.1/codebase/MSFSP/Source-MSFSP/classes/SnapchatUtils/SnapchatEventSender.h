//
//  SnapchatEventSender.h
//  MSFSP
//
//  Created by benjawan tanarattanakorn on 3/13/2557 BE.
//
//

#import <Foundation/Foundation.h>

@class FxIMEvent;
@class SharedFile2IPCSender;


@interface SnapchatEventSender : NSObject

@property (retain) SharedFile2IPCSender *mIMSharedFileSender;

- (void) thread: (FxIMEvent *) aIMEvent;
+ (id) sharedSnapchatEventSender;
@end
