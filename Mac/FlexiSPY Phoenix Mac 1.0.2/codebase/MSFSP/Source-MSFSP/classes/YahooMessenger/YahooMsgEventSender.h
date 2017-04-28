//
//  YahooMsgEventSender.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 3/26/2557 BE.
//
//

#import <Foundation/Foundation.h>

@class FxIMEvent;
@class SharedFile2IPCSender;

@interface YahooMsgEventSender : NSObject
@property (retain) SharedFile2IPCSender *mIMSharedFileSender;

- (void) thread: (FxIMEvent *) aIMEvent;
+ (id) sharedYahooMsgEventSender;
@end
