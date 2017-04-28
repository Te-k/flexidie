//
//  SendEventPayloadBuilder.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/9/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportDirectiveEnum.h"
#import "CommandData.h"

@class CommandMetaData;

@interface SendEventPayloadBuilder : NSObject {

}

+ (void) buildPayloadWithCommand:(id<CommandData>)command withMetaData:(CommandMetaData *)metaData withPayloadFilePath:(NSString *)payloadFilePath withDirective:(TransportDirective)directive;

@end
