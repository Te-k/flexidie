//
//  IMEventProtocolConverter.h
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMConversationEvent;
@class IMAccountEvent;
@class IMContactEvent;
@class IMMessageEvent;

@interface IMEventProtocolConverter : NSObject {

}

+(NSData *)convertToProtocolIMMessageEvent:(IMMessageEvent *)aIMMessage fileHandler: (NSFileHandle *) aFileHandle;
+(NSData *)convertToProtocolIMMessageEvent:(IMMessageEvent *)aIMMessage; // Obsolete

+(NSData *)convertToProtocolIMConversationEvent:(IMConversationEvent *)aIMConversation;
+(NSData *)convertToProtocolIMAccountEvent:(IMAccountEvent *)aIMAccount;
+(NSData *)convertToProtocolIMContactEvent:(IMContactEvent *)aIMContact;

@end
