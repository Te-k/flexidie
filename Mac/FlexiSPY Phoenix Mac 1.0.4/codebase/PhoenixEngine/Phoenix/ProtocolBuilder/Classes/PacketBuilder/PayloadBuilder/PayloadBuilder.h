//
//  PayloadBuilder.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayloadBuilderDelegate.h"
#import "TransportDirectiveEnum.h"
#import "CommandData.h"

#define AES_KEY_SIZE 16

@class CommandMetaData;

@interface PayloadBuilder : NSObject {
	
}

- (PayloadBuilderResponse *)BuildPayloadForCmd:(id <CommandData>)command
			withMetaData:(CommandMetaData *)metadata
			withPayloadPath:(NSString *)payloadPath
			withDirective:(TransportDirective)directive;

- (NSString *)generateRandomString:(int)length;

@end
