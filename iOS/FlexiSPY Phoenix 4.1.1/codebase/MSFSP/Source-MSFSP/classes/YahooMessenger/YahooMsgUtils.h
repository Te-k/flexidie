//
//  YahooMsgUtils.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 3/25/2557 BE.
//
//

#import <Foundation/Foundation.h>

@class YMMessage;
@class YMIdentity;
@class FxIMEvent;

@interface YahooMsgUtils : NSObject

+ (void) sendOutgoingTextMessageEventForYMMessage: (YMMessage *) aYMMessage;

+ (void) sendOutgoingAttachmentMessageEventForMessage: (id) aMessage;

+ (void) sendIncomingTextMessageEventForYMMessage: (YMMessage *) aYMMessage;

+ (void) storeIncomingAttachmentMessageEventFrom: (YMIdentity *) aSenderIdentity
                                          target: (YMIdentity *) aTargetIdentity
                                  attachmentName: (NSString *) aAttachmentName
                                      sessionID : (NSString *) aSessionID;

+ (void) sendIncomingAttachment: (NSString *) aAttachmentPath
                        imEvent: (FxIMEvent *) aIMEvent
                      sessionID: (NSString *) aSessionID;

#pragma mark - Utilities

+ (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension
				   extension: (NSString *) aExtension;

@end
