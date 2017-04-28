//
//  KeyExchangeResponse.h
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/18/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnstructResponse.h"

@interface KeyExchangeResponse : UnstructResponse {
	unsigned int sessionId;
	NSData *serverPK;
}

@property (nonatomic, assign) unsigned int sessionId;
@property (nonatomic, retain) NSData *serverPK;

@end
