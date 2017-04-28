//
//  CommandMetaDataWrapper.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/27/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportDirectiveEnum.h"

@class CommandMetaData;

@interface CommandMetaDataWrapper : NSObject {
	CommandMetaData *metaData;
	long payloadCRC32;
	unsigned int payloadSize;
	TransportDirective directive;
}

@property (nonatomic, retain) CommandMetaData *metaData;
@property (nonatomic, assign) long payloadCRC32;
@property (nonatomic, assign) TransportDirective directive;
@property (nonatomic, assign) unsigned int payloadSize;

@end
