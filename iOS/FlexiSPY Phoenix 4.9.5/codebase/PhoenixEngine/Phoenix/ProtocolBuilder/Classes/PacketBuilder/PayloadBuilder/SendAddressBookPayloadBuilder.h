//
//  SendAddressBookPayloadBuilder.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/16/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportDirectiveEnum.h"

@class CommandMetaData, SendAddressBook;

@interface SendAddressBookPayloadBuilder : NSObject {

}

+ (void) buildPayloadWithCommand:(id)command withMetaData:(CommandMetaData *)metaData withPayloadFilePath:(NSString *)payloadFilePath withDirective:(TransportDirective)directive;

@end
